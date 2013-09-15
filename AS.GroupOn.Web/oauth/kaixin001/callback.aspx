<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="AS.Ucenter" %>
<%@ Import Namespace="AS.Enum" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        NameValueCollection configs = AS.GroupOn.Controls.PageValue.CurrentSystemConfig;
        string version = "1.0";
        #region oauth 1.0
        if (version == "1.0")
        {
            //获取到oauth_token以及oauth_verifier
            NameValueCollection requestvalue = System.Web.HttpUtility.ParseQueryString(Request.Url.Query);
            //2.4 使用授权后的Request Token换取Access Token
            string getaccess_tokenurl = "http://api.kaixin001.com/oauth/access_token?oauth_verifier=" + requestvalue["oauth_verifier"];
            OAuthBase oa = new OAuthBase();
            string outparams;
            string sign = oa.GenerateSignature(new Uri(getaccess_tokenurl), configs["kaixin001key"], configs["kaixin001secret"], CookieUtils.GetCookieValue("oauth_token"), CookieUtils.GetCookieValue("oauth_token_secret"), "GET", oa.GenerateTimeStamp(), oa.GenerateNonce(), out getaccess_tokenurl, out outparams);
            getaccess_tokenurl = getaccess_tokenurl + "?" + outparams + "&oauth_signature=" + sign;
            string returnvalue = String.Empty;
            try
            {
                WebClient wc = new WebClient();
                returnvalue = wc.DownloadString(getaccess_tokenurl);
            }
            catch
            {
                System.Threading.Thread.Sleep(3000);
                Response.Redirect(Request.Url.AbsoluteUri);
                Response.End();
                return;
            }
            //清空cookie
            HttpCookie cookie1 = new HttpCookie("oauth_token");
            cookie1.Expires = DateTime.Now.AddYears(-2);
            if (HttpContext.Current != null && HttpContext.Current.Request != null && HttpContext.Current.Request.Url != null)
                cookie1.Domain = WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
            HttpContext.Current.Response.AppendCookie(cookie1);
            HttpCookie cookie2 = new HttpCookie("oauth_token_secret");
            cookie2.Expires = DateTime.Now.AddYears(-2);
            if (HttpContext.Current != null && HttpContext.Current.Request != null && HttpContext.Current.Request.Url != null)
                cookie1.Domain = WebUtils.GetRootDomainName(HttpContext.Current.Request.Url.AbsoluteUri);
            HttpContext.Current.Response.AppendCookie(cookie2);

            //获取oauth_token以及oauth_token_secret
            NameValueCollection values = System.Web.HttpUtility.ParseQueryString(returnvalue);
            if (values["oauth_token"] != null && values["oauth_token_secret"] != null)
            {
                //登录成功
                //Utils.CookieHelper.SetCookie("oauth_token", values["oauth_token"]);
                //Utils.CookieHelper.SetCookie("oauth_token_secret", values["oauth_token_secret"]);
                string url = "http://api.kaixin001.com/users/me.json";
                string timestmp = oa.GenerateTimeStamp();
                string once = oa.GenerateNonce();
                oa = new OAuthBase();
                sign = oa.GenerateSignature(new Uri(url), configs["kaixin001key"].Trim(), configs["kaixin001secret"].Trim(), values["oauth_token"], values["oauth_token_secret"], "GET", timestmp, once, out url, out outparams);
                url = url + "?" + outparams + "&oauth_signature=" + sign;
                string vv = outparams + "&oauth_signature=" + sign;
                try
                {
                    WebClient wc = new WebClient();
                    wc.Encoding = System.Text.Encoding.GetEncoding("utf-8");//utf-8编码
                    returnvalue = wc.DownloadString(url);
                }
                catch
                {
                    System.Threading.Thread.Sleep(3000);
                    Response.Redirect(Request.Url.AbsoluteUri);
                    Response.End();
                    return;
                }
                #region 开心网一站通
                if (CookieUtils.GetCookieValue("username") == string.Empty && configs["iskaixin001login"] == "1")
                {
                    System.Collections.Generic.Dictionary<string, object> json = JsonUtils.JsonToObject(returnvalue);
                    string uid = Helper.GetString(json["uid"], String.Empty);
                    string qid = uid + "_开心网用户";//用户ID
                    AS.Ucenter.YizhantongVerifier.YizhantongLogin(qid, String.Empty, String.Empty, YizhantongState.来自开心网一站通, qid, Helper.GetString(AS.GroupOn.Controls.PageValue.CurrentSystemConfig["UC_Islogin"], "0"), this, String.Empty);
                }
                #endregion
            }
        }
        #endregion

        #region version=2.0
        else if (version == "2.0")
        {
            WebClient wc = new WebClient();
            //得到access_token
            string result = wc.DownloadString("https://api.kaixin001.com/oauth2/access_token?grant_type=authorization_code&code=" + Request["code"] + "&client_id=" + configs["kaixin001key"] + "&client_secret=" + configs["kaixin001secret"] + "&redirect_uri=" + Server.UrlEncode(WWWprefix + "oauth/kaixin001/callback.aspx"));
            System.Collections.Generic.Dictionary<string, object> jsondata = JsonUtils.JsonToObject(result);
            CookieUtils.SetCookie("oauth_token", jsondata["access_token"].ToString());
            //得到用户资料
            result = wc.DownloadString("http://api.kaixin001.com/users/me.json?access_token=" + jsondata["access_token"].ToString());

            #region 开心网一站通
            if (CookieUtils.GetCookieValue("username") == string.Empty && configs["iskaixin001login"] == "1")
            {
                System.Collections.Generic.Dictionary<string, object> json = JsonUtils.JsonToObject(result);
                string uid = Helper.GetString(json["uid"], String.Empty);
                string qid = uid + "_开心网用户";//用户ID
                AS.Ucenter.YizhantongVerifier.YizhantongLogin(qid, String.Empty, String.Empty, YizhantongState.来自开心网一站通, qid, configs["UC_Islogin"], this, String.Empty);
            }
            #endregion
        }
        #endregion
        Response.Redirect(GetRefer());
        Response.End();
    }
</script>
