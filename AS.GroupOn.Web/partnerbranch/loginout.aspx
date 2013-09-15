<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerBranchPage" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.Ucenter" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!Page.IsPostBack)
        {
            ClearCookie();
            //SetSuccess("退出商户分店管理成功！");
            Response.Redirect(GetUrl("后台管理", "Login.aspx?type=pbranch"));
        }
    }
</script>