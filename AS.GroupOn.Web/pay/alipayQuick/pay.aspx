<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AlipayClass.alipayQuick" %>

<script runat="server">
    string partner = "";
    string key = "";
    string seller_email = "";
    string input_charset = "utf-8";
    string notify_url = "";
    string return_url = "";
    string sign_type = "MD5";
    string encrypt_key = ""; //防钓鱼时间戳，初始值
    string antiphishing = "0";//钓鱼功能
    string out_trade_no = "";
    string subject = "";
    string body = "";
    string total_fee = "";
    string exter_invoke_ip = ""; //获取客户端的IP地址，建议：编写获取客户端IP地址的程序(防钓鱼功能必填参数)
    string show_url = "";//商品展示地址，要用http:// 格式的完整路径，不允许加?id=123这类自定义参数
    string buyer_email = "";//默认买家支付宝账号
    string royalty_type = "";//提成类型，该值为固定值：10，不需要修改
    string royalty_parameters = "";//提成信息集
    string extra_common_param = "";//自定义参数，可存放任何内容（除=、&等特殊字符外），不会显示在页面上
    string paymethod = "";//默认支付方式，代码见“快捷支付接口”技术文档
    string defaultbank = ""; //默认网银代号，代号列表见“快捷支付接口”技术文档“附录”→“银行列表”

    ISystem systemmodel = null;
    NameValueCollection configs;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NeedLogin();
        if (!IsPostBack)
        {
            configs = WebUtils.GetSystem();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                systemmodel = session.System.GetByID(1);
            }
            setPublicValue();
            typePayMoney();

        }
    }
    /// <summary>
    /// 设置共用方法
    /// </summary>
    public void setPublicValue()
    {

        partner = systemmodel.alipaymid; //商户KEY
        key = systemmodel.alipaysec;//商户密锁
        seller_email = ASSystem.alipayacc;//签约支付宝账号或卖家支付宝帐户
        //请与贵网站订单系统中的唯一订单号匹配
        out_trade_no = Request.Form["out_trade_no"].ToString();
        //订单名称，显示在支付宝收银台里的“商品名称”里，显示在支付宝的交易管理的“商品名称”的列表里。
        subject = Request.Form["subject"].ToString();
        //订单描述、订单详细、订单备注，显示在支付宝收银台里的“商品描述”里
        body = Request.Form["body"].ToString();
        //订单总金额，显示在支付宝收银台里的“应付总额”里
        total_fee = Request.Form["total_fee"].ToString();
        //if (OrderMethod.GetPayType(out_trade_no))
        //    total_fee = OrderMethod.GetPayPrice(out_trade_no).ToString();

    }
    /// <summary>
    /// 设置其他方法
    /// </summary>
    public void typePayMoney()
    {

        paymethod = "bankPay";   //默认支付方式，四个值可选：bankPay(网银); cartoon(卡通); directPay(余额); CASH(网点支付)
        defaultbank = "CMB";    //默认网银代号，代号列表见http://club.alipay.com/read.php?tid=8681379
        if (antiphishing == "1")
        {
            encrypt_key = AlipayClass.AlipayFunction.Query_timestamp(partner);
            exter_invoke_ip = WebUtils.GetClientIP; //获取客户端的IP地址，建议：编写获取客户端IP地址的程序

        }
        //该功能默认不开通，需联系客户经理咨询
        string it_b_pay = "";  //超时时间，不填默认是15天。八个值可选：1h(1小时),2h(2小时),3h(3小时),1d(1天),3d(3天),7d(7天),15d(15天),1c(当天)
        extra_common_param = "";
        buyer_email = "";
        string url = "";
        notify_url = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "pay/alipay/notify.aspx"; //交易过程中服务器通知的页面 要用 http://格式的完整路径，不允许加?id=123这类自定义参数
        return_url = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "pay/alipay/returnurl.aspx"; //付完款后跳转的页面 要用 http://格式的完整路径，不允许加?id=123这类自定义参数
        if (configs["alipay_SecuredTransactions"] == "2") //使用双接口
        {
            //双接口
            AlipayClass.AlipayService_Dual aliService1 = new AlipayClass.AlipayService_Dual(partner, seller_email, return_url, notify_url, show_url, out_trade_no, subject, body, total_fee, "0.00", "EXPRESS", "SELLER_PAY", "1", String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, key, input_charset, CookieUtils.GetCookieValue("alipay_token"), sign_type);
            url = aliService1.Create_url();
        }
        else if (configs["alipay_SecuredTransactions"] == "1")
        {
            //使用担保交易
            AlipayClass.AlipaySecuredTransactionsService aliService = new AlipayClass.AlipaySecuredTransactionsService(partner, seller_email, return_url, notify_url, show_url, out_trade_no, subject, body, total_fee, "0", "EXPRESS", "SELLER_PAY", "1", String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, String.Empty, key, input_charset, sign_type);
            // url = aliService.Create_url();
            Response.Write(aliService.Create_url());
            Response.End();
        }
        else if (configs["alipay_SecuredTransactions"] == "0")
        {
            payMoney();
        }
        Response.Redirect(url);

    }
    private void payMoney()
    {
        ///////////////////////以下参数是需要通过下单时的订单数据传入进来获得////////////////////////////////
        //必填参数//
        //默认支付方式，代码见“快捷支付接口”技术文档
        paymethod = "motoPay";
        defaultbank = "CMB-MOTO-CREDIT";
        string anti_phishing_key = "";
        //扩展功能参数——防钓鱼//
        if (configs["alipay_anti_phishing"] == "1")
        {
            //防钓鱼时间戳
            Service aliQuery_timestamp = new Service();
            anti_phishing_key = aliQuery_timestamp.Query_timestamp();
            //获取客户端的IP地址，建议：编写获取客户端IP地址的程序
            exter_invoke_ip = WebUtils.GetClientIP;
        }
        //设置商户信息
        Config.Partner = partner;
        Config.Key = key;
        Config.Return_url = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "pay/alipay/returnurl.aspx";
        Config.Notify_url = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "pay/alipay/notify.aspx";
        Config.Token = CookieUtils.GetCookieValue("alipay_token");
        Config.Seller_email = systemmodel.alipayacc;
        
        //扩展功能参数——其他//
        //扩展功能参数——分润(若要使用，请按照注释要求的格式赋值)//
        //注意：
        //与需要结合商户网站自身情况动态获取每笔交易的各分润收款账号、各分润金额、各分润说明。最多只能设置10条
        //各分润金额的总和须小于等于total_fee
        //提成信息集格式为：收款方Email_1^金额1^备注1|收款方Email_2^金额2^备注2
        //示例：
        //royalty_type = "10";
        //royalty_parameters = "111@126.com^0.01^分润备注一|222@126.com^0.01^分润备注二";

        /////////////////////////////////////////////////////////////////////////////////////////////////////

        //构造快捷支付接口表单提交HTML数据，无需修改
        Service ali = new Service();
        string sHtmlText = ali.Create_direct_pay_by_userURL(
            out_trade_no,
            subject,
            body,
            total_fee,
            show_url,
            paymethod,
            defaultbank,
            anti_phishing_key,
            exter_invoke_ip,
            extra_common_param,
            buyer_email,
            royalty_type,
            royalty_parameters);
        string url = sHtmlText + "&seller_email=" + Server.UrlEncode(systemmodel.alipayacc);
        Response.Redirect(sHtmlText);

    }
       
</script>
