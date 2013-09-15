<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        string action = Request["action"];
        if ("locale" == action)
        {
            string s = AS.Common.Utils.CookieUtils.GetCookieValue("totw");
            if (s == String.Empty || s == "zh_tw")
            {
                AS.Common.Utils.CookieUtils.SetCookie("totw", "zh_cn");
            }
            else
                AS.Common.Utils.CookieUtils.SetCookie("totw", "zh_tw");
            string url = WebRoot + "index.aspx";
            if (Request.UrlReferrer != null)
                url = Request.UrlReferrer.AbsoluteUri;
            Response.Redirect(url);
            Response.End();
            return;
        }
    }
</script>
    