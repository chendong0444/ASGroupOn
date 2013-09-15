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
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.WapBodyID = "about-magiccard";
        PageValue.Title = "如何获取代金券";
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<header>
    <div class="left-box">
        <a class="go-back" href="<%=GetUrl("手机版首页","index.aspx") %>"><span>首页</span></a>
    </div>
    <h1>如何获取代金券</h1>
</header>
<div class="body" id="about-card">
    <div class="section">
        <p class="title">什么是代金券？</p>
        <p>代金券是<%=PageValue.CurrentSystem.sitename%>发行和认可的购物券，可以在<%=PageValue.CurrentSystem.sitename%>消费付款时抵扣相应面值的金额</p>
    </div>
    <div class="section">
        <p class="title">如何使用代金券？</p>
        <p>在网站和手机端付款时，都可以选择使用代金券，输入代金券券号和密码验证通过后，抵扣相应的金额</p>
    </div>
    <div class="section">
        <p class="title">代金券找零兑现吗？</p>
        <p>代金券不找零，不兑现。付款时代金券会被优先使用，不足支付时才会使用<%=PageValue.CurrentSystem.sitename%>余额</p>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>