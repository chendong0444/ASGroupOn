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
    protected IPagers<IArea> pager = null;
    protected IList<IArea> iListArea = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected string type = "";
    protected string types = "";
    protected string Name = "";
    protected int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Area_List))
        {
            SetError("你不具有查看区域商圈列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        AreaFilter filter = new AreaFilter();

        if (AS.Common.Utils.Helper.GetInt(Request.QueryString["id"], 0)!=0)
        {
            id = AS.Common.Utils.Helper.GetInt(Request.QueryString["id"], 0);
            type = AS.Common.Utils.Helper.GetString(Request["type"], String.Empty);
            filter.type = "circle";
            filter.circle_id = id;
        }
        else
        {
            filter.type = "area";
        }

        if (Request.QueryString["remove"] != null && Request.QueryString["remove"].ToString() != "")
        {
            try
            {
                int moveid = Convert.ToInt32(Request.QueryString["remove"].ToString());
                System.Collections.Generic.IList<IArea> list = null;
                AreaFilter are = new AreaFilter();
                are.circle_id = moveid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    list = session.Area.GetList(are);


                    if (list != null && list.Count > 0)
                    {
                        SetError("友情提示：此区域下面有商圈，无法删除");
                    }
                    else
                    {
                        session.Area.Delete(moveid);
                        SetSuccess("友情提示：删除成功");
                    }
                }
            }
            catch (Exception)
            {

                SetError("删除失败");
            }

            Response.Redirect("Type_Area.aspx", true);
        }
        
        url = url + "&page={0}";
        url = "Type_Area.aspx?type=" + type + "&id=" + id + "&" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(AreaFilter.Sort_Order_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Area.GetPager(filter);
        }
        iListArea = pager.Objects;
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
                                <div class="head"style="height:35px;">
                                    <%if (id != 0)
                                      {%>
                                    <h2>
                                       商圈列表</h2>
                                    <%}
                                      else
                                      {%>
                                    <h2>
                                        区域列表</h2>
                                    <%} %>
                                    <% if (id != null && id != 0)
                                       {%>
                                    <ul class="filter">
                                        <li><a href='Type_Area.aspx'>返回区域列表</a></li>
                                        <li><a class="ajaxlink" href="ajax_manage.aspx?action=area&add=<%=id %>">添加商圈</a></li>
                                    </ul>
                                    <%}
                                       else
                                       { %>
                                    <ul class="filter">
                                        <li><a href="Type_addarea.aspx?zone=area">新建区域列表</a></li>
                                    </ul>
                                    <%} %>
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
                                            <th width='15%'>
                                                城市名称
                                            </th>
                                            <th width='15%'>
                                                导航
                                            </th>
                                            <th width='15%'>
                                                排序
                                            </th>
                                            <th width='15%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListArea != null && iListArea.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (IArea areainfo in iListArea)
                                              {
                                                  if (i%2!=0)
                                                  {%>
                                                      <tr>
                                                   <%}
                                                  else
                                                  {%>
                                                      <tr class="alt">
                                                  <% }
                                                  i++; %>
                                        
                                            <td>
                                                <%=areainfo.id%>
                                            </td>
                                            <td>
                                                <%=areainfo.areaname%>
                                            </td>
                                            <td>
                                                <%=areainfo.ename%>
                                            </td>
                                            <%if (type != "" && type != null)
                                              {
                                                  IArea aremodel = null;
                                                  using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                  {
                                                      aremodel = session.Area.GetByID(areainfo.cityid);
                                                  }

                                                  if (aremodel != null)
                                                  {%>
                                            <td>
                                                <%=aremodel.areaname%>
                                            </td>
                                            <%}
                                              }%>
                                            <% 
                                                else
                                                {
                                                    ICategory cmodel = null;
                                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                    {
                                                        cmodel = session.Category.GetByID(areainfo.cityid);

                                                        if (cmodel != null)
                                                        {
                                                            if (cmodel.City_pid != 0)
                                                            {
                                                                int cid = cmodel.City_pid;
                                                                ICategory c = null;
                                                                c = session.Category.GetByID(cid);
                                            %>
                                            <td>
                                                <%=c.Name %>-<%= cmodel.Name %>
                                            </td>
                                            <% }
                                                            else
                                                            {%>
                                            <td>
                                                <%= cmodel.Name %>
                                            </td>
                                            <%}
                                                        }
                                                        else
                                                        {%>
                                            <td>
                                                <%=areainfo.cityid %>
                                            </td>
                                            <%}
                                                    }
                                                }
                                                  
                                            %>
                                            <%if (areainfo.display == "Y")
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
                                                <%=areainfo.sort%>
                                            </td>
                                            <td class='op'>
                                                <%if (areainfo.circle_id == 0)
                                                  {
                                                      IList<IArea> alist = null;
                                                      AreaFilter area = new AreaFilter();
                                                      area.type = "circle";
                                                      area.circle_id = areainfo.id;
                                                      using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                      {
                                                          alist = session.Area.GetList(area);
                                                      }%>
                                                <a href="Type_Area.aspx?Id=<%=areainfo.id %>&type=circle">操作商圈[<%= alist.Count %>]</a>｜
                                                <% }
                                                  else
                                                  {%>
                                                <a class='ajaxlink' href="ajax_manage.aspx?action=circle&update=<%=areainfo.id %>">编辑商圈</a>｜
                                                <% }
                                                  if (areainfo.circle_id == 0)
                                                  {%>
                                                <a href="Type_addarea.aspx?zone=area&edit=<%=areainfo.id %>">编辑</a>｜
                                                <% } %>
                                                <a class="remove-record" href="Type_Area.aspx?remove=<%=areainfo.id %>">删除</a>
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