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
    public IOrder ordermodel = null;
    public IUser usermodel = null;
    public string payid = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "支付订单";
        MobileNeedLogin();
        payid = Helper.GetString(Request["id"], String.Empty);
        if (payid != String.Empty)
        {
            IPay paymodel = null;
            using (IDataSession session = Store.OpenSession(false))
            {
                paymodel = session.Pay.GetByID(payid);
            }
            if (paymodel != null)
            {
                if (paymodel.Order_id > 0)
                {
                    //传递订单号
                    Getorder(paymodel.Id.ToString());
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        ordermodel = session.Orders.GetByID(Helper.GetInt(paymodel.Order_id, 0));
                    }
                    if (ordermodel != null)
                    {
                        usermodel = ordermodel.User;
                    }
                    if (ordermodel.State == "scorepay" && !string.IsNullOrEmpty(CookieUtils.GetCookieValue("invitor")) && string.IsNullOrEmpty(CookieUtils.GetCookieValue("invitorNum")))
                    {
                        int uid = Helper.GetInt(CookieUtils.GetCookieValue("invitor"), 0);
                        if (usermodel != null)
                        {
                            int invitescore = Helper.GetInt(PageValue.CurrentSystemConfig["invitescore"], 0);
                            OrderMethod.UpdateScore(usermodel.Id, usermodel.userscore, invitescore);
                            //设置只能一次返积分，再次购买则不会返积分。
                            CookieUtils.SetCookie("invitorNum", "1");
                        }
                    }
                }
            }
            else
            {
                OrderFilter of = new OrderFilter();
                of.Pay_id = payid;
                IList<IOrder> list = null;
                using (IDataSession session = Store.OpenSession(false))
                {
                    list = session.Orders.GetList(of);
                }
                if (list != null && list.Count > 0)
                {
                    ordermodel = list[0];
                }
            }
        }
    }
    //获取订单编号
    public void Getorder(string orderid)
    {
        OrderFilter of = new OrderFilter();
        IList<IOrder> list = null;
        of.Pay_id = orderid;
        using (IDataSession session = Store.OpenSession(false))
        {
            list = session.Orders.GetList(of);
        }
        if (list != null && list.Count > 0)
        {
            ordermodel = list[0];
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<body id='order-return'>
    <header>
        <div class="left-box">
            <a class="go-back" href="<%=GetUrl("手机版首页","index.aspx") %>"><span>首页</span></a>
        </div>
        <h1>支付订单</h1>
    </header>
    <article class="body common-form" id="buy">
        <%if (ordermodel != null && ordermodel.State == "pay")
          {%>
        <h2>✔ 恭喜您，购买成功！</h2>
        <%}
          else
          {%>
        <h2>✖ 对不起，购买失败！</h2>
        <%}%>
        <section class="common-items">
            <div class="common-item">
                <span class="item-label">订单编号：</span>
                <div class="item-content"><%=ordermodel.Id %></div>
            </div>
            <div class="common-item">
                <span class="item-label">团购项目：</span>
                <div class="item-content"><%=ordermodel.teamid!=0?ordermodel.Team.Product:ordermodel.OrderDetail[0].Team.Product %></div>
            </div>
            <div class="common-item">
                <span class="item-label">订单状态：</span>
                <%if (ordermodel != null && ordermodel.State == "pay")
                  {%>
                <div class="item-content">交易成功</div>
                <%}
                  else
                  {%>
                <div class="item-content">交易失败</div>
                <%}%>
            </div>
        </section>
    </article>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
