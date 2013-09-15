<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
  
    string detail = "";
    string where = "1=1";
    protected bool over = false;
    protected IPagers<IAsk> pager = null;
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
    public string strtitle = "";
    protected int i = 0;

    protected DateTime overtime = DateTime.Now;  //团购结束时间
    public int sortorder = 0;
    protected bool buy = true;//允许购买
    protected int ordercount = 0;//成功购买当前项目的订单数量
    protected int detailcount = 0;//成功购买当前项目数量
    protected int buycount = 0;//当前项目购买数量
    protected string buyurl = String.Empty;//购买按钮链接


    public NameValueCollection _system = new NameValueCollection();

    public string cityid = "0";

    OrderDetailFilter odf = new OrderDetailFilter();
    OrderFilter of = new OrderFilter();
    int cnt = 0;
    List<Hashtable> hashtable = new List<Hashtable>();
    IList<IOrder> listorder = null;
    IList<IAsk> listask = null;
    IList<IUserReview> listuserreview = null;
    IUserReview userReview = Store.CreateUserReview();
    AskFilter askfilter = new AskFilter();
    UserReviewFilter userreviewfilter = new UserReviewFilter();

    ITeam CurrentTeam = Store.CreateTeam();
    IPartner part = Store.CreatePartner();
    IUser usermodel = Store.CreateUser();


    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);


        _system = WebUtils.GetSystem();
        teamid = Helper.GetInt(Request["id"], 0);
        if (CurrentCity != null)
        {
            cityid = CurrentCity.Id.ToString();
        }
        if (teamid > 0)
        {

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                CurrentTeam = session.Teams.GetByID(teamid);
            }
            if (CurrentTeam != null)
            {
                Session["teamid"] = CurrentTeam.Id;
            }
        }
        else
        {
            CurrentTeam = base.CurrentTeam;
            Session["teamid"] = CurrentTeam.Id;
        }
        if (CurrentTeam != null)
        {
            if (Request.HttpMethod == "POST" && Request.Form["txtremark"] != null && Request.Form["txtremark"].ToString() != "")
            {
                submitValue(CurrentTeam.Id, Request.Form["txtremark"]);
            }
            buyurl = Page.ResolveUrl(PageValue.WebRoot + "ajax/PCar.aspx?id=" + CurrentTeam.Id);
            if (AsUser.Id != 0)
            {

                odf.Teamid = CurrentTeam.Id;
                odf.order_userid = AsUser.Id;
                odf.order_state = "scorepay";

                //统计订单详情里的项目
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    detailcount = seion.OrderDetail.GetDetailCount(odf);
                }
                //统计订单里的项目
                of.User_id = AsUser.Id;
                of.Team_id = CurrentTeam.Id;
                of.State = "scorepay";
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ordercount = seion.Orders.GetCount(of);
                }
            }
        }

        if (CurrentTeam == null)
        {
            Response.End();
            return;
        }
        twoline = (ASSystem.teamwhole == 0) ? 1 : 0;
        curtimefix = Helper.GetTimeFix(DateTime.Now) * 1000;
        difftimefix = Helper.GetTimeFix(CurrentTeam.End_time) * 1000;
        difftimefix = difftimefix - curtimefix;

        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            part = seion.Partners.GetByID(CurrentTeam.Partner_id);
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
        if (CurrentTeam.Team_type == "point")
        {
            strtitle = "积分商城";
        }

        if (AsUser.Id != 0)
        {
            OrderFilter of1 = new OrderFilter();
            of1.User_id = AsUser.Id;
            of1.Team_id = CurrentTeam.Id;
            of1.State = "unpay";

            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                cnt = seion.Orders.GetUnpay(of1);
            }
            if (cnt > 0)
            {
                
              string sqls= "select * from [order] left join [orderdetail] on([order].id=[orderdetail].order_id) where user_id=" + AsUser.Id + " and (team_id=" + CurrentTeam.Id + " or teamid=" + CurrentTeam.Id + ") and state='unpay'";

                using (IDataSession seion = Store.OpenSession(false))
                {
                   hashtable =  seion.GetData.GetDataList(sqls);
                }
                
                order = Helper.GetObjectProtery(hashtable[0]);
            }
        }
        team = Helper.GetObjectProtery(CurrentTeam);

        if (CurrentTeam.Min_number > 0)
        {
            size = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(190 * (Convert.ToDouble(CurrentTeam.Now_number) / Convert.ToDouble(CurrentTeam.Min_number)))));

            offset = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(5 * (Convert.ToDouble(CurrentTeam.Now_number) / Convert.ToDouble(CurrentTeam.Min_number)))));
        }
        setBuyTitle();
    }



    #region 显示项目答疑
    public string ListAsk()
    {
        System.Text.StringBuilder sb = new System.Text.StringBuilder();

        askfilter.Team_ID = CurrentTeam.Id;
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
    /// <summary>
    /// 买家评论内容
    /// </summary>
    public void setBuyTitle()
    {
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

    /// <summary>
    /// 提交内容
    /// </summary>
    public void submitValue(int id, string txtremark)
    {
        UserFilter userf = new UserFilter();
        IUser userinfo = Store.CreateUser();
        userf.Username = CookieUtils.GetCookieValue("username");
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            userinfo = session.Users.GetByName(userf);
        }
        if (userinfo != null)
        {
            int userid = userinfo.Id;
            if (Request.Form["txtremark"].ToString().Length > 2000)
            {
                SetError("您输入的内容过长，请重新输入");
            }
            else
            {

                string str = UserReview.User_ReView(0, null, txtremark, userid, teamid, _system);
                if (str == "")
                {
                    SetSuccess("发表成功!");
                }
                else
                {
                    SetError(str);

                }
            }

        }

        Response.Redirect("pointsshop_pointshop.aspx?Id=" + id);

    }

</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    jQuery(window).bind("load", function () {
        jQuery("div#slider1").codaSlider()
    });
</script>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <% LoadUserControl(PageValue.WebRoot + "UserControls/admid.ascx", null); %>
        <%if (over)
          { %>
        <div id="sysmsg-tip" class="sysmsg-tip-deal-close">
            <div class="sysmsg-tip-top">
            </div>
            <div class="sysmsg-tip-content">
                <div class="deal-close">
                    <form id="form1">
                    <div id="tip-deal-subscribe-body" class="body">
                        <table>
                            <tr>
                                <td>不想错过明天的团购？立刻订阅每日最新团购信息：&nbsp;
                                </td>
                                <td>
                                    <input type="text" name="email" class="f-text" value="" group="a" require="true"
                                        datatype="email" />
                                </td>
                                <td>&nbsp;<input group="a" type="submit" class="validator commit" value="订阅" action="<%=GetUrl("邮件订阅","help_Email_Subscribe.aspx")%>" />
                                </td>
                            </tr>
                        </table>
                    </div>
                        </form>
                </div>
                <span id="sysmsg-tip-close" class="sysmsg-tip-close">关闭</span>
            </div>
            <div class="sysmsg-tip-bottom">
            </div>
        </div>
        <%} %>
        <%if (order.Count > 0)
          {%>
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
        <%    if (CurrentTeam.Farefree == 0 || CurrentTeam.Delivery == "coupon")
              {
        %>
        <div id="deal-default">
            <%}
          }%>
            <div id="deal-default">
               <div id="content">
                    <div id="deal-intro" class="cf">
                        <h1>
                            <%if (!over)
                              { %>
                            <a class="deal-today-link" href="<%=getTeamPageUrl(int.Parse(team["id"]))%>"></a>
                            <%} %><%=team["title"] %>
                        </h1>
                        <div class="main">
                            <div class="deal-buy">
                                <div class="deal-price-tag">
                                </div>
                                <%if (state == AS.Enum.TeamState.successnobuy)
                                  { %>
                                <p class="deal-price">
                                    <strong>
                                        <%=GetMoney(team["teamscore"])%></strong><span class="deal-price-over"></span>
                                </p>
                                <%}
                                  else if (over)
                                  { %>
                                <p class="deal-price">
                                    <strong>
                                        <%=GetMoney(team["teamscore"])%></strong><span class="deal-price-end"></span>
                                </p>
                                <%}
                                  else
                                  {%>
                                <p class="deal-price">
                                    <strong>
                                        <%=GetMoney(team["teamscore"])%></strong>
                                    <%if (CurrentTeam.Begin_time <= DateTime.Now)
                                      {
						
                                    %>
                                    <a href="<%=buyurl %>"><span class="deal-price-buy"></span></a>
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
                                    <th>兑换积分
                                    </th>
                                    <th></th>
                                </tr>
                                <tr>
                                    <td>
                                        <%=ASSystem.currency %><%=GetMoney(team["Market_price"])%>
                                    </td>
                                    <td>
                                        <%=GetMoney(team["teamscore"])%>积分
                                    </td>
                                    <td></td>
                                </tr>
                            </table>
                            <div class="deal-box deal-status deal-status-open" id="deal-status">
                                <p class="deal-buy-tip-top">
                                    <strong>
                                        <%=CurrentTeam.Now_number %></strong> 人已兑换
                                </p>
                                <%if (CurrentTeam.Max_number > 0 && CurrentTeam.Max_number > CurrentTeam.Now_number)
                                  { %>
                                <p class="deal-buy-tip-btm">
                                    本单仅剩：<strong><%=CurrentTeam.Max_number-CurrentTeam.Now_number %></strong>份，欲兑换从速
                                </p>
                                <%} %>
                                <%if ((CurrentTeam.Max_number == 0) || (CurrentTeam.Max_number - CurrentTeam.Now_number) > 0)
                                  { %><br />
                                还可以继续兑换<%} %>
                                </p>
                            </div>
                        </div>
                        <div class="side">
                            <div class="deal-buy-cover-img" id="team_images">
                                <%if (team["image1"] != String.Empty || team["image2"] != String.Empty)
                                  { %>
                                <div class="mid">
                                    <ul>
                                        <li class="first"><a href="<%=getTeamPageUrl(int.Parse(team["id"]))%>" target="_blank">
                                            <img <%=ashelper.getimgsrc(team["image"]) %> class="dynload" /></a></li>
                                        <%if (team["image1"] != String.Empty)
                                          { %>
                                        <li><a href="<%=getTeamPageUrl(int.Parse(team["id"]))%>" target="_blank">
                                            <img <%=ashelper.getimgsrc(team["image1"]) %> class="dynload" /></a></li>
                                        <%} %>
                                        <%if (team["image2"] != String.Empty)
                                          { %>
                                        <li><a href="<%=getTeamPageUrl(int.Parse(team["id"]))%>" target="_blank">
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
                                <img <%=ashelper.getimgsrc(team["image"]) %> class="dynload" width="440" height="280" />
                                <%} %>
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
                                    <div class="blk detail" zoom_img_width="480">
                                        <%=ashelper.returnContentDetail(team["detail"].ToString())%>
                                    </div>
                                    <%} %>
                                    <%if (!String.IsNullOrEmpty(team["notice"]))
                                      { %>
                                    <h2 id="H2">
                                        <img src="<%=ImagePath() %>tbts.jpg" alt="特别提示" /></h2>
                                    <div class="blk cf" zoom_img_width="480">
                                        <%=team["notice"]%>
                                    </div>
                                    <%} %>
                                    <%if (!String.IsNullOrEmpty(team["userreview"]))
                                      { %>
                                    <h2 id="H3">
                                        <img src="<%=ImagePath() %>tms.jpg" alt="他们说" /></h2>
                                    <div class="blk review" zoom_img_width="480">
                                        <%=PageValue.GetSpilt(team["userreview"])%>
                                    </div>
                                    <%} %>
                                    <%if (!String.IsNullOrEmpty(team["systemreview"]))
                                      { %>
                                    <h2 id="H4">
                                        <%=ASSystemArr["abbreviation"]%>说</h2>
                                    <div class="blk review" zoom_img_width="480">
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
                                    <%if (CurrentTeam.Begin_time <= DateTime.Now)
                                      {
                                    %>
                                    <div class="buttonbuy">
                                        心动积分 <strong>
                                            <%=GetMoney(team["teamscore"])%>
                                        </strong><a href="<%=buyurl %>"><span class="deal-price-buy"></span></a>
                                    </div>
                                    <% }
                                      else
                                      {%>
                                    <% }%>
                                    <% } %>
                                </div>
                                <%if (ASSystem.teamwhole == 1 && part != null)
                                  { %>
                                <div class="side" id="team_partner_side_<%=twoline %>">
                                    <div id="side-business">
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
                                </div>
                                <% }%>
                                <div class="clear">
                                </div>
                            </div>
                        </div>
                    </div>
                    <!--老模式结束-->
                    <% }
                        else
                        {
                    %>
                    <!--修改代码开始-->
                    <div id="deal-stuff1" class="cf1">
                        <div class="clear box ">
                            <div class="box-content1 cf1">
                                <div class="slider-wrap">
                                    <div class="xxk">
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
                                                <div class="clear">
                                                </div>
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
                                                            <p class="deal-price">
                                                                <%if (CurrentTeam.Begin_time <= DateTime.Now)
                                                                  {
                                                                %>
                                                                <div class="buttonbuy">
                                                                    心动积分 <strong>
                                                                        <%=GetMoney(team["teamscore"])%>
                                                                    </strong><a href="<%=buyurl %>"><span class="deal-price-buy"></span></a>
                                                                </div>
                                                                <% }
                                                                  else
                                                                  {%>
                                                                <% }%>
                                                            </p>
                                                            <% }
                                      
                                                            %>
                                                        </div>
                                                        <!--项目详情结束-->
                                                        <!--本单答疑开始-->
                                                        <div class="undis" id="tbc_02" zoom_img_width="680">
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
                                                        <!--买家评论开始-->
                                                        <div class="undis" id="tbc_03" zoom_img_width="680">
                                                            <%if (listuserreview != null && listuserreview.Count > 0)
                                                              {
                                                                  foreach (IUserReview review in listuserreview)
                                                                  {
                                                                      if (i <= 9)
                                                                      { 
																	        
                                                            %>
                                                            <div class="comments">
                                                                <div class="deal_pic">
                                                                    <a href="<%=getTeamPageUrl(int.Parse(review.review_teamid.ToString()))%>" target="_blank">
                                                                        <img <%=ashelper.getimgsrc(review.Image) %> class="dynload" width="110" height="70"
                                                                            border="0" />
                                                                    </a>
                                                                </div>
                                                                <div class="comment_content">
                                                                    <div class="pltitle">
                                                                        <div class="desc">
                                                                            <%=GetUserLevel(Helper.GetDecimal(review.totalamount, 0))%>:<%=review.username%>
                                                                            评论了TA在<%=ASSystem.abbreviation%>买到的&nbsp;<a href="<%=getTeamPageUrl(Helper.GetInt(review.review_teamid,0))%>"><%=review.Title%></a>
                                                                        </div>
                                                                        <p class="pingjia">
                                                                            <%=review.comment%>
                                                                        </p>
                                                                        <div class="clear">
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <%}
                                                                      else { break; }

                                                                i++;
																		 
                                                                  }%>
                                                            <div class="ckgdpl">
                                                                <a href="<%=GetUrl("到货评价","buy_list_comments.aspx")%>">查看更多评论</a>
                                                            </div>
                                                            <% if (CookieUtils.GetCookieValue("username",Key) == String.Empty)
                                                               { %>
                                                            <a href="<%=GetUrl("用户登录","account_login.aspx")%>">登录</a>后可以单独查看您的评价
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
                                                        <div class="undis" id="tbc_04" zoom_img_width="435">
                                                            <div class="partnerinfo">
                                                                <h2>
                                                                    <%=partner["title"]%></h2>
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
                                                                    <img alt="" src="<%=partner["Image2"] %>" />
                                                                </div>
                                                                <%} %>
                                                            </div>
                                                            <%if (partner["location"] != null && partner["location"].ToString() != "")
                                                              { %>
                                                            <div class="sjadd">
                                                                <span class="sjinfo_tt">位置信息：</span><%=partner["location"]%>
                                                            </div>
                                                            <%} %>
                                                        </div>
                                                        <% }%>
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
                        <!--修改代码结束-->
                    </div>
                    <% }%>
                </div> <div id="sidebar">
                    <%LoadUserControl(PageValue.WebRoot + "UserControls/adleft.ascx", null); %>
                    <%LoadUserControl(PageValue.WebRoot + "UserControls/blockotherspoint.ascx", null); %>
                    <%LoadUserControl(PageValue.WebRoot + "UserControls/blockbulletin.ascx", null); %>
                    <%LoadUserControl(PageValue.WebRoot + "UserControls/blockflv.ascx", CurrentTeam); %>
                    <%LoadUserControl(PageValue.WebRoot + "UserControls/uc_NewList.ascx", null); %>
                    <%LoadUserControl(PageValue.WebRoot + "UserControls/blockvote.ascx", null); %>
                    <%LoadUserControl(PageValue.WebRoot + "UserControls/blocksubscribe.ascx", null); %>
                </div>
                
            </div>
        </div>
    </div>
    <!-- bd end -->
</div>
<%LoadUserControl("_footer.ascx", null); %>
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
    });

</script>
<%LoadUserControl("_htmlfooter.ascx", null); %>
