<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="ETSClient.com.allinpay.ets.client" %>

<script runat="server">
    
    //不为空字段
    protected string inputCharset = "1"; //字符集，utf-8
    protected string pickupUrl = ""; //付款用户的取货地址
    protected string receiveUrl = ""; //服务器接受支付结果的后台地址
    protected string version = "v1.0"; //网关接收支付请求接口版本
    protected string signType = "1"; //签名类型，证书签名验证方式
    protected string merchantId = ""; //商户号
    protected string orderNo = ""; //商户订单号
    protected string orderAmount = ""; //商户订单金额
    protected string orderDatetime = ""; //商户订单提交时间
    protected string payType = "0"; //支付方式
    protected string language = "1"; //网关页面显示语言种类
    protected string productId = ""; //商品代码
    protected string productName = ""; //商品名称
    protected string productNum = ""; //商品数量
    protected string productPrice = ""; //商品价格
    public string key = ""; //key

    protected string payerName = ""; //付款人姓名
    protected string payerEmail = ""; //付款人邮件
    protected string payerTelephone = ""; //付款人电话
    protected string payerIDCard = ""; //付款人证件号
    protected string Pid = ""; //合作伙伴的商户号
    protected string orderCurrency = ""; //订单金额类型
    protected string orderExpireDatetime = ""; //订单过期时间
    protected string productDescription = ""; //商品描述
    protected string ext1 = ""; //扩展字段1
    protected string ext2 = ""; //扩展字段2
    protected string issuerId = ""; //发卡方代码
    protected string pan = ""; //付款人支付卡

    public RequestOrder requestOrder = new RequestOrder();
    public NameValueCollection _system = new NameValueCollection();
    
    protected void Page_Load(object sender, EventArgs e)
    {
        SetValue();
    }

    /// <summary>
    /// 设置提交信息
    /// </summary>
    private void SetValue()
    {
        _system = WebUtils.GetSystem();

        //付款用户的取货地址
        pickupUrl = WWWprefix + "pay/allinpay/receive.aspx";
        //服务器接受支付结果的后台地址
        receiveUrl = WWWprefix + "pay/allinpay/receive.aspx";
        //商户号
        if (_system["allinpaymid"] != null && _system["allinpaymid"].ToString() != "")
        {
            merchantId = _system["allinpaymid"].ToString();
        }
        //商户订单号
        if (Request.Form["orderNo"] != null && Request.Form["orderNo"].ToString() != "")
        {
            orderNo = Request.Form["orderNo"].ToString();
        }
        //商户订单金额
        if (Request.Form["orderAmount"] != null && Request.Form["orderAmount"].ToString() != "")
        {
            orderAmount = Request.Form["orderAmount"];
            int oa = 0;
            oa = Convert.ToInt32(Convert.ToDecimal(orderAmount) * 100);
            orderAmount = oa.ToString();
            if (OrderMethod.GetPayType(orderNo))
            {
                orderAmount = Convert.ToInt32(OrderMethod.GetPayPrice(orderNo) * 100).ToString();
            }
        }
        //商户订单提交时间
        DateTime dt = DateTime.Now;
        string ymd = dt.ToString("yyyyMMdd");
        string hms = dt.ToString("HHmmss");
        orderDatetime = ymd + hms;
        //商品代码
        //商品名称
        if (Request.Form["orderPid"] != null && Request.Form["orderPid"].ToString() != "")
        {
            productName = Request.Form["orderPid"];
        }
        //商品数量
        if (Request.Form["orderId"] != null && Request.Form["orderId"].ToString() != "")
        {
            productNum = Request.Form["orderId"];
        }
        //商品价格
        //key
        if (_system["allinpaysec"] != null && _system["allinpaysec"].ToString() != "")
        {
            key = _system["allinpaysec"].ToString();
        }

        requestOrder.setInputCharset(inputCharset);
        requestOrder.setPickupUrl(pickupUrl);
        requestOrder.setReceiveUrl(receiveUrl);
        requestOrder.setVersion(version);
        requestOrder.setSignType(signType);
        requestOrder.setMerchantId(merchantId);
        requestOrder.setOrderNo(orderNo);
        requestOrder.setOrderAmount(orderAmount);
        requestOrder.setOrderDatetime(orderDatetime);
        requestOrder.setPayType(payType);
        requestOrder.setLanguage(language);
        requestOrder.setProductId(productId);
        requestOrder.setProductName(productName);
        requestOrder.setProductNum(productNum);
        requestOrder.setProductPrice(productPrice);
        requestOrder.setKey(key);

        String srcMsg = requestOrder.getSrc();
        String signMsg = requestOrder.doSign();
    }
</script>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body onload="javascript:document.E_FORM.submit()">
    <form name="E_FORM" action="http://116.236.252.102:9090/gateway/index.do " method="post">
    <ul>
        <li>
            <input type="hidden" name="inputCharset" id="inputCharset" value="<%=requestOrder.getInputCharset()%>" /></li>
        <li>
            <input type="hidden" name="pickupUrl" id="serverUrl" value="<%=requestOrder.getPickupUrl()%>" /></li>
        <li>
            <input type="hidden" name="receiveUrl" id="receiveUrl" value="<%=requestOrder.getReceiveUrl()%>" /></li>
        <li>
            <input type="hidden" name="version" id="version" value="<%=requestOrder.getVersion() %>" /></li>
        <li>
            <input type="hidden" name="language" id="language" value="<%=requestOrder.getLanguage() %>" /></li>
        <li>
            <input type="hidden" name="signType" id="signType" value="<%=requestOrder.getSignType()%>" /></li>
        <li>
            <input type="hidden" name="merchantId" id="merchantId" value="<%=requestOrder.getMerchantId()%>" /></li>
        <li>
            <input type="hidden" name="payerName" id="payerName" value="<%=requestOrder.getPayerName()%>" /></li>
        <li>
            <input type="hidden" name="payerEmail" id="payerEmail" value="<%=requestOrder.getPayerEmail()%>" /></li>
        <li>
            <input type="hidden" name="payerTelephone" id="payerTelephone" value="<%=requestOrder.getPayerTelephone() %>" /></li>
        <li>
            <input type="hidden" name="pid" id="pid" value="<%=requestOrder.getPid() %>" /></li>
        <li>
            <input type="hidden" name="orderNo" id="orderNo" value="<%=requestOrder.getOrderNo() %>" /></li>
        <li>
            <input type="hidden" name="orderAmount" id="orderAmount" value="<%=requestOrder.getOrderAmount() %>" /></li>
        <li>
            <input type="hidden" name="orderCurrency" id="orderCurrency" value="<%=requestOrder.getOrderCurrency() %>" /></li>
        <li>
            <input type="hidden" name="orderDatetime" id="orderDatetime" value="<%=requestOrder.getOrderDatetime() %>" /></li>
        <li>
            <input type="hidden" name="orderExpireDatetime" id="orderExpireDatetime" value="<%=requestOrder.getOrderExpireDatetime() %>" /></li>
        <li>
            <input type="hidden" name="productName" id="productName" value="<%=requestOrder.getProductName() %>" /></li>
        <li>
            <input type="hidden" name="productPrice" id="productPrice" value="<%=requestOrder.getProductPrice() %>" /></li>
        <li>
            <input type="hidden" name="productNum" id="productNum" value="<%=requestOrder.getProductNum() %>" /></li>
        <li>
            <input type="hidden" name="productId" id="productId" value="<%=requestOrder.getProductId() %>" /></li>
        <li>
            <input type="hidden" name="productDescription" id="productDescription" value="" /></li>
        <li>
            <input type="hidden" name="ext1" id="ext1" value="<%=requestOrder.getExt1() %>" /></li>
        <li>
            <input type="hidden" name="ext2" id="ext2" value="<%=requestOrder.getExt2() %>" /></li>
        <li>
            <input type="hidden" name="payType" id="payType" value="<%=requestOrder.getPayType() %>" /></li>
        <li>
            <input type="hidden" name="issuerId" id="issuerId" value="<%=requestOrder.getIssuerId() %>" /></li>
        <li>
            <input type="hidden" name="srcMsg" id="srcMsg" value="<%=requestOrder.getSrc() %>" /></li>
        <li>
            <input type="hidden" name="signMsg" id="signMsg" value="<%=requestOrder.doSign() %>" /></li>
    </ul>
    </form>
</body>
</html>
