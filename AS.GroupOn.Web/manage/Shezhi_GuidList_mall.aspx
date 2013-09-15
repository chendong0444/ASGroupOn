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
    protected IPagers<IGuid> pager = null;
    protected IList<IGuid> iListGuid = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_MallGuid_ViewList))
        {
            SetError("你不具有查看商城导航的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }

        GuidFilter filter = new GuidFilter();
        filter.teamormall = 1;
        url = url + "&page={0}";
        url = "Shezhi_GuidList_mall.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(GuidFilter.guidsort_desc);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Guid.GetPager(filter);
        }
        iListGuid = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);

       
        int id = Helper.GetInt(Request.QueryString["del"], 0);
        if (id > 0)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_MallGuid_Delete))
            {
                SetError("你不具有删除商城导航的权限！");
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
                SetSuccess("商城导航栏目" + id + "删除成功");
            }
            Response.Redirect("Shezhi_GuidList_mall.aspx");
            Response.End();
            return;
        }
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
                                        商城导航栏目</h2>
                                        <div class="search">
                                    <ul class="filter">
                                        <li><a href="Shezhi_Guid_mall.aspx?state=addguid">新建商城导航栏目</a></li>
                                    </ul></div>
                                </div>
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
                                                <div style='word-wrap: break-word; overflow: hidden;'>
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
                                                      Response.Write("商城导航");
                                                 
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
                                                <a class="remove-record" href="Shezhi_Guid_mall.aspx?state=updateguid&id=<%=guidinfo.id %>">编辑</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a
                                                   ask="确定删除?" href="Shezhi_GuidList_mall.aspx?del=<%=guidinfo.id %>">删除</a>
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
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%
                                                  Response.Write("商城导航");
                                                 
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
                                                <a class="remove-record" href="Shezhi_Guid_mall.aspx?state=updateguid&id=<%=guidinfo.id %>">编辑</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a
                                                    href="Shezhi_GuidList_mall.aspx?del=<%=guidinfo.id %>">删除</a>
                                            </td>
                                        </tr>
                                                  <%}
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