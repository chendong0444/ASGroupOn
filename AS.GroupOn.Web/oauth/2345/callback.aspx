<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="AS.Ucenter" %>
<%@ Import Namespace="AS.Enum" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>

<script runat="server">
    string username = "";
    //ucenter返回的对象
    protected AS.ucenter.RetrunClass retrunclass = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NameValueCollection configs = AS.GroupOn.Controls.PageValue.CurrentSystemConfig;
        NameValueCollection requestvalue = System.Web.HttpUtility.ParseQueryString(Request.Url.Query);
        string getaccess_tokenurl = "http://api.tuan.2345.com/oauth/access_token.php?oauth_verifier=" + requestvalue["oauth_verifier"];
        OAuthBase oa = new OAuthBase();
        string outparams;
        string sign = oa.GenerateSignature(new Uri(getaccess_tokenurl), configs["login2345key"], configs["login2345secret"], CookieUtils.GetCookieValue("oauth_token"), CookieUtils.GetCookieValue("oauth_token_secret"), "GET", oa.GenerateTimeStamp(), oa.GenerateNonce(), out getaccess_tokenurl, out outparams);
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
            // qid=77160020&qname=tuangou789%40abc.com&qmail=tuangou789%40abc.com
            string user_id = values["user_id"];
            if (user_id.Length > 0)
            {
                WebClient wc = new WebClient();
                NameValueCollection data = new NameValueCollection();
                data.Add("uid", user_id);
                returnvalue = System.Text.Encoding.UTF8.GetString(wc.UploadValues(String.Format("http://api.tuan.2345.com/api/getUserInfo.php?&oauth_token={0}&oauth_token_secret={1}", values["oauth_token"], values["oauth_token_secret"]), data));
            }

            CookieUtils.SetCookie("oauth_token", values["oauth_token"]);
            CookieUtils.SetCookie("oauth_token_secret", values["oauth_token_secret"]);
            #region 2345一站通
            if (CookieUtils.GetCookieValue("username") == String.Empty && configs["is2345login"] == "1")//启用了2345验证
            {
                //判断签名是否正确
                string[] val = returnvalue.Split('|');
                if (val.Length != 3)
                {
                    Response.Redirect(WebRoot + "index.aspx");
                    Response.End();
                    return;
                }
                string qid = val[0];//用户ID
                string qname = val[1];//用户名
                string qmail = val[2];//邮箱
                CookieUtils.SetCookie("2345_qid", qid);//通过此值可判断是360一站通登录用户
                CookieUtils.SetCookie("2345_qname", qname);
                //创建用户名
                username = qmail;
                //是否启用ucenter
                AS.Ucenter.YizhantongVerifier.YizhantongLogin(qid + "_" + YizhantongState.来自2345一站通, String.Empty, qmail, YizhantongState.来自2345一站通, String.Empty, Helper.GetString(AS.GroupOn.Controls.PageValue.CurrentSystemConfig["UC_Islogin"], "0"), this, String.Empty);
            }
            #endregion
        }
        Response.Redirect(GetRefer());
        Response.End();
    }
</script>
