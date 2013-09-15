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
<%@ Import Namespace="AS.GroupOn.App" %>
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
    protected IList<ILocation> iListLocation = null;
    protected IList<ILocation> iListLocationsider = null;//侧栏广告
    public NameValueCollection _system = null;
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
    protected int teamid = 0;
    protected string Currency;
    protected IList<ITeam> dt_pinglun = null;
    protected ITeam shopteam = null;
    protected ITeam ds = null;
    protected ITeam teammodel = null;
    protected IList<ITeam> ds1 = null;
    protected IList<ITeam> dto = null;
    protected string myvalue = "";
    protected IPagers<ITeam> pagers = null;
    protected string pagerhtml = string.Empty;
    public string page = "1";
    protected int k = 0;
    protected AS.GroupOn.Domain.ITeam t = null;
    public decimal summoney = 0;
    public int summount = 0;
    protected NameValueCollection myteam = new NameValueCollection();
    List<Car> carlist = new List<Car>();
    protected int cataparid = 0;
    protected int catamalid = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        carlist = CookieCar.GetCarData();
        myteam = AS.Common.Utils.Helper.GetObjectProtery(t);
        teamid = Helper.GetInt(Request["id"], 0);
        GetGuid();
        iListLocation = getAdd(0, 1);//得到首页广告
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
        headcatas = getCata("head"); //得到头部商品项目父分类
        getNews();

        setBuyTitle();

        if (teamid > 0)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                shopteam = session.Teams.GetByID(teamid);

            }
            //详情 加入购物车
            TeamFilter tfilter = new TeamFilter();
            tfilter.Id = teamid;
            tfilter.teamcata = 1;
            tfilter.mallstatus = 1;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ds = session.Teams.Get(tfilter);
                teammodel = session.Teams.Get(tfilter);
            }
            //喜欢此产品的用户还喜欢
            TeamFilter tfilter2 = new TeamFilter();
            tfilter2.oper_teamid = teamid;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ds1 = session.Teams.GetTeamOper(tfilter2);
            }
            //我浏览过的
            myvalue = CookieUtils.GetCookieValue("Cookie_historys");
            //浏览历史cookie
            CookieUtils.AddCookie(teamid.ToString());



            //同类热销排行
            int teamdetailnum = 0;
            if (_system["teamdetailnum"] != null && _system["teamdetailnum"].ToString() != "")
            {
                teamdetailnum = Helper.GetInt(_system["teamdetailnum"], 0);
            }
            TeamFilter tfilter3 = new TeamFilter();
            tfilter3.Top = teamdetailnum;
            tfilter3.dto_teamid = teamid;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                dto = session.Teams.GetTeamDto(tfilter3);
            }
        }
        if (Request["page"] != null && Request["page"].ToString() != "")
        {
            if (NumberUtils.IsNum(Request["page"].ToString()))
            {
                page = Request["page"].ToString();
            }
        }
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
    /// 得到分类
    /// </summary>
    protected IList<ICatalogs> getCata(string type)
    {
        int top = 0;
        IList<ICatalogs> iListCatalogsds = null;
        iListCatalogsds = GethostCataMall(top, 0, 1);
        return iListCatalogsds;
    }

    /// <summary>
    /// 显示主推大类：商城
    /// </summary>
    /// <param name="top"></param>
    /// <param name="cityid"></param>
    /// <param name="location"></param>
    /// <returns></returns>
    protected IList<ICatalogs> GethostCataMall(int top, int cityid, int location)
    {
        IList<ICatalogs> iListCatalogs = null;
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        catalogsfilter.type = 1;
        catalogsfilter.parent_id = 0;
        catalogsfilter.visibility = 0;
        catalogsfilter.catahost = 0;
        catalogsfilter.AddSortOrder(CatalogsFilter.MoreSort);
        if (top == 0)
        {
            if (cityid == 0)
            {
                if (location == 1)
                {
                    catalogsfilter.LocationOr = 1;
                }
            }
        }
        else
        {
            if (cityid == 0)
            {
                if (location == 1)
                {
                    catalogsfilter.Top = top;
                    //catalogsfilter.LocationOr = 1;
                }
            }
        }
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
    protected IList<ICatalogs> GetCataMall(string where)
    {
        IList<ICatalogs> iListCatalogsTwo = null;
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        catalogsfilter.type = 1;
        catalogsfilter.parent_idNotZero = 0;
        catalogsfilter.visibility = 0;
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
    /// 买家评论内容
    /// </summary>
    public void setBuyTitle()
    {
        page = Request.QueryString["page"];
        TeamFilter teamfilter = new TeamFilter();
        teamfilter.pl_teamid = teamid.ToString();
        if (_system["navUserreview"] != null && _system["navUserreview"].ToString() == "1")
        {
            if (_system["UserreviewYN"] != null && _system["UserreviewYN"].ToString() == "1")
            {
                teamfilter.pl_state = 1;
            }
            teamfilter.PageSize = 1;
            teamfilter.AddSortOrder(TeamFilter.ID_ASC);
            teamfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                dt_pinglun = session.Teams.GetPingLun(teamfilter);
            }

            //pagerhtml = WebUtils.GetPagerHtml(1, dt_pinglun.Count, Helper.GetInt(Request.QueryString["page"], 1), "#coms");
        }

    }

    public string Getfont1(int teamid, string oldresult)
    {
        string str = "";
        string bulletin = "";
        string initfont = "";

        ITeam iteam = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iteam = session.Teams.GetByID(teamid);
        }
        if (iteam != null)
        {
            bulletin = iteam.bulletin;
        }
        if (Utility.Getbulletin(bulletin) != "")
        {
            #region
            string[] bulletinteam = bulletin.Replace("{", "").Replace("}", "").Split(',');

            #region
            if (Utility.Getbulletin(iteam.bulletin) != "")
            {

                if (oldresult != "")
                {

                    string strResult = "";

                    for (k = 0; k < bulletinteam.Length; k++)
                    {
                        strResult = strResult + "," + bulletinteam[k].Split(':')[0];
                        if (bulletinteam[k] != "")
                        {
                            str += "<li id=\"choose-version\">";
                            str += "<div class=\"dt\" id=\"font_attr_name" + k + "\">" + bulletinteam[k].Split(':')[0] + "：</div>";
                            str += "<input type=\"hidden\" name='attr_value' id=\"attr_value_" + k + "\" />";
                            str += "<input type=\"hidden\" id=\"redspan" + k + "\" />";
                            str += "<div class=\"dd\">";
                            if (bulletinteam[k].Replace("[", "").Replace("]", "").Replace(":", "") != "")
                            {
                                string[] bull = bulletinteam[k].Split(':')[1].Replace("[", "").Replace("]", "").Split('|');

                                initfont = initfont + "," + bulletinteam[k].Split(':')[0] + ":[" + bull[0].ToString() + "]";

                                for (int h = 0; h < bull.Length; h++)
                                {
                                    if (h == 0)
                                    {
                                        str += "<div id=\"greyspan" + h + "_" + k + "\" name=\"greyspan" + k + "\" style=\"cursor: pointer;\" class=\"item selected\"><b></b><a  title=\"" + bull[h] + " \" href=\"#none\"  onclick=\"setattrvalue1(" + k + ",'" + bulletinteam[k].Split(':')[0] + "'," + h + ",'" + bull[h] + "')\">" + bull[h] + "</a></div>";
                                    }
                                    else
                                    {
                                        str += "<div id=\"greyspan" + h + "_" + k + "\" name=\"greyspan" + k
                                           + "\" style=\"cursor: pointer;\" class=\"item\"><b></b><a  title=\"" + bull[h] + " \" href=\"#none\" onclick=\"setattrvalue1(" + k + ",'" + bulletinteam[k].Split(':')[0] + "'," + h + ",'"
                                           + bull[h] + "')\">" + bull[h] + "</a></div>";


                                    }

                                }

                            }
                            str += "</div>";
                            str += "</li>";

                        }
                        str += "<li><span id=\"s_attr_name" + k + "\" class=\"STYLE317\"></span></li>";

                    }
                    str += "<input type=\"hidden\"  value=\"" + initfont + "\" id=\"hidattrname\" />";
                    str += "<input type=\"hidden\" id=\"hidattrvale\" value='" + strResult.Substring(1) + "' />";
                }

            }
            #endregion



            #endregion

        }


        return str;
    }
    public void UpdateView(AS.GroupOn.Domain.ITeam team)
    {
        t = team;
        myteam = AS.Common.Utils.Helper.GetObjectProtery(team);
    }
    private NameValueCollection _assystemarr = null;
    public NameValueCollection ASSystemArr
    {
        get
        {
            if (_assystemarr == null)
            {
                _assystemarr = Helper.GetObjectProtery(ASSystem);
                if (_assystemarr == null) _assystemarr = new NameValueCollection();
            }
            return _assystemarr;
        }
    }
   
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title> <%=PageValue.Title%></title>
    <meta name="keywords" content="<%=PageValue.KeyWord %>" />
    <meta name="description" content="<%=PageValue.Description%>" />
    <link href="<%=PageValue.WebRoot %>upfile/css/purchase.2012.css" rel="stylesheet" type="text/css" />
    <link href="<%=PageValue.WebRoot %>upfile/css/indexs.css" rel="stylesheet" type="text/css" media="all" />
    <link rel="icon" href="<%=PageValue.WebRoot %>upfile/icon/favicon.ico" mce_href="<%=PageValue.WebRoot %>upfile/icon/favicon.ico" type="image/x-icon">
    <script type='text/javascript' src="<%=PageValue.WebRoot %>upfile/js/index.js"></script>
    <script type='text/javascript'>webroot = '<%=PageValue.WebRoot %>'; LOGINUID = '<%=AsUser.Id %>';</script>
    <link href="<%=PageValue.WebRoot %>upfile/css/base.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" type="text/css" href="<%=PageValue.WebRoot %>upfile/css/pshow.css" media="all" />
</head>
<%if (WebUtils.config["slowimage"] == "1")
  { %>
<script src="<%=PageValue.WebRoot%>upfile/js/jquery.all_plugins.js" type="text/javascript"></script>
<script type="text/javascript">
    $(document).ready(function () {
        $("img[original]").lazyload(
        			{
        			    effect: "fadeIn",
        			    placeholder: webroot + "upfile/img/spacer.gif"
        			}
        		);
    });
</script>
<%}%>
<script type="text/javascript">
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
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog" style="display: none; background-color: rgb(255, 255, 255); left: 517.5px;
        top: 73.8px; z-index: 10000;">
    </div>
    <script type="text/javascript" src="<%=PageValue.WebRoot %>upfile/js/jdbase-v1.js"></script>

    <div id="shortcut-2013">
        <div class="w">
            <ul class="fl lh">
                <li class="fore1 ld"><b></b><a rel="nofollow" href="javascript:addToFavorite()">收藏<%= PageValue.CurrentSystemConfig["mallsitename"]%></a>
                </li>
            </ul>
            <ul class="fr lh">
                <%if (IsLogin && AsUser.Id != 0)
                  { %>
                <% if (AsUser.Realname != null && AsUser.Realname != "")
                   {%>
                <ul class="links">
                    <li class="fore1 ld" id="Li1">您好，
                        <%=AsUser.Realname%>！<a href="<%=PageValue.WebRoot %>loginout.aspx" class="link-logout">[退出]</a></li>
                    <li class="fore2"><a href="<%=GetUrl("我的订单", "order_index.aspx")%>" rel="nofollow">我的订单</a></li>
                    <%if (isPacket == true)
                      {%>
                    <li class="fore2"><a href="<%=GetUrl("我的红包", "order_packet.aspx")%>" rel="nofollow">
                        我的红包</a></li>
                    <%} %>
                </ul>
                <%}
                   else
                   { %>
                <ul class="links">
                    <li class="fore1 ld" id="Li2">您好，<%=AsUser.Username%>！<a href="<%=PageValue.WebRoot %>loginout.aspx"
                        class="link-logout">[退出]</a></li>
                    <li class="fore2"><a href="<%=GetUrl("我的订单", "order_index.aspx")%>" rel="nofollow">我的订单</a></li>
                </ul>
                <%} %>
                <%}
                  else
                  {%>
                <li class="fore1 ld" id="loginbar">您好！欢迎来到<%= PageValue.CurrentSystemConfig["mallsitename"]%>！<a
                    href="<%=GetUrl("用户登录", "account_login.aspx")%>">[登录]</a>&nbsp;<a href="<%=GetUrl("用户注册", "account_loginandreg.aspx")%>">[免费注册]</a></li>
                <%} %>
            </ul>
            <span class="clr"></span>
        </div>
    </div>
    <!--shortcut end-->
    <div id="o-header-2013">
        <div class="w" id="header-2013">
            <div id="logo" class="ld">
                <a href="<%=GetUrl("商城首页","mall_index.aspx")%>"><b></b>
                    <img src="<%=headlogo %>" width="259" height="50" alt="<%= PageValue.CurrentSystemConfig["mallsitename"]%>" /></a>
            </div>
            <!--logo end-->
            <div id="search-2013">
                <div class="i-search ld">
                    <b></b><s></s>
                    <ul id="shelper" class="hide">
                    </ul>
                    <div class="form">
                        <input id="keyword" type="text" class="text" autocomplete="off" x-webkit-speech=""
                            lang="zh-CN">
                        <input type="button" value="搜索" class="button" id="submit" name="submit">
                    </div>
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
                    <dt class="ld"><s><span id="shopping-amount"></span></s><a href="<%=GetUrl("京东购物车","mall_jdcart.aspx") %>">
                        <%if (carlist != null && carlist.Count > 0)
                          {%>
                        购物车<%=carlist.Count %>件
                        <%}
                          else
                          { %>
                        购物车0件
                        <%}%>
                    </a><b></b></dt>
                </dl>
            </div>
            <!--settleup end-->
        </div>
        <div class="w">
            <div id="nav-2013">
                <div id="categorys-2013">
                    <div class="mt ld">
                        <h2>
                            <a href="#" onmouseover="$('#_JD_ALLSORT').attr('style','display:block');$('#categorys-2013 .mt b').attr('style', 'background-position:-65px -23px');"
                                onmouseout="$('#_JD_ALLSORT').attr('style','display:none');$('#categorys-2013 .mt b').attr('style', 'background-position:-65px 0');">
                                全部商品分类<b></b></a></h2>
                    </div>
                    <div id="_JD_ALLSORT" class="mc" load="2" onmouseover="$('#_JD_ALLSORT').attr('style','display:block');$('#categorys-2013 .mt b').attr('style', 'background-position:-65px -23px');"
                        onmouseout="$('#_JD_ALLSORT').attr('style','display:none');$('#categorys-2013 .mt b').attr('style', 'background-position:-65px 0');">
                        <%if (headcatas != null && headcatas.Count > 0)
                          {
                              int c = 1;
                              foreach (ICatalogs icatalogsInfo in headcatas)
                              {
                                  c++;
                                  IList<ICatalogs> small = GetCataSamall(icatalogsInfo.id, 0);

                                  int s = 0;
                        %>
                        <div class="item fore<%=c %>" onmouseover="showhover(this)" onmouseout="hidehover(this)">
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
                        <% }

                              } %>
                        <div class="extra">
                            <a href="#">全部商品分类</a>
                        </div>
                    </div>
                </div>
                <ul id="navitems-2013">
                    <%url = Request.Url.PathAndQuery;
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
                                  menuhtml = menuhtml + "<li id=\"nav-home\" class=\"fore1\"><a href=\"" + model.guidlink + "\"  " + target + ">" + model.guidtitle + "</a></li>";
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
    <%if (teammodel != null)
      {%>
    <div class="w">
        <div class="breadcrumb">
            <strong>您现在的位置:</strong>&nbsp;&nbsp;<a href="<%=BaseUserControl.getMallPageUrl(Helper.GetString(_system["isrewrite"], "0")) %>"
                style="color: #c00"><b><%=_system["mallsitename"]%></b></a>
            <% 
              if (ds.TeamCatalogs != null)
              {

                  CatalogsFilter catafilter = new CatalogsFilter();
                  catafilter.Where = " ids like'%" + ds.TeamCatalogs.id + "%' or id=" + ds.TeamCatalogs.id;
                  IList<ICatalogs> ilistcata = null;
                  using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                  {
                      ilistcata = session.Catalogs.GetList(catafilter);
                  }
                  if (ilistcata != null)
                  {
                      string id = string.Empty;
                      foreach (ICatalogs cata in ilistcata)
                      {
                          if (cata.parent_id == 0)
                          {%>
            <em>&gt;</em><a href="<%=GetTeamListPageUrl(cata.id, 0,0, 0, 0, 0,0, String.Empty)%>"><%=cata.catalogname%></a>
            <%
                              id = cata.id.ToString();
                          }
                          if (cata.parent_id == ds.TeamCatalogs.parent_id)
                          {
                              ICatalogs catalogs = Store.CreateCatalogs();
                              CatalogsFilter cafilter = new CatalogsFilter();
                              cafilter.Where = "parent_id in (select id from catalogs where parent_id=0 and (ids like'%" + ds.TeamCatalogs.id + "%' or id=" + ds.TeamCatalogs.id + ")) and ids like '%" + ds.TeamCatalogs.id + "%'";
                              using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                              {
                                  catalogs = session.Catalogs.Get(cafilter);
                              }
                              if (catalogs != null)
                              {%>
            <em>&gt;</em><a href="<%=GetTeamListPageUrl(Helper.GetInt(id,0),catalogs.id,0, 0, 0, 0,0, String.Empty)%>"><%=catalogs.catalogname%></a>
            <%}

                          }

                      }
                      if (ds.TeamCatalogs.catalogname != "" && ds.TeamCatalogs.parent_id != 0)
                      {
            %>
            <em>&gt;</em><a href="<%=GetTeamListPageUrl(Helper.GetInt(id,0), Helper.GetInt(ds.cataid,0),0, 0, 0, 0,0,String.Empty)%>"><%=ds.TeamCatalogs.catalogname%></a>
            <%}

                  }
              }
            %>
            <em>&gt;</em><span class="lbrd_ltab" title="<%=teammodel.Title%>"><%=Helper.GetSubString(teammodel.Title, 28)%></span>
        </div>
    </div>
    <!--breadcrumb end-->
    <div class="w">
        <div id="product-intro" class="">
            <div id="name">
                <h1><%=teammodel.Title%></h1>
                <strong></strong>
            </div>
            <!--name end-->
            <div class="clearfix" clstag="shangpin|keycount|product|share">
                <ul id="summary">
                    <li id="summary-market">
                        <div class="dt">
                            参&nbsp;考&nbsp;价：
                        </div>
                        <div class="dd">
                            <del>
                                <%=GetMoney(teammodel.Market_price)%></del>
                        </div>
                    </li>
                    <li id="summary-price">
                        <div class="dt">
                            商&nbsp;城&nbsp;价：
                        </div>
                        <div class="dd">
                            <strong class="p-price" id="show_price">
                                <%=ASSystemArr["Currency"]%><%=GetMoney(teammodel.Team_price)%>
                            </strong>
                        </div>
                    </li>
                    <li id="summary-promotion" class="hide" style="display: list-item;">
                        <div class="dt">
                            促销信息：
                        </div>
                        <div class="dd">
                            <div id="promotions-orgin">
                                <em class="hl_red_bg">直降</em><em class="hl_red" id="youhui">已优惠<%=ASSystemArr["Currency"]%><%=GetMoney(Helper.GetDecimal(teammodel.Market_price, 0) - Helper.GetDecimal(teammodel.Team_price, 0))%>
                                </em>
                                <br />
                            </div>
                        </div>
                    </li>
                    <!-- 促销-->
                    <li id="summary-grade">
                        <div class="dt">
                            商品信息：
                        </div>
                        <div class="dd">
                            已售出<em><%=teammodel.Now_number%></em>件
                            <%if (dt_pinglun != null && dt_pinglun.Count > 0)
                              {%>
                            <a href="#coms" id="pinlun" style="float: left;" onmouseover="$('#comment-0').attr('style','display:block')">
                                (已有<%=dt_pinglun.Count%>人评价)</a>
                            <%}%>
                        </div>
                    </li>
                    <!-- 商品评分-->
                    <li id="summary-service" class="hide" style="display: list-item;">
                        <div class="dt">
                            服 务：
                        </div>
                        <div class="dd">
                            由 <span>
                            <%if (teammodel.Partner != null && teammodel.Partner.Title != null)
                              {%>
                                <%=teammodel.Partner.Title%>   
                              <%}
                              else
                              {%>
                                <%=_system["mallsitename"]%>   
                              <%} %>
                              </span>
                               发货并提供售后服务
                            <%if (teammodel.cashOnDelivery == "1")
                              { %>
                            ，支持货到付款。
                            <%}
                              else
                              {
                            %>
                            ，不支持货到付款。
                            <%} %>
                        </div>
                    </li>
                    <li id="summary-tips" class="hide">
                        <div class="dt">
                            温馨提示：
                        </div>
                        <div class="dd">
                        </div>
                    </li>
                    <li id="summary-gifts" class="hide">
                        <div class="dt">
                            赠 品：
                        </div>
                        <div class="dd">
                        </div>
                    </li>
                    <li id="summary-promotion-extra" class="none">
                        <div class="dt">
                            促销信息：
                        </div>
                        <div class="dd">
                        </div>
                    </li>
                </ul>
                <!--summary end-->
                <!--brand-bar-->
                <ul id="choose" clstag="shangpin|keycount|product|choose">
                    <%if (teammodel.bulletin != null && teammodel.bulletin.ToString().Replace("{", "").Replace("}", "") != "")
                      {%>
                    <%=Getfont1(int.Parse(teammodel.Id.ToString()), teammodel.bulletin.ToString())%>
                    <li id="choose-amount">
                        <div class="dt">
                            购买数量：
                        </div>
                        <div class="dd">
                            <div class="wrap-input">
                                <a class="btn-reduce" id="decreasenum" href="javascript:void(0)">减少数量</a><a class="btn-add"
                                    id="increasenum" href="javascript:void(0)">增加数量</a><input id="quantitynum" class="text"
                                        value="1" onkeyup="checksum();" />
                            </div>
                        </div>
                    </li>
                    <%} %>
                    <script type="text/javascript">
                            var open_invent=<%=teammodel.open_invent.ToString()%>;
                            var inventory=<%=teammodel.inventory.ToString()%>;
                            jQuery("#decreasenum").click(function () {
                                var oldnum = parseInt(jQuery("#quantitynum").val());
                                if (oldnum <= 1) {
                                    return;
                                }
                                var newnum = oldnum - 1;
                                jQuery("#quantitynum").val(newnum);
                            });
                            jQuery("#increasenum").click(function () {
                                var oldnum = parseInt(jQuery("#quantitynum").val());
                                if(open_invent=="1"&&inventory=="0")
                                {
                                    alert('库存不足！');
                                    return;
                                }
                                if (open_invent=="1"&&oldnum >= inventory) {
                                    alert("最大数量不超过"+ inventory+"个");
                                    return;
                                }
                                var newnum = oldnum + 1;
                                jQuery("#quantitynum").val(newnum);
                            });
                            function checksum()
                            {
                                var qsum= jQuery("#quantitynum").val();
                                if(open_invent=="1"&&qsum>inventory)
                                { jQuery('#quantitynum').val(inventory)
                                    jQuery('#carttip').text('当前库存'+inventory+'个');
                                    this.value=inventory;
                                }
                                else
                                {
                                    jQuery('#carttip').text('');
                                }
                                var regNum = /^\d*$/;
                                if (!regNum.test(qsum)) {
                                    if((open_invent=="1"&&inventory>0)||open_invent=="0")
                                        jQuery('#quantitynum').val('1');
                                    else
                                        jQuery('#quantitynum').val('0');
                                    alert("请输入数字");
                                }
                            }
                            var rule = "<%=GetMoney(teammodel.Team_price)%>";
                            //attrnameid:规格id attrnanevalue:规格名称   attrvalueid：规格值id attrvalue:规格值
                            function setattrvalue1(attrnameid, attrnanevalue, attrvalueid, attrvalue) {
                                for(var i=0;i<attrnameid+1;i++)
                                {
                                    $("#greyspan0_"+attrnameid).attr("class", "item");
                                }
                                $("#s_attr_name" + attrnameid).html("<font style=\" color:#c00\">已选择：<b >”"+attrvalue+"”</b></font>");
                                $("#attr_value_" + attrnameid).val(attrnanevalue);
                                var redspan = $("#redspan" + attrnameid).val();
                                if (redspan != null && redspan != "" && redspan != attrvalue) {
                                    $("[name='greyspan" + attrnameid + "']").attr("class", "item");
                                }
                                $("#greyspan" + attrvalueid + "_" + attrnameid).attr("class", "item selected");
                                $("#redspan" + attrnameid).val(attrvalue);
                                if (attrnanevalue != null) {
                                    var attrname = $("#hidattrname").val();
                                    //处理规格字符串
                                    if (attrname.indexOf(attrnanevalue) >= 0) {
                                        //找到规格，替换此规格值
                                        var newattrnames = "";
                                        var attrnames = attrname.split(",");
                                        for (i = 0; i < attrnames.length; i++) {
                                            if (attrnames[i] != "") {
                                                if (attrnames[i].indexOf(attrnanevalue) >= 0) {

                                                    newattrnames = newattrnames + "," + attrnanevalue + ":[" + attrvalue + "]";
                                                }
                                                else {
                                                    newattrnames = newattrnames + "," + attrnames[i];
                                                }
                                            }
                                        }
                                        $("#hidattrname").val(newattrnames.substring(1));
                                    }
                                    else {
                                        //不存在此规格，将规格添加到字符串中
                                        var hidattrname = attrname + "," + attrnanevalue + ":[" + attrvalue + "]";
                                        $("#hidattrname").val(hidattrname);
                                    }                    
                                }
                                //判断用户是否选择全了规格
                                var attrvales = $("#hidattrvale").val();  
                                var result = $("#hidattrname").val();
                                var c_reslut=result.split(',');
                                var falg="0";
                                var c_str="";
                                for(var i=0;i<c_reslut.length;i++)
                                {
                                    c_str+=c_reslut[i].split(':')[0]+",";
                                }
                                if (c_str.indexOf(attrvales)>-1)
                                {
                                    falg="1";
                                }
                                if(falg=="1")//选择全了规格
                                {  
                                    if (result.substring(0, 1) == ",") {
                                        result = result.substring(1);
                                    }
                                    if ('<%=shopteam.invent_result%>' != "" & result!= "")
                                    {
                                        var oldrulemo=new Array();
                                        oldrulemo = '<%=shopteam.invent_result%>'.replace("{", "").replace("}", "").split('|');
                                        for (var i = 0; i < oldrulemo.length; i++)
                                        {
                                            if(oldrulemo[i].indexOf(result)>=0)
                                            {
                                                rule = oldrulemo[i];
                                            }
                                        }
                                        if(rule.indexOf("价格")>=0)
                                        {
                                            rule=rule.substring(0,rule.lastIndexOf(','));
                                            rule=rule.substring(rule.lastIndexOf(',')).replace(",", "").replace("价格", "").replace(":", "").replace("[", "").replace("]", "");
                                        }
                                        else
                                        {
                                            rule='<%=shopteam.Team_price %>';
                                        }
                                    }
                                    if(rule!="")
                                    {
                                        $("#show_price").html("<%=ASSystemArr["Currency"]%>"+rule.substring(0,rule.indexOf(".") + 3));
                                        var youhuimoney='<%=GetMoney(teammodel.Market_price) %>';
                                        var resultmoney=youhuimoney-rule;
                                        $("#youhui").html("已优惠<%=ASSystemArr["Currency"]%>"+resultmoney.substring(0,resultmoney.indexOf(".") + 3));
                                    }
                                }
                            }
                            $(document).ready(function () {
                                var teamid = $("#hidteamid").val();
                                var num = $("#quantitynum").val();
                                $("#addshopcar").click(function () {
                                    $.ajax({
                                        type: "POST",
                                        url: webroot + "ajax/car.aspx?id=" + teamid + "&type=mall",
                                        success: function (msg) {
                                            location.href = '<%=GetUrl("京东购物车列表", "mall_jdcart.aspx")%>';
                                        }
                                    });
                                });
                                $("#shopcar").click(function () {
                                    var result = $("#hidattrname").val();
                                    var num = $("#quantitynum").val();
                                    if (parseInt(num) < 1) {
                                        alert("数量不能小于1");
                                        $("#quantitynum").val("1");
                                        return;
                                    }
                                    if (result == "") {
                                        alert("请您选择规格");
                                        return;
                                    }
                                    if (result.substring(0, 1) == ",") {
                                        result = result.substring(1);
                                    }
                                    //判断用户选择的规格是否正确
                                    var attrvales = $("#hidattrvale").val();
                                    if (attrvales != "") {
                                        var _attrvales = attrvales.split(",");
                                        for (i = 0; i < _attrvales.length; i++) {
                                            if (_attrvales[i] != "") {
                                                if (result.indexOf(_attrvales[i]) < 0) {
                                                    alert("请选择" + _attrvales[i]);
                                                    return;
                                                }
                                            }
                                        }
                                    }
                                    var teamid = $("#hidteamid").val();
                                    //{颜色:[1],大小:[4],数量:[1]}
                                    var _result = "{" + result + ",数量:[" + num + "]}";
                                    X.get(webroot + 'ajax/car.aspx?action=carinfo&addteamid=' + teamid + "&num=" + num + "&result=" + encodeURIComponent(_result) + "&type=jd&a=" + Math.random());
                                });
                                $("#buynow").click(function () { 
                                    var result = $("#hidattrname").val();
                                    var num = $("#quantitynum").val();
                                    if (parseInt(num) < 1) {
                                        alert("数量不能小于1");
                                        $("#quantitynum").val("1");
                                        return;
                                    }
                                    if (result == "") {
                                        alert("请您选择规格");
                                        return;
                                    }
                                    if (result.substring(0, 1) == ",") {
                                        result = result.substring(1);
                                    }
                                    //判断用户选择的规格是否正确
                                    var attrvales = $("#hidattrvale").val();
                                    if (attrvales != "") {
                                        var _attrvales = attrvales.split(",");
                                        for (i = 0; i < _attrvales.length; i++) {
                                            if (_attrvales[i] != "") {
                                                if (result.indexOf(_attrvales[i]) < 0) {
                                                    alert("请选择" + _attrvales[i]);
                                                    return;
                                                }
                                            }
                                        }
                                    }
                                    var teamid = $("#hidteamid").val();
                                    //{颜色:[1],大小:[4],数量:[1]}
                                    var _result = "{" + result + ",数量:[" + num + "]}";
                                    X.get(webroot + 'ajax/car.aspx?action=notprice&addteamid=' + teamid + "&num=" + num + "&result=" + encodeURIComponent(_result) + "&m_rule=" + rule + "&ty=jd");
                                });
                            });
                    </script>
                    <li id="choose-btns">
                        <input type="hidden" value="<%=teammodel.Id %>" id="hidteamid" />
                        <%if ((teammodel.open_invent.ToString() == "1" && Helper.GetInt(teammodel.inventory.ToString(), 0) > 0) || teammodel.open_invent.ToString() == "0")
                          { %>
                        <%if (teammodel.invent_result != null && teammodel.invent_result.Contains("价格"))//有规格多种价格
                          {%>
                        <div id="choose-btn-append" class="btn">
                            <a class="btn-append-buynow" id="buynow" style="width: 135px;">马上购买<b></b></a>
                        </div>
                        <%}
                          else if (teammodel.bulletin != null && teammodel.bulletin.ToString() != "" && teammodel.bulletin.ToString().Replace("{", "").Replace("}", "") != "")//有规格一种价格
                          {%>
                        <div id="Div1" class="btn">
                            <a class="btn-append " id="shopcar">加入购物车<b></b></a>
                        </div>
                        <%}
                          else//没有规格
                          {%>
                        <div id="choose-btn-append" class="btn">
                            <a class="btn-append " id="addshopcar">加入购物车<b></b></a>
                        </div>
                        <%}%>
                        <%}
                          else
                          {%>
                        <div>
                            <b>该商品暂时无货，非常抱歉！</b>
                        </div>
                        <div id="Div3" class="btn disabled">
                            <a class="btn-append" id="a1">加入购物车<b></b></a>
                        </div>
                        <%}%>
                        <div id="choose-btn-easybuy" class="btn">
                        </div>
                    </li>
                    <span style="padding: 0;" id="carttip"></span>
                    <li>
                        <div class="lbrd_share" style="margin-left: 10px;">
                            <div id="ckepop">
                                <%if (Helper.GetInt(teammodel.Bonus.ToString(), 0) > 0)
                                  {%>
                                <span class="jiathis_txt">推荐好友购买返<%=teammodel.Bonus.ToString()%>元&nbsp;&nbsp;</span>
                                <%} %>
                            </div>
                        </div>
                    </li>
                    <li id="msn">
                        <div id="short-share" style="margin-left: 10px; margin-bottom: 5px; padding: 10px 0 5px 0;">
                            <div id="share-list" class="lbrd_share" clstag="shangpin|keycount|product|share">
                                <div class="share-bd">
                                    <em class="share-hd">分享到：</em>
                                    <ul class="share-list-item clearfix share-list-item-all">
                                        <li><a target="_blank" href="<%=WebUtils.Share("tsina",WWWprefix.Substring(0, WWWprefix.LastIndexOf("/"))+BaseUserControl.getTeamPageUrl(teammodel.Id,AsUser.Id.ToString()),teammodel.Title,WWWprefix.Substring(0, WWWprefix.LastIndexOf("/"))+teammodel.Image) %>"
                                            id="site-sina" title="分享到新浪微博">新浪微博</a></li>
                                        <li><a target="_blank" href="<%=WebUtils.Share("tqq",WWWprefix.Substring(0, WWWprefix.LastIndexOf("/"))+BaseUserControl.getTeamPageUrl(teammodel.Id,AsUser.Id.ToString()),teammodel.Title,WWWprefix.Substring(0, WWWprefix.LastIndexOf("/"))+teammodel.Image) %>"
                                            id="site-qzone" title="分享到腾讯微博">腾讯微博</a></li>
                                        <li><a target="_blank" href="<%=WebUtils.Share("renren",WWWprefix.Substring(0, WWWprefix.LastIndexOf("/"))+BaseUserControl.getTeamPageUrl(teammodel.Id,AsUser.Id.ToString()),teammodel.Title,WWWprefix.Substring(0, WWWprefix.LastIndexOf("/"))+teammodel.Image) %>"
                                            id="site-renren" title="分享到人人网">人人网</a></li>
                                        <li><a target="_blank" href="<%=WebUtils.Share("kaixin001",WWWprefix.Substring(0, WWWprefix.LastIndexOf("/"))+BaseUserControl.getTeamPageUrl(teammodel.Id,AsUser.Id.ToString()),teammodel.Title,WWWprefix.Substring(0, WWWprefix.LastIndexOf("/"))+teammodel.Image) %>"
                                            id="site-kaixing" title="分享到开心网">开心网</a></li>
                                        <li><a target="_blank" href="<%=WebUtils.Share("douban",WWWprefix.Substring(0, WWWprefix.LastIndexOf("/"))+BaseUserControl.getTeamPageUrl(teammodel.Id,AsUser.Id.ToString()),teammodel.Title,WWWprefix.Substring(0, WWWprefix.LastIndexOf("/"))+teammodel.Image) %>"
                                            id="site-douban" title="分享到豆瓣">豆瓣</a></li>
                                        <li><a href="<%=BaseUserControl.Share_mail(teammodel,WWWprefix,AsUser.Id.ToString(),ASSystemArr) %>"
                                            id="site-email" title="邮件分享给好友">邮件</a></li>
                                    </ul>
                                </div>
                                <div id="share-ft" class="share-ft">
                                </div>
                            </div>
                            <div class="clb">
                            </div>
                        </div>
                    </li>
                </ul>
                <!--choose end-->
                <span class="clr"></span>
            </div>
            <div id="preview">
                <div style="height:280px;width:440px;" class="jqzoom" id="spec-n1" data-widget="tab-item">
                    <img class="dynload" <%=ashelper.getimgsrc(teammodel.Image) %> style="height:280px;width:440px;" />
                </div>
            </div>
            <!--preview end-->
        </div>
        <!--product-intro end-->
    </div>
    <br />
    <div class="w">
        <div class="right">
            <!--recommend end-->
            <div id="product-detail" class="m m1" data-widget="tabs" clstag="shangpin|keycount|product|detail">
                <div class="float-nav-wrap" style="height: 31px;">
                    <div class="mt" style="height: 31px;">
                        <ul class="tab">
                            <li clstag="shangpin|keycount|product|pinfotab" data-widget="tab-item" class="curr"
                                id="shangpjs"><a href="javascript:;" id="detail-id">商品介绍</a></li>
                            <li clstag="shangpin|keycount|product|pingjiatab" data-widget="tab-item" id="coms"><a
                                href="javascript:;" id="comments-id">商品评价</a></li>
                        </ul>
                    </div>
                </div>
                <div id="product-detail1" class="mc" data-widget="tab-content">
                    <ul class="detail-list">
                        <li>商品编号：<%=teammodel.Id%></li>
                        <li title="<%=teammodel.Title %>">商品名称：<%=Helper.GetSubString(teammodel.Title, 20)%></li>
                        <%if (teammodel.TeamCategorys != null)
                          {%>
                        <li>品牌：<a><%=Helper.GetString(teammodel.TeamCategorys.Name, string.Empty)%></a></li>
                        <% } %>
                        <li>上架时间：<%=Helper.GetString(teammodel.Begin_time, string.Empty)%></li>
                        <%
                          ICategory cate = Store.CreateCategory();
                          using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                          {
                              cate = session.Category.GetByID(teammodel.City_id);
                          }
                          if (cate != null)
                          {%>
                        <li>商品产地：<%=Helper.GetString(cate.Name, string.Empty)%></li>
                        <%} %>
                        <%if (teammodel.TeamCatalogs != null)
                          {%>
                        <li>类别：<%=Helper.GetString(teammodel.TeamCatalogs.catalogname, string.Empty)%></li>
                        <%} %>
                        <%if (teammodel.Partner != null)
                          {%>
                        <li>店铺：<%=Helper.GetString(teammodel.Partner.Title, string.Empty)%></li>
                        <%} %>
                    </ul>
                    <div class="ac">
                    </div>
                    <div class="detail-content" id="no_try_record">
                        <%--本单详情开始 --%>
                        <dl>
                            <dd>
                                <%=ashelper.returnContentDetail(teammodel.Detail)%>
                            </dd>
                        </dl>
                        <%--本单详情开始 --%>
                    </div>
                </div>
                <div class="mc  hide" data-widget="tab-content" id="product-detail-4">
                </div>
            </div>
            <!--product-detail end-->
            <!--comment end-->
            <div id="comments-list" class="m" data-widget="tabs" clstag="shangpin|keycount|product|comment"
                load="true">
                <div id="comment-0" class="mc" data-widget="tab-content" style="display: none">
                    <% if (dt_pinglun != null && dt_pinglun.Count > 0)
                       {

                           int i = 0;
                           foreach (ITeam itInfo in dt_pinglun)
                           {
                               //if (i <1)
                               //{
                               IUser user = Store.CreateUser();
                               UserFilter userfilter = new UserFilter();
                               userfilter.Username = itInfo.Username;
                               using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                               {
                                   user = session.Users.Get(userfilter);

                               }
                    %>
                    <div class="item">
                        <div class="user">
                            <div class="u-icon">
                                <a>
                                    <img height="50" width="50" upin="achen0212" src="<%=teammodel.Image %>" alt="<%=teammodel.Product%>">
                                </a>
                            </div>
                            <div class="u-name">
                                <%=itInfo.Username%>
                            </div>
                            <span class="u-level"><span style="color: #088000">
                                <%if (user != null && user.LeveName != null)
                                  { %><%=user.LeveName.Name%><%} %></span></span>
                        </div>
                        <div class="i-item" data-guid="9215ac7a-d790-4bea-9f2d-63cc651c3e2b">
                            <div class="o-topic">
                                <strong class="topic"><a></a></strong><span class="">评价内容：</span><span><em></em><a
                                    class="date-comment" title="">
                                    <%=itInfo.create_time%></a></span>
                            </div>
                            <div class="comment-content">
                                <dl>
                                    <dt>内容：</dt>
                                    <dd>
                                        <%=itInfo.comment%></dd>
                                </dl>
                                <div class="dl-extra">
                                    <dl>
                                    </dl>
                                </div>
                            </div>
                            <div class="btns">
                                <div class="useful fr" id="9215ac7a-d790-4bea-9f2d-63cc651c3e2b">
                                </div>
                            </div>
                        </div>
                        <div class="corner tl">
                        </div>
                    </div>
                    <%
                                  //} 
                                  i++;
                               }
                           
                    }
                       else
                       {%>
                    <div class="clearfix">
                        <div class="fl" style="padding: 8px 0 0 120px;">
                            <strong>[暂无评价！！]</strong>
                        </div>
                        <div class="pagin fr" clstag="shangpin|keycount|product|fanye" id="commentsPage0">
                        </div>
                    </div>
                    <%} %>
                </div>
                <%if (dt_pinglun != null && dt_pinglun.Count > 0)
                  { %>
                <script type="text/javascript">
                    $(document).ready(function () {

                        var show_per_page = 10;

                        var number_of_items = '<%= dt_pinglun.Count %>';
                        var number_of_pages = Math.ceil(number_of_items / show_per_page);
                        if (number_of_items == 0) {
                            $('#page_navigation').attr('style', 'display:none');
                        }
                        $('#current_page').val(0);
                        $('#show_per_page').val(show_per_page);


                        var navigation_html = '<a class="previous_link">共' + number_of_items + '条</a><a class="previous_link" href="javascript:previous();">上一页</a>';
                        var current_link = 0;
                        while (number_of_pages > current_link) {
                            navigation_html += '<a class="page_link" href="javascript:go_to_page(' + current_link + ')" longdesc="' + current_link + '">' + (current_link + 1) + '</a>';
                            current_link++;
                        }
                        navigation_html += '<a class="next_link" href="javascript:next();">下一页</a>';

                        $('#page_navigation').html(navigation_html);

                        $('#page_navigation .page_link:first').addClass('active_page');

                        $('#comment-0').children().css('display', 'none');

                        $('#comment-0').children().slice(0, show_per_page).css('display', 'block');

                    });

                    function previous() {

                        new_page = parseInt($('#current_page').val()) - 1;
                        if ($('.active_page').prev('.page_link').length == true) {
                            go_to_page(new_page);
                        }

                    }

                    function next() {
                        new_page = parseInt($('#current_page').val()) + 1;
                        if ($('.active_page').next('.page_link').length == true) {
                            go_to_page(new_page);
                        }

                    }
                    function go_to_page(page_num) {
                        var show_per_page = parseInt($('#show_per_page').val());

                        start_from = page_num * show_per_page;

                        end_on = start_from + show_per_page;

                        $('#comment-0').children().css('display', 'none').slice(start_from, end_on).css('display', 'block');

                        $('.page_link[longdesc=' + page_num + ']').addClass('active_page').siblings('.active_page').removeClass('active_page');

                        $('#current_page').val(page_num);
                    }
  
                    </script><%} %>
                <style>
                        #page_navigation a
                        {
                            padding: 3px 10px;
                            border: 1px solid #CCCCCC;
                            margin: 2px;
                            text-decoration: none;
                        }
                        .active_page
                        {
                            background: white;
                            color: red !important;
                        }
                    </style>
                    <input type='hidden' id='current_page' />
                    <input type='hidden' id='show_per_page' />
                <div class="m clearfix">
                    <div class="pagin fr">
                        <div id='page_navigation'>
                        </div>
                    </div>
                </div>
                <div reco_id="2" class="shop-choice hide" id="shop-choice">
                </div>
                <!-- 全部 -->
            </div>
            <!--comment end-->
            <script type="text/javascript">
                $(document).ready(function () {
                    jQuery('#comments-list').hide();
                });
                jQuery('#detail-id').click(function () {
                    jQuery('#product-detail1').show(); jQuery('#shangpjs').addClass('curr'); jQuery('#coms').removeClass('curr');
                    jQuery('#comments-list').hide(); jQuery('#topic').removeClass('curr');
                });
                jQuery('#comments-id').click(function () {
                    jQuery('#product-detail1').hide(); jQuery('#comments-list').show(); jQuery('#shangpjs').removeClass('curr');
                    jQuery("#comment-0").show();
                    jQuery('#coms').removeClass('curr'); jQuery('#coms').addClass('curr');
                });
                jQuery('#pinlun').click(function () {
                    jQuery('#product-detail1').hide(); jQuery('#comments-list').show(); jQuery('#shangpjs').removeClass('curr');
                    jQuery('#coms').removeClass('curr'); jQuery('#coms').addClass('curr');
                });

            </script>
            <!--related-viewed end-->
        </div>
        <!--right end-->
        <div class="left">
            <%if (teammodel.TeamCatalogs != null && teammodel.TeamCatalogs.parent_id != 0)
              {%>
            <div id="related-sorts" class="m m2" clstag="shangpin|keycount|product|sortlist">
                <div class="mt">
                    <h2>
                        相关分类</h2>
                </div>
                <div class="mc" style="display: block;">
                    <ul class="lh">
                        <% CatalogsFilter catafilter = new CatalogsFilter();
                           IList<ICatalogs> ilistcata = null;
                           catafilter.Where = " parent_id=(select parent_id from catalogs where catalogname='" + teammodel.TeamCatalogs.catalogname + "' and type=1) and id !=" + teammodel.TeamCatalogs.id;
                           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                           {
                               ilistcata = session.Catalogs.GetList(catafilter);
                           }
                           if (ilistcata.Count > 0)
                           {
                               foreach (ICatalogs cata in ilistcata)
                               {%>
                        <li><a title="<%=cata.catalogname %>" href="<%=GetTeamListPageUrl(Helper.GetInt(cata.parent_id,0), Helper.GetInt(cata.id,0),0, 0, 0, 0,0, string.Empty)%>">
                            <%=cata.catalogname%></a></li>
                        <%
                            cataparid = Helper.GetInt(cata.parent_id, 0);
                               }
                               }%>
                    </ul>
                </div>
            </div>
            <%}%>
            <!--related-sorts end-->
            <%if (teammodel.TeamCatalogs != null && teammodel.TeamCatalogs.parent_id != 0)
              {%>
            <div id="related-brands" class="m m2" clstag="shangpin|keycount|product|samebrand">
                <div class="mt">
                    <h2>
                        同类其他品牌</h2>
                </div>
                <div class="mc">
                    <ul class="lh">
                        <% CategoryFilter catefilter = new CategoryFilter();
                           IList<ICategory> ilistcate = null;
                           catefilter.Where = " Zone='brand' and Id in (select brand_id from Team where cataid=" + teammodel.cataid + ")";
                           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                           {
                               ilistcate = session.Category.GetList(catefilter);
                           }
                           if (ilistcate.Count > 0)
                           {
                               foreach (ICategory cates in ilistcate)
                               {%>
                        <li><a title="<%=cates.Name %>" href="<%=GetTeamListPageUrl( cataparid, 0,0, Helper.GetInt(cates.Id,0), 0, 0,0, string.Empty)%>">
                            <%=cates.Name%></a></li>
                        <% }
                               }%>
                    </ul>
                </div>
            </div>
            <%}%>
            <!--related-brands end-->
            <%if (dto != null && dto.Count > 0)
              {%>
            <div id="buy-buy" class="m m2 related-buy" style="display: block;">
                <div class="mt">
                    <h2>
                        同类热销排行</h2>
                </div>
                <div class="mc">
                    <ul>
                        <%
                      int i = 1;
                      foreach (ITeam tInfo in dto)
                      {
                          i++;
                          
                        %>
                        <li class="fore<%=i %>">
                            <div class="p-img" style="height: 100px">
                                <a target="_blank" title="<%=Helper.GetString(tInfo.Title,string.Empty)%>" href="<%=getTeamPageUrl(tInfo.Id)%>">
                                    <img height="100" src="<%=tInfo.Image %>" alt="<%=Helper.GetString(tInfo.Title,string.Empty)%> " /></a>
                            </div>
                            <div class="p-name">
                                <a target="_blank" title="<%=Helper.GetString(tInfo.Title,string.Empty)%>" href="<%=getTeamPageUrl(tInfo.Id)%>">
                                    <%=Helper.GetSubString(tInfo.Title, 28)%></a>
                            </div>
                            <div class="p-price">
                                <strong>
                                    <%=ASSystem.currency%><%=GetMoney(tInfo.Team_price)%>
                                </strong>
                            </div>
                        </li>
                        <% } %>
                    </ul>
                </div>
            </div>
            <%} %>
            <!--buy-buy end-->
            <!--browse-browse end-->
            <!--ad-area end-->
        </div>
        <!--left end-->
        <span class="clr"></span>
    </div>
<%--    <script type="text/javascript">
        jQuery(function () {
            jQuery(".jqzoom").jqueryzoom({
                xzoom: 400,
                yzoom: 400,
                offset: 10,
                position: "right",
                preload: 1,
                lens: 1
            });

        })
    </script>--%>
    <%}
      else
      {%>
    <div style="text-align: center; min-height: 500px;">
        没有找到该商品，请看看别的商品吧！
    </div>
    <%}%>
    <script type="text/javascript" src="<%=PageValue.WebRoot %>upfile/js/jdlib-v1.js"></script>
    <script type="text/javascript" src="<%=PageValue.WebRoot %>upfile/js/jdhome.js"></script>
    <div class="w">
        <div id="service-2013">
            <dl class="fore1" clstag="homepage|keycount|home2012|33a">
                <dt><b></b><strong></strong></dt>
                <dd>
                    <div>
                        <a href="<%=GetUrl("玩转东购团","help_tour.aspx")%>">玩转<%=abbreviation%></a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("常见问题","help_faqs.aspx")%>">常见问题</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("东购团概念","help_asdht.aspx")%>">
                            <%=abbreviation%>概念</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("开发API","help_api.aspx")%>">开发API</a>
                    </div>
                </dd>
            </dl>
            <dl class="fore2" clstag="homepage|keycount|home2012|33b">
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
                    <div>
                        <a href="<%=ASSystem.sinablog %>" target="_blank">新浪微博</a>
                    </div>
                    <%} %>
                    <%if (ASSystem.qqblog != "")
                      {%>
                    <div>
                        <a href="<%=ASSystem.qqblog %>" target="_blank">腾讯微博</a>
                    </div>
                    <%} %>
                </dd>
            </dl>
            <dl class="fore4" clstag="homepage|keycount|home2012|33d">
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
                      {
                    %>
                    <a href="<%=WebRoot%>mall/index.aspx">
                        <%if (_system != null && _system["mallfootlogo"] != null && _system["mallfootlogo"].ToString() != "")
                          {
                        %>
                        <img src="<%=_system["mallfootlogo"].ToString() %>" />
                        <%  
                              }
                          else
                          {
                        %>
                        <img src="<%=PageValue.WebRoot %>upfile/img/mall_logo.png" />
                        <%
                              } %>
                    </a>
                    <%
                          }
                      else
                      { 
                    %>
                    <a href="<%=WebRoot%>index.aspx">
                        <img src="<%=footlogo %>" /></a>
                    <%
                          } %>
                </div>
            </div>
            <span class="clr"></span>
        </div>
    </div>
    <!-- service end -->
    <div class="w">
        <div id="footer-2013">
            <div class="copyright">
                &copy;<span>2010</span>&nbsp;<%=sitename
                %>（<%=WWWprefix %>）版权所有&nbsp;<a href="<%=GetUrl("用户协议","about_terms.aspx")%>">使用<%=abbreviation
                %>前必读</a>&nbsp;<a href="http://www.miibeian.gov.cn/" target="_blank"><%=icp %></a>&nbsp;&nbsp;<%=statcode
                %><br />
                &nbsp;Powered by ASdht(<a target="_blank" href="http://www.asdht.com">艾尚团购系统程序</a>)
                Software V_<%=ASSystemArr["siteversion"] %>
            </div>
        </div>
    </div>
    <!-- footer end -->
    </form>
</body>
</html>
