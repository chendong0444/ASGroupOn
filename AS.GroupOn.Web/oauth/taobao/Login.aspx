<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Net" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NameValueCollection configs = WebUtils.GetSystem();
        string version = "2.0";
        if (configs != null)
        {
            if (version == "1.0")
            {
                if (configs["logintaobaokey"] != null && configs["logintaobaokey"].ToString() != "")
                {
                    string appkey = configs["logintaobaokey"];
                    string strurl = "http://container.open.taobao.com/container?appkey=" + appkey;
                    Response.Redirect(strurl);
                    Response.End();
                }
                else
                {
                    SetError("appkey为空,请联系管理员设置");
                    Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                    Response.End();
                }
            }
            else if (version == "2.0")
            {
                Response.Redirect(String.Format("https://oauth.taobao.com/authorize?response_type=code&client_id={0}&redirect_uri={1}&state=&scope=item&view=web", configs["logintaobaokey"], Server.UrlEncode(WWWprefix + "oauth/taobao/callback.aspx")));// Server.UrlEncode(WWWprefix + "account/oauth/taobao/callback.aspx")
                Response.End();
            }
        }
    }
</script>
