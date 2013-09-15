<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AlipayClass.alipay_oauth" %>
<%@ Import Namespace="System.Xml" %>

<script runat="server">
    NameValueCollection configs = null;
    string user_id = "";
    string token = "";
    string username = "";
    //ucenter返回的对象
    protected AS.ucenter.RetrunClass retrunclass = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        configs = AS.GroupOn.Controls.PageValue.CurrentSystemConfig;
        System.Collections.Generic.SortedDictionary<string, string> sArrary = GetRequestGet();

        if (sArrary.Count > 0)//判断是否有带返回参数
        {

            Config.Key = ASSystem.alipaysec;
            Config.Partner = ASSystem.alipaymid;
            Notify aliNotify = new Notify(sArrary, Request.QueryString["notify_id"]);

            //获取远程服务器ATN结果，验证是否是支付宝服务器发来的请求
            string responseTxt = aliNotify.ResponseTxt;
            //获取支付宝反馈回来的sign结果
            string sign = Request.QueryString["sign"];
            //获取通知返回后计算后（验证）的签名结果
            string mysign = aliNotify.Mysign;
            //写日志记录（若要调试，请取消下面两行注释）
            //string sWord = "responseTxt=" + responseTxt + "\n return_url_log:sign=" + Request.QueryString["sign"] + "&mysign=" + mysign + "\n return回来的参数：" + aliNotify.PreSignStr;
            //Function.LogResult(sWord);

            //判断responsetTxt是否为ture，生成的签名结果mysign与获得的签名结果sign是否一致
            //responsetTxt的结果不是true，与服务器设置问题、合作身份者ID、notify_id一分钟失效有关
            //mysign与sign不等，与安全校验码、请求时的参数格式（如：带自定义参数等）、编码格式有关
            //Response.Write(responseTxt + "<br>");
            //Response.Write(sign+"<br>");
            //Response.Write(mysign+"<br>");
            if (responseTxt == "true" && sign == mysign)//验证成功
            {

                /////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //请在这里加上商户的业务逻辑程序代码
                //——请根据您的业务逻辑来编写程序（以下代码仅作参考）——
                //获取支付宝的通知返回参数，可参考技术文档中页面跳转同步通知参数列表
                user_id = Request.QueryString["user_id"];//支付宝用户id
                token = Request.QueryString["token"];	//授权令牌

                //执行商户的业务程序

                //创建用户名
                string email = "支付宝用户_" + user_id + "@sina.com";
                if (Request["email"] != null)
                    email = Helper.GetString(Request["email"], String.Empty);
                username = "支付宝用户_" + user_id;
                CookieUtils.SetCookie("alipay_token", token);
                string url = String.Empty;
                if (Request["target_url"] != null)
                {
                    url = Request["target_url"];
                    SetRefer(url);
                }
                string real_name = Helper.GetString(Request.QueryString["real_name"], String.Empty);
                AS.Ucenter.YizhantongVerifier.YizhantongLogin(AS.Enum.YizhantongState.支付宝接口 + "_" + user_id, String.Empty, email, AS.Enum.YizhantongState.支付宝接口, real_name, Helper.GetString(AS.GroupOn.Controls.PageValue.CurrentSystemConfig["UC_Islogin"], "0"), this, url);

                //——请根据您的业务逻辑来编写程序（以上代码仅作参考）——

                /////////////////////////////////////////////////////////////////////////////////////////////////////////////
            }
            else//验证失败
            {
                SetError("登录失败");
            }
        }
        else
        {
            SetError("登录失败");
        }
        //Response.Redirect(GetRefer());
        //Response.End();
    }
    /// <summary>
    /// 获取支付宝GET过来通知消息，并以“参数名=参数值”的形式组成数组
    /// </summary>
    /// <returns>request回来的信息组成的数组</returns>
    public System.Collections.Generic.SortedDictionary<string, string> GetRequestGet()
    {
        int i = 0;
        System.Collections.Generic.SortedDictionary<string, string> sArray = new System.Collections.Generic.SortedDictionary<string, string>();
        NameValueCollection coll;
        //Load Form variables into NameValueCollection variable.
        coll = Request.QueryString;

        // Get names of all forms into a string array.
        String[] requestItem = coll.AllKeys;

        for (i = 0; i < requestItem.Length; i++)
        {
            sArray.Add(requestItem[i], Request.QueryString[requestItem[i]]);
        }

        return sArray;
    }
</script>