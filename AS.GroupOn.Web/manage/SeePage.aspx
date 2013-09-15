<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>

<script runat="server">
    
    public string content;
    public BasePage b = new BasePage();
    public IMailtasks mailmodel = null;
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_EmailMany_Add))
        {
            SetError("你不具有查看用户列表的权限！");
            Response.Redirect("Addmailtasks.aspx");
            Response.End();
            return;
        }
        if (Request["id"] != null)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                mailmodel = session.Mailtasks.GetByID(Convert.ToInt32(Request["id"]));
            }
            if (mailmodel != null)
            {
                content = mailmodel.content;
            }
        }
    }

</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <%=content %>
    </form>
</body>
</html>
