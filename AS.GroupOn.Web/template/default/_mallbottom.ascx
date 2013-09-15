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
    
    public NameValueCollection _system = new NameValueCollection();
    protected IList<ICatalogs> iListCatalogs = null;
    
    public override void UpdateView()
    {
        _system = WebUtils.GetSystem();

        iListCatalogs = getCata("center");//得到中间商品项目父分类
    }

    /// <summary>
    /// 得到分类
    /// </summary>
    protected IList<ICatalogs> getCata(string type)
    {
        int top = 0;
        IList<ICatalogs> iListCatalogsds = null;

        //后台设置中读取配置文件中的
        if (_system["listcatanum"] != null && _system["listcatanum"].ToString() != "")
        {
            top = int.Parse(_system["listcatanum"].ToString());
        }
        else
        {
            top = 5;
        }

        iListCatalogsds = GethostCataMall(top, 0, 2);
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
                if (location == 2)
                {
                    catalogsfilter.LocationOr = 2;
                }
            }
        }
        else
        {
            if (cityid == 0)
            {
                if (location == 2)
                {
                    catalogsfilter.Top = top;
                    catalogsfilter.LocationOr = 2;
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
    /// 根据分类得到商城项目
    /// </summary>
    /// <param name="cataid"></param>
    protected IList<ITeam> getMallTeamByCataid(int cataid)
    {
        string cid = getChildCataidByCateid(cataid);

        IList<ITeam> iListTeam = null;
        TeamFilter teamfilter = new TeamFilter();
        teamfilter.teamcata = 1;
        teamfilter.mallstatus = 1;
        teamfilter.Top = 6;
        teamfilter.AddSortOrder(TeamFilter.MoreSort);
        
        if (cid != "")
        {
            teamfilter.CataIDin = cid;
        }

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListTeam = session.Teams.GetList(teamfilter);
        }
        return iListTeam;
    }

    /// <summary>
    /// 根据分类id 得到分类下面的品牌
    /// </summary>
    /// <param name="cateid"></param>
    protected IList<ITeam> getBrandByCate(int cateid)
    {
        string cid = getChildCataidByCateid(cateid);

        IList<ITeam> iListTeam = null;
        TeamFilter teamfilter = new TeamFilter();
        teamfilter.teamcata = 1;
        teamfilter.mallstatus = 1;
        teamfilter.BrandIDNotZero = 0;
        teamfilter.CataIDin = cid;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListTeam = session.Teams.GetBrandId(teamfilter);
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
            {
                cid = icatalogs.ids + "," + cateid;
            }
            else
            {
                cid = cateid.ToString();
            }
        }
        return cid;
    }

    /// <summary>
    /// 得到各分类下的热销项目
    /// </summary>
    /// <param name="cateid"></param>
    protected IList<ITeam> getHotTeambyCate(int cateid)
    {
        string cid = getChildCataidByCateid(cateid);
        
        IList<ITeam> iListTeam = null;
        TeamFilter teamfilter = new TeamFilter();
        teamfilter.teamcata = 1;
        teamfilter.mallstatus = 1;
        teamfilter.Top = 4;
        teamfilter.AddSortOrder(TeamFilter.MoreSort2);

        if (cid != "")
        {
            teamfilter.CataIDin = cid;
        }

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListTeam = session.Teams.GetList(teamfilter);
        }
        return iListTeam;
    }
    
    public override string CacheKey
    {
        get
        {
            int cityid = 0;
            if (CurrentCity != null)
                cityid = CurrentCity.Id;
            return "cacheusercontrol-mallbottom";
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


<!--分类项目开始-->
<%if (iListCatalogs != null && iListCatalogs.Count > 0)
  {

      int i = 0;
      foreach(ICatalogs icatalogsInfo in iListCatalogs)
      {
          i++;
           IList<ITeam> _teamlistbyCate = getMallTeamByCataid(icatalogsInfo.id);
%>
<div class="bm_pbly">
    <div class="fl bm_bigtit">
        <div class="fl bm_sottit bm_sottit3">
            <h3>
                 <%=i %>F<span class="red"><%=icatalogsInfo.catalogname%></span><span class="EG"></span></h3>
        </div>
        <div class="hotrank">
            热销排行榜</div>
        <div class="fr bm_smore">
            <a  title="<%=icatalogsInfo.catalogname%>" href="<%=getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), icatalogsInfo.id,0, 0,"0","0") %>"
                target="_blank">
                <%=icatalogsInfo.catalogname%>更多</a>
        </div>
    </div>


    <div class="fl bm_pcshow lazyimg">
        <%if (_teamlistbyCate != null && _teamlistbyCate.Count > 0)
          {
              int a = 0;
              for (int k = 0; k < _teamlistbyCate.Count; k++)
              {
                  //if (a==1)
                  //{
                  //    k = 0;
                  //}
        
                 
              
        %>
        <div <%if(a==0){%> class="lfbg" <% }else if(k==2 || k==5){%>class="rtsl" id="nl"
            <%}else{ %>class="rtsl" <%} %> onmouseover="fnOver(this)" onmouseout="fnOut(this)">
            <%if (a != 0)
               { %>
            <div class="ma_img">
                <%} %>
                     <%if(a==0){%>

                      <a href="<%=icatalogsInfo.url%>"
                      target="_blank" >
                      <img width="191" height="333"  
                      <%=ashelper.getimgsrc(icatalogsInfo.image)%> 
                     class="dynload bm_pcshowtd" alt="<%=icatalogsInfo.catalogname %>"
                        onmouseout="this.className='bm_pcshowtd'" onmouseover="this.className='bm_pcshowtdhover'"
                         style="display: block;">
                     </a>
                      <%}else{%>

                      <a href="<%=getGoodsPageUrl(Helper.GetString(_system["isrewrite"], "0"),_teamlistbyCate[k].Id )  %>"
                      title="<%=_teamlistbyCate[k].Product %>" target="_blank" >
                        <img width="176" height="121"  <%=ashelper.getimgsrc(_teamlistbyCate[k].Image.ToString()) %> 
                       alt="<%=_teamlistbyCate[k].Product %>"
                        onmouseout="this.className='bm_pcshowtd'" onmouseover="this.className='bm_pcshowtdhover'"
                        class="dynload bm_pcshowtd"  style="display: block;">
                      <%} %> 
                   </a>

                <%if (a != 0)
                  { %></div>
            <%} %>


            <%if (a != 0)
              {%>
            <h3>
                <%=_teamlistbyCate[k].Title%></h3>
            <span class="Price"><b>现价：<%=ASSystem.currency%><%=GetMoney(_teamlistbyCate[k].Team_price)%></b><span
                class="old_pr">原价：<%=ASSystem.currency%><%=GetMoney(_teamlistbyCate[k].Market_price)%></span></span>
            <%} %>


        </div>
        <% 
            a++;
            if (a == 1)
            {
                k = -1;
            }
            }

          }  %>
    </div>
    <!--分类侧栏热销商品开始-->
    <ul id="bm_slist<%=icatalogsInfo.id %>" class="fl bm_slist">
        <%
            IList<ITeam> _teamlist = getHotTeambyCate(icatalogsInfo.id);

if (_teamlist != null && _teamlist.Count > 0)
{
    int j = 0;
    foreach(ITeam iteamInfoHot in _teamlist)
       {
        %>
        <li><span class="bm_slnum">
            <%=j + 1 %></span><a class="bm_slname" title="<%=iteamInfoHot.Product%>" href="<%=getGoodsPageUrl(Helper.GetString(_system["isrewrite"], "0"),iteamInfoHot.Id )  %>"
                target="_blank"><%=iteamInfoHot.Title%></a>
            <div id="bm_slimg<%=iteamInfoHot.Id %>" class="bm_slimg" <%if(j==0){%>style="display: block;"
                <%}else{%>style="display: none;" <%} %>>
                <a target="_blank" href="<%=getGoodsPageUrl(Helper.GetString(_system["isrewrite"], "0"),iteamInfoHot.Id )  %>">
                    <img width="220" height="140" <%=ashelper.getimgsrc(iteamInfoHot.Image.ToString())%> alt="<%=iteamInfoHot.Product %>"
                        class="dynload" style="overflow: hidden;"></a>
                <h3>
                    <%=iteamInfoHot.Title%></h3>
                <span class="Price"><b>现价：<%=ASSystem.currency%><%=GetMoney(iteamInfoHot.Team_price)%></b><span
                    class="old_pr">原价：<%=ASSystem.currency%><%=GetMoney(iteamInfoHot.Market_price)%></span></span>
            </div>
        </li>
        <!--{/if}-->
        <%j++;
}
       }
        %>
    </ul>
    <!--分类侧栏热销商品结束-->
    <script type="text/javascript">
            asdhtMall.siderHover(<%=icatalogsInfo.id %>);
    </script>
    <!--相关品牌开始-->
    <%IList<ITeam> iListTeamdt = getBrandByCate(icatalogsInfo.id);

      if (iListTeamdt != null && iListTeamdt.Count > 0)
      {
    %>
    <div class="oth_brd">
        <div class="othbd_tit">
            相关品牌</div>
        <ul class="othbd_ul">
            <%foreach (ITeam iteaminfodt in iListTeamdt)
              {
                  if (iteaminfodt.TeamCategorys != null && iteaminfodt.TeamCategorys.content != null && iteaminfodt.TeamCategorys.content != "")
                  {
            %>
            <li><a target="_blank" title="<%=iteaminfodt.TeamCategorys.Name %>" href="<%=getGoodsCatalistPageUrl(Helper.GetString(_system["isrewrite"], "0"), icatalogsInfo.id, int.Parse(iteaminfodt.brand_id.ToString()), 0,"0","0") %>">
                <img <%=ashelper.getimgsrc(ImageHelper.good_getSmallImgUrl(iteaminfodt.TeamCategorys.content.ToString(),80,30))%> alt="<%=iteaminfodt.TeamCategorys.Name %>" class="dynload"
                    style="height: 30px; width: 80px;"></a></li>
            <%  
                }

              } %>
        </ul>
        <div class="othbd_more">   
           <a title="更多品牌" href="<%=getBrandPageUrl(Helper.GetString(_system["isrewrite"], "0"))%>">
                更多品牌</a>
                </div>
    <div class="clear">
    </div>
    <div class="clear">
    </div>
    </div>
    <%
                      
}
    %>
    <!--相关品牌结束-->
    <div class="clear">
    </div>
    <div class="clear">
    </div>

</div>
<%
    }
          }%>
<!--分类项目结束-->
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