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
        PageValue.WapBodyID = "help";
        PageValue.Title = "帮助";
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<body id='help' >
    <header>
            <div class="left-box">
                <a class="go-back" href="<%=GetUrl("手机版首页","index.aspx")%>"><span>首页</span></a>
            </div>
        <h1>帮助</h1>
    </header>
<div class="body">
    <h2>手机上如何支付?</h2>
    <p>您可以通过支付宝的方式完成购买，确保交易安全。</p>
    <p>后续将开通财富通、网上银行的方式以方便购买。</p>
    <h2>什么情况下可退款?</h2>
    <p>您好，以下情况可以退款：</p>
    <ol>
        <li>团购结束时没有凑够团购人数，<%=PageValue.CurrentSystem.sitename%>网将立即为您全额原路退回。</li>
        <li>团购成功后，商家因意外原因临时出现停业或搬家的情况，我们会在第一时间将您当时支付的款项退还给您。</li>
        <li>团购成功后，对于支持“过期退”的项目，有效期内未消费，无条件退款。</li>
    </ol>
    <p>如对产品功能有建议或意见，欢迎<a href="<%=GetUrl("手机版反馈意见","help_feedback.aspx") %>">反馈给我们</a></p>
    <h2>客服电话：<a href="<%=PageValue.CurrentSystem.tuanphone %>"><%=PageValue.CurrentSystem.tuanphone %></a></h2>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>