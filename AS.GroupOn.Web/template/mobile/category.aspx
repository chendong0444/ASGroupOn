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
    public string cityname = string.Empty;
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
        public List<ALink> dalei = new List<ALink>();
        public List<ALink> xiaolei = new List<ALink>();
        public int Parentid = 0;
        public int dangqianid = 0;
        public string sql = String.Empty;
        public string title = String.Empty;
    }
    public int cityid = 0;
    protected int catalogid = 0;
    protected TuanGouing tuangou = new TuanGouing();
    public IList<ICatalogs> catalist = null;
    public int count = 0;
    public string[] zuijin = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "选择分类";
        if (PageValue.CurrentCity != null)
        {
            cityid = PageValue.CurrentCity.Id;
            cityname = PageValue.CurrentCity.Name;
        }
        NameValueCollection values = new NameValueCollection();
        values = WebUtils.GetSystem();
        if (values["zuijin"] != null && values["zuijin"] != "")
        {
            zuijin = values["zuijin"].ToString().Split(',');
        }
        IList<ICatalogs> bigcatalogs = null;
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
        if (bigcatalogs != null && bigcatalogs.Count > 0)
        {
            foreach (ICatalogs row in bigcatalogs)
            {
                row.SetValue("number", (object)(TeamMethod.GetSumByArea(row.id, String.Empty, 0, cityid, 0)));
            }
        }
        //大分类
        foreach (ICatalogs row in bigcatalogs)
        {
            ALink link = new ALink();
            link.Name = row.catalogname;
            link.number = row.number;
            link.ID = row.id;
            tuangou.dalei.Add(link);
        }
        CatalogsFilter cataft = new CatalogsFilter();
        cataft.type = 0;
        cataft.cityidLikeOr = cityid;
        cataft.visibility = 0;
        cataft.AddSortOrder(CatalogsFilter.MoreSort_DESC_ASC);
        using (IDataSession session = Store.OpenSession(false))
        {
            catalist = session.Catalogs.GetList(cataft);
        }
        TeamFilter teamft = new TeamFilter();
        teamft.teamcata = 0;
        teamft.ToBegin_time = DateTime.Now;
        teamft.FromEndTime = DateTime.Now;
        using (IDataSession session = Store.OpenSession(false))
        {
            count = session.Teams.GetCount(teamft);
        }
    }
    protected ICatalogs getcata(string cataid)
    {
        ICatalogs catalog = null;
        int id = Helper.GetInt(cataid, 0);
        if (id > 0)
        {
            using (IDataSession session = Store.OpenSession(false))
            {
                catalog = session.Catalogs.GetByID(id);
            }

        }
        return catalog;
    }
    protected string getcataname(string id)
    {
        ICatalogs cate = null;
        string str = "";
        int cateid = Helper.GetInt(id, 0);
        using (IDataSession session = Store.OpenSession(false))
        {
            cate = session.Catalogs.GetByID(cateid);
        }
        if (cate != null)
        {
            str = cate.catalogname;
        }
        return str;
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<body id='index'>
    <header class="cf">
        <h1 id="logo">
            <a  href="<%=GetUrl("手机版首页","index.aspx") %>"><span><%=PageValue.CurrentSystem.sitename%></span></a>
        </h1>
        <a  class="city" href="<%=GetUrl("手机版城市","city.aspx") %>"><%=cityname %></a>
        <div id="nav">
            <a class="account"  href="<%=GetUrl("手机版个人中心","account_index.aspx") %>">我的<%=PageValue.CurrentSystem.sitename%></a>
            <a class="category"  href="<%=GetUrl("手机版分类","category.aspx") %>">分类</a>
            <a class="search"  href="<%=GetUrl("手机版搜索","search.aspx") %>">搜索</a>
        </div>
    </header>
    <div id="category">
        <%string strs = "";
          if (zuijin != null && zuijin.Length > 0)
          { %>
        <div id="recently-category" class="category-box" style="transform-origin: 0px 0px 0px;
            opacity: 1; transform: scale(1, 1);" onclick="clicks('recently-category')">
            <div class="category-btn">
                <h1>
                    最近查看</h1>
                <label class="arrow">
                    <span class="bg"></span>
                </label>
            </div>
            <ul>
                <%for (int i = 0; i < zuijin.Length; i++)
                  {%>
                <li><a href="<%=GetUrl("手机版首页","index.aspx?cataid="+Helper.GetInt(zuijin[i],0))%>">
                    <%=getcataname(zuijin[i].ToString())%></a> </li>
                <%} %>
            </ul>
        </div>
        <% } %>
        <div class="category-box ">
            <div class="category-btn link">
                <h1>
                    <a href="<%=GetUrl("手机版首页","index.aspx") %>">全部分类<span class="count">(<%=TeamMethod.GetSumByArea(0, null, 0, cityid, 0)%>)</span></a></h1>
                <label>
                    <span class="bg"></span>
                </label>
            </div>
        </div>
        <%string str = "";
          for (int i = 0; i < tuangou.dalei.Count; i++)
          {
        %>
        <section id="categorys<%=i %>" class="category-box" onclick="clicks('categorys<%=i %>')">
        <div class="category-btn" data-name="<%=tuangou.dalei[i].Name%>">
        <h1><%=tuangou.dalei[i].Name%><span class="count"></span></h1>
            <label class="arrow"><span class="bg"></span></label> 
         </div> 
         <ul>
         <li><a href="<%=GetUrl("手机版首页","index.aspx?cataid="+tuangou.dalei[i].ID)%>"><%=tuangou.dalei[i].Name%><span class="count">(<%=tuangou.dalei[i].number%>)</span></a></li>
         <%foreach (ICatalogs item in catalist)
           {
               if (item.parent_id == tuangou.dalei[i].ID)
               { %>
                     <li><a href="<%=GetUrl("手机版首页","index.aspx?cataid="+item.id)%>" ><%=item.catalogname%>(<%=TeamMethod.GetSumByArea(item.id, null, 0, cityid, 0)%>)</a></li>
                 <%}
           }
           %>
           </ul>
       </section>
        <% }%>
    </div>
    <script type="text/javascript">
        function clicks(tagid) {
            var str = document.getElementById(tagid).className; if (str == 'category-box show-cate') {
                str = 'category-box';
                document.getElementById(tagid).className = str;
            } else { document.getElementById(tagid).className = 'category-box show-cate'; }
        }
    </script>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>