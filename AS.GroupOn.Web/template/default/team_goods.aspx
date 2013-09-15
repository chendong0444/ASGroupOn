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
        public System.Collections.Generic.List<ALink> dalei = new System.Collections.Generic.List<ALink>();
        public System.Collections.Generic.List<ALink> xiaolei = new System.Collections.Generic.List<ALink>();
        public int Parentid = 0;
        public int dangqianid = 0;
        public string sql = String.Empty;
        public string title = String.Empty;
    }

    protected IPagers<ITeam> pager = null;
    protected IList<ITeam> teamlist = null;
    protected string url = "";
    protected string pagerhtml = String.Empty;
    protected TuanGouing tuangou = new TuanGouing();
    public string pages = String.Empty;
    public string strNav = "";
    private DateTime beginTime = Convert.ToDateTime(DateTime.Now.ToString("yyyy-MM-dd" + " 00:00:00"));
    private DateTime endTime = Convert.ToDateTime(DateTime.Now.ToString("yyyy-MM-dd") + " 23:59:59");
    public string strpage;
    public string pagenum = "1";
    public IList<ICatalogs> catalist = null;
    public CatalogsFilter cataft = new CatalogsFilter();
    public string catid = "";
    public string cityid = "";
    protected SystemFilter systemft = new SystemFilter();
    protected ISystem systemModel = null;
    NameValueCollection _system = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {

        base.OnLoad(e);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            systemModel = session.System.GetByID(1);
        }
        _system = AS.Common.Utils.WebUtils.GetSystem();
        if (Request["pgnum"] != null)
        {
            if (AS.Common.Utils.NumberUtils.IsNum(Request["pgnum"].ToString()))
            {
                pagenum = Request["pgnum"].ToString();
            }
            else
            {
                SetError("您输入的参数非法");
            }
        }

        if (ASSystem.title == String.Empty)
        {
            PageValue.Title = "热销商品";

        }
        Getfather();
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
    private void initPage()
    {
        TeamFilter teamft = new TeamFilter();
        string strGID = "";
        if (Request["gid"] == null || Request["gid"].ToString() == "")
        {
            strGID = "";
        }
        else
        {
            strGID = Request["gid"].ToString();
             url += "&gid=" + strGID;
        }
        if (CurrentCity != null)
        {
            teamft.Cityblockothers = CurrentCity.Id;
        }
        teamft.teamcata = 0;
        teamft.Team_type = "goods";
        teamft.ToBegin_time = System.DateTime.Now;
        teamft.FromEndTime = System.DateTime.Now;
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
            initcata(Convert.ToInt32(catid));
            teamft.sql= tuangou.sql;
            url += "&catid=" + catid;
        }
        else
        {
            initcata(0);
        }
        url = url + "&page={0}";
        url = GetUrl("热销项目", "team_goods.aspx?" + url.Substring(1));
        teamft.PageSize = 16;
        teamft.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        teamft.AddSortOrder(TeamFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Teams.GetPager(teamft);
        }
        teamlist = pager.Objects;
        pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(16, pager.TotalRecords, pager.CurrentPage, url);

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
        int cid = 0;
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
                icatalog.SetValue("number", (object)(Catalogs.GetSumTeam("goods", icatalog.id, cid)));
            }
            else
            {
                icatalog.SetValue("number", (object)(Catalogs.GetSumTeam("goods", icatalog.id, cid)));
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
                cata.number = AS.GroupOn.Controls.Catalogs.GetSumTeam("goods", cata.id, cid);
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
                link.url = GetUrl("热销项目", "team_goods.aspx?catid=" + cata.id);
                tuangou.sql = " cataid in(" + delsidechar(cata.id + "," + cata.ids, ',') + ")";
            }
            else
                link.url = GetUrl("热销项目", "team_goods.aspx?catid=" + cata.id);
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
                        link.url = GetUrl("热销项目", "team_goods.aspx?catid=" + cata.id);
                        tuangou.sql = " cataid in(" + delsidechar(cata.id + "," + cata.ids, ',') + ")";
                    }
                    else
                        link.url = GetUrl("热销项目", "team_goods.aspx?catid=" + cata.id);


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
                    <div id="content-goods">
                        <div class="box">
                            <div class="box-content">
                                <div class="head1">
                                    <%--<h2>热销商品</h2>--%>
                                    <%if (systemModel.categoods == 1)
                                      { %>
                                    <dl class="sq">
                                        <dt><a href="#">产品分类</a></dt>
                                        <dd>
                                            <%if (catid != "" && catid != String.Empty)
                                              {%>
                                            <a href="<%=GetUrl("热销项目", "team_goods.aspx")%>">全部</a>
                                            <%}
                                              else
                                              { %>
                                            <a href="<%=GetUrl("热销项目", "team_goods.aspx")%>" class="this_fl">全部</a>
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
                                 <div class="clear"> </div>
                                 <div class="sect">
                                <div class="hot_box">
                                    <!--循环开始（循环deal_shop这个div）-->
                                    <%foreach (ITeam team in teamlist)
                                      {
                                          //Maticsoft.BLL.Team teambll = new Maticsoft.BLL.Team();
                                          //Maticsoft.Model.Team model = teambll.GetModel(Convert.ToInt32(teammodel["Id"].ToString()), false);
                                          
                                    %>
                                    <div class="deal_shop">
                                        <div class="list_img">
                                            <a href="<%=getTeamPageUrl(int.Parse(team.Id.ToString()))  %>"
                                                target="_blank">
                                                <img alt="<%=team.Title%>" src="<%=AS.Common.Utils.ImageHelper.getSmallImgUrl(team.Image).ToString()%>"
                                                    class="dynload" width="218" height="139" />
                                            </a>
                                            <% switch (GetState(team).ToString().Trim())
                                               {
                                                   case "begin":%>
                                            <!-- 正在进行的项目-->
                                            <div class="goods_on">
                                            </div>
                                            <%      break;
                                                   case "successbuy":%>
                                            <!-- 已成功未过期还可以购买-->
                                            <div class="goods_on">
                                            </div>
                                            <%   break;
                                                   case "successnobuy":%>
                                            <!--已成功未过期不可以购买已卖光-->
                                            <div class="isopen">
                                            </div>
                                            <%   break;
                                case "successtimeover":%>
                                            <!-- 已成功已过期-->
                                            <div class="goods_off">
                                            </div>
                                            <%     break;
                                case "fail":%>
                                            <!-- 未成功已过期-->
                                            <div class="goods_off">
                                            </div>
                                            <%     break;
                                case "none":%>
                                            <div class="goods_wait">
                                            </div>
                                            <% break; %>
                                            <%}%>
                                            <a target="_blank" title="热销" href="<%=getTeamPageUrl(int.Parse(team.Id.ToString()))  %>"
                                                class="isopenlink"></a>
                                        </div>
                                        <div class="list_bt">
                                            <a href="<%=getTeamPageUrl(int.Parse(team.Id.ToString()))  %>"
                                                target="_blank">
                                                <%=team.Title%></a></div>
                                        <div class="list_jg">
                                            已有<font><%=team.Now_number%></font>人购买</b><br />
                                            <s>原价：<%=ASSystem.currency%><%=team.Market_price%></s>&nbsp;&nbsp;&nbsp;&nbsp;现价：<font><%=ASSystem.currency%><%=team.Team_price%></font>
                                        </div>
                                        <div class="list_botton-detail">
                                            <%if (team.Farefree != 0)
                                              { %>
                                            <span>
                                                <%=team.Farefree%>件或以上包邮</span>
                                            <% }%>
                                            <a href="<%=getTeamPageUrl(int.Parse(team.Id.ToString()))  %>"
                                                title="去看看" target="_blank"></a>
                                        </div>
                                    </div>
                                    <% }%>
                                    <!--循环结束-->
                                </div></div>
                                <div class="clear">
                                </div>
                                <div>
                                    <ul class="paginator" style="margin-bottom: 30px; *margin-bottom: 14px;">
                                        <li class="current">
                                            <%=pagerhtml%>
                                        </li>
                                    </ul>
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
</html>