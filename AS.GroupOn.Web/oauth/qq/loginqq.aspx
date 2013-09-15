<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NameValueCollection configs = WebUtils.GetSystem();
        string key = configs["loginqqkey"].ToString().Trim();
        string secret = configs["loginqqsecret"].ToString();
        string oauth_callback = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "oauth/qq/callbackqq.aspx";
        if (key != "")
        {
            Response.Redirect("https://graph.qq.com/oauth2.0/authorize?response_type=code&client_id=" + key + "&redirect_uri=" + oauth_callback);
        }
        else
        {
            SetError("获取ToKen失败,请联系管理员查看后台一站通设置！");
            Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
            return;
        }
    }
</script>