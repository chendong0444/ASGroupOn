<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected IList<ITeam> list_team = null;
    protected TeamFilter filter = new TeamFilter();
    protected IPagers<ITeam> pager = null;
    protected string url = "";
    protected string pagerhtml = "";
    protected ICatalogs catalog = null;
    protected int catalogid = 0;
    protected int s = 0;
    protected string cataname = "全部分类";
    public int page = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        CookieUtils.SetCookie("pcversion", "0");    //设为触屏版

        if (PageValue.CurrentCity != null)
        {
            CookieUtils.SetCookie("cityid", PageValue.CurrentCity.Id.ToString(), DateTime.Now.AddYears(1));
        }
        else
        {
            CookieUtils.SetCookie("cityid", "0", DateTime.Now.AddYears(1));
        }
        PageValue.WapBodyID = "index";
        PageValue.Title = PageValue.CurrentSystem.abbreviation + "触屏版";
        if (Request["cataid"] != "" && Request["cataid"] != null)
        {
            catalogid = Helper.GetInt(Request["cataid"], 0);
        }
        if (catalogid > 0)
        {
            using (IDataSession session = Store.OpenSession(false))
            {
                catalog = session.Catalogs.GetByID(catalogid);
            }
        }
        if (catalog != null)
        {
            string str = "";
            cataname = catalog.catalogname;
            WebUtils systemmodel = new WebUtils();
            NameValueCollection values = new NameValueCollection();
            values = WebUtils.GetSystem();
            if (values["zuijin"] == null)
            {
                values.Add("zuijin", catalogid.ToString());
            }
            else if (!values["zuijin"].ToString().Contains(catalogid.ToString()))
            {
                s = 1;
                values.Add("zuijin", catalogid.ToString());
            }
            else
            {
                s = 0;
            }
            systemmodel.CreateSystemByNameCollection(values);
            string[] zuijin = values["zuijin"].ToString().Split(',');
            if (zuijin.Length >= 9)
            {
                values.Remove("zuijin");
                for (int i = s; i < s + 9; i++)
                {
                    values.Add("zuijin", zuijin[i]);
                }
                systemmodel.CreateSystemByNameCollection(values);
            }
            for (int i = 0; i < values.Count; i++)
            {
                string strKey = values.Keys[i];
                string strValue = values[strKey];
                FileUtils.SetConfig(strKey, strValue);
            }

        }
        InitData(catalogid);
    }
    private void InitData(int catalogid)
    {
        ICatalogs catalogs = null;
        CatalogsFilter cataft = new CatalogsFilter();
        IList<ICatalogs> catalis = null;
        string catids = String.Empty;
        if (catalogid > 0)
        {
            using (IDataSession session = Store.OpenSession(false))
            {
                catalogs = session.Catalogs.GetByID(catalogid);
            }
            if (catalogs.parent_id == 0)
            {
                cataft.parent_id = catalogid;
                using (IDataSession session = Store.OpenSession(false))
                {
                    catalis = session.Catalogs.GetList(cataft);
                }
                if (catalis != null && catalis.Count > 0)
                {
                    foreach (ICatalogs item in catalis)
                    {
                        catids = catids + item.id + ",";
                    }
                    filter.CataIDin = catids.Trim(',');
                }
                else
                {
                    filter.CataIDin = catalogid.ToString();
                }
            }
            else
            {
                filter.CataIDin = catalogid.ToString();
            }
        }
        if (ASSystem != null)
        {
            if (CurrentCity != null)
                filter.CityID = Helper.GetInt(CurrentCity.Id, 0);
            page = Helper.GetInt(Request["page"], 1);
            filter.teamcata = 0;
            filter.ToBegin_time = DateTime.Now;
            filter.FromEndTime = DateTime.Now;
            filter.TypeIn = "'normal','draw','goods','seconds'";
            filter.Cityblockothers = Helper.GetInt(CurrentCity.Id, 0);
            filter.PageSize = 30;
            filter.CurrentPage = page;
            filter.AddSortOrder(TeamFilter.Sort_Order_DESC);
            filter.AddSortOrder(TeamFilter.Begin_time_DESC);
            filter.AddSortOrder(TeamFilter.ID_DESC);
            using (IDataSession session = Store.OpenSession(false))
            {
                pager = session.Teams.GetPager(filter);
            }
            list_team = pager.Objects;
            url = GetUrl("手机版首页", "index.aspx?page={0}");
            pagerhtml = WebUtils.GetMBPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);

        }
    }
    private string GetTeamType(ITeam teammodel)
    {
        string str = String.Empty;
        if (teammodel != null)
        {
            if (teammodel.teamhost == 1)
            {
                str = "<span class=\"mark new\"><i></i>新单</span>";
            }
            else if (teammodel.teamhost == 2)
            {
                str = "<span class=\"mark new\"><i></i>热销</span>";
            }
        }
        return str;
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<body id='index'>
    <div class="current-category">
        您当前的分类：<%=cataname%></div>
    <div id="deals">
        <%if (list_team != null && list_team.Count > 0)
          {%>
        <% foreach (var item in list_team)
           {%>
        <div>
            <a href="<%=GetMobilePageUrl(item.Id) %>"><%=GetTeamType(item) %>
            <img data-src="<%=PageValue.CurrentSystem.domain+WebRoot %><%=item.PhoneImg==null?String.Empty:item.PhoneImg%>" width="122" height="74" alt="<%=item.Product %>"/>
                <detail>
                    <ul>
                        <li class="brand"><%=item.Product %></li>
                        <li class="title indent"><%=item.Title %></li>
 <li class="price"><strong><%=GetMoney(item.Team_price)%></strong>元<del><%=GetMoney(item.Market_price)%>元</del><span><%=item.Now_number%>人</span></li>
                    </ul>
                </detail>
            </a>
        </div>
        <%}%>
        <%}
          else
          {%>
        <div class="isEmpty">
            抱歉，<%=cataname%>分类下暂时没有项目！敬请稍后关注</div>
        <%}%>
    </div>
    <nav class="pageinator">
    <div id="nav-page">
        <%--<%if (AS.Common.Utils.Helper.GetInt(Request["page"], 1) != 1)
          {%>
             <a  class="nav-button" href="javascript:history.back()">上一页</a>   
          <%} %>
        <%if (list_team!=null&&list_team.Count >= 30)
          {%>
             <a class="nav-button" href="<%=url %>">下一页</a>   
          <%}%>--%>
          <%=pagerhtml%>
    </div>
    <div id="nav-top">
        <span class="nav-button" onclick="javascript:void(window.scrollTo(0, 0));"><span>回到顶部</span></span>
    </div>
</nav>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>