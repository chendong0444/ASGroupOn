<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script runat="server">
    protected IRole role = null;
    protected int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        id = Convert.ToInt32(Request.QueryString["addrole"]);
        if (id > 0)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Role_Add))
            {
                SetError("你不具有添加角色的权限！");
                Response.Redirect("User_Roles.aspx");
                Response.End();
                return;

            }
        }
        else
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Role_Edit))
            {
                SetError("你不具有编辑角色的权限！");
                Response.Redirect("User_Roles.aspx");
                Response.End();
                return;

            }
        }
        //id = Helper.GetInt(Request.QueryString["addrole"], 0);

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            role = session.Role.GetByID(id);
        }


    }
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 385px; height: 215px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span></h3>
    <div style="overflow-x: hidden; padding: 10px;" id="dialog-order-id">
        <table class="coupons-table-xq">
            <%if (id > 0)
              {
            %>
            <tr>
                <td width="80" nowrap="">
                    <input type="hidden" name="action" value="updaterole" />
                    <b>角色名称：</b>
                </td>
                <td nowrap="">
                    <input type="text" value="<%=role.rolename %>" name="rolename" group="g" require="true" datatype="require"
                        class="h-input" style="width: 120px" />
                    <span style="color: Red">*&nbsp;角色名称不能为空</span>
                    <input type="hidden" name="id" value="<%=id %>" />
                </td>
            </tr>
            <tr>
                <td width="80" nowrap="">
                    <b>角色代码：</b>
                </td>
                <td nowrap="">
                    <input id="engname" type="text" value="<%=role.code %>" readonly="readonly" name="code"
                        require="true" datatype="require" class="h-input" style="width: 120px" />
                    <span style="color: Red">*&nbsp;角色代码不可修改</span>
                </td>
            </tr>
            <%}

              else
              {
            %>
            <tr>
                <td width="80" nowrap="">
                    <input type="hidden" name="action" value="addrole" />
                    <b>角色名称：</b>
                </td>
                <td nowrap="">
                    <input type="text" name="rolename" require="true" datatype="require" group="g" class="h-input"
                        style="width: 120px" />
                    <span style="color: Red">*&nbsp;角色名称不能为空</span>
                </td>
            </tr>
            <tr>
                <td width="80" nowrap="">
                    <b>角色代码：</b>
                </td>
                <td nowrap="">
                    <input id="Text1" type="text" require="true" datatype="require" group="g" name="code" class="h-input"
                        style="width: 120px" />
                    <span style="color: Red">*&nbsp;角色代码不能为空</span>
                </td>
            </tr>
            <%}
            %>
            <tr>
                <td class="style1">
                </td>
                <td class="style1">
                    <input type="submit" name="commit" id="commit" class="validator formbutton" group="g"
                        style="margin-top: 10px;" value="确定" />
                </td>
            </tr>
        </table>
    </div>
</div>
