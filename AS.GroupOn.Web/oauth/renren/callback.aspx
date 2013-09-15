<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="AS.Ucenter" %>
<%@ Import Namespace="AS.Enum" %>

<script runat="server">
    string rid = "";
    string code = "";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NameValueCollection configs = AS.GroupOn.Controls.PageValue.CurrentSystemConfig;

        //人人网注册的API Key 和 Secret Key
        string key = configs["renrenkey"].ToString().Trim();
        string secret = configs["renrensecret"].ToString();

        string strUrl = Request.Url.AbsoluteUri;
        //string strUrl = WWWprefix + "account/oauth/renren/callback.aspx?code=8mIzxtdGmlc8nIRNLPLbZqcos3b2xtUQ";//测试用
        try
        {
            code = strUrl.Substring(strUrl.IndexOf("=") + 1);//得到Authorization Code
        }
        catch { }

        if (code != null && code != "")//登陆成功
        {
            #region 根据Authorization Code得到accesstoken  并将json下载下来
            string AccessToken = Server.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "oauth/renren/callback.aspx");//得到AccessToken的回传地址
            //string AccessToken = Server.UrlEncode("http://www.pztuan.com/account/oauth/renren/callback.aspx");//测试用            
            string getrequest_tokenurl = "https://graph.renren.com/oauth/token?client_id=" + key + "&client_secret=" + secret + "&redirect_uri=" + AccessToken + "&grant_type=authorization_code&code=" + code;
            string returnvalue = String.Empty;

            try
            {
                WebClient wc = new WebClient();
                wc.Encoding = System.Text.Encoding.GetEncoding("utf-8");//utf-8编码
                returnvalue = wc.DownloadString(getrequest_tokenurl);
            }
            catch
            {
                System.Threading.Thread.Sleep(3000);
                Response.Redirect(Request.Url.AbsoluteUri);
                Response.End();
                return;
            }
            #endregion


            #region 人人网一站通
            if (CookieUtils.GetCookieValue("username") == String.Empty && configs["isrenrenlogin"] == "1")//启用了renren验证
            {
                System.Collections.Generic.Dictionary<string, object> json_user = JsonUtils.JsonToObject(returnvalue);
                rid = ((System.Collections.Generic.Dictionary<string, object>)json_user["user"])["id"].ToString();
                //创建用户名、邮箱、用户真实姓名
                string realname = ((System.Collections.Generic.Dictionary<string, object>)json_user["user"])["name"].ToString();
                string remail = rid + "@renren.com";
                string username = "人人网用户_" + rid;
                //一站通登录
                AS.Ucenter.YizhantongVerifier.YizhantongLogin(YizhantongState.来自人人一站通 + rid, username, remail, YizhantongState.来自人人一站通, realname, Helper.GetString(AS.GroupOn.Controls.PageValue.CurrentSystemConfig["UC_Islogin"], "0"), this, String.Empty);
            }
            #endregion

            Response.Redirect(GetRefer());
            Response.End();
        }
    }
</script>
