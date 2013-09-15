<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        NameValueCollection configs = WebUtils.GetSystem();

        string version = "1.0";
        #region oauth 1.0
        if (version == "1.0")
        {
            OAuthBase oa = new OAuthBase();
            //2.2 获取未授权的Request Token
            string getrequest_tokenurl = "http://api.kaixin001.com/oauth/request_token?oauth_callback=" + oa.UrlEncode(WWWprefix + "oauth/kaixin001/callback.aspx"); ;
            string outparams = String.Empty;
            string sign = oa.GenerateSignature(new Uri(getrequest_tokenurl), configs["kaixin001key"], configs["kaixin001secret"], String.Empty, String.Empty, "GET", oa.GenerateTimeStamp(), oa.GenerateNonce(), out getrequest_tokenurl, out outparams);
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
            //获取到oauth_token、oauth_token_secret以及oauth_callback_confirmed
            CookieUtils.SetCookie("oauth_token", requestvalues["oauth_token"]);
            CookieUtils.SetCookie("oauth_token_secret", requestvalues["oauth_token_secret"]);
            //2.3 请求用户授权Request Token
            Response.Redirect("http://api.kaixin001.com/oauth/authorize?oauth_token=" + requestvalues["oauth_token"]);
            Response.End();
        }
        #endregion

        #region version=2.0
        else if (version == "2.0")
        {
            Response.Redirect(String.Format("http://api.kaixin001.com/oauth2/authorize?response_type=code&client_id={0}&redirect_uri={1}&display=page", configs["kaixin001key"], Server.UrlEncode(WWWprefix + "oauth/kaixin001/callback.aspx")));
            Response.End();
        }
        #endregion
    }
</script>
