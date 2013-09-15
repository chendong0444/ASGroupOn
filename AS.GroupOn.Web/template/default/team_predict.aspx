<%@ Page Language="C#" Debug="true"  Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public class ALink
    {
        public int ID = 0;
        public int number = 0;
        public string Name = String.Empty;
        public string url = String.Empty;
        public string Class = String.Empty;
    }
    public class TuanGouing
    {
        public System.Collections.Generic.List<ALink> dalei
            = new System.Collections.Generic.List<ALink>();
        public System.Collections.Generic.List<ALink> xiaolei
            = new System.Collections.Generic.List<ALink>();
        public int Parentid = 0;
        public int dangqianid = 0;
        public string sql = String.Empty;
        public string title = String.Empty;
    }
    protected TuanGouing tuangou = new TuanGouing();
    protected string pages = String.Empty;
    protected IList<ICatalogs> catalist = null;
    protected CatalogsFilter cataft = new CatalogsFilter();
    protected string catid = "";
    protected int cityid = 0;
    protected string strTitle = "";
    protected TeamFilter teamft = new TeamFilter();
    protected NameValueCollection _system = new NameValueCollection();
    protected ISystem sysmodel = null;
    protected bool result = false;
    protected int currentpage = 1;
    protected override void OnLoad(EventArgs e)
    {

        base.OnLoad(e);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            sysmodel = session.System.GetByID(1);
        }
        _system = AS.Common.Utils.WebUtils.GetSystem();


        if (sysmodel != null && sysmodel.Displayfailure == 1)
        {
            result = true;
        }
        //SetTitle("团购预告");
        Getfather();

        if (Request["search1"] == "搜索")//
        {
            initPage();
        }
        if (!Page.IsPostBack)
        {
            initPage();
        }
    }
    protected void pager_PageChanged(object sender, EventArgs e)
    {
        initPage();
    }
    public void Getfather()
    {
        int city = 0;
        if (CurrentCity != null)
        {
            city = CurrentCity.Id;
        }
        catalist = AS.GroupOn.Controls.Catalogs.GettopCata(city);
    }

    protected void initPage()
    {
        string cityid = "";
        teamft.teamcata = 0;
        teamft.Team_type = "normal";
        if (CurrentCity != null)
        {
            teamft.Cityblockothers = CurrentCity.Id;
        }
        string parameters = "";
        string strGID = "";
        if (Request["gid"] == null || Request["gid"].ToString() == "")
        {
            strGID = "";
        }
        else
        {
            strGID = Request["gid"].ToString();

            parameters = parameters + "&gid=" + Request["gid"].ToString();
        }
        if (!AS.Common.Utils.NumberUtils.IsNum(strGID))
        {
            SetError("参数有误！");
            return;
        }


        string strType = AS.Common.Utils.Helper.GetString(Request["typeid"], String.Empty);
        parameters = parameters + "&typeid=" + Request["typeid"];
        teamft.isPredict = 1;
        teamft.FromBegin_time = DateTime.Now;

        if (strGID != "")
        {
            teamft.Group_id = AS.Common.Utils.Helper.GetInt(strGID, 0);
        }
        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            parameters = parameters + "&id=" + Request["id"];
            teamft.Id = AS.Common.Utils.Helper.GetInt(Request["id"], 0);
        }
        if (Request["title"] != null && Request["title"].ToString() != "")
        {
            txttitle.Text = HttpUtility.UrlDecode(Request["title"].ToString());
        }

        if (this.txttitle.Text != "")
        {
            teamft.TitleLike = this.txttitle.Text.ToString();
            parameters = parameters + "&title=" + HttpUtility.UrlEncode(this.txttitle.Text);
        }
        if (Request["catid"] != null && Request["catid"] != "")
        {
            catid = Request["catid"];
            initcata(Convert.ToInt32(catid));
            //strSqlWhere = strSqlWhere + tuangou.sql;
        }
        else
        {
            initcata(0);
        }
        
        if (Request["page"] != null && Request["page"].ToString() != "")
        {
            currentpage = int.Parse(Request["page"].ToString());

        }

        int recordCount;
        StringBuilder sb = new StringBuilder();
        System.Data.DataTable dt = null;
        IPagers<ITeam> teamlist = null;

        teamft.CurrentPage = currentpage;
        teamft.PageSize = 12;
        if (Request["p"] != null)//按人气排序
        {
            parameters = parameters + "&p=p";
            teamft.AddSortOrder(TeamFilter.Nownumber_DESC);
            teamft.AddSortOrder(TeamFilter.ID_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teamlist = session.Teams.GetPager(teamft);
            }
            //ds = Maticsoft.DBUtility.DbHelperSQL.Page(10, currentpage, "Team", strSqlWhere, " Now_number desc,Id desc", "*", out recordCount);
        }
        else if (Request["d"] != null)//价格由低到高
        {
            parameters = parameters + "&d=d";
            teamft.AddSortOrder(TeamFilter.Team_Price_ASC);
            teamft.AddSortOrder(TeamFilter.ID_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teamlist = session.Teams.GetPager(teamft);
            }
            //ds = Maticsoft.DBUtility.DbHelperSQL.Page(10, currentpage, "Team", strSqlWhere, " Team_price asc,Id desc", "*", out recordCount);
        }
        else if (Request["g"] != null)//价格由高到低
        {
            parameters = parameters + "&g=g";
            teamft.AddSortOrder(TeamFilter.Team_Price_Desc);
            teamft.AddSortOrder(TeamFilter.ID_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teamlist = session.Teams.GetPager(teamft);
            }
            //ds = Maticsoft.DBUtility.DbHelperSQL.Page(10, currentpage, "Team", strSqlWhere, "  Team_price desc,Id desc", "*", out recordCount);
        }
        else
        {            
            teamft.AddSortOrder(TeamFilter.Begin_time_DESC);
            teamft.AddSortOrder(TeamFilter.ID_DESC);
            teamft.AddSortOrder(TeamFilter.Sort_Order_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teamlist = session.Teams.GetPager(teamft);
            }
            //ds = Maticsoft.DBUtility.DbHelperSQL.Page(10, currentpage, "Team", strSqlWhere, " begin_time desc,Sort_order desc ,Id desc", "*", out recordCount);
        }

        dt = AS.Common.Utils.Helper.ToDataTable(teamlist.Objects.ToList());
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    System.Data.DataRow dr = dt.Rows[i];
                    ITeam teamModel = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        teamModel = session.Teams.GetByID(AS.Common.Utils.Helper.GetInt(dr["Id"].ToString(), 0));
                    }
                    string Currency = "";
                    int Moneysave = 0;
                    if (ASSystem != null)
                    {
                        Currency = ASSystem.currency;

                        Moneysave = int.Parse(float.Parse(ASSystem.moneysave.ToString()).ToString());
                    }

                    sb.Append("<li class=\" first\">");
                    sb.Append("<p class=\"time\">" + DateTime.Parse(dr["Begin_time"].ToString()).ToString("yyyy-MM-dd").ToString() + "</p>");

                    if (Moneysave == 1)
                    {
                        sb.Append("<p class='Save_money'>节省：" + ASSystem.currency + (float.Parse(dr["Market_price"].ToString()) - float.Parse(dr["Team_price"].ToString())) + "</p>");
                    }
                    sb.Append("<h4><a href=\"" + getTeamPageUrl(int.Parse(dr["id"].ToString())) + "\" title=\"" + dr["Title"].ToString() + "\" target=\"_blank\">" + dr["Title"].ToString() + "</a></h4>");

                    sb.Append("<div class='info'>");
                    sb.Append("<p class='howmanypp_buy'><strong class='count'>" + dr["Now_number"].ToString() + "</strong>人购买</p>");

                    sb.Append("<p class='price'><span class='price_xian'>现价：</span><span class='xian_money'>" + ASSystem.currency + "" + GetMoney(dr["Team_price"]) + "</span></strong>");
                    sb.Append("<br>原价:<strong class='old'><span class='money'>" + ASSystem.currency + "</span>" + GetMoney(dr["Market_price"]) + "</strong>");
                    sb.Append("<br>折扣：<strong class='discount'>" + AS.Common.Utils.WebUtils.GetDiscount(AS.Common.Utils.Helper.GetDecimal(dr["Market_price"], 0), AS.Common.Utils.Helper.GetDecimal(dr["Team_price"], 0)) + "</strong><br></p></div>");

                    sb.Append("<div class=\"pic\">");
                    if (teamModel != null)
                    {
                        sb.Append("<div class='normal_wait' ></div>");
                    }

                    sb.Append("<a href=\"" + getTeamPageUrl(int.Parse(dr["id"].ToString())) + "\" class=\"isopenlink\" title=\"" + dr["Title"].ToString() + "\" target=\"_blank\"></a>");
                    sb.Append("<a href=\"" + getTeamPageUrl(int.Parse(dr["id"].ToString())) + "\" title=\"" + dr["Title"].ToString() + "\" target=\"_blank\"><img alt=\"" + dr["Title"].ToString() + "\"  src=\"" + AS.Common.Utils.ImageHelper.getSmallImgUrl(dr["Image"].ToString()) + "\" width=\"163\" height=\"104\"></a>");
                    sb.Append("</div>");
                    sb.Append("</li>");
                }
            }

        }        
        //if (recordCount >= 10)
        pages = AS.Common.Utils.WebUtils.GetPagerHtml(12, teamlist.TotalRecords, teamlist.CurrentPage, GetUrl("团购预告", "team_predict.aspx?page={0}" + parameters + "&catid=" + Request["catid"]));
        ltTeam.Text = sb.ToString();
    }
    protected string delsidechar(string str, char c)
    {
        str = str.Replace(",,", ",");
        if (str.Length > 0 && str[0] == c)
            str = str.Substring(1);
        if (str.Length > 0 && str[str.Length - 1] == c)
        {
            str = str.Substring(0, str.Length - 1);
        }
        return str;
    }
    protected void initcata(int id)
    {
        IList<ICatalogs> biglistcata = null;
        IList<ICatalogs> childcatalist = null;
        CatalogsFilter cataft = new CatalogsFilter();
        ICatalogs catalogrow = null;
        int cid = 0;
        int number = 0;
        cataft.type = 0;
        cataft.visibility = 0;
        if (id > 0)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                catalogrow = session.Catalogs.GetByID(id);
            }
        }
        cataft.parent_id = 0;
        cataft.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
        cataft.AddSortOrder(CatalogsFilter.ID_ASC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            biglistcata = session.Catalogs.GetList(cataft);
        }
        string ids = String.Empty;
        if (CurrentCity != null)
        {
            cid = CurrentCity.Id;
        }
        foreach (ICatalogs icatalog in biglistcata)
        {
            ids = icatalog.id.ToString();
            if (icatalog.ids.Length > 0) ids = ids + "," + icatalog.ids;
            ids = delsidechar(ids, ',');
            if (cid > 0)
            {
                icatalog.SetValue("number", (object)(Catalogs.GetSumTeam("notice", icatalog.id, cid)));
            }
            else
            {
                icatalog.SetValue("number", (object)(Catalogs.GetSumTeam("notice", icatalog.id, cid)));
            }
        }
        if (catalogrow != null)
        {
            CatalogsFilter catalogft = new CatalogsFilter();
            catalogft.type = 0;
            catalogft.visibility = 0;
            catalogft.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
            catalogft.AddSortOrder(CatalogsFilter.ID_ASC);

            if (catalogrow.parent_id == 0)
            {
                catalogft.parent_id = catalogrow.id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    childcatalist = session.Catalogs.GetList(catalogft);
                }
            }
            else
            {
                catalogft.parent_id = catalogrow.parent_id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    childcatalist = session.Catalogs.GetList(catalogft);
                }
            }
            tuangou.Parentid = catalogrow.parent_id;
            tuangou.dangqianid = catalogrow.id;
            tuangou.title = catalogrow.catalogname + " " + tuangou.title;


            foreach (ICatalogs cata in childcatalist)
            {
                ids = cata.id.ToString();
                if (cata.ids.Length > 0) ids = ids + "," + cata.ids;
                ids = ids.Replace(",,", ",");
                cata.number = AS.GroupOn.Controls.Catalogs.GetSumTeam("notice", cata.id, cid);
            }

        }

        //大分类
        foreach (ICatalogs row in biglistcata)
        {
            ALink link = new ALink();
            link.Name = row.catalogname;
            link.number = row.number;
            link.ID = row.id;
            if (row.id == id)
            {
                if (Request["p"] != null)
                {
                    link.url = GetUrl("团购预告", "team_predict.aspx?p=p&catid=" + row.id);
                }
                else if (Request["g"] != null)
                {
                    link.url = GetUrl("团购预告", "team_predict.aspx?g=g&catid=" + row.id);
                }
                else if (Request["d"] != null)
                {
                    link.url = GetUrl("团购预告", "team_predict.aspx?d=d&catid=" + row.id);
                }
                else
                {
                    link.url = GetUrl("团购预告", "team_predict.aspx?catid=" + row.id);
                }
                teamft.CataIDin = delsidechar(row.id + "," + row.ids, ',');
            }
            else
            {
                if (Request["p"] != null)
                {
                    link.url = GetUrl("团购预告", "team_predict.aspx?p=p&catid=" + row.id);
                }
                else if (Request["g"] != null)
                {
                    link.url = GetUrl("团购预告", "team_predict.aspx?g=g&catid=" + row.id);
                }
                else if (Request["d"] != null)
                {
                    link.url = GetUrl("团购预告", "team_predict.aspx?d=d&catid=" + row.id);
                }
                else
                {
                    link.url = GetUrl("团购预告", "team_predict.aspx?catid=" + row.id);
                }
            }
            tuangou.dalei.Add(link);

        }
        //小分类
        if (childcatalist != null)
        {
            foreach (ICatalogs row in childcatalist)
            {
                if (catalogrow != null)
                {
                    ALink link = new ALink();

                    if (catalogrow.id == row.id)
                    {
                        if (Request["p"] != null)
                        {
                            link.url = GetUrl("团购预告", "team_predict.aspx?p=p&catid=" + row.id);
                        }
                        else if (Request["g"] != null)
                        {
                            link.url = GetUrl("团购预告", "team_predict.aspx?g=g&catid=" + row.id);
                        }
                        else if (Request["d"] != null)
                        {
                            link.url = GetUrl("团购预告", "team_predict.aspx?d=d&catid=" + row.id);
                        }
                        else
                        {
                            link.url = GetUrl("团购预告", "team_predict.aspx?catid=" + row.id);
                        }
                        teamft.CataIDin = delsidechar(row.id + "," + row.ids, ',');
                    }
                    else
                    {
                        if (Request["p"] != null)
                        {
                            link.url = GetUrl("团购预告", "team_predict.aspx?p=p&catid=" + row.id);
                        }
                        else if (Request["g"] != null)
                        {
                            link.url = GetUrl("团购预告", "team_predict.aspx?g=g&catid=" + row.id);
                        }
                        else if (Request["d"] != null)
                        {
                            link.url = GetUrl("团购预告", "team_predict.aspx?d=d&catid=" + row.id);
                        }
                        else
                        {
                            link.url = GetUrl("团购预告", "team_predict.aspx?catid=" + row.id);
                        }
                    }
                    link.Name = row.catalogname;
                    link.number = row.number;
                    link.ID = row.id;
                    tuangou.xiaolei.Add(link);
                }
            }
        }

    }
    
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" action="predict.html" runat="server">
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="recent-deals">
                    <div id="content-seconds">
                        <div class="box">
                            <div class="box-content">
                                <div class="head1">
                                    <%if (_system["teamdpredict"] == "1")//sysmodel.cateteam == 1 ||
                                      {%>
                                    <dl class="sq">
                                        <dt><a href="#">产品分类</a></dt>
                                        <dd>
                                            <%if (catid != "" && catid != String.Empty)
                                              {%>
                                            <a href="<%=GetUrl("团购预告", "team_predict.aspx")%>">全部</a>
                                            <%}
                                              else
                                              { %>
                                            <a href="<%=GetUrl("团购预告", "team_predict.aspx")%>" class="this_fl">全部</a>
                                            <%} %>
                                            <%for (int i = 0; i < tuangou.dalei.Count; i++)
                                              {%>
                                            <%if (catid != "" && catid != String.Empty)
                                              {%>
                                            <%if (int.Parse(catid) == tuangou.dalei[i].ID || tuangou.Parentid == tuangou.dalei[i].ID)
                                              { %>
                                            <a href="<%=tuangou.dalei[i].url %>" class="this_fl">
                                                <%=tuangou.dalei[i].Name%>(<%=tuangou.dalei[i].number%>)</a>
                                            <% }
                                              else
                                              {%>
                                            <a href="<%=tuangou.dalei[i].url %>">
                                                <%=tuangou.dalei[i].Name%>(<%=tuangou.dalei[i].number%>)</a>
                                            <% }%>
                                            <%}
                                              else
                                              { %>
                                            <a href="<%=tuangou.dalei[i].url %>">
                                                <%=tuangou.dalei[i].Name%>(<%=tuangou.dalei[i].number%>)</a>
                                            <%} %>
                                            <% }%>
                                        </dd>
                                        <%if (catid != "" && catid != String.Empty)
                                          {%>
                                        <% 
                                            if (tuangou.xiaolei.Count > 0)
                                            { %>
                                        <p class="clear">
                                            <% 
                                                for (int j = 0; j < tuangou.xiaolei.Count; j++)
                                                {
                                            %>
                                            <%if (catid != "" && catid != String.Empty)
                                              {%>
                                            <%if (int.Parse(catid) == tuangou.xiaolei[j].ID)
                                              { %>
                                            <a name="liujiay" href="<%=tuangou.xiaolei[j].url %>" class="this_fl">
                                                <%=tuangou.xiaolei[j].Name%>(<%=tuangou.xiaolei[j].number%>)</a>
                                            <% }
                                              else
                                              {%>
                                            <a name="liujiay" href="<%=tuangou.xiaolei[j].url %>">
                                                <%=tuangou.xiaolei[j].Name%>(<%=tuangou.xiaolei[j].number%>)</a>
                                            <% }%>
                                            <% }
                                              else
                                              { %>
                                            <a name="liujiay" href="<%=tuangou.xiaolei[j].url %>">
                                                <%=tuangou.xiaolei[j].Name%>(<%=tuangou.xiaolei[j].number%>)</a>
                                            <%} %>
                                            <%  } %>
                                            <%} %>
                                        </p>
                                        <%}%>
                                    </dl>
                                    <%} %>
                                    <div class="wq_find1">
                                        <div class="wq_sel">
                                            <asp:TextBox ID="txttitle" runat="server"></asp:TextBox>
                                            <input id="Submit1" class="formbutton1" type="submit" value="搜索" name="search1" />
                                        </div>
                                        <div class="wq_Sort">
                                            <dt><a>排&nbsp;&nbsp;&nbsp;&nbsp;序</a></dt>
                                            <dd>
                                                <%if (Request["p"] != null || Request["d"] != null || Request["g"] != null)
                                                  {%>
                                                <a href="<%=GetUrl("团购预告", "team_predict.aspx?catid="+catid)%>">默认</a>
                                                <%}
                                                  else
                                                  { %>
                                                <a href="<%=GetUrl("团购预告", "team_predict.aspx")%>" class="this_fl">默认</a>
                                                <%} %>
                                                <%if (Request["p"] != null && Request["p"] != String.Empty)
                                                  {%>
                                                <a href="<%=GetUrl("团购预告", "team_predict.aspx?p=p&catid="+catid)%>" class="this_fl">
                                                    人气</a>
                                                <%}
                                                  else
                                                  { %>
                                                <a href="<%=GetUrl("团购预告", "team_predict.aspx?p=p&catid="+catid)%>">人气</a>
                                                <%} %>
                                                <%if (Request["d"] != null)
                                                  { %>
                                                <a href="<%=GetUrl("团购预告", "team_predict.aspx?g=g&catid="+catid)%>" class="this_fl">
                                                    价格由高到低</a>
                                                <% }
                                                  else if (Request["g"] != null)
                                                  {%>
                                                <a href="<%=GetUrl("团购预告", "team_predict.aspx?d=d&catid="+catid)%>" class="this_fl">
                                                    价格由低到高</a>
                                                <% }
                                                  else
                                                  {%>
                                                <a href="<%=GetUrl("团购预告", "team_predict.aspx?d=d&catid="+catid)%>">价格由低到高</a>
                                                <% }%>
                                            </dd>
                                        </div>
                                    </div>
                                </div>
                                <div class="sect">
                                    <ul class="deals-list2" style=" float:left;">
                                        <asp:Literal ID="ltTeam" runat="server"></asp:Literal>
                                    </ul>
                                    <div class="clear">
                                    </div>
                                    <div>
                                        <%=pages%>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="sidebar">
                        <div class="bottom">
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- bd end -->
    </div>
    <!-- bdw end -->
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>