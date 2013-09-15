<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    protected IPagers<ICategory> pager = null;
    protected IList<ICategory> iListCategory = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
      
        if (Request.QueryString["remove"] != null && Request.QueryString["remove"].ToString() != "")
        {
            try
            {
                int moveid = Convert.ToInt32(Request.QueryString["remove"].ToString());
                System.Collections.Generic.IList<ICategory> list = null; 
                System.Collections.Generic.IList<IArea> arlist = null;
                CategoryFilter cateft = new CategoryFilter();
                AreaFilter areaft = new AreaFilter ();
                cateft.City_pid = moveid;
                areaft.type = "area";
                areaft.cityid = moveid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    list = session.Category.GetList(cateft);
                    arlist = session.Area.GetList(areaft);
                }
                
                if (list != null && list.Count > 0)
                {
                    SetError("友情提示：此城市下面有子城市，无法删除");
                }
                else if (arlist != null && arlist.Count > 0)
                {
                    SetError("友情提示：此城市下面有区域，请您先删除区域再删除城市");
                }
                else
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int id = session.Category.Delete(moveid); 
                    }
                    SetSuccess("友情提示：删除成功");
                }

            }
            catch (Exception)
            {

                SetError("删除失败");
            }

            Response.Redirect("Type_ChengshiGroup.aspx", true);
        }
        CategoryFilter filter = new CategoryFilter();
        filter.Zone = "citygroup";

        url = url + "&page={0}";
        url = "Type_ChengshiGroup.aspx?" + url.Substring(1);
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
                <div id="coupons" >
                   
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        城市分组列表</h2>
                                        <ul class="filter">
                                        <li><a class="ajaxlink" href="ajax_manage.aspx?action=categoryedit&zone=citygroup">新建城市分组</a></li>
                                    </ul>                                    
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='20%'>
                                                ID
                                            </th>
                                            <th width='20%'>
                                                中文名称
                                            </th>                                            
                                            <th width='20%'>
                                                导航
                                            </th>
                                            <th width='20%'>
                                                排序
                                            </th>
                                            <th width='20%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListCategory != null && iListCategory.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (ICategory categoryinfo in iListCategory)
                                              {
                                                  if (i%2!=0)
                                                  {%>
                                                       <tr>
                                                  <% }
                                                  else
                                                  {%>
                                                       <tr class="alt">
                                                  <% }
                                                  i++;
                                        %>
                                       
                                            <td>
                                                
                                                    <%=categoryinfo.Id %>
                                                
                                            </td>
                                            <td>
                                                
                                                    <%=categoryinfo.Name %>
                                                
                                            </td>
                                            
                                            
                                              <%if (categoryinfo.Display == "Y")
                                                {%>
                                                    <td>显示</td>
                                                <% }
                                                else
                                                {%>
                                                    <td>隐藏</td>
                                                <% } %>
                                                    
                                            
                                            <td>
                                                
                                                    <%=categoryinfo.Sort_order%>
                                            </td>
                                            <td>
                                                <a class='ajaxlink' href="ajax_manage.aspx?action=categoryedit&zone=<%=categoryinfo.Zone %>&update=<%=categoryinfo.Id %>">编辑</a>｜
                    <a class="remove-record" href="Type_ChengshiGroup.aspx?remove=<%=categoryinfo.Id %>" >删除</a>
                                            </td>
                                            <% }

                                          } %>
                                        </tr>
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