<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>

<script runat="server">
    string outparams;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //Utils.SystemConfig sysconfig = new Utils.SystemConfig();
        NameValueCollection configs = WebUtils.GetSystem();
        string getrequest_tokenurl = "http://api.t.163.com/oauth/request_token";
        string outparams = String.Empty;
        OAuthBase oa = new OAuthBase();
        string sign = oa.GenerateSignature(new Uri(getrequest_tokenurl), configs["login163key"].Trim(), configs["login163secret"].Trim(), String.Empty, String.Empty, "GET", oa.GenerateTimeStamp(), oa.GenerateNonce(), out getrequest_tokenurl, out outparams);
        getrequest_tokenurl = getrequest_tokenurl + "?" + outparams + "&oauth_signature=" + sign;
        string returnvalue = String.Empty;
        try
        {
            WebClient wc = new WebClient();
            returnvalue = wc.DownloadString(getrequest_tokenurl);
        }
        catch (Exception ex)
        {
            System.Threading.Thread.Sleep(3000);
            Response.Redirect(Request.Url.AbsoluteUri);
            Response.End();
            return;
        }
        NameValueCollection requestvalues = HttpUtility.ParseQueryString(returnvalue);
        CookieUtils.SetCookie("oauth_token", requestvalues["oauth_token"]);
        CookieUtils.SetCookie("oauth_token_secret", requestvalues["oauth_token_secret"]);
        Response.Redirect("http://api.t.163.com/oauth/authenticate?oauth_token=" + requestvalues["oauth_token"] + "&oauth_callback=" + Server.UrlEncode(WWWprefix + "oauth/163/callback.aspx"));
        Response.End();
    }
</script>
