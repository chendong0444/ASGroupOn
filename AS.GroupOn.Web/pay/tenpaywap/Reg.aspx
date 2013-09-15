<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="Asdht.Wap.tenpay" %>
<script runat="server">
    ISystem system = null;
    public string fare = "0";
    public string product_fee = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        MobileNeedLogin();
        if (Request.Form["out_trade_no"] != null && Request.Form["out_trade_no"].ToString() != "")
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                system = session.System.GetByID(1);
            }
            if (system != null && Request.Form["total_fee"] != null && system.tenpaymid != "" && system.tenpaysec != "" && Request.Form["total_fee"].ToString() != "")
            {
                string payid = Helper.GetString(Request.Form["out_trade_no"], String.Empty);
                string total_price = "9999999";//支付金额
                if (OrderMethod.GetPayType(payid))
                {
                    //订单
                    total_price = GetMoney((Convert.ToDecimal(Request.Form["total_fee"]) * 100).ToString());
                }
                setNameVer(system.tenpaymid, system.tenpaysec, payid, total_price, fare, product_fee);

            }
        }

    }
    private void setNameVer(string partnerid, string tenpaykey, string payId, string money, string fare, string product_fee)
    {
        //商户号
        string bargainor_id = partnerid;
        //密钥
        string key = tenpaykey;
        //创建请求对象
        RequestHandler reqHandler = new RequestHandler(Context);
        //通信对象
        TenpayHttpClient httpClient = new TenpayHttpClient();
        //应答对象
        ClientResponseHandler resHandler = new ClientResponseHandler();
        //当前时间 yyyyMMdd
        string date = DateTime.Now.ToString("yyyyMMdd");
        //订单号，此处用时间和随机数生成，商户根据自己调整，保证唯一
        string sp_billno = payId;
        reqHandler.init();
        //设置密钥
        reqHandler.setKey(key);
        reqHandler.setGateUrl("https://wap.tenpay.com/cgi-bin/wappayv2.0/wappay_init.cgi");
        //-----------------------------
        //设置支付初始化参数
        //-----------------------------
        //版本号,ver默认值是1.0。目前版本ver取值应为2.0
        reqHandler.setParameter("ver", "2.0");
        //1 UTF-8, 2 GB2312, 默认为1 UTF-8
        reqHandler.setParameter("charset", "1");
        //银行类型:财付通支付填0
        reqHandler.setParameter("bank_type", "0");
        //商品描述
        reqHandler.setParameter("desc", StringUtils.SubString(Helper.GetString(Request["subject"], String.Empty), 32));
        //商户号,由财付通统一分配的10位正整数(120XXXXXXX)号
        reqHandler.setParameter("bargainor_id", bargainor_id);
        //商户系统内部的定单号,32个字符内、可包含字母
        reqHandler.setParameter("sp_billno", sp_billno);
        //总金额,以分为单位,不允许包含任何字、符号
        reqHandler.setParameter("total_fee", money);
        //现金支付币种,目前只支持人民币,默认值是1-人民币
        reqHandler.setParameter("fee_type", "1");
        //交易完成后跳转的URL,需给绝对路径，255字符内格式如:http://wap.tenpay.com/tenpay.asp
        reqHandler.setParameter("notify_url", WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "pay/tenpaywap/notify_url.aspx");
        //接收财付通通知的URL,需给绝对路径，255字符内格式如:http://wap.tenpay.com/tenpay.asp
        reqHandler.setParameter("callback_url", WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "pay/tenpaywap/callback_url.aspx");
        //交易完成后跳转的URL,需给绝对路径
        reqHandler.setParameter("attach", WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + GetUrl("手机版支付通知", "return_credit.aspx") + payId);
        string initRequestUrl = reqHandler.getRequestURL();
        //设置请求内容
        httpClient.setReqContent(initRequestUrl);
        //设置超时
        httpClient.setTimeOut(5);
        string rescontent = "";
        string payRequestUrl = "";
        //后台调用
        if (httpClient.call())
        {
            //获取结果
            rescontent = httpClient.getResContent();
            //设置结果参数
            resHandler.setContent(rescontent);
            string token_id = resHandler.getParameter("token_id");
            //成功，则token_id有只
            if (token_id != "")
            {
                //生成支付请求
                payRequestUrl = "https://wap.tenpay.com/cgi-bin/wappayv2.0/wappay_gate.cgi?token_id=" + tenpay.TenpayUtil.UrlEncode(token_id, Request.ContentEncoding.BodyName);
                //Get的实现方式
                Response.Redirect(payRequestUrl);
                Response.End();
            }
            else
            {
                //获取token_id调用失败 ，显示错误 页面
                Response.Write("支付初始化错误:" + resHandler.getParameter("err_info") + "<br>");
            }

        }
        else
        {
            //后台调用通信失败
            Response.Write("call err:" + httpClient.getErrInfo() + "<br>" + httpClient.getResponseCode() + "<br>");
            //有可能因为网络原因，请求已经处理，但未收到应答。
        }
    }
</script>
