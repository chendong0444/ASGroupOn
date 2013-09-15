<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
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
    public string style = "";
    private string _Select;
    public string Select
    {
        get { return _Select; }
        set { _Select = value; }
    }
    private NameValueCollection _system = new NameValueCollection();
    public IUser usermodel = null;
    public UserFilter userft = new UserFilter();
    protected string strlevel = "";
    public override void UpdateView()
    {
        Select = Params as string;
        _system = AS.Common.Utils.WebUtils.GetSystem();
        //是否开启买家评论
        if (AsUser.Id != 0)
        {
            usermodel = AsUser;
            strlevel = AS.GroupOn.Controls.Utilys.GetUserLevel(usermodel.totalamount);
        }
        switch (Select)
        {
            case "partner":
                this.partner.Attributes.Add("class", "active");
                break;
            case "packet":
                this.message.Attributes.Add("class", "active");
                break;
            case "coupon":
                this.coupon.Attributes.Add("class", "active");
                break;
            case "card":
                this.card.Attributes.Add("class", "active");
                break;
            case "buy":
                this.buy.Attributes.Add("class", "active");
                break;
            case "order":
                this.order.Attributes.Add("class", "active");
                break;
            //case "refer":
            //    this.account.Attributes.Add("class", "active");
            //    break;
            case "credit":
                this.credit.Attributes.Add("class", "active");
                break;
            case "settings":
                this.settings.Attributes.Add("class", "active");
                break;
            //case "jifen":
            //    this.score.Attributes.Add("class", "active");
            //    break;
            case "fapiao":
                this.fapiao.Attributes.Add("class", "active");
                break;
            case "draw":
                this.draw.Attributes.Add("class", "active");
                break;
            case "subscribe":
                this.subscribe.Attributes.Add("class", "active");
                break;
            default:
                this.order.Attributes.Add("class", "active");
                break;
        }
    }
</script>
<% if (usermodel != null)
   {%>
<div class="info">
    <%if (usermodel.Realname != "")
      { %>
    <h2>
        <%=usermodel.Realname%></h2>
    <%}
      else
      { %>
    <h2>
        <%=usermodel.Username %></h2>
    <%} %>
    <div class="notice1">
        (UID:
        <%=usermodel.Id %>)
    </div>
    <%if (ASSystem != null)
      { %>
    <div class="notice1">
        您好，欢迎光临<%=ASSystem.abbreviation%>！
    </div>
    <%}%>
    <div class="notice1">
        会员级别：<span><%=strlevel %></span>
    </div>
    <div class="notice1">
        您的余额：<span><%=ASSystem.currency %><%=usermodel.Money %></span>
    </div>
</div>
<%} %>
<div class="nav_sub" id="profile_orders">
    <h2>订单信息</h2>
    <ul class="navigationTabs">
        <li id="order" runat="server"><a href="<%=GetUrl("我的订单","order_index.aspx")%>">我的订单</a></li>
        <li id="coupon" runat="server"><a href="<%=GetUrl("我的优惠券", "coupon_coupon.aspx")%>">我的优惠券</a></li>

        <li id="subscribe" runat="server"><a href="<%=GetUrl("我的订阅","account_subscribe.aspx")%>">我的订阅</a></li>
    </ul>
</div>

<div class="nav_sub" id="profile_orders">
    <h2>活动与促销</h2>
    <ul class="navigationTabs">
        <li id="message" runat="server"><a href="<%=GetUrl("我的红包","order_packet.aspx")%>">我的红包</a></li>
        <li id="card" runat="server"><a href="<%=GetUrl("我的代金券","order_card.aspx")%>">我的代金券</a></li>
        <li id="draw" runat="server"><a href="<%=GetUrl("我的抽奖","order_draw.aspx")%>">我的抽奖</a></li>
        <%--<li id="account" runat="server"><a href="<%=GetUrl("我的邀请","account_refer.aspx")%>">我的邀请</a></li>
        <li id="score" runat="server"><a href="<%=GetUrl("我的积分","pointsshop_pointscore.aspx")%>">我的积分</a></li>--%>
    </ul>
</div>
<div class="nav_sub" id="profile_orders">
    <h2>我的评论</h2>
    <ul class="navigationTabs">
        <li id="partner" runat="server"><a href="<%=GetUrl("个人中心商户评论","buy_Send_list_partner.aspx")%>">商户评论</a></li>
        <li id="buy" runat="server"><a href="<%=GetUrl("个人中心产品评论","buy_Send_list_team.aspx")%>">产品评论</a></li>
    </ul>
</div>

<div class="nav_sub" id="profile_orders">
    <h2>账户信息</h2>
    <ul class="navigationTabs">
        <li id="credit" runat="server"><a href="<%=GetUrl("账户余额","credit_index.aspx")%>">账户余额</a></li>
        <li id="settings" runat="server"><a href="<%=GetUrl("账户设置","account_settings.aspx")%>">账户设置</a></li>
    </ul>
</div>

<div class="nav_sub" id="profile_orders">
    <h2>工具</h2>
    <ul class="navigationTabs">
        <li id="fapiao" runat="server"><a href="<%=GetUrl("发票查询","tools_fapiao.aspx")%>">发票查询</a></li>
    </ul>
</div>








