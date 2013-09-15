<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn.Controls" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        ClearCookie();
        Response.Redirect(GetUrl("手机版首页", "index.aspx"));
        Response.End();
    }
</script>
