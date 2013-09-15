<%@ Page Language="C#" AutoEventWireup="true" Debug="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Register Src="~/UserControls/blockothergoods.ascx" TagName="blockothergoods"
    TagPrefix="uc6" %>
<script runat="server">
   
    string detail = "";
    protected bool over = false;
    protected bool fail = false;
    protected bool canLoadMap = false;//加载地图111111
    protected NameValueCollection order = new NameValueCollection();
    protected NameValueCollection team = new NameValueCollection();
    protected NameValueCollection user = new NameValueCollection();
    protected NameValueCollection partner = new NameValueCollection();
    protected IPagers<IAsk> pager = null;
    protected IList<IAsk> listask = null;
    protected IList<IBranch> listbranch = null;
    protected int size = 0;
    protected int offset = 0;
    protected int imageindex = 2;
    protected int teamid = 0;
    new protected ITeam CurrentTeam = Store.CreateTeam();
    protected IPartner part = Store.CreatePartner();
    protected int twoline = 0;
    protected long curtimefix = 0;
    protected long difftimefix = 0;
    protected int i = 0;
    protected AS.Enum.TeamState state = AS.Enum.TeamState.none;
    public IList<IOrder> orderlist = null;
    protected string teamstatestring = String.Empty;//项目状态的英文soldout卖光,success成功,failure失败
    public string strtitle = "";
    public IUser usermodel = Store.CreateUser();
    protected string buyUrl = String.Empty; //购买链接
    protected DateTime overtime = DateTime.Now;  //团购结束时间
    public NameValueCollection _system = new NameValueCollection();
    UserReviewFilter userreviewfilter = new UserReviewFilter();
    IList<IUserReview> listuserreview = null;
    protected AskFilter askfilter = new AskFilter();
    string where = "1=1";
    protected string mapInfo = String.Empty;//地图信息
    protected IList<IAsk> asks = null;
    protected int ordercount = 0;//成功购买当前项目的订单数量
    protected int detailcount = 0;//成功购买当前项目数量
    protected int buycount = 0;//当前项目购买数量
    protected IList<IBranch> branches = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();
        teamid = Helper.GetInt(Request["id"], 0);
        if (teamid > 0)
        {
            using (IDataSession seion = Store.OpenSession(false))
            {
                CurrentTeam = seion.Teams.GetByID(teamid);
            }
        }
        else
        {
            CurrentTeam = base.CurrentTeam;
        }
        if (CurrentTeam != null && AsUser.Id != 0)
        {

            OrderDetailFilter of = new OrderDetailFilter();
            of.order_userid = AsUser.Id;
            of.Teamid = teamid;
            of.order_state = "pay";
            //统计订单详情里的项目、、
            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                detailcount = seion.OrderDetail.GetDetailCount(of);
            }

            OrderFilter orderf = new OrderFilter();
            orderf.User_id = AsUser.Id;
            orderf.Team_id = teamid;
            orderf.State = "pay";

            //统计订单里的项目
            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                ordercount = seion.Orders.GetCount(orderf);
            }

            if (CurrentTeam.Buyonce == "Y")
            {
                if (CurrentTeam.Now_number < CurrentTeam.Max_number || CurrentTeam.Max_number == 0)
                {
                    if (ordercount + detailcount > 0)
                    {
                        SetError("您已经成功购买了本单产品，请勿重复购买，快去关注一下其他产品吧！");
                    }
                }
            }
            else if (CurrentTeam.Buyonce == "N") //可以购买多次
            {
                if (CurrentTeam.Now_number < CurrentTeam.Max_number || CurrentTeam.Max_number == 0)
                {

                    //当前项目购买数量
                    buycount = TeamMethod.GetBuyCount(AsUser.Id, CurrentTeam.Id);

                    if (CurrentTeam.Per_number > 0)//当前项目设置了每人限购数量
                    {
                        if (buycount >= CurrentTeam.Per_number)//当前用户的购买数量大于限购数量 
                        {
                            SetError("您购买本单产品的数量已经达到上限，快去关注一下其他产品吧！");
                        }
                    }
                }
            }
        }
        if (CurrentTeam == null)
        {
            Response.End();
            return;
        }
        if (WebUtils.config["maptype"] != null && WebUtils.config["maptype"].ToString().Length > 0 && CurrentTeam != null && CurrentTeam.Delivery == "coupon")
        {
            canLoadMap = true;
        }
        twoline = (ASSystem.teamwhole == 0) ? 1 : 0;

        if (CurrentTeam.Begin_time > DateTime.Now)//未开始项目
        {
            curtimefix = Helper.GetTimeFix(DateTime.Now) * 1000;
            difftimefix = Helper.GetTimeFix(CurrentTeam.Begin_time) * 1000;
        }
        else
        {
            curtimefix = Helper.GetTimeFix(DateTime.Now) * 1000;
            difftimefix = Helper.GetTimeFix(CurrentTeam.End_time) * 1000;
        }


        difftimefix = difftimefix - curtimefix;
        using (IDataSession seion = Store.OpenSession(false))
        {
            part = seion.Partners.GetByID(CurrentTeam.Partner_id);
        }


        partner = Helper.GetObjectProtery(part);

        if (part != null && canLoadMap)
        {
            if (!String.IsNullOrEmpty(part.point) && part.point.IndexOf(",") >= 0)
            {
                string[] points = part.point.Split(',');
                mapInfo = "{\"title\":\"" + part.Title + "\", \"address\": \"" + part.Address + "\", \"tel\": \"" + part.Phone + "\", \"lng\": \"" + points[1] + "\", \"lat\": \"" + points[0] + "\"}";

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
                        mapInfo = mapInfo + ",{\"title\":\"" + item.branchname + "\", \"address\": \"" + item.address + "\", \"tel\": \"" + item.phone + "\", \"lng\": \"" + points[1] + "\", \"lat\": \"" + points[0] + "\"}";
                    }
                }
            }
        }

        state = GetState(CurrentTeam);

        if (state == AS.Enum.TeamState.fail || state == AS.Enum.TeamState.successtimeover)
        {
            over = true;
            overtime = CurrentTeam.End_time;
        }

        if (state == AS.Enum.TeamState.successnobuy)
        {
            over = true;
            if (CurrentTeam.Close_time.HasValue)
                overtime = CurrentTeam.Close_time.Value;
            else
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
            fail = true;
        }



        if (CurrentTeam.Team_type == "seconds")
        {
            strtitle = "今日秒杀";
        }
        if (CurrentTeam.Team_type == "goods")
        {
            strtitle = "今日热销";
        }
        if (CurrentTeam.Team_type == "normal")
        {
            strtitle = "今日团购";
        }
        if (CurrentTeam.Begin_time > DateTime.Now)
            buyUrl = "javascript: alert(\'秒杀还未开始...\')";
        else
            buyUrl = WebRoot + "ajax/car.aspx?id=" + CurrentTeam.Id;

        if (AsUser != null)
        {
            IList<IOrder> orders = null;
            OrderFilter orderf = new OrderFilter();
            orderf.Team_id = CurrentTeam.Id;
            orderf.User_id = AsUser.Id;
            orderf.State = "unpay";

            using (IDataSession seion = Store.OpenSession(false))
            {
                orders = seion.Orders.GetList(orderf);
            }
            if (orders.Count > 0)
                order = Helper.GetObjectProtery(orders[0]);
        }
        team = Helper.GetObjectProtery(CurrentTeam);

        if (CurrentTeam.Min_number > 0)
        {
            size = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(190 * (Convert.ToDouble(CurrentTeam.Now_number) / Convert.ToDouble(CurrentTeam.Min_number)))));

            offset = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(5 * (Convert.ToDouble(CurrentTeam.Now_number) / Convert.ToDouble(CurrentTeam.Min_number)))));
        }

        blockothersseconds1.UpdateView(CurrentTeam.Id);
        setBuyTitle();



        if (Request.HttpMethod == "POST" && Request["consult_content"] != null)
        {
            submitAsk();
        }

    }


    private void submitAsk()
    {
        string error = String.Empty;
        int teamid = 0;

        if (AsUser.Id == 0)
        {
            error = "用户名失效,请重新登录！";
        }
        else
        {
            if (CurrentTeam != null)
            {
                teamid = CurrentTeam.Id;
                int cityid = 0;
                if (CurrentCity != null)
                    cityid = CurrentCity.Id;

                error = UserReview.User_SubmitAsk(CurrentTeam.Id, AsUser.Id, cityid, HttpUtility.HtmlEncode(Request["consult_content"]));
            }
            else
            {
                error = "项目不能为空";
            }
        }

        if (error == String.Empty)
        {
            SetSuccess("您的问题已成功提交，客服很快就会回复的，稍等一会儿再来看吧。");
            Response.Redirect(Request.Url.AbsoluteUri);
            Response.End();
        }
        else
        {
            SetError(error);
            Response.Redirect(Request.Url.AbsoluteUri);
            Response.End();
            return;
        }
    }
    /// <summary>
    /// 买家评论内容
    /// </summary>
    public void setBuyTitle()
    {

        userreviewfilter.TState = 2;
        userreviewfilter.AddSortOrder(UserReviewFilter.t1_desc);
        if (WebUtils.config["navUserreview"] != null && WebUtils.config["navUserreview"].ToString() == "1")
        {

            if (WebUtils.config["UserreviewYN"] != null && WebUtils.config["UserreviewYN"].ToString() == "1")
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
        IUser userinfo = Store.CreateUser();
        userf.Username = CookieUtils.GetCookieValue("username");
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
            orderf.TeamOr = teamid;
            userReviewf.team_id = teamid;
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

    #region 显示项目答疑
    public string ListAsk()
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        if (ASSystem.teamask == 0)
        {
            askfilter.Team_ID = CurrentTeam.Id;
        }
        askfilter.IsComment = true;
        askfilter.PageSize = 15;
        askfilter.AddSortOrder(AskFilter.Create_Time_DESC);
        askfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = seion.Ask.GetPager(askfilter);
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
                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        usermodel = seion.Users.GetByID(ask.User_id);
                    }
                    sb.Append("<p class=\"user\"><strong>" + usermodel.Username + "</strong><span>" + DateTime.Parse(ask.Create_time.ToString()).ToString("yy-MM-dd") + "</span></p>");
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
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<% if (canLoadMap && WebUtils.config["maptype"] == "1")
   {%>
<script type="text/javascript" src="http://api.map.baidu.com/api?v=1.2"></script>
<script type="text/javascript" src="/upfile/js/baiduMap.js"></script>
<%} %>
<%if (WebUtils.config["slowimage"] == "1")
  { %>
<script src="<%=WebRoot%>upfile/js/jquery.all_plugins.js" type="text/javascript"></script>
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
<script language="javascript" type="text/javascript">
    function checksub_email() {
        var str = document.getElementById("sub_email").value;
        //对电子邮件的验证
        if (!str.match(/^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/)) {
            document.getElementById("sub_email").value = "";
            return false;
        }
        else {
            window.location.href = '<%=GetUrl("邮件订阅", "help_Email_Subscribe.aspx")%>' + '?email=' + str;
        }
    }
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
            } else {
                window.clearInterval(InterValObj);
            }
        }
    });
</script>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <%if (fail)
          { %>
        <div id="sysmsg-tip" class="sysmsg-tip-deal-close">
            <div class="sysmsg-tip-top">
            </div>
            <div class="sysmsg-tip-content">
                <div class="deal-close">
                    <div class="focus">
                        抱歉，您来晚了，<br />
                        此商品已经卖光啦。
                    </div>
                    <div id="tip-deal-subscribe-body" class="body">
                        <table>
                            <tr>
                                <td>不想错过明天的热销商品？立刻订阅每日最新热销商品信息：&nbsp;
                                </td>
                                <td>
                                    <input type="text" name="sub_email" id="sub_email" class="f-text" value="" require="true"
                                        datatype="email" />
                                </td>
                                <td>&nbsp;
                                    <input id="Button3" type="button" class="commit validator" value="订阅" onclick="checksub_email()" />
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <span id="sysmsg-tip-close" class="sysmsg-tip-close">关闭</span>
            </div>
            <div class="sysmsg-tip-bottom">
            </div>
        </div>
        <%} %>
        <%if (order.Count > 0)
          { %>
        <div id="Div1">
            <div class="sysmsg-tip-top">
            </div>
            <div class="sysmsg-tip-content">
                您已经下过订单，但还没有付款。<a href="<%=GetUrl("优惠卷确认","order_check.aspx?orderid="+order["id"])%>">查看订单并付款</a><span
                    id="Span1" class="sysmsg-tip-close">关闭</span>
            </div>
            <div class="sysmsg-tip-bottom">
            </div>
        </div>
        <div id="deal-default">
            <%} %>
            <div id="deal-default">
                <%LoadUserControl(WebRoot + "UserControls/blockshare.ascx", CurrentTeam); %>
                <div id="sidebar">
                    <%LoadUserControl(WebRoot + "UserControls/blockinvite.ascx", null); %>
                    <%LoadUserControl(WebRoot + "UserControls/blockbulletin.ascx", null); %>
                    <%LoadUserControl(WebRoot + "UserControls/blockflv.ascx", CurrentTeam); %>
                    <uc6:blockothergoods ID="blockothersseconds1" Visible="true" runat="server" />
                    <%LoadUserControl(WebRoot + "UserControls/blockask.ascx", CurrentTeam); %>
                    <%LoadUserControl(WebRoot + "UserControls/blockbusiness.ascx", null); %>
                    <%LoadUserControl(WebRoot + "UserControls/blockvote.ascx", null); %>
                    <%LoadUserControl(WebRoot + "UserControls/blocksubscribe.ascx", null); %>
                </div>
                <div id="content">
                    <div id="deal-intro" class="cf">
                        <h1>
                            <%=team["title"] %></h1>
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
                                        <%=ASSystemArr["Currency"] %><%=GetMoney(team["team_price"]) %>
                                    </strong>
                                    <%if (CurrentTeam.Begin_time <= DateTime.Now)
                                      {
                                          if (CurrentTeam.Per_number == 0)
                                          {%>
                                    <a href="<%=buyUrl %>"><span class="deal-price-buy"></span></a>
                                    <%
                                          }
                                          else
                                          {
                                              if (buycount < CurrentTeam.Per_number)
                                              {
                                                  
                                    %>
                                    <a href="<%=buyUrl %>"><span class="deal-price-buy"></span></a>
                                    <%    }
                                              else
                                              {
                                         
                                    %>
                                    <a href="<%=buyUrl %>"><span class="deal-price-buy"></span></a>
                                    <%  
                                              }
                                          }
                                      }
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
                                        <%=ASSystemArr["Currency"] %><%=GetMoney(Helper.GetDecimal(team["Market_price"], 0) -Helper.GetDecimal(team["Team_price"], 0))%>
                                    </td>
                                </tr>
                            </table>
                            <%if (over)
                              { %>
                            <div class="deal-box deal-timeleft deal-goods_end" id="deal-timeleft" curtime="<%=curtimefix %>"
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
                            <div class="deal-box deal-timeleft hotsell_xq deal-on" id="Div3" curtime="<%=curtimefix %>"
                                diff="<%=difftimefix %>">
                                <div class="limitdate">
                                    <ul id="counter">
                                        <%if ((CurrentTeam.End_time - DateTime.Now).Days > 0)
                                          { %>
                                        <span>
                                            <%=(CurrentTeam.End_time-DateTime.Now).Days %></span>天<span><%=(CurrentTeam.End_time-DateTime.Now).Hours %></span>时<span><%=(CurrentTeam.End_time-DateTime.Now).Minutes %></span>分<span><%=(CurrentTeam.End_time - DateTime.Now).Seconds%></span>秒
                                        <%}
                                          else
                                          { %>
                                        <span>
                                            <%=(CurrentTeam.End_time-DateTime.Now).Hours %></span>时<span>
                                                <%=(CurrentTeam.End_time-DateTime.Now).Minutes %></span>分<span>
                                                    <%=(CurrentTeam.End_time-DateTime.Now).Seconds %></span>秒
                                        <%} %>
                                    </ul>
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
                                        <%= (CurrentTeam.Min_number-CurrentTeam.Now_number) %></strong> 人到达最低热销人数
                                </p>
                                <%} %>
                            </div>
                            <%}
                              else if (state == AS.Enum.TeamState.successbuy)
                              { %>
                            <div class="deal-box deal-status deal-status-open" id="Div4">
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
                                    热销成功
                                    <% }%>
                                    <%if ((CurrentTeam.Max_number == 0) || (CurrentTeam.Max_number - CurrentTeam.Now_number) > 0)
                                      { %>
                                    可以继续购买<%} %>
                                </p>
                                <%if (CurrentTeam.Reach_time.HasValue)
                                  { %>
                                <p class="deal-buy-tip-btm">
                                    <%=CurrentTeam.Reach_time.Value.ToString("MM-dd HH:mm") %><br />
                                    达到最低热销人数：<strong><%=CurrentTeam.Min_number %></strong>人
                                </p>
                                <%} %>
                            </div>
                            <%} %>
                            <%}
                              else
                              { %>
                            <div class="deal-box deal-status deal-status-<%=teamstatestring %>" id="Div5">
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
                                    <div class="blk detail" zoom_img_width="418">
                                        <%=ashelper.returnContentDetail(team["detail"].ToString())%>
                                    </div>
                                    <%} %>
                                    <%if (!String.IsNullOrEmpty(team["notice"]))
                                      { %>
                                    <h2 id="H2">
                                        <img src="<%=ImagePath() %>tbts.jpg" alt="特别提示" /></h2>
                                    <div class="blk cf" zoom_img_width="418">
                                        <%=team["notice"]%>
                                    </div>
                                    <%} %>
                                    <%if (!String.IsNullOrEmpty(team["userreview"]))
                                      { %>
                                    <h2 id="H3">
                                        <img src="<%=ImagePath() %>tms.jpg" alt="他们说" /></h2>
                                    <div class="blk review" zoom_img_width="418">
                                        <%=PageValue.GetSpilt(team["userreview"])%>
                                    </div>
                                    <%} %>
                                    <%if (!String.IsNullOrEmpty(team["systemreview"]))
                                      { %>
                                    <h2 id="H4">
                                        <%=ASSystemArr["abbreviation"]%>说</h2>
                                    <div class="blk review" zoom_img_width="418">
                                        <%=team["systemreview"]%>
                                    </div>
                                    <%} %>
                                    <%--2.28新增购买按钮--%>

                                    <%if (state == AS.Enum.TeamState.successnobuy)
                                      {

                                      }
                                      else if (over)
                                      {
                                      }
                                      else
                                      {
                                          if (CurrentTeam.Begin_time <= DateTime.Now)
                                          {
                                              if (CurrentTeam.Per_number == 0)
                                              {%>
                                    <div class="buttonbuy">
                                        心动团购价 <strong>
                                            <%=ASSystemArr["currency"]%><%=GetMoney(team["team_price"])%>
                                        </strong><a href="<%=buyUrl %>"><span class="deal-price-buy"></span></a>
                                    </div>
                                    <%  }
                                              else
                                              {
                                                  if (buycount < CurrentTeam.Per_number)
                                                  {
                                                  
                                    %>
                                    <div class="buttonbuy">
                                        心动团购价 <strong>
                                            <%=ASSystemArr["currency"]%><%=GetMoney(team["team_price"])%>
                                        </strong><a href="<%=buyUrl %>"><span class="deal-price-buy"></span></a>
                                    </div>

                                    <%    }
                                                  else
                                                  {
                                         
                                    %>
                                    <div class="buttonbuy">
                                        心动团购价 <strong>
                                            <%=ASSystemArr["currency"]%><%=GetMoney(team["team_price"])%>
                                        </strong><a href="#"><span class="deal-price-buy"></span></a>
                                    </div>
                                    <%  
                                                  }
                                        }
                                          }
                                          else
                                          {%>
                                    <div class="buttonbuy">
                                        心动团购价 <strong>
                                            <%=ASSystemArr["currency"]%><%=GetMoney(team["team_price"])%>
                                        </strong><a href="#"><span class="deal-price-buy"></span></a>
                                    </div>
                                    <% }%>



                                    <% }%>
                                </div>
                                <div class="side" id="team_partner_side_<%=twoline %>">
                                    <div id="side-business">
                                        <div>
                                            <h2>
                                                <%=partner["title"]%></h2>
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
                                        </div>
                                        <%if (canLoadMap && mapInfo != String.Empty)
  {%>
                                        <div id="container" style="border: solid 1px #ccc;"></div>
                                        <%} %>
                                    </div>
                                </div>
                                <div class="clear">
                                </div>
                            </div>
                        </div>
                    </div>
                    <!--老模式结束-->
                    <% 
                        }
                        else
                        {%>
                    <!--修改代码开始-->
                    <div id="deal-stuff1" class="cf1">
                        <div class="clear box ">
                            <div class="box-content2 cf1">
                                <div class="slider-wrap">
                                    <div class="xxk" zoom_img_width="640">
                                        <div id="page-wrap">
                                            <!--切换修改开始-->
                                            <div id="organic-tabs">
                                                <ul id="explore-nav" class="xuanxiangk">
                                                    <li class="bb" id="tb_1"><a href="#">本单详情</a></li>
                                                    <li class="aa" id="tb_2"><a href="#">项目答疑</a></li>
                                                    <%
                            if (_system["navUserreview"] != null && _system["navUserreview"].ToString() == "1")
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
                                                        <div class="dis" id="tbc_01">
                                                            <%if (team["detail"] != String.Empty)
                                                              { %>
                                                            <h2 id="detail">
                                                                <img src="<%=ImagePath() %>bdxq.jpg" alt="本单详情" />
                                                            </h2>
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
                                                            <%--2.28新增购买按钮--%>
                                                            <%if (state == AS.Enum.TeamState.successnobuy)
                                                              {
                                                              }
                                                              else if (over)
                                                              {
                                                              }
                                                              else
                                                              {

                                                                  if (CurrentTeam.Begin_time <= DateTime.Now)
                                                                  {
                                                                      if (CurrentTeam.Per_number == 0)
                                                                      {%>
                                                            <div class="buttonbuy">
                                                                心动团购价 <strong>
                                                                    <%=ASSystemArr["currency"]%><%=GetMoney(team["team_price"])%>
                                                                </strong><a href="<%=buyUrl %>"><span class="deal-price-buy"></span></a>
                                                            </div>
                                                            <%
                                              }
                                              else
                                              {
                                                  if (buycount < CurrentTeam.Per_number)
                                                  {
                                                  
                                                            %>
                                                            <div class="buttonbuy">
                                                                心动团购价 <strong>
                                                                    <%=ASSystemArr["currency"]%><%=GetMoney(team["team_price"])%>
                                                                </strong><a href="<%=buyUrl %>"><span class="deal-price-buy"></span></a>
                                                            </div>

                                                            <%    }
                                                  else
                                                  {
                                         
                                                            %>
                                                            <div class="buttonbuy">
                                                                心动团购价 <strong>
                                                                    <%=ASSystemArr["currency"]%><%=GetMoney(team["team_price"])%>
                                                                </strong><a href="#"><span class="deal-price-buy"></span></a>
                                                            </div>
                                                            <%  
                                                  }
                                              }
                                          }
                                          else
                                          {%>
                                                            <div class="buttonbuy">
                                                                心动团购价 <strong>
                                                                    <%=ASSystemArr["currency"]%><%=GetMoney(team["team_price"])%>
                                                                </strong><a href="#"><span class="deal-price-buy"></span></a>
                                                            </div>
                                                            <% }

                                                              }
                                                              
                                                            %>
                                                        </div>
                                                        <!--项目详情结束-->


                                                        <!--本单答疑开始-->
                                                        <div class="dis" id="tbc_02">
                                                            <div id="consult">
                                                                <h3></h3>
                                                                <div class="sect consult-list">
                                                                    <ul class="list">
                                                                        <%= ListAsk()%>
                                                                    </ul>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <!--本单答疑结束-->


                                                        <!--买家评论开始xx-->
                                                        <div class="dis" id="tbc_03">
                                                            <% if (listuserreview != null && listuserreview.Count > 0)
                                                               {%>
                                                            <% foreach (IUserReview ur in listuserreview)
                                                               {

                                                                   if (i <= 9)
                                                                   {                
                                                                              
                                                            %>
                                                            <div class="comments">
                                                                <div class="deal_pic">
                                                                    <a href="<%=getTeamPageUrl(Helper.GetInt(ur.review_teamid,0))%>" target="_blank">
                                                                        <img <%=ashelper.getimgsrc(ur.Image) %> width="110" height="70" border="0" />
                                                                    </a>
                                                                </div>
                                                                <div class="comment_content">
                                                                    <div class="pltitle">
                                                                        <div class="desc">
                                                                            <%=GetUserLevel(Helper.GetDecimal(ur.totalamount, 0))%>:<%=ur.username%>
                                                                            评论了TA在<%=ASSystem.abbreviation%>买到的&nbsp;<a href="<%=getTeamPageUrl(Helper.GetInt(ur.review_teamid,0))%>"><%=ur.Title%></a>
                                                                        </div>
                                                                        <p class="pingjia"><%=ur.comment%></p>
                                                                        <div class="clear"></div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <%
                                                                   }
                                                                   else
                                                                   {
                                                                       break;
                                                                   }
                                                                   i++;
                                                               }%>
                                                            <div class="ckgdpl">
                                                                <a href="<%=GetUrl("到货评价","buy_list_comments.aspx") %>">查看更多评论</a>
                                                            </div>
                                                            <% if (CookieUtils.GetCookieValue("username").Length == 0)
                                                               { %>
                                                            <a href="<%=GetUrl("用户登录", "account_login.aspx") %>">登录</a>后可以单独查看您的评价
                                                            <%}
                                                               else
                                                               {
                                                                   if (resultValue())
                                                                   { %>
                                                            <div class="tjpl_content">
                                                                <div class="tjpl">
                                                                    <label>
                                                                    </label>
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
                                                                <% if (partner["id"] != null)
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
                                                        <%}%>
                                                        <!--商家结束-->
                                                    </div>
                                                </div>
                                            </div>
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
                    </div>
                    <!--修改代码结束-->
                    <%}%>
                </div>
            </div>
        </div>
    </div>
</div>
<%if (canLoadMap && mapInfo != String.Empty)
  {%>
<script type='text/javascript'>
    var poiData = [<%=mapInfo %>];
    //初始化团购控件
    var gp = new BMapGP.GroupPurchase("container", {
        //启用附近公交/地铁路线功能 
        enableRouteInfo: true,
        //启用从这里来/到这里去 公交路线搜索功能 
        //enableRouteSearchBox: true,
        //是否启用展开第一个结果 
        selectFirstResult: true,
        //地图类型 JS_MAP为js类型地图，STATIC_MAP为静态图, IFRAME_MAP为嵌入IFRAME类型
        type: JS_MAP,
        //地图缩放级别，如果多点情况，插件会自动缩放级别，将所有点显示在视野内
        zoom: 11,
        //地图大小 
        mapSize: { width: 205, height: 210 },
        pois: poiData
    });
</script>
<%}%>
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
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>

               