<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        NameValueCollection configs = WebUtils.GetSystem();

        //人人网注册的API Key 和 Secret Key
        string key = configs["renrenkey"].ToString().Trim();
        string secret = configs["renrensecret"].ToString();
        string oauth_callback = Server.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "oauth/renren/callback.aspx");//得到Authorization Code的回传地址
        //string oauth_callback = Server.UrlEncode("http://www.pztuan.com/account/oauth/renren/callback.aspx");//测试用

        string getrequest_tokenurl = "https://graph.renren.com/oauth/authorize?client_id=" + key + "&response_type=code&redirect_uri=" + oauth_callback;

        Response.Redirect(getrequest_tokenurl);
    }
</script>
