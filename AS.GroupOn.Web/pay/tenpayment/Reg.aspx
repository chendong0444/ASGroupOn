<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AlipayClass.alipay_oauth" %>
<%@ Import Namespace="tenpay" %>

<script runat="server">
    ISystem system = null;
    public string values;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NeedLogin();
        if (Request.Form["out_trade_no"] != null && Request.Form["out_trade_no"].ToString() != "")
        {
            values = Request["bank_type"];
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
                    total_price = Convert.ToInt32(((OrderMethod.GetPayPrice(payid)) * 100)).ToString();
                }
                else
                    total_price = (Convert.ToDecimal(Request.Form["total_fee"]) * 100).ToString();


                setName(system.tenpaymid, system.tenpaysec, Request.Form["out_trade_no"].ToString(), total_price);
                // setName(system.certifytenpaymid, system.certifytenpaysec, Request.Form["out_trade_no"].ToString(), total_price);

            }
        }

    }

    //创建PayRequestHandler实例
    MediPayRequest reqHandler;
    /// <summary>
    /// 设置参数
    /// </summary>
    /// <param name="bargainor_id1">商户号</param>
    /// <param name="key1">商户密码</param>
    /// <param name="payId">网银支付订单号</param>
    /// <param name="money">金额</param>
    private void setName(string bargainor_id1, string key1, string payId, string money)
    {
        //商户号
        string chnid = bargainor_id1;

        //密钥
        string key = key1;

        //当前时间 yyyyMMdd
        string date = DateTime.Now.ToString("yyyyMMdd");

        //生成订单10位序列号，此处用时间和随机数生成，商户根据自己调整，保证唯一
        string strReq = "" + DateTime.Now.ToString("HHmmss") + TenpayUtil.BuildRandomStr(4);

        //商户订单号，不超过32位，财付通只做记录，不保证唯一性

        string mch_vno = payId;

        //财付通订单号，10位商户号+8位日期+10位序列号，需保证全局唯一
        string transaction_id = chnid + date + strReq;
        string mch_price = money;
        //Utils.Helper.SubString(Utils.Helper.GetString(Request["subject"], String.Empty), 32)
        string mch_name = StringUtils.SubString(Helper.GetString(Request["subject"], String.Empty), 20).ToString();
        string mch_returl = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "order/tenpayment/callback.aspx";
        string show_url = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + GetUrl("支付通知", "order_success.aspx?id=" + payId);
        //创建PayRequestHandler实例
        MediPayRequest reqHandler = new MediPayRequest(Context);

        //设置密钥
        reqHandler.setKey(key);
        //s = reqHandler.setKey(key);
        //初始化
        reqHandler.init();
        reqHandler.setGateUrl("https://www.tenpay.com/cgi-bin/med/show_opentrans.cgi");
        //-----------------------------
        //设置支付参数
        //-----------------------------
        reqHandler.setParameter("chnid", chnid);				//平台商户号
        reqHandler.setParameter("seller", chnid);				//卖家商户号
        reqHandler.setParameter("mch_vno", mch_vno);				//商家订单号
        reqHandler.setParameter("mch_returl", mch_returl);		//支付通知url
        reqHandler.setParameter("show_url", show_url);			//支付结果显示页面
        reqHandler.setParameter("mch_name", mch_name);			//商品名称
        reqHandler.setParameter("mch_desc", "tenpay");		//交易说明
        reqHandler.setParameter("mch_price", mch_price);				//商品金额,以分为单位
        reqHandler.setParameter("encode_type", "1");				//编码类型：1,gb2312 2,utf-8
        reqHandler.setParameter("transport_desc", " 无");	//物流说明
        reqHandler.setParameter("transport_fee", "0");			//物流费用
        reqHandler.setParameter("need_buyerinfo", "2");			//是否需要在财付通填定物流信息，1：需要，2：不需要
        reqHandler.setParameter("mch_type", "2");				//交易类型：1、实物交易，2、虚拟交易
        reqHandler.setParameter("attach", "");				//商户自定义参数
        // System.IO.File.AppendAllText(AppDomain.CurrentDomain.BaseDirectory + "财付通.txt", "key值：" +key  + "--\r\n");
        //获取请求带参数的url
        string requestUrl = reqHandler.getRequestURL();
        Response.Redirect(requestUrl);


    }
</script>
