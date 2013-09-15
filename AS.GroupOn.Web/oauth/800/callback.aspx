<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="AS.Ucenter" %>
<%@ Import Namespace="AS.Enum" %>

<script runat="server">
    string username = "";
    //ucenter返回的对象
    protected AS.ucenter.RetrunClass retrunclass = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NameValueCollection configs = AS.GroupOn.Controls.PageValue.CurrentSystemConfig;
        NameValueCollection requestvalue = System.Web.HttpUtility.ParseQueryString(Request.Url.Query);
        string getaccess_tokenurl = "http://api.tuan800.com/oauth/oauth/accessToken?oauth_verifier=" + requestvalue["oauth_verifier"];
        OAuthBase oa = new OAuthBase();
        string outparams;
        string sign = oa.GenerateSignature(new Uri(getaccess_tokenurl), configs["logintuan800key"], configs["logintuan800secret"], CookieUtils.GetCookieValue("oauth_token"), CookieUtils.GetCookieValue("oauth_token_secret"), "GET", oa.GenerateTimeStamp(), oa.GenerateNonce(), out getaccess_tokenurl, out outparams);
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
        if (values["oauth_token"] != null && values["oauth_token_secret"] != null)
        {//登陆成功
            CookieUtils.SetCookie("oauth_token", values["oauth_token"]);
            CookieUtils.SetCookie("oauth_token_secret", values["oauth_token_secret"]);
            string getuserinfourl = "http://api.tuan800.com/oauth/oauthapi/userinfo/userInfo.json";
            oa = new OAuthBase();
            sign = oa.GenerateSignature(new Uri(getuserinfourl), configs["logintuan800key"], configs["logintuan800secret"], values["oauth_token"], values["oauth_token_secret"], "GET", oa.GenerateTimeStamp(), oa.GenerateNonce(), out getuserinfourl, out outparams);
            getuserinfourl = getuserinfourl + "?" + outparams + "&oauth_signature=" + sign;
            WebClient wc = new WebClient();
            returnvalue = wc.DownloadString(getuserinfourl);
            #region 团800一站通
            if (CookieUtils.GetCookieValue("username") == String.Empty && configs["istuan800login"] == "1")//启用了800验证
            {
                System.Collections.Generic.Dictionary<string, object> json_user = JsonUtils.JsonToObject(returnvalue);
                username = ((System.Collections.Generic.Dictionary<string, object>)json_user["userInfo"])["userName"].ToString();
                //创建用户名
                string formUser = username;
                username = username + "@tuan800.com";
                //判断此用户名是否存在
                //是否启用ucenter
                AS.Ucenter.YizhantongVerifier.YizhantongLogin(username + "_" + YizhantongState.来自团800一站通, username, String.Empty, YizhantongState.来自团800一站通, String.Empty, Helper.GetString(AS.GroupOn.Controls.PageValue.CurrentSystemConfig["UC_Islogin"], "0"), this, String.Empty);
            }
            #endregion

        }
        Response.Redirect(GetRefer());
        Response.End();
    }
</script>