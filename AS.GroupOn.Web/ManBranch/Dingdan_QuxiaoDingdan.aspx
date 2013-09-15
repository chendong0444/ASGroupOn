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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected IPagers<IOrder> pager = null;
    protected IList<IOrder> list_order = null;
    protected OrderFilter filter = new OrderFilter();
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected int id = 0;
    protected string type_name = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        id = Helper.GetInt(Request["delete"], 0);
        if (id > 0)
        {
            int adminid = Helper.GetInt(AsAdmin.Id, 0);
            AS.AdminEvent.OrderEvent.Del_Order(adminid, id, Request.UrlReferrer.ToString());
        }
        if (!string.IsNullOrEmpty(Request.QueryString["begintime"]))
        {     
            url = url + "&begintime=" + Request.QueryString["begintime"];
            filter.FromCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["begintime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
        {
            url = url + "&endtime=" + Request["endtime"];
            filter.ToCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["fromfinishtime"]))
        {
            url = url + "&fromfinishtime=" + Request["fromfinishtime"];
            filter.FromPay_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["fromfinishtime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["endfinishtime"]))
        {
            url = url + "&endfinishtime=" + Request.QueryString["endfinishtime"];
            filter.ToPay_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endfinishtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["select_type"]))
        {
            IUser uses = null;
            UserFilter u_filter = new UserFilter();
            url = url + "&select_type=" + Request.QueryString["select_type"];
            type_name = Request.QueryString["type_name"];
            if (Request.QueryString["select_type"] == "1" || Request.QueryString["select_type"] == "2")
            {
                if (Request.QueryString["select_type"] == "1")
                {
                    u_filter.Username = type_name;
                }
                else
                {
                    u_filter.Email = type_name;
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    uses = session.Users.Get(u_filter);
                }
                if (uses != null)
                    filter.User_id = uses.Id;
            }
            else if (Request.QueryString["select_type"] == "4")
            {
                filter.Id = Helper.GetInt(type_name, 0);
            }
            else if (Request.QueryString["select_type"] == "8")
            {
                filter.Team_In = Helper.GetInt(type_name, 0);
            }
            else if (Request.QueryString["select_type"] == "16")
            {
                filter.Pay_id = Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "32")
            {
                filter.Express_no = Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "64")
            {
                filter.Mobile = Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "128")
            {
                filter.Realname = Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "256")
            {
                filter.Address = Helper.GetString(type_name, String.Empty);
            }
            url = url + "&type_name=" + Request.QueryString["type_name"];
        }
        InitData();
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
        url = "Dingdan_QuxiaoDingdan.aspx?" + url.Substring(1);
        filter.State = "cancel";
        filter.PageSize = 30;
        filter.AddSortOrder(OrderFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        filter.City_id = AsAdmin.City_id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Orders.GetPager(filter);
        }
        list_order = pager.Objects;
        int i = 0;
        foreach (IOrder order in list_order)
        {
            user = order.User;
            team = order.Team;
            if (i % 2 != 0)
            {
                sb2.Append("<tr>");
            }
            else
            {
                sb2.Append("<tr class='alt'>");
            }
            i++;
            sb2.Append("<td>" + order.Id + "</td>");
            sb2.Append("<td>");
            if (order.Team_id == 0)
            {
                teamlist = order.Teams;
                orderlist = order.OrderDetail;
                foreach (ITeam teams in teamlist)
                {
                    sb2.Append("项目ID:" + teams.Id + "(<a class='deal-title' href='" + getTeamPageUrl(teams.Id) + "' target='_blank'>" + StringUtils.SubString(teams.Title, 70) + "..." + "</a>)</br>");
                }
            }
            else
            {
                if (team == null)
                {
                    sb2.Append("项目ID:" + order.Team_id + "<a>项目已不存在!</a>");
                }
                else
                {
                    sb2.Append("项目ID:" + order.Team_id + "(<a class='deal-title' href='" + getTeamPageUrl(team.Id) + "' target='_blank'>" + StringUtils.SubString(team.Title, 70) + "..." + "</a>)");
                }
            }
            if (order.result != null)
                sb2.Append(StringUtils.SubString(AS.Common.Utils.WebUtils.Getbulletin(order.result), 0, "<br>"));
            if (order.Parent_orderid != null && order.Parent_orderid != 0)
                sb2.Append("<br><font style='color:#0D6D00;font-weight:bold;'>该订单父ID:" + order.Parent_orderid + "</font>");
            sb2.Append("</td>");
            if (user != null)
                sb2.Append("<td><a class='ajaxlink' href='ajax_manage.aspx?action=userview&Id=" + order.User_id + "'>" + user.Email + "<br>" + user.Username + "</a>&nbsp;»&nbsp;<a class='ajaxlink' href='ajax_manage.aspx?action=sms&v=" + user.Mobile + "'>短信</a></td>");
            else
            {
                sb2.Append("<td>该用户已被删除</td>");
            }
            sb2.Append("<td>" + order.Quantity + "</td>");
            sb2.Append("<td>" + order.Origin + "</td>");
            sb2.Append("<td>" + WebUtils.GetPayText(order.State, order.Service) + "</td>");
            sb2.Append("<td>" + order.Credit + "</td>");
            if (order.Service == "cashondelivery" && order.State == "pay")
            {
                sb2.Append("<td>" + order.cashondelivery + "</td>");
            }
            else
            {
                sb2.Append("<td>" + order.Money + "</td>");
            }
            sb2.Append("<td>" + GetOrderExpress(order) + "</td>");
            if (order.State == "cancel" || order.State == "nocod")
            {
                sb2.Append("<td class='op'><a class='deal-title'href='Dingdan_QuxiaoDingdan.aspx?delete=" + order.Id + "' ask='确定删除本单吗？'>删除</a>｜<a class='ajaxlink' href='ajax_manage.aspx?action=orderview&orderview=" + order.Id + "'>详情</a></td>");
            }
            sb2.Append("</tr>");
        }
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
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
    <input id="Hid_type" type="hidden" runat="server" />
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        取消订单</h2><form id="Form1" runat="server" method="get">
                                <div class="search">
                                   生成订单时间：<input type="text" class="h-input" datatype="date" name="begintime"
                                        <%if(!string.IsNullOrEmpty(Request.QueryString["begintime"])){ %>value="<%=Request.QueryString["begintime"] %>"
                                        <%} %> />--<input type="text" class="h-input" datatype="date" name="endtime" <%if(!string.IsNullOrEmpty(Request.QueryString["endtime"])){ %>value="<%=Request.QueryString["endtime"] %>"
                                            <%} %> />&nbsp;&nbsp; 完成订单时间：<input type="text" class="h-input" datatype="date" name="fromfinishtime"
                                                <%if(!string.IsNullOrEmpty(Request.QueryString["fromfinishtime"])){ %>value="<%=Request.QueryString["fromfinishtime"] %>"
                                                <%} %> />--<input type="text" class="h-input" datatype="date" name="endfinishtime"
                                                    <%if(!string.IsNullOrEmpty(Request.QueryString["endfinishtime"])){ %>value="<%=Request.QueryString["endfinishtime"] %>"
                                                    <%} %> />&nbsp;&nbsp; 筛选条件：<select name="select_type" class="h-input">
                                                        <option value="">全部</option>
                                                        <option value="1" <%if(Request.QueryString["select_type"] == "1"){ %>selected="selected"
                                                            <%} %>>用户名</option>
                                                        <option value="2" <%if(Request.QueryString["select_type"] == "2"){ %>selected="selected"
                                                            <%} %>>Email</option>
                                                        <option value="4" <%if(Request.QueryString["select_type"] == "4"){ %>selected="selected"
                                                            <%} %>>订单编号</option>
                                                        <option value="8" <%if(Request.QueryString["select_type"] == "8"){ %>selected="selected"
                                                            <%} %>>项目ID</option>
                                                        <option value="16" <%if(Request.QueryString["select_type"] == "16"){ %>selected="selected"
                                                            <%} %>>交易单号</option>
                                                        <option value="32" <%if(Request.QueryString["select_type"] == "32"){ %>selected="selected"
                                                            <%} %>>快递单号</option>
                                                        <option value="64" <%if(Request.QueryString["select_type"] == "64"){ %>selected="selected"
                                                            <%} %>>手机号</option>
                                                        <option value="128" <%if(Request.QueryString["select_type"] == "128"){ %>selected="selected"
                                                            <%} %>>收货人</option>
                                                        <option value="256" <%if(Request.QueryString["select_type"] == "256"){ %>selected="selected"
                                                            <%} %>>派送地址</option>
                                                    </select>&nbsp;&nbsp; 内容：<input class="h-input" type="text" style="width: 120px;"
                                                        name="type_name" <%if(!string.IsNullOrEmpty(Request.QueryString["type_name"])){ %>value="<%=Request.QueryString["type_name"] %>"
                                                        <%} %> />&nbsp;&nbsp;
                                    <input type="submit" name="search" value="筛选" class="formbutton" style="padding: 1px 6px;
                                        width: 60px;" /></div>
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
