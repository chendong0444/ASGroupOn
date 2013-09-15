<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<script runat="server">

    
    protected string cityname = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        if (CurrentCity != null)
        {
            cityname = CurrentCity.Name;
        }
    }
    
    </script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:380px;">
<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>短信订阅</h3>
	<p class="info" id="smssub-dialog-display-id">订阅<%=cityname %>成功！<br><span style="font-size:12px; color:gray;">您可以随时取消订阅。</span></p>
</div>

