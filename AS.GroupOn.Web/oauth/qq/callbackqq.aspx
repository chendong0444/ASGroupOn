<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils.Objects" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="AS.Ucenter" %>
<%@ Import Namespace="AS.Enum" %>
<%@ Import Namespace="System.Xml" %>
<script runat="server">
    //ucenter返回的对象
    protected AS.ucenter.RetrunClass retrunclass = null;
    //用户名
    string username = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NameValueCollection configs = WebUtils.GetSystem();
        string key = configs["loginqqkey"].ToString().Trim();
        string secret = configs["loginqqsecret"].ToString();

        if (Request.QueryString["code"] != null && Request.QueryString["code"].ToString() != "")
        {
            string code = Request.QueryString["code"].ToString();
            string oauth_callback = Server.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot + "oauth/qq/callbackqq.aspx");
            string url = "https://graph.qq.com/oauth2.0/token?grant_type=authorization_code&client_id=" + key + "&client_secret=" + secret + "&code=" + code + "&state=" + Request.QueryString["state"] + "&redirect_uri=" + oauth_callback;
            try
            {
                string request_token = RequestData(url);
                NameValueCollection nv = new NameValueCollection();
                nv = HttpUtility.ParseQueryString(request_token);
                string access_token = "";
                if (nv.AllKeys.Length > 0)
                {
                    access_token = nv["access_token"];
                    if (access_token != "")
                    {
                        string request_openid = RequestData("https://graph.qq.com/oauth2.0/me?access_token=" + access_token);
                        System.Collections.Generic.Dictionary<string, object> jsondata = JsonUtils.JsonToObject(request_openid);
                        string qid = "";
                        string nickname = "";
                        string openid = "";
                        if (jsondata.Count > 0)
                        {
                            System.Xml.XmlTextReader Reader = new System.Xml.XmlTextReader("https://graph.qq.com/user/get_user_info?access_token=" + access_token + "&oauth_consumer_key=" + key + "&openid=" + jsondata["openid"].ToString() + "&format=xml");
                            openid = jsondata["openid"].ToString();
                            System.Xml.XmlDocument xmlDoc = new System.Xml.XmlDocument();
                            xmlDoc.Load(Reader);
                            nickname = xmlDoc.SelectSingleNode("/data/nickname").InnerText;
                        }
                        if (CookieUtils.GetCookieValue("username") == String.Empty && configs["isqqlogin"] == "1")//启用了qq验证
                        {
                            //判断签名是否正确
                            string openid_qq = openid + "_qq";
                            string qname = "";//用户名
                            if (nickname != "")
                            {
                                qname = nickname.Trim();
                            }
                            else
                            {
                                qname = openid_qq;
                            }
                            qid = openid_qq;//用户ID
                            string qqemail = openid + "@qq.com";
                            CookieUtils.SetCookie("qq_qid", qid);//通过此值可判断是qq一站通登录用户
                            CookieUtils.SetCookie("qq_qname", qname);
                            AS.Ucenter.YizhantongVerifier.YizhantongLogin(qid + "_" + YizhantongState.来自qq一站通, qname, qqemail, YizhantongState.来自qq一站通, String.Empty, Helper.GetString(AS.GroupOn.Controls.PageValue.CurrentSystemConfig["UC_Islogin"], "0"), this, String.Empty);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
                Response.End();
            }
        }
        Response.Redirect(GetRefer());
        Response.End();
    }
    public static string RequestData(string url)
    {
        string result = String.Empty;
        try
        {
            System.Net.WebClient netclient = new System.Net.WebClient();
            result = netclient.DownloadString(url);
            netclient.Dispose();
        }
        catch (Exception ex)
        {
            result = result + ex.Message;
        }
        return result;
    }
</script>