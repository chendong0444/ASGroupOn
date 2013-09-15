<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NameValueCollection configs = WebUtils.GetSystem();
        string getrequest_tokenurl = "http://api.tuan.2345.com/oauth/request_token.php";
        string outparams = String.Empty;
        OAuthBase oa = new OAuthBase();
        string sign = oa.GenerateSignature(new Uri(getrequest_tokenurl), configs["login2345key"], configs["login2345secret"], String.Empty, String.Empty, "GET", oa.GenerateTimeStamp(), oa.GenerateNonce(), out getrequest_tokenurl, out outparams);
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
        CookieUtils.SetCookie("oauth_token", requestvalues["oauth_token"]);
        CookieUtils.SetCookie("oauth_token_secret", requestvalues["oauth_token_secret"]);
        Response.Redirect("http://api.tuan.2345.com/oauth/authorize.php?oauth_token=" + requestvalues["oauth_token"] + "&oauth_callback=" + WWWprefix + "oauth/2345/callback.aspx");
        Response.End();
    }
</script>

