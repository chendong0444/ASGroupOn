<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    
    protected NameValueCollection _system = new NameValueCollection();
    protected SystemFilter systembll = new SystemFilter();
    protected ISystem systemmodel = null;
    protected ITeam m_team = null;
    protected IPagers<IUserReview> pager = null;
    protected TeamFilter teamft = new TeamFilter();
    protected string where = "1=1 ";
    protected UserReviewFilter userreviewft = new UserReviewFilter();
    protected int page = 1;
    protected string catateam = "2";
    protected int idteam = 0;
    protected string pagerhtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        page = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        idteam = AS.Common.Utils.Helper.GetInt(Request.QueryString["idteam"], 1);
        catateam = AS.Common.Utils.Helper.GetString(Request.QueryString["catateam"], "2");

        setBuyTitle();
    }
    //<summary>
    ///买家评论内容
    ////summary>
    public void setBuyTitle()
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            systemmodel = session.System.GetByID(1);
        }
        _system = AS.Common.Utils.WebUtils.GetSystem();
        if (_system["navUserreview"] != null && _system["UserreviewYN"] == "1")
        {
            if (catateam == "1")
            {
                userreviewft.state = 1;
                userreviewft.team_id = idteam;
                userreviewft.unstate = 2;
                userreviewft.teamcata = 1;
            }
            else if (catateam == "0")
            {
                userreviewft.teamcata = 0;
                userreviewft.state = 1;
                userreviewft.unstate = 2;
            }
            else
            {
                userreviewft.state = 1;
                userreviewft.unstate = 2;
            }
        }
        else
        {
            if (catateam == "1")
            {
                userreviewft.unstate = 2;
                userreviewft.teamcata = 1;
                userreviewft.team_id = idteam;
            }
            else if (catateam == "0")
            {
                userreviewft.unstate = 2;
                userreviewft.teamcata = 0;
            }
            else
            {
                userreviewft.unstate = 2;
            }
        }
        url = url + "&page={0}";
        url = GetUrl("到货评价", "buy_list_comments.aspx?" + url.Substring(1));
        userreviewft.PageSize = 30;
        userreviewft.AddSortOrder(UserReviewFilter.ID_DESC);
        userreviewft.AddSortOrder(UserReviewFilter.Create_Time_DESC);
        userreviewft.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.UserReview.GetPager(userreviewft);
        }
        pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        IList<IUserReview> listuserview = pager.Objects;
        System.Data.DataTable dt2 = AS.Common.Utils.Helper.ToDataTable(listuserview.ToList());
        if (pager != null)
        {
            if (dt2.Rows.Count > 0)
            {

                if (systemmodel != null)
                {
                    StringBuilder sb1 = new StringBuilder();
                    DateTime dt = System.DateTime.Now;
                    for (int i = 0; i < dt2.Rows.Count; i++)
                    {
                        System.Data.DataRow dr = dt2.Rows[i];
                        //提取时间
                        IUserReview userre = null;
                        int id = Convert.ToInt32(dr["user_id"]);
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            userre = session.UserReview.GetByID(Convert.ToInt32(dr["id"]));
                        }
                        DateTime dt1 = Convert.ToDateTime(dr["create_time"].ToString());
                        sb1.Append("<div class='comments'>");
                        sb1.Append(" <div class='comment_content'>");
                        if (userre.user_id != 0 && userre.user != null)
                        {
                            sb1.Append(" <div class='desc'><b>" + userre.user.Username + "</b>:&nbsp;&nbsp;&nbsp;&nbsp;" + dr["comment"].ToString() + " </div>");
                        }
                        else
                        {
                            sb1.Append(" <div class='desc'><b></b>:&nbsp;&nbsp;&nbsp;&nbsp;" + dr["comment"].ToString() + " </div>");
                        }
                        sb1.Append("<div class='pltitle'>");
                        ITeam team = null;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            team = session.Teams.GetByID(userre.team_id);
                        }
                        if (team != null)
                        {
                            sb1.Append("评论了在" + systemmodel.abbreviation + "买到的&nbsp;<a href='" + getTeamPageUrl(team.Id) + "'>" + AS.Common.Utils.Helper.GetSubString(team.Title, 56) + "</a>");
                        }
                            sb1.Append("</div>");
                        sb1.Append("<div class='time'>");
                        if (dt1 != null)
                        {
                            sb1.Append(returnTime(dt, dt1));
                        }
                        else
                        {
                            sb1.Append("&nbsp;");
                        }
                        sb1.Append("</div>");
                        sb1.Append("</div>");

                        sb1.Append("<div class='clear'></div>");
                        sb1.Append("</div>");

                    }

                    sb1.Append("</div>");
                    Literal1.Text = sb1.ToString();
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
<body>
    <form id="form1" runat="server">
    <div id="bdw" class="bdw">
        <div id="bd" class="cf">
            <div id="consult">
                <div id="content">
                    <div class="box clear">
                        <div id="pl_content">
                            <div class="content_body">
                                <ul style="float: left;" class="pl">
                                    <li class="ckpl"><a href="#">全部评价</a></li>
                                    <% if (AS.Common.Utils.CookieUtils.GetCookieValue("username").Length == 0)
                                       { %>
                                    <li><a href="<%=GetUrl("用户登录","account_login.aspx")%>">登录</a>后可以单独查看您的评价</li>
                                    <%}
                                       else
                                       { %>
                                    <li class="ckpl"><a href="<%=GetUrl("产品未评论分页用","buy_send_listcomments.aspx")%>">我的评论</a></li>
                                    <%} %>
                                </ul>
                                <div class="clear">
                                </div>
                                <p>
                                </p>
                                <p>
                                    这里是在<%=systemmodel.abbreviation %>购物过的朋友留下的评价。您也可以在"我的<%=systemmodel.abbreviation %>"下方的"我的订单"里面给已经发货的订单评价哦~</p>
                                <!--买家评论循环开始-->
                                <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                <!--买家评论循环结束-->
                                <div>
                                    <ul class="paginator" style="margin-bottom: 20px; *margin-bottom: 4px;">
                                        <li class="current">
                                            <%= pagerhtml %>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                            <!--翻页列表部分 -->
                        </div>
                    </div>
                </div>
                <div id="sidebar">
                    <%LoadUserControl(WebRoot + "UserControls/comment_right.ascx", null); %>
                </div>
            </div>
        </div>
        <!-- bd end -->
    </div>
    <!-- bdw end -->
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
