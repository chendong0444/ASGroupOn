<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn.Controls" %>

<script runat="server">
    public string cashNo = "";
    public string cashAmount = "";
    public string cashId = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        NeedLogin();
        Cash();
    }

    //货到付款
    private void Cash()
    {
        if (Request.Form["cashNo"] != null && Request.Form["cashNo"].ToString() != "")
        {
            cashNo = Request.Form["cashNo"].ToString();
        }
        if (Request.Form["cashAmount"] != null && Request.Form["cashAmount"].ToString() != "")
        {
            cashAmount = Request.Form["cashAmount"].ToString();
        }
        if (Request.Form["cashId"] != null && Request.Form["cashId"].ToString() != "")
        {
            cashId = Request.Form["cashId"].ToString();
        }
        OrderMethod.Updateorder(cashNo, cashAmount, "cashondelivery", null);
        Response.Redirect(GetUrl("支付通知", "order_success.aspx?id=" + cashNo));
    }
</script>
