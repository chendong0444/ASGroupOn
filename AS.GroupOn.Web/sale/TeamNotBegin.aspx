<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.SalePage" %>

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
    string dataTime = System.DateTime.Today.ToString("yyyy-MM-dd");
    public string style = "";
    public string style1 = "";
    public string style2 = "";
    public string style3 = "";
    public string sql = "";
    public int pagenum = 0;
    private NameValueCollection _system = new NameValueCollection();
    int strSaleId = 0;
    int page = 1;
    protected string pagerhtml = String.Empty;
    string url = String.Empty;
    string request_shuxing = String.Empty;
    string request_fenlei = String.Empty;
    string request_selecttype = String.Empty;
    string request_selectconent = String.Empty;
    string request_teamtype = String.Empty;
    protected IList<ICatalogs> ilistcata = null;
    protected CatalogsFilter catafilter = new CatalogsFilter();
    protected TeamFilter teamfilter = new TeamFilter();
    protected IList<ITeam> ilistteam = null;
    protected IPagers<ITeam> pager = null;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        strSaleId = Helper.GetInt(CookieUtils.GetCookieValue("sale", key).ToString(), 0);
        _system = WebUtils.GetSystem();

        if (Request.HttpMethod == "POST")
        {
            request_selecttype = ddlstate.Value.ToString();
            request_shuxing = ddlhost.Value.ToString();
            request_fenlei = ddlparent.SelectedValue.ToString();
            request_selectconent = txtteam.Value.ToString();
            request_teamtype = Helper.GetString(Request.QueryString["team_type"], String.Empty);
        }
        else
        {
            request_selecttype = Helper.GetString(Request.QueryString["selecttype"], String.Empty);
            request_shuxing = Helper.GetString(Request.QueryString["shuxing"], String.Empty);
            request_fenlei = Helper.GetString(Request.QueryString["fenlei"], String.Empty);
            request_teamtype = Helper.GetString(Request.QueryString["team_type"], String.Empty);
            request_selectconent = Helper.GetString(Request.QueryString["selectconent"], String.Empty);
            page = Helper.GetInt(Request.QueryString["page"], 1);
            ddlstate.Value = request_selecttype;
            ddlhost.Value = request_shuxing;
            ddlparent.SelectedValue = request_fenlei;
            txtteam.Value = request_selectconent;
        }

        if (!Page.IsPostBack)
        {
            cataloglist();
        }

        if (Request.QueryString["team_type"] != null)
        {
            switch (Request.QueryString["team_type"].ToString())
            {
                case "normal":
                    style1 = "current";
                    break;
                case "seconds":
                    style2 = "current";
                    break;
                case "goods":
                    style3 = "current";
                    break;
            }
            sqlWhere = "  sale_id=" + strSaleId + " and Begin_time >GetDate() and Team_type='" + request_teamtype.Replace("'", "''") + "' ";
            url = "team_type=" + request_teamtype.Replace("'", "''");
        }
        else
        {
            style = "current";
        }

        sqlWhere = sqlWhere + " and team_type<>'point' ";

        if (request_teamtype != String.Empty)
        {
            sqlWhere = "  sale_id=" + strSaleId + " and Begin_time >GetDate() and Team_type='" + request_teamtype.Replace("'", "''") + "' ";
            url = "team_type=" + request_teamtype.Replace("'", "''");
        }
        else
        {
            sqlWhere = "  sale_id=" + strSaleId + " and Begin_time >GetDate() and team_type<>'point'";
        }

        if (request_selecttype != "0" && request_selecttype != String.Empty)
        {
            if (request_selecttype == "1")//项目ID
            {
                sqlWhere += "  and Id='" + Helper.GetInt(request_selectconent, 0) + "' ";
            }
            else if (request_selecttype == "2")//项目标题
            {
                sqlWhere += "  and Title like '%" + request_selectconent + "%' ";
            }
            else if (request_selecttype == "3")//城市
            {
                CategoryFilter catefilter = new CategoryFilter();
                IList<ICategory> icate = null;
                catefilter.NameLike = Helper.GetString(request_selectconent, string.Empty);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    icate = session.Category.GetList(catefilter);
                }

                if (icate.Count > 0)
                {
                    foreach (ICategory cate in icate)
                    {
                        sqlWhere += "  and  City_id=" + Helper.GetInt(cate.Id.ToString(), 0) + "";
                    }
                }
            }
            else if (request_selecttype == "4")
            {
                sqlWhere += " and Partner_id='" + Helper.GetInt(request_selectconent, 0) + "'";
            }
            else if (request_selecttype == "0")
            {

            }
            url += "&selecttype=" + request_selecttype;
            url += "&selectconent=" + Server.UrlEncode(request_selectconent);
        }


        if (request_shuxing == "1")
        {
            sqlWhere += "   and teamhost=1";
            url += "&shuxing=" + request_shuxing;

        }
        else if (request_shuxing == "2")
        {
            sqlWhere += "   and teamhost=2";
            url += "&shuxing=" + request_shuxing;

        }
        if (request_fenlei != "0" && request_fenlei != String.Empty)
        {
            string cid = "";
            ICatalogs cata = Store.CreateCatalogs();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                cata = session.Catalogs.GetByID(Helper.GetInt(request_fenlei, 0));
            }
            if (cata != null)
            {
                if (Helper.GetString(cata.ids, "") != "")
                {
                    cid = cata.ids + "," + request_fenlei;

                }
                else
                {
                    cid = request_fenlei.ToString();
                }
            }
            sqlWhere += "  and cataid in (" + cid + ")";
            url += "&fenlei=" + request_fenlei;
        }

        getDangqian();
    }

    #region 视图
    public string sqlWhere
    {
        get
        {
            if (this.ViewState["sqlWhere"] != null)
                return this.ViewState["sqlWhere"].ToString();
            else
                return "  sale_id=" + strSaleId + " and Begin_time >GetDate() ";

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

        catafilter.type = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistcata = session.Catalogs.GetList(catafilter);
        }
        System.Data.DataTable dt = AS.Common.Utils.Helper.ToDataTable(ilistcata.ToList());

        this.ddlparent.Items.Add(new ListItem("请选择", "0"));
        BindData(dt, 0, "");

    }

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
    #endregion


    /// <summary>
    /// 内容列表
    /// </summary>
    private void getDangqian()
    {
        string sql1 = sqlWhere;
        Session["sql"] = sqlWhere;
        Literal1.Text = "<tr ><th width='10%'>ID</th><th width='20%'>项目名称</th><th width='10%' nowrap>属性</th><th width='10%' nowrap>类别</th><th width='10%' nowrap>排序</th><th width='10%'>日期</th><th width='8%'>成交</th><th width='7%' nowrap>价格</th><th width='15%'>操作</th></tr>";
        StringBuilder sb2 = new StringBuilder();
        teamfilter.where = sqlWhere + " and teamcata=0";
        teamfilter.PageSize = 30;
        teamfilter.CurrentPage = page;
        teamfilter.AddSortOrder(TeamFilter.Sort_Order_DESC);
        teamfilter.AddSortOrder(TeamFilter.Begin_time_DESC);
        teamfilter.AddSortOrder(TeamFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Teams.GetPager(teamfilter);
        }
        ilistteam = pager.Objects;

        if (ilistteam != null && ilistteam.Count > 0)
        {
            if (ilistteam.Count > 0)
            {
                int i = 0;
                foreach (ITeam teaminfo in ilistteam)
                {
                    if (i % 2 != 0)
                    {
                        sb2.Append("<tr>");
                    }
                    else
                    {
                        sb2.Append("<tr class='alt'>");
                    }
                    sb2.Append("<td>" + teaminfo.Id + "</a></td>");
                    if (teaminfo.Team_type.ToString() == "normal")
                    {
                        sb2.Append("<td><div style=\"word-wrap: break-word;width: 250px; overflow:hidden;\">[团购]	<a class='deal-title' href='" + getTeamPageUrl(Helper.GetInt(teaminfo.Id, 0)) + "' target='_blank'>" + teaminfo.Title + "</a></div></td>");
                    }
                    else if (teaminfo.Team_type.ToString() == "seconds")
                    {
                        sb2.Append("<td><div style=\"word-wrap: break-word;width: 250px; overflow:hidden;\">[秒杀]	<a class='deal-title' href='" + getTeamPageUrl(Helper.GetInt(teaminfo.Id, 0)) + "' target='_blank'>" + teaminfo.Title + "</a></div></td>");
                    }
                    else if (teaminfo.Team_type.ToString() == "goods")
                    {
                        sb2.Append("<td><div style=\"word-wrap: break-word;width: 250px; overflow:hidden;\">[热销]	<a class='deal-title' href='" + getTeamPageUrl(Helper.GetInt(teaminfo.Id, 0)) + "' target='_blank'>" + teaminfo.Title + "</a></div></td>");
                    }
                    sb2.Append("<td>");

                    if (Helper.GetInt(teaminfo.teamhost, 0) == 1)
                    {
                        sb2.Append("新品");

                    }
                    else if (Helper.GetInt(teaminfo.teamhost, 0) == 2)
                    {
                        sb2.Append("推荐");
                    }
                    sb2.Append("<br>");
                    sb2.Append("</td>");

                    sb2.Append("<td nowrap>");
                    ICategory item1 = Store.CreateCategory();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        item1 = session.Category.GetByID(Helper.GetInt(teaminfo.City_id, 0));
                    }

                    if (item1 != null)
                    {
                        sb2.Append(item1.Name);
                    }
                    else
                    {
                        sb2.Append("全部城市");
                    }

                    sb2.Append("<br/>");
                    ICatalogs catamodel = Store.CreateCatalogs();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        catamodel = session.Catalogs.GetByID(Helper.GetInt(teaminfo.cataid, 0));
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
                    CategoryFilter cate = new CategoryFilter();
                    IList<ICategory> ilistcate = null;
                    cate.Id = teaminfo.Group_id;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        ilistcate = session.Category.GetList(cate);
                    }
                    foreach (ICategory cateinfo in ilistcate)
                    {
                        sb2.Append("[" + cateinfo.Name + "](API)");
                    }

                    sb2.Append("</td>");

                    sb2.Append("<td>" + teaminfo.Sort_order + "</td>");
                    sb2.Append("<td nowrap>" + teaminfo.Begin_time + "<br/>" + teaminfo.End_time + "</td>");
                    sb2.Append("<td nowrap>" + teaminfo.Now_number + "/" + teaminfo.Min_number + "</td>");
                    sb2.Append("<td nowrap><span class='money'>¥</span>" + teaminfo.Market_price + "<br/><span class=\'money\'>¥</span>" + teaminfo.Team_price + "</td>");
                    sb2.Append("<td class='op' nowrap>");
                    sb2.Append("<a class='ajaxlink' href='" + PageValue.WebRoot + "manage/ajax_manage.aspx?action=teamdetail&id=" + teaminfo.Id + "'>详情</a>");
                    sb2.Append("</td>");
                    sb2.Append("</tr>");
                    i++;
                }
            }
        }
        Literal2.Text = sb2.ToString();
        pagerhtml = WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, PageValue.WebRoot + "sale/TeamNotBegin.aspx?" + url + "&page={0}");

    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1" runat="server" method="post">
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
                                        未开始项目</h2>
                                    <div class="search">
                                        属性：
                                        <select id="ddlhost" runat="server" class="h-input">
                                            <option value="0">请选择</option>
                                            <option value="1">新品</option>
                                            <option value="2">推荐</option>
                                        </select>
                                        分类：
                                        <asp:DropDownList class="h-input" ID="ddlparent" runat="server">
                                        </asp:DropDownList>
                                        <select id="ddlstate" runat="server" class="h-input">
                                            <option value="0">请选择</option>
                                            <option value="1">项目编号</option>
                                            <option value="2">项目标题</option>
                                            <option value="3">城市</option>
                                        </select>
                                        <input type="text" id="txtteam" class="h-input" runat="server" />
                                        <input type="submit" id="btnselect" group="goto" value="筛选" class="formbutton" name="btnselect"
                                            style="padding: 1px 6px;" />
                                        <ul class="filter" style="top: 0">
                                            <li class="<%=style %>" style="padding-top: 11px;"><a href="TeamNotBegin.aspx">全部</a></li>
                                            <li class="<%=style1 %>" style="padding-top: 11px;"><a href="TeamNotBegin.aspx?team_type=normal">
                                                团购</a></li>
                                            <li class="<%=style2 %>" style="padding-top: 11px;"><a href="TeamNotBegin.aspx?team_type=seconds">
                                                秒杀</a></li>
                                            <li class="<%=style3 %>" style="padding-top: 11px;"><a href="TeamNotBegin.aspx?team_type=goods">
                                                热销</a></li>
                                        </ul>
                                    </div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="9">
                                                <ul class="paginator">
                                                    <li class="current">
                                                        <%= pagerhtml %>
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
    </form>
</body>
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
<%LoadUserControl("_footer.ascx", null); %>
