<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<div class="clear"></div>
<div class="header_info">
<br><strong>什么是账户余额？</strong>
<br>
<p>账户余额是您在<%=ASSystemArr["sitename"] %>团购时可用于支付的金额。</p>
<br>
<strong>可以往账户里充值么？</strong>
<br>
<p>请到<a href="<%=GetUrl("账户余额", "credit_index.aspx")%>">账户余额</a>菜单，在线充值。</p>

<br>
<strong>那怎样才能有余额？</strong>
<br>
<p>邀请好友获得返利将充值到账户余额，参加团购亦可获得返利。</p>

</div>