<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
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
    public string ids = String.Empty;
    public IList<ICatalogs> catafatherlist = null;//查询全部的父类
    public IList<ICatalogs> cata19list = null;//查询精品团购
    string detail = "";
    string where = "1=1";
    protected bool over = false;
    protected NameValueCollection order = new NameValueCollection();
    protected NameValueCollection team = new NameValueCollection();
    protected NameValueCollection user = new NameValueCollection();
    protected NameValueCollection partner = new NameValueCollection();
    protected int size = 0;
    protected int offset = 0;
    protected int imageindex = 2;
    protected int teamid = 0;
    new protected ITeam CurrentTeam = null;
    protected int twoline = 0;
    protected long curtimefix = 0;
    protected long difftimefix = 0;
    protected AS.Enum.TeamState state = AS.Enum.TeamState.none;
    protected string teamstatestring = String.Empty;//项目状态的英文soldout卖光,success成功,failure失败
    public string strtitle = "";
    protected DateTime overtime = DateTime.Now;  //团购结束时间
    public int sortorder = 0;
    protected bool buy = true;//允许购买
    protected int ordercount = 0;//成功购买当前项目的订单数量
    protected int detailcount = 0;//成功购买当前项目数量
    protected int buycount = 0;//当前项目购买数量
    protected string buyurl = String.Empty;//购买按钮链接
    public int cityid = 0;
    public int currentcityid = 0;
    public List<AS.GroupOn.Domain.Spi.key> keylist = new List<AS.GroupOn.Domain.Spi.key>();
    public IList<IArea> areaList = null;
    public string keyid = "";//分类的编号
    public string keyname = "";//分类的名称
    public string child = "";//记录父类下面的子类
    public IList<ITeam> teamhostlist = null;//显示属性下面的项目
    public IList<ITeam> teamnewlist = null;//显示属性下面的项目新品
    public NameValueCollection _system = new NameValueCollection();
    public string pagerhtml = "";
    public string url = "";
    protected IPagers<ITeam> pager = null;
    protected TeamFilter filter = new TeamFilter();
    public override void UpdateView()
    {
        _system = WebUtils.GetSystem();
        if (CurrentCity != null)
        {
            cityid = CurrentCity.Id;
            currentcityid = CurrentCity.Id;
        }
        CurrentTeam = base.CurrentTeam;
        if (CurrentTeam == null)
        {
            Response.End();
            return;
        }
        strtitle = TeamMethod.GetTeamtype(CurrentTeam);
        twoline = (ASSystem.teamwhole == 0) ? 1 : 0;
        curtimefix = Helper.GetTimeFix(DateTime.Now) * 1000;
        difftimefix = Helper.GetTimeFix(CurrentTeam.End_time) * 1000;
        difftimefix = difftimefix - curtimefix;
        IPartner part = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            part = session.Partners.GetByID(CurrentTeam.Partner_id);
        }
        if (part != null)
        {
            partner = Helper.GetObjectProtery(part);
        }
        state = GetState(CurrentTeam);
        if (state == AS.Enum.TeamState.fail || state == AS.Enum.TeamState.successtimeover || state == AS.Enum.TeamState.successnobuy)
        {
            over = true;
            overtime = CurrentTeam.End_time;
        }
        if (state == AS.Enum.TeamState.fail)
        {
            teamstatestring = "failure";
        }
        else if (state == AS.Enum.TeamState.successbuy || state == AS.Enum.TeamState.successtimeover)
        {
            teamstatestring = "success";
        }
        else if (state == AS.Enum.TeamState.successnobuy)
        {
            teamstatestring = "soldout";
        }
        buyurl = Page.ResolveUrl(WebRoot + "ajax/car.aspx?id=" + CurrentTeam.Id);
        team = Helper.GetObjectProtery(CurrentTeam);

        if (CurrentTeam.Min_number > 0)
        {
            size = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(190 * (Convert.ToDouble(CurrentTeam.Now_number) / Convert.ToDouble(CurrentTeam.Min_number)))));

            offset = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(5 * (Convert.ToDouble(CurrentTeam.Now_number) / Convert.ToDouble(CurrentTeam.Min_number)))));
        }
        GetArea();//显示区域
        Getfather();//显示所有父类
        GetKey("");//显示关键字
        teamhost(CurrentTeam.Id);//显示项目属性的项目热销
    }
    /// <summary>
    /// 显示区域
    /// </summary>
    public void GetArea()
    {
        AreaFilter af = new AreaFilter();
        areaList = TeamMethod.GetArea(cityid);
    }
    /// <summary>
    /// 新品项目的显示
    /// </summary>
    /// <param name="teamid"></param>
    public void teamnew(int teamid)
    {
        int top = 3;
        top = Helper.GetInt(WebUtils.config["tnew"], 3);
        string wherestr = " 1=1  ";
        if (CurrentCity != null)
        {
            wherestr = wherestr + " and (City_id=" + CurrentCity.Id + " or city_id=0)";
        }
        else
        {
            wherestr = wherestr + "  and City_id>=0 ";
        }
        wherestr = wherestr + " and (Team_type='normal' or Team_type='draw'  or Team_type='goods') and (teamnew=1)  and Begin_time<='" + DateTime.Now.ToString() + "' and end_time>='" + DateTime.Now.ToString() + "'";
        wherestr += " and  teamcata=0 and cataid<>15";  //不要抽奖，抽奖在右侧栏显示过了
        string sql = "select top " + top + " * from team where " + wherestr + " order by  sort_order desc,Begin_time desc,id desc";
        using (IDataSession session = Store.OpenSession(false))
        {
            teamnewlist = session.Teams.GetList(sql);
        }
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="teamid"></param>
    public void teamhost(int teamid)
    {
        int num = Helper.GetInt(_system["indexteam"], 20);
        if (CurrentCity != null)
            filter.CityID = Helper.GetInt(CurrentCity.Id, 0);
        filter.teamcata = 0;
        filter.ToBegin_time = DateTime.Now;
        filter.FromEndTime = DateTime.Now;
        filter.TypeIn = "'normal','draw'";
        filter.CataIDNotin = "15";//不要抽奖，抽奖在右侧栏显示过了
        if (num > 0)
        {
            filter.PageSize = num;
        }
        else
        {
            if (WebUtils.config["row"] == "2")
                filter.PageSize = 20;
            else
                filter.PageSize = 30;
        }
        filter.AddSortOrder(TeamFilter.Sort_Order_DESC);
        filter.AddSortOrder(TeamFilter.Begin_time_DESC);
        filter.AddSortOrder(TeamFilter.ID_DESC);
        url = url + "&page={0}";
        url = GetUrl("一日多团六", "index_tuanmore6.aspx?" + url.Substring(1));
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = Store.OpenSession(false))
        {
            pager = session.Teams.GetPager(filter);
        }
        teamhostlist = pager.Objects;
        if (teamhostlist != null)
        {
            if (num > 0)
            {
                pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(num, pager.TotalRecords, pager.CurrentPage, url);
            }
            else
            {
                if (WebUtils.config["row"] == "2")
                    pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(20, pager.TotalRecords, pager.CurrentPage, url);
                else if (WebUtils.config["row"] == "3")
                    pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
            }
        }
    }
    /// <summary>
    /// 显示关键字
    /// </summary>
    /// <param name="key"></param>
    public void GetKey(string key)
    {
        string city = "0";
        if (CurrentCity != null)
        {
            city = CurrentCity.Id.ToString();
        }
        keylist = TeamMethod.Getkey(key, city);
    }
    public override string CacheKey
    {
        get
        {
            int cityid = 0;
            if (CurrentCity != null)
                cityid = CurrentCity.Id;
            return "cacheusercontrol-tuan6lefttop-" + cityid;
        }
    }
    public override bool CanCache
    {
        get
        {
            return false;
        }
    }
    /// <summary>
    /// 显示所有父类
    /// </summary>
    public void Getfather()
    {
        int city = 0;
        if (CurrentCity != null)
        {
            city = CurrentCity.Id;
        }
        catafatherlist = TeamMethod.GettopCata(city);
        cata19list = TeamMethod.GetCataall(100, 19, city);
    }
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
</script>
<%if (WebUtils.config["row"] == "2")
  { %>
<div class="tmore_box2">
    <dl class="sq-t">
        <dt><a href="#">本地团购</a></dt>
        <dd>
            <%if (catafatherlist != null && catafatherlist.Count > 0)
              {%>
            <a href="<%=getTeamDetailPageUrl(0,0,0,0)%>" class="this_fl">全部</a>
            <%foreach (ICatalogs model in catafatherlist)
              {
                  if (model.id == 19) continue;
            %>
            <a href="<%=getTeamDetailPageUrl(model.id, 0, 0, 0) %>">
                <%=model.catalogname %>(<%=TeamMethod.GetSumByArea(model.id,null,0,currentcityid,0)%>)</a>
            <% }%>
            <%}
              else
              {%>
            <a href="#">暂无本地团购</a>
            <%}%>
        </dd>
    </dl>
    <%if (currentcityid != 0 && areaList != null && areaList.Count > 0)
      {%>
    <dl class="sq-t">
        <dt><a href="#">区域</a></dt>
        <dd>
            <a href="<%=getTeamDetailPageUrl(0,0,0,0)%>" class="this_fl">全部</a>
            <%foreach (IArea model in areaList)
              { %>
            <a href="<%=getTeamDetailPageUrl(0, 0, 0, model.id) %>">
                <%=model.areaname%>(<%=TeamMethod.GetSumByArea(0, null, 0, currentcityid, model.id)%>)
            </a>
            <%}%>
        </dd>
    </dl>
    <%}%>
    <dl class="sq-t">
        <dt><a href="#">精品团购</a></dt>
        <dd>
            <%if (cata19list != null && cata19list.Count > 0)
              {%>
            <%--<a href="<%=getTeamDetailPageUrl(19,0,0,0)%>" class="this_fl">全部</a>--%>
            <%foreach (ICatalogs model in cata19list)
              {
                  if (model.parent_id != 19) continue;
            %>
            <a href="<%=getTeamDetailPageUrl(model.id, 0, 0, 0) %>">
                <%=model.catalogname %>(<%=TeamMethod.GetSumByArea(model.id,null,0,currentcityid,0)%>)</a>
            <% }%>
            <%}
              else
              {%>
            <a href="#">暂无精品团购</a>
            <%}%>
        </dd>
    </dl>
</div>
<div id="content_sy">
    <div class="tuan_more">
        <!--团购类别代码开始-->
        <!--热销开始-->
        <% int isece = 0; %>
        <div class="tuanmore_box">
            <!--热销循环开始-->
            <%if (teamhostlist != null && teamhostlist.Count > 0)
              {%>
            <%foreach (ITeam teammodel in teamhostlist)
              {
                  isece++;         
            %>
            <%if (isece % 2 == 0)
              {%>
            <div class="tuanmore1_list_r" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                <%}
              else
              { %>
                <div class="tuanmore1_list" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                    <%} %>
                    <div style="position: relative">
                        <%if (teammodel.teamhost == 2)
                          { %>
                        <div class="list1_goods">
                        </div>
                        <% }
                          else if (teammodel.teamhost == 1)
                          {%>
                        <div class="list1_new">
                        </div>
                        <% }
                          else if (teammodel.teamhost == 3 && teammodel.Begin_time.AddDays(1) > DateTime.Now)
                          {%>
                        <div class="list1_new">
                        </div>
                        <%}%>
                        <div class="lists1_img img_zt">
                            <a href="<%=getTeamPageUrl(teammodel.Id )  %>" target="_blank" class="image_link">
                                <img <%=ashelper.getimgsrc(teammodel.Image) %> width="336" class="dynload" height="221"
                                    alt="<%=teammodel.Title %>" title="<%=teammodel.Title %>" />
                            </a>
                        </div>
                        <h3 class="newh3">
                            <a href="<%=getTeamPageUrl(teammodel.Id )  %>">
                                <%=teammodel.Product%></a></h3>
                    </div>
                <%  if (GetState(teammodel) == AS.Enum.TeamState.successnobuy)
                    {%>
                <div class="tuanbd5 over">
                    <div class="goods_price">
                        <div class="price_now">
                            <span class="rmb">
                                <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b> <span class="price_original">
                                    原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                        </div>
                    </div>
                    <div class="goods_status">
                        <a target="_blank" href="#"></a>
                    </div>
                </div>
                <% }
                    else if (teammodel.Delivery == "draw")
                    {%>
                <div class="tuanbd5 chouj">
                    <div class="goods_price">
                        <div class="price_now">
                            <span class="rmb">
                                <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b> <span class="price_original">
                                    原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                        </div>
                    </div>
                    <div class="goods_status">
                        <a target="_blank" href="<%=getTeamPageUrl(teammodel.Id )  %>"></a>
                    </div>
                </div>
                <%}
                    else
                    {%>
                <div class="tuanbd5">
                    <div class="goods_price">
                        <div class="price_now">
                            <span class="rmb">
                                <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b> <span class="price_original">
                                    原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                        </div>
                    </div>
                    <div class="goods_status">
                        <a target="_blank" href="<%=getTeamPageUrl(teammodel.Id )  %>"></a>
                    </div>
                </div>
                <%} %>
                <div class="tuanft5">
                    <div class="goods_time">
                        <%if ((teammodel.End_time - DateTime.Now).Days >= 3)
                          { %>
                        <strong class="title">剩余时间：</strong><span> 3天以上</span>
                        <%}
                          else
                          { %>
                        <strong class="title">剩余时间：</strong>
                        <%if ((teammodel.End_time - DateTime.Now).Days > 0)
                          {%>
                        <span class="num" id="Span5">
                            <%=(teammodel.End_time - DateTime.Now).Days%></span>天
                        <%}%>
                        <span id="Span1" class="num">
                            <%=(teammodel.End_time - DateTime.Now).Hours%></span>时 <span id="min_1" class="num">
                                <%=(teammodel.End_time - DateTime.Now).Minutes%></span>分
                        <%} %>
                    </div>
                    <div class="goods_buyernumber">
                        <!-- 秒杀判断 -->
                        <span class="num">
                            <%=teammodel.Now_number%></span>人购买
                    </div>
                    <%if (TeamMethod.isShop(teammodel))
                      { 
                    %>
                    <a href="<%=WebRoot%>ajax/car.aspx?id=<%=teammodel.Id %>"></a>
                    <% }
                      else
                      { %>
                    <div class="xq" onmouseover="show(this)" onmouseout="hide(this)">
                        <%if (!TeamMethod.isShop(teammodel))
                          { %>
                        <div style="display: none;" class="adre_widtd">
                            <% IPartner _partnermodel = null;
                               using (IDataSession session = Store.OpenSession(false))
                               {
                                   _partnermodel = session.Partners.GetByID(teammodel.Partner_id);
                               }
                               if (_partnermodel != null)
                               {
                                   if (_partnermodel.Address != "")
                                   { %>
                            <p>
                                <strong>
                                    <%if (_partnermodel.area != "")
                                      {%><%=_partnermodel.area%><% }
                                      else
                                      { %>地址<%} %></strong>：
                                <%=_partnermodel.Address%>
                            </p>
                            <em></em>
                            <% }
                                       else
                                       { 
                            %>
                            <p>
                                <strong>
                                    <%if (_partnermodel.area != "")
                                      {%><%=_partnermodel.area%><% }
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
                <%} %>
                <%} %>
                <!--热销循环结束-->
            </div>
            <!--团购类别代码结束-->
        </div>
        <div>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <%=pagerhtml%>
        </div>
    </div>
</div>
<%}
  else
  {%>
<%--分类头--%>
<div class="tmore_box">
    <dl class="sq">
        <dt><a href="#">产品分类</a></dt>
        <dd>
            <%if (catafatherlist != null && catafatherlist.Count > 0)
              {%>
            <a href="<%=getTeamDetailPageUrl(0,0,0,0)%>" class="this_fl">全部</a>
            <%foreach (ICatalogs model in catafatherlist)
              { %>
            <a href="<%=getTeamDetailPageUrl(model.id, 0, 0, 0) %>">
                <%=model.catalogname %>(<%=TeamMethod.GetSumByArea(model.id,null,0,currentcityid,0)%>)</a>
            <% }%>
            <%}
              else
              { %>
            <a href="#">暂无产品分类</a>
            <%}%>
        </dd>
    </dl>
    <dl class="sq">
        <dt><a href="#">热门分类</a></dt>
        <dd>
            <%if (keylist != null && keylist.Count > 0)
              {  
            %>
            <a href="<%=getTeamDetailPageUrl(0,0,0,0)%>" class="this_fl">全部</a>
            <%foreach (AS.GroupOn.Domain.Spi.key model in keylist)
              { %>
            <a href="<%=getTeamDetailPageUrl(0, 0, 0, 0) %>?keyword=<%=model.keyname %>">
                <%=model.keyname%></a>
            <% }%>
            <%}
              else
              { %>
            <a href="#">暂无热门分类</a>
            <%} %>
        </dd>
    </dl>
    <%if (currentcityid != 0 && areaList != null && areaList.Count > 0)
      {%>
    <dl class="sq_gjc">
        <dt><a href="#">区域</a></dt>
        <dd>
            <a href="<%=getTeamDetailPageUrl(0,0,0,0)%>" class="this_fl">全部</a>
            <%foreach (IArea model in areaList)
              { %>
            <a href="<%=getTeamDetailPageUrl(0, 0, 0, model.id) %>">
                <%=model.areaname%>(<%=TeamMethod.GetSumByArea(0, null, 0, currentcityid, model.id)%>)
            </a>
            <%} %>
            <%} %>
        </dd>
    </dl>
</div>
<%--分类结束--%>
<div id="deal-default">
    <div id="content_sy">
        <!--团购类别代码开始-->
        <!--热销开始-->
        <% int isece = 0; %>
        <div class="tuanmore_boxxq">
            <%foreach (ITeam teammodel in teamhostlist)
              {
                  isece++;         
            %>
            <%if (isece % 3 == 0)
              {%>
            <div class="tuanmore_listxq_r5" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                <%}
              else
              { %>
                <div class="tuanmore_listxq5" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                    <%} %>
                    <div style="position: relative">
                        <%if (teammodel.teamhost == 2)
                          { %>
                        <div class="list1_goods">
                        </div>
                        <% }
                          else if (teammodel.teamhost == 1)
                          {%>
                        <div class="list1_new">
                        </div>
                        <% }%>
                        <div class="lists_xq_img5 img_xq">
                            <a href="<%=getTeamPageUrl(teammodel.Id )  %>" target="_blank" class="image_link">
                                <img <%=ashelper.getimgsrc(teammodel.Image) %> width="298" class="dynload" height="190"
                                    alt="<%=teammodel.Title %>" title="<%=teammodel.Title %>" />
                            </a>
                        </div>
                        <h3 class="newh3">
                            <a href="<%=getTeamPageUrl(teammodel.Id )  %>">
                                <%=teammodel.Product%></a></h3>
                    </div>
                    <%  if (GetState(teammodel) == AS.Enum.TeamState.successnobuy)
                        {%>
                    <div class="price_info5 over">
                        <span class="price_now"><em>
                            <%=ASSystem.currency%></em>
                            <%=GetMoney(teammodel.Team_price)%>
                        </span><span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                        <a title="<%=teammodel.Title %>" target="_blank" href="<%=getTeamPageUrl(teammodel.Id )  %>">
                        </a>
                    </div>
                    <% }
                        else if (teammodel.Delivery == "draw")
                        {%>
                    <div class="price_info5 chouj">
                        <span class="price_now"><em>
                            <%=ASSystem.currency%></em>
                            <%=GetMoney(teammodel.Team_price)%>
                        </span><span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                        <a title="<%=teammodel.Title %>" target="_blank" href="<%=getTeamPageUrl(teammodel.Id )  %>">
                        </a>
                    </div>
                    <%}
                        else
                        {%>
                    <div class="price_info5">
                        <span class="price_now"><em>
                            <%=ASSystem.currency%></em>
                            <%=GetMoney(teammodel.Team_price)%>
                        </span><span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                        <a title="<%=teammodel.Title %>" target="_blank" href="<%=getTeamPageUrl(teammodel.Id )  %>">
                        </a>
                    </div>
                    <%} %>
                    <div class="tuanft5">
                        <div class="goods_time">
                            <%if ((teammodel.End_time - DateTime.Now).Days >= 3)
                              { %>
                            <strong class="title">剩余时间：</strong><span> 3天以上</span>
                            <%}
                              else
                              { %>
                            <strong class="title">剩余时间：</strong>
                            <%if ((teammodel.End_time - DateTime.Now).Days > 0)
                              {%>
                            <span class="num" id="Span2">
                                <%=(teammodel.End_time - DateTime.Now).Days%></span>天
                            <%}%>
                            <span id="Span3" class="num">
                                <%=(teammodel.End_time - DateTime.Now).Hours%></span>时 <span id="Span4" class="num">
                                    <%=(teammodel.End_time - DateTime.Now).Minutes%></span>分
                            <%} %>
                        </div>
                        <div class="goods_buyernumber">
                            <!-- 秒杀判断 -->
                            <span class="num">
                                <%=teammodel.Now_number%></span>人购买
                        </div>
                        <%if (TeamMethod.isShop(teammodel))
                          { 
                        %>
                        <a href="<%=WebRoot%>ajax/car.aspx?id=<%=teammodel.Id %>"></a>
                        <% }
                          else
                          {  %>
                        <div class="xq" onmouseover="show(this)" onmouseout="hide(this)">
                            <%if (!TeamMethod.isShop(teammodel))
                              {
                            %>
                            <div style="display: none;" class="adre_widtd">
                                <%
                                  IPartner _partnermodel = null;
                                  using (IDataSession session = Store.OpenSession(false))
                                  {
                                      _partnermodel = session.Partners.GetByID(teammodel.Partner_id);
                                  }
                                  if (_partnermodel != null)
                                  {
                                      if (_partnermodel.Address != "")
                                      {
                                %>
                                <p>
                                    <strong>
                                        <%if (_partnermodel.area != "")
                                          {%><%=_partnermodel.area%><% }
                                          else
                                          { %>地址<%} %></strong>：
                                    <%=_partnermodel.Address%>
                                </p>
                                <em></em>
                                <% }
                                      else
                                      { 
                                %>
                                <p>
                                    <strong>
                                        <%if (_partnermodel.area != "")
                                          {%><%=_partnermodel.area%><% }
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
                <%} %>
                <div class="clear">
                </div>
                <div>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <%=pagerhtml%>
                </div>
            </div>
            <!--团购类别代码结束-->
        </div>
    </div>
</div>
<%}%>
