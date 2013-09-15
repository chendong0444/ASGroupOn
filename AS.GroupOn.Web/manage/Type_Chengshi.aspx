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
    protected string type = "";
    protected string Name = "";
    protected int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_City_List))
        {
            SetError("你不具有查看城市列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        CategoryFilter filter = new CategoryFilter();
        filter.Zone = "city";
        if (Request.QueryString["id"] != null && Request["id"].ToString() != "")
        {
            id = AS.Common.Utils.Helper.GetInt(Request.QueryString["id"], 0);
            filter.City_pid = id;
        }
        else
        {
            filter.City_pid = 0;
        }


        if (Request.QueryString["remove"] != null && Request.QueryString["remove"].ToString() != "")
        {
            try
            {
                //判断管理员是否有此操作
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_City_Delete))
                {
                    SetError("你不具有删除城市分类的权限！");
                    Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                    Response.End();
                    return;
                }
                int moveid = Convert.ToInt32(Request.QueryString["remove"].ToString());
                IList<ICategory> list = null;
                IList<IArea> arlist = null;
                CategoryFilter cate = new CategoryFilter();
                AreaFilter are = new AreaFilter();
                cate.City_pid = moveid;
                are.type = "area";
                are.cityid = moveid;

                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    list = session.Category.GetList(cate);
                    arlist = session.Area.GetList(are);


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
                        session.Category.Delete(moveid);
                        SetSuccess("友情提示：删除成功");
                    }
                }
            }
            catch (Exception)
            {

                SetError("删除失败");
            }

            Response.Redirect("Type_Chengshi.aspx", true);
        }
        url = url + "&page={0}";
        url = "Type_Chengshi.aspx?" + url.Substring(1) + "&id="+id;
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
                                    <%if (Name != "" && Name != String.Empty)
                                      {%>
                                    <h2>
                                        <%=Name%></h2>
                                    <%}
                                      else
                                      {%>
                                    <h2>
                                        城市列表</h2>
                                    <%} %>
                                    
                                </div><ul class="filter" >
                                        <% if (id != null && id != 0)
                                           {%>
                                        <li><a href='Type_Chengshi.aspx'>返回城市列表</a></li>
                                        <li><a class="ajaxlink" href="ajax_manage.aspx?action=categoryedit&zone=city&add=<%=id %>">
                                            添加子城市</a></li>
                                        <%}
                                           else
                                           { %>
                                        <li><a class="ajaxlink" href="ajax_manage.aspx?action=categoryedit&zone=city">新建城市列表</a></li>
                                        <%} %>
                                    </ul>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='10%'>
                                                ID
                                            </th>
                                            <th width='10%'>
                                                中文名称
                                            </th>
                                            <th width='10%'>
                                                英文名称
                                            </th>
                                            <%if (id != 0)
                                              {%>
                                            <th width='10%'>
                                                城市父ID/城市名称
                                            </th>
                                            <%} %>
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
                                                  { %>
                                                      <tr>
                                                 <% }
                                                  else
                                                  { %>
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
                                            <td>
                                                <%=categoryinfo.Ename %>
                                            </td>
                                            <%if (id != 0)
                                              {
                                                  if (categoryinfo.City_pid != 0)
                                                  {
                                                      ICategory cmodel = null;
                                                      using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                      {
                                                          cmodel = session.Category.GetByID(categoryinfo.City_pid);
                                                      }%>
                                            <td>
                                                <%=categoryinfo.City_pid%>/<%= cmodel.Name%>
                                            </td>
                                            <%}
                                              }%>
                                            <td>
                                                <%=categoryinfo.Letter %>
                                            </td>
                                            <%if (categoryinfo.Czone != null && categoryinfo.Czone != "" && categoryinfo.Czone != "0")
                                              {
                                                  ICategory model = null;
                                                  using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                  {
                                                      model = session.Category.GetByID(AS.Common.Utils.Helper.GetInt(categoryinfo.Czone,0));
                                                  }
                                                  if (model != null)
                                                  {%>
                                            <td>
                                                <%= model.Name %>
                                            </td>
                                            <% }
                                                  else
                                                  {%>
                                            <td>
                                                默认分组
                                            </td>
                                            <%}
                                              }
                                              else
                                              {%>
                                            <td>
                                                默认分组
                                            </td>
                                            <%}
                                            %>
                                            <%if (categoryinfo.Display == "Y")
                                              {%>
                                            <td>
                                                显示
                                            </td>
                                            <% }
                                              else
                                              {%>
                                            <td>
                                                隐藏
                                            </td>
                                            <% } %>
                                            <td>
                                                <%=categoryinfo.Sort_order%>
                                            </td>
                                            <td class='op'>
                                                <%if (categoryinfo.City_pid != null)
                                                  {
                                                      if (categoryinfo.City_pid != 0)
                                                      {%>
                                                <a class='ajaxlink' href="ajax_manage.aspx?action=categoryedit&zone=<%=categoryinfo.Zone%>&update=<%=categoryinfo.Id%>">
                                                    编辑子城市</a>｜
                                                <%}
                                                      else if (categoryinfo.City_pid == 0)
                                                      {
                                                          IList<ICategory> clist = null;
                                                          CategoryFilter cate = new CategoryFilter();
                                                          cate.Zone = "city";
                                                          cate.City_pid = categoryinfo.Id;
                                                          using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                          {
                                                              clist = session.Category.GetList(cate);
                                                          }%>
                                                <a href="Type_Chengshi.aspx?Id=<%=categoryinfo.Id%> ">操作子城市[<%= clist.Count %>]</a>｜
                                                <a class='ajaxlink' href="ajax_manage.aspx?action=categoryedit&zone=<%=categoryinfo.Zone%>&update=<%=categoryinfo.Id%>">
                                                    编辑</a>｜
                                                <%}
                                                  }%>
                                                <a href="Type_Chengshi_GongGao.aspx?Id=<%=categoryinfo.Id%>">公告</a>｜ <a class="remove-record"
                                                    href="Type_Chengshi.aspx?remove=<%=categoryinfo.Id%>">删除</a>
                                            </td>
                                            <% }

                                          } %>
                                        </tr>
                                        <tr>
                                            <td colspan="10">
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