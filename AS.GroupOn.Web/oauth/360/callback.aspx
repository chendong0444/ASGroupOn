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
        string getaccess_tokenurl = "http://api.hao.360.cn/oauth/access_token.php?oauth_verifier=" + requestvalue["oauth_verifier"];
        OAuthBase oa = new OAuthBase();
        string outparams;
        string sign = oa.GenerateSignature(new Uri(getaccess_tokenurl), configs["login360key"], configs["login360secret"], CookieUtils.GetCookieValue("oauth_token"), CookieUtils.GetCookieValue("oauth_token_secret"), "GET", oa.GenerateTimeStamp(), oa.GenerateNonce(), out getaccess_tokenurl, out outparams);
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
            CookieUtils.SetCookie("oauth_token", values["oauth_token"]);
            CookieUtils.SetCookie("oauth_token_secret", values["oauth_token_secret"]);
            #region 360一站通
            if (CookieUtils.GetCookieValue("username") == String.Empty && configs["is360login"] == "1")//启用了360验证
            {
                //判断签名是否正确
                string qid = values["qid"];//用户ID
                string qname = values["qname"];//用户名
                string qmail = values["qmail"];//邮箱
                CookieUtils.SetCookie("360_qid", qid);//通过此值可判断是360一站通登录用户
                CookieUtils.SetCookie("360_qname", qname);
                //创建用户名
                username = qmail;
                //判断此用户名是否存在
                AS.Ucenter.YizhantongVerifier.YizhantongLogin(qid + "_" + YizhantongState.来自360一站通, qname, qmail, YizhantongState.来自360一站通, String.Empty, Helper.GetString(AS.GroupOn.Controls.PageValue.CurrentSystemConfig["UC_Islogin"], "0"), this, String.Empty);
            }
            #endregion

        }
        Response.Redirect(GetRefer());
        Response.End();
    }
    
</script>
