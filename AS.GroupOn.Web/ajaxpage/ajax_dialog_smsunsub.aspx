<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<script runat="server">
    public string strMobile = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        strMobile = Request["mobile"];
    }
   
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>取消短信订阅</h3>
    <p class="info" id="smssub-dialog-display-id">
        您的手机号<span style="color: #F00; font-weight: bold;"><%=strMobile %></span><br>
        取消短信订阅成功！</p>
</div>
