﻿<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

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
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Order_ListView))
        {
            SetError("你不具有查看订单列表的权限！");
            Response.Redirect("index_index.aspx");
            return;
        }
        int cashid = Helper.GetInt(Request["id"], 0);//当前订单
        if (cashid > 0)
        {
            string error = AS.AdminEvent.OrderEvent.Manager_Cash(cashid, AsUser.Id);
            if (error == String.Empty)
            {
                //订单付款成功提醒
                IOrder ordermodel = null;
                using (IDataSession session=Store.OpenSession(false))
                {
                    ordermodel = session.Orders.GetByID(cashid);
                }
                SetSuccess("掉单订单ID:" + cashid + "更改为已付款成功,其中余额付款" + ordermodel.Credit + "元,在线支付" + ordermodel.Money + "元");
            }
            else
                SetError(error);
            string gourl = Request.Url.AbsoluteUri;
            if (Request.UrlReferrer != null)
                gourl = Request.UrlReferrer.AbsoluteUri;
            Response.Redirect(gourl);
            Response.End();
            return;
        }
        id = Helper.GetInt(Request["delete"], 0);
        if (id > 0)
        {
            int adminid = Helper.GetInt(AsAdmin.Id, 0);
            AS.AdminEvent.OrderEvent.Del_Order(adminid, id, Request.UrlReferrer.ToString());

        }
        if (!string.IsNullOrEmpty(Request.QueryString["state"]))
        {
            url = url + "&state=" + Request.QueryString["state"];
            if (Request["state"] == "1")
            {
                filter.State = "unpay";
            }
            else if (Request["state"] == "2" ||Request["state"]=="4")
            {
                filter.State = "pay";
            }
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
                    u_filter.Username = type_name;
                else
                    u_filter.Email = type_name;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    uses = session.Users.Get(u_filter);
                }
                if (uses != null)
                    filter.User_id = uses.Id;
                else
                    return;
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
        url = "Dingdan_DangqiDingdan.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(OrderFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        if (!string.IsNullOrEmpty(Request["time"] ))
        {
            filter.ToCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["time"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
        }
        if (Request["state"] == "2")
        {
            filter.table = "(SELECT  orderdetail.Num, orderdetail.Teamid, orderdetail.Teamprice, Team.Title, Team_1.Title AS team_title, "
+ "[Order].*, [User].Email,[User].Username FROM Team RIGHT OUTER JOIN [Order] LEFT OUTER JOIN [User] ON"
 + "[Order].User_id = [User].Id ON Team.Id = [Order].Team_id LEFT OUTER JOIN Team AS Team_1 INNER JOIN orderdetail "
 + "ON Team_1.Id = orderdetail.Teamid ON [Order].Id = orderdetail.Order_id) ttt1";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pager = session.Orders.GetBranchPage(filter);
            }
        }
        else
        {
            filter.StateIn = "'pay','unpay','cancel','refunding','refund','nocod'";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pager = session.Orders.GetPager(filter);
            }
        }
        
        
       
        list_order = pager.Objects;
        int i = 0;
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
            sb2.Append("<td>" +(order.Service == "cashondelivery" ? order.cashondelivery.ToString("0.00") : order.Money.ToString("0.00"))+ "</td>");
            sb2.Append("<td>" + GetOrderExpress(order) + "</td>");
            if (order.State == "pay" || order.State == "scorepay")
            {
                sb2.Append("<td class='op'><a class='ajaxlink' href='ajax_manage.aspx?action=orderview&orderview=" + order.Id + "'>详情</a></td>");
            }
            else if (order.State == "cancel" || order.State == "nocod")
            {
                sb2.Append("<td class='op'><a class='deal-title'href='Dingdan_DangqiDingdan.aspx?delete=" + order.Id + "' ask='确定删除本单吗？'>删除</a>｜<a class='ajaxlink' href='ajax_manage.aspx?action=orderview&orderview=" + order.Id + "'>详情</a></td>");
            }
            else if (order.State == "unpay" || order.State == "scoreunpay")
            {
                sb2.Append("<td class='op'>");
                if (user != null)
                {
                    sb2.Append("<a class='deal-title' href='Dingdan_DangqiDingdan.aspx?id=" + order.Id + "' ask='确定本单为现金付款?'>现金</a>｜");
                }
                sb2.Append("<a class='deal-title' href='Dingdan_DangqiDingdan.aspx?delete=" + order.Id + "' ask='确定删除本单吗？'>删除</a>｜<a class='ajaxlink' href='ajax_manage.aspx?action=orderview&orderview=" + order.Id + "'>详情</a></td>");
            }
            else if (order.State == "refund" || order.State == "refunding")
            {
                sb2.Append("<td class='op'><a class='ajaxlink' href='ajax_manage.aspx?action=orderview&type=refunding&orderview=" + order.Id + "'>详情</a></td>");
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
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                <%if (Request["state"] == "2")
                                  {%>
                                      <h2>延时付款</h2>
                                  <%}
                                  else
                                  {%>
                                  <h2>所有订单</h2>
                                 <% }%>
                                    <form id="Form1" runat="server" method="get">
                                    <div class="search" style="margin-right：0px;">
                                        <ul>
                                           订单状态：<select name="state" class="h-input">
                                                <option value="">全部</option>
                                                <option value="1" <%
                                                    if (Request.QueryString["state"] == "1")
                                                    {
                                         %>selected="selected"
                                                    <%} %>>下单</option>
                                                <option value="2" <%if (Request.QueryString["state"] == "2")
                                                                    { %>selected="selected"
                                                    <%} %>>付款</option>
                                            </select>
                                            &nbsp;&nbsp; 生成订单时间：<input type="text" class="h-input" datatype="date" name="begintime" style="margin-right: 0px;"
                                                <%if (!string.IsNullOrEmpty(Request.QueryString["begintime"]))
                                                  { %>value="<%=Request.QueryString["begintime"] %>"
                                                <%} %> />--<input type="text" class="h-input" datatype="date" name="endtime" <%if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
                                                                                                                               { %>value="<%=Request.QueryString["endtime"] %>"
                                                    <%} %> />
                                            &nbsp;&nbsp; 完成订单时间：<input type="text" class="h-input" datatype="date" name="fromfinishtime" style="margin-right: 0px;"
                                                <%if (!string.IsNullOrEmpty(Request.QueryString["fromfinishtime"]))
                                                  { %>value="<%=Request.QueryString["fromfinishtime"] %>"
                                                <%} %> />--<input type="text" class="h-input" datatype="date" name="endfinishtime"
                                                    <%if (!string.IsNullOrEmpty(Request.QueryString["endfinishtime"]))
                                                      { %>value="<%=Request.QueryString["endfinishtime"] %>"
                                                    <%} %> />
                                              &nbsp;&nbsp; 筛选条件：<select id="select_type" name="select_type" class="h-input">
                                                <option value="">全部</option>
                                                <option value="1" <%if (Request.QueryString["select_type"] == "1")
                                                                    { %>selected="selected"
                                                    <%} %>>用户名</option>
                                                <option value="2" <%if (Request.QueryString["select_type"] == "2")
                                                                    { %>selected="selected"
                                                    <%} %>>Email</option>
                                                <option value="4" <%if (Request.QueryString["select_type"] == "4")
                                                                    { %>selected="selected"
                                                    <%} %>>订单编号</option>
                                                <option value="8" <%if (Request.QueryString["select_type"] == "8")
                                                                    { %>selected="selected"
                                                    <%} %>>项目ID</option>
                                                <option value="16" <%if (Request.QueryString["select_type"] == "16")
                                                                     { %>selected="selected"
                                                    <%} %>>交易单号</option>
                                                <option value="32" <%if (Request.QueryString["select_type"] == "32")
                                                                     { %>selected="selected"
                                                    <%} %>>快递单号</option>
                                                <option value="64" <%if (Request.QueryString["select_type"] == "64")
                                                                     { %>selected="selected"
                                                    <%} %>>手机号</option>
                                                <option value="128" <%if (Request.QueryString["select_type"] == "128")
                                                                      { %>selected="selected"
                                                    <%} %>>收货人</option>
                                                <option value="256" <%if (Request.QueryString["select_type"] == "256")
                                                                      { %>selected="selected"
                                                    <%} %>>派送地址</option>
                                            </select>
                                            &nbsp;&nbsp; 内容：<input class="h-input" type="text" style="width: 120px;" name="type_name" id="type_name"
                                                <%if (!string.IsNullOrEmpty(Request.QueryString["type_name"]))
                                                  { %>value="<%=Request.QueryString["type_name"]%>"
                                                <%} %> />&nbsp;&nbsp;
                                    <input type="submit" name="search" value="筛选" class="formbutton" style="padding: 1px 6px; width: 60px;" onClick="return checkvale();" />
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
<script type="text/javascript">
    function checkvale() {
        if ($("#select_type").val() != "") {
            if ($("#type_name").val() == "") {
                var selectIndex = document.getElementById("select_type").selectedIndex;
                var selectText = document.getElementById("select_type").options[selectIndex].text
                alert("请输入您要进行筛选的" + selectText);
                return false;
            }
        }
        else {
            $("#type_name").val("");
        }
    }
</script>
<%LoadUserControl("_footer.ascx", null); %>
