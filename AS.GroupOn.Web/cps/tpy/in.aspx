<%@ Page Language="C#" AutoEventWireup="true" CodePage="65001" %>

<script language="C#" runat="server">
    //太平洋cps入口
    protected void Page_Load(Object Src, EventArgs E)
    {

        string key = Request["key"];
        string codeid = AS.Common.Utils.WebUtils.config["tpykey"];
        string gongyao = AS.Common.Utils.WebUtils.config["tpysecret"];
        string url = Request.QueryString["url"];
        string userid = Request["userid"];
        if (String.IsNullOrEmpty(url)) url = AS.GroupOn.Controls.PageValue.WebRoot + "index.aspx";

        if (key == AS.Common.Utils.Helper.MD5(userid + codeid + gongyao))
        {
            HttpCookie cps = new HttpCookie("cps");
            NameValueCollection values = new NameValueCollection();
            values.Add("name", "tpycps");
            values.Add("userid", Server.UrlEncode(Request["userid"]));
            cps.Values.Add(values);
            Response.Cookies.Add(cps);
            AS.Common.Utils.CookieUtils.SetCookie("fromdomain", "来自太平洋cps", DateTime.Now.AddHours(2));
        }
        Response.Write("<script>location.href='" + url + "';</" + "script>");
        Response.End();
    }
</script>
