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
    protected IPagers<IGuid> pager = null;
    protected IList<IGuid> iListGuid = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_SetTg_Guid_List))
        {
            SetError("你不具有查看团购导航的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        id = Helper.GetInt(Request["del"], 0);
        if (id > 0)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_SetTg_Guid_Delete))
            {
                SetError("你不具有删除团购导航的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;

            }
            int del_id = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                del_id = session.Guid.Delete(id);
            }
            if (del_id > 0)
            {

                SetSuccess("团购导航栏目" + id + "删除成功");
            }
            Response.Redirect("Shezhi_GuidList.aspx");
            Response.End();
            return;
        }

        
        GuidFilter filter = new GuidFilter();
        filter.teamormall = 0;
        url = url + "&page={0}";
        url = "Shezhi_GuidList.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(GuidFilter.guidsort_desc);
        filter.AddSortOrder(GuidFilter.Id_Desc);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Guid.GetPager(filter);
        }
        iListGuid = pager.Objects;
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
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head" style="height:35px;">
                                    <h2>
                                        团购导航栏目</h2>
                                        <div class="search">
                                     </div>
                                </div><ul class="filter">
                                        <li><a href="Shezhi_Guid.aspx?state=addguid">新建团购导航栏目</a></li>
                                    </ul>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='15%'>
                                                ID
                                            </th>
                                            <th width='15%'>
                                                导航栏目
                                            </th>
                                            <th width='10%'>
                                                导航类型
                                            </th>
                                            <th width='15%'>
                                                url
                                            </th>
                                            <th width='15%'>
                                                日期
                                            </th>
                                            <th width='15%'>
                                                状态
                                            </th>
                                            <th width='15%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListGuid != null && iListGuid.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (IGuid guidinfo in iListGuid)
                                              {
                                                  if (i % 2 == 0)
                                                  {%>
                                                  <tr>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=guidinfo.id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=guidinfo.guidtitle%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%
                                                      Response.Write("团购导航");
                                                 
                                                    %>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=guidinfo.guidlink%>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=guidinfo.createtime%>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%if (guidinfo.guidopen == 0)
                                                      {
                                                          Response.Write("显示");
                                                      }
                                                      if (guidinfo.guidopen == 1)
                                                      {
                                                          Response.Write("隐藏");
                                                      }
                                                    %>
                                            </td>
                                            <td>
                                                <a class="remove-record" href="Shezhi_Guid.aspx?state=updateguid&id=<%=guidinfo.id %>">编辑</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a
                                                    href="Shezhi_GuidList.aspx?del=<%=guidinfo.id %>" ask="确定删除导航栏目吗？">删除</a>
                                            </td>
                                        </tr>
                                                  <%}
                                                  else
                                                  {%>
                                                  <tr class="alt">
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=guidinfo.id %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=guidinfo.guidtitle %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%
                                                  Response.Write("团购导航");
                                                 
                                                    %>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=guidinfo.guidlink%>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=guidinfo.createtime%>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%if (guidinfo.guidopen == 0)
                                                      {
                                                          Response.Write("显示");
                                                      }
                                                      if (guidinfo.guidopen == 1)
                                                      {
                                                          Response.Write("隐藏");
                                                      }
                                                    %>
                                            </td>
                                            <td>
                                                <a class="remove-record" href="Shezhi_Guid.aspx?state=updateguid&id=<%=guidinfo.id %>">编辑</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a
                                                    href="Shezhi_GuidList.aspx?del=<%=guidinfo.id %>" ask="确定删除导航栏目吗？">删除</a>
                                            </td>
                                        </tr>
                                                 <% }
                                                  i++;
                                              }
                                          } %>
                                        <tr>
                                            <td colspan="7">
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