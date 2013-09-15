<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
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
     protected string couponname = String.Empty;
     public override void UpdateView()
     {
         if (ASSystem != null)
         {
             couponname = ASSystem.couponname;
         }
     }
</script>
<div class="clear">
</div>
<div class="header_info">
    <br/>
    <strong>我已支付成功，为什么没有<%=couponname%>？</strong>
    <br/>
    <p>
        因为还没有到达最低团购人数，一旦凑够人数，您就会看到<%=couponname %>了。</p>
    <br/>
    <strong>什么是已过期订单？</strong>
    <br/>
    <p>
        如果某个订单未及时付款，那么等团购结束时就无法再付款了，这种订单就是过期订单。</p>
    <br/>
    <strong>什么是确认收货？</strong>
    <br/>
    <p>如果您某个订单已付款，用户登录支付宝或者财付通。确认收货。</p>
</div>
