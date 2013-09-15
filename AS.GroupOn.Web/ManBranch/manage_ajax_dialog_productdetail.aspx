<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">

    protected ProductFilter proft = new ProductFilter();
    protected IProduct promodel = null;
    protected PartnerFilter parft = new PartnerFilter();
    protected IPartner parmodel = null;
    protected OrderFilter orderfilter = new OrderFilter();
    protected OrderDetailFilter orderdetailfilter = new OrderDetailFilter();
    protected IList<IOrderDetail> orderdetaillist = null;
    protected IList<IOrder> orderlist = null;
    protected int buycount = 0;
    protected int paycount = 0;
    protected decimal teamprice = 0; //项目收支
    protected decimal cardpay = 0;
    protected int nownumber = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Team_Detail))
        {
            Response.Clear();
            Response.Write("没有权限访问");
            Response.End();
            return;
        }
        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            int productid = int.Parse(Request["id"].ToString());
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                promodel = session.Product.GetByID(int.Parse(Request["id"].ToString()));
            }
            if (promodel != null)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    parmodel = session.Partners.GetByID(promodel.partnerid);
                }
                TeamFilter teamft = new TeamFilter();               
                IList<ITeam> teamlist = null;
                teamft.productid = productid;

                TeamFilter teamb = new TeamFilter();

                using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teamlist = session.Teams.GetList(teamft);                    
                }
                foreach (ITeam teamm in teamlist)
                {
                    orderdetailfilter.TeamidOrder = teamm.Id;
                    orderfilter.State = "pay";
                    orderfilter.Team_id = teamm.Id;
                    using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        orderdetaillist = session.OrderDetail.GetList(orderdetailfilter);
                        orderlist = session.Orders.GetList(orderfilter);
                    }
                    foreach (var item in orderdetaillist)
                    {
                        buycount += item.Num;
                        teamprice += item.Num * item.Teamprice;
                        cardpay += item.Num * item.Credit;
                    }
                    foreach (var item in orderlist)
                    {
                        buycount += item.Quantity;
                        teamprice += item.Quantity * item.Price;
                        cardpay += item.Quantity * item.Card;
                    }
                    paycount = orderdetaillist.Count + orderlist.Count;
                }
            }
        }

    }
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 510px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>产品详情</h3>
    <div style="overflow-x: hidden; padding: 10px;">
        <table width="96%" align="center" class="coupons-table-xq">
            <%if (promodel != null)
              { %>
            <tr>
                <td width="80">
                    <b>产品名称：</b>
                </td>
                <td>
                    <b>
                        <%=promodel.productname%></b>
                </td>
            </tr>
            <%if (parmodel != null)
              { %>
            <tr>
                <td width="80">
                    <b>商户名称：</b>
                </td>
                <td>
                    <b>
                        <%=parmodel.Title%></b>
                </td>
            </tr>
            <%} %>
            <tr>
                <td>
                    <b>添加时间：</b>
                </td>
                <td>
                    <b>
                        <%=promodel.createtime%></b>
                </td>
            </tr>
            <tr>
                <td>
                    <b>当前状态：</b>
                </td>
                <td>
                    <span style="color: #F00; font-weight: bold;">
                        <% if (promodel.status == 1)
                           {%>上架<% }
                           else if (promodel.status == 2)
                           {%>被拒绝<% }
                           else if (promodel.status == 4)
                           { %>
                        待审核<%}
                           else if (promodel.status == 8)
                           {%>
                        下架<% }%></span>
                </td>
            </tr>
            <tr>
                <td>
                    <b>产品库存：</b>
                </td>
                <td>
                    <%=promodel.inventory%>
                </td>
            </tr>
            <tr>
                <td>
                    <b>成本价格：</b>
                </td>
                <td>
                    <%=promodel.price%>&nbsp;元
                </td>
            </tr>
            <tr>
                <td>
                    <b>团购价格：</b>
                </td>
                <td>
                    <%=promodel.team_price%>&nbsp;元
                </td>
            </tr>
            <tr>
                <td>
                    <th colspan="2">
                        <hr />
                    </th>
                </td>
            </tr>
            <tr>
                <td>
                    <b>成交情况：</b>
                </td>
                <td>
                    <b>
                        <%=nownumber%></b>&nbsp;，实际共&nbsp;<b><%=paycount%></b>&nbsp;人购买了&nbsp;<b><%=buycount%></b>&nbsp;份
                </td>
            </tr>
            <tr>
                <td>
                    <b>项目收支：</b>
                </td>
                <td>
                    支付总额：<b><%=teamprice%></b>&nbsp;元&nbsp;&nbsp;&nbsp;&nbsp;代金券抵用：<b><%=cardpay%></b>&nbsp;元
                </td>
            </tr>
            <%} %>
        </table>
    </div>
</div>
