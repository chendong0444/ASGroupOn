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
    protected IUser users = null;
    protected IList<IRole> role = null;
    protected int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Admin_Author))
        {
            SetError("你不具有查看管理员授权的权限！");
            Response.Redirect("User_guanliyuanbiao.aspx");
            Response.End();
            return;

        }
        RoleFilter filter = new RoleFilter();
        id = Helper.GetInt(Request.QueryString["authorization"], 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            users = session.Users.GetByID(id);

            role = session.Role.GetList(filter);
        }

        //string aa = Request["auth"].ToString();
    }
    //protected void Power_Click(object sender, EventArgs e)
    //{
        //string auth = Helper.GetString(Request["auth"], String.Empty);
        //if (auth != String.Empty)
        //    auth = "{" + auth.Replace(",", "}{") + "}";
        //userinfo.Auth = auth;
        //useroper.Update(userinfo);
        //SetSuccess("更改" + userinfo.Username + "权限成功");
        //Response.Redirect(Request.UrlReferrer.AbsoluteUri);
    //    SetSuccess("设置成功！！");
    //}
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>管理授权：<%=users.Email %></h3>
    <div style="overflow-x: hidden; padding: 10px;">
        <input type="hidden" name="id" value="<%=users.Id %>" />
       <h3 style="color:Red">只能选择一种角色权限!!</h3>
        <table width="96%" class="coupons-table-xq">
        
            <tr>
                <td width='100'>
                    <% if (role != null && role.Count > 0)
                       {
                           foreach (IRole roleinfo in role)
                           {
                               if (users.auth != String.Empty && users.auth!=null && users.auth.IndexOf("{" + roleinfo.code + "}") >= 0)
                               {%>
                    <input type="checkbox" name="auth" checked="checked" value="<%=roleinfo.Id %>" onclick="get_onclick(this)" />
                    <b>
                        <%=roleinfo.rolename%></b><br />
                    <% }
                               else
                               {%>
                    <input type="checkbox" name="auth" value="<%=roleinfo.Id %>" onclick="get_onclick(this)" />
                    <b>
                        <%=roleinfo.rolename%></b><br />
                    <%}%>
                    
                    <%}
                       }%>
                </td>
            </tr>
            <tr style="margin-top: 10px">
                <td colspan="2">
                <input type="hidden" name="action" value="uppower" />
                    <input type="submit" runat="server" class="formbutton" value="确定授权"/>
                </td>
            </tr>
        </table>
    </div>
</div>
<script type="text/javascript">
    var uid = 0;
    //只能选中一个值;  
    function get_onclick(obj) {
        uid = obj.value;
        var auth = document.getElementsByName("auth");
        for (var i = 0; i < auth.length; i++) {
            auth[i].checked = false;
        }
        obj.checked = true;
        
    }  
 </script>
 
 
