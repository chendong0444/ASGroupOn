<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        NameValueCollection configs = WebUtils.GetSystem();

        string version = "2.0";
        #region oauth 1.0
        if (version == "1.0")
        {
            OAuthBase oa = new OAuthBase();
            string getrequest_tokenurl = "https://openapi.baidu.com/oauth/1.0/request_token?oauth_callback=" + oa.UrlEncode(WWWprefix + "oauth/baidu/callback.aspx?service_provider=baidu"); ;
            string outparams = String.Empty;
            string sign = oa.GenerateSignature(new Uri(getrequest_tokenurl), configs["baidukey"], configs["baidusecret"], String.Empty, String.Empty, "GET", oa.GenerateTimeStamp(), oa.GenerateNonce(), out getrequest_tokenurl, out outparams);
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
            Response.Redirect("http://openapi.baidu.com/oauth/1.0/authorize?oauth_token=" + requestvalues["oauth_token"] + "&req_perms=email&display=popup");
            Response.End();
        }
        #endregion
        else if (version == "2.0")
        {
            Response.Redirect(String.Format("https://openapi.baidu.com/oauth/2.0/authorize?response_type=code&client_id={0}&redirect_uri={1}&display=page", configs["baidukey"], Server.UrlEncode(WWWprefix + "oauth/baidu/callback.aspx")));
            Response.End();
        }
    }
</script>
