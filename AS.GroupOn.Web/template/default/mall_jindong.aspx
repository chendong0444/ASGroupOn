<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected string headlogo = String.Empty;
    protected string curcityid = String.Empty;
    protected bool trsimple = false; //开启繁简转换
    protected string couponname = String.Empty;//优惠券名称
    protected string abbreviation = String.Empty;//网站简称
    protected bool opensmssubscribe = false; //是否开启短信订阅
    protected string url = String.Empty;
    protected string menuhtml = String.Empty;
    protected bool isPacket = false;
    protected IList<IGuid> iListGuid = null;
    protected IUser iuser = null;
    protected IList<IPacket> iListPacket = null;
    protected IList<ICatalogs> headcatas = null;//中间商品项目父分类
    protected IList<ICatalogs> headcataslist = null;//中间商品项目父分类
    protected IList<ILocation> iListLocation = null;
    protected IList<ILocation> iListLocationsider = null;//侧栏广告
    public NameValueCollection _system = new NameValueCollection();
    protected string footlogo = String.Empty;
    protected IList<IFriendLink> piclinks = null;
    protected FriendLinkFilter picfilter = new FriendLinkFilter();
    protected IList<IFriendLink> textlinks = null;
    protected FriendLinkFilter textfilter = new FriendLinkFilter();
    protected string sitename = String.Empty;
    protected string icp = String.Empty;
    protected string statcode = String.Empty;
    protected bool closeLocation = false;
    protected IList<INews> iListNews = null;
    protected StringBuilder sb = new StringBuilder();
    protected StringBuilder sb1 = new StringBuilder();
    List<Car> carlist = new List<Car>();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        GetGuid();
        carlist = CookieCar.GetCarData();
        //提取用户的相关信息
        if (AsUser.Id != 0)
        {
            PacketFilter packetfilter = new PacketFilter();
            packetfilter.State = "0";
            packetfilter.User_id = AsUser.Id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iListPacket = session.Packet.GetList(packetfilter);
            }
            if (iListPacket != null && iListPacket.Count > 0)
            {
                isPacket = true;
            }
        }
        if (CurrentCity != null)
        {
            curcityid = CurrentCity.Id.ToString();
        }
        if (ASSystem != null)
        {
            if (ASSystem.trsimple > 0) trsimple = true;
            couponname = ASSystem.couponname;
            abbreviation = ASSystem.abbreviation;

            if (PageValue.CurrentSystemConfig["mallheadlogo"] != null && PageValue.CurrentSystemConfig["mallheadlogo"].ToString() != "")
            {
                headlogo = PageValue.CurrentSystemConfig["mallheadlogo"];
            }
            else
            {
                headlogo = "/upfile/img/mall_logo.png";
            }
            opensmssubscribe = Convert.ToBoolean(ASSystem.smssubscribe);
        }
        _system = WebUtils.GetSystem();
        if (ASSystem != null)
        {
            abbreviation = ASSystem.abbreviation;
            if (PageValue.CurrentSystemConfig["mallfootlogo"] != null && PageValue.CurrentSystemConfig["mallfootlogo"].ToString() != "")
            {
                footlogo = _system["mallfootlogo"];
            }
            else
            {
                footlogo = ASSystem.footlogo;
            }
            sitename = ASSystem.sitename;
            icp = ASSystem.icp;
            statcode = ASSystem.statcode;
        }
        headcatas = GethostCataMall(1);//顶部分类
        headcataslist = GethostCataMall(2);//列表分类
        getNews();//加载新闻
        InitSide();
        InitTeam();

    }
    protected IList<ITeam> GetNew()
    {
        IList<ITeam> iListTeam = null;
        TeamFilter tf = new TeamFilter();
        tf.teamcata = 1;
        tf.mallstatus = 1;
        tf.teamhost = 1;
        tf.Top = 5;
        tf.AddSortOrder(TeamFilter.MoreSort);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListTeam = session.Teams.GetList(tf);
        }
        return iListTeam;
    }
    protected void getNews()
    {
        NewsFilter newsfilter = new NewsFilter();
        newsfilter.type = 1;
        newsfilter.Top = 8;
        newsfilter.AddSortOrder(NewsFilter.CreateTime_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListNews = session.News.GetList(newsfilter);
        }
    }
    protected IList<ILocation> getAdd(int top, int type)
    {
        IList<ILocation> listLocation = null;
        LocationFilter locationfilter = new LocationFilter();
        locationfilter.visibility = 1;
        locationfilter.height = "1";
        locationfilter.To_Begintime = DateTime.Now;
        locationfilter.From_Endtime = DateTime.Now;
        locationfilter.AddSortOrder(LocationFilter.ID_DESC);
        locationfilter.Location = type;
        if (top > 0)
        {
            locationfilter.Top = top;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listLocation = session.Location.GetList(locationfilter);
        }
        return listLocation;
    }
    /// <summary>
    /// 显示主推大类：商城
    /// </summary>
    protected IList<ICatalogs> GethostCataMall(int location)
    {
        IList<ICatalogs> iListCatalogs = null;
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        catalogsfilter.type = 1;
        catalogsfilter.parent_id = 0;
        catalogsfilter.visibility = 0;
        catalogsfilter.catahost = 0;
        catalogsfilter.LocationOr = location;
        catalogsfilter.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCatalogs = session.Catalogs.GetList(catalogsfilter);
        }
        return iListCatalogs;
    }

    /// <summary>
    /// 根据条件top二级大类：商城
    /// </summary>
    /// <param name="where"></param>
    /// <returns></returns>
    protected IList<ICatalogs> GetCataMall(string where, int top)
    {

        IList<ICatalogs> iListCatalogsTwo = null;
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        catalogsfilter.type = 1;
        catalogsfilter.parent_idNotZero = 0;
        catalogsfilter.visibility = 0;
        if (top != 0)
        {
            catalogsfilter.Top = top;
        }
        if (where != "")
        {
            catalogsfilter.parent_id = Helper.GetInt(where, 0);
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCatalogsTwo = session.Catalogs.GetList(catalogsfilter);

        }
        return iListCatalogsTwo;
    }
    protected IList<ICatalogs> GetCataSamall(int partid, int top)
    {
        IList<ICatalogs> iListCatalogsTwo = null;
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        catalogsfilter.type = 1;
        catalogsfilter.visibility = 0;
        if (top != 0)
        {
            catalogsfilter.Top = top;
        }
        if (partid != 0)
        {
            catalogsfilter.parent_id = partid;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCatalogsTwo = session.Catalogs.GetList(catalogsfilter);

        }
        return iListCatalogsTwo;
    }
    /// <summary>
    /// 显示导航栏目
    /// </summary>
    public void GetGuid()
    {
        GuidFilter guidfilter = new GuidFilter();
        guidfilter.teamormall = 1;
        guidfilter.AddSortOrder(GuidFilter.guidsort_desc);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListGuid = session.Guid.GetList(guidfilter);
        }
    }
    /// <summary>
    /// 根据分类得到商城项目
    /// </summary>
    /// <param name="cataid"></param>
    protected IList<ITeam> getMallTeamByCataid(int cataid)
    {
        IList<ITeam> iListTeam = null;
        TeamFilter teamfilter = new TeamFilter();
        teamfilter.teamcata = 1;
        teamfilter.mallstatus = 1;
        teamfilter.Top = 10;
        teamfilter.AddSortOrder(TeamFilter.MoreSort);
        if (cataid != 0)
        {
            teamfilter.CataID = cataid;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListTeam = session.Teams.GetList(teamfilter);
        }
        return iListTeam;
    }
    /// <summary>
    /// 根据父类得到子分类
    /// </summary>
    /// <param name="cateid"></param>
    /// <returns></returns>
    private string getChildCataidByCateid(int cateid)
    {
        ICatalogs icatalogs = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            icatalogs = session.Catalogs.GetByID(cateid);
        }
        string cid = "";
        if (icatalogs != null)
        {
            if (Helper.GetString(icatalogs.ids, "") != "")
                cid = icatalogs.ids + "," + cateid;
            else
                cid = cateid.ToString();
        }
        return cid;
    }
    private IList<ICategory> GetBrandlist(int cataid)
    {
        List<ICategory> catalist = new List<ICategory>();
        string cid = getChildCataidByCateid(cataid);
        IList<ITeam> listTeam = null;
        TeamFilter teamfilter = new TeamFilter();
        teamfilter.teamcata = 1;
        teamfilter.mallstatus = 1;
        teamfilter.BrandIDNotZero = 0;
        teamfilter.CataIDin = cid;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listTeam = session.Teams.GetBrandId(teamfilter);
        }
        if (listTeam != null && listTeam.Count > 0)
        {
            foreach (ITeam team in listTeam)
            {
                if (team.TeamCategorys != null)
                {
                    catalist.Add(team.TeamCategorys);
                    if (catalist.Count >= 10)
                    {
                        return catalist;
                    }
                }
            }
        }
        return catalist;
    }
    private void InitSide()
    {
        iListLocation = getAdd(0, 1);//得到首页顶部广告
        for (int i = 0; i < iListLocation.Count; i++)
        {
            ILocation c = iListLocation[i];
            sb.Append("pageConfig.DATA_MSlide.push({width: 670,height: 240,");
            sb.AppendFormat("href:\"{0}\",", c.pageurl);
            sb.AppendFormat("alt:\"{0}\",", "");
            sb.AppendFormat("src:\"{0}\",", c.locationname);
            sb.Append("widthB: 550,heightB: 240,srcB:\"\" });");
        }
    }
    private void InitTeam()
    {
        IList<ILocation> list = getAdd(0, 3);//得到首页下面广告
        for (int i = 0; i < list.Count; i++)
        {
            sb1.Append("{");
            sb1.Append("alt: \"\",");
            sb1.AppendFormat("href:\"{0}\",", list[i].pageurl);
            sb1.AppendFormat("index: {0},", i);
            sb1.AppendFormat("src: \"{0}\",", list[i].locationname);
            if (i > 2)
                sb1.Append("ext: \"\"");
            else
                sb1.Append("ext: \"1\"");
            sb1.Append("},");
        }
    }
    public string GetTuanUrl()
    {
        string url = String.Empty;
        if (_system["moretuan"] == "0")
            url = GetUrl("一日多团一", "index_tuanmore.aspx");
        else if (_system["moretuan"] == "1")
            url = GetUrl("一日多团二", "index_tuanmore2.aspx");
        else if (_system["moretuan"] == "2")
            url = GetUrl("一日多团三", "index_tuanmore3.aspx");
        else if (_system["moretuan"] == "3")
            url = GetUrl("一日多团四", "index_tuanmore4.aspx");
        else if (_system["moretuan"] == "4")
            url = GetUrl("一日多团五", "index_tuanmore5.aspx");
        else if (_system["moretuan"] == "5")
            url = GetUrl("一日多团六", "index_tuanmore6.aspx");
        return url;
    }
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta name="keywords" content="<%=PageValue.KeyWord %>" />
    <meta name="description" content="<%=PageValue.Description%>" />
    <link href="/upfile/css/index.css" rel="stylesheet" type="text/css" />
    <link rel="icon" href="<%=PageValue.WebRoot %>upfile/icon/favicon.ico" mce_href="<%=PageValue.WebRoot %>upfile/icon/favicon.ico" type="image/x-icon">
    <script type="text/javascript" src="<%=PageValue.WebRoot %>upfile/js/jquery-1.4.2.min.js"></script>
    <script type='text/javascript'>webroot = '<%=PageValue.WebRoot %>'; LOGINUID = '<%=AsUser.Id %>';</script>
    <title><%=PageValue.Title%></title>
</head>
<script type="text/javascript">
    jQuery(function () {
        function b() {
            d.each(function () {
                typeof $(this).attr("original") != "undefined" && $(this).offset().top < $(document).scrollTop() + $(window).height() && $(this).attr("src", $(this).attr("original")).removeAttr("original")
            })
        }
        var d = $(".dynload");
        $(window).scroll(function () {
            b();
            jQuery('img[w]').each(function () {
                try {
                    var w = parseInt(jQuery(this).attr("w"));
                    var width = jQuery(this).width();
                    if (width > w) {
                        jQuery(this).css("width", w);
                    }
                }
                catch (e) { }
            });
        });
        b();
    });
    function addToFavorite() {
        var d = "<%=PageValue.WWWprefix%>";
        var c = "<%=PageValue.CurrentSystemConfig["mallsitename"] %>";
        if (document.all) {
            window.external.AddFavorite(d, c)
        } else {
            if (window.sidebar) {
                window.sidebar.addPanel(c, d, "")
            } else {
                alert("\u5bf9\u4e0d\u8d77\uff0c\u60a8\u7684\u6d4f\u89c8\u5668\u4e0d\u652f\u6301\u6b64\u64cd\u4f5c!\n\u8bf7\u60a8\u4f7f\u7528\u83dc\u5355\u680f\u6216Ctrl+D\u6536\u85cf\u672c\u7ad9\u3002")
            }
        }
    }
</script>
<body class="root61">
    <script type="text/javascript" src="/upfile/js/jdbase-v1.js"></script>
    <div id="shortcut-2013">
        <div class="w">
<ul class="fl lh">
			<li  class="fore1 ld"><b></b><a rel="nofollow" href="javascript:addToFavorite()">收藏<%= PageValue.CurrentSystemConfig["mallsitename"]%></a>
			</li>
		</ul>
              <ul class="fr lh">
            <%if (IsLogin && AsUser.Id != 0)
              { %>
            <% if (AsUser.Realname != null && AsUser.Realname != "")
               {%>
                <li class="fore1" id="loginbar">您好，
                        <%=AsUser.Realname%>！<a href="<%=PageValue.WebRoot %>loginout.aspx" class="link-logout">[退出]</a></li>
                <li class="fore2 ld"><s></s><a href="<%=GetUrl("我的订单", "order_index.aspx")%>" rel="nofollow">我的订单</a></li>
                <%if (isPacket == true)
                  {%>
                <li class="fore3 ld"><s></s><a href="<%=GetUrl("我的红包", "order_packet.aspx")%>" rel="nofollow">我的红包</a></li>
                <%} %>
            <%}
               else
               { %>
          
                <li class="fore1" id="loginbar">您好，<%=AsUser.Username%>！<a href="<%=PageValue.WebRoot %>loginout.aspx"
                    class="link-logout">[退出]</a></li>
                <li class="fore2 ld"><s></s><a href="<%=GetUrl("我的订单", "order_index.aspx")%>" rel="nofollow">我的订单</a></li>
            <%} %>
            <%}
              else
              {%>
            <li class="fore1 ld" id="loginbar">您好！欢迎来到<%= PageValue.CurrentSystemConfig["mallsitename"]%>！<span><a
                href="<%=GetUrl("用户登录", "account_login.aspx")%>">[登录]</a>&nbsp;<a href="<%=GetUrl("用户注册", "account_loginandreg.aspx")%>">[免费注册]</a></span></li>
            <%} %>
            </ul>
              <span class="clr"></span>
        </div>
    </div>
    <!--shortcut end-->
    <!-- shortcut end -->
    <div id="o-header-2013">
        <div class="w" id="header-2013">
            <div id="logo-2013" class="ld">
                 <a href="<%=GetUrl("商城首页","mall_index.aspx")%>">
                    <b></b>
                    <img src="<%=headlogo %>" width="259" height="50" alt="<%= PageValue.CurrentSystemConfig["mallsitename"]%>"></a>
            </div>
            <!--logo end-->
            <div id="search-2013">
                <div class="i-search ld">
                    <b></b><s></s>
                    <ul id="shelper" class="hide">
                    </ul>
                    <div class="form">
                        <input type="text" class="text" x-webkit-speech="" lang="zh-CN" autocomplete="off" accesskey="s" id="keyword" autocomplete="off">
                        <input type="submit" value="搜索" class="button"
                            id="submit">
                    </div>
                </div>
                <div id="hotwords">
                </div>
            </div>
             <script type="text/javascript">
                 $(document).ready(function () {
                     $("#submit").click(function () {
                         var keyword = $("#keyword").val();
                         if (keyword.indexOf('<script>') >= 0) {
                             alert("非法字符！");
                             return;
                         }
                         if (keyword != "") {
                             window.location.href = '<%=GetTeamListPageUrl(0,0,0,0,0,0,0,String.Empty)%>' + '?keyword=' + encodeURIComponent(keyword);
                            }
                        });
                    });
                    $(document).ready(function () {
                        $("#keyword").keypress(function (event) {
                            if (event.keyCode == 13) {
                                var keyword = $("#keyword").val();
                                if (keyword.indexOf('<script>') >= 0) {
                                    alert("非法字符！");
                                    event.preventDefault();
                                    return;
                                }
                                if (keyword != "") {
                                    window.location.href = '<%=GetTeamListPageUrl(0,0,0,0,0,0,0,String.Empty)%>' + '?keyword=' + encodeURIComponent(keyword);
                                    event.preventDefault();
                                }
                                event.preventDefault();
                            }
                        });
                    });
             </script>
            <!--search end-->
                <div id="settleup-2013">
                    <dl>
                        <dt class="ld"><s><span id="shopping-amount"></span></s>
                            <a href="<%=GetUrl("京东购物车","mall_jdcart.aspx") %>">
                                <%if (carlist != null && carlist.Count > 0)
                                  {%>
                               购物车<%=carlist.Count %>件
                              <%}
                                  else
                                  { %>
                                 购物车0件 
                               <%}%>
                            </a>
                            <b></b>
                        </dt>
                    </dl>
                </div>
            <!--settleup end-->
        </div>

        <div class="w">
            <div id="nav-2013">
                <div id="categorys-2013">
                    <div class="mt ld">
                        <h2>
                            <a href="#">全部商品分类<b></b></a></h2>
                    </div>
                    <div id="_JD_ALLSORT" class="mc">
                        <%if (headcatas != null && headcatas.Count > 0)
                          {
                              int c = 1;
                              foreach (ICatalogs icatalogsInfo in headcatas)
                              {
                                  c++;
                                  IList<ICatalogs> small = GetCataSamall(icatalogsInfo.id, 0);
                        %>
                        <div class="item fore<%=c %>" onMouseOver="showhover(this)" onMouseOut="hidehover(this)">
                            <span>
                                <h3>
                                    <a href="<%=GetTeamListPageUrl(icatalogsInfo.id,0,0, 0,0,0,0,String.Empty) %>">
                                        <%=icatalogsInfo.catalogname %></a></h3>
                            </span>
                            <div class="i-mc">
                                <div class="subitem">
                                 <h4 style="height: 30px;line-height: 30px;border-bottom: 2px solid #E4393C;font-size: 15px;margin-top: 10px;"><%=icatalogsInfo.catalogname%></h4>
                                    <div onClick="$(this).parent().parent().removeClass('hover')" class="close"></div>
                                    <%foreach (var cata in small)
                                      {%>
                                           <dd > <em> <a href="<%=GetTeamListPageUrl(icatalogsInfo.id,cata.id,0,0, 0,0,0,String.Empty) %>"><%=cata.catalogname %></a></em> </dd>
                                    <%} %>
                                </div>
                            </div>
                        </div>
                        <%}%>
                        <%}%>
                        <div class="extra">
                            <a href="#">全部商品分类</a>
                        </div>
                    </div>
                </div>
                <ul id="navitems-2013">
                    <%
                        url = Request.Url.PathAndQuery;
                        string url1 = Request.RawUrl.ToString();
                        foreach (IGuid model in iListGuid)
                        {
                            if (model.guidopen == 0)
                            {
                                string target = "";
                                if (model.guidparent == 1)
                                {
                                    target = "target=_blank";
                                }
                                if (url1 == model.guidlink || url == model.guidlink)
                                {
                                    menuhtml = menuhtml + "<li class=\"hover\"><a href=\"" + model.guidlink + "\" " + target + ">" + model.guidtitle + "</a></li>";
                                }
                                else
                                {
                                    menuhtml = menuhtml + "<li class=\"fore3\"><a href=\"" + model.guidlink + "\"  " + target + ">" + model.guidtitle + "</a></li>";
                                }
                            }
                        }
                    %>
                    <%=menuhtml %>
                </ul>
                <script type="text/javascript">
                    function showhover(object) {
                        jQuery('#_JD_ALLSORT').children('div').removeClass('hover');
                        jQuery(object).addClass('hover');
                    }
                    function hidehover(object) {
                        jQuery('#_JD_ALLSORT').children('div').removeClass('hover');
                    }
                    $(document).ready(function () {
                        $("#navitems-2013 li").Jdropdown();
                    });
                </script>
            </div>
        </div>
    </div>
    <!-- header end -->
    <!-- header end -->
    <div class="w">
        <div id="o-slide">
            <div class="slide" id="slide">
                <script type="text/javascript">
                    pageConfig.DATA_MSlide = [];
			        <%=sb.ToString()%>
     (function (object, data) {
                        var a = data, b = [], c = [];
                        if (data!="") {
                        var x = pageConfig.FN_GetCompatibleData(a[0]), e = [];
                        e.push("<ul class=\"slide-items\"><li><a target=\"_blank\" href=\"");
                        e.push(x.href);
                        e.push("\" title=\"");
                        e.push(x.alt);
                        e.push("\"><img src=\"");
                        e.push(x.src);
                        e.push("\" width=\"");
                        e.push(x.width);
                        e.push("\" height=\"");
                        e.push(x.height);
                        e.push("\" /></a></li></ul><div class=\"slide-controls\"><span class=\"curr\">1</span></div>");
                        document.getElementById(object).innerHTML = e.join("");
                        pageConfig.DATA_MSlide = a
                        }
                    })("slide", pageConfig.DATA_MSlide);
                </script>
            </div>
            <!--slide end-->
            <div class="jscroll" id="mscroll">
                <div class="ctrl" id="mscroll-ctrl-prev"><b></b></div>
                <div class="ctrl" id="mscroll-ctrl-next"><b></b></div>
                <div class="o-list">
                    <div class="list" id="mscroll-list"></div>
                </div>
            </div>
            <!--mscroll end-->
            <script type="text/javascript">
                pageConfig.DATA_MScroll = [<%=sb1.ToString().TrimEnd(',')%>];
                (function (object, data) {
                    var a = data;
                    var e = [];
                    if (data!="") {
                    e.push("<ul class=\"lh\">");
                    for (var i = 0; i < 3; i++) {
                        x = pageConfig.FN_GetCompatibleData(a[i]);
                        e.push("<li class=\"item\"><a href=\"");
                        e.push(x.href);
                        e.push("\"><img src=\"http://misc.360buyimg.com/lib/img/e/blank.gif\" style=\"background:url(");
                        e.push(x.src);
                        e.push(") no-repeat #fff center 0;\" alt=\"");
                        e.push(x.alt);
                        e.push("\" width=\"");
                        e.push(x.width);
                        e.push("\" height=\"");
                        e.push(x.height);
                        e.push("\" /></a></li>")
                    };
                    e.push("</ul>");
                    document.getElementById(object).innerHTML = e.join("");
                    pageConfig.DATA_MScroll = a;}
                })("mscroll-list", pageConfig.DATA_MScroll);
            </script>
        </div>
         <!--slide end-->
        <div id="jdnews" class="m m1">
            <%if (iListNews != null && iListNews.Count > 0)
              {%>
            <div class="mt">
                <h2>新闻快报</h2>
                <div class="extra"><a href="<%=GetUrl("新闻公告", "usercontrols_Morenewlist.aspx?type=1")%>" target="_blank">更多快报&nbsp;&gt;</a></div>
            </div>
            <ul>
                <%foreach (INews inewsInfo in iListNews)
                  {
                      if (inewsInfo.link != null && inewsInfo.link != "")
                      {
                %>
                <li class="odd"><a target="_blank" href="<%=inewsInfo.link %>">
                    <%=inewsInfo.title%></a></li>
                <%}
                      else
                      {%>
                <li class="odd"><a target="_blank" href="<%=GetUrl("新闻","usercontrols_newlist.aspx?id="+inewsInfo.id)%>">
                    <%=inewsInfo.title%></a></li>
                <% } %>
                <%}%>
            </ul>
            <%}%>
        </div>
        <!--jdnews-->
        <div id="virtuals" class="m m3">
            <%IList<ILocation> locationlist = getAdd(1, 2);%>
            <% if (locationlist != null && locationlist.Count > 0) { Response.Write(locationlist[0].locationname); }%>
        </div>
        <!--virtuals end-->
        <span class="clr"></span>
    </div>

   <!-- <div class="w w1">
       
    </div>-->

    <div class="w">
        <div class="m m2" id="hot">
            <div class="fore1 curr"  data-widget="tab-item" onMouseOver="showhot(this,'news')">
                <div class="mt">
                    <h2>新品上架</h2>
                   <div class="tab-arrow" style="left: 534px;"><b></b></div>
                </div>
                <div class="mc">
                    <ul class="lh style2">
                        <%IList<ITeam> newlist = GetNew();
                          int v = 0;
                          if (newlist != null && newlist.Count > 0)
                          {
                              foreach (var team in newlist)
                              {
                                  v++; %>
                        <li class="fore<%=v %>">
                            <div class="p-img ld">
                                <a href="<%=getTeamPageUrl(team.Id)%>" target="_blank"><img <%=ashelper.getimgsrc(team.Image) %>
                                    height="100" alt="<%=team.Title%>" class="dynload"></a>
                            </div>
                            <div class="p-name">
                                <a href="<%=getTeamPageUrl(team.Id)%>" title="<%=team.Title%>" target="_blank"><%=team.Title%></a>
                            </div>
                            <div class="p-price">
                                <span><%=ASSystemArr["Currency"] %></span><span><%=GetMoney(team.Team_price) %></span>
                            </div>
                        </li>
                        <%}%>
                        <%}%>
                    </ul>
                </div>
            </div>
            <div class="fore3" data-widget="tab-item" onMouseOver="showhot(this,'mhot')">
                <div class="mt">
                    <h2>热卖商品</h2>
                </div>
                <div id="mhot" class="mc" data-widget="tab-content">
                    <div class="loading-style1">
                        <b></b>加载中，请稍候...
                    </div>
                </div>
            </div>
            <div class="fore4" data-widget="tab-item" onMouseOver="showhot(this,'mtui')">
                <div class="mt">
                    <h2>推荐商品</h2>
                </div>
                <div id="mtui" class="mc" data-widget="tab-content">
                    <div class="loading-style1">
                        <b></b>加载中，请稍候...
                    </div>
                </div>
            </div>
            <div class="fore5" data-widget="tab-item" onMouseOver="showhot(this,'msale')">
                <div class="mt">
                    <h2>低价促销</h2>
                </div>
                <div id="msale" class="mc" data-widget="tab-content">
                    <div class="loading-style1">
                        <b></b>加载中，请稍候...
                    </div>
                </div>
            </div>
            <div class="fore2" data-widget="tab-item" onMouseOver="showhot(this,'grab')">
                <div class="mt">
                    <h2>限时抢购</h2>
                </div>
                <div id="grab" class="mc" data-widget="tab-content">
                    <div class="loading-style1">
                        <b></b>加载中，请稍候...
                    </div>
                </div>
            </div>
        </div>
        <script language="javascript" type="text/javascript">
            function showhot(object, divname) {
                jQuery('#hot').children('div').removeClass('curr');
                jQuery(object).addClass('curr');
                var idhtml = $('#' + divname).html();
                var idtext = $('#' + divname).text();
                if (idtext.indexOf("加载中") >= 0) {
                    $.ajax({
                        type: "POST",
                        url: webroot + "ajax/ajax_getteam.aspx",
                        data: { "type": divname },
                        success: function (msg) {
                            $('#' + divname).html(msg);
                        }
                    });
                }
            }
        </script>
        <div class="m m1" id="group" clstag="homepage|keycount|home2013|16a">
            <div class="mt">
                <h2>今日团购</h2>
                <div class="extra"><a href="<%=GetTuanUrl()%>" target="_blank">更多团购&nbsp;&gt;</a></div>
            </div>
            <%if (CurrentTeam != null)
              {%>
            <div class="jscroll mc" id="gscroll">
                <div class="o-list">
                    <div class="list" id="gscroll-list" style="position: relative; width: 292px; height: 230px; overflow: hidden;">
                        <ul class="lh" style="position: absolute; width: 1168px; height: 230px; top: 0px; left: 0px;">
                            <li class="item fore1"><a href="<%=getTeamPageUrl(CurrentTeam.Id) %>" target="_blank">
                                <img width="292" height="230" src="<%=CurrentTeam.Image %>" style="background: url(<%=CurrentTeam.Image%>) no-repeat 0 0;" class="loading-style2" alt="<%=CurrentTeam.Title %>"></a>
                                <div class="p-detail"><a target="_blank" class="btn-tuan" href="<%=getTeamPageUrl(CurrentTeam.Id) %>">参团</a>                <span>团购价：</span><strong> <%=ASSystemArr["Currency"] %><%=GetMoney(CurrentTeam.Team_price)%></strong>            </div>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
            <%}%>
        </div>
        <!--virtuals end-->
        <span class="clr"></span>
    </div>

    <%if (headcataslist != null && headcataslist.Count > 0)
      {%>
    <%int k = 0; %>
    <%string ids = String.Empty; %>
    <% foreach (ICatalogs icatalogsInfo in headcataslist)
       {
           k++;
    %>
    <div class="w w1" id="electronics">
        <div class="m m1 catalogue">
            <div class="mt ld">
                <div class="floor"><b class="fixpng b b1"></b><b class="fixpng b b2" style="height: 34px; display: block;"></b><b class="b b3"><%=k %></b><b class="fixpng b4"></b></div>
                <h2><%=icatalogsInfo.catalogname.Length>5?icatalogsInfo.catalogname.Substring(0,5):icatalogsInfo.catalogname %></h2>
            </div>
            <div class="mc">
                <div class="style1">
                    <ul class="lh">
                        <%IList<ICatalogs> cc = GetCataMall(icatalogsInfo.id.ToString(), 0); %>
                        <%foreach (var item in cc)
                          {%>
                        <li><a href="<%=GetTeamListPageUrl(icatalogsInfo.id,item.id,0,0,0,0,0,String.Empty)%>"><b>·</b><%=item.catalogname %></a></li>
                        <%} %>
                    </ul>
                    <span><a target="_blank" title="<%=icatalogsInfo.catalogname %>" href="<%=Helper.GetString(icatalogsInfo.url,String.Empty) %>">
                        <img <%=ashelper.getimgsrc(Helper.GetString(icatalogsInfo.image,String.Empty)) %>
                            width="208" height="170" alt="<%=icatalogsInfo.catalogname %>" class="dynload"></a></span>
                </div>
            </div>
        </div>


        <div class="m plist" id="plist<%=k %>">
            <%IList<ICatalogs> child = GetCataMall(icatalogsInfo.id.ToString(), 5); %>
            <%int i = 0; %>
            <%int j = 1; %>
            <%foreach (var item in child)
              {%>
            <%IList<ITeam> list = getMallTeamByCataid(item.id);%>
            <%i++; %>
            <%if (i == 1)
              {%>
            <div class="sm sm2 fore1 curr" data-widget="tab-item" onMouseOver="show(this,'<%=item.id%>','plist<%=k %>')">
                <%}
              else
              { %>
                <div class="sm sm2 fore<%=i %>" data-widget="tab-item" onMouseOver="show(this,'<%=item.id%>','plist<%=k %>')">
                    <%} %>
                    <div class="smt">
                        <h3>
                            <%=item.catalogname%></h3>
                    </div>
                    <%if (i == 1)
                      {%>
                    <div id="team<%=item.id%>" class="smc" data-widget="tab-content">
                        <ul class="lh style3">
                            <%foreach (var team in list)
                              {%>
                            <li class="fore<%=j++ %>">
                                <div class="p-img ld">
                                      <a target="_blank" href="<%=getTeamPageUrl(team.Id) %>" title="<%=team.Product %>">
                                    <img height="100" alt="<%=team.Product %>" data-img="1" "<%=ashelper.getimgsrc(team.Image.ToString()) %>" class="dynload"></a>
                                </div>
                                <div class="p-name">
                                    <a target="_blank" href="<%=getTeamPageUrl(team.Id) %>" title="<%=team.Product %>">
                                        <%=team.Product.ToString()%></a>
                                </div>
                                <div class="p-price">
                                    <span><%=ASSystemArr["Currency"] %></span><span><%=GetMoney(team.Team_price)%></span>
                                </div>
                            </li>
                            <%} %>
                        </ul>
                    </div>
                    <%}
                      else
                      {%>
                    <div id="team<%=item.id%>" class="smc" data-widget="tab-content">
                        <div class="loading-style1">
                            <b></b>加载中，请稍候...
                        </div>
                    </div>
                    <%}%>
                </div>
                <%} %>
            </div>
            <div class="sm sm1 brands">
                <div class="smt">
                    <div class="extra"><a href="<%=GetUrl("商城品牌大全","mall_brandlist.aspx") %>" target="_blank">更多品牌<b></b></a></div>
                </div>
                <div class="smc">
                    <ul class="lh">
                        <% IList<ICategory> catlist = GetBrandlist(icatalogsInfo.id);%>
                        <%if (catlist != null && catlist.Count > 0)
                          {%>
                        <%foreach (var brand in catlist)
                          {%>
                        <li class="fore1"><a target="_blank" title="<%=brand.Name %>" href="<%=GetTeamListPageUrl(icatalogsInfo.id,0,0,brand.Id, 0,0,0,"") %>">
                             <img height="35" width="98" alt="<%=brand.Name %>" data-img="2" "<%=ashelper.getimgsrc(brand.content) %>" class="dynload"></a></li>
                        <%} %>
                        <% } %>
                    </ul>
                </div>
            </div>

            <div class="fr da209x180">
                <div class="slide">
                    <div class="slide-itemswrap">
                        <div class="slide-items">
                            <a target="_blank" title="<%=icatalogsInfo.catalogname %>" href="<%=Helper.GetString(icatalogsInfo.url1,String.Empty) %>">
                                <img <%=ashelper.getimgsrc(Helper.GetString(icatalogsInfo.image1,String.Empty))%>  width="208" height="180" alt="<%=icatalogsInfo.catalogname %>" class="dynload"></a>
                        </div>
                    </div>
                </div>
            </div>
            <!-- ad start -->
            <span class="clr"></span>
        </div>
    </div>
    <%}%>
    <%}%>
    <script language="javascript" type="text/javascript">
        function show(object, divname, mp) {
            jQuery('#' + mp).children('div').removeClass('curr');
            var id = "#team" + divname;
            var idhtml = $(id).html();
            var idtext = $(id).text();
            jQuery(object).addClass('curr');
            if (idtext.indexOf("加载中") >= 0) {
                $.ajax({
                    type: "POST",
                    url: webroot + "ajax/ajax_getteam.aspx",
                    data: { "id": divname },
                    success: function (msg) {
                        $(id).html(msg);
                    }
                });
            }
        }
    </script>
    <script type="text/javascript" src="/upfile/js/jdpack.js"></script>
    <script type="text/javascript" src="/upfile/js/jdlib-v1.js"></script>
    <script type="text/javascript">
        pageConfig.TPL_MScroll = '<ul class="lh">\
	{for slide in list}\
	<li class="item fore${parseInt(slide_index)+1}">\
		<a href="${slide.href}" target="_blank">\
			<img width="202" height="159" src="http://misc.360buyimg.com/lib/img/e/blank.gif" class="loading-style2" data-lazyload="background:url(${slide.src}) no-repeat #fff center 0;" alt="${slide.alt}" /></a>\
	</li>\
	{/for}</ul>';
    </script>
    <script type="text/javascript" src="/upfile/js/jdhome.js"></script>
    <div class="w">
        <div id="service-2013">
            <dl class="fore1">
                <dt><b></b><strong></strong></dt>
                <dd>
                    <div>
                        <a href="<%=GetUrl("玩转东购团","help_tour.aspx")%>">玩转<%=abbreviation%></a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("常见问题","help_faqs.aspx")%>">常见问题</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("东购团概念","help_asdht.aspx")%>"><%=abbreviation%>概念</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("开发API","help_api.aspx")%>">开发API</a>
                    </div>

                </dd>
            </dl>
            <dl class="fore2">
                <dt><b></b><strong></strong></dt>
                <dd>
                    <div>
                        <a href="<%=GetUrl("邮件订阅","help_Email_Subscribe.aspx?cityid="+CurrentCity.Id)%>">邮件订阅</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("RSS订阅","help_RSS_feed.aspx?ename="+CurrentCity.Ename)%>">RSS订阅</a>
                    </div>
                    <%if (ASSystem.sinablog != "")
                      {%>
                    <div><a href="<%=ASSystem.sinablog %>" target="_blank">新浪微博</a></div>
                    <%} %>
                    <%if (ASSystem.qqblog != "")
                      {%>
                    <div><a href="<%=ASSystem.qqblog %>" target="_blank">腾讯微博</a></div>
                    <%} %>
                </dd>
            </dl>
            <dl class="fore4">
                <dt><b></b><strong></strong></dt>
                <dd>
                    <div>
                        <a href="<%=GetUrl("关于东购团","about_us.aspx")%>">关于<%=abbreviation %></a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("工作机会","about_job.aspx")%>">工作机会</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("联系方式","about_contact.aspx")%>">联系方式</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("用户协议","about_terms.aspx")%>">用户协议</a>
                    </div>
                </dd>
            </dl>
            <dl class="fore5">
                <dt><b></b><strong></strong></dt>
                <dd>
                    <div>
                        <a href="<%=GetUrl("商务合作","feedback_seller.aspx")%>">商务合作</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("友情链接","help_link.aspx")%>">友情链接</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("后台管理","Login.aspx")%>">后台管理</a>
                    </div>
                </dd>
            </dl>
            <div class="fr">
                <div class="sm" id="branch-office">
                    <%if (Request.Url.ToString().ToLower().IndexOf("/mall/") > 0)
                      { %>
                    <a href="<%=WebRoot%>mall/index.aspx">
                        <%if (_system != null && _system["mallfootlogo"] != null && _system["mallfootlogo"].ToString() != "")
                          { %>
                        <img src="<%=_system["mallfootlogo"].ToString() %>" />
                        <%}
                          else
                          { %>
                        <img src="/upfile/img/mall_logo.png" />
                        <%}%>
                    </a>
                    <%}
                      else
                      {%>
                    <a href="<%=WebRoot%>index.aspx">
                        <img src="<%=footlogo %>" /></a>
                    <%}%>
                </div>
            </div>
            <span class="clr"></span>
        </div>
    </div>
    <div class="w">
        <div id="footer-2013">
            <div class="copyright">
                &copy;<span>2010</span>&nbsp;<%=sitename
                %>（<%=WWWprefix %>）版权所有&nbsp;<a href="<%=GetUrl("用户协议","about_terms.aspx")%>">使用<%=abbreviation
                %>前必读</a><br />
                <a href="http://www.miibeian.gov.cn/" target="_blank"><%=icp %></a>&nbsp;&nbsp;<%=statcode
                %> &nbsp;Powered by ASdht(<a target="_blank" href="http://www.asdht.com">艾尚团购系统程序</a>)
    Software V_<%=ASSystemArr["siteversion"] %>
            </div>
        </div>
    </div>
</body>
</html>
