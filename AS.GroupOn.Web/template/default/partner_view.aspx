<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected IPagers<ITeam> pager = null;
    protected IPagers<IUserReview> pagers = null;
    protected IList<ITeam> iListTeam = null;
    protected string url = "";
    protected string ur = "";
    protected string strTitile = "";
    protected string strOther = "";
    protected string strPhone = "";
    protected string strAdress = "";
    protected string strHomePage = "";
    protected int strTeamCount = 0;
    protected int strJoinNumber = 0;
    //protected int strSaveNumber = 0;
    protected string strImg = "";
    protected string strImg1 = "";
    protected string strImg2 = "";
    protected string strpage;
    protected string strpages;
    protected string pagenum = "1";
    protected DataTable ds_pro = null;
    protected TeamFilter teamft = new TeamFilter();
    protected IList<ITeam> teamlist = null;
    //全部点评
    protected string page = "1";
    protected string strID = "";
    protected NameValueCollection _system = new NameValueCollection();
    protected SystemFilter systemft = new SystemFilter();
    protected ISystem systemm = null;
    protected ITeam m_team = null;
    public int allCount = 0;
    public int count = 0;
    //点评数
    public int userReviewCount = 0;
    //满意
    public int manYiCount = 0;
    //一般
    public int yiBanCount = 0;
    //失望
    public int shiWangCount = 0;

    //团购项目或全部点评
    //0为团购项目1为全部点评
    public string type = "0";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = AS.Common.Utils.WebUtils.GetSystem();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            systemm = session.System.GetByID(1);
        }
        if (Request["pagenum"] != null)
        {
            if (AS.Common.Utils.NumberUtils.IsNum(Request["pagenum"].ToString()))
            {
                pagenum = Request["pagenum"].ToString();
            }
            else
            {
                SetError("您输入的参数非法");
            }
        }
        if (Request["page"] != null)
        {
            if (AS.Common.Utils.NumberUtils.IsNum(Request["page"].ToString()))
            {
                page = Request["page"].ToString();
            }
            else
            {
                SetError("您输入的参数非法");
            }
        }
        if (!Page.IsPostBack)
        {
            initPage();
        }
        if (Request["type"] != null)
        {
            if (Request["type"].ToString() == "1")
            {
                type = "1";
            }
        }
        if (type == "1")
        {
            this.liShow.Attributes.Add("class", "");
            this.liShow2.Attributes.Add("class", "current");
            this.idTeam.Style.Add("display", "none");
            this.idUserreview.Style.Add("display", "block");
        }
    }

    private void initPage()
    {
        string strID = "";
        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            strID = Request["id"].ToString();

            if (!AS.Common.Utils.NumberUtils.IsNum(strID))
            {
                SetError("参数错误！");
                return;
            }

            PartnerFilter partnerft = new PartnerFilter();
            IPartner partnermodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                partnermodel = session.Partners.GetByID(int.Parse(strID));
            }
            if (partnermodel != null)
            {
                strTitile = partnermodel.Title;
                strOther = partnermodel.Other;
                strPhone = partnermodel.Phone;
                strAdress = partnermodel.Address;
                strHomePage = partnermodel.Homepage;
                strImg = partnermodel.Image;
                string strOpen = partnermodel.Open;

                StringBuilder sb = new StringBuilder();
                StringBuilder sb1 = new StringBuilder();
                if (partnermodel.Image1 != "")
                {
                    strImg1 = partnermodel.Image1;
                    sb.Append("<li><img src=\"" + strImg1 + " \"/></li>");
                    sb1.Append("<a ref=\"2\" >2</a>");
                }

                if (partnermodel.Image2 != "")
                {
                    strImg2 = partnermodel.Image2;
                    sb.Append("<li><img src=\"" + strImg2 + "\"/></li>");
                    sb1.Append("<a ref=\"3\" >3</a>");
                }
                ltIndex.Text = sb1.ToString();
                ltImg.Text = sb.ToString();      
            }
            teamft.Partner_id = AS.Common.Utils.Helper.GetInt(strID,0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teamlist = session.Teams.GetList(teamft);
                //teamlist = session.Teams.GetList("select count(*) as num FROM Team where Partner_id =" + strID);
         
                strTeamCount = teamlist.Count;
            }
            foreach (ITeam item in teamlist)
            {
                strJoinNumber += item.Now_number;
            }

            float fSaveNumber = 0;
            DataTable dt = AS.Common.Utils.Helper.ToDataTable(teamlist.ToList());
            if (dt != null)
            {
                if (dt.Rows.Count > 0)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        DataRow dr = dt.Rows[i];
                        float Market_price = float.Parse(dr["Market_price"].ToString());
                        float Team_price = float.Parse(dr["Team_price"].ToString());

                        //该每个产品节约的钱 
                        float fsave = Market_price - Team_price;

                        //得到该产品的订单数
                        OrderFilter orderft = new OrderFilter();
                        orderft.Team_id = Convert.ToInt32(dr["id"]);
                        IList<IOrder> listorder = null;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            listorder = session.Orders.GetList(orderft);
                        }
                        int iQuantity = 0;
                        foreach (IOrder item in listorder)
                        {
                            iQuantity += item.Quantity;
                        }
                        //该项目节约的钱数
                        fSaveNumber = fSaveNumber + fsave * iQuantity;
                    }
                }

            }
            //strSaveNumber = AS.Common.Utils.Helper.GetInt(fSaveNumber, 0);
            initPro(int.Parse(strID));
            setBuyTitle(int.Parse(strID));

            UserReviewFilter userReviewft = new UserReviewFilter();
            //根据商户ID获取评论
            userReviewft.type = "partner";
            userReviewft.state = 1;
            userReviewft.partner_id = AS.Common.Utils.Helper.GetInt(strID,0);
            IList<IUserReview> ilistuserreview = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilistuserreview = session.UserReview.GetList(userReviewft);
            }
            System.Data.DataTable dt2 = AS.Common.Utils.Helper.ToDataTable(ilistuserreview.ToList());

            if (_system["openUserreviewPartner"] != null && _system["openUserreviewPartner"].ToString() == "1")
            {
                //循环评论分值
                if (dt2.Rows.Count > 0)
                {
                    for (int z = 0; z < dt2.Rows.Count; z++)
                    {
                        if (int.Parse(dt2.Rows[z]["score"].ToString()) == 0)
                        {
                            count = count + 0;
                            shiWangCount = shiWangCount + 1;
                        }
                        else
                        {
                            count = count + int.Parse(dt2.Rows[z]["score"].ToString());
                            if (dt2.Rows[z]["score"].ToString() == "100")
                            {
                                manYiCount = manYiCount + 1;
                            }
                            if (dt2.Rows[z]["score"].ToString() == "50")
                            {
                                yiBanCount = yiBanCount + 1;
                            }
                        }
                        allCount = allCount + 100;
                    }
                }
                userReviewCount = dt2.Rows.Count;
            }
        }
    }
    protected string strCurrency = "";
    private void initPro(int PartnerID)
    {
        url = url + "&page={0}&pagenum={0}&type=0";
        url = GetUrl("品牌商户详情", "partner_view.aspx?" + url.Substring(1) + "&id=" + PartnerID);
        strCurrency = systemm.currency;
        TeamFilter teamft = new TeamFilter();
        teamft.Partner_id = PartnerID;
        teamft.PageSize = 4;
        teamft.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        teamft.AddSortOrder(TeamFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Teams.GetPager(teamft);
        }
        iListTeam = pager.Objects;
        ds_pro = AS.Common.Utils.Helper.ToDataTable(iListTeam.ToList());
        strpage = AS.Common.Utils.WebUtils.GetPagerHtml(4, pager.TotalRecords, pager.CurrentPage, url);
    }

    //<summary>
    ///买家评论内容
    ////summary>
    public void setBuyTitle(int PartnerID)
    {
        if (_system["openUserreviewPartner"] != null && _system["openUserreviewPartner"].ToString() == "1")
        {
            UserReviewFilter userreviewft = new UserReviewFilter();
            userreviewft.type = "partner";
            userreviewft.state = 1;
            userreviewft.partner_id = int.Parse(Request["id"]);
            userreviewft.PageSize = 10;
            userreviewft.AddSortOrder(UserReviewFilter.ID_DESC);
            userreviewft.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pagers = session.UserReview.GetPager(userreviewft);
            }
            IList<IUserReview> listuserreview = pagers.Objects;
            System.Data.DataTable dt2 = AS.Common.Utils.Helper.ToDataTable(listuserreview.ToList());
            if (pagers != null)
            {
                if (dt2.Rows.Count > 0)
                {

                    if (systemm != null)
                    {
                        StringBuilder sb1 = new StringBuilder();
                        DateTime dtime = System.DateTime.Now;
                        for (int i = 0; i < dt2.Rows.Count; i++)
                        {
                            //提取时间

                            DataRow dr = dt2.Rows[i];
                            DateTime dt1 = Convert.ToDateTime(dr["create_time"].ToString());
                            sb1.Append("<div class='comments'>");
                            sb1.Append("<div class='deal_pic'>");
                            if (dr["Id"] != null && dr["Id"].ToString() != "")
                            {
                                sb1.Append("<a href='" + getTeamPageUrl(int.Parse(dr["Id"].ToString())) + "' target='_blank' title='" + dr["title"] + "'>");
                                sb1.Append("<img src='" + AS.Common.Utils.ImageHelper.getSmallImgUrl(dr["Image"].ToString()) + "' width='110' height='70'  border='0'/>");
                                sb1.Append("</a>");
                            }
                            sb1.Append("</div>");
                            sb1.Append(" <div class='comment_content'>");
                            sb1.Append("<div class='pltitle'>");
                            if (dr["Id"] != null && dr["Id"].ToString() != "")
                            {
                                IUser user = null;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    user = session.Users.GetByID(AS.Common.Utils.Helper.GetInt(dr["user_id"].ToString(),0));
                                }
                                sb1.Append(" <div class='desc'>" + user.Username + " 评论了TA在" + systemm.abbreviation + "买到的&nbsp;<a href='" + getTeamPageUrl(int.Parse(dr["Id"].ToString())) + "' target='_blank' title='" + dr["title"] + "'>" + dr["Title"].ToString() + "</a></div>");
                            }
                            sb1.Append("<div class='time'>");
                            if (dt1 != null)
                            {
                                sb1.Append(returnTime(dtime, dt1));
                            }
                            else
                            {
                                sb1.Append("&nbsp;");
                            }
                            sb1.Append("</div>");
                            sb1.Append("<div class='clear'></div>");
                            sb1.Append("</div>");
                            sb1.Append("<p class='pingjia'>" + dr["comment"].ToString() + "</p>");
                            sb1.Append("</div>");
                            sb1.Append("</div>");
                        }

                        //sb1.Append("</div>");
                        Literal1.Text = sb1.ToString();
                        strpages = AS.Common.Utils.WebUtils.GetPagerHtml(10, pagers.TotalRecords, Convert.ToInt32(page), GetUrl("品牌商户详情", "partner_view.aspx?id=" + PartnerID + "&ur=true&page={0}&type=1"));
                    }
                }
            }
        }
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
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript" language="javascript">
    function show(num) {
        var num = num;
        if (num == 1) {
            $("#liShow").attr("class", "current");
            $("#liShow2").attr("class", "");
            $("#idTeam").show();
            $("#idUserreview").hide();
        }
        else {
            $("#liShow").attr("class", "");
            $("#liShow2").attr("class", "current");
            $("#idUserreview").show();
            $("#idTeam").hide();
        }
    }
</script>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="deal-default">
            <div id="content">                
                    <div id="deal-intro" class="cf">
                        <h1 style="padding-left: 0;">
                            商户：<%=strTitile %></h1>
                        <div class="main">
                            <div class="partner_team_box">
                                <div class="other" style="margin: 10px; padding: 5px;">
                                    <p>
                                        <b>电话</b>：<%=strPhone %></p>
                                    <p>
                                        <b>地址</b>：<%=strAdress %></p>
                                    <p>
                                        <b>网址</b>：<a href="http://<%=strHomePage %>" target="_blank"><%=strHomePage%></a></p>
                                </div>
                                <% if (_system["openUserreviewPartner"] != null && _system["openUserreviewPartner"].ToString() == "1")
                                   { %>
                                <p id="partner-btn">
                                    <%if (allCount == 0)
                                      {%>
                                    <span class="h-comment">满意度--%</span>
                                    <%} %>
                                    <%else
                                        { %>
                                    <span class="h-comment">满意度
                                        <%=Convert.ToDouble((Convert.ToDouble(count) / Convert.ToDouble(allCount)).ToString("0.00")) * 100%>%
                                        <%} %>
                                    </span><span class="partner-comment-btn"><a href="<%=GetUrl("个人中心商户已评论","buy_Send_list_pcomments.aspx?id="+Request["id"])%>"
                                        id="partner-comment-btn"></a></span>
                                </p>
                                </p>
                                <div class="partner-dianping">
                                    <p style="line-height: 24px;">
                                        共 <strong>
                                            <%=userReviewCount%></strong> 条点评：
                                    </p>
                                    <p>
                                        <image src="<%=ImagePath() %>comment-icon-A.gif"></image>
                                        &nbsp;<span>满意:</span><%=manYiCount%></p>
                                    <p>
                                        <image src="<%=ImagePath() %>comment-icon-P.gif"></image>
                                        &nbsp;<span>一般:</span><%=yiBanCount%></p>
                                    <p>
                                        <image src="<%=ImagePath() %>comment-icon-F.gif"></image>
                                        &nbsp;<span>失望:</span><%=shiWangCount%></p>
                                </div>
                                <%} %>
                                <div class="partner_team_info" style="margin: 10px; padding: 5px;">
                                    <p>
                                        组织 <b>
                                            <%=strTeamCount %></b> 次团购<p>
                                                <p>
                                                    购买 <b>
                                                        <%=strJoinNumber %></b> 人次</p>
                                                <%--<p>
                                                    节省 <b>
                                                        <%=strSaveNumber%></b> 元</p>--%>
                                </div>
                            </div>
                        </div>
                        <div class="side">
                            <div class="deal-buy-cover-img" id="team_images">
                                <div class="mid">
                                    <ul>
                                        <li class="first">
                                            <img src="<%=strImg %>" /></li>
                                        <asp:literal id="ltImg" runat="server"></asp:literal>
                                    </ul>
                                    <div id="img_list">
                                        <a ref="1" class="active">1</a>
                                        <asp:literal id="ltIndex" runat="server">   </asp:literal>
                                    </div>
                                </div>
                                <img src="<%=strImg %>" width="440" height="280" />
                            </div>
                            <p style="text-indent: 2em; word-spacing: 2px; margin-top: 10px;">
                                <%=strOther %></p>
                        </div>
                    </div>
                    <div id="recent-deals" class="cf" style="margin-top: 15px;">
                        <div id="Div1" class="dashboard">
                            <ul>
                                <li id="liShow" runat="server" class="current"><a onclick="show(1)" style="cursor: pointer">
                                    团购项目</a><span></span></li>
                                <%if (_system["openUserreviewPartner"] != null && _system["openUserreviewPartner"].ToString() == "1")
                                  { %>
                                <li id="liShow2" runat="server"><a onclick="show(2)" style="cursor: pointer">全部点评</a><span></span></li></ul>
                            <%} %>
                        </div>
                        <div id="Div4" class="ppsh" runat="server">
                            <div class="sect" style="border: 0" id="idTeam" runat="server">
                                <ul class="deals-list">
                                    <%
                                        StringBuilder sb = new StringBuilder();
                                        if (ds_pro != null)
                                        {
                                            if (ds_pro.Rows.Count > 0)
                                            {
                                                for (int i = 0; i < ds_pro.Rows.Count; i++)
                                                {

                                                    string strId = ds_pro.Rows[i]["ID"].ToString();
                                                    string strTitle = ds_pro.Rows[i]["Title"].ToString();
                                                    string strBeginTime = ds_pro.Rows[i]["Begin_time"].ToString();
                                                    string strImg_p = ds_pro.Rows[i]["Image"].ToString();
                                                    string strNowNumber = ds_pro.Rows[i]["Now_number"].ToString();
                                                    string strTeamPrice = ds_pro.Rows[i]["Team_price"].ToString();
                                                    string strMarketPrice = ds_pro.Rows[i]["Market_price"].ToString();
                                                    string fDiscount = AS.Common.Utils.WebUtils.GetDiscount(AS.Common.Utils.Helper.GetDecimal(strMarketPrice, 0), AS.Common.Utils.Helper.GetDecimal(strTeamPrice, 0));

                                                    sb.Append("<li class=' first'>");
                                                    sb.Append("<p class=\"time\">" + DateTime.Parse(strBeginTime).ToString("yyyy-MM-dd") + "</p>");
                                                    sb.Append("<h4><a href=\"" + getTeamPageUrl(AS.Common.Utils.Helper.GetInt(strId.ToString(), 0)) + "\" title=\"" + strTitle + "\" target=\"_blank\">" + strTitle + "</a></h4>");
                                                    sb.Append("<div class='info'>");
                                                    sb.Append("<p class=\"howmanypp_buy\">");
                                                    sb.Append("<strong class=\"count\">" + strNowNumber + "</strong>人已购买");
                                                    sb.Append("</p>");
                                                    sb.Append("<p class=\"price\">");
                                                    sb.Append("<span class=\"price_xian\">现价:</span>");
                                                    sb.Append("<span class=\"xian_money\">" + strTeamPrice + "</span>");
                                                    sb.Append("<br/>");
                                                    sb.Append("原价:");
                                                    sb.Append("<strong class=\"old\"><span class=\"money\">" + strMarketPrice + "</span></strong>");
                                                    sb.Append("<br/>");
                                                    sb.Append("折扣:");
                                                    sb.Append("<strong class=\"discount\">" + fDiscount + "</strong>");
                                                    sb.Append("<br/>");
                                                    sb.Append("</p>");
                                                    sb.Append("</div>");
                                                    sb.Append("<div class=\"pic\">");
                                                    sb.Append("<a target=\"_blank\" alt=\"" + strTitle + "\" title=\"" + strTitle + "\" href=\"" + getTeamPageUrl(AS.Common.Utils.Helper.GetInt(strId.ToString(), 0)) + "\"><img height=\"121\" width=\"163\" alt=\"" + strTitle + "\" src=\"" + AS.Common.Utils.ImageHelper.getSmallImgUrl(strImg_p) + "\" width=\"200\" height=\"121\"></a>");
                                                    sb.Append("</div>");
                                                    sb.Append("</li>");
                                                }
                                            }

                                        }
                                        Response.Write(sb.ToString());
                                    %>
                                </ul>
                                <div class="clear">
                                </div>
                                <div>
                                    <div class="clear">
                                    </div>
                                    <div>
                                        <ul class="paginator">
                                            <li class="current">
                                                <%=strpage%>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                            <div class="content_body" id="idUserreview" runat="server" style="display: none">
                                <asp:literal id="Literal1" runat="server"></asp:literal>
                                <ul class="paginator" style="margin-bottom: 20px; *margin-bottom: 4px;">
                                    <li class="current">
                                        <%=strpages %>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>                
            </div>
            <div id="sidebar">
                <%LoadUserControl(WebRoot + "UserControls/blockbusiness.ascx", null); %>
                <%LoadUserControl(WebRoot + "UserControls/blocksubscribe.ascx", null); %>
            </div>
        </div>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>