<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

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
    protected IPagers<IOrder> pager = null;
    protected IList<IOrder> list_order = null;
    protected OrderFilter filter = new OrderFilter();
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected int id = 0;
    protected string type_name = "";
    protected string title = "";
    protected string username = "";
    protected string Service = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Order_Pay_ListView))
        {
            SetError("你不具有查看订单列表的权限！");
            Response.Redirect("index_index.aspx");
            return;
        }
        if (!string.IsNullOrEmpty(Request.QueryString["service"]))
        {
            url = url + "&service=" + Request.QueryString["service"];
            Service = Helper.GetString(Request.QueryString["service"], String.Empty);
            filter.Service = Service;
            if (Service != "")
            {
                title = GetTitle(Service);
                if (!string.IsNullOrEmpty(Request.QueryString["begintime"]))
                {
                    url = url + "&begintime=" + Request.QueryString["begintime"];
                    filter.FromPay_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["begintime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
                }
                if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
                {
                    url = url + "&endtime=" + Request["endtime"];
                    filter.ToPay_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
                }
                IUser uses = null;
                UserFilter u_filter = new UserFilter();
                if (!string.IsNullOrEmpty(Request.QueryString["username"]))
                {
                    url = url + "&username=" + Request.QueryString["username"];
                    u_filter.Username = Helper.GetString(Request.QueryString["username"], String.Empty);
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        uses = session.Users.Get(u_filter);
                    }
                    if (uses != null)
                    {
                        filter.User_id = uses.Id;
                    }
                    else
                    {
                        return;
                    }
                }
                if (!string.IsNullOrEmpty(Request.QueryString["email"]))
                {
                    url = url + "&email=" + Request.QueryString["email"];
                    u_filter.Email = Helper.GetString(Request.QueryString["email"], String.Empty);
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        uses = session.Users.Get(u_filter);
                    }
                    if (uses != null)
                    {
                        filter.User_id = uses.Id;
                    }
                    else
                    {
                        return;
                    }
                }
                if (!string.IsNullOrEmpty(Request.QueryString["teamid"]))
                {
                    url = url + "&teamid=" + Request["teamid"];
                    filter.Team_In = Helper.GetInt(Request["teamid"], 0);
                }
                InitData();
            }
        }
    }
    private string GetTitle(string service)
    {
        switch (service.ToLower())
        {
            case "yeepay":
                service = "易宝付款";
                break;
            case "alipay":
                service = "支付宝付款";
                break;
            case "tenpay":
                service = "财富通付款";
                break;
            case "chinabank":
                service = "网银在线";
                break;
            case "cashondelivery":
                service = "货到付款";
                break;
            case "credit":
                service = "余额付款";
                break;
            case "cash":
                service = "线下支付";
                break;
            case "chinamobilepay":
                service = "中国移动付款";
                break;
        }
        return service;
    }
    private void InitData()
    {
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        IUser user = Store.CreateUser();
        ITeam team = Store.CreateTeam();
        IList<ITeam> teamlist = null;
        IList<IOrderDetail> orderlist = null;
        sb1.Append("<tr >");
        sb1.Append("<th width='7%'>ID</th>");
        sb1.Append("<th width='22%'>项目</th>");
        sb1.Append("<th width='13%'>用户</th>");
        sb1.Append("<th width='5%'>数量</th>");
        sb1.Append("<th width='5%'>总款</th>");
        sb1.Append("<th width='10%' >支付方式</th>");
        sb1.Append("<th width='8%' >余付</th>");
        sb1.Append("<th width='10%' >在线支付货到付款</th>");
        sb1.Append("<th width='10%' >递送方式</th>");
        sb1.Append("<th width='10%'>操作</th>");
        sb1.Append("</tr>");
        url = url + "&page={0}";
        url = "Dingdan_Service.aspx?" + url.Substring(1);
        filter.State = "pay";
        filter.PageSize = 30;
        filter.AddSortOrder(OrderFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Orders.GetPager(filter);
        }
        list_order = pager.Objects;
        int i = 0;
        if (list_order != null && list_order.Count > 0)
        {
            foreach (IOrder order in list_order)
            {
                user = order.User;
                team = order.Team;
                if (i % 2 != 0)
                    sb2.Append("<tr>");
                else
                    sb2.Append("<tr class='alt'>");
                i++;
                sb2.Append("<td>" + order.Id + "</td>");
                sb2.Append("<td>");
                if (order.Team_id == 0)
                {
                    orderlist = order.OrderDetail;
                    foreach (IOrderDetail detail in orderlist)
                    {
                        sb2.Append("项目ID:" + detail.Team.Id + "(<a class='deal-title' href='" + getTeamPageUrl(detail.Team.Id) + "' target='_blank'>" + StringUtils.SubString(detail.Team.Title, 70) + "..." + "</a>)");
                        sb2.Append(StringUtils.SubString(AS.Common.Utils.WebUtils.Getbulletin(detail.result), 0, "<br>"));
                    }
                }
                else
                {
                    if (team != null)
                    {
                        sb2.Append("项目ID:" + order.Team_id + "(<a class='deal-title' href='" + getTeamPageUrl(team.Id) + "' target='_blank'>" + StringUtils.SubString(team.Title, 70) + "..." + "</a>)");
                    }
                    if (order.result != null)
                        sb2.Append(StringUtils.SubString(AS.Common.Utils.WebUtils.Getbulletin(order.result), 0, "<br>"));
                }
                if (order.Parent_orderid != null && order.Parent_orderid != 0)
                    sb2.Append("<font style='color:#0D6D00;font-weight:bold;'>该订单父ID:" + order.Parent_orderid + "</font>");
                sb2.Append("</td>");
                if (user != null)
                {
                    sb2.Append("<td><a class='ajaxlink' href='ajax_manage.aspx?action=userview&Id=" + order.User_id + "'>" + user.Email + "<br>" + user.Username + "</a>&nbsp;»&nbsp;<a class='ajaxlink' href='ajax_manage.aspx?action=sms&v=" + user.Mobile + "'>短信</a></td>");
                }
                else
                {
                    sb2.Append("<td>该用户已被删除</td>");
                }
                sb2.Append("<td>" + order.Quantity + "</td>");
                sb2.Append("<td>" + order.Origin + "</td>");
                sb2.Append("<td>" + WebUtils.GetPayText(order.State, order.Service) + "</td>");
                sb2.Append("<td>" + order.Credit + "</td>");
                sb2.Append("<td>" + (order.Service == "cashondelivery" ? order.cashondelivery.ToString("0.00") : order.Money.ToString("0.00")) + "</td>");
                sb2.Append("<td>" + GetOrderExpress(order) + "</td>");
                sb2.Append("<td class='op'><a class='ajaxlink' href='ajax_manage.aspx?action=orderview&orderview=" + order.Id + "'>详情</a></td>");
                sb2.Append("</tr>");
            }
            if (pager.TotalRecords >= 30)
            {
                pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
            }
        }
        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();

    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2><%=title %></h2><form id="Form" runat="server" method="get">
                                    <div class="search" style="margin-right：0px;">
                                        <ul>
                                          <input type="hidden" name="service" id="service"  <%if (!string.IsNullOrEmpty(Request.QueryString["service"]))
                                                  { %>value="<%=Request.QueryString["service"]%>"
                                                <%} %> />
                                            <input type="hidden" name="begintime" id="begintime"  <%if (!string.IsNullOrEmpty(Request.QueryString["begintime"]))
                                                  { %>value="<%=Request.QueryString["begintime"]%>"
                                                <%} %> />
                                            <input type="hidden" name="endtime" id="endtime"  <%if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
                                                  { %>value="<%=Request.QueryString["endtime"]%>"
                                                <%} %> />
                                             <input type="hidden" name="fromfinishtime" id="fromfinishtime"  <%if (!string.IsNullOrEmpty(Request.QueryString["fromfinishtime"]))
                                                  { %>value="<%=Request.QueryString["fromfinishtime"]%>"
                                                <%} %> />
                                             <input type="hidden" name="endfinishtime" id="endfinishtime"  <%if (!string.IsNullOrEmpty(Request.QueryString["endfinishtime"]))
                                                  { %>value="<%=Request.QueryString["endfinishtime"]%>"
                                                <%} %> />
                                            &nbsp;&nbsp; 用户名：<input class="h-input" type="text" style="width: 120px;" name="username" id="username"
                                                <%if (!string.IsNullOrEmpty(Request.QueryString["username"]))
                                                  { %>value="<%=Request.QueryString["username"]%>"
                                                <%} %> />&nbsp;&nbsp;
                                            用户Email：<input class="h-input" type="text" style="width: 120px;" name="email" id="email"
                                                <%if (!string.IsNullOrEmpty(Request.QueryString["email"]))
                                                  { %>value="<%=Request.QueryString["email"]%>"
                                                <%} %> />&nbsp;&nbsp;
                                            项目编号：<input class="h-input" type="text" style="width: 120px;" name="teamid" id="teamid"
                                                <%if (!string.IsNullOrEmpty(Request.QueryString["teamid"]))
                                                  { %>value="<%=Request.QueryString["teamid"]%>"
                                                <%} %> />&nbsp;&nbsp;
                                    <input type="submit" name="search" value="筛选" class="formbutton" style="padding: 1px 6px; width: 60px;" />
                                        </ul>
                                    </div>
                                </form>
                                </div>
                                
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="10">
                                                <%=pagerHtml%>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
<%LoadUserControl("_footer.ascx", null); %>
