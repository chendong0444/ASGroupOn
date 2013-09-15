﻿<%@ Page Language="C#" AutoEventWireup="true"  Inherits="AS.GroupOn.Controls.FBasePage" %>

<script runat="server">
    
    public string strMobile = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        strMobile = Request["mobile"];
    }
   
    </script>


<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:380px;">
<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>短信认证码</h3>
	<p class="info" id="smssub-dialog-display-id">手机认证码已经发送<br/>请输入认证码！</p>
	<p class="notice">手机认证码已经发送到手机号：<span style="font-weight:bold; color:#F00;"><%=strMobile%></span></p>
	<p class="notice" style="margin-top:15px;">认证码：<input id="smssub-dialog-input-secretcode" type="text" name="captchacode" style="text-transform:uppercase;" class="f-input" maxLength="6" /></p>
	<p class="notice" style="margin:20px 4em;" ><input id="smssub-dialog-query" class="formbutton" value="确定" name="query" type="submit" onclick="return smssub_submit();"/></p>
</div>

<script type="text/javascript">
function smssub_submit() {

	var secretcode = trim(jQuery('#smssub-dialog-input-secretcode').val());
	if(secretcode == '') {
		alert('认证码不能为空');
		jQuery('#smssub-dialog-input-secretcode').focus();
        return false;
	} 
    else {
		X.get(webroot + "ajax/sms.aspx?action=codeyes&mobile="+<%=strMobile %>+"&secretcode="+secretcode+"&r="+ Math.random());
		jQuery('#smssub-dialog-input-secretcode').val('');
		jQuery('#smssub-dialog-input-secretcode').focus();
        return false;
	}
}

function trim(str) {
	return str.replace(/^\s*(.*?)[\s\n]*$/g, '$1');
}
</script>
