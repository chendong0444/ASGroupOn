<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<script runat="server">
    protected CategoryFilter filter = new CategoryFilter();
    protected IList<ICategory> IlistCategory = null;
    protected IPagers<ICategory> pager = null;
    protected string pageHtml = String.Empty;
    protected string pagePar = "";
    protected string orders = "";
    protected int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        PageValue.Title = "商户分类";
        base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Partner_List))
        {
            SetError("你没有查看商户分类的权限");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        id = AS.Common.Utils.Helper.GetInt(Request["remove"], 0);
        if (id > 0)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Partner_Delete))
            {
                SetError("你没有删除商户分类的权限");
                Response.Redirect("Type_ShanghuFenlei.aspx");
                Response.End();
                return;

            }
            int delete = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                delete = session.Category.Delete(id);
            }
            if (delete > 0)
            {
                SetSuccess("删除成功");
            }
            Response.Redirect("Type_ShanghuFenlei.aspx");
            Response.End();
            return;
        }
        filter.Zone = "partner";
        filter.AddSortOrder(CategoryFilter.Sort_Order_DESC);
        filter.AddSortOrder(CategoryFilter.ID_DESC);
        pagePar = pagePar + "&page={0}" + pagePar;
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        filter.PageSize = 30;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Category.GetPager(filter);
        }
        IlistCategory = pager.Objects;
        pageHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, pagePar);
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head" style="height: 35px;">
                                    <h2>
                                        商户分类</h2>
                                </div>
                                <ul class="filter">
                                    <li><a class="ajaxlink" href='ajax_manage.aspx?action=categoryedit&zone=partner'>新建商户分类</a></li>
                                </ul>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" style="margin-top: 10px;" cellpadding="0"
                                        border="0" class="coupons-table">
                                        <tr>
                                            <th>
                                                ID
                                            </th>
                                            <th>
                                                中文名称
                                            </th>
                                            <th>
                                                英文名称
                                            </th>
                                            <th>
                                                首字母
                                            </th>
                                            <th>
                                                自定义分组
                                            </th>
                                            <th>
                                                导航
                                            </th>
                                            <th>
                                                排序
                                            </th>
                                            <th>
                                                操作
                                            </th>
                                        </tr>
                                        <% int i = 0;
                                           foreach (ICategory item in IlistCategory)
                                           {
                                               if (i % 2 == 0)
                                               {
                                        %>
                                        <tr class="alt">
                                            <%}
                                               else
                                               { %>
                                            <tr>
                                                <%} i++; %>
                                                <td>
                                                    <%=item.Id %>
                                                </td>
                                                <td>
                                                    <%=item.Name %>
                                                </td>
                                                <td>
                                                    <%=item.Ename %>
                                                </td>
                                                <td>
                                                    <%=item.Letter %>
                                                </td>
                                                <td>
                                                    <%=item.Czone %>
                                                </td>
                                                <td>
                                                    <%
                                               if (item.Display.ToString().Trim().ToUpper() == "Y")
                                               {%>
                                                    显示
                                                    <%}
                                    else
                                    {%>
                                                    隐藏
                                                    <%}%>
                                                </td>
                                                <td>
                                                    <%=item.Sort_order %>
                                                </td>
                                                <td>
                                                    <a ask="确认删除吗？" href="Type_ShanghuFenlei.aspx?remove=<%=item.Id %>">删除</a>｜ <a class='ajaxlink'
                                                        href="ajax_manage.aspx?action=categoryedit&update=<%=item.Id %>">编辑</a>
                                                </td>
                                            </tr>
                                            <%} %>
                                    </table>
                                    <%=pageHtml %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>