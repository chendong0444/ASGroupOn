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
<script runat="server">
    public IList<ICity> citylist = null;
    public IList<ICategory> zonelist = null;
    public IList<ICategory> letters = null;
    public IList<ICategory> catelists = null;
    public IList<ICategory> otherlist = null;
    protected StringBuilder cityshtml = new StringBuilder();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        CityFilter allfilter = new CityFilter();
        CategoryFilter zonefilter = new CategoryFilter();
        CategoryFilter cityfilter = new CategoryFilter();
        CategoryFilter letterscf = new CategoryFilter();
        CategoryFilter othercf = new CategoryFilter();
        CityFilter city = new CityFilter();
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
            citylist = session.Citys.GetList(allfilter);
            otherlist = session.Category.GetList(othercf);
        }
        cityshtml.Append("<div class=\"other-city\">");
        if (zonelist != null)
        {
            for (int i = 0; i < zonelist.Count; i++)
            {
                ICategory cate = zonelist[i];
                cityshtml.Append("<dl class=\"hot_city\"><dt><em>" + cate.Name + "</em></dt><dd>");
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
                            cityshtml.Append("<a title=\"" + c.Name + "团购\" href=\"" + GetUrl("城市列表", "city.aspx?ename=" + c.Ename + "") + "\" >" + c.Name + "</a>");
                        }
                    }
                }
                cityshtml.Append("</dd></dl>");
            }
        }
        cityshtml.Append("<dl class=\"hot_city\"><dt><em>默认城市</em></dt><dd>");
        if (otherlist != null)
        {
            for (int k = 0; k < otherlist.Count; k++)
            {
                ICategory c = otherlist[k];
                if (c.Display.ToUpper() == "Y")
                {
                    cityshtml.Append("<a title=\"" + c.Name + "团购\" href=\"" + GetUrl("城市列表", "city.aspx?ename=" + c.Ename) + "\" >" + c.Name + "</a>");
                }
            }
        }
        cityshtml.Append("<a title=\"全部城市团购\" href=\"" + GetUrl("城市列表", "city.aspx?ename=quanguo") + "\" >全部城市</a></dd></dl>");
        
        if (citylist != null && citylist.Count > 0)
        {
            for (int i = 0; i < citylist.Count; i++)
            {
                IList<ICategory> citylists = null;
                CategoryFilter ctfilter = new CategoryFilter();
                ctfilter.City_pid = citylist[i].Id;
                ctfilter.Display = "Y";
                ctfilter.AddSortOrder(CategoryFilter.Sort_Order_DESC);
                using (IDataSession session = Store.OpenSession(false))
                {
                    citylists = session.Category.GetList(ctfilter);
                }
                if (citylists != null && citylists.Count > 0)
                {
                    cityshtml.Append("<dl class=\"hot_city\">");
                    cityshtml.Append("<dt><em>" + citylist[i].Name.ToString() + "</em></dt><dd>");
                    for (int j = 0; j < citylists.Count; j++)
                    {
                        if (citylists[j].Display.ToString().ToUpper() == "Y")
                        {
                            cityshtml.Append("<a title=\"" + citylists[j].Name + "团购\" href=\"" + GetUrl("城市列表", "city.aspx?ename=" + citylists[j].Ename) + "\" >" + citylists[j].Name + "</a>");
                        }
                    }
                }
                cityshtml.Append("</dd></dl>");
            }
        }
        cityshtml.Append("</div>");

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
<%LoadUserControl(PageValue.TemplatePath + "_htmlheader.ascx", null); %>
<%LoadUserControl(PageValue.TemplatePath + "_header.ascx", null); %>
<script type="text/javascript">
    function GetCity() {
        var province = $("#province").find("option:selected").val();
        if (province == -1) {
            $("#citys").empty();
            $("#citys").append("<option value='-1'>--城市--</option>");
            return;
        }
        $.ajax({
            type: "POST",
            url: "<%=WebRoot%>ajax/ajax_getcity.aspx",
            data: { "province": province },
            success: function (msg) {
                var cityarr = msg.split(",");
                $("#citys").empty();
                for (var i = 0; i < cityarr.length; i++) {
                    var onecity = cityarr[i].split("|");
                    $("#citys").append("<option value='" + onecity[0] + "'>" + onecity[1] + "</option>");
                }
            }
        });
    }
    function citybtn() {
        var province = $("#province").find("option:selected").val();
        if (province == "-1") {
            alert("请选择省份"); return;
        }
        var cityname = $("#citys").find("option:selected").val();
        if (cityname != "-1") {
            window.location.href = "<%=WebRoot%>city.aspx?ename=" + cityname;
        } else {
            alert("请选择城市");
        }
    }
    window.onload = GetCity;
</script>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="choosecities">
            <div class="hotcities">
                <%if (CurrentCity != null)
                  { %>
                <h2>进入<a href="<%=WebRoot%>index.aspx"><%=CurrentCity.Name%>站<span>»</span></a></h2>
                <%} %>
            </div>
            <div class="province_choose">
                <label>
                    请选择省份：</label>
                <span style="float: left;">
                    <select id="province" onchange="GetCity()">
                        <option value="-1">--省份--</option>
                        <%foreach (var item in citylist)
                          {%>
                        <option <%if (CurrentCity.Name == item.Name)
                                  {%>selected="selected" <%} %> value="<%=item.Name%>">
                            <%=item.Name%></option>
                        <%} %>
                    </select></span> <span style="float: left;">
                        <select id="citys">
                            <option value="-1">--城市--</option>
                        </select>&nbsp;</span><input type="button" name="btn" id="btn" onclick="citybtn()"
                            value="确定" />
            </div>
            <div class="city-content">
                <div class="sect">
                    <%=cityshtml%>
                    <div class="pinyin">
                        <dl>
                            <dt>
                                <h2>按拼音选择城市</h2>
                            </dt>
                            <dd>
                                <%for (int i = 0; i < letters.Count; i++)
                                  {%>
                                <a href="#<%=letters[i].Letter%>">
                                    <%=letters[i].Letter%></a>
                                <%} %>
                            </dd>
                        </dl>
                        <%
                            for (int i = 0; i < letters.Count; i++)
                            { %>
                        <div id="<%=letters[i].Letter%>" name="<%=letters[i].Letter%>" class="row" onmouseout="fnOut(this)"
                            onmouseover="fnOver(this)">
                            <div>
                                <%=letters[i].Letter%>
                            </div>
                            <ul>
                                <%IList<ICity> citys = GetCitysByLetter(letters[i].Letter); %>
                                <%if (citys != null && citys.Count > 0)
                                  {%>
                                <%foreach (ICity city in citys)
                                  { %>
                                <li><a href="<%=WebRoot%>city.aspx?ename=<%=city.Ename %>&r=<%=GetRefer() %>">
                                    <%=city.Name%></a></li>
                                <%}%>
                                <%}%>
                            </ul>
                        </div>
                        <%} %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
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
</script>
<%LoadUserControl(PageValue.TemplatePath + "_footer.ascx", null); %>
<%LoadUserControl(PageValue.TemplatePath + "_htmlfooter.ascx", null); %> 
