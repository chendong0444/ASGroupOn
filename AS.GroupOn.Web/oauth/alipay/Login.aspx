<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AlipayClass.alipay_oauth" %>

<script runat="server">
    ISystem sysmodel = null;
    private static string GATEWAY_NEW = "https://mapi.alipay.com/gateway.do?";
    private static string _input_charset = "utf-8";
    private static string _sign_type = "";
    private static string _key = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        ////////////////////////////////////////////请求参数/////////////////////////////////////////////////
        //扩展功能参数——防钓鱼//
        //防钓鱼时间戳
        string anti_phishing_key = "";
        //获取客户端的IP地址，建议：编写获取客户端IP地址的程序
        string exter_invoke_ip = "";
        //注意：
        //请慎重选择是否开启防钓鱼功能
        //exter_invoke_ip、anti_phishing_key一旦被设置过，那么它们就会成为必填参数
        //建议使用POST方式请求数据
        //示例：
        //exter_invoke_ip = "";
        //Service aliQuery_timestamp = new Service();
        //anti_phishing_key = aliQuery_timestamp.Query_timestamp();               //获取防钓鱼时间戳函数

        string target_service = "user.auth.quick.login";
        /////////////////////////////////////////////////////////////////////////////////////////////////////

        //构造快捷登录接口表单提交HTML数据，无需修改
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            sysmodel = session.System.GetByID(1);
        }
        string shtmlUrl = "";
        NameValueCollection configs = PageValue.CurrentSystemConfig;

        //1.判断是否运用了支付宝的一站通
        if (configs["Isalipaylogin"] == "1")
        {
            _key = sysmodel.alipaysec;
            _sign_type = "MD5";
            //把请求参数打包成数组
            System.Collections.Generic.SortedDictionary<string, string> sParaTemp = new System.Collections.Generic.SortedDictionary<string, string>();
            sParaTemp.Add("partner", sysmodel.alipaymid);
            sParaTemp.Add("_input_charset", "utf-8");
            sParaTemp.Add("service", "alipay.auth.authorize");
            sParaTemp.Add("target_service", target_service);
            sParaTemp.Add("return_url", WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "oauth/alipay/callback.aspx");
            sParaTemp.Add("anti_phishing_key", anti_phishing_key);
            sParaTemp.Add("exter_invoke_ip", exter_invoke_ip);

            //建立请求
            string sHtmlText = BuildRequest(sParaTemp, "get", "确认");
            Response.Write(sHtmlText);
        }
    }
    public static string BuildRequest(System.Collections.Generic.SortedDictionary<string, string> sParaTemp, string strMethod, string strButtonValue)
    {
        //待请求参数数组
        System.Collections.Generic.Dictionary<string, string> dicPara = new System.Collections.Generic.Dictionary<string, string>();
        dicPara = BuildRequestPara(sParaTemp);

        StringBuilder sbHtml = new StringBuilder();

        sbHtml.Append("<form id='alipaysubmit' name='alipaysubmit' action='" + GATEWAY_NEW + "_input_charset=" + _input_charset + "' method='" + strMethod.ToLower().Trim() + "'>");

        foreach (System.Collections.Generic.KeyValuePair<string, string> temp in dicPara)
        {
            sbHtml.Append("<input type='hidden' name='" + temp.Key + "' value='" + temp.Value + "'/>");
        }

        //submit按钮控件请不要含有name属性
        sbHtml.Append("<input type='submit' value='" + strButtonValue + "' style='display:none;'></form>");

        sbHtml.Append("<script>document.forms['alipaysubmit'].submit();</"+"script>");

        return sbHtml.ToString();
    }

    /// <summary>
    /// 生成要请求给支付宝的参数数组
    /// </summary>
    /// <param name="sParaTemp">请求前的参数数组</param>
    /// <returns>要请求的参数数组</returns>
    private static System.Collections.Generic.Dictionary<string, string> BuildRequestPara(System.Collections.Generic.SortedDictionary<string, string> sParaTemp)
    {
        //待签名请求参数数组
        System.Collections.Generic.Dictionary<string, string> sPara = new System.Collections.Generic.Dictionary<string, string>();
        //签名结果
        string mysign = "";

        //过滤签名参数数组
        sPara = FilterPara(sParaTemp);

        //获得签名结果
        mysign = BuildRequestMysign(sPara);

        //签名结果与签名方式加入请求提交参数组中
        sPara.Add("sign", mysign);
        sPara.Add("sign_type", _sign_type);

        return sPara;
    }
    /// <summary>
    /// 除去数组中的空值和签名参数并以字母a到z的顺序排序
    /// </summary>
    /// <param name="dicArrayPre">过滤前的参数组</param>
    /// <returns>过滤后的参数组</returns>
    public static System.Collections.Generic.Dictionary<string, string> FilterPara(System.Collections.Generic.SortedDictionary<string, string> dicArrayPre)
    {
        System.Collections.Generic.Dictionary<string, string> dicArray = new System.Collections.Generic.Dictionary<string, string>();
        foreach (System.Collections.Generic.KeyValuePair<string, string> temp in dicArrayPre)
        {
            if (temp.Key.ToLower() != "sign" && temp.Key.ToLower() != "sign_type" && temp.Value != "" && temp.Value != null)
            {
                dicArray.Add(temp.Key, temp.Value);
            }
        }

        return dicArray;
    }
    /// <summary>
    /// 生成请求时的签名
    /// </summary>
    /// <param name="sPara">请求给支付宝的参数数组</param>
    /// <returns>签名结果</returns>
    private static string BuildRequestMysign(System.Collections.Generic.Dictionary<string, string> sPara)
    {
        //把数组所有元素，按照“参数=参数值”的模式用“&”字符拼接成字符串
        string prestr = CreateLinkString(sPara);
        string _sign_type = "MD5";
        //把最终的字符串签名，获得签名结果
        string mysign = "";
        switch (_sign_type)
        {
            case "MD5":
                mysign = Sign(prestr, _key, _input_charset);
                break;
            default:
                mysign = "";
                break;
        }

        return mysign;
    }
    /// <summary>
    /// 签名字符串
    /// </summary>
    /// <param name="prestr">需要签名的字符串</param>
    /// <param name="key">密钥</param>
    /// <param name="_input_charset">编码格式</param>
    /// <returns>签名结果</returns>
    public static string Sign(string prestr, string key, string _input_charset)
    {
        StringBuilder sb = new StringBuilder(32);

        prestr = prestr + key;

        System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
        byte[] t = md5.ComputeHash(Encoding.GetEncoding(_input_charset).GetBytes(prestr));
        for (int i = 0; i < t.Length; i++)
        {
            sb.Append(t[i].ToString("x").PadLeft(2, '0'));
        }

        return sb.ToString();
    }
    /// <summary>
    /// 把数组所有元素，按照“参数=参数值”的模式用“&”字符拼接成字符串
    /// </summary>
    /// <param name="sArray">需要拼接的数组</param>
    /// <returns>拼接完成以后的字符串</returns>
    public static string CreateLinkString(System.Collections.Generic.Dictionary<string, string> dicArray)
    {
        StringBuilder prestr = new StringBuilder();
        foreach (System.Collections.Generic.KeyValuePair<string, string> temp in dicArray)
        {
            prestr.Append(temp.Key + "=" + temp.Value + "&");
        }

        //去掉最後一個&字符
        int nLen = prestr.Length;
        prestr.Remove(nLen - 1, 1);

        return prestr.ToString();
    }
</script>