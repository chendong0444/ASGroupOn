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
    protected IList<ICity> citylist = null;
    protected IList<ICategory> zonelist = null;
    protected IList<ICategory> letters = null;
    protected IList<ICategory> catelists = null;
    protected IList<ICategory> otherlist = null;
    protected int citypid = 0;
    protected CityFilter allfilter = new CityFilter();
    protected CategoryFilter zonefilter = new CategoryFilter();
    protected CategoryFilter cityfilter = new CategoryFilter();
    protected CategoryFilter letterscf = new CategoryFilter();
    protected CategoryFilter othercf = new CategoryFilter();
    protected CityFilter city = new CityFilter();
    protected StringBuilder cityshtml = new StringBuilder();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "选择城市";
        othercf.Display = "Y";
        othercf.Czone = "0";
        othercf.Zone = "city";
        othercf.AddSortOrder(CategoryFilter.Sort_Order_DESC);
        allfilter.Display = "Y";
        allfilter.City_pid = 0;
        allfilter.AddSortOrder(CategoryFilter.Sort_Order_DESC);
        zonefilter.Zone = "citygroup";
        zonefilter.Display = "Y";
        zonefilter.AddSortOrder(CategoryFilter.Sort_Order_DESC);
        letterscf.Display = "Y";
        letterscf.Zone = "city";
        letterscf.AddSortOrder(CategoryFilter.Letter_ASC);
        using (IDataSession session = Store.OpenSession(false))
        {
            letters = session.Category.GetletterList(letterscf);
            zonelist = session.Category.GetList(zonefilter);
            otherlist = session.Category.GetList(othercf);
        }
        if (zonelist != null)
        {
            for (int i = 0; i < zonelist.Count; i++)
            {
                ICategory cate = zonelist[i];
                cityshtml.Append("<div id=\"" + cate.Id + "\" class=\"category-box show-cate\" onclick=\"clicks(" + cate.Id + ")\">");
                cityshtml.Append("<div class=\"category-btn\">");
                cityshtml.Append("<h1>" + cate.Name + "</h1><span class=\"arrow\"><span class=\"bg\"></span></span>");
                cityshtml.Append("</div>");
                cityshtml.Append("<ul>");
                if (cate.Czone.ToString() != "0")
                {
                    cityfilter.Display = "Y";
                    cityfilter.Zone = WebUtils.GetCatalogName(CatalogType.city).ToString();
                    cityfilter.Czone = cate.Id.ToString();
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        catelists = session.Category.GetList(cityfilter);
                    }
                }
                if (catelists != null)
                {
                    for (int j = 0; j < catelists.Count; j++)
                    {
                        ICategory c = catelists[j];
                        if (c.Display.ToUpper() == "Y")
                        {
                            cityshtml.Append("<li><a href=" + PageValue.WebRoot + "wap/" + c.Ename + "/" + " class='city'>" + c.Name + "</a></li>");
                        }
                    }
                }
                cityshtml.Append("</ul>");
                cityshtml.Append("</div>");
            }
        }
        if (otherlist != null && otherlist.Count > 0)
        {
            cityshtml.Append("<div id=\"moren\" class=\"category-box show-cate\" onclick=\"clicks('moren')\">");
            cityshtml.Append("<div class=\"category-btn\">");
            cityshtml.Append("<h1>默认城市</h1><span class=\"arrow\"><span class=\"bg\"></span></span>");
            cityshtml.Append("</div>");
            cityshtml.Append("<ul>");
            for (int k = 0; k < otherlist.Count; k++)
            {
                ICategory c = otherlist[k];
                if (c.Display.ToUpper() == "Y")
                {
                    cityshtml.Append("<li><a href=" + PageValue.WebRoot +"wap/"+ c.Ename + "/" + " class='city'>" + c.Name + "</a></li>");
                }
            }
            cityshtml.Append("<li><a href=" + PageValue.WebRoot + "wap/quanguo" + "/" + " class='city'>全国</a></li>");
            cityshtml.Append("</ul>");
            cityshtml.Append("</div>");
        }
    }
    private IList<ICity> GetCitysByLetter(string str)
    {
        if (String.IsNullOrEmpty(str)) return null;
        IList<ICity> clist = null;
        CityFilter c = new CityFilter();
        c.Letter = str;
        c.Display = "Y";
        c.AddSortOrder(CityFilter.Sort_Order_DESC);
        using (IDataSession session = Store.OpenSession(false))
        {
            clist = session.Citys.GetList(c);
        }
        return clist;
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<body id='changecity'>
    <header>
        <div class="left-box">
            <a class="go-back" href="javascript:history.back()"><span>返回</span></a>
        </div>
        <h1>选择城市</h1>
    </header>
    <div id="cityBox">
        <%=cityshtml %>
        <%for (int i = 0; i < letters.Count; i++)
          { %>
        <div id="letter<%=i %>" class="category-box " onclick="clicks('letter<%=i %>')">
            <div class="category-btn  ">
                <h1>
                    <%=letters[i].Letter%>
                </h1>
                <span class="arrow"><span class="bg"></span></span>
            </div>
            <ul>
                <%IList<ICity> citys = GetCitysByLetter(letters[i].Letter); %>
                <%if (citys != null && citys.Count > 0)
                  {%>
                <%foreach (ICity city in citys)
                  { %>
                <li><a href="<%=PageValue.WebRoot %>wap/<%=city.Ename %>/">
                    <%=city.Name%></a></li>
                <%}%>
                <%}%>
            </ul>
        </div>
        <%} %>
    </div>
    <%LoadUserControl("_footer.ascx", null); %>
    <script type="text/javascript">
        function clicks(tagid) {
            var str = document.getElementById(tagid).className; if (str == 'category-box show-cate') {
                str = 'category-box';
                document.getElementById(tagid).className = str;
            } else { document.getElementById(tagid).className = 'category-box show-cate'; }
        }
    </script>
    <%LoadUserControl("_htmlfooter.ascx", null); %>
