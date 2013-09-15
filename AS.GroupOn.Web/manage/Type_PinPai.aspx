<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">

    protected IPagers<ICategory> pager = null;
    protected IList<ICategory> iListCategory = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Brand_List))
        {
            SetError("你不具有查看品牌列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        CategoryFilter filter = new CategoryFilter();
        filter.Zone = "brand";
        
        if (Request.QueryString["remove"] != null && Request.QueryString["remove"].ToString() != "")
        {
            try
            {
                //判断管理员是否有此操作
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Brand_Delete))
                {
                    SetError("你不具有删除品牌的权限！");
                    Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                    Response.End();
                    return;
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int id = session.Category.Delete(Convert.ToInt32(Request.QueryString["remove"].ToString())); 
                }
                
                SetSuccess("删除成功");

            }
            catch (Exception)
            {

                SetError("删除失败");
            }

            Response.Redirect("Type_PinPai.aspx", true);
        }
        url = url + "&page={0}";
        url = "Type_PinPai.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(CategoryFilter.Sort_Order_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Category.GetPager(filter);
        }
        iListCategory = pager.Objects;
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
                                        品牌分类</h2>
                                    <ul class="filter">
                                        <li><a class="ajaxlink" href="ajax_manage.aspx?action=categoryedit&zone=brand">新建品牌分类</a></li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='10%'>
                                                ID
                                            </th>
                                            <th width='15%'>
                                                中文名称
                                            </th>
                                            <th width='15%'>
                                                英文名称
                                            </th>
                                            <th width='10%'>
                                                首字母
                                            </th>
                                            <th width='10%'>
                                                自定义分组
                                            </th>
                                            <th width='10%'>
                                                导航
                                            </th>
                                            <th width='10%'>
                                                排序
                                            </th>
                                            <th width='15%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListCategory != null && iListCategory.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (ICategory CategoryInfo in iListCategory)
                                              {
                                                  if (i%2!=0)
                                                  {%>
                                                      <tr>
                                                   <%}
                                                  else
                                                  {%>
                                                      <tr class="alt">
                                                  <% }
                                                  i++;
                                        %>
                                        
                                            <td>
                                                        <%=CategoryInfo.Id%>
                                            </td>
                                            <td>
                                                        <%=CategoryInfo.Name%>
                                            </td>
                                            <td>
                                                        <%=CategoryInfo.Ename%>
                                            </td>
                                            <td>
                                                        <%=CategoryInfo.Letter%>
                                            </td>
                                            <td>                                                
                                                        <%=CategoryInfo.Czone%>   
                                            </td>
                                            <%if (CategoryInfo.Display != null && CategoryInfo.Display == "Y")
                                              { 
                                            %>
                                            <td>显示 </td>
                                            <%
                                                }
                                              else
                                              { 
                                            %>
                                            <td>隐藏                                                
                                            </td>
                                            <% }
                                            %>
                                            <td>
                                                <%=CategoryInfo.Sort_order%>                               
                                            </td>

                                            <td><a class="ajaxlink" href="ajax_manage.aspx?action=categoryedit&zone=<%=CategoryInfo.Zone %>&update=<%=CategoryInfo.Id %>">编辑</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="Type_PinPai.aspx?remove=<%=CategoryInfo.Id %>">删除</a></td>
                                        </tr>
                                        <%       
                                            }
                                          } %>
                                        <tr>
                                            <td colspan="9">
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