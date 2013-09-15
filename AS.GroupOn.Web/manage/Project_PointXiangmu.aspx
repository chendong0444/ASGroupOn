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
    protected IPagers<ITeam> pager = null;
    protected IList<ITeam> teamlist = null;
    protected IList<ITeam> teamlist2 = null;
    protected IList<ICatalogs> catalogslist = null;
    private NameValueCollection _system = new NameValueCollection();
    private string href = "";
    protected CouponFilter couponfilter = new CouponFilter();
    protected IList<ICatalogs> iListCatalogs = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected CategoryFilter categoryfilter = new CategoryFilter();
    protected IList<ICategory> iListCategory = null;
    protected CatalogsFilter catalogsfilter = new CatalogsFilter();
    protected System.Data.DataTable catalogsdt = null;
    protected int count = 0;
    protected ITeam teamodel = null;
    protected ICategory categorymodel = null;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Score_List))
        {
            SetError("你不具有查看积分列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        TeamFilter filter2 = new TeamFilter();
        _system = AS.Common.Utils.WebUtils.GetSystem();
        if (this.Textid.Text != null && this.Textid.Text != "")//项目ID
        {
            filter2.Id = AS.Common.Utils.Helper.GetInt(this.Textid.Text, 0);
        }

        if (Request.QueryString["remove"] != null && Request.QueryString["remove"] != "")
        {
            delProject(int.Parse(Request.QueryString["remove"].ToString()));
        }
        if (this.Texttitle.Text != null && this.Texttitle.Text != "" || Request.QueryString["Texttitle"] != null)
        {
            if (Request.QueryString["Texttitle"] != null)
            {
                this.Texttitle.Text = Request.QueryString["Texttitle"].ToString();
            }
            filter2.TitleLike = this.Texttitle.Text;
            url = url + "&Texttitle=" + this.Texttitle.Text;
        }
        if (this.txtcity.Text != null && this.txtcity.Text != "" || Request.QueryString["txtcity"] != null)
        {
            if (Request.QueryString["txtcity"] != null)
            {
                this.txtcity.Text = Request.QueryString["txtcity"].ToString();
            }
            filter2.cityidIn = this.txtcity.Text;
            url = url + "&txtcity=" + this.txtcity.Text;
        }
        // 复制项目
        if (Request["add"] != null)
        {
            AddTeam(Convert.ToInt32(Request["add"]));
        }
        url = url + "&page={0}";
        url = "Project_PointXiangmu.aspx?" + url.Substring(1);
        filter2.PageSize = 30;
        filter2.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        filter2.Team_type = "point";
        filter2.AddSortOrder(TeamFilter.Sort_Order_DESC);
        filter2.AddSortOrder(TeamFilter.Begin_time_DESC);
        filter2.AddSortOrder(TeamFilter.ID_DESC);
        filter2.ToBegin_time = DateTime.Now;
        filter2.FromEndTime = DateTime.Now;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Teams.GetPager(filter2);
        }
        teamlist2 = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }
    //复制项目
    public void AddTeam(int teamid)
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teamodel = session.Teams.GetByID(teamid);
        }

        if (teamodel.autolimit <= 0)
        {
            teamodel.autolimit = 0;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int id = session.Teams.Insert(teamodel);
        }
        SetSuccess("友情提示：复制成功");
        Response.Redirect("Project_PointXiangmu.aspx");
    }
    private void delProject(int id)
    {
        bool result = false;
        result = TeamMethod. isExist(id);
        if (result)
        {
            SetError("项目已成交 , 不可删除！");
        }
        else
        {
            int num = TeamMethod.delProject(id);
            if (num > 0)
            {
                SetSuccess("删除成功");
            }
            string key = AS.Common.Utils.FileUtils.GetKey();
            AS.AdminEvent.ConfigEvent.AddOprationLog(AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", key), 0), "删除项目", "删除项目 ID:" + Request.QueryString["remove"].ToString(), DateTime.Now);
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
                                <div class="head">
                                    <h2>
                                        上架积分项目
                                    </h2>
                                    <div class="search">
                                        &nbsp;&nbsp; 城市:
                                        <asp:TextBox class="h-input" ID="txtcity" runat="server"></asp:TextBox>
                                        项目编号：
                                        <asp:TextBox class="h-input" ID="Textid" runat="server"></asp:TextBox>
                                        项目标题:
                                        <asp:TextBox class="h-input" ID="Texttitle" runat="server"></asp:TextBox>
                                        <input type="submit" id="btnselect" group="goto" value="筛选" class="formbutton" name="btnselect"
                                            style="padding: 1px 6px;" />
                                        <ul class="filter">
                                            <li class="current"><a href="Project_PointXiangmu.aspx">上架积分项目</a></li>
                                            <li><a href="Project_ChenggongPointXiangmu.aspx?team_type=normal">下架积分项目</a></li>
                                        </ul>
                                    </div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='8%'>
                                                ID
                                            </th>
                                            <th width='25%'>
                                                项目名称
                                            </th>
                                            <th width='15%'>
                                                类别
                                            </th>
                                            <th width='8%'>
                                                排序
                                            </th>
                                            <th width='12%'>
                                                日期
                                            </th>
                                            <th width='5%'>
                                                成交
                                            </th>
                                            <th width='7%'>
                                                价格
                                            </th>
                                            <th width='20%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (teamlist2 != null && teamlist2.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (ITeam teamInfo in teamlist2)
                                              {
                                                  href = getTeamPageUrl(teamInfo.Id);
                                                  if (i % 2 != 0)
                                                  {%>
                                        <tr>
                                            <%}
                                                  else
                                                  {%>
                                            <tr class="alt">
                                                <%    
}
                                                  i++;
                                                %>
                                                <td>
                                                    <%=teamInfo.Id%>
                                                </td>
                                                <td>
                                                    [积分] <a href="<%= href %>" target="_blank" class="deal-title">
                                                        <%=teamInfo.Title%>
                                                    </a>
                                                </td>
                                                <%ICategory cate = null;
                                                  using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                  {
                                                      cate = session.Category.GetByID(teamInfo.City_id);
                                                  }%>
                                                <td>
                                                    <%if (cate != null)
                                                      {%>
                                                    <%=cate.Name %>
                                                    <%}
                                                      else if (teamInfo.City_id == 0)
                                                      {%>
                                                    全部城市
                                                    <% }
                                                      else
                                                      {%>
                                                    全部城市
                                                    <%}%>
                                                    <br />
                                                    <% if (teamInfo.cataid != null)
                                                       {
                                                           catalogsfilter.id = teamInfo.cataid;
                                                           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                           {
                                                               iListCatalogs = session.Catalogs.GetList(catalogsfilter);
                                                           }
                                                           foreach (ICatalogs catalogs in iListCatalogs)
                                                           {
                                                               if (catalogs.catalogname != null)
                                                               { %>
                                                    [<%= catalogs.catalogname %>]
                                                    <% }%>
                                                    <%else
                                                        {
                                                        }
                                                           }
                                                       }
                                                       else
                                                       {
                                                       }%>
                                                    <br />
                                                    <%if (teamInfo.Group_id != null)
                                                      {
                                                          categoryfilter.Id = teamInfo.Group_id;
                                                          using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                          {
                                                              iListCategory = session.Category.GetList(categoryfilter);
                                                          }
                                                          foreach (ICategory category in iListCategory)
                                                          {
                                                              if (category.Name != null)
                                                              { %>
                                                    [<%= category.Name %>](API)
                                                    <% }
                                                              else
                                                              {

                                                              }
                                                          }
                                                      }%>
                                                </td>
                                                <td>
                                                    <%=teamInfo.Sort_order %>
                                                </td>
                                                <td>
                                                    <%=teamInfo.Begin_time%>
                                                    <br />
                                                    <%=teamInfo.End_time %>
                                                </td>
                                                <td>
                                                    <%=teamInfo.Now_number%>/<%=teamInfo.Min_number%>
                                                </td>
                                                <td>
                                                    <span class='money'>￥</span><%=teamInfo.Market_price%><br />
                                                    <span class='money'>￥</span><%=teamInfo.Team_price%>
                                                </td>
                                                <td class="op">
                                                    <a class="ajaxlink" href="ajax_manage.aspx?action=teamdetail&id=<%=teamInfo.Id%>">详情</a>｜
                                                    <a class="deal-title" href="Project_BianjiXiangmu.aspx?id=<%=teamInfo.Id%>">编辑</a>｜
                                                    <a class="deal-title" href="Project_PointXiangmu.aspx?remove=<%= teamInfo.Id%>" ask="确定删除本项目吗?">
                                                        删除</a>｜ <a class="deal-title" href="Project_DangqianXiangmu.aspx?add=<%= teamInfo.Id %>"
                                                            ask="确定复制本项目吗？">复制</a>
                                                    <%
                                                        if (teamInfo.open_invent == 1)
                                                        {
                                                            if (teamInfo.Delivery != "pcoupon")
                                                            {%>
                                                    <br />
                                                    <a class="ajaxlink" href="ajax_coupon.aspx?action=invent&p=&inventid=<%= teamInfo.Id %>"
                                                        target='_blank'>出入库</a>
                                                    <%   }
                                                        }%>
                                                </td>
                                            </tr>
                                            <%
                                                }
                                          } %>
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
                <!-- bd end -->
            </div>
            <!-- bdw end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
