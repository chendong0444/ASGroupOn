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
    public ISystem systemmodel = null;
    public static object locker = new object(); //锁
    public string orderid = String.Empty;
    public string paytype = String.Empty;
    protected ITeam teammodel = null;
    protected IUser usermodel = null;
    protected IOrder ordermodel = null;
    public string Pid;//产品编号
    public string Amt;//支付金额
    public decimal paymoney;//支付金额
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        MobileNeedLogin();
        systemmodel = PageValue.CurrentSystem;
        lock (locker)
        {
            if (Request["orderid"] != null && Request["paytype"] != null)
            {
                //用户无法修改其他用户的额单子
                if (OrderMethod.IsUserOrder(AsUser.Id, Helper.GetInt(Request["orderid"], 0)))
                {
                    SetError("友情提示：无法操作其他用户的订单");
                    Response.Redirect(GetUrl("手机版首页", "index.aspx"));
                    Response.End();
                    return;
                }
                paymoney = Helper.GetDecimal(Request["paymoney"], 0);
                orderid = Helper.GetString(Request["orderid"], "0");
                paytype = Helper.GetString(Request["paytype"], String.Empty);
                using (IDataSession session = Store.OpenSession(false))
                {
                    ordermodel = session.Orders.GetByID(int.Parse(orderid));
                }
                if (ordermodel != null)
                {
                    teammodel = ordermodel.Team;
                    usermodel = ordermodel.User;
                    bool ok;
                    string msg = OrderMethod.SystemAllowPayOrder(int.Parse(orderid), AsUser.Id, out ok);
                    if (msg.Length > 0)
                    {
                        SetError(msg);
                        Response.Redirect(GetUrl("手机版首页", "index.aspx"));
                        Response.End();
                        return;
                    }
                    if (paytype != String.Empty && paytype == "credit")
                    {
                        //修改订单的支付网关,同时生成交易单号
                        OrderMethod.Updatebyservice(ordermodel.Id, PayType.credit.ToString(), OrderMethod.Getorder(ordermodel.User_id, ordermodel.Team_id, ordermodel.Id), ordermodel.Origin);
                        //使用余额支付处理 
                        if (OrderMethod.Isjudge(AsUser.Money, ordermodel.Origin))////判断用户账号金额是否大于订单金额
                        {
                            OrderMethod.Updateorder(ordermodel.Pay_id, "0", "credit", DateTime.Now);
                        }
                        else
                        {
                            SetError("您的余额不够支付该订单,请您重新选择");
                            Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["orderid"]);
                            Response.End();
                        }
                        Response.Redirect(GetUrl("手机版支付通知", "return_credit.aspx") + ordermodel.Pay_id);
                        Response.End();
                    }
                    else if (paytype != String.Empty)
                    {
                        if (teammodel != null)
                        {
                            Pid = "订单编号:" + orderid + "-" + teammodel.Product;//产品名称
                        }
                        else
                        {
                            Pid = ASSystem.abbreviation + "商品-" + "订单编号" + ordermodel.Id;
                        }
                        if (paymoney != 0)
                        {
                            Amt = paymoney.ToString();
                        }
                        else
                        {
                            if (usermodel != null)
                            {
                                Amt = (usermodel.Money - (usermodel.Money - ordermodel.Origin)).ToString();//支付金额
                            }
                            else
                            {
                                Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["orderid"]);
                            }
                        }  
                        //修改订单的支付网关,同时生成交易单号
                        OrderMethod.Updatebyservice(ordermodel.Id, PayType.credit.ToString(), OrderMethod.Getorder(ordermodel.User_id, ordermodel.Team_id, ordermodel.Id), ordermodel.Origin);
                    }
                }
            }
            else
            {
                Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["orderid"]);
            }
        }
    }
</script>
<html>
<head>
</head>
<body>
    <%if (ordermodel != null && ordermodel.State != "pay" && paytype != String.Empty && paytype != "credit")
      {%>
    <%if (paytype != String.Empty && paytype == "alipaywap")
      {%>
    <form id="form" action="<%=WebRoot %>pay/alipaywap/pay.aspx" method="post">
        <input type="hidden" name="out_trade_no" value='<%=ordermodel.Pay_id %>' />
        <input type="hidden" name="subject" value='<%=Pid %>' />
        <input type="hidden" name="total_fee" value='<%=Amt %>' />
    </form>
    <%}
      else if (paytype != String.Empty && paytype == "tenpaywap")
      {%>
    <form id="form" action="<%=WebRoot %>pay/tenpaywap/Reg.aspx" method="post">
        <input type="hidden" name="out_trade_no" value='<%=ordermodel.Pay_id %>' />
        <input type="hidden" name="subject" value='<%=Pid %>' />
        <input type="hidden" name="total_fee" value='<%=Amt %>' />
    </form>
    <%}%>
    <script>
        document.getElementById('form').submit();
    </script>
    <%}%>
</body>
</html>
