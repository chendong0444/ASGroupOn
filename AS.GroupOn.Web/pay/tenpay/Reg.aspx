<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AlipayClass.alipayQuick" %>
<%@ Import Namespace="tenpay" %>

<script runat="server">
    ISystem system = null;
    public NameValueCollection _system = new NameValueCollection();
    public string bank_type = String.Empty;
    public string fare = "0";
    public string product_fee = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NeedLogin();
        _system = WebUtils.GetSystem();
        if (Request.Form["out_trade_no"] != null && Request.Form["out_trade_no"].ToString() != "")
        {
            bank_type = Helper.GetString(Request["bank_type"], String.Empty);
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
                else
                {
                    //充值
                    total_price = (Convert.ToDecimal(Request.Form["total_fee"]) * 100).ToString();
                }
                setNameVer(system.tenpaymid, system.tenpaysec, Request.Form["out_trade_no"].ToString(), total_price, fare, product_fee);

            }
        }

    }

    private void setNameVer(string partnerid, string tenpaykey, string payId, string money, string fare, string product_fee)
    {
        //商户号
        string partner = partnerid;
        //密钥
        string key = tenpaykey;
        //当前时间 yyyyMMdd
        string date = DateTime.Now.ToString("yyyyMMdd");
        //订单号，此处用时间和随机数生成，商户根据自己调整，保证唯一
        //string out_trade_no = payId + DateTime.Now.ToString("HHmmss") + TenpayUtil.BuildRandomStr(4);
        string out_trade_no = payId;
        //创建RequestHandler实例
        RequestHandler reqHandler = new RequestHandler(Context);
        //初始化
        reqHandler.init();
        //设置密钥
        reqHandler.setKey(key);
        reqHandler.setGateUrl("https://gw.tenpay.com/gateway/pay.htm");
        //-----------------------------
        //设置支付参数
        //-----------------------------
        reqHandler.setParameter("partner", partner);		        //商户号
        reqHandler.setParameter("out_trade_no", out_trade_no);		//商家订单号
        reqHandler.setParameter("total_fee", money);			        //商品金额,以分为单位
        reqHandler.setParameter("return_url", WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "pay/tenpay/callback.aspx");		    //交易完成后跳转的URL
        reqHandler.setParameter("notify_url", WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "pay/tenpay/notify_url.aspx");		    //接收财付通通知的URL
        reqHandler.setParameter("body", StringUtils.SubString(Helper.GetString(Request["subject"], String.Empty), 32));	                    //商品描述
        if (bank_type != String.Empty)
        {
            if (!NumberUtils.IsNum(bank_type))
            {
                bank_type = "DEFAULT";
            }
            else
            {
                reqHandler.setParameter("bank_type", bank_type);		    //银行类型(中介担保时此参数无效)
            }
        }
        else
        {
            reqHandler.setParameter("bank_type", "DEFAULT");		    //银行类型(中介担保时此参数无效)  
        }
        reqHandler.setParameter("spbill_create_ip", GetClientIP);   //用户的公网ip，不是商户服务器IP
        reqHandler.setParameter("fee_type", "1");
        //币种，1人民币

        ///////////////////////////////////////////////
        reqHandler.setParameter("subject", StringUtils.SubString(Helper.GetString(Request["subject"], String.Empty), 32));              //商品名称(中介交易时必填)
        ///////////////////////////////////////////////


        //系统可选参数
        reqHandler.setParameter("sign_type", "MD5");
        reqHandler.setParameter("service_version", "1.0");
        reqHandler.setParameter("input_charset", "UTF-8");
        reqHandler.setParameter("sign_key_index", "1");

        //业务可选参数

       
        //附加数据，原样返回
        reqHandler.setParameter("attach", money);
        reqHandler.setParameter("product_fee", "0");                 //商品费用，必须保证transport_fee + product_fee=total_fee
        reqHandler.setParameter("transport_fee", "0");

        //物流费用，必须保证transport_fee + product_fee=total_fee
        reqHandler.setParameter("time_start", DateTime.Now.ToString("yyyyMMddHHmmss"));            //订单生成时间，格式为yyyymmddhhmmss
        reqHandler.setParameter("time_expire", "");                 //订单失效时间，格式为yyyymmddhhmmss
        reqHandler.setParameter("buyer_id", "");                    //买方财付通账号
        reqHandler.setParameter("goods_tag", "");                   //商品标记
        ///////2.28添加是否为担保交易
        if (_system["is_Certify_Tenpay"] == "0" || _system["is_Certify_Tenpay"] == "" || _system == null)
        {
            reqHandler.setParameter("trade_mode", "1");
        }
        else if (_system["is_Certify_Tenpay"] == "1")
        {
            reqHandler.setParameter("trade_mode", "2");      //交易模式，1即时到账(默认)，2中介担保，3后台选择（买家进支付中心列表选择）
        }
        reqHandler.setParameter("transport_desc", "");              //物流说明
        reqHandler.setParameter("trans_type", "1");                  //交易类型，1实物交易，2虚拟交易
        reqHandler.setParameter("agentid", "");                     //平台ID
        reqHandler.setParameter("agent_type", "");                  //代理模式，0无代理(默认)，1表示卡易售模式，2表示网店模式
        reqHandler.setParameter("seller_id", "");                   //卖家商户号，为空则等同于partner
        //获取请求带参数的url
        string requestUrl = reqHandler.getRequestURL();
        Response.Redirect(requestUrl);
    }
    public static string getRealIp()
    {
        string UserIP;
        if (HttpContext.Current.Request.ServerVariables["HTTP_VIA"] != null) //得到穿过代理服务器的ip地址
        {
            UserIP = HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"].ToString();
        }
        else
        {
            UserIP = HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"].ToString();
        }
        return UserIP;
    }
    public static string GetClientIP
    {
        get
        {
            if (HttpContext.Current.Items["clientip"] == null)
            {
                Regex regex = new Regex("([1-9]|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])(\\.(\\d|[1-9]\\d|1\\d{2}|2[0-4]\\d|25[0-5])){3}");
                string clientIp = Helper.GetString(HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"], String.Empty);
                if (HttpContext.Current.Request.ServerVariables["HTTP_CDN_SRC_IP"] != null && regex.IsMatch(HttpContext.Current.Request.ServerVariables["HTTP_CDN_SRC_IP"]))
                {
                    clientIp = Helper.GetString(HttpContext.Current.Request.ServerVariables["HTTP_CDN_SRC_IP"], String.Empty);
                }
                else if (HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"] != null && regex.IsMatch(HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"]))
                {
                    clientIp = Helper.GetString(HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"], String.Empty);
                }
                string[] ip = clientIp.Split(',');
                HttpContext.Current.Items["clientip"] = ip[0];
                return ip[0];
            }
            else
            {
                return HttpContext.Current.Items["clientip"] as string;
            }
        }
    }
</script>
