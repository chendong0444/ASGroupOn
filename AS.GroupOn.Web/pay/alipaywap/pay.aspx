<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="Asdht.Wap.Alipay.Class" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        MobileNeedLogin();
        if (!IsPostBack)
        {
            submit();
        }
    }
    private void submit()
    {
        //支付宝网关地址
        string GATEWAY_NEW = "http://wappaygw.alipay.com/service/rest.htm?";

        ////////////////////////////////////////////调用授权接口alipay.wap.trade.create.direct获取授权码token////////////////////////////////////////////

        //返回格式
        string format = "xml";
        //必填，不需要修改

        //返回格式
        string v = "2.0";
        //必填，不需要修改

        //请求号
        string req_id = DateTime.Now.ToString("yyyyMMddHHmmss");
        //必填，须保证每次请求都是唯一

        //req_data详细信息

        //服务器异步通知页面路径
        string notify_url = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "pay/alipaywap/notify.aspx";
        //需http://格式的完整路径，不允许加?id=123这类自定义参数

        //页面跳转同步通知页面路径
        string call_back_url = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "pay/alipaywap/returnurl.aspx";
        //需http://格式的完整路径，不允许加?id=123这类自定义参数

        //卖家支付宝帐户
        string seller_email = ASSystem.alipayacc;
        //必填

        //商户订单号
        string out_trade_no = Request.Form["out_trade_no"].ToString().Trim();
        //商户网站订单系统中唯一订单号，必填

        //订单名称
        string subject = Request.Form["subject"].ToString();
        //必填

        //付款金额
        string total_fee = Request.Form["total_fee"];  
        //必填

        //请求业务参数详细
        string req_dataToken = "<direct_trade_create_req><notify_url>" + notify_url + "</notify_url><call_back_url>" + call_back_url + "</call_back_url><seller_account_name>" + seller_email + "</seller_account_name><out_trade_no>" + out_trade_no + "</out_trade_no><subject>" + subject + "</subject><total_fee>" + total_fee + "</total_fee></direct_trade_create_req>";
        //必填

        Config.Key = ASSystem.alipaysec;
        Config.Partner = ASSystem.alipaymid;
        //把请求参数打包成数组
        System.Collections.Generic.Dictionary<string, string> sParaTempToken = new System.Collections.Generic.Dictionary<string, string>();
        sParaTempToken.Add("partner", Config.Partner);
        sParaTempToken.Add("_input_charset", Config.Input_charset.ToLower());
        sParaTempToken.Add("sec_id", Config.Sign_type.ToUpper());
        sParaTempToken.Add("service", "alipay.wap.trade.create.direct");
        sParaTempToken.Add("format", format);
        sParaTempToken.Add("v", v);
        sParaTempToken.Add("req_id", req_id);
        sParaTempToken.Add("req_data", req_dataToken);

        //建立请求
        string sHtmlTextToken = Submit.BuildRequest(GATEWAY_NEW, sParaTempToken);
        //URLDECODE返回的信息
        Encoding code = Encoding.GetEncoding(Config.Input_charset);
        sHtmlTextToken = HttpUtility.UrlDecode(sHtmlTextToken, code);

        //解析远程模拟提交后返回的信息
        System.Collections.Generic.Dictionary<string, string> dicHtmlTextToken = Submit.ParseResponse(sHtmlTextToken);

        //获取token
        string request_token = dicHtmlTextToken["request_token"];

        ////////////////////////////////////////////根据授权码token调用交易接口alipay.wap.auth.authAndExecute////////////////////////////////////////////


        //业务详细
        string req_data = "<auth_and_execute_req><request_token>" + request_token + "</request_token></auth_and_execute_req>";
        //必填

        //把请求参数打包成数组
        System.Collections.Generic.Dictionary<string, string> sParaTemp = new System.Collections.Generic.Dictionary<string, string>();
        sParaTemp.Add("partner", Config.Partner);
        sParaTemp.Add("_input_charset", Config.Input_charset.ToLower());
        sParaTemp.Add("sec_id", Config.Sign_type.ToUpper());
        sParaTemp.Add("service", "alipay.wap.auth.authAndExecute");
        sParaTemp.Add("format", format);
        sParaTemp.Add("v", v);
        sParaTemp.Add("req_data", req_data);

        //建立请求
        string sHtmlText = Submit.BuildRequest(GATEWAY_NEW, sParaTemp, "get", "确认");
        Response.Write(sHtmlText);
    }
</script>
