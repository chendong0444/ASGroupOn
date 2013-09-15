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
    protected bool over = false;
    protected bool soldout = false;
    protected NameValueCollection order = new NameValueCollection();
    protected NameValueCollection team = new NameValueCollection();
    public NameValueCollection _system = new NameValueCollection();
    new protected ITeam CurrentTeam = null;
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
    protected DateTime overtime = DateTime.Now;  //团购结束时间
    public string cityid = "0";
    protected IList<ITeam> list_team = null;
    protected TeamFilter filter = new TeamFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (CurrentCity != null)
        {
            cityid = CurrentCity.Id.ToString();
        }
        _system = PageValue.CurrentSystemConfig;
        teamid = Helper.GetInt(Request["id"], 0);
        if (teamid > 0)
        {
            using (IDataSession session = Store.OpenSession(false))
            {
                CurrentTeam = session.Teams.GetByID(teamid);
            }
        }
        else
        {
            CurrentTeam = base.CurrentTeam;
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
        if (AsUser != null)
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
                order = Helper.GetObjectProtery(orders[0]);
        }
        team = Helper.GetObjectProtery(CurrentTeam);
        if (CurrentTeam.Min_number > 0)
        {
            size = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(190 * (Convert.ToDouble(CurrentTeam.Now_number) / Convert.ToDouble(CurrentTeam.Min_number)))));
            offset = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(5 * (Convert.ToDouble(CurrentTeam.Now_number) / Convert.ToDouble(CurrentTeam.Min_number)))));
        }
        UpdateView(CurrentTeam.Id);

    }
    public void UpdateView(int teamid)
    {
        int top = 0;
        if (ASSystem != null)
        {
            top = Helper.GetInt(WebUtils.config["indexteam"], 10);
            if (top > 0)
            {
                string wherestr = " 1=1  ";
                if (CurrentCity != null)
                    wherestr = wherestr + " and (City_id=" + CurrentCity.Id + " or level_cityid=" + CurrentCity.Id + " or city_id=0 or ','+othercity+',' like '%," + CurrentCity.Id + ",%')";
                else
                    wherestr = wherestr + "  and City_id>=0 ";
                wherestr = wherestr + " and  teamcata=0 and (Team_type='normal' or Team_type='draw') and id<>" + teamid + " and Begin_time<='" + DateTime.Now.ToString() + "' and end_time>='" + DateTime.Now.ToString() + "'";
                string sql = "select top " + top + " * from team where " + wherestr + " order by  sort_order desc,Begin_time desc,id desc ";
                using (IDataSession session = Store.OpenSession(false))
                {
                    list_team = session.Teams.GetList(sql);
                }
            }
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    $(document).ready(function () {
        var SysSecond = parseInt(jQuery('div.deal-timeleft').attr('diff')) / 1000;
        var InterValObj = window.setInterval(SetRemainTime, 1000);
        function SetRemainTime() {
            if (SysSecond > 0) {
                SysSecond = SysSecond - 1;
                var second = Math.floor(SysSecond % 60);
                var minite = Math.floor((SysSecond / 60) % 60);
                var hour = Math.floor((SysSecond / 3600) % 24);
                var day = Math.floor((SysSecond / 3600) / 24);
                if (day > 0) {
                    $("#counter").html("<span>" + day + "</span>天<span>" + hour + "</span>时<span>" + minite + "</span>分<span>" + second + "</span>秒");
                }else {
                    $("#counter").html("<span>" + hour + "</span>时<span>" + minite + "</span>分<span>" + second + "</span>秒");
                }
            } else {
                window.clearInterval(InterValObj);
            }
        }
    });
</script>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <%LoadUserControl(WebRoot + "UserControls/admid.ascx", null); %>
        <%if (order.Count > 0)
          { %>
        <%if (CurrentTeam.Farefree == 0 || CurrentTeam.Delivery == "coupon")
          { %>
        <div id="sysmsg-tip">
            <div class="sysmsg-tip-top">
            </div>
            <div class="sysmsg-tip-content">
                您已经下过订单，但还没有付款。<a href="<%=GetUrl("优惠卷确认", "order_check.aspx?orderid="+order["id"])%>">查看订单并付款</a>
                <span id="sysmsg-tip-close" class="sysmsg-tip-close">关闭</span>
            </div>
            <div class="sysmsg-tip-bottom">
            </div>
        </div>
        <%}%>
        <%}%>
        <div id="deal-default">
            <%LoadUserControl(WebRoot + "UserControls/blockshare.ascx", CurrentTeam); %>
            <div id="content">
                <div id="deal-intro" class="cf">
                    <h1>
                        <a class="deal-today-link" href="<%=getTeamPageUrl(int.Parse(team["id"])) %>">
                            <%=strtitle %>：</a><a class="deal-today-link-xx" href="<%=getTeamPageUrl(int.Parse(team["id"])) %>"><%=team["title"]%></a>
                    </h1>
                    <div class="main">
                        <div class="deal-buy">
                            <div class="deal-price-tag">
                            </div>
                            <%if (state == AS.Enum.TeamState.successnobuy)
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
                                <a href="<%=PageValue.WebRoot%>ajax/car.aspx?id=<%=team["id"] %>"><span class="button-deal-cj"></span></a>
                                <% }
                                  else
                                  {%>
                                <a href="<%=PageValue.WebRoot%>ajax/car.aspx?id=<%=team["id"] %>"><span class="deal-price-buy"></span></a>
                                <% }%>
                                <% }
                                  else
                                  {%>
                                <a href="#"></a>
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
                        <div class="deal-box deal-timeleft deal-on" id="deal-timeleft" curtime="<%=curtimefix %>"
                            diff="<%=difftimefix %>">
                            <h3></h3>
                            <div class="limitdate">
                                    <%if ((CurrentTeam.End_time - DateTime.Now).Days >=3)
                                      { %>
                                  <ul id="">
                                    <span style="font-size:20px;">
                                       3天以上</span></ul>
                                    <%}
                                      else
                                      { %>
                                    <ul id="counter">
                                    <span>
                                        <%=(CurrentTeam.End_time-DateTime.Now).Hours %></span>时<span>
                                            <%=(CurrentTeam.End_time-DateTime.Now).Minutes %></span>分<span>
                                                <%=(CurrentTeam.End_time-DateTime.Now).Seconds %></span>秒
                                    </ul>
                                    <%} %>
                            </div>
                        </div>
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
                                    <li class="first"><a href="<%=getTeamPageUrl(int.Parse(team["id"].ToString())) %>"
                                        target="_blank">
                                        <img <%=ashelper.getimgsrc(team["image"]) %>alt="<%=team["Title"] %>" class="dynload"
                                            title="<%=team["Title"] %>" /></a></li>
                                    <%if (team["image1"] != String.Empty)
                                      { %>
                                    <li><a href="<%=getTeamPageUrl(int.Parse(team["id"].ToString())) %>"
                                        target="_blank">
                                        <img <%=ashelper.getimgsrc(team["image1"]) %> alt="<%=team["Title"] %>" class="dynload"
                                            title="<%=team["Title"] %>" /></a></li>
                                    <%} %>
                                    <%if (team["image2"] != String.Empty)
                                      { %>
                                    <li><a href="<%=getTeamPageUrl(int.Parse(team["id"].ToString())) %>"
                                        target="_blank">
                                        <img <%=ashelper.getimgsrc(team["image2"]) %> alt="<%=team["Title"] %>" class="dynload"
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
                            <img <%=ashelper.getimgsrc(team["image"]) %> class="dynload" width="440" height="280" />
                            <%} %>
                        </div>
                        <div class="digest">
                            <br />
                            <%=team["Summary"] %>
                        </div>
                    </div>
                </div>
                <!--开始代码-->
                <div class="cf" id="deal-stuff">
                    <div class="clear box">
                        <div class="other_buy cf">
                            <div id="qttg_bt">
                            </div>
                            <!--循环开始-->
                            <div id="left_kj">
                                <%if (list_team != null && list_team.Count > 0)
                                  {%>
                                <% foreach (ITeam model in list_team)
                                   {  %>
                                <div class="cp_content">
                                    <div class="cp_img">
                                        <a href="<%=getTeamPageUrl(model.Id) %>"
                                            target="_blank">
                                            <img <%=ashelper.getimgsrc(model.Image) %> width="267" class="dynload" height="166"
                                                border="0" alt="<%=model.Title %>" title="<%=model.Title %>" /></a>
                                    </div>
                                    <div class="cp_xq">
                                        <div class="duotuan_bt">
                                            <a href="<%=getTeamPageUrl(model.Id) %>"
                                                target="_blank">
                                                <%=TeamMethod.GetTeamtype(model)%>:<font style="font-weight: bold; color: Black;"><%=model.Title%></font></a>
                                        </div>
                                        <div class="duotuan_hb">
                                            <%=ASSystemArr["Currency"]%>
                                        </div>
                                        <div class="duotuan_jg">
                                            <%=model.Team_price%>
                                        </div>
                                        <div class="price">
                                            原价：<%=ASSystemArr["Currency"]%><%=GetMoney(model.Market_price)%>
                                            <br />
                                            折扣：<%=ASSystemArr["Currency"]%><%=WebUtils.GetDiscount(model.Market_price, model.Team_price)%>
                                            <br />
                                            节省：<%=ASSystemArr["Currency"]%><%=GetMoney(model.Market_price - model.Team_price).ToString()%>
                                        </div>
                                        <div class="goumai">
                                            <div class="goumai_order">
                                                <a href="<%=getTeamPageUrl(model.Id) %>"
                                                    target="_blank">
                                                    <%if (false)
                                                      {  %><img src="<%=ImagePath() %>order_over_bt.png" width="145" height="39" border="0px;" /><%}
                                                      else
                                                      {%><img src="<%=ImagePath() %>order_bt.png" width="145" height="39" border="0px;" />
                                                    <%} %></a>
                                            </div>
                                            <div class="goumai_rs">
                                                已有<span style="font-size: 15px; color: #ff0000;"><%=model.Now_number%>
                                                </span>人购买
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <%}%>
                                <%}%>
                            </div>
                            <!--循环结束-->
                        </div>
                    </div>
                </div>
                <!--结束代码-->
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
        </div></div></div>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
