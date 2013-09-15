<%@ Page Language="C#" Debug="true" Inherits="AS.GroupOn.Controls.BasePage" %>

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
    protected IPagers<ITeam> pager = null;
    protected IList<ITeam> teamlist = null;
    protected string url = "";
    protected TuanGouing tuangou = new TuanGouing();
    public IList<ICatalogs> catafatherlist = null;
    public string strNav = "";
    private DateTime beginTime = DateTime.Now;
    public NameValueCollection _system = new NameValueCollection();
    int page = 1;
    protected string pagerhtml = String.Empty;

    protected SystemFilter systemft = new SystemFilter();
    protected ISystem systemModel = null;
    protected int cityid = 0;
    public string catid = "";
    public string strTitle = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        Form.Action = GetUrl("秒杀项目", "team_seconds.aspx");
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            systemModel = session.System.GetByID(1);
        }
        //NameValueCollection _system = new NameValueCollection();
        _system = AS.Common.Utils.WebUtils.GetSystem();
        Getfather();
        initPage();
        strTitle = "秒杀团购";


    }
    public void Getfather()
    {
        int city = 0;
        if (CurrentCity != null)
        {
            city = CurrentCity.Id;
            CatalogsFilter cataft = new CatalogsFilter();
            cataft.type = 0;
            cataft.parent_id = 0;
            cataft.visibility = 0;
            cataft.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
            cataft.AddSortOrder(CatalogsFilter.ID_DESC);
            System.Data.DataSet ds = new System.Data.DataSet();
            if (cityid == 0)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    catafatherlist = session.Catalogs.GetList(cataft);
                }
            }
            else
            {
                cataft.cityidLikeOr = cityid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    catafatherlist = session.Catalogs.GetList(cataft);
                }
            }
        }
    }
    private void initPage()
    {
        TeamFilter teamft = new TeamFilter();
        StringBuilder sb = new StringBuilder();
        string strGID = "";
        teamft.teamcata = 0;
        teamft.Team_type = "seconds";
        if (Request["gid"] == null || Request["gid"].ToString() == "")
        {
            strGID = "";
        }
        else
        {
            strGID = Request["gid"].ToString();
            url += "&gid=" + strGID;
        }
        string cityid = "";
        if (CurrentCity != null)
        {
            teamft.Cityblockothers = CurrentCity.Id;
        }
        if (strGID != "")
        {
            teamft.Group_id = AS.Common.Utils.Helper.GetInt(strGID, 0);
        }
        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            teamft.Id = AS.Common.Utils.Helper.GetInt(Request["id"], 0);
        }
        if (Request["catid"] != null && Request["catid"] != "")
        {
            catid = Request["catid"];
            initcata(Convert.ToInt32(Request["catid"]));
            teamft.sql = tuangou.sql;
            url += "&catid=" + catid;
        }
        else
        {
            initcata(0);
        }
        if (Request["page"] != null && Request["page"].ToString() != "")
        {
            page = int.Parse(Request["page"].ToString());
        }
        int recordCount;
        url = url + "&page={0}";
        url = GetUrl("秒杀项目", "team_seconds.aspx?" + url.Substring(1));
        teamft.PageSize = 12;
        teamft.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        teamft.AddSortOrder(TeamFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Teams.GetPager(teamft);
        }
        teamlist = pager.Objects;
        pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(12, pager.TotalRecords, pager.CurrentPage, url);
        System.Data.DataTable dt = AS.Common.Utils.Helper.ToDataTable(teamlist.ToList());
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
                        teamModel = session.Teams.GetByID(Convert.ToInt32(dr["Id"].ToString()));
                    }
                    sb.Append("<li class=\" first\">");
                    sb.Append("<p class=\"time\">" + DateTime.Parse(dr["Begin_time"].ToString()).ToString("yyyy-MM-dd").ToString() + "</p>");
                    sb.Append("<h4><a href=\"" + getTeamPageUrl(int.Parse(dr["id"].ToString())) + "\" title=\"" + dr["Title"].ToString() + "\" target=\"_blank\">" + dr["Title"].ToString() + "</a></h4>");
                    sb.Append("<div class='info'>");
                    sb.Append("<p class='howmanypp_buy'><strong class='count'>" + dr["Now_number"].ToString() + "</strong>人购买</p>");

                    sb.Append("<p class='price'><span class='price_xian'>现价：</span><span class='xian_money'>" + ASSystem.currency + "" + GetMoney(dr["Team_price"]) + "</span></strong>");

                    sb.Append("<br>折扣：<strong class='discount'>" + AS.Common.Utils.WebUtils.GetDiscount(AS.Common.Utils.Helper.GetDecimal(dr["Market_price"], 0), AS.Common.Utils.Helper.GetDecimal(dr["Team_price"], 0)) + "</strong>");
                    sb.Append("<br>原价：<strong class='old'><span class='money'>" + ASSystem.currency + "</span>" + GetMoney(dr["Market_price"]) + "</strong><br></p></div>");
                    sb.Append("<div class=\"pic\">");
                    if (teamModel != null)
                    {
                        switch (GetState(teamModel).ToString().Trim())
                        {
                            case "begin":
                                //正在进行的项目
                                sb.Append("<div class='seconds_on'></div>");
                                break;
                            case "successbuy":
                                // 已成功未过期还可以购买
                                sb.Append("<div class='seconds_on'></div>");
                                break;
                            case "successnobuy":
                                //已成功未过期不可以购买已卖光
                                sb.Append("<div class='isopen'></div>");
                                break;
                            case "successtimeover":
                                /// 已成功已过期
                                sb.Append("<div class='seconds_off'></div>");
                                break;
                            case "fail":
                                // 未成功已过期
                                sb.Append("<div class='seconds_off'></div>");
                                break;
                            case "none":
                                //未开始项目
                                sb.Append("<div class='seconds_wait'></div>");
                                break;
                        }
                    }

                    sb.Append("<a class=\"isopenlink\" href=\"" + getTeamPageUrl(int.Parse(dr["id"].ToString())) + "\" title=\"" + dr["Title"].ToString() + "\" target=\"_blank\"></a>");
                    sb.Append("<a href=\"" + getTeamPageUrl(int.Parse(dr["id"].ToString())) + "\" title=\"" + dr["Title"].ToString() + "\" target=\"_blank\"><img alt=\"" + dr["Title"].ToString() + "\" " + AS.Common.Utils.WebUtils.getimgsrc(dr["Image"]) + " class=\"dynload\" width=\"163\" height=\"121\"></a>");
                    sb.Append("</div>");
                    sb.Append("</li>");
                }

            }
        }

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
        ICatalogs catalogrow = null;
        IList<ICatalogs> biglistcata = null;
        IList<ICatalogs> childcatalist = null;
        System.Data.DataTable brands;
        int cid = 0;
        int number = 0;
        if (id > 0)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                catalogrow = session.Catalogs.GetByID(id);
            }
        }
        CatalogsFilter cataft = new CatalogsFilter();
        cataft.parent_id = 0;
        cataft.type = 0;
        cataft.visibility = 0;
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
                icatalog.SetValue("number", (object)(Catalogs.GetSumTeam("seconds", icatalog.id, cid)));
            }
            else
            {
                icatalog.SetValue("number", (object)(Catalogs.GetSumTeam("seconds", icatalog.id, cid)));
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
            if (catalogrow != null)
            {
                tuangou.Parentid = catalogrow.parent_id;
                tuangou.dangqianid = catalogrow.id;
                tuangou.title = catalogrow.catalogname + " " + tuangou.title;
            }
            foreach (ICatalogs cata in childcatalist)
            {
                ids = cata.id.ToString();
                if (cata.ids.Length > 0) ids = ids + "," + cata.ids;
                ids = ids.Replace(",,", ",");
                cata.number = AS.GroupOn.Controls.Catalogs.GetSumTeam("seconds", cata.id, cid);
            }
        }

        //大分类
        foreach (ICatalogs cata in biglistcata)
        {
            ALink link = new ALink();
            link.Name = cata.catalogname;
            link.number = cata.number;
            link.ID = cata.id;
            if (cata.id == id)
            {
                link.url = GetUrl("秒杀项目", "team_seconds.aspx?catid=" + cata.id);
                tuangou.sql = " cataid in(" + delsidechar(cata.id + "," + cata.ids, ',') + ")";
            }
            else
                link.url = GetUrl("秒杀项目", "team_seconds.aspx?catid=" + cata.id);
            tuangou.dalei.Add(link);

        }
        //小分类
        if (childcatalist != null)
        {
            foreach (ICatalogs cata in childcatalist)
            {
                if (catalogrow != null)
                {
                    ALink link = new ALink();
                    if (catalogrow.id == cata.id)
                    {
                        link.url = GetUrl("秒杀项目", "team_seconds.aspx?catid=" + cata.id);
                        tuangou.sql = " cataid in(" + delsidechar(cata.id + "," + cata.ids, ',') + ")";
                    }
                    else
                        link.url = GetUrl("秒杀项目", "team_seconds.aspx?catid=" + cata.id);


                    link.Name = cata.catalogname;
                    link.number = cata.number;
                    link.ID = cata.id;
                    tuangou.xiaolei.Add(link);
                }
            }
        }
    }
  
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
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
                <div id="recent-deals">
                    <div id="content-seconds">
                        <div class="box">
                            <div class="box-content">
                                <div class="head1">
                                    <%if (systemModel.cateseconds == 1)
                                      { %>
                                    <dl class="sq">
                                        <dt><a href="#">产品分类</a></dt>
                                        <dd>
                                            <%if (catid != "" && catid != String.Empty)
                                              {%>
                                            <a href="<%=GetUrl("秒杀项目", "team_seconds.aspx")%>">全部</a>
                                            <%}
                                              else
                                              { %>
                                            <a href="<%=GetUrl("秒杀项目", "team_seconds.aspx")%>" class="this_fl">全部</a>
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
                                </div>
                                <div class="clear">
                                </div>
                                <div class="sect">
                                    <ul class="deals-list2">
                                        <asp:Literal ID="ltTeam" runat="server"></asp:Literal>
                                    </ul>
                                    <div class="clear">
                                    </div>
                                    <div>
                                        <ul class="paginator">
                                            <li class="current">
                                                <%= pagerhtml %>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
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