<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">

    protected IPagers<ITeam> pager = null;
    protected IList<ITeam> iListTeam = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected CouponFilter couponfilter = new CouponFilter();
    protected int count = 0;

    protected CatalogsFilter catalogsfilter = new CatalogsFilter();
    protected IList<ICatalogs> iListCatalogs = null;
    protected IList<ICatalogs> ilist = null;
    protected CategoryFilter categoryfilter = new CategoryFilter();
    protected IList<ICategory> iListCategory = null;
    protected string style = null;
    protected string style1 = null;
    protected string style2 = null;
    protected string style3 = null;
    protected ITeam teamodel = null;
    protected string key = FileUtils.GetKey();
    protected ICategory categorymodel = null;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_MallTeam_ListView))
        {
            SetError("你不具有查看项目列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        string strPartnerID = CookieUtils.GetCookieValue("partner", key).ToString();
        TeamFilter filter = new TeamFilter();
        catalogsfilter.type = 1;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilist = session.Catalogs.GetList(catalogsfilter);
        }
        System.Data.DataTable dt = AS.Common.Utils.Helper.ToDataTable(ilist.ToList());
        if (!IsPostBack)
        {
            this.ddlparent.Items.Add(new ListItem("请选择", "0"));
            BindData(dt, 0, "");
        }

        style = "current";
        url = url + "&page={0}";
        url = "Commoditylist.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(TeamFilter.Sort_Order_DESC);
        filter.AddSortOrder(TeamFilter.ID_DESC);
        filter.Partner_id = Convert.ToInt32(strPartnerID);
        filter.teamcata = 1;
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);

        //根据项目标题查询模糊查询
        //if (Request.HttpMethod == "POST" && Request["btnselect"] == "筛选")
        //{

            //if (ddlhost.Value != "0")
        if (!string.IsNullOrEmpty(Request.QueryString["ddlhost"]))
            {
                url = url + "&ddlhost=" + Request.QueryString["ddlhost"];
                filter.teamhost = Helper.GetInt(Request.QueryString["ddlhost"], 0);
            }
        //if (this.ddlparent.SelectedValue != "0")
            if (!string.IsNullOrEmpty(Request.QueryString["ddlparent"]) && Request.QueryString["ddlparent"] != "0")
            {
                url = url + "&ddlparent=" + Request.QueryString["ddlparent"];
                filter.CataID = Convert.ToInt32(Request.QueryString["ddlparent"]);
            }
            if (!string.IsNullOrEmpty(Request.QueryString["ddlstate"]))
            {
                url = url + "&ddlstate=" + Request.QueryString["ddlstate"];
                if (Request.QueryString["ddlstate"] == "1")//项目ID
                {
                    filter.Id = AS.Common.Utils.Helper.GetInt(Request.QueryString["txtteam"], 0);
                }
                else if (Request.QueryString["ddlstate"] == "2")//项目标题
                {
                    if (Request.QueryString["txtteam"] != null)
                    {
                        filter.TitleLike = Request.QueryString["txtteam"];
                    }
                }

                else if (Request.QueryString["ddlstate"] == "3")//商户
                {
                    if (Request.QueryString["txtteam"] != null)
                    {
                        filter.Partner_id = Helper.GetInt(Request.QueryString["txtteam"],-1);
                    }
                }
                url = url + "&txtteam=" + Request.QueryString["txtteam"];
            }
        //}
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Teams.GetPager(filter);
        }
        iListTeam = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }

    /// <summary>
    /// 绑定分类
    /// </summary>
    /// <param name="dt"></param>
    /// <param name="id"></param>
    /// <param name="blank"></param>
    private void BindData(System.Data.DataTable dt, int id, string blank)
    {
        if (dt != null && dt.Rows.Count > 0)
        {
            System.Data.DataView dv = new System.Data.DataView(dt);
            dv.RowFilter = "parent_id = " + id.ToString();
            if (id != 0)
            {
                blank += "|─";
            }
            foreach (System.Data.DataRowView drv in dv)
            {
                this.ddlparent.Items.Add(new ListItem(blank + "" + drv["catalogname"].ToString(), drv["id"].ToString()));
                BindData(dt, Convert.ToInt32(drv["id"]), blank);
            }
        }
    }    
</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1" runat="server" method="get">
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
                                        当前项目</h2>
                                    <div class="search">
                                        &nbsp;&nbsp; 属性：
                                        <select id="ddlhost" name="ddlhost" class="h-input">
                                            <option value="">请选择</option>
                                            <option value="2" <% if (Request.QueryString["ddlhost"] == "2")
                                                    {
                                         %>selected="selected"
                                                    <%} %>>热销产品</option>
                                            <option value="1" <% if (Request.QueryString["ddlhost"] == "1")
                                                    {
                                         %>selected="selected"
                                                    <%} %>>新品上架</option>
                                            <option value="3" <% if (Request.QueryString["ddlhost"] == "3")
                                                    {
                                         %>selected="selected"
                                                    <%} %>>推荐产品</option>
                                            <option value="4" <% if (Request.QueryString["ddlhost"] == "4")
                                                    {
                                         %>selected="selected"
                                                    <%} %>>低价促销</option>
                                        </select>
                                        &nbsp;&nbsp;&nbsp;&nbsp;分类：<asp:DropDownList ID="ddlparent" runat="server" CssClass="h-input">
                                        </asp:DropDownList>
                                        &nbsp;&nbsp;
                                        <select id="ddlstate" name="ddlstate" class="h-input">
                                            <option value="">请选择</option>
                                            <option value="1" <% if (Request.QueryString["ddlstate"] == "1")
                                                    {
                                         %>selected="selected"
                                                    <%} %>>项目编号</option>
                                            <option value="2" <% if (Request.QueryString["ddlstate"] == "2")
                                                    {
                                         %>selected="selected"
                                                    <%} %>>项目标题</option>
                                            <option value="3" <% if (Request.QueryString["ddlstate"] == "3")
                                                    {
                                         %>selected="selected"
                                                    <%} %>>商户编号</option>
                                        </select>
                                        &nbsp;&nbsp;<input id="txtteam" name="txtteam" <%if (!string.IsNullOrEmpty(Request.QueryString["txtteam"]))
                                                  { %>value="<%=Request.QueryString["txtteam"]%>"
                                                <%} %>  class="h-input"/>
                                        <input type="submit" id="btnselect" group="goto" value="筛选" class="formbutton" name="btnselect"
                                            style="padding: 1px 6px;" />
                                    </div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='10%'>
                                                ID
                                            </th>
                                            <th width='20%'>
                                                项目名称
                                            </th>
                                            <th width='10%'>
                                                属性
                                            </th>
                                            <th width='10%'>
                                                类别
                                            </th>
                                            <th width='10%'>
                                                排序
                                            </th>
                                            <th width='15%'>
                                                日期
                                            </th>
                                            <th width='7%'>
                                                成交
                                            </th>
                                            <th width='8%'>
                                                价格
                                            </th>
                                            <th width='10%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListTeam != null && iListTeam.Count > 0)
                                          {
                                              int ii = 0;
                                              foreach (ITeam teamInfo in iListTeam)
                                              {

                                                  if (ii % 2 == 0)
                                                  {%>
                                        <tr>
                                            <td>
                                                <%=teamInfo.Id%>
                                            </td>
                                            <td>
                                                <a class="deal-title" href="<%=getTeamPageUrl(Helper.GetInt(teamInfo.Id.ToString(), 0)) %>" target="_blank">
                                                    <%=teamInfo.Title%></a>
                                            </td>
                                            <%if (teamInfo.teamhost == 1)
                                              {
                                            %>
                                            <td>
                                                新品上架
                                            </td>
                                            <%}
                                              else if (teamInfo.teamhost == 2)
                                              {%>
                                            <td>
                                                热销产品
                                            </td>
                                            <% }
                                              else if (teamInfo.teamhost == 3)
                                              {%>
                                            <td>
                                                推荐产品
                                            </td>
                                            <% }
                                              else if (teamInfo.teamhost == 4)
                                              {%>
                                            <td>
                                                低价促销
                                            </td>
                                            <% }
                                              else
                                              {%>
                                            <td>
                                                <a>&nbsp;</a>
                                            </td>
                                            <%} %>
                                            <td>
                                                <% if (teamInfo.cataid != null)
                                                   {
                                                       ICatalogs catalogs = Store.CreateCatalogs();
                                                       using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                       {
                                                           catalogs = session.Catalogs.GetByID(teamInfo.cataid);
                                                       }
                                                       if (catalogs != null)
                                                       {%>
                                                [<%= catalogs.catalogname%>]
                                                <% }
                                                   }%>
                                            </td>
                                            <td>
                                                <%=teamInfo.Sort_order%>
                                            </td>
                                            <td>
                                                <%=teamInfo.Begin_time%>
                                            </td>
                                            <td>
                                                <%=teamInfo.Now_number%>
                                            </td>
                                            <td>
                                                <span class='money'>￥</span><%=teamInfo.Market_price%><br />
                                                <span class='money'>￥</span><%=teamInfo.Team_price%>
                                            </td>
                                            <td class="op">
                                                <a class="ajaxlink" href="<%=PageValue.WebRoot %>manage/ajax_manage.aspx?action=teamdetail&id=<%=teamInfo.Id%>">
                                                    详情</a>
                                            </td>
                                        </tr>
                                        <% }
                                                  else
                                                  {%>
                                        <tr class="alt">
                                            <td>
                                                <%=teamInfo.Id %>
                                            </td>
                                            <td>
                                                <a class="deal-title" href="<%=getTeamPageUrl(Helper.GetInt(teamInfo.Id.ToString(), 0)) %>" target="_blank">
                                                    <%=teamInfo.Title%></a>
                                            </td>
                                            <%if (teamInfo.teamhost == 1)
                                              {
                                            %>
                                            <td>
                                                新品
                                            </td>
                                            <%}
                                              else if (teamInfo.teamhost == 2)
                                              {%>
                                            <td>
                                                推荐
                                            </td>
                                            <% }
                                              else if (teamInfo.teamhost == 3)
                                              {%>
                                            <td>
                                                明星产品
                                            </td>
                                            <% }
                                              else if (teamInfo.teamhost == 4)
                                              {%>
                                            <td>
                                                低价促销
                                            </td>
                                            <% }
                                              else
                                              {%>
                                            <td>
                                                <a>&nbsp;</a>
                                            </td>
                                            <%} %>
                                            <td>
                                                <% if (teamInfo.cataid != null)
                                                   {
                                                       ICatalogs catalogs = Store.CreateCatalogs();
                                                       using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                       {
                                                           catalogs = session.Catalogs.GetByID(teamInfo.cataid);
                                                       }
                                                       if (catalogs != null)
                                                       {%>
                                                [<%= catalogs.catalogname %>]
                                                <%   }


                                                   }%>
                                            </td>
                                            <td>
                                                <%=teamInfo.Sort_order %>
                                            </td>
                                            <td>
                                                <%=teamInfo.Begin_time%>
                                            </td>
                                            <td>
                                                <%=teamInfo.Now_number%>
                                            </td>
                                            <td>
                                                <span class='money'>￥</span><%=teamInfo.Market_price%><br />
                                                <span class='money'>￥</span><%=teamInfo.Team_price%>
                                            </td>
                                            <td class="op">
                                                <a class="ajaxlink" href="<%=PageValue.WebRoot %>manage/ajax_manage.aspx?action=teamdetail&id=<%=teamInfo.Id%>">
                                                    详情</a>
                                            </td>
                                        </tr>
                                        <%}
                                                  ii++;
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
<script type="text/javascript">

    jQuery(function () {
        $('input').keyup(function (event) {

            if (event.keyCode == "13") {
                document.getElementById("btnselect").click();   //服务器控件loginsubmit点击事件被触发
                return false;
            }

        });

    }); 
</script>
