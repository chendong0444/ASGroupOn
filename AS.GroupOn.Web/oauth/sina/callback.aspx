<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils.Objects" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>
<%@ Import Namespace="AS.Ucenter" %>
<%@ Import Namespace="AS.Enum" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Security.Cryptography" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<script runat="server">
    //用户名
    string username = "";
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (Request["code"] != null)
            {
                string code = Request["code"].ToString();
                System.Net.WebClient wc = new System.Net.WebClient();
                string url = "https://api.weibo.com/oauth2/access_token";
                NameValueCollection values = new NameValueCollection();
                values.Add("client_id", PageValue.CurrentSystemConfig["loginSinakey"].Trim());
                values.Add("client_secret", PageValue.CurrentSystemConfig["loginSinasecret"].Trim());
                values.Add("grant_type", "authorization_code");
                values.Add("redirect_uri", WWWprefix + "oauth/sina/callback.aspx");
                values.Add("code", code);
                string dataval = string.Empty;
                string uid = string.Empty;
                try
                {
                    byte[] data = wc.UploadValues(url, "POST", values);
                    dataval = Encoding.UTF8.GetString(data);
                }
                catch (Exception ex) { }
                if (dataval != string.Empty)
                {
                    System.Collections.Generic.Dictionary<string, object> jsondata = JsonUtils.JsonToObject(dataval);
                    uid = jsondata["uid"].ToString();
                    if (uid != string.Empty)
                    {
                        username = uid + "_新浪微博";
                        YizhantongVerifier.YizhantongLogin(uid + "_" + YizhantongState.新浪微博, username, String.Empty, YizhantongState.新浪微博, String.Empty, PageValue.CurrentSystemConfig["UC_Islogin"], this, String.Empty);

                    }
                }
            }
        }
    }
</script>
