<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    private int menu = 1;

    public int Menu
    {
        get { return menu; }
        set { menu = value; }
    }

</script>
<li <%if(Menu==1){%>class="current" <%} %>><a href="<%=PageValue.WebRoot%>manage/Partner_OrderList.aspx">
    付款订单</a><span></span></li>
    <li <%if(Menu==4){%> class="current"<%} %>><a href="<%=PageValue.WebRoot%>manage/Partner_OrderList.aspx?key=4">退款订单</a><span></span></li>
<li <%if(Menu==2){%>class="current" <%} %>><a href="<%=PageValue.WebRoot%>manage/Partner_OrderList_WeiXuanZe.aspx">
    发货状态</a><span></span></li>
<li <%if(Menu==3){%>class="current" <%} %>><a href="<%=PageValue.WebRoot%>manage/OrderList_CashOnDelivery.aspx">
    发货状态(货到付款)</a><span></span></li>