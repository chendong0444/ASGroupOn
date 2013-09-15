<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="AS.Ucenter" %>
<%@ Import Namespace="AS.Enum" %>
<script runat="server">
    string username = "";
    //ucenter返回的对象
    protected AS.ucenter.RetrunClass retrunclass = null;
     protected string code = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        NameValueCollection configs = AS.GroupOn.Controls.PageValue.CurrentSystemConfig;
        NameValueCollection requestvalue = System.Web.HttpUtility.ParseQueryString(Request.Url.Query);



        string appkey = configs["logintaobaokey"];
        string appsecret = configs["logintaobaosecret"];

        string version = "2.0";

        if (version == "1.0")
        {
            string url = "http://gw.api.taobao.com/router/rest";

            if (Request.Url.AbsoluteUri.IndexOf("top_session") <= 0)
            {
                string strurl = "http://container.open.taobao.com/container?appkey=" + appkey;
                Response.Redirect(strurl);
            }

            string sessionkey = Request["top_session"];



            if (Request["top_session"] != null || Request["top_session"].ToString() != "")
            {


                taobaoUserlogin(configs, appkey, appsecret, url, sessionkey);

            }
            else
            {

                SetError("获取sessionKey失败！！");
                Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                Response.End();
            }
        }
        else if (version == "2.0")
        {
            WebUtils.LogWrite("淘宝一站通授权日志", "进入回调页面：" + Request.Url.Query);
            if (Request.Url.Query.IndexOf("code=") > 0)
            {
                code = Helper.GetString(Request["code"], String.Empty);
                NameValueCollection values = new NameValueCollection();
                if (Request["code"] != null && Request["code"].ToString() != "")
                {
                    string postUrl = "https://oauth.taobao.com/token";
                    values.Add("client_id", appkey);
                    values.Add("client_secret", appsecret);
                    values.Add("grant_type", "authorization_code");
                    values.Add("code", code);
                    values.Add("redirect_uri", Server.UrlEncode(WWWprefix + "account/oauth/taobao/callback.aspx"));
                    values.Add("scope", "usergrade");
                    values.Add("state", "login");
                    values.Add("view", "web");
                    string datastr = String.Empty;
                    try
                    {
                        WebClient wc = new WebClient();
                        byte[] data = wc.UploadValues(postUrl, "POST", values);
                        datastr = System.Text.Encoding.UTF8.GetString(data);

                    }
                    catch (Exception ex)
                    {
                        System.Threading.Thread.Sleep(3000);
                        WebUtils.LogWrite("淘宝一站通登录错误", ex.Message);
                        SetError("您所使用的淘宝一站通登陆失败，请在本站注册登陆");
                        Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                        Response.End();
                        return;
                    }
                    string[] strs = datastr.Trim().Replace("{", "").Replace("}", "").Split(',');
                    string taobao_user_id = String.Empty;
                    string taobao_user_nick = String.Empty;
                    for (int i = 0; i < strs.Length; i++)
                    {
                        string[] str = strs[i].Split(':');
                        string tkey = str[0].ToString();
                        string tvalue = str[1].ToString();
                        if (tkey.Contains("taobao_user_id"))
                            taobao_user_id = tvalue.Replace("\"", "");
                        if (tkey.Contains("taobao_user_nick"))
                            taobao_user_nick = tvalue.Replace("\"", "");
                    }
                    if (taobao_user_nick != String.Empty && taobao_user_id != String.Empty)
                    {
                        string key = taobao_user_id + "_" + taobao_user_nick + YizhantongState.来自淘宝一站通.ToString();
                        AS.Ucenter.YizhantongVerifier.YizhantongLogin(taobao_user_id + "_" + YizhantongState.来自淘宝一站通, taobao_user_nick, key, YizhantongState.来自淘宝一站通, String.Empty, Helper.GetString(AS.GroupOn.Controls.PageValue.CurrentSystemConfig["UC_Islogin"], "0"), this, String.Empty);
                    }
                    else
                    {
                        WebUtils.LogWrite("淘宝一站通授权日志", datastr);
                        SetError("您所使用的淘宝一站通登陆失败，请在本站注册登陆");
                        Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                        Response.End();
                        return;
                    }
                }
                else if (Request["error"] != null && Request["error"].ToString() != "")
                {
                    Response.Redirect("/index.aspx");
                }
            }
            else
            {
                Response.Write(Request.Url.Query.ToString());
            }

        }
    }

    private void taobaoUserlogin(NameValueCollection configs, string appkey, string appsecret, string url, string sessionkey)
    {
        Top.Api.ITopClient client = new Top.Api.DefaultTopClient(url, appkey, appsecret);
        Top.Api.Request.UserGetRequest req = new Top.Api.Request.UserGetRequest();
        req.Fields = "user_id,uid,nick,email";



        Top.Api.Response.UserGetResponse response = null;

        string userid = "";
        string email = "";
        string nick = String.Empty;
        try
        {
            response = client.Execute(req, sessionkey);

        }
        catch (Exception ex)
        {
            SetError(ex.Message);
            Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
            Response.End();

        }
        if (response != null && response.User != null)
        {
            //登陆成功
            userid = response.User.UserId.ToString();
            email = response.User.Email;
            nick = response.User.Nick;

            #region toabao一站通
            if (CookieUtils.GetCookieValue("username") == String.Empty && configs["istaobaologin"] == "1")//启用了taobao验证
            {
                //判断签名是否正确
                string qid = userid;//用户ID
                string qmail = email;//邮箱
                AS.Ucenter.YizhantongVerifier.YizhantongLogin(qid + "_" + YizhantongState.来自淘宝一站通, nick, qmail, YizhantongState.来自淘宝一站通, String.Empty, configs["UC_Islogin"], this, String.Empty);
            }
            #endregion

        }
        Response.Redirect(GetRefer());
        Response.End();
    }
</script>
