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
        //string str = Request.Url.Query;
        NameValueCollection requestvalue = System.Web.HttpUtility.ParseQueryString(Request.Url.Query);
        string getaccess_tokenurl = "http://api.t.163.com/oauth/access_token";
        OAuthBase oa = new OAuthBase();
        string outparams;
        string sign = oa.GenerateSignature(new Uri(getaccess_tokenurl), configs["login163key"].Trim(), configs["login163secret"].Trim(), CookieUtils.GetCookieValue("oauth_token"), CookieUtils.GetCookieValue("oauth_token_secret"), "GET", oa.GenerateTimeStamp(), oa.GenerateNonce(), out getaccess_tokenurl, out outparams);
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

            //WebClient wc = new WebClient();
            //NameValueCollection data = new NameValueCollection();

            //returnvalue = System.Text.Encoding.UTF8.GetString(wc.UploadValues(String.Format("http://api.t.163.com/oauth/authenticate?oauth_token={0}&oauth_token_secret={1}", values["oauth_token"], values["oauth_token_secret"]), data));
            CookieUtils.SetCookie("oauth_token", values["oauth_token"]);
            CookieUtils.SetCookie("oauth_token_secret", values["oauth_token_secret"]);
            string url = "http://api.t.163.com/account/verify_credentials.json";
            string timestmp = oa.GenerateTimeStamp();
            string once = oa.GenerateNonce();
            oa = new OAuthBase();
            sign = oa.GenerateSignature(new Uri(url), configs["login163key"].Trim(), configs["login163secret"].Trim(), values["oauth_token"], values["oauth_token_secret"], "GET", timestmp, once, out url, out outparams);
            url = url + "?" + outparams + "&oauth_signature=" + sign;
            string vv = outparams + "&oauth_signature=" + sign;
            WebClient wc = new WebClient();
            byte[] data = wc.DownloadData(url);
            returnvalue = System.Text.Encoding.UTF8.GetString(data);
            #region 163一站通
            if (CookieUtils.GetCookieValue("username") == String.Empty && configs["is163login"] == "1")//启用了163验证
            {
                System.Collections.Generic.Dictionary<string, object> json = JsonUtils.JsonToObject(returnvalue);
                string id = Helper.GetString(json["id"], String.Empty);

                string qid = id + "_网易微博用户";//用户ID
                CookieUtils.SetCookie("163_qname", qid);
                //创建用户名
                username = qid;
                AS.Ucenter.YizhantongVerifier.YizhantongLogin(qid, String.Empty, String.Empty, YizhantongState.来自网易微博登录, String.Empty, Helper.GetString(AS.GroupOn.Controls.PageValue.CurrentSystemConfig["UC_Islogin"], "0"), this, String.Empty);
            }
            #endregion

        }
        Response.Redirect(GetRefer());
        Response.End();
    }
</script>
