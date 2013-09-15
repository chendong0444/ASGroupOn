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
    protected int twoline = 0;
    protected long curtimefix = 0;
    protected long difftimefix = 0;
    protected AS.Enum.TeamState state = AS.Enum.TeamState.none;
    protected string teamstatestring = String.Empty;//项目状态的英文soldout卖光,success成功,failure失败
    public string strtitle = "";
    public IList<ICatalogs> catafatherlist = null;//查询全部的父类
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
    public IList<IArea> areaList = null; //显示区域
    public string keyid = "";//分类的编号
    public string keyname = "";//分类的名称
    public IList<ITeam> teamhostlist = null;//显示属性下面的项目
    public IList<ITeam> teamnewlist = null;//显示属性下面的项目新品
    public NameValueCollection _system = new NameValueCollection();
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
        IPartner par = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            par = session.Partners.GetByID(CurrentTeam.Partner_id);
        }
        curtimefix = Helper.GetTimeFix(DateTime.Now) * 1000;
        difftimefix = Helper.GetTimeFix(CurrentTeam.End_time) * 1000;
        difftimefix = difftimefix - curtimefix;
        if (par != null)
        {
            partner = Helper.GetObjectProtery(par);
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
            wherestr = wherestr + " and (City_id=" + CurrentCity.Id + " or level_cityid=" + CurrentCity.Id + " or city_id=0  or ','+othercity+',' like '%," + CurrentCity.Id + ",%')";
        }
        else
        {
            wherestr = wherestr + "  and City_id>=0 ";
        }
        wherestr = wherestr + " and (Team_type='normal' or Team_type='draw') and (teamnew=1)  and Begin_time<='" + DateTime.Now.ToString() + "' and end_time>='" + DateTime.Now.ToString() + "' and  teamcata=0";
        string sql = "select top " + top + " * from team where " + wherestr + " order by  sort_order desc,Begin_time desc,id desc";
        using (IDataSession session = Store.OpenSession(false))
        {
            teamnewlist = session.Teams.GetList(sql);
        }
    }


    /// <summary>
    /// 热销
    /// </summary>
    /// <param name="teamid"></param>
    public void teamhost(int teamid)
    {
        int top = 0;
        if (PageValue.CurrentSystemConfig["thost"] != null)
            top = Helper.GetInt(PageValue.CurrentSystemConfig["thost"], 3);
        string wherestr = " 1=1  ";
        if (CurrentCity != null)
        {
            wherestr = wherestr + " and (City_id=" + CurrentCity.Id + " or level_cityid=" + CurrentCity.Id + " or city_id=0 or  ','+othercity+',' like '%," + CurrentCity.Id + ",%')";
        }
        else
        {
            wherestr = wherestr + "  and City_id>=0 ";
        }
        wherestr = wherestr + " and  teamcata=0  and (Team_type='normal' or Team_type='draw' or Team_type='goods')  and (teamhost!=0 or teamnew!=0) and id<>" + teamid + " and Begin_time<='" + DateTime.Now.ToString() + "' and end_time>='" + DateTime.Now.ToString() + "'";
        string sql = "select top " + top + " * from team where " + wherestr + "  order by sort_order desc,Begin_time desc,id desc";
        ids = CurrentTeam.Id.ToString();
        using (IDataSession session = Store.OpenSession(false))
        {
            teamhostlist = session.Teams.GetList(sql);
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
            return "cacheusercontrol-tuan5lefttop-" + cityid;
        }
    }
    public override bool CanCache
    {
        get
        {
            return true;
        }
    }
    public void Getfather()
    {
        int city = 0;
        if (CurrentCity != null)
            city = CurrentCity.Id;
        catafatherlist = TeamMethod.GettopCata(city);
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
    public static bool isShop(ITeam model)
    {
        bool falg = false;
        NameValueCollection configs = WebUtils.GetSystem();
        if (configs["closeshopcar"] == "0")//开启购物车车标志
        {
            if (model.Delivery == "express")//是否是快递
                falg = true;
        }
        return falg;
    }
</script>
<div id="content_sy">
    <div class="tuan_more">
        <div class="tmore_box2">
            <dl class="sq1">
                <dt><a href="#">产品分类</a></dt>
                <dd>
                    <%if (catafatherlist != null && catafatherlist.Count > 0)
                      { %>
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
                    <%} %>
                </dd>
            </dl>
           
            <%if (currentcityid != 0 && areaList != null && areaList.Count > 0)
              {%>
            <dl class="sq1">
                <dt><a href="#">区域</a></dt>
                <dd>
                    <a href="<%=getTeamDetailPageUrl(0,0,0,0)%>" class="this_fl">全部</a>
                    <%foreach (IArea model in areaList)
                      {%>
                    <a href="<%=getTeamDetailPageUrl(0, 0, 0, model.id) %>">
                        <%=model.areaname%>(<%=TeamMethod.GetSumByArea(0, null, 0, currentcityid, model.id)%>)
                    </a>
                    <%}%>
                </dd>
                <%} %>
            </dl>
        </div>
        <div id="deal-intro" class="cf">
            <h1>
                <%
                    if (!over)
                    { %>
                <a class="deal-today-link" href="<%=getTeamPageUrl(int.Parse(team["id"].ToString()))  %>">
                    <%=strtitle %>：</a><%} %>
                <a class="deal-today-link-xx" href="<%=getTeamPageUrl(int.Parse( team["id"].ToString()))  %>"
                    title="<%=team["title"] %>">
                    <%=team["title"].ToString() %></a>
            </h1>
            <div class="main">
                <div class="deal-buy">
                    <div class="deal-price-tag">
                    </div>
                    <%
                        if (state == AS.Enum.TeamState.successnobuy)
                        { %>
                    <p class="deal-price">
                        <strong>
                            <%=ASSystemArr["currency"] %><%=GetMoney(team["team_price"]) %></strong><span class="deal-price-over"></span>
                    </p>
                    <%}
                        else if (over)
                        { %>
                    <p class="deal-price">
                        <strong>
                            <%=ASSystemArr["Currency"] %><%=GetMoney(team["team_price"]) %></strong><span class="deal-price-end"></span>
                    </p>
                    <%}
                        else
                        {%>
                    <p class="deal-price">
                        <strong>
                            <%=ASSystemArr["Currency"]%><%=GetMoney(team["team_price"])%></strong>
                        <%if (CurrentTeam.Begin_time <= DateTime.Now)
                          {
                      
                        %>
                        <%if (CurrentTeam.Delivery == "draw")
                          { %>
                        <a href="<%=buyurl %>"><span class="button-deal-cj"></span></a>
                        <% }
                          else
                          {%>
                        <a href="<%=buyurl %>"><span class="deal-price-buy"></span></a>
                        <% }%>
                        <% }
                          else
                          {%>
                        <a href="#"><span class="deal-price-notstart"></span></a>
                        <% }%>
                    </p>
                    <% } %>
                </div>
                <table class="deal-discount">
                    <tr>
                        <th>原价
                        </th>
                        <th>折扣
                        </th>
                        <th>节省
                        </th>
                    </tr>
                    <tr>
                        <td>
                            <%=ASSystemArr["Currency"] %><%=GetMoney(team["Market_price"])%>
                        </td>
                        <td>
                            <%=WebUtils.GetDiscount(Helper.GetDecimal(team["Market_price"],0),Helper.GetDecimal(team["Team_price"],0)) %>
                        </td>
                        <td>
                            <%=ASSystemArr["Currency"] %><%=GetMoney((Helper.GetDecimal(team["Market_price"], 0) - Helper.GetDecimal(team["Team_price"], 0)).ToString())%>
                        </td>
                    </tr>
                </table>
                <%if (over)
                  { %>
                <div class="deal-box deal-timeleft deal-off" id="deal-timeleft" curtime="<%=curtimefix %>"
                    diff="<%=difftimefix %>">
                    <div class="limitdate">
                        <p class="deal-buy-ended">
                            <%=overtime.ToString("yyyy-MM-dd HH:mm:ss")%><br />
                        </p>
                    </div>
                </div>
                <%}
                  else
                  { %>
                <%if (CurrentTeam.Begin_time <= DateTime.Now)
                  {
                %>
                <div class="deal-box deal-timeleft deal-on" id="Div1" curtime="<%=curtimefix %>"
                    diff="<%=difftimefix %>">
                    <h3></h3>
                    <div class="limitdate">
                        
                            <%if ((CurrentTeam.End_time - DateTime.Now).Days >= 3)
                              { %>
                           <ul><span style="font-size:20px;">
                                       3天以上</span></ul> 
                            <%}
                              else
                              { %>
                            <ul id="counter"><span> 
                                  <%if ((CurrentTeam.End_time - DateTime.Now).Days > 0)
                              {%>
                                  <span class="num" id="Span3"><%=(CurrentTeam.End_time - DateTime.Now).Days%>天</span> 
                              <%}%>
                                <%=(CurrentTeam.End_time - DateTime.Now).Hours%></span>时<span>
                                    <%=(CurrentTeam.End_time - DateTime.Now).Minutes%></span>分<span>
                                        <%=(CurrentTeam.End_time - DateTime.Now).Seconds%></span>秒  </ul>
                            <%} %>
                      
                    </div>
                </div>
                <%}
                  else
                  {%>
                <div class="deal-box deal-timeleft deal-deal_start" id="Div6" curtime="<%=curtimefix %>"
                    diff="<%=difftimefix %>">
                    <h3></h3>
                    <div class="limitdate">
                        
                            <%if ((CurrentTeam.Begin_time - DateTime.Now).Days >= 3)
                              { %>
                           <ul><span style="font-size:20px;">
                                       3天以上</span></ul> 
                            <%}
                              else
                              { %>
                            <ul id="counter">
                                  <%if ((CurrentTeam.End_time - DateTime.Now).Days > 0)
                                 {%>
                                  <span><%=(CurrentTeam.End_time - DateTime.Now).Days%></span>天 
                              <%}%>
                                      <%=(CurrentTeam.Begin_time - DateTime.Now).Hours%></span>时<span>
                                    <%=(CurrentTeam.Begin_time - DateTime.Now).Minutes%></span>分<span>
                                        <%=(CurrentTeam.Begin_time - DateTime.Now).Seconds%></span>秒</ul>
                            <%} %>
                    </div>
                </div>
                <%} %>
                <%} %>
                <%if (!over)
                  { %>
                <%if (state == AS.Enum.TeamState.begin)
                  { %>
                <div class="deal-box deal-status" id="deal-status">
                    <p class="deal-buy-tip-top">
                        <strong>
                            <%=team["Now_number"]%></strong> 人已购买
                    </p>
                    <div class="progress-pointer" style="padding-left: <%=(size-offset)%>px;">
                        <span></span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-left" style="width: <%=(size-offset)%>px;">
                        </div>
                        <div class="progress-right ">
                        </div>
                    </div>
                    <div class="cf">
                        <div class="min">
                            0
                        </div>
                        <div class="max">
                            <%=team["Min_number"] %>
                        </div>
                    </div>
                    <%if (CurrentTeam.Max_number > 0)
                      { %>
                    <p class="deal-buy-tip-btm">
                        还差 <strong>
                            <%= (CurrentTeam.Min_number-CurrentTeam.Now_number) %></strong> 人到达最低团购人数
                    </p>
                    <%} %>
                </div>
                <%}
                  else if (state == AS.Enum.TeamState.successbuy)
                  { %>
                <div class="deal-box deal-status deal-status-open" id="deal-status">
                    <p class="deal-buy-tip-top">
                        <strong>
                            <%=CurrentTeam.Now_number %></strong> 人已购买
                    </p>
                    <%if (CurrentTeam.Max_number > 0 && CurrentTeam.Max_number > CurrentTeam.Now_number)
                      { %>
                    <p class="deal-buy-tip-btm">
                        本单仅剩：<strong><%=CurrentTeam.Max_number-CurrentTeam.Now_number %></strong>份，欲购从速
                    </p>
                    <%} %>
                    <%if (CurrentTeam.Now_number >= CurrentTeam.Min_number)
                      { %>
                    <p class="deal-buy-on" style="line-height: 200%;">
                        <img src="<%=ImagePath() %>deal-buy-succ.gif" />
                        团购成功
                        <% }%>
                        <%if ((CurrentTeam.Max_number == 0) || (CurrentTeam.Max_number - CurrentTeam.Now_number) > 0)
                          { %>
                        可以继续购买<%} %>
                    </p>
                    <%if (CurrentTeam.Reach_time.HasValue)
                      { %>
                    <p class="deal-buy-tip-btm">
                        <%=CurrentTeam.Reach_time.Value.ToString("MM-dd HH:mm") %><br />
                        达到最低团购人数：<strong><%=CurrentTeam.Min_number %></strong>人
                    </p>
                    <%} %>
                </div>
                <%} %>
                <%}
                  else
                  { %>
                <div class="deal-box deal-status deal-status-<%=teamstatestring %>" id="deal-status">
                    <div class="deal-buy-<%=teamstatestring %>">
                    </div>
                    <p class="deal-buy-tip-total">
                        共有 <strong>
                            <%=team["Now_number"] %></strong> 人购买
                    </p>
                </div>
                <%} %>
            </div>
            <div class="side">
                <div class="deal-buy-cover-img" id="team_images">
                    <div id="zk">
                        <p>
                            <span class="zk">
                                <%=WebUtils.GetDiscount(Helper.GetDecimal(team["Market_price"], 0), Helper.GetDecimal(team["Team_price"], 0)).Replace("折", "")%></span>
                        </p>
                    </div>
                    <%if (team["image1"] != String.Empty || team["image2"] != String.Empty)
                      { %>
                    <div class="mid">
                        <ul>
                            <li class="first"><a href="<%=getTeamPageUrl(int.Parse(team["id"].ToString()))%>"
                                target="_blank">
                                <img <%=ashelper.getimgsrc(team["image"]) %> class="dynload" alt="<%=team["Title"] %>"
                                    title="<%=team["Title"] %>" /></a></li>
                            <%if (team["image1"] != String.Empty)
                              { %>
                            <li><a href="<%=getTeamPageUrl(int.Parse(team["id"].ToString()))%>" target="_blank">
                                <img <%=ashelper.getimgsrc(team["image1"]) %> class="dynload" alt="<%=team["Title"] %>"
                                    title="<%=team["Title"] %>" /></a></li>
                            <%} %>
                            <%if (team["image2"] != String.Empty)
                              { %>
                            <li><a href="<%=getTeamPageUrl(int.Parse(team["id"].ToString()))%>" target="_blank">
                                <img <%=ashelper.getimgsrc(team["image2"]) %> class="dynload" alt="<%=team["Title"] %>"
                                    title="<%=team["Title"] %>" /></a></li>
                            <%} %>
                        </ul>
                        <div id="img_list">
                            <a ref="1" class="active">1</a>
                            <%if (team["image1"] != String.Empty)
                              { %>
                            <a ref="<%=imageindex %>">
                                <%=imageindex %></a>
                            <%imageindex = imageindex + 1;
                              } %>
                            <%if (team["image2"] != String.Empty)
                              { %>
                            <a ref="<%=imageindex %>">
                                <%=imageindex%></a>
                            <%} %>
                        </div>
                    </div>
                    <%}
                      else
                      { 
                    %>
                    <img <%=ashelper.getimgsrc(team["image"]) %> width="440" class="dynload" height="280"
                        alt="<%=team["Title"] %>" title="<%=team["Title"] %>" />
                    <%} %>
                </div>
                <div class="digest">
                    <%=team["Summary"] %>
                </div>
            </div>
        </div>
        <!--团购类别代码开始-->
        <!--热销开始-->
        <% int isece = 0; %>
        <div class="tuanmore_box">
            <%if (teamhostlist != null && teamhostlist.Count > 0)
              { %>
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
                        <% }%>
                        <div class="lists1_img img_zt">
                            <a href="<%=getTeamPageUrl(teammodel.Id )  %>"
                                target="_blank" class="image_link">
                                <img <%=ashelper.getimgsrc(teammodel.Image) %> width="336" class="dynload" height="221"
                                    alt="<%=teammodel.Title %>" title="<%=teammodel.Title %>" />
                            </a>
                        </div>
                        <h3 class="newh3">
                            <a href="<%=getTeamPageUrl(teammodel.Id )  %>">
                                <%=teammodel.Title%></a></h3>
                    </div>
                    <%  if (GetState(teammodel) == AS.Enum.TeamState.successnobuy)
                        {%>
                    <div class="tuanbd5 over">
                        <div class="goods_price">
                            <div class="price_now">
                                <span class="rmb">
                                    <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b> <span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
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
                                    <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b> <span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
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
                                    <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b> <span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
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
                          <strong class="title">剩余时间：</strong><span>
                                       3天以上</span>
                            <%}
                              else
                              { %>
                                <strong class="title">剩余时间：</strong>
                            <%if ((teammodel.End_time - DateTime.Now).Days>0)
                              {%>
                                  <span class="num" id="Span2"><%=(teammodel.End_time - DateTime.Now).Days%></span>天 
                              <%}%>
                            <span id="Span1" class="num"><%=(teammodel.End_time - DateTime.Now).Hours%></span>时
                            <span id="min_1" class="num"><%=(teammodel.End_time - DateTime.Now).Minutes%></span>分
                            <%} %>
                        </div>
                        <div class="goods_buyernumber">
                            <!-- 秒杀判断 -->
                            <span class="num">
                                <%=teammodel.Now_number%></span>人购买
                        </div>
                        <%if (isShop(teammodel))
                          { 
                        %>
                        <a href="<%=WebRoot%>ajax/car.aspx?id=<%=teammodel.Id %>"></a>
                        <% }
                          else
                          { 
                        %>
                        <div class="xq" onmouseover="show(this)" onmouseout="hide(this)">
                            <%if (!isShop(teammodel))
                              {
                            %>
                            <div style="display: none;" class="adre_widtd">
                                <%if (teammodel.Partner!= null)
                                  {
                                      if (teammodel.Partner.Address != "")
                                      {
                                %>
                                <p>
                                    <strong>
                                        <%if (teammodel.Partner.area != "")
                                          {%><%=teammodel.Partner.area%><% }
                                          else
                                          { %>地址<%} %></strong>：
                                    <%=teammodel.Partner.Address%>
                                </p>
                                <em></em>
                                <% }
                                      else
                                      { 
                                %>
                                <p>
                                    <strong>
                                        <%if (teammodel.Partner.area != "")
                                          {%><%=teammodel.Partner.area%><% }
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
            </div>
            <!--团购类别代码结束-->
        </div>
    </div>
