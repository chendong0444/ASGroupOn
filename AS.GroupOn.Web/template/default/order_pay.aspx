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
    protected IOrder ordermodel = null;
    public string service;//支付网关
    public string money;//应付的金额
    public string orderid;//订单号
    public string Amt;//支付金额
    public string Pid;//产品编号
    public string pcat;//产品种类
    public string Pdesc;//产品描述
    public string pd_FrpId;//易宝银行编号
    public string cft_FrpId;//财付通银行编号
    public string orderId;//数量
    public NameValueCollection _system = new NameValueCollection();
    public ISystem systemmodel = null;
    public static object locker = new object(); //锁
    public string pordermsg = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NeedLogin();
        _system = PageValue.CurrentSystemConfig;
        systemmodel = PageValue.CurrentSystem;
        lock (locker)
        {
            if (Request["orderid"] != null)
            {
                //判断当前订单是否已经付款了，是否有已经卖光的或者过期的项目则阻止付款
                decimal paymoney = Helper.GetDecimal(Request["p"], 0);
                int temporderid = Helper.GetInt(Request["orderid"], 0);
                bool ok;
                string msg = OrderMethod.SystemAllowPayOrder(temporderid, AsUser.Id, out ok);
                if (!ok)
                {
                    SetError(msg);
                    Response.Redirect(WebRoot + "index.aspx");
                    Response.End();
                    return;
                }
                //判断此订单是否参加了抽奖，如果已经抽奖了，则阻止进行抽奖活动
                if (DrawMethod.isDraw(Helper.GetInt(Request["orderid"], 0)))
                {
                    SetError("友情提示:此订单已经抽奖，无法再次进行抽奖");
                    Response.Redirect(WWWprefix);
                    Response.End();
                    return;
                }
                GetMoney(Request["orderid"].ToString(), paymoney);
                orderid = Request["orderid"].ToString();//获取交易单号
                IOrder modemodel = null;
                using (IDataSession session = Store.OpenSession(false))
                {
                    modemodel = session.Orders.GetByID(int.Parse(orderid));
                }
                if (ordermodel != null)
                {
                    pordermsg = ordermodel.Pay_id + "|" + systemmodel.paypalmid + "|" + Amt;//传给回调地址
                }
            }
            else
            {
                Response.Redirect(GetUrl("我的订单", "order_index.aspx"));
            }
            if (Request["pd_FrpId"] != null)
            {
                pd_FrpId = Request["pd_FrpId"].ToString();
            }
            if (Request["cft_FrpId"] != null)
            {
                cft_FrpId = Request["cft_FrpId"].ToString();
            }
            if (Request.Form["pay"] == "使用账户余额支付")
            {
                //使用余额支付处理 
                if (OrderMethod.Isjudge(AsUser.Money, ordermodel.Origin))////判断用户账号金额是否大于订单金额
                {
                    OrderMethod.Updateorder(ordermodel.Pay_id, "0", "credit", DateTime.Now);
                }
                Response.Redirect(GetUrl("支付通知", "order_success.aspx?id=" + ordermodel.Pay_id));
                Response.End();
            }
        }
    }
    public void GetMoney(string orderid,decimal m)
    {
        ITeam teammodel = null;
        IUser usermodel = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            ordermodel = session.Orders.GetByID(Helper.GetInt(orderid, 0));
        }
        if (ordermodel != null)
        {
            teammodel = ordermodel.Team;
            usermodel = ordermodel.User;
        }
        service = ordermodel.Service;
        if (m > 0)
        {
            if (m > ordermodel.Origin || m > usermodel.Money || m == ordermodel.Origin)
            {
                if (m > ordermodel.Origin)
                {
                    SetError("友情提示：您输入的金额超出订单金额,请您重新输入");
                }
                if (m > usermodel.Money)
                {
                    SetError("友情提示：您输入的金额超出您的帐户余额,请您重新输入");
                }
                if (m == ordermodel.Origin)
                {
                    SetError("友情提示：您输入的金额不正确,请您重新选择");
                }
                Response.Redirect(GetPayPageUrl(Request["orderid"]));
                Response.End();
            }
            else
            {
                money = (ordermodel.Origin - m).ToString();
                Amt = (ordermodel.Origin - m).ToString(); //支付金额  
            }
        }
        else
        {
            money = (usermodel.Money - (usermodel.Money - ordermodel.Origin)).ToString();
            Amt = (usermodel.Money - (usermodel.Money - ordermodel.Origin)).ToString();//支付金额
        }
        if (teammodel != null)
        {
            Pid = "订单编号:" + orderid + "-" + teammodel.Product;//产品名称
            pcat = teammodel.Team_type;//产品种类
            Pdesc = teammodel.Detail;//产品描述
        }
        else
        {
            Pid = ASSystem.abbreviation + "商品-" + "订单编号" + ordermodel.Id;
        }
        orderId = ordermodel.Quantity.ToString();
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="order-pay">
            <div id="content">
                <div id="deal-buy" class="box">
                    <div class="box-content">
                        <div class="head">
                            <h2>应付总额：<strong class="total-money"><%=ASSystem.currency%><%=money%></strong>
                            </h2>
                        </div>
                        <div class="sect">
                            <div style="text-align: left;">
                                <%
                                    if (service == "credit")
                                    { %>
                                <form id="form1" action="" method="post" target="_blank" onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                    <input type="hidden" name="service" value="credit" />
                                    <input type="submit" name="pay" class="formbutton gotopay" value="使用账户余额支付" />
                                </form>
                                <%}
                                    else if (service == "tenpay"&&cft_FrpId != "" && _system["iscftbank"] != null && _system["iscftbank"].ToString() != "" && _system["iscftbank"].ToString() == "1")
                                    { %>
                                <form id="form2" target="_blank" method="post" action="<%=WebRoot %>pay/tenpay/Reg.aspx?bank_type=<%=cft_FrpId%>" onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                    <input type="hidden" name="body" value='' />
                                    <input type="hidden" name="out_trade_no" value='<%=ordermodel.Pay_id %>' />
                                    <input type="hidden" name="partner" value="" />
                                    <input type="hidden" name="payment_type" value="1" />
                                    <input type="hidden" name="return_url" value="" />
                                    <input type="hidden" name="service" value="tenpay" />
                                    <input type="hidden" name="subject" value='<%=Pid %>' />
                                    <input type="hidden" name="total_fee" value='<%=Amt %>' />
                                    <input type="hidden" name="sign_type" value="MD5" />
                                    <input type="submit" class="formbutton gotopay" value="前往财付通银行通付款" />
                                </form>
                                <%}
                                    else if (service == "tenpay")
                                    { %>
                                <form id="form11" target="_blank" method="post" action="<%=WebRoot %>pay/tenpay/Reg.aspx" onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                    <input type="hidden" name="body" value='' />
                                    <input type="hidden" name="out_trade_no" value='<%=ordermodel.Pay_id %>' />
                                    <input type="hidden" name="partner" value="" />
                                    <input type="hidden" name="payment_type" value="1" />
                                    <input type="hidden" name="return_url" value="" />
                                    <input type="hidden" name="service" value="tenpay" />
                                    <input type="hidden" name="subject" value='<%=Pid %>' />
                                    <input type="hidden" name="total_fee" value='<%=Amt %>' />
                                    <input type="hidden" name="sign_type" value="MD5" />
                                    <img src="<%=ImagePath()%>tenpay.jpg" /><br />
                                    <input type="submit" class="formbutton gotopay" value="前往财付通付款" />
                                </form>
                                <%}
                                    else if (service == "paypal")
                                    { %>
                                <form id="form10" target="_blank" method="post" action="https://www.paypal.com/cgi-bin/webscr" onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                    <input type="hidden" name="item_number" value='<%=pordermsg%>' />
                                    <input type="hidden" name="cmd" value="_xclick" />
                                    <input type="hidden" name="business" value='<%=systemmodel.paypalmid%>' />
                                    <input type="hidden" name="item_name" value='<%=Pid%>' />
                                    <input type="hidden" name="amount" value="<%=Amt%>" />
                                    <input type="hidden" name="currency_code" value="CNY" />
                                    <input type="hidden" name="charset" value="utf-8" />
                                    <input type="hidden" name="notify_url" value="<%=WebRoot%>pay/paypal/reg.aspx">
                                    <input type="hidden" name="return" value="<%=GetUrl("支付通知", "order_success.aspx?paypalid="+ordermodel.Pay_id) %>" />
                                    <img src="<%=(ImagePath()+"paypal.gif") %>" /><br />
                                    <input type="submit" class="formbutton gotopay" value="前往贝宝支付" />
                                </form>
                                <%}
                                    else if (service == "alipay")
                                    { %>
                                <%if (_system["Isalipaylogin"] == "1")
                                  {%>
                                <form id="form3" method="post" action="<%=WebRoot %>pay/alipayQuick/pay.aspx" target="_blank" onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                    <%}
                                  else
                                  { %>
                                    <form id="form5" method="post" action="<%=WebRoot %>pay/alipay/pay.aspx" target="_blank" onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                        <%} %>
                                        <input type="hidden" name="body" value='' />
                                        <input type="hidden" name="out_trade_no" value='<%=ordermodel.Pay_id %>' />
                                        <input type="hidden" name="partner" value="" />
                                        <input type="hidden" name="payment_type" value="1" />
                                        <input type="hidden" name="return_url" value="" />
                                        <input type="hidden" name="service" value="alipay" />
                                        <input type="hidden" name="subject" value='<%=Pid %>' />
                                        <input type="hidden" name="total_fee" value='<%=Amt %>' />
                                        <input type="hidden" name="sign_type" value="MD5" />
                                        <img src="<%=ImagePath()%>alipay.png" /><br />
                                        <input type="submit" class="formbutton gotopay" value="前往支付宝支付" />
                                    </form>
                                    <%}
                                    else if (service == "yeepay" && pd_FrpId != "yeepay")
                                    { %>
                                    <form id="form4" method="post" action="<%=WebRoot %>pay/yeepay/Req.aspx" target="_blank" onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                        <input type='hidden' name='p2_Order' value='<%=ordermodel.Pay_id %>'>
                                        <input type='hidden' name='p3_Amt' value='<%=Amt %>'>
                                        <input type='hidden' name='p4_Cur' value='CNY'>
                                        <input type='hidden' name='p5_Pid' value='<%=Pid %>'>
                                        <input type='hidden' name='p6_Pcat' value='<%=pcat %>'>
                                        <input type='hidden' name='p7_Pdesc' value='<%=Pid %>'>
                                        <input type='hidden' name='p8_Url' value=''>
                                        <input type='hidden' name='p9_SAF' value='0'>
                                        <input type='hidden' name='pa_MP' value=''>
                                        <input type='hidden' name='pd_FrpId' value='<%=pd_FrpId %>'>
                                        <input type='hidden' name='pr_NeedResponse' value='1'>
                                        <%if (pd_FrpId == "yeepay")
                                          { %>
                                        <img src="<%=ImagePath()%>yeepay.gif" />
                                        <br />
                                        <input type="submit" class="formbutton gotopay " value="前往易宝支付" />
                                        <%}
                                          else
                                          { %>
                                        <img src="<%=ImagePath()%><%= pd_FrpId%>.gif" />
                                        <br />
                                        <input type="submit" class="formbutton gotopay " value="前往银行支付" />
                                        <%}%>
                                        <%}
                                    else if (service == "bill")
                                    { %>
                                        <img src="<%=ImagePath()%>99bill.png" /><br />
                                        <input type="submit" class="formbutton gotopay" value="前往快钱支付" />
                                        <%}
                                    else if (service == "paypal")
                                    { %>
                                        <img src="<%=ImagePath()%>paypal.png" /><br />
                                        <input type="submit" class="formbutton gotopay" value="Go to PayPal" style="vertical-align: middle;" />
                                        <%}
                                    else if (service == "allinpay")
                                    { %>
                                        <form id="allinpay" method="post" action="<%=WebRoot %>pay/allinpay/post.aspx" target="_blank" onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                            <input type="hidden" name="orderNo" value='<%=ordermodel.Pay_id %>' />
                                            <input type="hidden" name="orderPid" value='<%=Pid %>' />
                                            <input type="hidden" name="orderAmount" value='<%=Amt %>' />
                                            <input type="hidden" name="orderId" value='<%=orderId %>' />
                                            <img src="<%=ImagePath()%>tlzf.jpg" /><br />
                                            <input type="submit" class="formbutton allinpay" value="前往通联支付" />
                                        </form>
                                        <%}
                                    else if (service == "chinabank")
                                    { %>
                                        <form id="form7" method="post" action="<%=WebRoot %>pay/chinabank/Send.aspx" target="_blank" onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                            <input type="hidden" name="body" value='' />
                                            <input type="hidden" name="out_trade_no" value='<%=ordermodel.Pay_id %>' />
                                            <input type="hidden" name="partner" value="" />
                                            <input type="hidden" name="payment_type" value="1" />
                                            <input type="hidden" name="return_url" value="" />
                                            <input type="hidden" name="service" value="chinabank" />
                                            <input type="hidden" name="subject" value='<%=Pid %>' />
                                            <input type="hidden" name="total_fee" value='<%=Amt %>' />
                                            <input type="hidden" name="sign_type" value="MD5" />
                                            <img src="<%=ImagePath()%>chinabank.png" /><br />
                                            <input type="submit" class="formbutton gotopay" value="前往网银在线支付" style="vertical-align: middle;" />
                                            <% }%>
                                            <%else if (service == "cashondelivery")
                                    { %>
                                            <form id="cashondelivery" method="post" action="<%=WebRoot %>pay/cashondelivery/pay.aspx" target="_blank"
                                                onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                                <input type="hidden" name="cashNo" value='<%=ordermodel.Pay_id %>' />
                                                <input type="hidden" name="cashAmount" value='<%=Amt %>' />
                                                <input type="hidden" name="cashId" value='<%=orderid %>' />
                                                <input type="submit" class="formbutton gotopay" value="货到付款" style="vertical-align: middle;" />
                                            </form>
                                            <% } %>
                                            <%if (_system != null)
                                              {
                                                  if (service == "chinamobilepay")
                                                  {
                                            %>
                                            <form id="form6" method="post" action="<%=WebRoot %>pay/mobile/webPay.aspx" target="_blank" onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                                <input type="hidden" name="out_trade_no" value='<%=ordermodel.Pay_id %>' />
                                                <input type="hidden" name="payment_type" value="1" />
                                                <input type="hidden" name="subject" value='<%=Pid %>' />
                                                <input type="hidden" name="total_fee" value='<%=Amt %>' />
                                                <img src="<%=ImagePath()%>chinamobile.jpg" /><br />
                                                <input type="submit" class="formbutton gotopay" value="前往手机移动支付" />
                                            </form>
                                            <% }
                                              }%>
                                            <div class="back-to-check">
                                                <a href="<%=GetUrl("优惠卷确认","order_check.aspx?orderid="+Request["orderid"])%>">&raquo; 返回选择其他支付方式</a>
                                            </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- bd end -->
</div>
<!-- bdw end -->
<div id="showpaydialog" style="display: none;">
    <div style="width: 380px;" class="order-pay-dialog-c" id="order-pay-dialog">
        <h3>
            <span onclick="return X.boxClose();" class="close" id="order-pay-dialog-close">关闭</span></h3>
        <p class="info">
            请您在新打开的页面上完成付款。
        </p>
        <p class="notice">
            付款完成前请不要关闭此窗口。<br />
            完成付款后请根据您的情况点击下面的按钮：
        </p>
        <p class="act">
            <input type="submit" onclick="location.href='<%=GetUrl("支付通知", "order_success.aspx?id="+ordermodel.Pay_id) %>';" value="已完成付款" class="formbutton" id="order-pay-dialog-succ">&nbsp;&nbsp;&nbsp;<input
                    type="submit" onclick="return X.boxClose();" value="付款 遇到问题" class="formbutton"
                    id="order-pay-dialog-fail">
        </p>
        <p class="retry">
            <a href="<%=GetUrl("优惠卷确认","order_check.aspx?orderid="+Request["orderid"])%>">»返回选择其他支付方式</a>
        </p>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
