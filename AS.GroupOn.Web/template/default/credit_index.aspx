<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>

<script runat="server">
    
    public NameValueCollection _system = new NameValueCollection();
    public IUser usermodel = null;
    public ISystem sysmodel = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected IPagers<IFlow> pager = null;
    protected IList<IFlow> flowlist = null;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Ordertype = "credit";
        //判断用户失效！
        NeedLogin();
        _system = WebUtils.GetSystem();
        int userid = AsUser.Id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            usermodel = session.Users.GetByID(userid);
        }
        GetUserfee();
    }

    #region 根据用户名查询用户的账户余额
    public void GetUserfee()
    {
        url = url + "&page={0}";
        url = GetUrl("账户余额", "credit_index.aspx?" + url.Substring(1));
        FlowFilter flowfilter = new FlowFilter();
        flowfilter.PageSize = 30;
        flowfilter.AddSortOrder(OrderFilter.Create_time_DESC);
        flowfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        flowfilter.User_id = AsUser.Id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Flow.GetPager(flowfilter);
        }
        flowlist = pager.Objects;

        if (flowlist.Count == 0)
        {
            pagerHtml = "对不起，没有相关数据";
        }
        else
        {
            pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        }
    }
    #endregion

    #region 根据项目编号，查询项目内容
    public string GetTeam(string id, string orderid)
    {
        string str = "";
        ITeam teamodel = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teamodel = session.Teams.GetByID(Convert.ToInt32(id));
        }
        if (teamodel != null)
        {
            str = "<a href='" + getTeamPageUrl(teamodel.Id) + "' target=_blank>" + teamodel.Title + "</a>";
        }
        else
        {
            IList<IOrderDetail> detaillist = null;
            OrderDetailFilter orderdetailfilter = new OrderDetailFilter();
            orderdetailfilter.Order_ID = Convert.ToInt32(orderid);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                detaillist = session.OrderDetail.GetList(orderdetailfilter);
            }
            int num = 0;
            foreach (IOrderDetail model in detaillist)
            {
                num++;
                str += "<a href='" + getTeamPageUrl(model.Teamid) + "' target=_blank>" + num + ":";
                str += model.Team == null ? "" : model.Team.Title;
                str += "</a><br>";
            }
        }
        return str;
    }
    #endregion

    #region  获取被邀请人的用户名
    public string Getname(string orderid)
    {
        string str = "";
        IOrder iorder = GetOrderid(orderid);
        if (iorder != null)
        {
            if (iorder.User != null)
            {
                str = iorder.User.Username;
            }
        }
        return str;
    }
    #endregion

    public IOrder GetOrderid(string orderid)
    {
        IOrder iorder = null;
        OrderFilter orderfilter = new OrderFilter();
        orderfilter.Pay_id = orderid;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iorder = session.Orders.Get(orderfilter);
        }
        return iorder;
    }
</script>

<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="credit">
            <div class="menu_tab" id="dashboard">
                <%LoadUserControl("_MyWebside.ascx", Ordertype); %>
            </div>
            <div id="tabsContent" class="coupons-box">
                <div class="box-content1 tab">
                    <div class="head">
                        <h2>账户余额</h2>
                        <%LoadUserControl(WebRoot + "UserControls/blockcredittip.ascx", null); %>
                    </div>
                    <div class="sect">
                        <p class="charge">
                            充值到
                            <%if (sysmodel != null)
                              { %>
                            <%=sysmodel.abbreviation%>账户，方便抢购！
                            <% }%>
                            <span>&raquo;</span> <a href="<%=GetUrl("支付方式","credit_charge.aspx")%>">立即充值</a>
                        </p>
                        <h3 class="credit-title">当前的账户余额是 <strong>
                            <%=ASSystem.currency %><%=usermodel.Money %></strong>
                            <%--，您的积分是<strong><%=usermodel.Userscore%></strong>，您现在是<strong><%=strleve %></strong>，购买<%=ASSystem.sitename %>所有商品均<strong><%=strlevemoney%></strong>折扣--%></h3>
                        <table id="order-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                            <tr>
                                <th width="120">时间
                                </th>
                                <th width="auto">详情
                                </th>
                                <th width="50">收支
                                </th>
                                <th width="70">金额
                                </th>
                            </tr>
                            <%int i = 0; %>
                            <%foreach (IFlow flowmodel in flowlist)
                              { %>
                            <tr <% if (i % 2 != 0)
                                   { %> class="alt" <%} %>>
                                <td style="text-align: left;">
                                    <%=flowmodel.Create_time %>
                                </td>
                                <td>
                                    <%if (flowmodel.Action == "coupon")
                                      { %>
                                    <%if (sysmodel != null)
                                      { %>
                                    <%=sysmodel.couponname%><% }

                                      }%>
                                    <% else if (flowmodel.Action == "invite")
                                      {%>
                                    返利好友-<%=Getname(flowmodel.Detail_id)%>
                                    <% }
                                      else if (flowmodel.Action == "buy")
                                      {%>
                                    <%
                                            IOrder iordermodel = GetOrderid(flowmodel.Detail_id);
                                            if (iordermodel != null)
                                            { %>
                                    <a href="<%=getTeamPageUrl(iordermodel.Team_id)  %>">购买-<%=GetTeam((iordermodel.Team_id.ToString()), (iordermodel.Id.ToString()))%></a>
                                    <% }
                                        else
                                        {%>购买-订单不存在
                                    <%} %>
                                    <% }%>
                                    <%  else if (flowmodel.Action == "charge")
                                      { %>
                                    充值-在线充值
                                    <%}
                                      else if (flowmodel.Action == "store")
                                      { %>
                                    充值—线下充值
                                    <%}
                                      else if (flowmodel.Action == "cash")
                                      { %>
                                    现金支付
                                    <%}
                                      else if (flowmodel.Action == "money")
                                      { %>
                                    红包
                                    <%}
                                      else if (flowmodel.Action == "Feeding_amount")
                                      { %>
                                    返余额
                                    <%}
                                      else if (flowmodel.Action == "refund")
                                      {%>
                                    管理员退款
                                    <% }
                                      else if (flowmodel.Action == "review")
                                      {%>
                                    评价返利
                                    <% }
                                      else if (flowmodel.Action == "withdraw")
                                      {%>
                                    提现
                                    <% }
                                      else if (flowmodel.Action == "sign")
                                      {%>
                                    签到
                                    <%} %>
                                </td>
                                <td>
                                    <%if (flowmodel.Direction == "income")
                                      { %>
                                    收入
                                    <%}
                                      else if (flowmodel.Direction == "expense")
                                      { %>
                                    支出
                                    <% }%>
                                </td>
                                <td>
                                    <%=ASSystem.currency %><%=flowmodel.Money %>
                                </td>
                            </tr>
                            <%
                                      i++;
                              }%>
                            <tr>
                                <td colspan="4">
                                    <%=pagerHtml%>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- bd end -->
</div>
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %>  