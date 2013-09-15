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
    protected StringBuilder strhtml = new StringBuilder();
    protected IList<ITeam> list_team = null;
    protected TeamFilter teamfil = new TeamFilter();
    protected string pagerhtml = string.Empty;
    protected IPagers<ITeam> pager = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "我的代金券";
        MobileNeedLogin();
        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            InitData();
        }
    }
    //根据商户ID获取此商户的项目
    private void InitData()
    {
        int partnerId = int.Parse(Request["id"].ToString());
        teamfil.PageSize = 15;
        teamfil.CurrentPage = AS.Common.Utils.Helper.GetInt(Request["page"], 1);
        teamfil.AddSortOrder(OrderFilter.ID_DESC);
        teamfil.Partner_id = partnerId;
        teamfil.teamcata = 0;
        teamfil.ToBegin_time = DateTime.Now;
        teamfil.FromEndTime = DateTime.Now;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Teams.GetPager(teamfil);
        }
        list_team = pager.Objects;
        if (list_team != null && list_team.Count > 0)
        {
            pagerhtml = WebUtils.GetMBPagerHtml(15, pager.TotalRecords, pager.CurrentPage, GetUrl("手机版个人中心代金卷查看商户项目", "account_card_product.aspx?id=" + partnerId + "&page={0}"));
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<body id='orders'>
    <header>
            <div class="left-box">
                <a class="go-back" href="<%=GetUrl("手机版个人中心代金卷","account_card.aspx") %>"><span>返回</span></a>
            </div>
        <h1>我的代金券</h1>
    </header>
    <div class="body">
        <div id="deals">
            <%if (list_team != null && list_team.Count > 0)
              {%>
            <% foreach (var item in list_team)
               {%>
            <div>
                <a href="<%=GetMobilePageUrl(item.Id) %>">
                    <img data-src="<%=item.PhoneImg==null?String.Empty:item.PhoneImg%>" width="122" height="74"
                        alt="<%=item.Product %>" />
                    <detail>
                    <ul>
                        <li class="brand"><%=item.Product %></li>
                        <li class="title indent"><%=item.Title %></li>
                        <li class="price"><strong><%=GetMoney(item.Team_price)%></strong>元<del><%=GetMoney(item.Market_price)%>元</del><span><%=item.Now_number%>人</span></li>
                    </ul>
                </detail>
                </a>
            </div>
            <%}%>
            <%}
              else
              {%>
            <div class="isEmpty">
                抱歉，此商户下暂时没有正在进行的项目</div>
            <%} %>
        </div>
        <nav class="pageinator">
        <div id="nav-page">
            <%=pagerhtml %>
        </div>
        <div id="nav-top">
            <span class="nav-button" onclick="javascript:void(window.scrollTo(0, 0));"><span>回到顶部</span></span>
        </div>
    </nav>
    </div>
    <%LoadUserControl("_footer.ascx", null); %>
    <%LoadUserControl("_htmlfooter.ascx", null); %>
