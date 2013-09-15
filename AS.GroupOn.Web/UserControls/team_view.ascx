<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">

    protected NameValueCollection team = new NameValueCollection();
    protected AS.Enum.TeamState state = AS.Enum.TeamState.none;
    protected DateTime overtime = DateTime.Now;  //团购结束时间l了11111111
    protected bool over = false;
    protected int imageindex = 2;
    protected NameValueCollection partner = new NameValueCollection();
    protected ITeam teammodel = Store.CreateTeam();
    protected IPartner part = Store.CreatePartner();
    protected DataTable dt1 = null;
    protected IPagers<IAsk> pager = null;
    protected IList<IAsk> listask = null;
    protected IList<ITeam> listTeam = null;
    protected IList<ITeam> listTeam1 = null;
    protected IList<ITeam> listTeam2 = null;
    protected IList<IBranch> listbranch = null;
    protected IList<IBranch> branches = null;
    protected string teamstatestring = String.Empty;//项目状态的英文soldout卖光,success成功,failure失败
    protected bool buy = true;//允许购买
    protected int ordercount = 0;//成功购买当前项目的订单数量
    protected int detailcount = 0;//成功购买当前项目数量
    protected int buycount = 0;//当前项目购买数量
    protected string buyurl = String.Empty;//购买按钮链接
    protected int twoline = 0;
    protected long curtimefix = 0;
    protected long difftimefix = 0;
    public string strtitle = "";
    public int i = 0;
    protected string mapInfo = String.Empty;//地图信息
    protected NameValueCollection order = new NameValueCollection();
    protected int size = 0;
    protected int offset = 0;
    public string strOtherTeamid = "";
    public NameValueCollection _system = new NameValueCollection();
    protected bool canLoadMap = false;//加载地图
    IList<IUserReview> listuserreview = null;

    public override void UpdateView()
    {

        _system = WebUtils.GetSystem();
        teammodel = Params as ITeam;
        if (WebUtils.config["maptype"] != null && WebUtils.config["maptype"].ToString().Length > 0 && teammodel != null && teammodel.Delivery == "coupon")
        {
            canLoadMap = true;
        }
        team = Helper.GetObjectProtery(teammodel);
        setBuyTitle();
        if (teammodel != null)
        {
            buyurl = Page.ResolveUrl(PageValue.WebRoot + "ajax/car.aspx?id=" + teammodel.Id);
        }
        if (teammodel == null)
        {
            Response.End();
            return;
        }
        twoline = (ASSystem.teamwhole == 0) ? 1 : 0;
        if (teammodel.Begin_time > DateTime.Now)//未开始项目
        {
            curtimefix = Helper.GetTimeFix(DateTime.Now) * 1000;
            difftimefix = Helper.GetTimeFix(teammodel.Begin_time) * 1000;
        }
        else
        {
            curtimefix = Helper.GetTimeFix(DateTime.Now) * 1000;
            difftimefix = Helper.GetTimeFix(teammodel.End_time) * 1000;
        }
        difftimefix = difftimefix - curtimefix;
        using (IDataSession sion = AS.GroupOn.App.Store.OpenSession(false))
        {
            part = sion.Partners.GetByID(teammodel.Partner_id);
        }

        if (part != null)
        {
            partner = Helper.GetObjectProtery(part);
            if (canLoadMap)
            {
                if (!String.IsNullOrEmpty(part.point) && part.point.IndexOf(",") >= 0)
                {
                    string[] points = part.point.Split(',');
                    mapInfo = "{\"name\":\"" + part.Title + "\", \"address\": \"" + part.Address + "\", \"tel\": \"" + part.Phone + "\", \"point\": \"" + points[1] + "," + points[0] + "\",\"citycode\":131}";

                }
                BranchFilter bf = new BranchFilter();
                bf.partnerid = part.Id;
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    branches = seion.Branch.GetList(bf);
                }
                if (branches != null && branches.Count > 0)
                {
                    foreach (var item in branches)
                    {
                        if (!String.IsNullOrEmpty(item.point) && item.point.IndexOf(",") >= 0)
                        {
                            string[] points = item.point.Split(',');
                            mapInfo = mapInfo + ",{\"name\":\"" + item.branchname + "\", \"address\": \"" + item.address + "\", \"tel\": \"" + item.phone + "\", \"point\": \"" + points[1] + "," + points[0] + "\",\"citycode\":131}";
                        }
                    }
                }
            }
        }
        BasePage bp = new BasePage();
        state = bp.GetState(teammodel);
        if (state == AS.Enum.TeamState.fail || state == AS.Enum.TeamState.successtimeover)
        {
            over = true;
            overtime = teammodel.End_time;
        }

        if (state == AS.Enum.TeamState.successnobuy)
        {
            over = true;
            if (teammodel.Close_time.HasValue)
                overtime = teammodel.Close_time.Value;
            else
                overtime = teammodel.End_time;
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
        if (teammodel.Team_type == "seconds")
        {
            strtitle = "今日秒杀";
        }
        if (teammodel.Team_type == "goods")
        {
            strtitle = "今日热销";
        }
        if (teammodel.Team_type == "normal")
        {
            strtitle = "今日团购";
        }
        if (teammodel.Min_number > 0)
        {
            size = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(190 * (Convert.ToDouble(teammodel.Now_number) / Convert.ToDouble(teammodel.Min_number)))));

            offset = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(5 * (Convert.ToDouble(teammodel.Now_number) / Convert.ToDouble(teammodel.Min_number)))));
        }
    }

    public override string CacheKey
    {
        get
        {

            ITeam _teammodel = null;
            _teammodel = Params as ITeam;
            if (_teammodel != null)
            {
                return "cacheusercontrol-team_view_" + _teammodel.Id.ToString();
            }
            return String.Empty;
        }

    }

    public override bool CanCache
    {
        get
        {
            return true;
        }
    }

    #region 显示项目答疑
    public string ListAsk()
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        AskFilter askf = new AskFilter();
        askf.IsComment = true;
        askf.PageSize = 15;
        askf.CurrentPage = Helper.GetInt(Request.QueryString["page"], 1);
        askf.AddSortOrder(AskFilter.Create_Time_DESC);
        if (ASSystem.teamask == 0)
        {
            askf.Team_ID = teammodel.Id;
        }

        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = seion.Ask.GetPager(askf);
        }

        listask = pager.Objects;
        if (listask != null && listask.Count > 0)
        {
            foreach (IAsk ask in listask)
            {

                if (ask.Comment != null && ask.Comment.ToString() != "")
                {
                    sb.Append("<li id=\"ask-entry-" + ask.Id.ToString() + "\" >");
                    sb.Append("<div class=\"item\">");

                    IUser usermodel = Store.CreateUser();

                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        usermodel = seion.Users.GetByID(ask.User_id);
                    }

                    string username = String.Empty;
                    if (usermodel != null)
                    {
                        username = usermodel.Username;
                    }
                    sb.Append("<p class=\"user\"><strong>" + username + "</strong><span>" + DateTime.Parse(ask.Create_time.ToString()).ToString("yy-MM-dd") + "</span></p>");
                    sb.Append("<div class=\"clear\"></div>");
                    sb.Append("<p class=\"text\">" + ask.Content + "</p>");
                    sb.Append("<p class=\"reply\"><strong>回复：</strong>" + ask.Comment + "</p>");
                    sb.Append("</div>");
                    sb.Append("</li>");

                }

            }

        }
        return sb.ToString();
    }
    #endregion
    /// <summary>
    /// 买家评论内容
    /// </summary>
    public void setBuyTitle()
    {
        UserReviewFilter userreviewfilter = new UserReviewFilter();
        userreviewfilter.TState = 2;
        userreviewfilter.AddSortOrder(UserReviewFilter.t1_desc);
        if (_system["navUserreview"] != null && _system["navUserreview"] == "1")
        {
            if (_system["UserreviewYN"] != null && _system["UserreviewYN"] == "1")
            {
                userreviewfilter.TState2 = 1;
            }

            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                listuserreview = seion.UserReview.GetByContent(userreviewfilter);
            }

        }

    }

    /// <summary>
    /// 是否显示提交的评价框
    /// </summary>
    public bool resultValue()
    {
        bool result = false;
        int cnt = 0;
        UserFilter userf = new UserFilter();
        OrderFilter orderf = new OrderFilter();
        UserReviewFilter userReviewf = new UserReviewFilter();
        IUser userinfo = null;
        userf.Username = CookieUtils.GetCookieValue("username", FileUtils.GetKey());
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            userinfo = session.Users.GetByName(userf);
        }
        if (userinfo != null)
        {
            int userid = userinfo.Id;
            int userreviewid = 0;
            //查找用户是否购买过此项目
            orderf.User_id = userid;
            orderf.TeamOr = teammodel.Id;
            userReviewf.team_id = teammodel.Id;
            userReviewf.user_id = userid;

            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                cnt = seion.Orders.GetUnpay(orderf);
            }
            if (cnt > 0)
            {
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    userreviewid = seion.UserReview.GetTop1Id(userReviewf);
                }
                //用户是否参与过评价
                if (userreviewid <= 0)
                {
                    result = true;
                }
            }

        }

        return result;

    }

    /// <summary>
    /// 返回指定时间之差
    /// </summary>
    /// <param name="DateTime1">当前时间</param>
    /// <param name="DateTime2">之前时间</param>
    /// <returns></returns>
    public string returnTime(DateTime DateTime1, DateTime DateTime2)
    {
        string dateDiff = null;

        TimeSpan ts1 = new TimeSpan(DateTime1.Ticks);
        TimeSpan ts2 = new TimeSpan(DateTime2.Ticks);
        TimeSpan ts = ts1.Subtract(ts2).Duration();
        if (ts.Days > 0)
        {
            dateDiff += ts.Days.ToString() + "天";
        }
        if (ts.Hours > 0)
        {
            dateDiff += ts.Hours.ToString() + "小时";
        }
        if (ts.Minutes > 0)
        {
            dateDiff += ts.Minutes.ToString() + "分钟";
        }
        return dateDiff;

    }

</script>
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
<%} %>
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
                }
                else {
                    $("#counter").html("<span>" + hour + "</span>时<span>" + minite + "</span>分<span>" + second + "</span>秒");
                }
            }
            else {
                window.clearInterval(InterValObj);
            }
        }
    });
</script>
<div id="content">
    <div id="deal-intro" class="cf">
        <h1>
            <%if (!over)
              { %><a class="deal-today-link" href="<%=getTeamPageUrl(int.Parse(team["id"].ToString()))%>"><%=strtitle%>:</a>
            <%} %>
            <a style="text-decoration: none;" class="deal-today-link-xx">
                <%=team["title"] %></a>
        </h1>
        <div class="main">
            <div class="deal-buy">
                <div class="deal-price-tag">
                </div>
                <%if (state == AS.Enum.TeamState.successnobuy)
                  { %>
                <p class="deal-price" id="deal-price">
                    <strong>
                        <%=ASSystemArr["currency"] %><%=GetMoney(team["team_price"]) %></strong><span class="deal-price-over"></span>
                </p>
                <%}
                  else if (over)
                  { %>
                <p class="deal-price" id="deal-price">
                    <strong>
                        <%=ASSystemArr["Currency"] %><%=GetMoney(team["team_price"]) %></strong><span class="deal-price-end"></span>
                </p>
                <%}
                  else
                  {
                %>
                <p class="deal-price" id="deal-price">
                    <strong>
                        <%=ASSystemArr["Currency"] %><%=GetMoney(team["team_price"]) %></strong>
                    <%if (teammodel.Begin_time <= DateTime.Now)
                      { %>
                    <%
                          if (teammodel.Delivery == "draw")
                          { %>
                    <a href="<%=buyurl %>"><span class="button-deal-cj"></span></a>
                    <% }
                          else
                          {
                              if (teammodel.invent_result != null)
                              {
                                  if (teammodel.invent_result.Contains("价格"))
                                  {%>
                    <span class="deal-price-buy" onclick="addbuyurl();"></span>
                    <%}
                                else
                                {%>
                    <a href="<%=buyurl %>"><span class="deal-price-buy"></span></a>
                    <%}
                            }
                            else
                            {%>
                    <a href="<%=buyurl %>"><span class="deal-price-buy"></span></a>
                    <%}%>
                    <% }%>
                    <% }
                      else
                      {%>
                    <a href="#"><span class="deal-price-notstart"></span></a>
                    <% }%>
                </p>
                <%} %>
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
                        <%=ASSystemArr["Currency"] %><%=GetMoney(Helper.GetDecimal(team["Market_price"], 0) - Helper.GetDecimal(team["Team_price"], 0))%>
                    </td>
                </tr>
            </table>
            <%if (over)
              { %>
            <div class="deal-box deal-timeleft deal-off" id="deal-timeleft" curtime="<%=curtimefix %>"
                diff="<%=difftimefix %>">
                <div class="limitdate">
                    <p class="deal-buy-ended">
                        <%= overtime.ToString("yyyy年MM月dd日hh点MM分")%><br />
                    </p>
                </div>
            </div>
            <%}
              else
              { %>
            <%if (teammodel.Begin_time <= DateTime.Now)
              {
            %>
            <div class="deal-box deal-timeleft deal-on" id="deal-timeleft" curtime="<%=curtimefix %>"
                diff="<%=difftimefix %>">
                <h3></h3>
                <div class="limitdate">

                    <%if ((teammodel.End_time - DateTime.Now).Days >= 3)
                      { %>
                    <ul>
                        <span style="font-size: 20px;">3天以上</span>
                    </ul>
                    <%}
                      else
                      { %>
                    <ul id="counter">
                        <%if ((teammodel.End_time - DateTime.Now).Days > 0)
                          {%>
                        <span><%=(teammodel.End_time - DateTime.Now).Days%></span>天 
                              <%}%>
                        <span><%=(teammodel.End_time - DateTime.Now).Hours%></span>时<span>
                            <%=(teammodel.End_time - DateTime.Now).Minutes%></span>分<span>
                                <%=(teammodel.End_time - DateTime.Now).Seconds%></span>秒
                    </ul>
                    <%} %>
                </div>
            </div>
            <%}
              else
              {%>
            <div class="deal-box deal-timeleft deal-deal_start" id="deal-timeleft" curtime="<%=curtimefix %>"
                diff="<%=difftimefix %>">
                <h3></h3>
                <div class="limitdate">
                    <%if ((teammodel.Begin_time - DateTime.Now).Days > 0)
                      { %>
                    <ul>
                        <span style="font-size: 20px;">3天以上</span>
                    </ul>
                    <%}
                      else
                      { %>
                    <ul id="counter">
                        <%if ((teammodel.End_time - DateTime.Now).Days > 0)
                          {%>
                        <span><%=(teammodel.End_time - DateTime.Now).Days%></span>天 
                              <%}%>
                        <span><%=(teammodel.Begin_time - DateTime.Now).Hours%></span> 时<span>
                            <%=(teammodel.Begin_time - DateTime.Now).Minutes%></span>分<span>
                                <%=(teammodel.Begin_time - DateTime.Now).Seconds%></span>秒
                    </ul>
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
                <%if (team["Conduser"] == "Y")
                  {%><p class="deal-buy-tip-top">
                      <strong>
                          <%=team["Now_number"]%>
                      </strong>人已购买
                  </p>
                <%}

                  else
                  { %><p class="deal-buy-tip-top">
                      <strong>已购买<%=team["Now_number"]%>
                      </strong>件
                  </p>
                <%} %>
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

                <%if (teammodel.Max_number > 0)
                  { %>
                <p class="deal-buy-tip-btm">
                    还差 <strong>
                        <%= (teammodel.Min_number-teammodel.Now_number) %></strong> 人到达最低团购人数
                </p>
                <%} %>
            </div>
            <%if (teammodel.Delivery == "coupon" && teammodel.isrefund == "Y")
              {%>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="back-money">支持"7天退款"</span> <span class="over-times">支持"过期退款"</span>
            </div>
            <%}
              else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "S")
              { %>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="back-money">支持"7天退款"</span> <span class="none-over-times">支持"过期退款"</span>
            </div>
            <%}
              else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "G")
              { %>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="none-back-money">支持"7天退款"</span> <span class="over-times">支持"过期退款"</span>
            </div>
            <%}
              else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "N")
              { %>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="none-back-money">不支持"7天退款"</span> <span class="none-over-times">不支持"过期退款"</span>
            </div>
            <%}
              else if (teammodel.Delivery == "coupon")
              { %>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="none-back-money">不支持"7天退款"</span> <span class="none-over-times">不支持"过期退款"</span>
            </div>
            <%} %>
            <%}
              else if (state == AS.Enum.TeamState.successbuy)
              { %>
            <div class="deal-box deal-status deal-status-open" id="deal-status">
                <p class="deal-buy-tip-top">
                    <%if (team["Conduser"] == "Y")
                      {%>
                    <strong>
                        <%=team["Now_number"]%></strong> 人已购买
                    <%}
                      else
                      { %>
                    <strong>已购买<%=team["Now_number"]%>
                    </strong>件<%} %>
                </p>

                <%if (teammodel.Max_number > 0 && teammodel.Max_number > teammodel.Now_number)
                  { %>

                <p class="deal-buy-tip-btm">
                    本单仅剩：<strong><%=teammodel.Max_number-teammodel.Now_number %></strong>份，欲购从速
                </p>

                <%} %>
                <%if (teammodel.Now_number >= teammodel.Min_number)
                  { %>

                <p class="deal-buy-on" style="line-height: 200%;">
                    <img src="<%=ImagePath() %>deal-buy-succ.gif" />
                    团购成功
                    <% }%>
                    <%if ((teammodel.Max_number == 0) || (teammodel.Max_number - teammodel.Now_number) > 0)
                      { %>
                    可以继续购买<%} %>
                </p>
                <%if (teammodel.Reach_time.HasValue)
                  { %>
                <p class="deal-buy-tip-btm">
                    <%=teammodel.Reach_time.Value.ToString("MM-dd HH:mm") %><br />
                    达到最低团购人数：<strong><%=teammodel.Min_number %></strong>人
                </p>
                <%} %>
            </div>
            <%if (teammodel.Delivery == "coupon" && teammodel.isrefund == "Y")
              {%>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="back-money">支持"7天退款"</span> <span class="over-times">支持"过期退款"</span>
            </div>
            <%}
              else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "S")
              { %>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="back-money">支持"7天退款"</span> <span class="none-over-times">支持"过期退款"</span>
            </div>
            <%}
              else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "G")
              { %>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="none-back-money">支持"7天退款"</span> <span class="over-times">支持"过期退款"</span>
            </div>
            <%}
              else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "N")
              { %>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="none-back-money">不支持"7天退款"</span> <span class="none-over-times">不支持"过期退款"</span>
            </div>
            <%}
              else if (teammodel.Delivery == "coupon")
              { %>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="none-back-money">不支持"7天退款"</span> <span class="none-over-times">不支持"过期退款"</span>
            </div>
            <%} %>
            <%} %>
            <%}
              else
              { %>
            <div class="deal-box deal-status deal-status-<%=teamstatestring %>" id="deal-status">
                <div class="deal-buy-<%=teamstatestring %>">
                </div>
                <p class="deal-buy-tip-total">
                    共有 <strong>
                        <%= teammodel.Now_number%></strong> 人购买
                </p>
            </div>
            <%if (teammodel.Delivery == "coupon" && teammodel.isrefund == "Y")
              {%>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="back-money">支持"7天退款"</span> <span class="over-times">支持"过期退款"</span>
            </div>
            <%}
              else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "S")
              { %>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="back-money">支持"7天退款"</span> <span class="none-over-times">支持"过期退款"</span>
            </div>
            <%}
              else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "G")
              { %>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="none-back-money">支持"7天退款"</span> <span class="over-times">支持"过期退款"</span>
            </div>
            <%}
              else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "N")
              { %>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="none-back-money">不支持"7天退款"</span> <span class="none-over-times">不支持"过期退款"</span>
            </div>
            <%}
              else if (teammodel.Delivery == "coupon")
              { %>
            <div class="deal-box deal-status-refund" id="refund">
                <span class="none-back-money">不支持"7天退款"</span> <span class="none-over-times">不支持"过期退款"</span>
            </div>
            <%} %>
            <%} %>
            <!--购物车代码开始-->
            <%if ((_system["isguige"] != null && _system["isguige"].ToString() == "1") || (teammodel.invent_result != null && teammodel.invent_result.Contains("价格")))
              {%>


            <%if (!over && teammodel.Begin_time <= DateTime.Now && teammodel.Delivery == "express" && teammodel.bulletin.Replace("{", "").Replace("}", "") != "")
              {%>
            <div class="deal-color">
                <script type="text/javascript">
                    var rule = "";
                    var haveNum = "";
                    //attrnameid:规格id attrnanevalue:规格名称   attrvalueid：规格值id attrvalue:规格值
                    function setattrvalue(attrnameid, attrnanevalue, attrvalueid, attrvalue) {
                        for (var i = 0; i < attrnameid + 1; i++) {
                            $("#greyspan0_" + attrnameid).attr("class", "");
                        }
                        $("#s_attr_name" + attrnameid).html(attrvalue);
                        $("#attr_value_" + attrnameid).val(attrnanevalue);
                        var redspan = $("#redspan" + attrnameid).val();
                        if (redspan != null && redspan != "" && redspan != attrvalue) {
                            $("[name='greyspan" + attrnameid + "']").attr("class", "td28");
                        }

                        $("#greyspan" + attrvalueid + "_" + attrnameid).attr("class", "ulliahover");
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
                                if (hidattrname.substring(0, 1) == ",") {
                                    hidattrname = hidattrname.substring(1);
                                }
                                $("#hidattrname").val(hidattrname);
                            }
                        }

                        //判断用户是否选择全了规格
                        var attrvales = $("#hidattrvale").val();
                        var result = $("#hidattrname").val();
                        //alert(result);
                        var c_reslut = result.split(',');
                        var falg = "0";
                        var c_str = "";
                        for (var i = 0; i < c_reslut.length; i++) {
                            c_str += c_reslut[i].split(':')[0] + ",";
                        }

                        if (c_str.indexOf(attrvales) > -1) {
                            falg = "1";
                        }
                        if (falg == "1")//选择全了规格
                        {
                            if (result.substring(0, 1) == ",") {
                                result = result.substring(1);
                            }
                            //保存用户选择的规格
                            $("#results").val(result);
                            if ('<%=teammodel.invent_result%>' != "" & result != "") {
                                var oldrulemo = new Array();
                                oldrulemo = '<%=teammodel.invent_result%>'.replace("{", "").replace("}", "").split('|');
                                for (var i = 0; i < oldrulemo.length; i++) {
                                    if (oldrulemo[i].indexOf(result) >= 0) {
                                        rule = oldrulemo[i];
                                    }
                                }
                                if (rule.indexOf("价格") >= 0) {
                                    rule = rule.substring(0, rule.lastIndexOf(','));

                                    rule = rule.substring(rule.lastIndexOf(',')).replace(",", "").replace("价格", "").replace(":", "").replace("[", "").replace("]", "");
                                }

                                else {
                                    rule = '<%=teammodel.Team_price %>';
                                }

                            }
                            if (rule != "") {
                                //去掉钱后面的0
                                var reg = /^(\d+)$|^(\d+.[1-9])0$|^(\d+).00$/;
                                reg.exec(rule);
                                rule = rule.replace(rule, RegExp.$1 + RegExp.$2 + RegExp.$3);
                                $("#deal-price strong").html("<%=ASSystemArr["Currency"] %>" + rule);
                                $("#moneys").val(rule);
                            }
                        }
                    }

                    function addbuyurl() {
                        var teamid = $("#hidteamid").val();
                        var result = $("#hidattrname").val();
                        if (result.substring(0, 1) == ",") {
                            result = result.substring(1);
                        }
                        var _result = "{" + result + ",数量:[1]}";
                        X.get(webroot + 'ajax/car.aspx?action=notprice&addteamid=' + teamid + "&num=1&result=" + encodeURIComponent(_result) + "&m_rule=" + $("#moneys").val() + "&a=" + Math.random());
                    }

                    $(document).ready(function () {
                        $("#addshopcar").click(function () {
                            var result = $("#hidattrname").val();
                            var num = $("#txtcurrshopmax").val();
                            if (parseInt(num) < 1) {
                                alert("数量不能小于1");
                                $("#txtcurrshopmax").val("1");
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
                            if ($("#addbuy").val() != undefined) {
                                X.get(webroot + 'ajax/car.aspx?action=notprice&addteamid=' + teamid + "&num=" + num + "&result=" + encodeURIComponent(_result) + "&m_rule=" + $("#moneys").val() + "&a=" + Math.random());
                            } else {
                                X.get(webroot + 'ajax/car.aspx?action=carinfo&addteamid=' + teamid + "&num=" + num + "&result=" + encodeURIComponent(_result) + "&m_rule=" + rule + "&a=" + Math.random());
                            }

                        });
                    });

                </script>
                <!--循环项目规格信息-->
                <%if (teammodel.bulletin.Replace("{", "").Replace("}", "") != "")
                  {%>

                <%=Utilys.Getfont2(teammodel.Id, teammodel.bulletin)%>

                <% } %>
                <!--循环项目规格信息结束-->

                <%if (teammodel.bulletin.Replace("{", "").Replace("}", "") != "")
                  {
                %>
                <table class="TB">
                    <tbody>
                        <tr>
                            <td>
                                <span style="height: 30px; line-height: 20px;">购买数量：
                                 <input type="text" maxlength="4" class="tdip" size="4" onkeyup="showme()" value="1" style="font-size: 12px;" id="txtcurrshopmax" /></span>
                                <input type="hidden" value="" id="results" name="results" />
                                <script type="text/javascript">
                                    function showme() {
                                        var minnumber = $("#minnumber").val();
                                        var maxnumber = <%=teammodel.Per_number %>;
                                        if (maxnumber!=0) {
                                            if(parseInt(minnumber)>parseInt(maxnumber))
                                            {
                                                alert("本项目最多可以购买"+maxnumber+"个");
                                                $("#minnumber").val(maxnumber);
                                            }
                                        }
                                    }
                                </script>
                                <% if (Utilys.GetTeamType(teammodel.Id))
                                   { %>
                                <input type="hidden" value="addbuy" id="addbuy" />
                                <a href="javascript:void(0)">
                                    <input type="button" value="购买" id="addshopcar" class="formbutton1" style="height: 20px; width: 45px; margin-left: 10px; margin-top: 0px;" /></a>
                                <input type="hidden" id="moneys" value="<%=GetMoney(team["team_price"]) %>" />
                                <%}
                                   else
                                   { %>
                                <input type="hidden" id="moneys" value="<%=GetMoney(team["team_price"]) %>" />
                                <a href="javascript:void(0)">
                                    <img src="/upfile/css/i/ljgm_15.gif" id="addshopcar" /></a>
                                <%} %>
                                <input type="hidden" value="<%=teammodel.Id %>" id="hidteamid" />
                            </td>
                            <td><span id="msshow"></span></td>
                        </tr>
                        <tr>
                            <td></td>
                        </tr>
                    </tbody>
                </table>
                <%}%>
            </div>
            <% } %>
            <%} %>
            <!--购物车代码结束-->
        </div>
        <div class="side">
            <div class="deal-buy-cover-img" id="team_images">
                <div id="zk">
                    <p>
                        <span class="zk">
                            <%=WebUtils.GetDiscount(Helper.GetDecimal(team["Market_price"], 0),Helper.GetDecimal(team["Team_price"], 0)).Replace("折", "")%></span>
                    </p>
                </div>
                <%if (team["image1"] != String.Empty || team["image2"] != String.Empty)
                  { %>
                <div class="mid">
                    <ul>
                        <li class="first">
                            <img src="<%=team["image"] %>" /></li>
                        <%if (team["image1"] != String.Empty)
                          { %>
                        <li>
                            <img src="<%=team["image1"] %>" /></li>
                        <%} %>
                        <%if (team["image2"] != String.Empty)
                          { %>
                        <li>
                            <img src="<%=team["image2"] %>" /></li>
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
                <img src="<%=team["image"] %>" width="440" height="280" />
                <%} %>
            </div>
            <div class="digest">
                <br />
                <%=team["Summary"] %>
            </div>
        </div>
    </div>
    <!--今日其他团购开始-->
    <%

        TeamFilter tf = new TeamFilter();
        TeamFilter tf1 = new TeamFilter();

        //  Maticsoft.BLL.catalogs catabll = new Maticsoft.BLL.catalogs();

        int num = 0;
        string wherestr = "";

        int teamdetailnum = 0;
        string sql = "";
        if (WebUtils.config["teamdetailnum"] != null && WebUtils.config["teamdetailnum"].ToString() != "")
        {
            teamdetailnum = Helper.GetInt(WebUtils.config["teamdetailnum"], 0);
        }

        string samstr = "";
        string cid = "";

        if (CurrentCity != null)
        {
            tf.Cityblockothers = CurrentCity.Id;
            tf1.Cityblockothers = CurrentCity.Id;
        }
        else
        {
            tf.DA_City_id = 0;
            tf1.DA_City_id = 0;
        }

        if (teammodel != null)
        {
            if (teammodel.cataid != 0)
            {
                if (Helper.GetString(Catalogs.GetCataId(teammodel.cataid), "") != "")
                {
                    samstr = samstr + " and cataid in (" + Catalogs.GetCataId(teammodel.cataid) + ")";
                    tf.CataIDin = Catalogs.GetCataId(teammodel.cataid);

                    wherestr = wherestr + " and  cataid not in (" + Catalogs.GetCataId(teammodel.cataid) + ")";
                    tf1.CataIDNotin = Catalogs.GetCataId(teammodel.cataid);
                }
            }
        }

        tf.Top = teamdetailnum;
        tf.teamcata = 0;
        tf.ToBegin_time = DateTime.Now;
        tf.FromEndTime = DateTime.Now;
        tf.AddSortOrder(TeamFilter.MoreAsc);
        tf.No_Id = Helper.GetInt(team["id"], 0);
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            listTeam = seion.Teams.GetList(tf);
        }

        if (listTeam.Count < teamdetailnum)
        {
            num = teamdetailnum - listTeam.Count;
        }

        string bb = "select top " + teamdetailnum + " id,title,image,market_price,team_price,sort_order,begin_time from team where teamcata=0 and id<>" + team["id"] + samstr + " and begin_time<='" + DateTime.Now + "' and end_time>='" + DateTime.Now + "' and teamcata=0  and Team_type='normal'  order by Sort_order asc,begin_time asc,id asc";
        string aa = "select top " + num + " id,title,image,market_price,team_price,sort_order,begin_time from team where  teamcata=0 and id<>" + team["id"] + wherestr + " and begin_time<='" + DateTime.Now + "' and end_time>='" + DateTime.Now + "' and teamcata=0  and Team_type='normal' order by Sort_order asc,begin_time asc ,id asc";


        tf1.Top = num;
        tf1.teamcata = 0;
        tf1.No_Id = Helper.GetInt(team["id"], 0);
        tf1.ToBegin_time = DateTime.Now;
        tf1.FromEndTime = DateTime.Now;
        tf1.Team_type = "normal";
        tf1.AddSortOrder(TeamFilter.MoreAsc);

        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            listTeam1 = seion.Teams.GetList(tf1);
        }

        if ((listTeam1 != null && listTeam1.Count > 0) || (listTeam != null && listTeam.Count > 0))
        {
            
    %>
    <div class="today_other_teams">
        <h2></h2>
        <ul class="today_other_box">
            <%
            
            if (listTeam != null && listTeam.Count > 0)
            {
                foreach (ITeam dro in listTeam)
                {%>
            <%
                                            
                    strOtherTeamid = strOtherTeamid + "," + dro.Id.ToString();
            %>
            <li class="today_other_list">
                <div class="link" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                    <a href="<%=getTeamPageUrl(int.Parse( dro.Id.ToString()))  %>">
                        <img height="129" width="215" src="<%= ImageHelper.getSmallImgUrl(dro.Image) %>"
                            alt="<%=dro.Title %>" title="<%=dro.Title %>" /></a>
                    <div class="name">
                        <a href="<%=getTeamPageUrl(int.Parse( dro.Id.ToString()))  %>">
                            <%=dro.Title%></a>
                    </div>
                </div>
                <span class="market-price gray">原价：<span class="arial"><%=ASSystemArr["Currency"]%></span><%=GetMoney(dro.Market_price)%></span><span
                    class="team-price"><span class="gray bold">现价：</span><span class="pink bold"><span
                        class="arial"><%=ASSystemArr["Currency"]%></span><%=GetMoney(dro.Team_price)%></span></span>
                <a class="qiangou pink bold f14" href="<%=getTeamPageUrl(int.Parse( dro.Id.ToString()))  %>"
                    title="<%=dro.Title %>">查看详情》</a></li>




            <%}
            }


            TeamFilter teamf = new TeamFilter();
            teamf.Top = num;
            teamf.teamcata = 0;
            teamf.Team_type = "normal";
            teamf.No_Id = Helper.GetInt((team["id"] + wherestr), 0);
            teamf.ToBegin_time = DateTime.Now;
            teamf.FromEndTime = DateTime.Now;
            teamf.AddSortOrder(TeamFilter.MoreAsc);

            if (strOtherTeamid.Length > 0)
            {
                string strID = strOtherTeamid.Substring(1);
                teamf.IdnotIn = strID;
                using (IDataSession sion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    listTeam2 = sion.Teams.GetList(teamf);
                }
            }
            else
            {
                using (IDataSession sion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    listTeam2 = sion.Teams.GetList(teamf);
                }
            }
                                 
            %>
            <%    if (listTeam2 != null && listTeam2.Count > 0)
                  {

                      foreach (ITeam list2 in listTeam2)
                      {%>
            <%

                          strOtherTeamid = strOtherTeamid + "," + list2.Id.ToString(); 
      
            %>
            <li class="today_other_list">
                <div class="link" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                    <a href="<%=getTeamPageUrl(int.Parse(list2.Id.ToString()))  %>">
                        <img height="129" width="215" src="<%= ImageHelper.getSmallImgUrl(list2.Image) %>" /></a>
                    <div class="name">
                        <a href="<%=getTeamPageUrl(int.Parse( list2.Id.ToString()))  %>">
                            <%=list2.Title%></a>
                    </div>
                </div>
                <span class="market-price gray">原价：<span class="arial"><%=ASSystemArr["Currency"]%></span><%=GetMoney(list2.Market_price)%></span><span
                    class="team-price"><span class="gray bold">现价：</span><span class="pink bold"><span
                        class="arial"><%=ASSystemArr["Currency"]%></span><%=GetMoney(list2.Team_price)%></span></span><a
                            class="qiangou pink bold f14" href="<%=getTeamPageUrl(int.Parse(list2.Id.ToString()))  %>">
                            查看详情》</a></li>
            <%}

                  }%>
        </ul>
    </div>
    <%}
        
    %>
    <!--今日其他团购结束-->
    <%
        if (team["shanhu"] == "0")
        { %>
    <!--老模式开始-->
    <div id="deal-stuff" class="cf">
        <div class="clear box <%if (team["Partner_id"] != "0" && ASSystemArr["teamwhole"] == "Y")
                                { %> box-split <%} %>">
            <div class="box-content cf">
                <div class="main" id="team_main_side">
                    <%if (team["detail"] != String.Empty)
                      { %>
                    <h2 id="H1">
                        <img src="<%=ImagePath() %>bdxq.jpg" alt="本单详情" /></h2>
                    <div class="blk detail" zoom_img_width="435">
                        <%=ashelper.returnContentDetail(team["detail"].ToString())%>
                    </div>
                    <%} %>
                    <%if (!String.IsNullOrEmpty(team["notice"]))
                      { %>
                    <h2 id="H2">
                        <img src="<%=ImagePath() %>tbts.jpg" alt="特别提示" /></h2>
                    <div class="blk cf" zoom_img_width="435">
                        <%=team["notice"]%>
                    </div>
                    <%} %>
                    <%if (!String.IsNullOrEmpty(team["userreview"]))
                      { %>
                    <h2 id="H3">
                        <img src="<%=ImagePath() %>tms.jpg" alt="他们说" /></h2>
                    <div class="blk review" zoom_img_width="435">
                        <%=PageValue.GetSpilt(team["userreview"])%>
                    </div>
                    <%} %>
                    <%if (!String.IsNullOrEmpty(team["systemreview"]))
                      { %>
                    <h2 id="H4">
                        <%=ASSystemArr["abbreviation"]%>说</h2>
                    <div class="blk review" zoom_img_width="435">
                        <%=team["systemreview"]%>
                    </div>
                    <%} %>
                    <%--2.28添加抢购--%>
                    <%if (state == AS.Enum.TeamState.successnobuy)
                      { %>
                    <%}
                      else if (over)
                      { %>
                    <%}
                      else
                      {%>
                    <%if (teammodel.Begin_time <= DateTime.Now)
                      {
                      
                    %>
                    <%if (teammodel.Delivery == "draw")
                      { %>
                    <div class="buttonbuy">
                        心动团购价 <strong>
                            <%=ASSystemArr["currency"] %><%=GetMoney(team["team_price"]) %>
                        </strong><a href="<%=buyurl %>"><span class="deal-price-buy"></span></a>
                    </div>
                    <% }
                      else
                      {%>
                    <div class="buttonbuy">
                        心动团购价 <strong>
                            <%=ASSystemArr["currency"] %><%=GetMoney(team["team_price"]) %></strong>
                        <%if (teammodel.invent_result != null)
                          {
                              if (teammodel.invent_result.Contains("价格"))
                              {%>
                        <span class="deal-price-buy" onclick="addbuyurl();"></span>
                        <%}
                              else
                              {%>
                        <a href="<%=buyurl %>"><span class="deal-price-buy"></span></a>
                        <%}
                          }
                          else
                          {%>
                        <a href="<%=buyurl %>"><span class="deal-price-buy"></span></a>
                        <%}%>
                    </div>
                    <% }%>
                    <% }
                      else
                      {%>
                    <%-- <a href="#"><span class="deal-price-notstart"></span></a>--%>
                    <% }%>
                    <%} %>
                </div>
                <div class="side" id="team_partner_side_0">
                    <div id="side-business">
                        <div>
                            <h2>
                                <a href="<%=GetUrl("品牌商户详情","partner_view.aspx?id="+partner["id"])%>">
                                    <%=partner["title"]%></a></h2>
                            <%if (partner["Contact"] != null && partner["Contact"].ToString() != "")
                              { %>
                            <div style="margin-top: 10px;">
                                联系人:<%=partner["Contact"]%>
                            </div>
                            <%} %>
                            <%if (partner["Phone"] != null && partner["Phone"].ToString() != "")
                              { %>
                            <div style="margin-top: 10px;">
                                联系电话:<%=partner["Phone"]%>
                            </div>
                            <%} %>
                            <%if (partner["Mobile"] != null && partner["Mobile"].ToString() != "")
                              { %>
                            <div style="margin-top: 10px;">
                                手机号码:<%=partner["Mobile"]%>
                            </div>
                            <%} %>
                            <%if (partner["Address"] != null && partner["Address"].ToString() != "")
                              { %>
                            <div style="margin-top: 10px;">
                                商户地址:<%=partner["Address"]%>
                            </div>
                            <%} %>
                            <%if (partner["location"] != null && partner["location"].ToString() != "")
                              { %>
                            <div style="margin-top: 10px;">
                                位置信息:<%=partner["location"]%>
                            </div>
                            <%} %>
                            <%if (partner["Other"] != null && partner["Other"].ToString() != "")
                              { %>
                            <div style="margin-top: 10px;">
                                其它信息:<%=partner["Other"]%>
                            </div>
                            <%} %>
                            <%if (partner["homepage"] != null)
                              { %><div style="margin-top: 10px;">
                                  <a href="http://<%=partner["homepage"] %>" target="_blank">
                                      <%=partner["homepage"].Replace("http://", "")%></a>
                              </div>
                            <%} %>
                        </div>
                        <%if (canLoadMap && mapInfo != String.Empty)
                          {%>
                        <div id="container" style="border: solid 1px #ccc;"></div>
                        <%} %>
                        <!--分站开始-->
                        <%
            if (partner["id"] != null)
            {
                BranchFilter bf = new BranchFilter();
                bf.partnerid = Helper.GetInt(partner["id"], 0);
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    listbranch = seion.Branch.GetList(bf);
                }
                int loopid = 1;
                if (listbranch != null && listbranch.Count > 0)
                {
                    foreach (IBranch row in listbranch)
                    {
                                        
                                                             
                        %>
                        <div>
                            <div style="margin-top: 10px;">
                                <h2>
                                    <%=row.branchname%></h2>
                            </div>
                            <%if (row.contact.ToString() != "")
                              { %>
                            <div style="margin-top: 10px;">
                                <span class="sjinfo_tt">联系人：</span>
                                <%=row.contact.ToString()%>
                            </div>
                            <%} %>
                            <%if (row.phone != "")
                              { %>
                            <div style="margin-top: 10px;">
                                <span class="sjinfo_tt">联系电话：</span><%=row.phone%>
                            </div>
                            <%} %>
                            <%if (row.address != null && row.address.ToString() != "")
                              { %>
                            <div style="margin-top: 10px;">
                                <span class="sjinfo_tt">商户地址：</span><%=row.address%>
                            </div>
                            <%} %>
                            <%if (row.mobile != null && row.mobile.ToString() != "")
                              { %>
                            <div style="margin-top: 10px;">
                                <span class="sjinfo_tt">手机号码：</span><%=row.mobile %>
                            </div>
                            <%} %>
                        </div>
                        <%loopid++;
                    }
                }
            }%>
                        <!--分站结束-->
                    </div>
                </div>
                <div class="clear">
                </div>
            </div>
        </div>
    </div>
    <!--老模式结束-->
    <% }
        else
        {%>
    <!--修改代码开始-->
    <div id="deal-stuff1" class="cf1">
        <div class="clear box ">
            <div class="box-content2 cf1">
                <div class="slider-wrap">
                    <div class="xxk">
                        <div id="page-wrap">
                            <!--切换修改开始-->
                            <div id="organic-tabs">
                                <ul id="explore-nav" class="xuanxiangk">
                                    <li class="bb" id="tb_1"><a href="#">本单详情</a></li>
                                    <li class="aa" id="tb_2"><a href="#">项目答疑</a></li>
                                    <% if (_system["navUserreview"] != null && _system["navUserreview"].ToString() == "1")
                                       {%>
                                    <li class="aa" id="tb_3"><a href="#">买家评论</a></li>
                                    <%}%>
                                    <%if (ASSystem.teamwhole == 1 && part != null)
                                      { %>
                                    <li class="aa" id="tb_4"><a href="#">商家信息</a></li>
                                    <%} %>
                                </ul>
                                <div id="all-list-wrap">
                                    <div class="ctt list2">
                                        <!--项目详情开始-->
                                        <div class="dis" id="tbc_01" zoom_img_width="680">
                                            <%if (team["detail"] != String.Empty)
                                              { %>
                                            <h2 id="detail">
                                                <img src="<%=ImagePath() %>bdxq.jpg" alt="本单详情" /></h2>
                                            <div>
                                                <%=ashelper.returnContentDetail(team["detail"].ToString())%>
                                            </div>
                                            <% }%>
                                            <!--提示-->
                                            <%if (!String.IsNullOrEmpty(team["notice"]))
                                              { %>
                                            <h2 id="detailit">
                                                <img alt="特别提示" src="<%=ImagePath() %>tbts.jpg" /></h2>
                                            <div>
                                                <%=team["notice"]%>
                                            </div>
                                            <% }%>
                                            <%if (!String.IsNullOrEmpty(team["userreview"]))
                                              { %>
                                            <h2 id="userreview">
                                                <img src="<%=ImagePath() %>tms.jpg" alt="他们说" /></h2>
                                            <div class="blk review">
                                                <%=PageValue.GetSpilt(team["userreview"])%>
                                            </div>
                                            <%} %>
                                            <%if (!String.IsNullOrEmpty(team["systemreview"]))
                                              { %>
                                            <h2 id="systemreview">
                                                <%=ASSystemArr["abbreviation"]%>说</h2>
                                            <div>
                                                <div>
                                                    <%=team["systemreview"]%>
                                                </div>
                                            </div>
                                            <% }%>
                                            <%--2.28添加抢购--%>
                                            <%if (state == AS.Enum.TeamState.successnobuy)
                                              { %>
                                            <%}
                                              else if (over)
                                              { %>
                                            <%}
                                              else
                                              {%>
                                            <%if (teammodel.Begin_time <= DateTime.Now)
                                              { %>
                                            <%if (teammodel.Delivery == "draw")
                                              { %>
                                            <div class="buttonbuy">
                                                心动团购价 <strong>
                                                    <%=ASSystemArr["currency"]%><%=GetMoney(team["team_price"])%>
                                                </strong><a href="<%= buyurl %>"><span class="deal-price-buy"></span></a>
                                            </div>
                                            <% }
                                              else
                                              {%>
                                            <div class="buttonbuy">
                                                心动团购价 <strong>
                                                    <%=ASSystemArr["currency"]%><%=GetMoney(team["team_price"])%>
                                                </strong>
                                                <%if (teammodel.invent_result != null)
                                                  {
                                                      if (teammodel.invent_result.Contains("价格"))
                                                      {%>
                                                <span class="deal-price-buy" onclick="addbuyurl();"></span>
                                                <%}
                                                      else
                                                      {%>
                                                <a href="<%=buyurl %>"><span class="deal-price-buy"></span></a>
                                                <%}
                                                  }
                                                  else
                                                  {%>
                                                <a href="<%=buyurl %>"><span class="deal-price-buy"></span></a>
                                                <%}%>
                                            </div>
                                            <% }%>
                                            <% }
                                              else
                                              {%>
                                            <%-- <a href="#"><span class="deal-price-notstart"></span></a>--%>
                                            <% }%>
                                            <%}
                                            %>
                                        </div>
                                        <!--项目详情结束-->
                                        <!--本单答疑开始-->
                                        <div class="dis" id="tbc_02" zoom_img_width="680">
                                            <div id="consult">
                                                <h3></h3>
                                                <div class="sect consult-list">
                                                    <ul class="list">
                                                        <%=ListAsk()%>
                                                    </ul>
                                                </div>
                                            </div>
                                        </div>
                                        <!--本单答疑结束-->
                                        <!--买家评论开始-->
                                        <div class="dis" id="tbc_03" zoom_img_width="680">
                                            <% if (listuserreview != null && listuserreview.Count > 0)
                                               {%>
                                            <% foreach (IUserReview ur in listuserreview)
                                               {
                                                   if (i <= 9)
                                                   {
                                                       i = i + 1; %>
                                            <div class="comments">
                                                <div class="deal_pic">
                                                    <a href="<%=getTeamPageUrl(Helper.GetInt(ur.review_teamid,0))%>"
                                                        target="_blank">
                                                        <img src="<%=ur.Image %>"
                                                            width="110" height="70" border="0" title="<%=ur.Title %>" alt="<%=ur.Title %>" />
                                                    </a>
                                                </div>
                                                <div class="comment_content">
                                                    <div class="comment_list_arrow"></div>
                                                    <div class="pltitle">
                                                        <div class="desc">
                                                            <strong><%=ur.username%>:</strong><%=ur.comment%>
                                                        </div>
                                                        <h1><span class="comment_float_left">评论了TA在<%=ASSystem.abbreviation%>买到的&nbsp;
                                <a href="<%=getTeamPageUrl(Helper.GetInt(ur.review_teamid,0))%>">
                                    <%=ur.Title %></a></span>
                                                        </h1>
                                                    </div>
                                                </div>
                                            </div>
                                            <%
                                                   }
                                                   else
                                                   {
                                                       break;
                                                   }

                                               }
                                            %>
                                            <div class="ckgdpl">
                                                <a href="<%=GetUrl("到货评价","buy_list_comments.aspx")%>">查看更多评论</a>
                                            </div>
                                            <% if (!IsLogin)
                                               { %>
                                            <a href="<%=GetUrl("用户登录","account_login.aspx") %>">登录</a>后可以单独查看您的评价
                                            <%}
                                               else
                                               {
                                                   if (resultValue())
                                                   { %>
                                            <div class="tjpl_content">
                                                <div class="tjpl">
                                                    <textarea style="width: 600px; height: 80px; padding: 2px;" id="txtremark" name="txtremark"></textarea>
                                                </div>
                                                <div class="tjpl_bt">
                                                    <input type="submit" value="提交评论" class="formbutton validator" group="a" name="ctl02">
                                                </div>
                                            </div>
                                            <%}
                                               } %>
                                            <% }
                                               else
                                               {%>
                                            <div class="comments">
                                                暂无评论。您可以在"<%=ASSystem.abbreviation%>"下方的'我的订单'里面给已经发货的订单评价哦
                                            </div>
                                            <%} %>
                                            <div class="clear">
                                            </div>
                                        </div>
                                        <!--买家评论结束-->
                                        <!--商家开始-->
                                        <%if (ASSystem.teamwhole == 1 && part != null)
                                          { %>
                                        <div class="dis" id="tbc_04" zoom_img_width="435" style="padding: 5px 0;">
                                            <div class="partnerinfo" style="width: 480px; padding: 0;">

                                                <h2>
                                                    <a href="<%=GetUrl("品牌商户详情","partner_view.aspx?id="+partner["id"])%>">
                                                        <%=partner["title"]%></a></h2>
                                                <%if (partner["Contact"] != null && partner["Contact"].ToString() != "")
                                                  { %>
                                                <div style="margin-top: 10px;">
                                                    <span class="sjinfo_tt">联系人：</span>
                                                    <%=partner["Contact"]%>
                                                </div>
                                                <%} %>
                                                <%if (partner["Phone"] != null && partner["Phone"].ToString() != "")
                                                  { %>
                                                <div style="margin-top: 10px;">
                                                    <span class="sjinfo_tt">联系电话：</span><%=partner["Phone"]%>
                                                </div>
                                                <%} %>
                                                <%if (partner["Address"] != null && partner["Address"].ToString() != "")
                                                  { %>
                                                <div style="margin-top: 10px;">
                                                    <span class="sjinfo_tt">商户地址：</span><%=partner["Address"]%>
                                                </div>
                                                <%} %>
                                                <%if (partner["Mobile"] != null && partner["Mobile"].ToString() != "")
                                                  { %>
                                                <div style="margin-top: 10px;">
                                                    <span class="sjinfo_tt">手机号码：</span><%=partner["Mobile"]%>
                                                </div>
                                                <%} %>
                                                <%if (partner["location"] != null && partner["location"].ToString() != "")
                                                  { %>
                                                <div style="margin-top: 10px;">
                                                    <span style="font-weight: bold; font-size: 14px;">位置信息&nbsp;:&nbsp;</span><%=partner["location"]%>
                                                </div>
                                                <%} %>
                                                <%if (partner["Other"] != null && partner["Other"].ToString() != "")
                                                  { %>
                                                <div style="margin-top: 10px;">
                                                    <span class="sjinfo_tt">其它信息：</span><%=partner["Other"]%>
                                                </div>
                                                <%} %>
                                                <%if (partner["homepage"] != null)
                                                  { %><div style="margin-top: 10px;">
                                                      <a href="http://<%=partner["homepage"] %>" target="_blank">
                                                          <%=partner["homepage"].Replace("http://", "")%></a>
                                                  </div>
                                                <%} %>
                                                <% if (partner["Image"] != "")
                                                   { %>
                                                <div style="margin-top: 10px;">
                                                    <img alt="" src="<%=partner["Image"] %>" />
                                                </div>
                                                <%} %>
                                                <% if (partner["Image1"] != "")
                                                   { %>
                                                <div style="margin-top: 10px;">
                                                    <img alt="" src="<%=partner["Image1"] %>" />
                                                </div>
                                                <%} %>
                                                <% if (partner["Image2"] != "")
                                                   { %>
                                                <div style="margin-top: 10px;">
                                                    <img alt="" src="<%=partner["Image2"]%>" />
                                                </div>
                                                <%} %>
                                                <!--分站信息开始-->
                                                <%
                                              if (partner["id"] != null)
                                              {
                                                  BranchFilter branchf = new BranchFilter();
                                                  branchf.partnerid = Helper.GetInt(partner["id"], 0);

                                                  using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                                                  {
                                                      branches = seion.Branch.GetList(branchf);
                                                  }
                                                %>
                                                <%
                                                  int loopid = 1;
                                                  if (branches != null && branches.Count > 0)
                                                  {
                                                      foreach (IBranch row in branches)
                                                      { %>
                                                <h2>
                                                    <%=row.branchname%></h2>
                                                <%if (row.contact.ToString() != "")
                                                  { %>
                                                <div style="margin-top: 10px;">
                                                    <span class="sjinfo_tt">联系人：</span>
                                                    <%=row.contact%>
                                                </div>
                                                <%} %>
                                                <%if (row.phone.ToString() != "")
                                                  { %>
                                                <div style="margin-top: 10px;">
                                                    <span class="sjinfo_tt">联系电话：</span><%=row.phone%>
                                                </div>
                                                <%} %>
                                                <%if (row.address != null && row.address.ToString() != "")
                                                  { %>
                                                <div style="margin-top: 10px;">
                                                    <span class="sjinfo_tt">商户地址：</span><%=row.address%>
                                                </div>
                                                <%} %>
                                                <%if (row.mobile != null && row.mobile.ToString() != "")
                                                  { %>
                                                <div style="margin-top: 10px;">
                                                    <span class="sjinfo_tt">手机号码：</span><%=row.mobile%>
                                                </div>
                                                <%} %>


                                                <%loopid++;
                                                        }
                                                    }
                                              } %>
                                                <!--分站信息结束-->
                                            </div>
                                            <div class="sjadd" style="float: right; padding: 5px 0 15px 0;">
                                                <%if (canLoadMap && mapInfo != String.Empty)
                                                  {%>
                                                <div id="container" style="border: solid 1px #ccc;"></div>
                                                <%} %>
                                            </div>
                                        </div>
                                        <%}%>
                                        <!--商家结束-->
                                    </div>
                                </div>
                            </div>
                            <script type="text/javascript" language="javascript">
                                $(document).ready(function () {
                                    $("#tb_1").find("a").click(function () {
                                        $("#tb_1").attr("class", "bb");
                                        $("#tb_2").attr("class", "aa");
                                        $("#tb_3").attr("class", "aa");
                                        $("#tb_4").attr("class", "aa");
                                        $("#tbc_01").show();
                                        $("#tbc_02").hide();
                                        $("#tbc_03").hide();
                                        $("#tbc_04").hide();
                                    });
                                    $("#tb_2").find("a").click(function () {
                                        $("#tb_1").attr("class", "aa");
                                        $("#tb_2").attr("class", "bb");
                                        $("#tb_3").attr("class", "aa");
                                        $("#tb_4").attr("class", "aa");
                                        $("#tbc_01").hide();
                                        $("#tbc_02").show();
                                        $("#tbc_03").hide();
                                        $("#tbc_04").hide();
                                    });
                                    $("#tb_3").find("a").click(function () {
                                        $("#tb_1").attr("class", "aa");
                                        $("#tb_2").attr("class", "aa");
                                        $("#tb_3").attr("class", "bb");
                                        $("#tb_4").attr("class", "aa");
                                        $("#tbc_01").hide();
                                        $("#tbc_02").hide();
                                        $("#tbc_03").show();
                                        $("#tbc_04").hide();
                                    });
                                    $("#tb_4").find("a").click(function () {
                                        $("#tb_1").attr("class", "aa");
                                        $("#tb_2").attr("class", "aa");
                                        $("#tb_3").attr("class", "aa");
                                        $("#tb_4").attr("class", "bb");
                                        $("#tbc_01").hide();
                                        $("#tbc_02").hide();
                                        $("#tbc_03").hide();
                                        $("#tbc_04").show();
                                    });
                                    $("#tbc_01").show();
                                    $("#tbc_02").hide();
                                    $("#tbc_03").hide();
                                    $("#tbc_04").hide();
                                });

                            </script>
                            <!--切换修改结束-->
                            <!-- END Organic Tabs -->
                        </div>
                        <!-- #slider1 -->
                    </div>
                </div>
                <div class="clear">
                </div>
            </div>
        </div>
        <!--修改代码结束-->
        <%}%>
    </div>
</div>
<div id="sidebar">
    <%LoadUserControl(PageValue.WebRoot + "UserControls/adleft.ascx", null); %>
    <%        
        Dictionary<string, object> othervalues = new Dictionary<string, object>();
        othervalues.Add("teamid", teammodel.Id);
        othervalues.Add("strOtherTeamid", strOtherTeamid);
        othervalues.Add("strview", "teamview");
        LoadUserControl(PageValue.WebRoot + "UserControls/blockothers.ascx", othervalues); %>
    <%LoadUserControl(PageValue.WebRoot + "UserControls/blockinvite.ascx", null); %>
    <%LoadUserControl(PageValue.WebRoot + "UserControls/blockbulletin.ascx", null); %>
    <%LoadUserControl(PageValue.WebRoot + "UserControls/blockflv.ascx", teammodel); %>
    <%LoadUserControl(PageValue.WebRoot + "UserControls/blockask.ascx", teammodel); %>
    <%
        if (_system["newgao"] != null)
        {
            if (_system["newgao"] == "1")
            { %>
    <%LoadUserControl(PageValue.WebRoot + "UserControls/uc_NewList.ascx", null); %>
    <% 
            }
        }%>
    <%LoadUserControl(PageValue.WebRoot + "UserControls/blockvote.ascx", null); %>
    <%LoadUserControl(PageValue.WebRoot + "UserControls/blockbusiness.ascx", null); %>
    <%LoadUserControl(PageValue.WebRoot + "UserControls/blocksubscribe.ascx", null); %>
</div>

<%if (canLoadMap && mapInfo != String.Empty)
  {%>
<script type="text/javascript" src="http://api.map.baidu.com/api?v=1.2"></script>
<script type='text/javascript'>
    var BAIDUMAPCONTENT = "container";
    var BAIDUPOINTS = [<%=mapInfo %>];
</script>
<script type="text/javascript" src="/upfile/js/baiduMap.js"></script>
<%}%>