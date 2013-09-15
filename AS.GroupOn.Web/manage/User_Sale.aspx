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
    protected IPagers<ISales> pager = null;
    protected IList<ISales> iListSales = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Sale_List))
        {
            SetError("你不具有查看销售人员列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }


        id = Helper.GetInt(Request["delete"], 0);
        if (id > 0)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Sale_Delete))
            {
                SetError("你不具有删除销售人员的权限！");
                Response.Redirect("User_Sale.aspx");
                Response.End();
                return;
               

            }
            int del_id = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                del_id = session.Sales.Delete(id);
            }
            if (del_id > 0)
            {

                SetSuccess("销售人员" + id + "删除成功");
            }
            Response.Redirect("User_Sale.aspx");
            Response.End();
            return;
        }

        SalesFilter filter = new SalesFilter();
        url = url + "&page={0}";
        url = "User_Sale.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(SalesFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Sales.GetPager(filter);
        }
        iListSales = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }
   
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <script src="../template/default/js/index.js" type="text/javascript"></script>
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
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head" style="height:35px;">
                                    <h2>
                                        销售列表</h2>
                                        <div class="search">
                                    <ul class="filter" style="top: 0">
                                        <li><a href="User_Sale_Edit.aspx?state=addsale">添加销售人员&nbsp;&nbsp;</a> </li>
                                    </ul></div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='20%'>
                                                ID
                                            </th>
                                            <th width='20%'>
                                                用户名
                                            </th>
                                            <th width='20%'>
                                                真实姓名
                                            </th>
                                            <th width='20%'>
                                                联系电话
                                            </th>
                                            <th width='20%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListSales != null && iListSales.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (ISales salesinfo in iListSales)
                                              {
                                                  if (i % 2 == 0)
                                                  {%>
                                        <tr>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=salesinfo.id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=salesinfo.username%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=salesinfo.realname%>
                                            </td>
                                            <td>
                                                <%=salesinfo.contact%>
                                            </td>
                                            <td>
                                                <a class="remove-record" href="User_Sale.aspx?delete=<%=salesinfo.id %>" ask="确定删除本销售人员吗？">
                                                    删除</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="User_Sale_Edit.aspx?state=updatesale&id=<%=salesinfo.id %>">编辑</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a
                                                        class='ajaxlink' href="<%=WebRoot%>manage/ajax_manage.aspx?action=salerelation&saleid=<%=salesinfo.id %>">绑定项目</a>
                                            </td>
                                        </tr>
                                        <% }
                                                  else
                                                  {%>
                                        <tr class="alt">
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=salesinfo.id %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=salesinfo.username %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=salesinfo.realname%>
                                            </td>
                                            <td>
                                                <%=salesinfo.contact%>
                                            </td>
                                            <td>
                                                <a class="remove-record" href="User_Sale.aspx?delete=<%=salesinfo.id %>" ask="确定删除本销售人员吗？">
                                                    删除</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="User_Sale_Edit.aspx?state=updatesale&id=<%=salesinfo.id %>">编辑</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a
                                                        class='ajaxlink' href="ajax_manage.aspx?action=salerelation&saleid=<%=salesinfo.id %>">绑定项目</a>
                                            </td>
                                        </tr>
                                        <%}
                                                  i++;
                                              }
                                          } %>
                                        <tr>
                                            <td colspan="6">
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