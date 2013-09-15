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
    protected NameValueCollection order = new NameValueCollection();
    protected NameValueCollection team = new NameValueCollection();
    protected NameValueCollection user = new NameValueCollection();
    protected NameValueCollection partner = new NameValueCollection();
    protected IList<ITeam> otherteams = null;
    public BaseUserControl baseuser = new BaseUserControl();
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
    public NameValueCollection _system = new NameValueCollection();
    public string cityid = "0";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (CurrentCity != null)
        {
            cityid = CurrentCity.Id.ToString();
        }
        _system = WebUtils.GetSystem();
        teamid = Helper.GetInt(Request["id"], 0);
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
            {
                Session["teamid"] = CurrentTeam.Id;
            }
            else
            {
                Session["teamid"] = "0";
            }
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
        IPartner part = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            part = session.Partners.GetByID(CurrentTeam.Partner_id);
        }
        partner = Helper.GetObjectProtery(part);

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
            IList<IOrder> orderlist = null;
            OrderFilter of = new OrderFilter();
            of.Team_id = CurrentTeam.Id;
            of.User_id = AsUser.Id;
            of.State = "unpay";
            using (IDataSession session = Store.OpenSession(false))
            {
                orderlist = session.Orders.GetList(of);
            }
            if (orderlist != null && orderlist.Count > 0)
                order = Helper.GetObjectProtery(orderlist[0]);
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
                wherestr = wherestr + " and  teamcata=0 and (Team_type='normal' or Team_type='draw' or Team_type='goods') and id<>" + teamid + " and Begin_time<='" + DateTime.Now.ToString() + "' and end_time>='" + DateTime.Now.ToString() + "'";
                string sql = "select top " + top + " * from team where " + wherestr + " order by  sort_order desc,Begin_time desc,id desc ";
                using (IDataSession session = Store.OpenSession(false))
                {
                    otherteams = session.Teams.GetList(sql);
                }
            }
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script>
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
<script language="javascript" type="text/javascript">
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
    $(document).ready(function () {
        jQuery("div.deal-timeleft").each(function () {
            var numid = jQuery(this).attr("num");
            var SysSecond = parseInt(jQuery(this).attr('diff')) / 1000;
            var InterValObj = window.setInterval(SetRemainTime, 1000);
            function SetRemainTime() {
                if (SysSecond > 0) {
                    SysSecond = SysSecond - 1;
                    var second = Math.floor(SysSecond % 60);
                    var minite = Math.floor((SysSecond / 60) % 60);
                    var hour = Math.floor((SysSecond / 3600) % 24);
                    var day = Math.floor((SysSecond / 3600) / 24);
                    if (day > 0) {
                        $("#counter" + numid).html("<span>" + day + "</span>天<span>" + hour + "</span>时<span>" + minite + "</span>分<span>" + second + "</span>秒");
                    }
                    else {
                        $("#counter" + numid).html("<span>" + hour + "</span>时<span>" + minite + "</span>分<span>" + second + "</span>秒");
                    }
                } else {
                    window.clearInterval(InterValObj);
                }
            }
        });
    });
</script>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <% LoadUserControl(WebRoot + "UserControls/admid.ascx", null); %>
        <%if (order.Count > 0)
          {
              if (CurrentTeam.Farefree == 0 || CurrentTeam.Delivery == "coupon")
              {
        %>
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
        <%}
          }%>
        <div id="deal-default">
            <%LoadUserControl(WebRoot + "UserControls/blockshare.ascx", CurrentTeam); %>
            <div id="content">
                <div id="deal-intro" class="cf">
                    <h1>
                        <a class="deal-today-link" href="<%=getTeamPageUrl(int.Parse(team["id"].ToString())) %>">
                            <%=strtitle %>：</a><a class="deal-today-link-xx" href="<%=getTeamPageUrl(int.Parse(team["id"].ToString())) %>"><%=team["title"]%></a>
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
                                  {%>
                                <%if (CurrentTeam.Delivery == "draw")
                                  { %>
                                <a href="<%=WebRoot%>ajax/car.aspx?id=<%=team["id"] %>"><span class="button-deal-cj"></span></a>
                                <% }
                                  else
                                  {%>
                                <a href="<%=WebRoot%>ajax/car.aspx?id=<%=team["id"] %>"><span class="deal-price-buy"></span></a>
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
                            diff="<%=difftimefix %>" num="0">
                            <h3></h3>
                            <div class="limitdate">
                                    <%if ((CurrentTeam.End_time - DateTime.Now).Days > 3)
                                      { %>
                                     <ul><span style="font-size:20px;">3天以上</span></ul>
                                    <%}
                                      else
                                      { %>
                                    <ul id="counter0"><span>
                                        <%=(CurrentTeam.End_time-DateTime.Now).Hours %></span>时<span>
                                            <%=(CurrentTeam.End_time-DateTime.Now).Minutes %></span>分<span>
                                                <%=(CurrentTeam.End_time-DateTime.Now).Seconds %></span>秒 </ul>
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
                              { 
                            %>
                            <img <%=ashelper.getimgsrc(team["image"]) %> width="440" class="dynload" height="280" />
                            <%} %>
                        </div>
                        <div class="digest">
                            <br />
                            <%=team["Summary"] %>
                        </div>
                    </div>
                </div>
                <!--开始代码-->
                <div class="tuan_more">
                    <!--循环一日多团开始-->
                    <%int num = 1; %>
                    <%if (otherteams != null && otherteams.Count > 0)
                      { %>
                    <%foreach (ITeam model in otherteams)
                      {
                          string city = "";
                          if (model.City_id == 0)
                              city = "全部城市";
                          else
                          {
                              ICategory citymodel = null;
                              using (IDataSession session = Store.OpenSession(false))
                              {
                                  citymodel = session.Category.GetByID(model.City_id);
                              }
                              if (citymodel != null)
                                  city = citymodel.Name;
                              else
                                  city = "全部城市";
                          }
                    %>
                    <div id="abcd<%=num%>" <%  if (num % 2 == 0)
                                               { %> class="duotuan2_kj" <% }
                                               else
                                               {%>
                        class="duotuan_kj" <% }%> onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                        <div class="duotuan_title">
                            <font class="dtcity-color">
                                <%=city%>
                            </font><a target="_blank" href="<%=getTeamPageUrl(model.Id) %>">今日团购:<font style="font-weight: bold; color: Black;"><%=model.Title%></font></a>
                        </div>
                        <div class="dtcp_img">
                            <a target="_blank" href="<%=getTeamPageUrl(model.Id) %>">
                                <img <%=ashelper.getimgsrc(model.Image) %> class="dynload" width="335" height="220" /></a>
                        </div>
                        <div class="team-more-buy-new">
                            <div class="team-more-tag-new">
                            </div>
                            <div class="team-price-new">
                                <strong>
                                    <%=ASSystem.currency%><%=GetMoney(model.Team_price)%></strong> <span>
                                        <%if (GetState(model) == AS.Enum.TeamState.successnobuy)
                                          {%><a class="tuanmore_over_bt" target="_blank" href="<%=getTeamPageUrl(model.Id) %>">查看详情</a><%}
                                          else
                                          {%><a class="tuanmore_bt" target="_blank" href="<%=getTeamPageUrl(model.Id) %>">查看详情</a>
                                        <%} %>
                                    </span>
                            </div>
                            <div class="team-more-price">
                                <p class="through">
                                    原价：<b><%=GetMoney(model.Market_price)%>元</b>
                                </p>
                                <p>
                                    折扣：<b><%=WebUtils.GetDiscount(Helper.GetDecimal(model.Market_price, 0), Helper.GetDecimal(model.Team_price, 0))%></b>
                                </p>
                                <p>
                                    节省：<b><%=ASSystemArr["Currency"]%><%=GetMoney((Helper.GetDecimal(model.Market_price, 0) - Helper.GetDecimal(model.Team_price, 0)).ToString())%></b>
                                </p>
                            </div>
                        </div>
                        <%
                                          curtimefix = Helper.GetTimeFix(DateTime.Now) * 1000;
                                          difftimefix = Helper.GetTimeFix(model.End_time) * 1000;
                                          difftimefix = difftimefix - curtimefix;
          
                        %>
                        <div class="deal-timeleft stat" id="deal-timeleft" curtime="<%=curtimefix %>" diff="<%=difftimefix %>"
                            num="<%=num %>">
                            <div class="timer countdown">
                                    <%if ((model.End_time - DateTime.Now).Days > 3)
                                      { %>
                                    <ul class="duotuan_time">
                                   <span style="font-size:15px;">剩余时间：3天以上</span>
                                    </ul>
                                    <%}
                                      else
                                      { %>
                                    <ul id="counter<%=num %>" class="duotuan_time">
                                    <li><span>
                                        <%=(model.End_time - DateTime.Now).Hours%></span>小时</li>
                                    <li><span>
                                        <%=(model.End_time - DateTime.Now).Minutes%></span>分钟</li>
                                    <li><span>
                                        <%=(model.End_time - DateTime.Now).Seconds%></span>秒</li>
                                    </ul>
                                    <%} %>
                                
                            </div>
                            <div class="total">
                                <span class="num">
                                    <%=model.Now_number%></span>人已购买
                            </div>
                        </div>
                    </div>
                    <% num++; %>
                    <% }%>
                    <%} %>
                    <!--循环一日多团结束-->
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
        <!-- bd end -->
    </div>
    <!-- bdw end -->
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
