<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.Ucenter" %>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!Page.IsPostBack)
        {

            ClearCookie();
            //SetSuccess("退出商户管理成功！");
            Response.Redirect("/merchantLogin.aspx?type=merchant");
            Response.End();
        }
    }
</script>
