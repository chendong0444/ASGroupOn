<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="AS.Ucenter" %>
<%@ Import Namespace="AS.Enum" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        NameValueCollection configs = AS.GroupOn.Controls.PageValue.CurrentSystemConfig;
        string version = "2.0";
        if (version == "1.0")
        {
            NameValueCollection requestvalue = System.Web.HttpUtility.ParseQueryString(Request.Url.Query);
            string getaccess_tokenurl = "https://openapi.baidu.com/oauth/1.0/access_token?oauth_verifier=" + requestvalue["oauth_verifier"];
            OAuthBase oa = new OAuthBase();
            string outparams;
            string sign = oa.GenerateSignature(new Uri(getaccess_tokenurl), configs["baidukey"], configs["baidusecret"], CookieUtils.GetCookieValue("oauth_token"), CookieUtils.GetCookieValue("oauth_token_secret"), "GET", oa.GenerateTimeStamp(), oa.GenerateNonce(), out getaccess_tokenurl, out outparams);
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
            NameValueCollection values = System.Web.HttpUtility.ParseQueryString(returnvalue);
            if (values["oauth_token"] != null && values["oauth_token_secret"] != null && values["uid"] != null && values["uname"] != null)
            {//登陆成功
                // oauth_token=3.f3cef582ca6d7b50c4d6523735cce84b.86400.1310140800-4078741719&oauth_token_secret=3ede9948a7a0b493aa09ac4f6cea056e&uid=4078741719&uname=%E4%BE%BF_%E5%AE%9C%E8%B4%AD&portrait=e6f3b1e35fd2cbb9ba0818&expires=86400
                CookieUtils.SetCookie("oauth_token", values["oauth_token"]);
                CookieUtils.SetCookie("oauth_token_secret", values["oauth_token_secret"]);
                BaiduLogin(values["uid"], values["uname"], configs);

            }
        }
        else if (version == "2.0")
        {
            WebClient wc = new WebClient();
            //得到access_token
            string result = wc.DownloadString("https://openapi.baidu.com/oauth/2.0/token?grant_type=authorization_code&code=" + Request["code"] + "&client_id=" + configs["baidukey"] + "&client_secret=" + configs["baidusecret"] + "&redirect_uri=" + Server.UrlEncode(WWWprefix + "oauth/baidu/callback.aspx"));
            System.Collections.Generic.Dictionary<string, object> jsondata = JsonUtils.JsonToObject(result);
            CookieUtils.SetCookie("oauth_token", jsondata["access_token"].ToString());
            //得到用户资料
            result = wc.DownloadString("https://openapi.baidu.com/rest/2.0/passport/users/getInfo?access_token=" + jsondata["access_token"].ToString());
            jsondata = JsonUtils.JsonToObject(result);
            BaiduLogin(jsondata["userid"].ToString(), jsondata["username"].ToString(), configs);
        }
        Response.Redirect(GetRefer());
        Response.End();
    }

    void BaiduLogin(string userid, string username, NameValueCollection configs)
    {
        #region baidu一站通
        if (!User.Identity.IsAuthenticated && configs["isbaidulogin"] == "1")//启用了baidu验证
        {
            //判断签名是否正确
            string qid = userid;//用户ID
            string qname = System.Text.RegularExpressions.Regex.Unescape(username);//用户名
            string qmail = qid + "@baidu.com";
            string key = qid + "_来自百度一站通";

            AS.Ucenter.YizhantongVerifier.YizhantongLogin(key, qname, qmail, YizhantongState.来自百度一站通, String.Empty, Helper.GetString(AS.GroupOn.Controls.PageValue.CurrentSystemConfig["UC_Islogin"], "0"), this, String.Empty);

        }
        #endregion
    }
</script>