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
    protected bool over = false;
    protected NameValueCollection order = new NameValueCollection();
    protected NameValueCollection team = new NameValueCollection();
    protected NameValueCollection user = new NameValueCollection();
    protected NameValueCollection partner = new NameValueCollection();
    public BaseUserControl baseuser = new BaseUserControl();
    protected int size = 0;
    protected int offset = 0;
    protected int imageindex = 2;
    protected int teamid = 0;
    protected int twoline = 0;
    protected long curtimefix = 0;
    protected long difftimefix = 0;
    protected AS.Enum.TeamState state = AS.Enum.TeamState.none;
    protected string teamstatestring = String.Empty;//项目状态的英文soldout卖光,success成功,failure失败
    protected IList<ITeam> otherteams = null;
    public string strtitle = "";
    protected DateTime overtime = DateTime.Now;  //团购结束时间
    public int sortorder = 0;
    new protected ITeam CurrentTeam = null;
    protected bool buy = true;//允许购买
    protected int ordercount = 0;//成功购买当前项目的订单数量
    protected int detailcount = 0;//成功购买当前项目数量
    protected int buycount = 0;//当前项目购买数量
    protected string buyurl = String.Empty;//购买按钮链接
    public NameValueCollection _system = new NameValueCollection();
    public int cityid = 0;
    public int currentcityid = 0;
    public List<AS.GroupOn.Domain.Spi.key> keylist = new List<AS.GroupOn.Domain.Spi.key>();
    public IList<IArea> areaList = null; //显示区域
    public IList<ICatalogs> catafatherlist = null;//查询全部的父类
    public IList<ICatalogs> catachildlist = null;//查询父类下的子类
    public string keyid = "";//分类的编号
    public string keyname = "";//分类的名称
    public string child = "";//记录父类下面的子类
    public IList<ITeam> teamhostlist = null;//显示属性下面的项目
    public IList<ITeam> teamnewlist = null;//显示属性下面的项目新品
    public string ids = String.Empty;
    public IList<ICatalogs> hostlist = null;//主推的类别
    public string cataids = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();
        teamid = Helper.GetInt(Request["id"], 0);
        if (CurrentCity != null)
        {
            cityid = CurrentCity.Id;
            currentcityid = CurrentCity.Id;
        }
        if (teamid > 0)
        {
            using (IDataSession session = Store.OpenSession(false))
            {
                CurrentTeam = session.Teams.GetByID(teamid);
            }
            Session["teamid"] = CurrentTeam.Id;
        }
        else
        {
            CurrentTeam = base.CurrentTeam;
            if (CurrentTeam != null)
                Session["teamid"] = CurrentTeam.Id;
            else
                Session["teamid"] = "0";
        }
        if (CurrentTeam != null)
        {
            buyurl = Page.ResolveUrl(WebRoot + "ajax/car.aspx?id=" + CurrentTeam.Id);
        }
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
        IPartner par = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            par = session.Partners.GetByID(CurrentTeam.Partner_id);
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
        if (AsUser.Id != 0)
        {
            OrderFilter filter = new OrderFilter();
            filter.Team_id = CurrentTeam.Id;
            filter.User_id = AsUser.Id;
            filter.State = "unpay";
            IList<IOrder> orders = null;
            using (IDataSession session = Store.OpenSession(false))
            {
                orders = session.Orders.GetList(filter);
            }
            if (orders != null && orders.Count > 0)
            {
                order = Helper.GetObjectProtery(orders[0]);
                if (CurrentTeam.Farefree > 0 && CurrentTeam.Delivery == "express")
                    buyurl = Page.ResolveUrl(WebRoot + "ajax/car.aspx?id=" + CurrentTeam.Id);
                else
                    buyurl = Page.ResolveUrl(GetUrl("优惠卷确认", "order_check.aspx?orderid=" + order["id"]));
            }
        }
        team = Helper.GetObjectProtery(CurrentTeam);
        if (CurrentTeam.Min_number > 0)
        {
            size = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(190 * (Convert.ToDouble(CurrentTeam.Now_number) / Convert.ToDouble(CurrentTeam.Min_number)))));
            offset = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(5 * (Convert.ToDouble(CurrentTeam.Now_number) / Convert.ToDouble(CurrentTeam.Min_number)))));
        }
        GetArea();//显示区域
        Getfather();//显示所有父类
        GetKey("");//显示关键字
        Gethost();//显示主推的类别
        teamhost(CurrentTeam.Id);//显示项目属性的项目热销
        //UpdateView(CurrentTeam.Id);//显示其他正在团购的项目
    }
    /// <summary>
    /// 根据分类编号，显示分类下面的信息
    /// </summary>
    /// <param name="top"></param>
    /// <param name="catamodel"></param>
    public IList<ITeam> GetBycata(int top, ICatalogs catamodel)
    {
        IList<ITeam> teamlist = null;
        if (catamodel != null)
        {
            if (!String.IsNullOrEmpty(catamodel.ids))
            {
                teamlist = TeamMethod.GetTopTeam(currentcityid, top, catamodel.ids.TrimEnd(','), CurrentTeam.Id.ToString());
            }
            else
            {
                teamlist = TeamMethod.GetTopTeam(currentcityid, top, catamodel.id.ToString(), CurrentTeam.Id.ToString());
            }
        }
        if (teamlist != null && teamlist.Count > 0)
        {
            for (int i = 0; i < teamlist.Count; i++)
            {
                if (!ids.Contains(teamlist[i].Id.ToString()))
                {
                    ids = ids + "," + teamlist[i].Id;
                }
            }
        }
        return teamlist;
    }
    /// <summary>
    /// 显示区域
    /// </summary>
    public void GetArea()
    {
        AreaFilter af = new AreaFilter();
        areaList = TeamMethod.GetArea(cityid);
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
            wherestr = wherestr + " and (City_id=" + CurrentCity.Id + " or level_cityid=" + CurrentCity.Id + " or city_id=0 or ','+othercity+',' like '%," + CurrentCity.Id + ",%')";
        }
        wherestr = wherestr + " and (Team_type='normal' or Team_type='draw') and (teamnew=1)  and Begin_time<='" + DateTime.Now.ToString() + "' and end_time>='" + DateTime.Now.ToString() + "'";
        wherestr += " and  teamcata=0";
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
        int top = 3;
        if (_system != null)
        {
            if (_system["thost"] != null)
            {
                top = Helper.GetInt(_system["thost"], 0);
            }
        }
        string wherestr = " 1=1  ";
        if (CurrentCity != null)
        {
            wherestr = wherestr + " and (City_id=" + CurrentCity.Id + " or level_cityid=" + CurrentCity.Id + " or city_id=0 or ','+othercity+',' like '%," + CurrentCity.Id + ",%')";
        }
        wherestr = wherestr + " and  teamcata=0 and (Team_type='normal' or Team_type='draw' or Team_type='goods')  and (teamhost!=0 or teamnew!=0) and id<>" + teamid + " and Begin_time<='" + DateTime.Now.ToString() + "' and end_time>='" + DateTime.Now.ToString() + "'";
        string sql = "select top " + top + " * from team where " + wherestr + "  order by sort_order desc,Begin_time desc,id desc";
        using (IDataSession session = Store.OpenSession(false))
        {
            teamhostlist = session.Teams.GetList(sql);
        }
        ids = CurrentTeam.Id.ToString();
        for (int i = 0; i < teamhostlist.Count; i++)
        {
            if (!ids.Contains(teamhostlist[i].Id.ToString()))
            {
                ids = ids + "," + teamhostlist[i].Id;
            }
        }
    }
    public IList<ITeam> GetTodayTeam()
    {
        int top = 0;
        if (ASSystem != null)
        {
            top = Helper.GetInt(WebUtils.config["indexteam"], 10);
            if (top > 0)
            {
                string wherestr = " 1=1  ";
                if (CurrentCity != null)
                {
                    wherestr = wherestr + " and (City_id=" + CurrentCity.Id + " or level_cityid=" + CurrentCity.Id + " or city_id=0 or ','+othercity+',' like '%," + CurrentCity.Id + ",%')";
                }
                else
                {
                    wherestr = wherestr + "  and City_id>=0 ";
                }
                if (ids != String.Empty)
                {
                    wherestr = wherestr + "  and id not in (" + ids.TrimEnd(',') + ")";
                }
                wherestr = wherestr + " and  teamcata=0 and (Team_type='normal' or Team_type='draw') and id<>" + CurrentTeam.Id + " and Begin_time<='" + DateTime.Now.ToString() + "' and end_time>='" + DateTime.Now.ToString() + "'";
                string sql = "select top " + top + " * from team where " + wherestr + " order by  sort_order desc,Begin_time desc,id desc ";
                using (IDataSession session = Store.OpenSession(false))
                {
                    otherteams = session.Teams.GetList(sql);
                }
            }
        }
        return otherteams;
    }
    /// <summary>
    /// 显示所有父类
    /// </summary>
    public void Getfather()
    {
        int city = 0;
        if (CurrentCity != null)
            city = CurrentCity.Id;
        catafatherlist = TeamMethod.GettopCata(city);
    }
    /// <summary>
    /// 显示主推类别
    /// </summary>
    public void Gethost()
    {
        int city = 0;
        if (CurrentCity != null)
            city = CurrentCity.Id;
        hostlist = TeamMethod.GethostCata(0, city);
    }
    /// <summary>
    /// 显示关键字
    /// </summary>
    /// <param name="key"></param>
    public void GetKey(string key)
    {
        string city = "0";
        if (CurrentCity != null)
            city = CurrentCity.Id.ToString();
        keylist = TeamMethod.Getkey(key, city);
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    function checksub_email() {
        var str = document.getElementById("sub_email").value;
        if (!str.match(/^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/)) {
            document.getElementById("sub_email").value = "";
            return false;
        }
        else {
            window.location.href = '<%=GetUrl("邮件订阅", "help_Email_Subscribe.aspx")%>' + '?email=' + str;
        }
    }
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
    function show(obj) {
        $(obj).children('.adre_widtd').css("display", "block");
    }
    function hide(obj) {
        $(obj).children('.adre_widtd').css("display", "none");
    }
</script>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <%LoadUserControl(WebRoot + "UserControls/admid.ascx", null); %>
        <div class="tmore_box">
            <dl class="sq">
                <dt><a href="#">产品分类</a></dt>
                <dd>
                    <%if (catafatherlist != null && catafatherlist.Count > 0)
                      { %>
                    <a href="<%=getTeamDetailPageUrl(0,0,0,0,"")%>" class="this_fl">全部</a>
                    <%foreach (ICatalogs model in catafatherlist)
                      { %>
                    <a href="<%=getTeamDetailPageUrl(model.id, 0, 0, 0,"") %>">
                        <%=model.catalogname %>(<%=TeamMethod.GetSumByArea(model.id,null,0,currentcityid,0)%>)</a>
                    <% }%>
                    <%}
                      else
                      { %>
                    <a href="#">暂无产品分类</a>
                    <%} %>
                </dd>
            </dl>
            <dl class="sq">
                <dt><a href="#">热门分类</a></dt>
                <dd>
                    <%if (keylist != null && keylist.Count > 0)
                      { %>
                    <a href="<%=getTeamDetailPageUrl(0,0,0,0,"")%>" class="this_fl">全部</a>
                    <%foreach (AS.GroupOn.Domain.Spi.key model in keylist)
                      { %>
                    <a href="<%=getTeamDetailPageUrl(0, 0, 0, 0,Server.UrlEncode(model.keyname)) %>">
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
            <dl class="sq">
                <dt><a href="#">区域</a></dt>
                <dd>
                    <a href="<%=getTeamDetailPageUrl(0,0,0,0,"")%>" class="this_fl">全部</a>
                    <%foreach (IArea model in areaList)
                      { %>
                    <a href="<%=getTeamDetailPageUrl(0, 0, 0, model.id,"") %>">
                        <%=model.areaname%>(<%=TeamMethod.GetSumByArea(0, null, 0, currentcityid, model.id)%>)
                    </a>
                    <%} %>
                </dd>
            </dl>
            <%} %>
        </div>
        <div id="deal-default">
            <%LoadUserControl(WebRoot + "UserControls/blockshare.ascx", CurrentTeam); %>
            <div id="content">
                <div id="deal-intro" class="cf">
                    <h1>
                        <%if (!over)
                          { %>
                        <a class="deal-today-link" href="<%=getTeamPageUrl(int.Parse(team["id"].ToString()))  %>">
                            <%=strtitle %>：</a><%} %>
                        <a class="deal-today-link-xx" href="<%=getTeamPageUrl(int.Parse(team["id"].ToString())) %>"
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
                                  { %>
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
                                <th>
                                    原价
                                </th>
                                <th>
                                    折扣
                                </th>
                                <th>
                                    节省
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
                        <div class="deal-box deal-timeleft deal-on" curtime="<%=curtimefix %>"
                            diff="<%=difftimefix %>">
                            <h3>
                            </h3>
                            <div class="limitdate">
                                    <%if ((CurrentTeam.End_time - DateTime.Now).Days >= 3)
                                      { %>
                                    <ul><span style="font-size:15px;">剩余时间：3天以上</span></ul>
                                    <%}
                                      else
                                      {%>
                                    <ul id="counter">
                                         <%if ((CurrentTeam.End_time - DateTime.Now).Days > 0)
                                 {%>
                                 <span><%=(CurrentTeam.End_time - DateTime.Now).Days%></span>天 
                              <%}%>
                                        <%=(CurrentTeam.End_time - DateTime.Now).Hours%></span>时<span>
                                            <%=(CurrentTeam.End_time - DateTime.Now).Minutes%></span>分<span>
                                                <%=(CurrentTeam.End_time - DateTime.Now).Seconds%></span>秒</ul>
                                    <%} %>
                                
                            </div>
                        </div>
                        <%}
                          else
                          {%>
                        <div class="deal-box deal-timeleft deal-deal_start" curtime="<%=curtimefix %>"
                            diff="<%=difftimefix %>">
                            <h3>
                            </h3>
                            <div class="limitdate">
                                    <%if ((CurrentTeam.Begin_time - DateTime.Now).Days >= 3)
                                      { %>
                                     <ul><span style="font-size:15px;">剩余时间：3天以上</span></ul>
                                    <%}
                                      else
                                      { %>
                                    <ul id="counter"><span>
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
                                        <img <%=ashelper.getimgsrc(team["image"]) %> class="dynload" /></a></li>
                                    <%if (team["image1"] != String.Empty)
                                      { %>
                                    <li><a href="<%=getTeamPageUrl(int.Parse(team["id"].ToString()))%>" target="_blank">
                                        <img <%=ashelper.getimgsrc(team["image1"]) %> class="dynload" /></a></li>
                                    <%} %>
                                    <%if (team["image2"] != String.Empty)
                                      { %>
                                    <li><a href="<%=getTeamPageUrl(int.Parse(team["id"].ToString()))%>" target="_blank">
                                        <img <%=ashelper.getimgsrc(team["image2"]) %> class="dynload" /></a></li>
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
                              { %>
                            <img <%=ashelper.getimgsrc(team["image"]) %> width="440" height="280" class="dynload"
                                alt="<%=team["Title"] %>" title="<%=team["Title"] %>" />
                            <%} %>
                        </div>
                        <div class="digest">
                            <br />
                            <%=team["Summary"] %>
                        </div>
                    </div>
                </div>
                <!--团购类别代码开始-->
                <div class="tuan_more">
                    <!--热销开始-->
                    <% int isece = 0; %>
                    <div class="tuanmore_boxzt">
                        <%if (teamhostlist != null && teamhostlist.Count > 0)
                          {%>
                        <%foreach (ITeam teammodel in teamhostlist)
                          {
                              isece++;         
                        %>
                        <%if (isece % 3 == 0)
                          {%>
                        <div class="tuanmore_list_r" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                            <%}
                          else
                          { %>
                            <div class="tuanmore_list" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                                <%} %>
                                <%if (teammodel.teamhost == 2)
                                  { %>
                                <div style="position: relative">
                                    <div class="list_goods">
                                    </div>
                                    <% }
                                  else if (teammodel.teamhost == 1)
                                  {%>
                                    <div style="position: relative">
                                        <div class="list_new">
                                        </div>
                                        <% }%>
                                        <div class="lists_img">
                                            <a href="<%=getTeamPageUrl(teammodel.Id)  %>"
                                                target="_blank" class="image_link">
                                                <img <%=ashelper.getimgsrc(teammodel.Image) %> width="210" class="dynload" height="133"
                                                    alt="<%=teammodel.Title %>" title="<%=teammodel.Title%>" />
                                            </a>
                                        </div>
                                        <h3>
                                            <a class="js_dlst " href="<%=getTeamPageUrl(teammodel.Id) %>"
                                                target="_blank">
                                                <%=teammodel.Title%></a></h3>
                                    </div>
                                    <%  if (GetState(teammodel) == AS.Enum.TeamState.successnobuy)
                                        {%>
                                    <div class="price_info4 over">
                                        <span class="price_now"><em>
                                            <%=ASSystem.currency%></em><%=GetMoney(teammodel.Team_price)%></span> <a title='<%=teammodel.Product %>'
                                                target="_blank" href="#" class="over"></a>
                                    </div>
                                    <% }
                                        else if (isover(teammodel))
                                        {%>
                                    <div class="price_info4 end">
                                        <span class="price_now"><em>
                                            <%=ASSystem.currency%></em><%=GetMoney(teammodel.Team_price)%></span> <a title='<%=teammodel.Product %>'
                                                target="_blank" href="#" class="end"></a>
                                    </div>
                                    <% }
                                        else
                                        {%>
                                    <% if (teammodel.Delivery == "draw")
                                       {%>
                                    <div class="price_info4 chouj">
                                        <span class="price_now"><em>
                                            <%=ASSystem.currency%></em><%=GetMoney(teammodel.Team_price)%></span> <a title='<%=teammodel.Product %>'
                                                target="_blank" href="<%=getTeamPageUrl(teammodel.Id) %>"
                                                class="chouj"></a>
                                    </div>
                                    <% }
                                       else
                                       {%>
                                    <div class="price_info4">
                                        <span class="price_now"><em>
                                            <%=ASSystem.currency%></em><%=GetMoney(teammodel.Team_price)%></span> <a title='<%=teammodel.Product %>'
                                                target="_blank" href="<%=getTeamPageUrl(teammodel.Id) %>">
                                            </a>
                                    </div>
                                    <% }%>
                                    <% }%>
                                    <div class="tuanft4">
                                        <div class="goods_buyernumber4">
                                            <span class="num">
                                                <%=teammodel.Now_number %></span>人购买
                                        </div>
                                        <div class="price_y">
                                            原价：<del><%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></del>
                                        </div>
                                        <%if (TeamMethod.isShop(teammodel))
                                          { 
                                        %>
                                        <a href="<%=WebRoot%>ajax/car.aspx?id=<%=teammodel.Id %>"></a>
                                        <% }
                                          else
                                          { 
                                        %>
                                        <div class="xq" onmouseover="show(this)" onmouseout="hide(this)">
                                            <%if (!TeamMethod.isShop(teammodel))
                                              {
                                            %>
                                            <div style="display: none;" class="adre_widtd">
                                                <%if (teammodel.Partner != null)
                                                  {
                                                      if (teammodel.Partner.Address != null)
                                                      {
                                                %>
                                                <p>
                                                    <strong>
                                                        <%if (teammodel.Partner.area != null)
                                                          {%><%=teammodel.Partner.area%><% }
                                                          else
                                                          { %>地址<%} %></strong>：
                                                    <%=teammodel.Partner.Address%>
                                                </p>
                                                <em></em>
                                                <%}
                                                      else
                                                      { 
                                                %>
                                                <p>
                                                    <strong>
                                                        <%if (teammodel.Partner.area != null)
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
                                <% }%>
                                <%}%>
                            </div>
                            <!--热销结束-->
                            <!--循环一日多团4-开始-->
                            <%if (hostlist != null && hostlist.Count > 0)
                              { %>
                            <%foreach (ICatalogs model in hostlist)
                              { %>
                            <div class="sort_list">
                                <!--加载分类-开始-->
                                <div class="box_tag">
                                    <h2>
                                        <a href="#">
                                            <%=model.catalogname %></a></h2>
                                    <div class="in_hot">
                                        <% catachildlist = TeamMethod.GetCataall(7, model.id, 0); %>
                                        <%if (catachildlist != null && catachildlist.Count > 0)
                                          {%>
                                        <%foreach (ICatalogs childmodel in catachildlist)
                                          { %>
                                        <a href="<%=getTeamDetailPageUrl(childmodel.id, 0, 0, 0,"") %>">
                                            <%=childmodel.catalogname %><span>(<%=TeamMethod.GetSum(childmodel.id, currentcityid,CurrentTeam.Id)%>)</span></a>
                                        <% }%>
                                        <%} %>
                                    </div>
                                    <a href="<%=getTeamDetailPageUrl(model.id, 0, 0, 0,"") %>" class="more_link">更多>></a>
                                </div>
                                <!--加载分类-结束-->
                                <!--加载分类下面项目-开始-->
                                <div class="tuanmore_box4">
                                    <%IList<ITeam> teamlist = null; %>
                                    <%teamlist = GetBycata(model.keytop, model); %>
                                    <% int itype = 0; %>
                                    <%if (teamlist != null && teamlist.Count > 0)
                                      {%>
                                    <%foreach (ITeam teammodel in teamlist)
                                      {

                                          itype++;
                                    %>
                                    <!--循环项目-开始-->
                                    <%if (itype % 3 == 0)
                                      {%>
                                    <div class="tuanmore_list_r" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                                        <%}
                                      else
                                      { %>
                                        <div class="tuanmore_list" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                                            <%}%>
                                            <div class="lists_img">
                                                <a href="<%=getTeamPageUrl(teammodel.Id)  %>"
                                                    target="_blank" class="image_link">
                                                    <img <%=ashelper.getimgsrc(teammodel.Image) %> class="dynload" width="210" height="133"
                                                        alt="<%=teammodel.Title %>" title="<%=teammodel.Title %>" />
                                                </a>
                                            </div>
                                            <h3>
                                                <a class="js_dlst " href="<%=getTeamPageUrl(teammodel.Id)  %>"
                                                    target="_blank">
                                                    <%=teammodel.Title%></a></h3>
                                            <!--项目金额-开始-->
                                            <%  if (GetState(teammodel) == AS.Enum.TeamState.successnobuy)
                                                {%>
                                            <div class="price_info4 over">
                                                <span class="price_now"><em>
                                                    <%=ASSystem.currency%></em><%=GetMoney(teammodel.Team_price)%></span> <a title='<%=teammodel.Product %>'
                                                        target="_blank" href="#" class="over"></a>
                                            </div>
                                            <% }
                                                else if (isover(teammodel))
                                                {%>
                                            <div class="price_info4 end">
                                                <span class="price_now"><em>
                                                    <%=ASSystem.currency%></em><%=GetMoney(teammodel.Team_price)%></span> <a title='<%=teammodel.Product %>'
                                                        target="_blank" href="#" class="end"></a>
                                            </div>
                                            <% }
                                                else
                                                {%>
                                            <% if (teammodel.Delivery == "draw")
                                               {%>
                                            <div class="price_info4 chouj">
                                                <span class="price_now"><em>
                                                    <%=ASSystem.currency%></em><%=GetMoney(teammodel.Team_price)%></span> <a title='<%=teammodel.Product %>'
                                                        target="_blank" href="<%=getTeamPageUrl(teammodel.Id)  %>"
                                                        class="chouj"></a>
                                            </div>
                                            <% }
                                               else
                                               {%>
                                            <div class="price_info4">
                                                <span class="price_now"><em>
                                                    <%=ASSystem.currency%></em><%=GetMoney(teammodel.Team_price)%></span> <a title='<%=teammodel.Product %>'
                                                        target="_blank" href="<%=getTeamPageUrl(teammodel.Id)  %>">
                                                    </a>
                                            </div>
                                            <% }%>
                                            <% }%>
                                            <!--项目金额-结束-->
                                            <!--购买人数和地址-开始-->
                                            <div class="tuanft4">
                                                <div class="goods_buyernumber4">
                                                    <span class="num">
                                                        <%=teammodel.Now_number %></span>人购买
                                                </div>
                                                <div class="price_y">
                                                    原价：<del><%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></del>
                                                </div>
                                                <%if (TeamMethod.isShop(teammodel))
                                                  { %>
                                                <a href="<%=WebRoot%>ajax/car.aspx?id=<%=teammodel.Id %>"></a>
                                                <% }
                                                  else
                                                  {  %>
                                                <div class="xq" onmouseover="show(this)" onmouseout="hide(this)">
                                                    <!--加载项目地址-->
                                                    <%if (!TeamMethod.isShop(teammodel))
                                                      { %>
                                                    <div style="display: none;" class="adre_widtd">
                                                        <%if (teammodel.Partner != null)
                                                          {
                                                              if (teammodel.Partner.Address != null)
                                                              {%>
                                                        <p>
                                                            <strong>
                                                                <%if (teammodel.Partner.area != null)
                                                                  {%><%=teammodel.Partner.area%><% }
                                                                  else
                                                                  { %>地址<%} %></strong>：
                                                            <%=teammodel.Partner.Address%>
                                                        </p>
                                                        <em></em>
                                                        <%}
                                                              else
                                                              { 
                                                        %>
                                                        <p>
                                                            <strong>
                                                                <%if (teammodel.Partner.area != null)
                                                                  {%><%=teammodel.Partner.area%><% }
                                                                  else
                                                                  { %>地址<%} %></strong>： 暂无地址
                                                        </p>
                                                        <em></em>
                                                        <%}
                                                          }
                                                          else
                                                          {     %><strong> 地址</strong>： 暂无地址 <em></em>
                                                        <%} %>
                                                    </div>
                                                    <%}%>
                                                    <!--加载项目地址结束-->
                                                </div>
                                                <%} %>
                                            </div>
                                            <!--购买人数和地址-结束-->
                                        </div>
                                        <!--循环项目-结束-->
                                        <%} %>
                                        <%} %>
                                    </div>
                                    <!--加载分类下面项目-结束-->
                                </div>
                                <% }%>
                                <% }%>
                                <!--循环一日多团4-结束-->
                                <%otherteams = GetTodayTeam();%>
                               <%if (otherteams != null && otherteams.Count > 0)
                                  { %>
                                <div class="sort_list">
                                    <div class="box_tag">
                                        <h2>
                                            <a href="#">今日团购</a></h2>
                                        <div class="in_hot">
                                        </div>
                                        <a href="#" class="more_link"></a>
                                    </div>
                                    <div class="tuanmore_box4">
                                        <% int i = 0; %>
                                        <%foreach (ITeam teammodel in otherteams)
                                          {

                                              i++;
                                        %>
                                        <%if (i % 3 == 0)
                                          {%>
                                        <div class="tuanmore_list_r" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                                            <%}
                                          else
                                          { %>
                                            <div class="tuanmore_list" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                                                <%} %>
                                                <div class="lists_img">
                                                    <a href="<%=getTeamPageUrl(teammodel.Id)  %>"
                                                        target="_blank" class="image_link">
                                                        <img <%=ashelper.getimgsrc(teammodel.Image) %> class="dynload" width="210" height="133"
                                                            alt="<%=teammodel.Title %>" title="<%=teammodel.Title %>" />
                                                    </a>
                                                </div>
                                                <h3>
                                                    <a class="js_dlst " href="<%=getTeamPageUrl(teammodel.Id)  %>"
                                                        target="_blank">
                                                        <%=teammodel.Title%></a></h3>
                                                <%  if (GetState(teammodel) == AS.Enum.TeamState.successnobuy)
                                                    {%>
                                                <div class="price_info4 over">
                                                    <span class="price_now"><em>
                                                        <%=ASSystem.currency%></em><%=GetMoney(teammodel.Team_price)%></span> <a title='<%=teammodel.Product %>'
                                                            target="_blank" href="#" class="over"></a>
                                                </div>
                                                <% }
                                                    else if (isover(teammodel))
                                                    {%>
                                                <div class="price_info4 end">
                                                    <span class="price_now"><em>
                                                        <%=ASSystem.currency%></em><%=GetMoney(teammodel.Team_price)%></span> <a title='<%=teammodel.Product %>'
                                                            target="_blank" href="#" class="end"></a>
                                                </div>
                                                <% }
                                                    else
                                                    {%>
                                                <% if (teammodel.Delivery == "draw")
                                                   {%>
                                                <div class="price_info4 chouj">
                                                    <span class="price_now"><em>
                                                        <%=ASSystem.currency%></em><%=GetMoney(teammodel.Team_price)%></span> <a title='<%=teammodel.Product %>'
                                                            target="_blank" href="<%=getTeamPageUrl(teammodel.Id)  %>"
                                                            class="chouj"></a>
                                                </div>
                                                <% }
                                                   else
                                                   {%>
                                                <div class="price_info4">
                                                    <span class="price_now"><em>
                                                        <%=ASSystem.currency%></em><%=GetMoney(teammodel.Team_price)%></span> <a title='<%=teammodel.Product %>'
                                                            target="_blank" href="<%=getTeamPageUrl(teammodel.Id)  %>">
                                                        </a>
                                                </div>
                                                <% }%>
                                                <% }%>
                                                <div class="tuanft4">
                                                    <div class="goods_buyernumber4">
                                                        <!-- 秒杀判断 -->
                                                        <span class="num">
                                                            <%=teammodel.Now_number %></span>人购买
                                                    </div>
                                                    <div class="price_y">
                                                        原价：<del><%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></del>
                                                    </div>
                                                    <%if (TeamMethod.isShop(teammodel))
                                                      { 
                                                    %>
                                                    <a href="<%=WebRoot%>ajax/car.aspx?id=<%=teammodel.Id %>"></a>
                                                    <% }
                                                      else
                                                      { 
                                                    %>
                                                    <div class="xq" onmouseover="show(this)" onmouseout="hide(this)">
                                                        <%if (!TeamMethod.isShop(teammodel))
                                                          { %>
                                                        <div style="display: none;" class="adre_widtd">
                                                            <%if (teammodel.Partner != null)
                                                              {
                                                                  if (teammodel.Partner.Address != null)
                                                                  {
                                                            %>
                                                            <p>
                                                                <strong>
                                                                    <%if (teammodel.Partner.area != null)
                                                                      {%><%=teammodel.Partner.area%><% }
                                                                      else
                                                                      { %>地址<%} %></strong>：
                                                                <%=teammodel.Partner.Address%>
                                                            </p>
                                                            <em></em>
                                                            <%}
                                                                  else
                                                                  { 
                                                            %>
                                                            <p>
                                                                <strong>
                                                                    <%if (teammodel.Partner.area != null)
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
                                            <% }%>
                                        </div>
                                    </div>
                                    <% }%>
                                    <!--团购类别代码结束-->
                                </div>
                            </div>
                            <div id="sidebar">
                                <%LoadUserControl(WebRoot + "UserControls/adleft.ascx", null); %>
                                <%LoadUserControl(WebRoot + "UserControls/blockSign.ascx", null); %>
                                <%LoadUserControl(WebRoot + "UserControls/blockinvite.ascx", null); %>
                                <%LoadUserControl(WebRoot + "UserControls/blockcomment.ascx", null); %>
                                <%LoadUserControl(WebRoot + "UserControls/blockbulletin.ascx", null); %>
                                <%LoadUserControl(WebRoot + "UserControls/blockflv.ascx", CurrentTeam); %>
                                <%LoadUserControl(WebRoot + "UserControls/blockask.ascx", CurrentTeam); %>
                                <%LoadUserControl(WebRoot + "UserControls/blockqq.ascx", CurrentTeam); %>
                                <%
                                    if (_system["newgao"] != null)
                                    {
                                        if (_system["newgao"] == "1")
                                        { %>
                                <%LoadUserControl(PageValue.WebRoot + "UserControls/uc_NewList.ascx", null); %>
                                <% 
                                        }
                                    }%>
                                <%LoadUserControl(WebRoot + "UserControls/blockvote.ascx", null); %>
                                <%LoadUserControl(WebRoot + "UserControls/blockbusiness.ascx", null); %>
                                <%LoadUserControl(WebRoot + "UserControls/blocksubscribe.ascx", null); %>
                            </div>
                            <!-- bd end -->
                        </div>
                    </div>
                </div></div></div></div></div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
