<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected IPagers<ITeam> pager = null;
    protected IList<ITeam> teamlist = null;
    protected IList<ITeam> teamlist2 = null;
    protected IList<ICatalogs> catalogslist = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected CouponFilter couponfilter = new CouponFilter();
    protected IList<ICatalogs> iListCatalogs = null;
    protected CategoryFilter categoryfilter = new CategoryFilter();
    protected IList<ICategory> iListCategory = null;
    protected CatalogsFilter catalogsfilter = new CatalogsFilter();
    protected System.Data.DataTable catalogsdt = null;
    protected int count = 0;
    protected ITeam teamodel = null;
    protected ICategory categorymodel = null;
    private string href = "";
    private NameValueCollection _system = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = AS.Common.Utils.WebUtils.GetSystem();   
        TeamFilter filter2 = new TeamFilter();

        if (this.Textid.Text != null && this.Textid.Text != "" || Request["Textid"] !=null)//项目ID
        {
            if (Request["Textid"] != null)
            {
                this.Textid.Text = Request["Textid"];
            }
            filter2.Id = AS.Common.Utils.Helper.GetInt(this.Textid.Text, 0);
            url = url + "&Textid=" + this.Textid.Text;
        }

        if (Request.QueryString["remove"] != null && Request.QueryString["remove"] != "")
        {
            delProject(int.Parse(Request.QueryString["remove"].ToString()));
        }
        if (this.Texttitle.Text != null && this.Texttitle.Text != "" || Request["Texttitle"] != null)
        {
            if (Request["Texttitle"] != null)
            {
                this.Texttitle.Text = Request["Texttitle"];
            }
            filter2.TitleLike = this.Texttitle.Text;
            url = url + "&Texttitle=" + this.Texttitle.Text;
        }


        if (this.txtcity.Text != null && this.txtcity.Text != "" || Request["txtcity"] != null)
        {
            if (Request["txtcity"] != null)
            {
                this.txtcity.Text = Request["txtcity"];
            }
            filter2.cityidIn = this.txtcity.Text;
            url = url + "&txtcity=" + this.txtcity.Text;
        }


        #region 复制项目
        if (Request["add"] != null)
        {
            AddTeam(Convert.ToInt32(Request["add"]));
        }
        #endregion
        url = url + "&page={0}";
        url = "Project_ChenggongPointXiangmu.aspx?" + url.Substring(1);

        filter2.PageSize = 30;
        filter2.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        filter2.Team_type = "point";
        filter2.teamcata = 0;
        filter2.AddSortOrder(TeamFilter.Sort_Order_DESC);
        filter2.AddSortOrder(TeamFilter.Begin_time_DESC);
        filter2.AddSortOrder(TeamFilter.ID_DESC);
        //filter2.State = TeamState.xiajia;
        filter2.EndToTime = DateTime.Now;
        filter2.orBegin_time = DateTime.Now;
        filter2.City_id = AsAdmin.City_id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Teams.GetPager(filter2);
        }
        teamlist2 = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }

    #region 复制项目
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
    #endregion

    private void delProject(int id)
    {
        bool result = false;
        result = isExist(id);
        if (result)
        {
            SetError("项目已成交 , 不可删除！");
        }
        else
        {
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                session.Teams.Delete(id);
                //teams.Delete(id, AsUser.Id);
            }
            SetSuccess("删除成功");
        }
    }
    public bool isExist(int id)
    {
        OrderFilter orderfilter = new OrderFilter();
        OrderDetailFilter orderdetailfilter = new OrderDetailFilter();

        IList<IOrderDetail> orderdetaillist = null;
        IList<IOrder> orderlist = null;
        bool result = false;
        orderdetailfilter.TeamidOrder = id;
        orderfilter.Team_id = id;
        orderfilter.State = "pay";

        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            orderdetaillist = session.OrderDetail.GetList(orderdetailfilter);
            orderlist = session.Orders.GetList(orderfilter);
        }

        if (orderlist.Count > 0 || orderdetaillist.Count > 0)
        {
            result = true;
        }
        return result;
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
                                        下架积分项目
                                    </h2>
                                    <div class="search">
                                        &nbsp;&nbsp; 城市:
                                        <asp:TextBox CssClass="h-input" ID="txtcity" runat="server"></asp:TextBox>
                                        项目编号：
                                        <asp:TextBox  CssClass="h-input" ID="Textid" runat="server"></asp:TextBox>
                                        项目标题:
                                        <asp:TextBox CssClass="h-input" ID="Texttitle" runat="server"></asp:TextBox>
                                        <input type="submit" id="btnselect" group="goto" value="筛选" class="formbutton" name="btnselect"
                                            style="padding: 1px 6px;" />
                                            <ul class="filter">
                                        <li><a href="Project_PointXiangmu.aspx">上架积分项目</a></li>
                                        <li class="current"><a href="Project_ChenggongPointXiangmu.aspx?team_type=normal">下架积分项目</a></li>
                                        </ul>
                                    </div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='8%'>
                                                ID
                                            </th>
                                            <th width='20%'>
                                                项目名称
                                            </th>
                                            <th width='10%'>
                                                属性
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
                                            <th width='15%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (teamlist2 != null && teamlist2.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (ITeam teamInfo in teamlist2)
                                              {
                                                  href = getTeamPageUrl(teamInfo.Id);
                                                  if (i%2!=0)
                                                  {%>
                                                      <tr>
                                                  <%}
                                                  else
                                                  {%>
                                                      <tr class="alt">
                                                  <%}
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
                                            <%if (teamInfo.teamhost == 1)
                                              {
                                            %>
                                            <td>
                                                <a>新品</a>
                                            </td>
                                            <%}
                                              else if (teamInfo.teamhost == 2)
                                              {%>
                                            <td>
                                                <a>推荐</a>
                                            </td>
                                            <% }
                                              else
                                              {%>
                                            <td>
                                                <a>&nbsp;</a>
                                            </td>
                                            <%} %>
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
                                                <a>全部城市</a>
                                                <% }
                                                  else
                                                  {%>
                                                <a>城市不存在</a>
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
                                                <a>[<%= catalogs.catalogname %>]</a>
                                                <% }%>
                                                <%else
{%>
                                                <a></a>
                                                <%}
                                                       }
                                                   }
                                                   else
                                                   {%>
                                                <a></a>
                                                <%}%>
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
                                                <a>[<%= category.Name %>](API)</a>
                                                <% }
                                                          else
                                                          {%>
                                                <a></a>
                                                <%}
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
                                                <a>
                                                    <%=teamInfo.Now_number%>/<%=teamInfo.Min_number%></a>
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