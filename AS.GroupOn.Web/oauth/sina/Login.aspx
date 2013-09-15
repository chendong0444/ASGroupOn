<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        if (PageValue.CurrentSystemConfig != null && PageValue.CurrentSystemConfig["loginSinakey"] != null)
        {
            string getrequest_tokenurl = string.Format("https://api.weibo.com/oauth2/authorize?client_id={0}&response_type=code&redirect_uri={1}", PageValue.CurrentSystemConfig["loginSinakey"].Trim(), WWWprefix + "oauth/sina/callback.aspx");
            Response.Redirect(getrequest_tokenurl);
            Response.End();
        }
        else
        {
            SetError("获取ToKen失败,请联系管理员查看后台一站通设置！");
            Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
            return;
        }
    }
</script>