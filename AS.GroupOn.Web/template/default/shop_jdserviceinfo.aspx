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
    protected IOrder ordermodel = null;
    protected decimal totalprice = 0;//应付总额不含运费
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
    protected string headlogo = String.Empty;
    protected string sitename = String.Empty;
    protected string icp = String.Empty;
    protected string statcode = String.Empty;
    protected string abbreviation = String.Empty;//网站简称
    protected string footlogo = String.Empty;
    protected IUser iuser = null;
    protected bool isPacket = false;
    protected IList<IPacket> iListPacket = null;
    protected NameValueCollection nv = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NeedLogin();
        GetPayImg();
        if (AsUser.Id != 0)
        {
            PacketFilter packetfilter = new PacketFilter();
            packetfilter.State = "0";
            packetfilter.User_id = AsUser.Id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iListPacket = session.Packet.GetList(packetfilter);
            }
            if (iListPacket != null && iListPacket.Count > 0)
            {
                isPacket = true;
            }
        }
        _system = PageValue.CurrentSystemConfig;
        if (ASSystem != null)
        {
            abbreviation = ASSystem.abbreviation;
            if (PageValue.CurrentSystemConfig["mallheadlogo"] != null && PageValue.CurrentSystemConfig["mallheadlogo"].ToString() != "")
            {
                headlogo = PageValue.CurrentSystemConfig["mallheadlogo"];
            }
            else
            {
                headlogo = "/upfile/img/mall_logo.png";
            }
            if (PageValue.CurrentSystemConfig["mallfootlogo"] != null && PageValue.CurrentSystemConfig["mallfootlogo"].ToString() != "")
            {
                footlogo = _system["mallfootlogo"];
            }
            else
            {
                footlogo = ASSystem.footlogo;
            }
            abbreviation = ASSystem.abbreviation;
            sitename = ASSystem.sitename;
            icp = ASSystem.icp;
            statcode = ASSystem.statcode;
        }
        _system = PageValue.CurrentSystemConfig;
        systemmodel = PageValue.CurrentSystem;
        lock (locker)
        {
            if (Request["orderid"] != null)
            {
                if (OrderMethod.IsUserOrder(AsUser.Id, Helper.GetInt(Request["orderid"], 0)))
                {
                    SetError("友情提示：无法操作其他用户的订单");
                    Response.Redirect(WebRoot + "index.aspx");
                    Response.End();
                    return;
                }
                //判断当前订单是否已经付款了，是否有已经卖光的或者过期的项目则阻止付款
                int temporderid = Helper.GetInt(Request["orderid"], 0);
                decimal paymoney = Helper.GetDecimal(Request["p"], 0);
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
                orderid = Request["orderid"].ToString();//获取交易单号
                GetMoney(orderid, paymoney);
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
                    AS.Common.Utils.JsHelper.Alert("您输入的金额超出订单金额,请您重新输入");
                }
                if (m > usermodel.Money)
                {
                    AS.Common.Utils.JsHelper.Alert("您输入的金额超出您的帐户余额,请您重新输入");
                }
                if (m == ordermodel.Origin)
                {
                    AS.Common.Utils.JsHelper.Alert("您输入的金额不正确,请您重新选择");
                }
                AS.Common.Utils.JsHelper.Redirect(GetUrl("京东选择银行", "shop_jdservice.aspx?orderid=" + Helper.GetInt(Request["orderid"], 0)));
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
    protected void GetPayImg()
    {
        nv.Add("1002", "/upfile/css/i/ICBC-NET.png");
        nv.Add("1003", "/upfile/css/i/CCB-NET.png");
        nv.Add("1001", "/upfile/css/i/CMBCHINA-NET.png");
        nv.Add("1020", "/upfile/css/i/BOCO-NET.png");
        nv.Add("1005", "/upfile/css/i/ABC-NET.png");
        nv.Add("1027", "/upfile/css/i/GDB-NET.png");
        nv.Add("1009", "/upfile/css/i/CIB-NET.png");
        nv.Add("1022", "/upfile/css/i/CEB-NET.png");
        nv.Add("1028", "/upfile/css/i/POST-NET.png");
        nv.Add("1021", "/upfile/css/i/ECITIC-NET.png");
        nv.Add("1004", "/upfile/css/i/SPDB-NET.png");
        nv.Add("1052", "/upfile/css/i/BOC-NET.png");
        nv.Add("1008", "/upfile/css/i/SDB-NET.png");
        nv.Add("1006", "/upfile/css/i/CMBC-NET.png");
        nv.Add("1032", "/upfile/css/i/BCCB-NET.png"); 
    }
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head">
    <meta name="keywords" content="<%=PageValue.KeyWord %>"/>
    <meta name="description" content="<%=PageValue.Description %>" />
    <title>订单信息确认 - <%=PageValue.CurrentSystemConfig["malltitle"]%></title>
    <script type='text/javascript' src="<%=PageValue.WebRoot %>upfile/js/index.js"></script>
    <link href="<%=PageValue.WebRoot %>upfile/css/orderInfo.css" rel="stylesheet" type="text/css" charset="utf-8" />
</head>
<script type="text/javascript">
    function addToFavorite() {
        var d = "<%=PageValue.WWWprefix%>";
        var c = "<%=PageValue.CurrentSystemConfig["mallsitename"] %>";
        if (document.all) {
            window.external.AddFavorite(d, c)
        } else {
            if (window.sidebar) {
                window.sidebar.addPanel(c, d, "")
            } else {
                alert("\u5bf9\u4e0d\u8d77\uff0c\u60a8\u7684\u6d4f\u89c8\u5668\u4e0d\u652f\u6301\u6b64\u64cd\u4f5c!\n\u8bf7\u60a8\u4f7f\u7528\u83dc\u5355\u680f\u6216Ctrl+D\u6536\u85cf\u672c\u7ad9\u3002")
            }
        }
    }
</script>
<body>
    <div id="dialog" style="display: none; background-color: rgb(255, 255, 255); left: 517.5px; top: 73.8px; z-index: 10000;">
    </div>
    <div id="pagemasker">
    </div>
    <div id="shortcut-2013">
        <div class="w">
<ul class="fl lh">
			<li  class="fore1 ld"><b></b><a rel="nofollow" href="javascript:addToFavorite()">收藏<%= PageValue.CurrentSystemConfig["mallsitename"]%></a>
			</li>
	</ul>
            <ul class="fr lh">
                <%if (IsLogin && AsUser.Id != 0)
                  { %>
                <% if (AsUser.Realname != null && AsUser.Realname != "")
                   {%>
                <li class="fore1" id="loginbar">您好，
                        <%=AsUser.Realname%>！<a href="<%=PageValue.WebRoot %>loginout.aspx" class="link-logout">[退出]</a></li>
                <li class="fore2 ld"><s></s><a href="<%=GetUrl("我的订单", "order_index.aspx")%>" rel="nofollow">我的订单</a></li>
                <%if (isPacket == true)
                  {%>
                <li class="fore3 ld"><s></s><a href="<%=GetUrl("我的红包", "order_packet.aspx")%>" rel="nofollow">我的红包</a></li>
                <%} %>
                <%}
                   else
                   { %>
                <li class="fore1">您好，<%=AsUser.Username%>！<a href="<%=PageValue.WebRoot %>loginout.aspx"
                    class="link-logout">[退出]</a></li>
                <li class="fore2 ld"><s></s><a href="<%=GetUrl("我的订单", "order_index.aspx")%>" rel="nofollow">我的订单</a></li>
                <%} %>
                <%}
                  else
                  {%>
                <li class="fore1">您好！欢迎来到<%= PageValue.CurrentSystemConfig["mallsitename"]%>！<span><a
                    href="<%=GetUrl("用户登录", "account_login.aspx")%>">[登录]</a>&nbsp;<a href="<%=GetUrl("用户注册", "account_loginandreg.aspx")%>">[免费注册]</a></span></li>
                <%} %>
                <span class="clr"></span>
            </ul>
        </div>
    </div>
    <!--shortcut end-->
    <div class="w" id="headers">
        <div id="logo">
            <a href="<%=GetUrl("商城首页","mall_index.aspx")%>">
                <b></b>
                <img src="<%=headlogo %>" width="170" height="60" alt="<%= PageValue.CurrentSystemConfig["mallsitename"]%>"></a>
        </div>
        <div id="step2" class="step">
            <ul>
                <li class="fore1">1.选择支付方式<b></b></li>
                <li class="fore2">2.核对支付信息<b></b></li>
                <li class="fore3">3.支付结果信息</li>
            </ul>
        </div>
        <div class="clr"></div>
    </div>
    <script>
        $(document).ready(function () {
            jQuery("input[name='pd_FrpId']").click(function () {
                jQuery("input[name='paytype']").attr("checked", false);
                jQuery("input[name='cft_FrpId']").attr("checked", false);
            });
            jQuery("input[name='paytype']").click(function () {
                jQuery("input[name='pd_FrpId']").attr("checked", false);
                jQuery("input[name='cft_FrpId']").attr("checked", false);
            });
            jQuery("input[name='cft_FrpId']").click(function () {
                jQuery("input[name='pd_FrpId']").attr("checked", false);
                jQuery("input[name='paytype']").attr("checked", false);
            });
        })
    </script>
    <div class="w main">
        <div class="m m3" id="qpay">
            <div class="mc">
                <s class="icon-succ02"></s>
                <div class="fore">
                    <h3 class="ftx-02">订单提交成功，请您尽快付款！</h3>
                    <ul class="list-h">
                        <li class="fore1">订单号：<%=ordermodel.Id %></li>
                        <li class="fore2">应付金额：<strong class="ftx-01"><%=ASSystem.currency%><%=money %>元</strong></li>
                     
                    </ul>
                    <p id="p_show_info">&nbsp;</p>
                </div>
            </div>
        </div>
        <div id="qpay13" class="m tabs">
            <div class="mt">
            </div>
            <div class="mc" data-widget="tabs">
                <div class="tabcon">
                    <div class="i-tab-t">您已选择的支付方式：</div>
                    <dl class="fore0 clearfix">
                        <dd>
                            <%if (service == "credit")
                                { %>
                            <form id="form1" action="" method="post" target="_blank" onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                               <ul class="list-h">
                                    <li>
                                        <div class="bank-info">
                                             <img src="/upfile/css/i/balance-pay.gif" width="125" height="28" />
                                            </div>
                                    </li>
                                </ul>
                                 <div class="i-extra"><a href="<%=GetUrl("京东选择银行","shop_jdservice.aspx?orderid=" + ordermodel.Id)%>">[重新选择]</a></div>
                                <input type="hidden" name="service" value="credit" />
                                <div class="clr"></div>
                                <input type="submit" name="pay" style="vertical-align: middle;" class="btn-impay" value="使用账户余额支付" />
                            </form>
                            <%}
                              else if (service == "tenpay" && cft_FrpId != "" && _system["iscftbank"] != null && _system["iscftbank"].ToString() != "" && _system["iscftbank"].ToString() == "1")
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
                                <ul class="list-h">
                                    <li>
                                        <div class="bank-info">
                                            <img src="<%=nv[cft_FrpId]%>" width="125" height="28" /></div>
                                    </li>
                                </ul>
                                <div class="i-extra"><a href="<%=GetUrl("京东选择银行","shop_jdservice.aspx?orderid=" + ordermodel.Id)%>">[重新选择]</a></div>
                                <div class="clr"></div>
                                <input type="submit"  class="btn-impay" value="前往财付银行通付款" style="vertical-align: middle;" />
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
                                <ul class="list-h">
                                    <li>
                                        <div class="bank-info">
                                            <img src="<%=ImagePath()%>tenpay.jpg" width="125" height="28" /></div>
                                    </li>
                                </ul>
                                <div class="i-extra"><a href="<%=GetUrl("京东选择银行","shop_jdservice.aspx?orderid=" + ordermodel.Id)%>">[重新选择]</a></div>
                                <div class="clr"></div>
                                <input type="submit" class="btn-impay" value="前往财付通付款" style="vertical-align: middle;" />
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

                                <ul class="list-h">
                                    <li>
                                        <div class="bank-info">
                                            <img src="<%=ImagePath()%>paypal.gif" width="125" height="28" /></div>
                                    </li>
                                </ul>
                                <div class="i-extra"><a href="<%=GetUrl("京东选择银行","shop_jdservice.aspx?orderid=" + ordermodel.Id)%>">[重新选择]</a></div>
                                <div class="clr"></div>
                                <input type="submit" class="btn-impay" value="前往贝宝支付" style="vertical-align: middle;" />
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
                                    <ul class="list-h">
                                        <li>
                                            <div class="bank-info">
                                                <img src="<%=ImagePath()%>alipay.png" width="125" height="28" /></div>
                                        </li>
                                    </ul>
                                    <div class="i-extra"><a href="<%=GetUrl("京东选择银行","shop_jdservice.aspx?orderid=" + ordermodel.Id)%>">[重新选择]</a></div>
                                    <div class="clr"></div>
                                    <input type="submit" class="btn-impay" value="前往支付宝支付" style="vertical-align: middle;" />
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
                                    <ul class="list-h">
                                        <li>
                                            <div class="bank-info">
                                                <img src="<%=ImagePath()%>yeepay.gif" width="125" height="28" /></div>
                                        </li>
                                    </ul>
                                    <div class="i-extra"><a href="<%=GetUrl("京东选择银行","shop_jdservice.aspx?orderid=" + ordermodel.Id)%>">[重新选择]</a></div>
                                     <div class="clr"></div>
                                    <input type="submit" class="btn-impay" value="前往易宝支付" style="vertical-align: middle;" />

                                    <%}
                                      else
                                      { %>
                                    <ul class="list-h">
                                        <li>
                                            <div class="bank-info">
                                                <img src="/upfile/css/i/<%= pd_FrpId%>.png" width="125" height="28" /></div>
                                        </li>
                                    </ul>
                                    <div class="i-extra"><a href="<%=GetUrl("京东选择银行","shop_jdservice.aspx?orderid=" + ordermodel.Id)%>">[重新选择]</a></div>
                                     <div class="clr"></div>
                                    <input type="submit" class="btn-impay " value="前往银行支付" style="vertical-align: middle;" />
                                    <%}%>
                                </form>
                                <%}
                                    else if (service == "paypal")
                                    { %>
                                <ul class="list-h">
                                    <li>
                                        <div class="bank-info">
                                            <img src="<%=ImagePath()%>paypal.png" width="125" height="28" /></div>
                                    </li>
                                </ul>
                                <div class="i-extra"><a href="<%=GetUrl("京东选择银行","shop_jdservice.aspx?orderid=" + ordermodel.Id)%>">[重新选择]</a></div>

                                <div class="clr"></div>
                                <input type="submit" class="btn-impay" value="Go to PayPal" style="vertical-align: middle;" />
                                <%}
                                    else if (service == "allinpay")
                                    { %>
                                <form id="allinpay" method="post" action="<%=WebRoot %>pay/allinpay/post.aspx" target="_blank" onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                    <input type="hidden" name="orderNo" value='<%=ordermodel.Pay_id %>' />
                                    <input type="hidden" name="orderPid" value='<%=Pid %>' />
                                    <input type="hidden" name="orderAmount" value='<%=Amt %>' />
                                    <input type="hidden" name="orderId" value='<%=orderId %>' />
                                    <ul class="list-h">
                                        <li>
                                            <div class="bank-info">
                                                <img src="<%=ImagePath()%>tlzf.jpg" width="125" height="28" /></div>
                                        </li>
                                    </ul>
                                    <div class="i-extra"><a href="<%=GetUrl("京东选择银行","shop_jdservice.aspx?orderid=" + ordermodel.Id)%>">[重新选择]</a></div>

                                    <div class="clr"></div>
                                    <input type="submit" class="btn-impay" value="前往通联支付" style="vertical-align: middle;" />
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

                                    <ul class="list-h">
                                        <li>
                                            <div class="bank-info">
                                                <img src="<%=ImagePath()%>chinabank.png" width="125" height="28" /></div>
                                        </li>
                                    </ul>
                                    <div class="i-extra"><a href="<%=GetUrl("京东选择银行","shop_jdservice.aspx?orderid=" + ordermodel.Id)%>">[重新选择]</a></div>

                                    <div class="clr"></div>
                                    <input type="submit" class="btn-impay" value="前往网银在线支付" style="vertical-align: middle;" />
                                </form>
                                <% }%>
                                <%else if (service == "cashondelivery")
                                    { %>
                                <form id="cashondelivery" method="post" action="<%=WebRoot %>pay/cashondelivery/pay.aspx" target="_blank"
                                    onsubmit="X.boxShow($('#showpaydialog').html(),true)">
                                    <input type="hidden" name="cashNo" value='<%=ordermodel.Pay_id %>' />
                                    <input type="hidden" name="cashAmount" value='<%=Amt %>' />
                                    <input type="hidden" name="cashId" value='<%=orderid %>' />
                                      <ul class="list-h">
                                        <li>
                                            <div class="bank-info">
                                                <img src="/upfile/css/i/cash.gif"  width="125" height="28" /></div>
                                        </li>
                                    </ul>
                                    <div class="i-extra"><a href="<%=GetUrl("京东选择银行","shop_jdservice.aspx?orderid=" + ordermodel.Id)%>">[重新选择]</a></div>
                                       <div class="clr"></div>
                                    <input type="submit" class="btn-impay" value="货到付款" style="vertical-align: middle;" />
                                </form>
                                <% }%>
                        </dd>
                    </dl>
                </div>
            </div>
        </div>
        <div class="m" id="qpay08">
            <div class="mc">
                <h5>温馨提示：</h5>
                <dl>
                    <dt>1.网银银行页面打不开，怎么办？</dt>
                    <dd>-建议使用IE核心的浏览器，点击IE的菜单“工具”－“Internet选项”－“安全”，将安全中的各项设置恢复到默认级别。</dd>
                    <dt>2.我的银行卡未开通网上支付功能，怎么办？</dt>
                    <dd>-登录该银行卡的网上银行主页，在线开通网上支付功能，有些银行开通需要到银行柜台，您最好致电该银行客服咨询。</dd>
                    <dt>3.我的订单金额超过该银行支付限额怎么办？</dt>
                    <dd>-如您使用的是京东支持快捷支付的银行卡，建议您使用快捷支付，快捷支付信用卡的支付限额是信用卡额度本身。<br>
                        -如暂不支持您的银行卡开通快捷支付，您可以使用银联在线支付平台，银联在线的认证支付对支付限额限制较少，支持大额支付。</dd>

                </dl>
            </div>
        </div>

        <div class="o-mb">
            完成支付后，您可以：
							<a href="<%=GetUrl("订单详情","order_view.aspx?id="+ordermodel.Id) %>" target="_blank">查看订单详情</a>
        </div>
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
                    <input type="submit" style="padding: 4px 1em; color: #fff; background-color: #FF3300; border-top-color: #FF5353; border-bottom-color: #990000; border-left-color: #FF5353; margin-top: 10px; margin-left: 10px;" onclick="location.href='<%=GetUrl("支付通知", "order_success.aspx?id="+ordermodel.Pay_id) %>    ';" value="已完成付款" class="formbutton" id="order-pay-dialog-succ">&nbsp;&nbsp;&nbsp;<input type="submit" onclick="    return X.boxClose();" value="付款 遇到问题" style="padding: 4px 1em; color: #fff; background-color: #FF3300; border-top-color: #FF5353; border-bottom-color: #990000; border-left-color: #FF5353; margin-top: 10px; margin-left: 10px;"
                        id="order-pay-dialog-fail">
                </p>
                <p class="retry">
                    <a href="<%=GetUrl("京东银行支付","shop_jdserviceinfo.aspx?orderid=" + ordermodel.Id)%>">»返回选择其他支付方式</a>
                </p>
            </div>
        </div>
    </div>
    <div class="Footer_Link">
        <div class="copyright">
            &copy;<span>2010</span>&nbsp;<%=sitename
            %>（<%=WWWprefix %>）版权所有&nbsp;<a href="<%=GetUrl("用户协议","about_terms.aspx")%>">使用<%=abbreviation
            %>前必读</a><br />
            <a href="http://www.miibeian.gov.cn/" target="_blank"><%=icp %></a>&nbsp;&nbsp;<%=statcode
            %> &nbsp;Powered by ASdht(<a target="_blank" href="http://www.asdht.com">艾尚团购系统程序</a>)
    Software V_<%=ASSystemArr["siteversion"] %>
        </div>
    </div>
</body>
</html>
