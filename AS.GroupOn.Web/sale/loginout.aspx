<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.SalePage" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.Ucenter" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!Page.IsPostBack)
        {
            ClearCookie();
            //SetSuccess("退出销售登录成功！");
            //Response.Redirect(GetUrl("后台管理", "Login.aspx?type=sale"));
            Response.Redirect("/saleLogin.aspx?type=sale");
        }
    }
</script>
