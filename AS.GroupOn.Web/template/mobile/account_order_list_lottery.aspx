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
    protected ITeam teammodel = null;
    protected IPagers<IDraw> pager = null;
    protected string pagerhtml = string.Empty;
    protected IList<IDraw> list_draw = null;
    protected IList<IDraw> list_draws = null;
    protected StringBuilder strhtml = new StringBuilder();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "订单";
        MobileNeedLogin();
        InitData();
    }
    //获取抽奖数据
    public void InitData()
    {
        DrawFilter drawfil = new DrawFilter();
        //drawfil.userid = AsUser.Id;
        drawfil.table = " (select teamid from draw where userid="+AsUser.Id+" group by teamid)as a";
        drawfil.PageSize = 15;
        drawfil.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        drawfil.AddSortOrder(DrawFilter.TeamID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Draw.GetPageChou(drawfil);
        }
        list_draw = pager.Objects;
        if (list_draw != null && list_draw.Count > 0)
        {
            for (int i = 0; i < list_draw.Count; i++)
            {
                strhtml.Append("<div class='order-box'>");
                strhtml.AppendFormat("<a href='{0}'>", GetUrl("手机版个人中心订单抽奖单详情", "account_order_lottery_view.aspx?teamid=" + list_draw[i].teamid));
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teammodel = session.Teams.GetByID(Helper.GetInt(list_draw[i].teamid, 0));
                }
                if (teammodel != null)
                {
                    strhtml.AppendFormat("<img src='{0}' alt='{1}' width='122' height='74' />", PageValue.CurrentSystem.domain + WebRoot + (teammodel.PhoneImg == null ? String.Empty : teammodel.PhoneImg), teammodel.Product);
                    strhtml.Append("<h3>" + teammodel.Product + "</h3>");
                }
                strhtml.Append("<ul>");

                DrawFilter drawfils = new DrawFilter();
                drawfils.teamid = list_draw[i].teamid;
                drawfils.userid = AsUser.Id;
                string strnum = "";
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    list_draws = session.Draw.GetList(drawfils);
                }
                if (list_draws != null)
                {
                    for (int j = 0; j < list_draws.Count; j++)
                    {
                        strnum += list_draws[j].number + "<br/>";
                    }
                    strhtml.Append("<li class='coupon'>您的抽奖号是：<br><strong>" + strnum + "</strong></li>");
                }
                strhtml.Append("</ul>");
                strhtml.Append("</a></div>");
            }
            pagerhtml = WebUtils.GetMBPagerHtml(15, pager.TotalRecords, pager.CurrentPage, GetUrl("手机版个人中心订单抽奖单", "account_order_list_lottery.aspx?page={0}"));
        }
        else
        {
            strhtml.Append("<p class='isEmpty'>没有相关数据</p>");
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<body id='orders'>
    <header>
        <div class="left-box">
            <a class="go-back" href="<%=GetUrl("手机版首页","index.aspx") %>"><span>返回首页</span></a>
        </div>
        <h1>订单</h1>
    </header>
    <menu>
        <ul>
            <li><a href="<%=GetUrl("手机版个人中心订单","account_orders.aspx") %>">待付款</a></li>
            <li><a href="<%=GetUrl("手机版个人中心订单已退款","account_order_list_refund.aspx") %>">已退款</a></li>
            <li class="current"><a href="<%=GetUrl("手机版个人中心订单抽奖单","account_order_list_lottery.aspx") %>">抽奖单</a></li>
            <li><a href="<%=GetUrl("手机版个人中心订单已消费","account_order_list_used.aspx") %>">已付款</a></li>
        </ul>
    </menu>
    <div class="body">
        <div id="orders-tips" class="orders-tips">
            <p>订单状态可能会有延迟，请以实际消费情况为准</p>
        </div>
        <div id="orders-list">
            <%=strhtml %>

            <nav class="pageinator">
                <div id="nav-page">
                    <%=pagerhtml %>
                </div>
                <div id="nav-top">
                    <span class="nav-button" onclick="javascript:void(window.scrollTo(0, 0));"><span>回到顶部</span></span>
                </div>
            </nav>

        </div>
    </div>
    <%LoadUserControl("_footer.ascx", null); %>
    <%LoadUserControl("_htmlfooter.ascx", null); %>