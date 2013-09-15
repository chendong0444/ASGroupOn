<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>


<script runat="server">

    public string strMobile = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!Page.IsPostBack)
        {
            if (CookieUtils.GetCookieValue("username",Key) != String.Empty)
            {
                string strUserName = CookieUtils.GetCookieValue("username",Key);
                IList<IUser> listuser = null;
                UserFilter uf = new UserFilter();
               
                uf.Username = string.Format(" Username='{0}'", Helper.GetString(strUserName, String.Empty));

                using (IDataSession seion = Store.OpenSession(false))
                {
                   listuser=  seion.Users.GetList(uf);
                }
              
                if (listuser !=null && listuser.Count>0)
                {
                    strMobile = listuser[0].Mobile.ToString();
                      
                }
            }
        }
    }
    
    </script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:380px;">
<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>取消短信订阅</h3>
	<p class="info" id="smssub-dialog-display-id">请您输入手机号及验证码<br/>获取取消订阅认证码</p>
	<p class="notice" style=" width:300px;">手机号：<input id="smssub-dialog-input-mobile" type="text" name="mobile" class="f-input" style="text-transform:uppercase;" maxLength="12" value="<%=strMobile %>" /></p>
	<p class="notice" style=" width:300px;">验证码：<input id="smssub-dialog-input-verifycode" type="text" name="captchacode" style="text-transform:uppercase;" class="f-input" maxLength="6" /></p>
	<p class="notice" style="margin-left:5em;width:200px;"><img id="img-captcha-id" src="<%=WebRoot%>checkcode.aspx?a=<%=Helper.GetRandomString(5) %>" style="margin-bottom:-4px;" /><a href="javascript:;" style="margin:5px; font-size:12px;" onclick="jQuery('#img-captcha-id').attr('src',webroot+'checkcode.aspx?a='+Math.random());" >看不清楚？换一张</a></p>
	<p class="notice" style="margin:10px 3em;width:200px;" ><input id="smssub-dialog-query" class="formbutton" value="发送认证码" name="query" type="submit" onclick="return smssub_submit();"/></p>
</div>

<script type="text/javascript">
    function smssub_submit() {
        var mobile = trim(jQuery('#smssub-dialog-input-mobile').val());
        var verifycode = trim(jQuery('#smssub-dialog-input-verifycode').val());
        if (mobile == '') {
            alert('手机号不能为空');
            jQuery('#smssub-dialog-input-mobile').focus();
            return false;
        } else if (verifycode == '') {
            alert('验证码不能为空');
            jQuery('#smssub-dialog-input-verifycode').focus();
            return false;
        } else {
            X.get(webroot + "ajax/sms.aspx?action=unsubscribecheck&mobile=" + mobile + "&verifycode=" + verifycode + "&r=" + Math.random());
        }
        return false;
        
    }

    function captcha_again() {
        alert('验证码错误，请重新输入！');
        jQuery('#smssub-dialog-input-verifycode').val('');
        jQuery('#smssub-dialog-input-verifycode').focus();
        jQuery('#img-captcha-id').attr('src', webroot + 'checkcode.aspx?a=' + Math.random());
        return false;
    }

    function trim(str) {
        return str.replace(/^\s*(.*?)[\s\n]*$/g, '$1');
    }
</script>

