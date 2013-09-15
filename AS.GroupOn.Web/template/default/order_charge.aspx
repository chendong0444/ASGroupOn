<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

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
    
    public NameValueCollection _system = new NameValueCollection();
    public ISystem sysmodel = null;
    public string money;//应付的金额
    public string pd_FrpId;//银行编号
    public string Amt;//支付金额
    public string Pid;//产品编号
    public string orderid;//订单编号
    public string paytype = "";
    public string pordermsg = "";
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        NeedLogin();
        _system = WebUtils.GetSystem();

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            sysmodel = session.System.GetByID(1);
        }

        if (Request["fee"] != null)
        {
            money = Request["fee"].ToString();
        }
        if (Request["pd_FrpId"] != null)
        {
            pd_FrpId = Request["pd_FrpId"].ToString();
        }

        if (Request["paytype"] != null)
        {
            paytype = Request["paytype"].ToString();
        }

        GetMoney();
        Amt = money;

        if (Request["orderid"] != null)
        {
            orderid = Request["orderid"].ToString();
            pordermsg = orderid + "|" + sysmodel.paypalmid + "|" + Amt;//传给回调地址
        }
    }

    #region 根据订单的编号，获取应付的金额
    public void GetMoney()
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            sysmodel = session.System.GetByID(1);
        }
        if (sysmodel != null)
        {
            Pid = sysmodel.abbreviation + "充值" + money;
        }

    }
    #endregion
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
                            <h2>
                                充值金额：<strong class="total-money"><%=ASSystem.currency%><%=money %></strong>
                            </h2>
                        </div>
                        <div class="sect">
                            <div style="text-align: left;">
                                <%if (paytype == "tenpay" && _system["iscftbank"] != null && _system["iscftbank"].ToString() != "" && _system["iscftbank"].ToString() == "0")
                                  { %>
                                <form id="form1" method="post" action="<%=WebRoot %>pay/tenpay/Reg.aspx">
                                <input type="hidden" name="body" value='' />
                                <input type="hidden" name="out_trade_no" value='<%=orderid %>' />
                                <input type="hidden" name="subject" value='<%=Pid %>' />
                                <input type="hidden" name="total_fee" value='<%=Amt %>' />
                                <img src="<%=ImagePath() %>tenpay.jpg" /><br />
                                <input type="submit" class="formbutton gotopay" value="前往财付通支付" />
                                </form>
                                <% }%>
                                  <%if (paytype == "tenpay" && pd_FrpId != "" && _system["iscftbank"] != null && _system["iscftbank"].ToString() != "" && _system["iscftbank"].ToString() == "1")
                                    { %>
                                <form id="form7" target="_blank" method="post" action="<%=WebRoot %>pay/tenpay/Reg.aspx?bank_type=<%=pd_FrpId%>" onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                    <input type="hidden" name="body" value='' />
                                    <input type="hidden" name="out_trade_no" value='<%=orderid %>' />
                                    <input type="hidden" name="partner" value="" />
                                    <input type="hidden" name="payment_type" value="1" />
                                    <input type="hidden" name="return_url" value="" />
                                    <input type="hidden" name="service" value="tenpay" />
                                    <input type="hidden" name="subject" value='<%=Pid %>' />
                                    <input type="hidden" name="total_fee" value='<%=Amt %>' />
                                    <input type="hidden" name="sign_type" value="MD5" />
                                    <input type="submit" class="formbutton gotopay" value="前往财付通银行通付款" />
                                </form>
                                <%}%>
                                <%if (paytype == "yeepay")
                                  { %>
                                <form id="form2" method="post" action="<%=WebRoot %>pay/yeepay/Req.aspx">
                                <input type='hidden' name='p7_Pdesc' value=''>
                                <input type='hidden' name='p8_Url' value=''>
                                <input type='hidden' name='p9_SAF' value='0'>
                                <input type='hidden' name='pa_MP' value=''>
                                <input type='hidden' name='p2_Order' value='<%=orderid %>'>
                                <input type='hidden' name='p3_Amt' value='<%=Amt %>'>
                                <input type='hidden' name='p5_Pid' value='<%=Pid %>'>
                                <input type='hidden' name='pd_FrpId' value='<%=pd_FrpId %>'>
                                <%if (pd_FrpId == "")
                                  { %>
                                <img src="<%=ImagePath()%>yeepay.gif" /><br />
                                <input type="submit" class="formbutton gotopay" value="前往易宝支付" />
                                <%}
                                  else
                                  { %>
                                <img src="<%=ImagePath()%><%= pd_FrpId%>.gif" /><br />
                                <input type="submit" class="formbutton gotopay validator" value="前往银行支付" />
                                <% }%>
                                </form>
                                <% }%>
                                <%if (paytype == "alipay")
                                  { %>
                                <%if (_system["Isalipaylogin"] == "1")
                                  {%>
                                <form id="form3" method="post" action="<%=WebRoot %>pay/alipayQuick/pay.aspx">
                                <% }
                                  else
                                  {%>
                                <form id="form4" method="post" action="<%=WebRoot %>pay/alipay/pay.aspx">
                                <%} %>
                                <input type="hidden" name="body" value='' />
                                <input type="hidden" name="out_trade_no" value='<%=orderid %>' />
                                <input type="hidden" name="subject" value='<%=Pid %>' />
                                <input type="hidden" name="total_fee" value='<%=Amt %>' />
                                <img src="<%=ImagePath()%>alipay.png" /><br />
                                <input type="submit" class="formbutton gotopay" value="前往支付宝支付" />
                                </form>
                                <% }%>
                                <%if (paytype == "chinabank")
                                  { %>
                                <form id="form5" method="post" action="<%=WebRoot %>pay/chinabank/Send.aspx">
                                <input type="hidden" name="body" value='' />
                                <input type="hidden" name="out_trade_no" value='<%=orderid %>' />
                                <input type="hidden" name="subject" value='<%=Pid %>' />
                                <input type="hidden" name="total_fee" value='<%=Amt %>' />
                                <img src="<%=ImagePath()%>chinabank.png" /><br />
                                <input type="submit" class="formbutton gotopay" value="前往网银在线支付" style="vertical-align: middle;" />
                                </form>
                                <% }%>
                                <%if (paytype == "paypal")
                                  { %>
                                <form id="form10" target="_blank" method="post" action="https://www.paypal.com/cgi-bin/webscr">
                                <input type="hidden" name="item_number" value='<%=pordermsg%>' />
                                <input type="hidden" name="cmd" value="_xclick" />
                                <input type="hidden" name="business" value='<%=sysmodel.paypalmid%>' />
                                <input type="hidden" name="item_name" value='<%=Pid%>' />
                                <input type="hidden" name="amount" value="<%=Amt%>" />
                                <input type="hidden" name="currency_code" value="CNY" />
                                <input type="hidden" name="charset" value="utf-8" />
                                <input type="hidden" name="notify_url" value="<%=WebRoot%>pay/paypal/reg.aspx" />
                                <input type="hidden" name="return" value="<%=GetUrl("支付通知", "order_success.aspx?paypalid="+orderid)%>" />
                                <img src="<%=(ImagePath()+"paypal.gif") %>" /><br />
                                <input type="submit" class="formbutton gotopay" value="前往贝宝支付" />
                                </form>
                                <% }%>
                                <%if (paytype == "chinamobilepay")
                                  { %>
                                <form id="form6" method="post" action="<%=WebRoot%>pay/mobile/webPay.aspx">
                                <input type="hidden" name="out_trade_no" value='<%=orderid %>' />
                                <input type="hidden" name="payment_type" value="1" />
                                <input type="hidden" name="subject" value='<%=Pid %>' />
                                <input type="hidden" name="total_fee" value='<%=Amt %>' />
                                <img src="<%=ImagePath()%>chinamobile.jpg" /><br />
                                <input type="submit" class="formbutton gotopay" value="前往移动支付" />
                                </form>
                                <% }%>
                                <%-- <%if (paytype == "allinpay")
                                          { %>
                                        <form id="allinpay" method="post" action="allinpay/post.aspx">
                                        <img src="<%=ImagePath()%>tlzf.jpg" /><br />
                                        <input type="hidden" name="orderNo" value='<%=orderid %>' />
                                        <input type="hidden" name="" value='<%=Pid %>' />
                                        <input type="hidden" name="orderAmount" value='<%=Amt %>' />
                                        <input type="submit" class="formbutton gotopay" value="前往通联支付" />
                                        </form>
                                        <%} %>--%>
                                <div class="back-to-check">
                                    <a href="<%=GetUrl("支付方式","credit_charge.aspx")%>">&raquo; 返回选择其他支付方式</a></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- bd end -->
</div>
<div id="showpaydialog" style="display: none;">
    <div style="width: 380px;" class="order-pay-dialog-c" id="order-pay-dialog">
        <h3>
            <span onclick="return X.boxClose();" class="close" id="order-pay-dialog-close">关闭</span></h3>
        <p class="info">
            请您在新打开的页面上完成付款。</p>
        <p class="notice">
            付款完成前请不要关闭此窗口。<br />
            完成付款后请根据您的情况点击下面的按钮：</p>
        <p class="act">
            <input type="submit" onclick="location.href='<%=GetUrl("支付通知", "order_success.aspx?id="+orderid) %>';"
                value="已完成付款" class="formbutton" id="order-pay-dialog-succ">&nbsp;&nbsp;&nbsp;<input
                    type="submit" onclick="return X.boxClose();" value="付款 遇到问题" class="formbutton"
                    id="order-pay-dialog-fail"></p>
        <p class="retry">
            <a href="<%=GetUrl("支付方式","credit_charge.aspx")%>">»返回选择其他支付方式</a></p>
    </div>
</div>
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %>  
