<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>

<script runat="server">
    protected NameValueCollection _system = new NameValueCollection();
    protected IList<ILocation> iListLocation = null;
    protected IList<ILocation> iListLocationsider = null;//侧栏广告
    protected IList<ITeam> iListTeamNew = null;
    protected IList<ITeam> iListTeamHot = null;
    protected IList<ITeam> iListTeamStar = null;
    protected IList<ITeam> iListTeamLow = null;
    protected IList<INews> iListNews = null;

    public override void UpdateView()
    {
        _system = WebUtils.GetSystem();
        iListLocation = getAdd(0, 1);//得到首页广告
        iListLocationsider = getAdd(0, 2);//得到3条侧栏广告信息
        iListTeamNew = getHostTeam(1);//显示新品上架下面的项目
        iListTeamHot = getHostTeam(2);//显示热销下面的项目
        iListTeamStar = getHostTeam(3);//显示明星产品下面的项目
        iListTeamLow = getHostTeam(4);//显示低价促销下面的项目
        getNews();
    }

    /// <summary>
    /// 得到商城新闻
    /// </summary>
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

    /// <summary>
    /// 得到推荐产品
    /// </summary>
    private IList<ITeam> getHostTeam(int type)
    {
        IList<ITeam> iListTeam = null;
        TeamFilter teamfilter = new TeamFilter();
        teamfilter.teamcata = 1;
        teamfilter.mallstatus = 1;
        teamfilter.teamhost = type;
        //teamfilter.AddSortOrder(TeamFilter.Sort_Order_DESC);
        teamfilter.AddSortOrder(TeamFilter.MoreSort);
        teamfilter.Top = 10;
        if (_system["recommendnum"] != null && _system["recommendnum"].ToString() != "" && _system["recommendnum"].ToString() != "0")
        {
            teamfilter.Top = int.Parse(_system["recommendnum"].ToString());
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListTeam = session.Teams.GetList(teamfilter);
        }
        return iListTeam;
    }

    /// <summary>
    /// 得到广告信息
    /// </summary>
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

    public override string CacheKey
    {
        get
        {
            int cityid = 0;
            if (CurrentCity != null)
                cityid = CurrentCity.Id;
            return "cacheusercontrol-malltop";
        }
    }
    public override bool CanCache
    {
        get
        {
            return true;
        }
    }
</script>

<div class="bmt_pbly">


    <%if (iListLocation != null && iListLocation.Count > 0)
      {
    %>
    <script src="/upfile/js/jquery.KinSlideshow-1.2.1.min.js" type="text/javascript"></script>
    <div id="picBox">
        <ul id="show_pic" style="top: 0;">

            <% foreach (ILocation ilocationInfo in iListLocation)
               {
            %>

            <li><a href="<%=ilocationInfo.pageurl %>" target="_blank">
                <img src="<%=ilocationInfo.locationname %>" alt="<%=ilocationInfo.width %>" width="736" height="298" /></a></li>
            <%
               } %>
        </ul>
        <ul id="icon_num">
            <%for (int i = 0; i < iListLocation.Count; i++)
              {
            %>
            <li <%if (i == 0)
                  { %>class="active"
                <% } %>><%=i+1 %></li>
            <%
              } %>
        </ul>
        <script type="text/javascript">
            glide.layerGlide(true, 'icon_num', 'show_pic', 304, 3, 0.2, 'top'); //742
        </script>
    </div>

    <% 
      } %>






    <div class="fl bm_sortly">
        <ul id="hotlist-div" class="fl bm_htpctit">
            <li id="star" onmouseover="show(this,'new_star')"><a class="" href="javascript:void(0);" class="bm_htpccur">推荐商品</a></li>
            <li id="new" onmouseover="show(this,'new_new')"><a href="javascript:void(0)">新品上架</a></li>
            <li id="hot" onmouseover="show(this,'new_hot')"><a href="javascript:void(0);" class="">热销产品</a></li>
            <li style="border-right: 0px;" id="slow" onmouseover="show(this,'new_slow')"><a href="javascript:void(0);" class="">低价促销</a></li>
        </ul>


        <!--新品上架开始-->

        <%if (iListTeamNew != null && iListTeamNew.Count > 0)
          { 
        %>
        <div class="clear">
            <ul id="new_new" class="fl bm_htpc" style="display: none;">


                <% foreach (ITeam iteamInfo in iListTeamNew)
                   {
                %>
                <li>
                    <a href="<%=getGoodsPageUrl(Helper.GetString(_system["isrewrite"], "0"),iteamInfo.Id )  %>" title="<%=iteamInfo.Product %>" target="_blank">

                        <img style="width: 154px; height: 98px;" <%=ashelper.getimgsrc(iteamInfo.Image.ToString())%> alt="<%=iteamInfo.Product %>" class="dynload">
                    </a>
                    <div style="width: 156px;" class="fl bm_htpcbuy">
                        <span>
                            <label class="arial"><%=ASSystem.currency%></label>
                            <em><%=GetMoney(iteamInfo.Team_price)%></em></span>
                        <a onclick="asdhtMall.addCart('<%=iteamInfo.Id %>');" class="fl bm_htpcadd" title="<%=iteamInfo.Product %>" href="javascript:void(0);"></a>
                    </div>
                    <div class="clear fl bm_htpcbuy">
                        <a href="<%=getGoodsPageUrl(Helper.GetString(_system["isrewrite"], "0"),iteamInfo.Id )  %>" title="<%=iteamInfo.Product %>" target="_blank"><%=iteamInfo.Title%></a>
                    </div>
                </li>

                <%
     
                   } %>
            </ul>
        </div>
        <%
          } %>
        <!--新品上架结束-->


        <!--推荐商品开始-->
        <%if (iListTeamStar != null && iListTeamStar.Count > 0)
          {
    
        %>

        <div class="clear">
            <ul id="new_star" class="fl bm_htpc" style="display: block;">

                <%foreach (ITeam iteamInfoStar in iListTeamStar)
                  {
                %>
                <li>
                    <a href="<%=getGoodsPageUrl(Helper.GetString(_system["isrewrite"], "0"),iteamInfoStar.Id )  %>" title="<%=iteamInfoStar.Product %>" target="_blank">


                        <img style="width: 154px; height: 98px;" <%=ashelper.getimgsrc(iteamInfoStar.Image.ToString())%> alt="<%=iteamInfoStar.Product %>" class="dynload">
                    </a>
                    <div style="width: 156px;" class="fl bm_htpcbuy">
                        <span>
                            <label class="arial"><%=ASSystem.currency%></label>
                            <em><%=GetMoney(iteamInfoStar.Team_price)%></em></span>
                        <a onclick="asdhtMall.addCart('<%=iteamInfoStar.Id %>');" title="<%=iteamInfoStar.Product %>" class="fl bm_htpcadd" href="javascript:void(0);"></a>
                    </div>
                    <div class="clear fl bm_htpcbuy">
                        <a href="<%=getGoodsPageUrl(Helper.GetString(_system["isrewrite"], "0"),iteamInfoStar.Id )  %>" title="<%=iteamInfoStar.Product %>" target="_blank"><%=iteamInfoStar.Title%></a>
                    </div>
                </li>

                <%
                  }
                %>
            </ul>
        </div>

        <%
          }%>
        <!--推荐商品结束-->



        <!--热销产品开始-->
        <%if (iListTeamHot != null && iListTeamHot.Count > 0)
          {
        %>

        <div class="clear">
            <ul id="new_hot" class="fl bm_htpc" style="display: none;">


                <%foreach (ITeam iteamInfoHot in iListTeamHot)
                  {
                %>
                <li>
                    <a href="<%=getGoodsPageUrl(Helper.GetString(_system["isrewrite"], "0"),iteamInfoHot.Id )  %>" title="<%=iteamInfoHot.Product %>" target="_blank">

                        <img style="width: 154px; height: 98px;" <%=ashelper.getimgsrc(iteamInfoHot.Image.ToString())%> alt="<%=iteamInfoHot.Product %>" class="dynload">
                    </a>
                    <div style="width: 156px;" class="fl bm_htpcbuy">
                        <span>
                            <label class="arial"><%=ASSystem.currency%></label>
                            <em><%=GetMoney(iteamInfoHot.Team_price)%></em></span>
                        <a onclick="asdhtMall.addCart('<%=iteamInfoHot.Id %>');" title="<%=iteamInfoHot.Product %>" class="fl bm_htpcadd" href="javascript:void(0);"></a>
                    </div>
                    <div class="clear fl bm_htpcbuy">
                        <a href="<%=getGoodsPageUrl(Helper.GetString(_system["isrewrite"], "0"),iteamInfoHot.Id )  %>" title="<%=iteamInfoHot.Product %>" target="_blank"><%=iteamInfoHot.Title%></a>
                    </div>
                </li>

                <%
                  }
                %>
            </ul>
        </div>
        <%
          }
        %>


        <!--热销产品结束-->


        <!--低价促销开始-->
        <%if (iListTeamLow != null && iListTeamLow.Count > 0)
          {
        %>
        <div class="clear">
            <ul id="new_slow" class="fl bm_htpc" style="display: none;">
                <%foreach (ITeam iteamInfoLow in iListTeamLow)
                  {
                %>
                <li>
                    <a href="<%=getGoodsPageUrl(Helper.GetString(_system["isrewrite"], "0"),iteamInfoLow.Id )  %>" title="<%=iteamInfoLow.Product %>" target="_blank">

                        <img style="width: 154px; height: 98px;" <%=ashelper.getimgsrc(iteamInfoLow.Image.ToString())%> alt="<%=iteamInfoLow.Product %>" class="dynload">
                    </a>
                    <div style="width: 156px;" class="fl bm_htpcbuy">
                        <span>
                            <label class="arial"><%=ASSystem.currency%></label>
                            <em><%=GetMoney(iteamInfoLow.Team_price)%></em></span>
                        <a onclick="asdhtMall.addCart('<%=iteamInfoLow.Id %>');" title="<%=iteamInfoLow.Product %>" class="fl bm_htpcadd" href="javascript:void(0);"></a>
                    </div>
                    <div class="clear fl bm_htpcbuy">
                        <a href="<%=getGoodsPageUrl(Helper.GetString(_system["isrewrite"], "0"),iteamInfoLow.Id )  %>" title="<%=iteamInfoLow.Product %>" target="_blank"><%=iteamInfoLow.Title%></a>
                    </div>
                </li>

                <%
                  }
                %>
            </ul>
        </div>
        <%
          }%>

        <!--低价促销结束-->

    </div>

</div>






<script language="javascript" type="text/javascript">

    function show(object, divname) {
        jQuery('#new_new').hide(); jQuery('#new').children('a').removeClass('bm_htpccur');
        jQuery('#new_hot').hide(); jQuery('#hot').children('a').removeClass('bm_htpccur');
        jQuery('#new_star').hide(); jQuery('#star').children('a').removeClass('bm_htpccur');
        jQuery('#new_slow').hide(); jQuery('#slow').children('a').removeClass('bm_htpccur');
        jQuery(object).children('a').addClass('bm_htpccur');
        $("#" + divname).show();
    }


</script>


<div class="fr">


    <!--新闻开始-->

    <%if (iListNews != null && iListNews.Count > 0)
      { 
    %>
    <div class="bm_seckill">
        <div class="bm_secktit">
            <h3>新闻<span class="EG">News</span></h3>
        </div>
        <ul class="Mnews">
            <%foreach (INews inewsInfo in iListNews)
              {
                  if (inewsInfo.link != null && inewsInfo.link != "")
                  {
            %>
            <li><a target="_blank" href="<%=inewsInfo.link %>">• <%=inewsInfo.title%></a></li>
            <%
                  }
                  else
                  {
            %>
            <li><a target="_blank" href="<%=GetUrl("新闻","usercontrols_newlist.aspx?id="+inewsInfo.id)%>">• <%=inewsInfo.title%></a></li>

            <% 
              }
            %>

            <%
              } %>
        </ul>
        <div class="more_nw"><a target="_blank" href="<%=GetUrl("新闻公告", "usercontrols_Morenewlist.aspx?type=1")%>">去看看更多新闻</a></div>
    </div>

    <%
      } %>


    <!--新闻结束-->


    <!--特卖精品-->
    <%if (CurrentTeam != null)
      { 
    %>
    <div class="bm_tdy">
        <div class="fl bm_tdytit">
            <h3><span class="red">今日</span>团购<span class="EG">HotSale</span></h3>
        </div>
        <a target="_blank" href="<%=getTeamPageUrl(CurrentTeam.Id) %>">
            <img title="<%=CurrentTeam.Title %>" alt="<%=CurrentTeam.Title %>" <%=ashelper.getimgsrc(CurrentTeam.Image.ToString())%> class="dynload" style="height: 141px; width: 221px; padding: 6px;"></a>

        <div class="title">
            <b>现价：<%=ASSystem.currency%><%=CurrentTeam.Team_price%></b><p class="old_pr">原价：<%=ASSystem.currency%><%=CurrentTeam.Market_price%></p>
        </div>
        <a class="Buy_bot" href="<%=getTeamPageUrl(CurrentTeam.Id) %>"></a>

    </div>

    <%
      
      } %>


    <!--右侧广告信息开始-->
    <%if (iListLocationsider != null && iListLocationsider.Count > 0)
      { 
    %>
    <div class="bm_pbleft">



        <%foreach (ILocation ilocationInfo in iListLocationsider)
          { 
        %>
        <div class="fl bm_ad1 bm_ad2">
            <a href="<%=ilocationInfo.pageurl %>" target="_blank">
                <%=ilocationInfo.locationname%>
            </a>
        </div>
        <%
          } %>
    </div>
    <%
      } %>
</div>
<div class="clear"></div>
