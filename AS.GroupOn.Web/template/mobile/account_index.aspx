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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    IUser user = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.WapBodyID = "account";
        PageValue.Title = PageValue.CurrentSystem.abbreviation;
        MobileNeedLogin();
        if (IsLogin && AsUser.Id != 0)
        {
            user = AsUser;
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div class="body magic-card">
    <div class="common-list">
        <ul>
            <li>
                <span><strong><%=AsUser.Username %></strong></span><p><a href="<%=GetUrl("手机版修改密码","account_resetpwd.aspx") %>" >修改密码</a></p>    
            </li>
             <li class="link-block"><span>账户余额</span><p id="balance"><%=user.Money %></p></li>
            <li class="link-block"><a href="<%=GetUrl("手机版个人中心代金卷","account_card.aspx") %>">
                <label>代金券</label></a></li>
            <li class="link-block"><a href="<%=GetUrl("手机版个人中心订单","account_orders.aspx") %>">
                <label>我的订单</label></a></li>
        </ul>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>