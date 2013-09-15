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
    protected IList<IOrderDetail> list_orderde = null;
    protected IList<ITeam> list_team = null;
    protected ITeam team = null;
    protected OrderFilter filter = new OrderFilter();
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected StringBuilder sb1 = new StringBuilder();
    protected StringBuilder sb2 = new StringBuilder();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TJ_Order_Pay_Source))
        {
            SetError("你不具有查看付款订单来源统计的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
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
        sb1.Append("<tr >");
        sb1.Append("<th width='10%'>ID</th>");
        sb1.Append("<th width='30%'>项目名称</th>");
        sb1.Append("<th width='25%'>用户</th>");
        sb1.Append("<th width='25%'>来源地址</th>");
        sb1.Append("<th width='10%'>详情</th>");
        sb1.Append("</tr>");
        url = url + "&page={0}";
        url = "Tongji_Fukuan.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.State = "pay";
        filter.AddSortOrder(UserFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Orders.GetPager(filter);
        }
        list_order = pager.Objects;
        ITeam t = Store.CreateTeam();
        IUser user = Store.CreateUser();
        int i = 0;
        if (list_order != null)
        {
            foreach (var item in list_order)
            {
                t = item.Team;
                user = item.User;
                list_orderde = item.OrderDetail;
                list_team = item.Teams;
                if (i % 2 != 0)
                    sb2.Append("<tr>");
                else
                    sb2.Append("<tr class='alt'>");
                i++;
                sb2.Append("<td>" + item.Id + "</td>");
                if (t != null && t.Title.ToString() != "")
                    sb2.Append("<td><a class='deal-title' href='" + getTeamPageUrl(t.Id) + "' target='_blank'>" + t.Title + "</a></td>");
                else
                {
                    sb2.Append("<td>&nbsp;");
                    int num = 0;
                    if (list_orderde != null)
                    {
                        foreach (var od in list_team)
                        {
                            num++;
                            sb2.Append("(<a class='deal-title' href='" + getTeamPageUrl(od.Id) + "' target='_blank'>" + num + ":");
                            team = od;
                            sb2.Append(team == null ? "" : team.Title);
                            sb2.Append("</a>)<br>");
                        }
                    }
                    sb2.Append("</td>");
                }
                if (user != null && user.Username != "")
                {
                    sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 100px;'><a class='ajaxlink' href='ajax_manage.aspx?action=userview&Id=" + user.Id + "'>" + user.Username + "</a><br/>(" + user.Email + ")</div></td>");
                }
                else if (user != null && user.Email != "")
                {
                    sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 100px;'>" + user.Username + "<br/>(" + user.Email + ")</div></td>");
                }
                else
                {
                    sb2.Append("<td>&nbsp;</td>");
                }
                if (item.IP_Address != null)
                {
                    if (item.IP_Address.Trim() == "直接输入网址")
                        sb2.Append("<td style='color:red;'>" + item.IP_Address + "</td>");
                    else
                        sb2.Append("<td><a target='_blank' href='" + item.IP_Address + "' alt='" + item.IP_Address + "'>" + item.IP_Address + "</a></td>");
                }
                else
                    sb2.Append("<td>&nbsp;</td>");
                sb2.Append("<td class='op' nowrap><a href='ajax_manage.aspx?action=orderview&orderview=" + item.Id + "' class='ajaxlink'>详情</a></td>");
                sb2.Append("</tr>");
            }
        }
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        Literal2.Text = sb2.ToString();
        Literal1.Text = sb1.ToString();
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <div>
    </div>
    <div>
    </div>
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div class="dashboard" id="dashboard">
                    </div>
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        付款订单来源统计</h2>
                                    <form runat="server" method="get">
                                    <div class="lie_fl">
                                        筛选条件：付款日期：<input type="text" class="h-input" datatype="date" name="begintime" style="margin-right: 0px;"
                                            <%if(!string.IsNullOrEmpty(Request.QueryString["begintime"])){ %>value="<%=Request.QueryString["begintime"] %>"
                                            <%} %> />--<input type="text" class="h-input" datatype="date" name="endtime" <%if(!string.IsNullOrEmpty(Request.QueryString["endtime"])){ %>value="<%=Request.QueryString["endtime"] %>"
                                                <%} %> />&nbsp;<input type="submit" name="search" value="统计" class="formbutton" group="go"
                                                    style="padding: 1px 6px; width: 60px;" />
                                    </div>
                                    </form>
                                    <div class="lie_fl">
                                    </div>
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
</body>
<%LoadUserControl("_footer.ascx", null); %>
