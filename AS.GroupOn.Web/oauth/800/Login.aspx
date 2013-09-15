<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NameValueCollection configs = WebUtils.GetSystem();
        string getrequest_tokenurl = "http://api.tuan800.com/oauth/oauth/requestToken";
        string outparams = String.Empty;
        OAuthBase oa = new OAuthBase();
        string sign = oa.GenerateSignature(new Uri(getrequest_tokenurl), configs["logintuan800key"], configs["logintuan800secret"], String.Empty, String.Empty, "GET", oa.GenerateTimeStamp(), oa.GenerateNonce(), out getrequest_tokenurl, out outparams);
        getrequest_tokenurl = getrequest_tokenurl + "?" + outparams + "&oauth_signature=" + sign;
        string returnvalue = String.Empty;
        try
        {
            WebClient wc = new WebClient();
            returnvalue = wc.DownloadString(getrequest_tokenurl);
        }
        catch
        {
            System.Threading.Thread.Sleep(3000);
            Response.Redirect(Request.Url.AbsoluteUri);
            Response.End();
            return;
        }
        NameValueCollection requestvalues = HttpUtility.ParseQueryString(returnvalue);
        if (requestvalues["oauth_token"] == null || requestvalues["oauth_token_secret"] == null)
        {
            System.Threading.Thread.Sleep(3000);
            Response.Redirect(Request.Url.AbsoluteUri);
            Response.End();
            return;
        }
        CookieUtils.SetCookie("oauth_token", requestvalues["oauth_token"]);
        CookieUtils.SetCookie("oauth_token_secret", requestvalues["oauth_token_secret"]);
        Response.Redirect("http://api.tuan800.com/oauth/oauth/authorize?oauth_token=" + requestvalues["oauth_token"] + "&oauth_callback=" + Server.UrlEncode(WWWprefix + "oauth/800/callback.aspx"));
        Response.End();
    }
</script>
