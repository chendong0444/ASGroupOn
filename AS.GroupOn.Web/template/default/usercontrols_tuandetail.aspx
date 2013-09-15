<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="AS.GroupOn.Domain.Spi" %>
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
        public TuanGouing()
        {
            ALink a1 = new ALink();
            a1.Name = "默认";
            a1.ID = 0;
            sorts.Add(a1);
            ALink a2 = new ALink();
            a2.Name = "人气";
            a2.ID = 1;
            sorts.Add(a2);
            ALink a3 = new ALink();
            a3.Name = "价格由低到高";
            a3.ID = 2;
            sorts.Add(a3);
        }
        public List<ALink> dalei = new List<ALink>();
        public List<ALink> xiaolei = new List<ALink>();
        public List<ALink> pinpai = new List<ALink>();
        public List<ALink> keyword = new List<ALink>();
        public List<ALink> sorts = new List<ALink>();
        public List<ALink> area = new List<ALink>();
        public List<ALink> circle = new List<ALink>();
        public int Parentid = 0;
        public int dangqianid = 0;
        public string sql = String.Empty;
        public string title = String.Empty;
    }
    string detail = "";
    string where = "1=1";
    protected bool over = false;
    protected int size = 0;
    protected int offset = 0;
    protected int imageindex = 2;
    protected int teamid = 0;
    new protected ITeam CurrentTeam = Store.CreateTeam();
    protected IPartner part = Store.CreatePartner();
    protected int twoline = 0;
    protected long curtimefix = 0;
    protected long difftimefix = 0;
    protected AS.Enum.TeamState state = AS.Enum.TeamState.none;
    protected string teamstatestring = String.Empty;//项目状态的英文soldout卖光,success成功,failure失败
    public string strtitle = "";
    public IUser usermodel = Store.CreateUser();
    protected DateTime overtime = DateTime.Now;  //团购结束时间
    public int sortorder = 0;
    protected bool buy = true;//允许购买
    protected int ordercount = 0;//成功购买当前项目的订单数量l
    protected int detailcount = 0;//成功购买当前项目数量
    protected int buycount = 0;//当前项目购买数量
    protected string buyurl = String.Empty;//购买按钮链接
    public NameValueCollection _system = new NameValueCollection();
    public IUserReview userreviewModel = Store.CreateUserReview();
    public int cityid = 0;

    public ICatalogs catamodel = Store.CreateCatalogs();
    public UserReviewFilter userreviewfilter = new UserReviewFilter();
    public IList<key> keylist = null;
    public IList<ICatalogs> catalist = null;//显示大类
    public IList<ICatalogs> cataloglist = null;//根据条件显示全部类别
    public IList<ICatalogs> catafatherlist = null;//查询全部的父类
    public IList<ICatalogs> catachildlist = null;//查询父类下的子类
    public IList<ITeam> teamlist = null;//显示分类下面的项目
    public IList<ICatalogs> childlist = null;//查询子类下的子类
    public IList<IUserReview> listuserreview = null;
    public IPagers<IAsk> pager = null;
    public IPagers<ITeam> teampager = null;
    public IList<IAsk> listask = null;
    public List<Hashtable> hashtable = null;
    protected IList<IAsk> asks = null;

    public string child = "";//记录父类下面的子类

    public string keyid = "";//分类的编号

    public string keyname = "";//分类的名称

    public string kfid = "";

    public int cataid = 0;//获取项目的分类的编号
    public string name = "";//获取项目的分类的名称

    public string sort = " sort_order desc,Begin_time desc,id desc";//排序
    public string sortname = "";
    public string strwhere = "";

    public int currentcityid = 0;
    public string strpage;
    public string pagenum = "1";
    protected TuanGouing tuangou = new TuanGouing();
    protected int catalogid = 0;
    protected int brandid = 0;
    protected int sortid = 0;
    protected int areaid = 0;
    protected int quyu = 0;
    protected int shangquan = 0;
    protected string keyword = String.Empty;
    protected string addkeyname = String.Empty;
    protected string pagerhtml = String.Empty;
    protected string catalogAll = "";
    protected string brandAll = "";
    protected string keywordAll = "";
    protected string areaAll = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        catalogid = Helper.GetInt(Request["catalogid"], 0);
        brandid = Helper.GetInt(Request["brandid"], 0);
        keyword = Helper.GetString(Request["keyword"], String.Empty);
        sortid = Helper.GetInt(Request["sort"], 0);
        areaid = Helper.GetInt(Request["areaid"], 0);
        tuangou.title = ASSystem.title;
        _system = WebUtils.GetSystem();
        if (Request.HttpMethod == "POST" && Request.Form["title"] != null)
        {
            Response.Redirect(getTeamDetailPageUrl(0, 0, 0, 0, Server.UrlEncode(Request.Form["title"])));
        }
        if (Request["search"] == "搜索")
        {
            if (Request["title"] != null)
            {
                keyword = Helper.GetString(Request["title"], String.Empty);
            }
        }
        if (Request["pgnum"] != null)
        {
            if (NumberUtils.IsNum(Request["pgnum"].ToString()))
            {
                pagenum = Request["pgnum"].ToString();
            }
            else
            {
                SetError("您输入的参数非法");
            }
        }
        if (CurrentCity != null) cityid = CurrentCity.Id;
        ICatalogs catalogrow = null;
        IList<ICatalogs> bigcatalogs = null;
        IList<ICatalogs> childcatalogs = null;
        IList<ICategory> brands = null;
        CategoryFilter catafilter = new CategoryFilter();
        catafilter.Zone = "brand";
        catafilter.Display = "Y";
        catafilter.AddSortOrder(CategoryFilter.Sort_Order_DESC);
        catafilter.AddSortOrder(CategoryFilter.ID_ASC);
        using (IDataSession session = Store.OpenSession(false))
        {
            brands = session.Category.GetList(catafilter);
        }
        if (brands != null && brands.Count > 0)
        {
            foreach (ICategory row in brands)
            {
                if (cityid > 0)
                    row.SetValue("number", (object)(TeamMethod.GetSumByArea(0, null, row.Id, cityid, areaid)));
                else
                    row.SetValue("number", (object)(TeamMethod.GetSumByArea(0, null, row.Id, 0, areaid)));
            }
        }
        IList<IArea> areas = null;
        IList<IArea> circles = null;
        if (catalogid > 0)
        {
            using (IDataSession session = Store.OpenSession(false))
            {
                catalogrow = session.Catalogs.GetByID(catalogid);
            }
        }
        CatalogsFilter cf = new CatalogsFilter();
        cf.type = 0;
        cf.parent_id = 0;
        cf.cityidLikeOr = cityid;
        cf.visibility = 0;
        cf.AddSortOrder(CatalogsFilter.MoreSort_DESC_ASC);
        using (IDataSession session = Store.OpenSession(false))
        {
            bigcatalogs = session.Catalogs.GetList(cf);
        }
        string ids = String.Empty;
        if (bigcatalogs != null && bigcatalogs.Count > 0)
        {
            foreach (ICatalogs row in bigcatalogs)
            {
                if (cityid > 0)
                    row.SetValue("number", (object)(TeamMethod.GetSumByArea(row.id, null, 0, cityid, areaid)));
                else
                    row.SetValue("number", (object)(TeamMethod.GetSumByArea(row.id, null, 0, 0, areaid)));
            }
        }

        if (catalogrow != null)
        {
            CatalogsFilter cataf = new CatalogsFilter();
            cataf.type = 0;
            cataf.visibility = 0;
            cataf.AddSortOrder(CatalogsFilter.MoreSort_DESC_ASC);
            if (catalogrow.parent_id == 0)
            {
                cataf.parent_id = catalogrow.id;
                using (IDataSession session = Store.OpenSession(false))
                {
                    childcatalogs = session.Catalogs.GetDetail(cataf);
                }
            }
            else
            {
                cataf.parent_id = catalogrow.parent_id;
                using (IDataSession session = Store.OpenSession(false))
                {
                    childcatalogs = session.Catalogs.GetDetail(cataf);
                }
            }
            foreach (ICatalogs row in childcatalogs)
            {
                row.SetValue("number", (object)(TeamMethod.GetSumByArea(row.id, null, 0, cityid, areaid)));
            }
        }
        //根据城市查询区域
        if (cityid > 0)
        {
            AreaFilter af = new AreaFilter();
            AreaFilter areaf = new AreaFilter();
            af.type = "area";
            af.display = "Y";
            af.cityid = cityid;
            using (IDataSession session = Store.OpenSession(false))
            {
                areas = session.Area.GetList(af);
            }
            if (areas != null && areas.Count > 0)
            {
                foreach (IArea row in areas)
                {
                    ALink link = new ALink();
                    link.Name = row.areaname;
                    link.number = TeamMethod.GetSumByArea(catalogid, keyword, brandid, cityid, row.id);
                    link.ID = row.id;
                    if (areaid == row.id)
                    {
                        link.url = getTeamDetailPageUrl(catalogid, brandid, sortid, 0, Server.UrlEncode(keyword));
                    }
                    else
                    {
                        link.url = getTeamDetailPageUrl(catalogid, brandid, sortid, row.id, Server.UrlEncode(keyword));
                    }
                    tuangou.area.Add(link);


                    areaf.type = "circle";
                    areaf.display = "Y";
                    if (row.type == "circle")
                    {
                        areaf.circle_id = row.circle_id;
                    }
                    else
                    {
                        areaf.circle_id = areaid;
                    }
                    using (IDataSession seion = Store.OpenSession(false))
                    {
                        circles = seion.Area.GetList(areaf);
                    }
                    if (circles != null)
                    {
                        tuangou.circle.Clear();
                        foreach (IArea circle in circles)
                        {
                            ALink circleslink = new ALink();
                            circleslink.Name = circle.areaname;
                            circleslink.number = TeamMethod.GetSumByArea(catalogid, keyword, brandid, cityid, circle.id);
                            circleslink.ID = circle.id;
                            if (areaid == circle.id)
                            {
                                circleslink.url = getTeamDetailPageUrl(catalogid, brandid, sortid, 0, Server.UrlEncode(keyword));
                            }
                            else
                            {
                                circleslink.url = getTeamDetailPageUrl(catalogid, brandid, sortid, circle.id, Server.UrlEncode(keyword));
                            }                            
                            tuangou.circle.Add(circleslink);


                        }
                    }
                }
            }
        }
        //大分类
        foreach (ICatalogs row in bigcatalogs)
        {
            ALink link = new ALink();
            link.Name = row.catalogname;
            link.number = row.number;
            link.ID = row.id;
            if (row.id == catalogid)
            {
                link.url = getTeamDetailPageUrl(0, 0, sortid, areaid, Server.UrlEncode(keyword));
            }
            else
                link.url = getTeamDetailPageUrl(row.id, 0, sortid, areaid, Server.UrlEncode(keyword));
            tuangou.dalei.Add(link);

            //查询关键字
            string sqlKey = " id=" + row.id + " or parent_id=" + row.id;
            GetKey(sqlKey);
            string guanjian = String.Empty;
            int count = 0;
            foreach (key guanjianzi in keylist)
            {
                count = count + 1;
                if (guanjianzi.keyname.Length > 0)
                {
                    if (count == 1)
                    {
                        guanjian = guanjianzi.keyname;
                    }
                    else
                    {
                        guanjian = guanjian + "," + guanjianzi.keyname;
                    }
                }
            }
            string[] keys = guanjian.Split(',');
            if (catalogrow == null || catalogrow.id == row.id || catalogrow.parent_id == row.id)
                for (int i = 0; i < keys.Length; i++)
                {
                    if (addkeyname.IndexOf("," + keys[i] + ",") < 0)
                    {
                        ALink keylink = new ALink();
                        keylink.Name = keys[i];
                        if (keyword == keys[i])
                        {
                            keylink.url = getTeamDetailPageUrl(catalogid, brandid, sortid, areaid, Server.UrlEncode(keyword));
                        }
                        else
                            keylink.url = getTeamDetailPageUrl(catalogid, brandid, sortid, areaid, Server.UrlEncode(keys[i]));
                        tuangou.keyword.Add(keylink);
                        addkeyname = addkeyname + "," + keys[i] + ",";
                    }
                }

        }
        if (brands != null && brands.Count > 0)
        {
            foreach (var item in brands)
            {
                ALink link = new ALink();
                if (item.Id == brandid)
                {
                    tuangou.title = item.Name + " " + tuangou.title;
                    link.url = getTeamDetailPageUrl(catalogid, 0, sortid, areaid, Server.UrlEncode(keyword));
                }
                else
                {
                    link.url = getTeamDetailPageUrl(catalogid, item.Id, sortid, areaid, Server.UrlEncode(keyword));
                }
                link.number = TeamMethod.GetSumByArea(catalogid, keyword, item.Id, cityid, areaid);
                link.Name = item.Name;
                link.ID = item.Id;
                tuangou.pinpai.Add(link);
            }
        }

        //小分类
        if (childcatalogs != null)
        {
            foreach (ICatalogs row in childcatalogs)
            {
                if (catalogrow != null)
                {
                    ALink link = new ALink();
                    if (catalogrow.id == row.id)
                    {
                        link.url = getTeamDetailPageUrl(0, 0, sortid, areaid, Server.UrlEncode(keyword));
                    }
                    else
                        link.url = getTeamDetailPageUrl(row.id, 0, sortid, areaid, Server.UrlEncode(keyword));

                    link.Name = row.catalogname;
                    link.number = row.number;
                    link.ID = row.id;
                    tuangou.xiaolei.Add(link);
                }
            }
        }
        //排序
        for (int i = 0; i < tuangou.sorts.Count; i++)
        {
            tuangou.sorts[i].url = getTeamDetailPageUrl(catalogid, brandid, tuangou.sorts[i].ID, areaid, Server.UrlEncode(keyword));
        }
        ////////////////////////
        catalogAll = getTeamDetailPageUrl(0, brandid, sortid, areaid, Server.UrlEncode(keyword));
        brandAll = getTeamDetailPageUrl(catalogid, 0, sortid, areaid, Server.UrlEncode(keyword));
        keywordAll = getTeamDetailPageUrl(catalogid, brandid, sortid, areaid, Server.UrlEncode(keyword));
        areaAll = getTeamDetailPageUrl(catalogid, brandid, sortid, 0, Server.UrlEncode(keyword));
        //////////////////////
        string sql = TeamMethod.GetTeamListByArea(catalogid, keyword, brandid, cityid, areaid);
        string pageurl = "?page={0}";
        if (Helper.GetString(keyword, String.Empty) != String.Empty)
        {
            pageurl = "&page={0}";
        }
        int page = Helper.GetInt(Request["page"], 1);
        string orderby = "sort_order desc,begin_time desc,id desc";
        if (sortid == 1)
        {
            orderby = "now_number desc";
        }
        else if (sortid == 2)
        {
            orderby = "team_price asc";
        }
        //**********************分页*****************************
        TeamFilter teamf = new TeamFilter();
        teamf.table = "(" + sql + ")t";
        teamf.PageSize = 15;
        teamf.CurrentPage = page;
        teamf.AddSortOrder(orderby);
        using (IDataSession seion = Store.OpenSession(false))
        {
            teampager = seion.Teams.GetDetailPager(teamf);
        }
        teamlist = teampager.Objects;
        pagerhtml = WebUtils.GetPagerHtml(15, teampager.TotalRecords, teampager.CurrentPage, getTeamDetailPageUrl(catalogid, brandid, sortid, areaid, Server.UrlEncode(keyword)) + pageurl);

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

    #region 显示子类下面的子类
    public void GetChildList(int id)
    {
        childlist = AS.GroupOn.Controls.Catalogs.GetCata("parent_id=" + id + "");
    }

    #endregion
    #region 记录父目录下面的子类得编号
    public string GetChildid(DataTable dt, int id)
    {

        DataView dv = new DataView(dt);
        dv.RowFilter = "type=0 and parent_id = " + id.ToString();
        child += id + ",";
        foreach (DataRowView dr in dv)
        {
            child += dr["id"] + ",";
            GetChildid(dt, Convert.ToInt32(dr["id"]));
        }
        return child;
    }
    #endregion


    #region
    public bool isover(ITeam model)
    {
        bool falg = false;
        state = GetState(model);
        if (state == AS.Enum.TeamState.fail || state == AS.Enum.TeamState.successtimeover || state == AS.Enum.TeamState.successnobuy)
        {
            falg = true;
            overtime = model.End_time;
        }
        return falg;
    }
    #endregion

    #region 显示大类
    public void GetCata()
    {
        catalist = AS.GroupOn.Controls.Catalogs.GettopCata(8);
    }
    #endregion

    #region 根据条件显示全部类别
    public void Getcatalist()
    {
        cataloglist = AS.GroupOn.Controls.Catalogs.GetCata("");
    }
    #endregion
    #region 显示所有父类
    public void Getfather()
    {
        int city = 0;
        if (CurrentCity != null)
        {
            city = CurrentCity.Id;
        }
        catafatherlist = AS.GroupOn.Controls.Catalogs.GettopCata(city);
    }
    #endregion
    #region 显示关键字
    public void GetKey(string key)
    {
        string city = "0";
        if (CurrentCity != null)
        {
            city = CurrentCity.Id.ToString();
        }
        keylist = TeamMethod.Getkey(key, city);
    }
    #endregion
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script language="javascript" type="text/javascript">
    function checksub_email() {
        var str = document.getElementById("sub_email").value;
        //对电子邮件的验证
        if (!str.match(/^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/)) {
            document.getElementById("sub_email").value = "";
            return false;
        }
        else {
            window.location.href = '<%=GetUrl("邮件订阅", "help_Email_Subscribe.aspx")%>' + '?email=' + str;
        }
    }
    function fnOver(thisId) {
        var thisClass = thisId.className;
        var overCssF = thisClass;
        if (thisClass.length > 0) { thisClass = thisClass + " " };
        thisId.className = thisClass + overCssF + "hover";
    }
    function fnOut(thisId) {
        var thisClass = thisId.className;
        var thisNon = (thisId.className.length - 5) / 2;
        thisId.className = thisClass.substring(0, thisNon);
    }
    function show(obj) {
        $(obj).children('.adre_widtd').css("display", "block");
    }
    function hide(obj) {
        $(obj).children('.adre_widtd').css("display", "none");
    }

</script>
<div id="bdw" class="bdw">
	<!--左悬浮菜单-->
	<%LoadUserControl(WebRoot + "UserControls/leftmenu.ascx", null); %>
    <div id="bd" class="cf">
        <div class="midad">
            <%LoadUserControl(WebRoot + "UserControls/admid.ascx", null); %>
        </div>
        <div class="tmore_box">
            <%if (tuangou.dalei.Count > 0)
              { %>
            <dl class="sq">
                <dt><a href="#">分类</a> </dt>
                <dd>
                    <%if (catalogid != 0)
                      {%>
                    <a href="<%=catalogAll %>">全部</a>
                    <%}
                      else
                      { %>
                    <a href="<%=catalogAll %>" class="this_fl">全部</a>
                    <%} %>
                    <%for (int i = 0; i < tuangou.dalei.Count; i++)
                      {%>
                    <%if (catalogid == tuangou.dalei[i].ID || tuangou.Parentid == tuangou.dalei[i].ID)
                      { %>
                    <a href="<%=tuangou.dalei[i].url %>" class="this_fl">
                        <%=tuangou.dalei[i].Name%>(<%=tuangou.dalei[i].number%>)</a>
                    <% }
                      else
                      {%>
                    <a href="<%=tuangou.dalei[i].url %>">
                        <%=tuangou.dalei[i].Name%>(<%=tuangou.dalei[i].number%>)</a>
                    <% }%>
                    <% }%>
                </dd>
                <% 
                    if (tuangou.xiaolei.Count > 0)
                    { %>
                <p class="clear">
                    <% 
                        for (int j = 0; j < tuangou.xiaolei.Count; j++)
                        {
                    %>
                    <%if (catalogid == tuangou.xiaolei[j].ID)
                      { %>
                    <a name="liujiay" href="<%=tuangou.xiaolei[j].url %>" class="this_fl">
                        <%=tuangou.xiaolei[j].Name%>(<%=tuangou.xiaolei[j].number%>)</a>
                    <% }
                      else
                      {%>
                    <a name="liujiay" href="<%=tuangou.xiaolei[j].url %>">
                        <%=tuangou.xiaolei[j].Name%>(<%=tuangou.xiaolei[j].number%>)</a>
                    <% }%>
                    <% 
                        }
                    %>
                </p>
                <%}%>
            </dl>
            <%} %>
            <%if (tuangou.keyword.Count > 0)
              { %>
            <dl class="sq">
                <dt><a href="#">关键字</a></dt>
                <dd>
                    <%if (keyword != "")
                      {%>
                    <a href="<%=getTeamDetailPageUrl(0,0,0,0,"")%>">全部</a>
                    <%}
                      else
                      { %>
                    <a href="<%=getTeamDetailPageUrl(0,0,0,0,"")%>" class="this_fl">全部</a>
                    <%} %>
                    <%for (int j = 0; j < tuangou.keyword.Count; j++)
                      { %>
                    <%if (keyword == tuangou.keyword[j].Name)
                      { %>
                    <%if (keyword == "")
                      { %><%}
                      else
                      { %>
                    <a href="<%=tuangou.keyword[j].url %>" class="this_fl">
                        <%=tuangou.keyword[j].Name%></a>
                    <%} %>
                    <% }
                      else
                      {%>
                    <a href="<%=tuangou.keyword[j].url %>">
                        <%=tuangou.keyword[j].Name%></a>
                    <% }%>
                    <% }%>
                </dd>
            </dl>
            <%} %>
            <%if (tuangou.pinpai.Count > 0)
              { %>
            <dl class="sq">
                <dt><a href="#">品牌</a></dt>
                <dd>
                    <%if (brandid != 0)
                      {%>
                    <a href="<%=brandAll %>">全部</a>
                    <%}
                      else
                      { %>
                    <a href="<%=brandAll %>" class="this_fl">全部</a>
                    <%} %>
                    <%for (int j = 0; j < tuangou.pinpai.Count; j++)
                      {
                    %>
                    <%if (brandid == tuangou.pinpai[j].ID)
                      { %>
                    <a href="<%=tuangou.pinpai[j].url %>" class="this_fl">
                        <%=tuangou.pinpai[j].Name%>(<%=tuangou.pinpai[j].number%>)</a>
                    <% }
                      else
                      {%>
                    <a href="<%=tuangou.pinpai[j].url %>">
                        <%=tuangou.pinpai[j].Name%>(<%=tuangou.pinpai[j].number%>)</a>
                    <% }%>
                    <% }%>
                </dd>
            </dl>
            <%} %>
            <%if (tuangou.area.Count > 0)
              { %>
            <dl class="sq">
                <dt><a href="#">区域</a></dt>
                <dd>
                    <%if (areaid != 0)
                      {%>
                    <a href="<%=areaAll %>">全部</a>
                    <%}
                      else
                      { %>
                    <a href="<%=areaAll %>" class="this_fl">全部</a>
                    <%} %>
                    <%for (int i = 0; i < tuangou.area.Count; i++)
                      {
                    %>
                    <%if (areaid == tuangou.area[i].ID)
                      { %>
                    <a href="<%=tuangou.area[i].url %>" class="this_fl">
                        <%=tuangou.area[i].Name%>(<%=tuangou.area[i].number%>)</a>
                    <% }
                      else
                      {%>
                    <a href="<%=tuangou.area[i].url %>">
                        <%=tuangou.area[i].Name%>(<%=tuangou.area[i].number%>)</a>
                    <% }%>
                    <% }%>
                </dd>
                <% 
                    if (tuangou.circle.Count > 0)
                    { %>
                <p class="clear">
                    <% 
                        for (int j = 0; j < tuangou.circle.Count; j++)
                        {
                    %>
                    <%if (shangquan == tuangou.circle[j].ID)
                      { %>
                    <a name="liujiay" href="<%=tuangou.circle[j].url %>" class="this_fl">
                        <%=tuangou.circle[j].Name%>(<%=tuangou.circle[j].number%>)</a>
                    <% }
                      else
                      {%>
                    <a name="liujiay" href="<%=tuangou.circle[j].url %>">
                        <%=tuangou.circle[j].Name%>(<%=tuangou.circle[j].number%>)</a>
                    <% }%>
                    <% 
                        }
                    %>
                </p>
                <%}%>
            </dl>
            <%} %>
            <dl class="sq_gjc">
                <dt><a href="#">排序</a></dt>
                <dd>
                    <%for (int i = 0; i < tuangou.sorts.Count; i++)
                      { %>
                    <%if (sortid == tuangou.sorts[i].ID)
                      { %>
                    <a href="<%=tuangou.sorts[i].url %>" class="this_fl">
                        <%=tuangou.sorts[i].Name%></a>
                    <% }
                      else
                      {%>
                    <a href="<%=tuangou.sorts[i].url %>">
                        <%=tuangou.sorts[i].Name%></a>
                    <% }%>
                    <%} %>
                </dd>
            </dl>
        </div>
        <div id="deal-default">
            <!--团购类别代码开始-->
            <div class="content_sy">
                <!--循环一日多团4-开始-->
                <div class="tuanmore_boxxq">
                    <!--分类下的项目显示-->
                    <%if (teamlist.Count > 0)
                      { %>
                    <% int i = 0; %>
                    <%foreach (ITeam teammodel in teamlist)
                      {

                          i++;
                    %>
                    <%if (i % 3 == 0)
                      {%>
                    <div class="tuanmore_listxq_r5" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                        <%}
                      else
                      { %>
                        <div class="tuanmore_listxq5" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                            <%} %>
                            <% %>
                            <%if (teammodel.Delivery == "draw")
                              { 
                                   
                            %>
                            <%--                                    <div class="list_cj">
                                    </div>--%>
                            <% }%>
                            <div class="lists_xq_img5 img_xq">
                                <a href="<%=getTeamPageUrl(teammodel.Id) %>" target="_blank" class="image_link">
                                    <img <%=ashelper.getimgsrc(teammodel.Image) %> class="dynload" width="298" height="190"
                                        alt="<%=teammodel.Title %>" title="<%=teammodel.Title %>" />
                                </a>
                            </div>
                            <h3>
                                <a class="js_dlst " href="<%=getTeamPageUrl(teammodel.Id)  %>" target="_blank">
                                    <%=teammodel.Product%></a></h3>
                            <!--2011.11.15 修改模板-->
                            <%  if (GetState(teammodel) == AS.Enum.TeamState.successnobuy)
                                {%>
                            <div class="price_info5 over">
                                <span class="price_now"><em>
                                    <%=ASSystem.currency%></em><%=teammodel.Team_price%></span> <a href="#" target="_blank"
                                        title="<%=teammodel.Product %>"></a>
                            </div>
                            <% }
                                else if (isover(teammodel))
                                {%>
                            <div class="price_info5 end">
                                <span class="price_now"><em>
                                    <%=ASSystem.currency%></em><%=teammodel.Team_price%></span> <a href="#" target="_blank"
                                        title="<%=teammodel.Product %>"></a>
                            </div>
                            <% }
                                else
                                {%>
                            <% if (teammodel.Delivery == "draw")
                               {%>
                            <div class="price_info5 chouj">
                                <span class="price_now"><em>
                                    <%=ASSystem.currency%></em><%=teammodel.Team_price%></span> <a href="<%=getTeamPageUrl(teammodel.Id) %>"
                                        target="_blank" title="<%=teammodel.Product %>"></a>
                            </div>
                            <% }
                               else
                               {%>
                            <div class="price_info5">
                                <span class="price_now"><em>
                                    <%=ASSystem.currency%></em><%=GetMoney(teammodel.Team_price)%></span> <span class="price_original">
                                        原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span> <a href="<%=getTeamPageUrl(teammodel.Id) %>"
                                            target="_blank" title="<%=teammodel.Product %>"></a>
                            </div>
                            <% }%>
                            <% }%>
                            <!--2011.11.15 修改模板结束-->
                            <div class="tuanft5">
                                <div class="goods_time">
                                   
                                     <% if ((teammodel.End_time - DateTime.Now).Days >= 3)
                                        { %>
                                          <span id="Span4" class="">3天以上</span>
                                     <%}
                                        else
                                        { %>
                                        <span id="Span1" class="num"> <%=(teammodel.End_time - DateTime.Now).Days%></span>天<span class="num" id="Span2"><%=(teammodel.End_time - DateTime.Now).Hours%></span>时<span
                                            class="num" id="Span3"><%=(teammodel.End_time - DateTime.Now).Minutes%></span>分
                                            <%} %>
                                </div>
                                <div class="goods_buyernumber">
                                    <span class="num">
                                        <%=teammodel.Now_number%></span>人购买
                                </div>
                                <%if (TeamMethod.isShop(teammodel))
                                  { 
                                %>
                                <a href="<%=PageValue.WebRoot%>ajax/car.aspx?id=<%=teammodel.Id %>"></a>
                                <% }
                                  else
                                  { 
                                %>
                                <div class="xq" onmouseover="show(this)" onmouseout="hide(this)">
                                    <%if (!TeamMethod.isShop(teammodel))
                                      {
                                    %>
                                    <div style="display: none;" class="adre_widtd">
                                        <%if (teammodel.Partner != null)
                                          {
                                              if (teammodel.Partner.Address != null)
                                              {
                                        %>
                                        <p>
                                            <strong>
                                                <%if (teammodel.Partner.area != null)
                                                  {%><%=teammodel.Partner.area%><% }
                                                  else
                                                  { %>地址<%} %></strong>：
                                            <%=teammodel.Partner.Address%>
                                        </p>
                                        <em></em>
                                        <%}
                                              else
                                              { 
                                        %>
                                        <p>
                                            <strong>
                                                <%if (teammodel.Partner.area != null)
                                                  {%><%=teammodel.Partner.area %><% }
                                                  else
                                                  { %>地址<%} %></strong>： 暂无地址
                                        </p>
                                        <em></em>
                                        <%
                                            }
                                          }
                                          else
                                          {     %><strong> 地址</strong>： 暂无地址 <em></em>
                                        <%} %>
                                    </div>
                                    <%
                                        }%>
                                </div>
                                <%
                                    }%>
                            </div>
                        </div>
                        <% }%>
                        <% }
                      else
                      {%>
                        <div style="font-size: 14px; text-align: center; color: #666666;">
                            当前条件下没有找到合适的团购信息，您可以更换条件试试。
                        </div>
                        <% }%>
                        <!--分类下的项目结束-->
                        <div class="clear">
                        </div>
                        <div>
                            <%=pagerhtml%>
                        </div>
                    </div>
                </div>
            </div>
            <!--循环一日多团4-结束-->
            <!--团购类别代码结束-->
        </div>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>