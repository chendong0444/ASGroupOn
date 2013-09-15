<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="ETSClient.com.allinpay.ets.client" %>

<script runat="server">
    //不为空字段
    protected string merchantId = ""; //商户号
    protected string version = ""; //网关返回支付结果接口版本
    protected string signType = ""; //签名类型
    protected string paymentOrderId = ""; //支付订单号
    protected string orderNo = ""; //商户订单号
    protected string orderDatetime = ""; //商户订单提交时间
    protected string orderAmount = ""; //商户订单金额
    protected string payDatetime = ""; //支付完成时间
    protected string payAmount = ""; //订单实际支付金额
    protected string payResult = ""; //处理结果
    protected string returnDatetime = ""; //结果返回时间
    protected string signMsg = ""; //签名字符串

    //表单参数
    protected string language = ""; //网页显示语言种类
    protected string payType = ""; //支付方式
    protected string issuerId = ""; //发卡方机构代码

    protected string ext1 = ""; //扩展字段1
    protected string ext2 = ""; //扩展字段2
    protected string errorCode = ""; //错误代码

    public String verifySrc = null;
    public bool verifyResult = false;
    public PaymentResult paymentResult = new PaymentResult();
    
    protected void Page_Load(object sender, EventArgs e)
    {
        merchantId = Request.Form["merchantId"]; //商户号
        version = Request.Form["version"]; //网关返回支付结果接口版本
        signType = Request.Form["signType"]; //签名类型
        paymentOrderId = Request.Form["paymentOrderId"]; //支付订单号
        orderNo = Request.Form["orderNo"]; //商户订单号
        orderDatetime = Request.Form["orderDatetime"]; //商户订单提交时间
        orderAmount = Request.Form["orderAmount"]; //商户订单金额
        payDatetime = Request.Form["payDatetime"]; //支付完成时间
        payAmount = Request.Form["payAmount"]; //订单实际支付金额
        payResult = Request.Form["payResult"]; //处理结果
        returnDatetime = Request.Form["returnDatetime"]; //结果返回时间
        signMsg = Request.Form["signMsg"]; //签名字符串
        language = Request.Form["language"];
        payType = Request.Form["payType"];
        issuerId = Request.Form["issuerId"];
        errorCode = Request.Form["errorCode"];
        ext1 = Request.Form["ext1"];
        ext2 = Request.Form["ext2"];

        paymentResult.setMerchantId(merchantId);
        paymentResult.setVersion(version);
        paymentResult.setSignType(signType);
        paymentResult.setPaymentOrderId(paymentOrderId);
        paymentResult.setOrderNo(orderNo);
        paymentResult.setOrderDatetime(orderDatetime);
        paymentResult.setOrderAmount(orderAmount);
        paymentResult.setPayDatetime(payDatetime);
        paymentResult.setPayAmount(payAmount);
        paymentResult.setPayResult(payResult);
        paymentResult.setReturnDatetime(returnDatetime);
        paymentResult.setSignMsg(signMsg);
        paymentResult.setLanguage(language);
        paymentResult.setExt1(ext1);
        paymentResult.setExt2(ext2);
        paymentResult.setPayType(payType);
        paymentResult.setIssuerId(issuerId);
        paymentResult.setErrorCode(errorCode);

        this.verifySrc = paymentResult.getVerifySrc(); //签名源串
        this.verifyResult = paymentResult.verify();    //验签

        if (this.verifyResult)
        {
            //1为支付成功,0为支付失败
            if (payResult == "1")
            {
                //修改订单状态
                OrderMethod.Updateorder(orderNo, (Convert.ToDecimal(orderAmount) / 100).ToString(), "allinpay", null);
                Response.Redirect(GetUrl("支付通知", "order_success.aspx?id=" + orderNo));
            }
            else
            {
                Response.Write("支付失败！");
            }
        }
        else
        {
            Response.Write("验签失败！");
        }
    }
</script>