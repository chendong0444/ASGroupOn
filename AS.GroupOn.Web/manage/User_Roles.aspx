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
    protected IPagers<IRole> pager = null;
    protected IList<IRole> iListRole = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Role_List))
        {
            SetError("你不具有查看管理员角色列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }

        id = Helper.GetInt(Request["del"], 0);
        if (id > 0)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Role_Delete))
            {
                SetError("你不具有删除管理员角色的权限！");
                Response.Redirect("User_Roles.aspx");
                Response.End();
                return;

            }
            int del_id = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                del_id = session.Role.Delete(id);
                del_id = session.RoleAuthority.DelByRoleID(id);
            }
            if (del_id > 0)
            {

                SetSuccess("角色" + id + "删除成功");
            }
            Response.Redirect("User_Roles.aspx");
            Response.End();
            return;
        }

        RoleFilter filter = new RoleFilter();

        url = url + "&page={0}";
        url = "User_Roles.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(RoleFilter.ID_ASC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Role.GetPager(filter);
        }
        iListRole = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }
    
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear ">
                            <div class="box-content">
                                <div class="head" style="height:35px;">
                                    <h2>
                                        管理角色</h2>
                                        <div class="search">
                                    <ul class="filter">
                                        <li><a class='ajaxlink' href="ajax_manage.aspx?action=addrole">添加角色&nbsp;&nbsp;</a>
                                        </li>
                                    </ul></div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='25%'>
                                                ID
                                            </th>
                                            <th width='25%'>
                                                角色名称
                                            </th>
                                            <th width='25%'>
                                                英文名称
                                            </th>
                                            
                                            <th width='25%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListRole != null && iListRole.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (IRole roleinfo in iListRole)
                                              {
                                                  if (i % 2 == 0)
                                                  {%>
                                        <tr>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=roleinfo.Id%><br />
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=roleinfo.rolename%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=roleinfo.code%>
                                                </div>
                                            </td>
                                            <td>
                                                <a class="ajaxlink" href="ajax_manage.aspx?action=addrole&addrole=<%=roleinfo.Id %>">
                                                    编辑</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="User_Roles.aspx?del=<%=roleinfo.Id %>" ask="确定删除角色吗？">删除</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="User_Role.aspx?id=<%=roleinfo.Id %>">分配权限</a>
                                            </td>
                                        </tr>
                                        <%}
                              else
                              {%>
                                        <tr class="alt">
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; width: '>
                                                    <%=roleinfo.Id%><br />
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; width: '>
                                                    <%=roleinfo.rolename %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; width: '>
                                                    <%=roleinfo.code %>
                                                </div>
                                            </td>
                                            <td>
                                                <a class="ajaxlink" href="ajax_manage.aspx?action=addrole&addrole=<%=roleinfo.Id %>">
                                                    编辑</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="User_Roles.aspx?del=<%=roleinfo.Id %>" ask="确定删除角色吗？">删除</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="User_Role.aspx?id=<%=roleinfo.Id %>">分配权限</a>
                                            </td>
                                        </tr>
                                        <%}
                              i++;
                          }
                      } %>
                                        <tr>
                                            <td colspan="4">
                                                <%=pagerHtml %>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>