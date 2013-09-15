<%@ Page Language="C#" AutoEventWireup="true" EnableViewState="false" Inherits="AS.GroupOn.Controls.SalePage" %>

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
    public string sql = "";
    public int pagenum = 0;
    private NameValueCollection _system = new NameValueCollection();
    int strSaleId = 0;
    protected IList<ICatalogs> ilistcata = null;
    protected CatalogsFilter catafilter = new CatalogsFilter();
    protected TeamFilter teamfilter = new TeamFilter();
    protected IList<ITeam> ilistteam = null;
    protected IPagers<ITeam> pager = null;
    int page = 1;
    protected string pagerhtml = String.Empty;
    string url = String.Empty;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        strSaleId = Helper.GetInt(CookieUtils.GetCookieValue("sale", key).ToString(), 0);

        _system = WebUtils.GetSystem();

        //if (!Page.IsPostBack)
        //{
        cataloglist();

        //}


        #region 根据项目标题查询模糊查询
        //if (Request["btnselect"] == "筛选")
        //{
        sqlWhere = "sale_id=" + CookieUtils.GetCookieValue("sale", key).ToString() + " and Teamcata=1";
        if (!string.IsNullOrEmpty(Request.QueryString["ddlstate"]))
        {
            url = url + "&ddlstate=" + Request.QueryString["ddlstate"];
            if (Request.QueryString["ddlstate"] == "1")//项目ID
            {
                sqlWhere += "  and Id='" + Helper.GetInt(Request.QueryString["txtteam"], 0) + "' ";
            }
            else if (Request.QueryString["ddlstate"] == "2")//项目标题
            {
                sqlWhere += "  and Title like '%" + Request.QueryString["txtteam"] + "%' ";
            }
            else if (Request.QueryString["ddlstate"] == "4")
            {
                sqlWhere += " and Partner_id='" + Helper.GetInt(Request.QueryString["txtteam"], -1) + "'";
            }

            url = url + "&txtteam=" + Request.QueryString["txtteam"];
        }
        if (!string.IsNullOrEmpty(Request.QueryString["ddlhost"]))
        {
            url = url + "&ddlhost=" + Request.QueryString["ddlhost"];
            sqlWhere += " and teamhost=" + Request.QueryString["ddlhost"];

        }

        //if (this.ddlparent.SelectedValue != "0")
        if (!string.IsNullOrEmpty(Request.QueryString["ddlparent"]) && Request.QueryString["ddlparent"] != "0")
        {
            string cid = "";
            ICatalogs cata = Store.CreateCatalogs();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                cata = session.Catalogs.GetByID(Helper.GetInt(Request.QueryString["ddlparent"], 0));
            }
            if (cata != null)
            {
                if (Helper.GetString(cata.ids, "") != "")
                {
                    cid = cata.ids + "," + Request.QueryString["ddlparent"];

                }
                else
                {
                    cid = Request.QueryString["ddlparent"].ToString();
                }
            }
            url = url + "&ddlparent=" + Request.QueryString["ddlparent"];
            sqlWhere += "  and cataid in (" + cid + ")";
        }
        //}
        #endregion

        if (Request["pagenum"] != null)
        {
            sqlWhere = Session["sql"].ToString();
        }
        getDangqian();
    }

    #region 视图
    //public int pages
    //{
    //    get
    //    {
    //        if (this.ViewState["pages"] != null)
    //            return Convert.ToInt32(this.ViewState["pages"].ToString());
    //        else
    //            return 1;
    //    }
    //    set
    //    {
    //        this.ViewState["pages"] = value;
    //    }
    //}
    public string sqlWhere
    {
        get
        {
            if (this.ViewState["sqlWhere"] != null)
                return this.ViewState["sqlWhere"].ToString();
            else
                return "sale_id=" + CookieUtils.GetCookieValue("sale", key).ToString();

        }
        set
        {
            this.ViewState["sqlWhere"] = value;
        }
    }
    #endregion


    #region 显示目录信息
    public void cataloglist()
    {
        this.ddlparent.Items.Clear();
        catafilter.type = 1;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistcata = session.Catalogs.GetList(catafilter);
        }

        System.Data.DataTable dt = AS.Common.Utils.Helper.ToDataTable(ilistcata.ToList());

        this.ddlparent.Items.Add(new ListItem("请选择", "0"));
        BindData(dt, 0, "");

    }
    #endregion

    private void BindData(DataTable dt, int id, string blank)
    {
        if (dt != null && dt.Rows.Count > 0)
        {
            DataView dv = new DataView(dt);
            dv.RowFilter = "parent_id = " + id.ToString();
            if (id != 0)
            {
                blank += "|─";
            }
            foreach (DataRowView drv in dv)
            {
                this.ddlparent.Items.Add(new ListItem(blank + "" + drv["catalogname"].ToString(), drv["id"].ToString()));
                BindData(dt, Convert.ToInt32(drv["id"]), blank);
            }
        }
    }

    private void getDangqian()
    {
        string sql1 = sqlWhere;
        Session["sql"] = sqlWhere;
        Literal1.Text = "<tr ><th width='10%'>ID</th><th width='20%'>项目名称</th><th width='10%' nowrap>属性</th><th width='10%' nowrap>类别</th><th width='10%' nowrap>排序</th><th width='10%'>日期</th><th width='8%'>成交</th><th width='7%' nowrap>价格</th><th width='15%'>操作</th></tr>";
        StringBuilder sb2 = new StringBuilder();

        teamfilter.where = sqlWhere + " and teamcata=1";
        teamfilter.PageSize = 30;
        teamfilter.CurrentPage = Helper.GetInt(Request.QueryString["page"], 1);
        teamfilter.AddSortOrder(TeamFilter.Sort_Order_DESC);
        teamfilter.AddSortOrder(TeamFilter.Begin_time_DESC);
        teamfilter.AddSortOrder(TeamFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Teams.GetPager(teamfilter);
        }
        ilistteam = pager.Objects;
        int i = 0;
        foreach (ITeam item in ilistteam)
        {
            if (i % 2 != 0)
            {
                sb2.Append("<tr>");
            }
            else
            {
                sb2.Append("<tr class='alt'>");
            }
            i++;
            sb2.Append("<td>" + item.Id + "</a></td>");

            sb2.Append("<td><a class='deal-title' href='" + getTeamPageUrl(item.Id) + "' target='_blank'>" + item.Title + "</a></td>");


            sb2.Append("<td>");

            if (item.teamhost == 1)
            {
                sb2.Append("新品上架");

            }
            else if (item.teamhost == 2)
            {
                sb2.Append("热销产品");
            }
            else if (item.teamhost == 3)
            {
                sb2.Append("推荐产品");
            }
            else if (item.teamhost == 4)
            {
                sb2.Append("低价促销");
            }
            sb2.Append("<br>");
            sb2.Append("</td>");

            sb2.Append("<td nowrap>");
            ICatalogs catamodel = Store.CreateCatalogs();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                catamodel = session.Catalogs.GetByID(Helper.GetInt(item.cataid, 0));
            }
            if (catamodel != null)
            {
                sb2.Append("[" + catamodel.catalogname + "]");
            }
            else
            {
                sb2.Append("");
            }
            sb2.Append("<br>");

            sb2.Append("</td>");
            sb2.Append("<td>" + item.Sort_order + "</td>");
            sb2.Append("<td nowrap>" + item.Begin_time + "</td>");
            sb2.Append("<td nowrap>" + item.Now_number + "</td>");
            sb2.Append("<td nowrap><span class='money'>¥</span>" + item.Market_price + "<br/><span class='money'>¥</span>" + item.Team_price + "</td>");
            sb2.Append("<td class='op' nowrap>");
            sb2.Append("<a class='ajaxlink' href='" + PageValue.WebRoot + "manage/ajax_manage.aspx?action=teamdetail&id=" + item.Id + "'>详情</a>");
            sb2.Append("</td>");
            sb2.Append("</tr>");

        }
        Literal2.Text = sb2.ToString();
        pagerhtml = WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, PageValue.WebRoot + "sale/CommodityList.aspx?&page={0}" + url);

    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
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
                                </div>
                                <form id="form2" runat="server" method="get">
                                <div class="search">
                                    <ul>
                                        &nbsp;&nbsp; &nbsp;&nbsp; 属性：
                                        <select id="ddlhost" name="ddlhost" class="h-input">
                                            <option value="">请选择</option>
                                            <option value="2" <%if(Request.QueryString["ddlhost"]=="2"){%> selected<%}%>>热销产品</option>
                                            <option value="1" <%if(Request.QueryString["ddlhost"]=="1"){%> selected<%}%>>新品上架</option>
                                            <option value="3" <%if(Request.QueryString["ddlhost"]=="3"){%> selected<%}%>>推荐产品</option>
                                            <option value="4" <%if(Request.QueryString["ddlhost"]=="4"){%> selected<%}%>>低价促销</option>
                                        </select>
                                        分类：
                                        <asp:DropDownList ID="ddlparent" runat="server" class="h-input">
                                        </asp:DropDownList>
                                        <select id="ddlstate" name="ddlstate" class="h-input">
                                            <option value="">请选择</option>
                                            <option value="1" <%if(Request.QueryString["ddlstate"]=="1"){%> selected<%}%>>项目编号</option>
                                            <option value="2" <%if(Request.QueryString["ddlstate"]=="2"){%> selected<%}%>>项目标题</option>
                                            <option value="4" <%if(Request.QueryString["ddlstate"]=="4"){%> selected<%}%>>商户编号</option>
                                        </select>
                                        <input type="text" id="txtteam" name="txtteam" class="h-input" <%if (!string.IsNullOrEmpty(Request.QueryString["txtteam"]))
                                                  { %>value="<%=Request.QueryString["txtteam"]%>" <%} %> />
                                        <input type="submit" id="btnselect" value="筛选" class="formbutton" name="btnselect"
                                            style="padding: 1px 6px;" /></ul>
                                </div>
                                </form>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="9">
                                                <ul class="paginator">
                                                    <li class="current">
                                                        <%=pagerhtml %>
                                                    </li>
                                                </ul>
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
</body>
<%LoadUserControl("_footer.ascx", null); %>
