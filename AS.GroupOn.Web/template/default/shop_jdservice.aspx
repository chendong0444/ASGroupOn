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
    public ISystem sysmodel = null;
    public IUser user = null;
    public ITeam teamodel = null;
    public IOrder ordermodel = null;
    public bool falg = false;
    public string strpage;
    public string pagenum = "1";
    public string service = "";//支付网关默认为账户余额
    public NameValueCollection _system = new NameValueCollection();
    public IList<IOrderDetail> detaillist = null;
    bool isRedirect = false;
    protected decimal totalprice = 0;//应付总额不含运费
    protected decimal fare = 0;//应付运费
    protected bool payselectexpress = false;
    public bool show = false;
    protected string headlogo = String.Empty;
    protected string sitename = String.Empty;
    protected string icp = String.Empty;
    protected string statcode = String.Empty;
    protected string abbreviation = String.Empty;//网站简称
    protected string footlogo = String.Empty;
    protected IUser iuser = null;
    protected bool isPacket = false;
    protected IList<IPacket> iListPacket = null;
    protected decimal inputmoney = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
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
        sysmodel = PageValue.CurrentSystem;
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
        if (_system["payselectexpress"] == "1")
        {
            payselectexpress = true;
        }
        NeedLogin();
        using (IDataSession session = Store.OpenSession(false))
        {
            ordermodel = session.Orders.GetByID(Helper.GetInt(Request["orderid"], 0));
        }
        if (ordermodel != null && ordermodel.OrderDetail != null)
        {
            detaillist = ordermodel.OrderDetail;
            user = ordermodel.User;
        }
        if (ordermodel == null || ordermodel.User_id != AsUser.Id)
        {
            SetError("不存在此订单");
            Response.Redirect(WebRoot + "index.aspx");
            Response.End();
            return;
        }
        form1.Action = GetUrl("京东选择银行", "shop_jdservice.aspx?orderid=" + Helper.GetInt(Request["orderid"], 0));
        showcash(Helper.GetInt(Request["orderid"], 0));
        if (Request.Form["btnadd"] == "确认订单，付款")
        {
            NeedLogin();
            CookieUtils.ClearCar();//清除cookie
            if (NumberUtils.IsNum(Request["orderid"].ToString()))
            {
                fare = ordermodel.Fare;
            }
            ConfirmOrder();
        }
        if (Request["orderid"] != null)
        {
            //用户无法修改其他用户的额单子
            if (OrderMethod.IsUserOrder(AsUser.Id, Helper.GetInt(Request["orderid"], 0)))
            {
                //SetError("友情提示：无法操作其他用户的订单");
                Response.Redirect(WebRoot + "index.aspx");
                Response.End();
                return;
            }
            if (NumberUtils.IsNum(Request["orderid"].ToString()))
            {

                fare = ordermodel.Fare;
                totalprice = ordermodel.Origin;
            }
        }
    }
    public void showcash(int orderid)
    {
        int num = 0;
        int newnum = 0;
        int cash = 0;
        if (ordermodel.OrderDetail != null && ordermodel.OrderDetail.Count > 0)
        {
            for (int j = 0; j < ordermodel.OrderDetail.Count; j++)
            {
                teamodel = ordermodel.OrderDetail[j].Team;
                if (teamodel != null)
                {
                    cash = Helper.GetInt(teamodel.cashOnDelivery, 0);
                }
                if (cash == 0)
                {
                    num += 1;
                }
                else
                {
                    newnum += 1;
                }
            }
        }
        if (newnum > 0 && num == 0)
        {
            show = true;
        }
    }
    //如果用户当前余额可以付款，那么修改订单状态
    public void ConfirmOrder()
    {
        IOrder ordermodel = null;
        IUser usermodel = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            ordermodel = session.Orders.GetByID(Helper.GetInt(Request["orderid"], 0));
        }
        if (ordermodel != null)
        {
            usermodel = ordermodel.User;
            if (usermodel != null)
            {
                inputmoney = Helper.GetDecimal(Request["inputmoney"], 0);
                if (Request["pd_FrpId"] != null) //如果用户选择了某个银行那么，支付网关就是选中的银行
                {
                    service = "yeepay";
                }
                else if (Request["paytype"] != null)
                {
                    service = Request["paytype"].ToString();
                }
                else if (Request["cft_FrpId"] != null)
                {
                    service = "tenpay";
                }
                //paypal支付
                else if (Request["paypal"] != null)
                {
                    service = Request["paypal"].ToString();
                }
                else
                {
                    service = ""; //用户没有选择支付网关，默认为支付宝
                }
                if (service == "")
                {
                    SetError("请您选择支付方式");
                    Response.Redirect(GetUrl("京东选择银行", "shop_jdservice.aspx?orderid=" + Helper.GetInt(Request["orderid"], 0)));
                    Response.End();
                }
                else
                {
                    if (service != "credit")
                    {
                        if (inputmoney != 0)
                        {
                            if (inputmoney > ordermodel.Origin || inputmoney > usermodel.Money)
                            {
                                if (inputmoney > ordermodel.Origin)
                                {
                                    SetError("您输入的金额超出订单金额,请您重新输入");
                                }
                                if (inputmoney > usermodel.Money)
                                {
                                    SetError("您输入的金额超出您的帐户余额,请您重新输入");
                                }
                                Response.Redirect(GetUrl("京东选择银行", "shop_jdservice.aspx?orderid=" + Helper.GetInt(Request["orderid"], 0))); 
                                Response.End();
                            }
                        }
                    }
                    else
                    {
                        inputmoney = 0;
                    }
                    #region 修改订单的支付网关,同时生成交易单号
                    OrderMethod.Updatebyservice(ordermodel.Id, service, OrderMethod.Getorder(ordermodel.User_id, ordermodel.Team_id, ordermodel.Id), ordermodel.Origin);
                    #endregion
                    Response.Redirect(GetUrl("京东银行支付", "shop_jdserviceinfo.aspx?orderid=" + ordermodel.Id + "&pd_FrpId=" + Request["pd_FrpId"] + "&cft_FrpId=" + Request["cft_FrpId"] + "&fare=" + fare + "&p=" + inputmoney));
                    Response.End();
                }
            }
            else
            {
               SetError("订单不存在");
                return;
            }
        }
    }
    //根据项目编号，查询项目内容
    public string GetTeam(string id)
    {
        ITeam t = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            t = session.Teams.GetByID(Helper.GetInt(id, 0));
        }
        if (t != null)
            return t.Title;
        else
            return "";
    }
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head">
    <meta name="keywords" content="<%=PageValue.KeyWord %>"/>
    <meta name="description" content="<%=PageValue.Description %>" />
    <title>订单信息确认 - <%=PageValue.CurrentSystemConfig["malltitle"]%></title>
    <script type='text/javascript' src="<%=PageValue.WebRoot %>upfile/js/index.js"></script>
    <link href="<%=PageValue.WebRoot %>upfile/css/orderInfo.css" rel="stylesheet" type="text/css" />
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
    $(document).ready(function () {
        $("#btnadd").click(function () {
            var money = parseFloat("<%=inputmoney %>");
            var pm = parseFloat("<%=ordermodel.Origin %>");
            var um = parseFloat("<%=user.Money%>");
            var im = $("#inputmoney").val();
            var paytype = $("input[name='paytype']:checked");
            var cft_FrpId = $("input[name='cft_FrpId']:checked");
            var pd_FrpId = $("input[name='pd_FrpId']:checked");
            if (paytype.length <= 0 && cft_FrpId.length <= 0 && pd_FrpId.length <= 0) {
                alert("请选择支付方式");
                return false;
            }
            if ($("input:radio:checked").val() != "credit") {
                if (im > 0) {
                    if (im > pm) {
                        alert("您输入的金额超出订单金额,请您重新输入");
                        return false;
                    }
                    else if (im == pm) {
                        alert("您输入的金额请不要大于或等于订单金额,请您重新输入");
                        return false;
                    }
                    if (im > um) {
                        alert("您输入的金额超出您的帐户余额,请您重新输入");
                        return false;
                    }
                }
            }
        });
    });
</script>
<body>
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

                <li class="fore1">您好，<%=iuser.Username%>！<a href="<%=PageValue.WebRoot %>loginout.aspx"
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
                    <img src="<%=headlogo %>" width="170" height="60" alt="<%= PageValue.CurrentSystemConfig["mallsitename"]%>"></a></div>
        <div id="step1" class="step">
            <ul>
                <li class="fore1">1.选择支付方式<b></b></li>
                <li class="fore2">2.核对支付信息<b></b></li>
                <li class="fore3">3.支付结果信息</li>
            </ul>
        </div>
        <div class="clr"></div>
    </div>
    <div class="w main">
        <div class="m m3" id="qpay">
            <div class="mc">
                <s class="icon-succ02"></s>
                <div class="fore">
                    <h3 class="ftx-02">订单提交成功，请您尽快付款！</h3>
                    <ul class="list-h">
                        <li class="fore1">订单号：<%=ordermodel.Id %></li>
                        <li class="fore2">应付金额：<strong class="ftx-01"><%=ASSystem.currency%><%=totalprice %>元</strong></li>
                    </ul>
                    <p id="p_show_info">&nbsp;</p>
                </div>
            </div>
        </div>
        <form id="form1" runat="server">
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
            <div class="Wrap_cart">
                <asp:HiddenField ID="HiddenField1" runat="server" />
                <!--Cart信息开始-->
                <table class="Table" cellpadding="0" cellspacing="0" width="100%">
                    <tbody>
                        <tr class="align_Center Thead">
                            <td>商品名称
                            </td>
                            <td width="7%">数量
                            </td>
                            <td width="10%"></td>
                            <td width="10%">价格
                            </td>
                            <td width="10%"></td>
                            <td width="8%">总价
                            </td>
                        </tr>
                        <%  int num = 0; %>
                        <%foreach (var model in detaillist)
                          { %>
                        <tr>
                            <td class="deal-buy-desc"><%=GetTeam(model.Teamid.ToString())%><font style="color: red"><%=WebUtils.Getbulletin(model.result)%></font></td>
                            <td t="totalnum" tid="<%=model.Teamid %>" class="deal-buy-quantity"><%=model.Num%></td>
                            <td class="deal-buy-multi">x</td>
                            <td class="deal-buy-price" id="Td1"><span class="money"><span><%=ASSystem.currency%><%=model.Teamprice%></td>
                            <td class="deal-buy-price">=</td>
                            <td class="deal-buy-total" id="Td2" total="teamprice"><%=ASSystem.currency%><%=Convert.ToDecimal(model.Num*model.Teamprice-model.Credit)%></td>
                        </tr>
                        <% }%>
                        <tr>
                            <td class="deal-buy-desc">快递</td>
                            <td class="deal-buy-quantity"></td>
                            <td class="deal-buy-multi"></td>
                            <td class="deal-buy-price"><span id="Span3" total="fareprice">
                                <%=ASSystem.currency%><%=fare%>
                            </span></td>
                            <td class="deal-buy-price"></td>
                            <td class="deal-buy-total"><span class="money"></span><span id="Span4"></td>
                        </tr>
                        <%if (ordermodel.disamount > 0)
                          { %>
                        <tr>
                            <td class="deal-buy-desc">
                                <%=ordermodel.Disinfos%>
                            </td>
                            <td class="deal-buy-quantity"></td>
                            <td class="deal-buy-multi"></td>
                            <td class="deal-buy-price">
                                <span id="Span5" total="fareprice">
                                    <%=ASSystem.currency%>-<%=(ordermodel.disamount) %>
                                </span>
                            </td>
                            <td></td>
                            <td class="deal-buy-total">
                                <span class="money"></span><span id="Span6"></span>
                            </td>

                        </tr>
                        <%} %>
                        <%if (ordermodel.State != "scoreunpay")
                          { %>
                        <%if (ActionHelper.GetUserLevelMoney(AsUser.totalamount) != 1)
                          { %>
                        <tr>
                            <td></td>
                            <td colspan="3" style="color: red">等级：<%=Utilys.GetUserLevel(AsUser.totalamount)%>,折扣：
                                            <% if (ActionHelper.GetUserLevelMoney(AsUser.totalamount) < 1)
                                               {%>
                                <%=ActionHelper.GetUserLevelMoney(AsUser.totalamount)*10 + "折"%>
                                <% }
                                               else
                                               {%>
                                            不打折
                                            <%}%>
                            </td>
                            <td></td>
                            <td></td>
                        </tr>
                        <%}%>
                        <%}%>
                        <tr class="order-total">
                            <td class="deal-buy-desc"><strong>应付总额：</strong></td>
                            <td class="deal-buy-quantity"></td>
                            <td class="deal-buy-multi"></td>
                            <td class="deal-buy-price"></td>
                            <td class="deal-buy-equal">=</td>
                            <td class="deal-buy-total" total="totalprice">
                                <%=ASSystem.currency%><%=totalprice %>
                            </td>
                        </tr>
                    </tbody>
                </table>
                <!--Cart信息结束-->
                <div id="qpay13" class="m tabs">
                    <div class="mt">
                        <div class="hn" id="notice1"></div>
                    </div>
                    <input id="savingsFlag" name="savingsFlag" type="hidden" value="0" />
                    <input id="creditFlag" name="creditFlag" type="hidden" value="0" />
                    <input id="ruDebitFlag" name="ruDebitFlag" type="hidden" value="0" />
                    <input id="ruCreditFlag" name="ruCreditFlag" type="hidden" value="0" />
                    <div class="mc" data-widget="tabs">
                        <div class="tabcon ol3" data-widget="tabs">
                            <div class="mpart fore1">
                                <%if (ordermodel.State == "unpay")
                                  {%>
                                <div class="order-pay-credit">
                                    <strong>您的余额</strong>
                                    <p>
                                        账户余额：<strong><span class="money"></span><%=ASSystem.currency%><%=user.Money%></strong>

                                     
                                        <%if (user.Money < ordermodel.Origin)
                                          { %>
                         ,您的余额不够完成本次付款，还需支付 <strong><span class="money"></span><%=ASSystem.currency%><%=OrderMethod.Getyumoney(user.Money, ordermodel.Origin)%> </strong>

                                        <%} %>
                                           <%if (user.Money>0)
                                          {%>
                                        使用账户余额支付
                                              <input id="inputmoney" type="text" name="inputmoney" value="<%=Helper.GetDecimal(Request["inputmoney"],0)%>" style="width:50px" /> 
                                          <% } %>
                                    </p>
                                    <div class="other_pay"></div>
                                </div>
                                <% }%>
                                <strong>请选择支付方式：</strong>
                            </div>
                            <div class="mpart fore2">
                                <%if (sysmodel != null)
                                  { %>
                                <%if (sysmodel.yeepaymid != "" && CookieUtils.GetCookieValue("alipay_token") == "" && _system["isybbank"] != null && _system["isybbank"].ToString() != "" && _system["isybbank"].ToString() == "1")
                                  {%>
                                   <div class="mp-t">
                                    <strong>易宝支付</strong>
                                </div>
                                <input type="hidden" id="ybbank" value="<%=_system["isybbank"]%>" />
                                <ul class="bank-list" id="common_bank_one">
                                    <li>
                                        <input type="radio" class="radio" value="ICBC-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="工商银行" src="/upfile/css/i/ICBC-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="CCB-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="建设银行" src="/upfile/css/i/CCB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" id="abc" value="CMBCHINA-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="招商银行" src="/upfile/css/i/CMBCHINA-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li clstag="payment|keycount|bank|c-bcom" class="">
                                        <input type="radio" class="radio" value="BOCO-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="交通银行" src="/upfile/css/i/BOCO-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="ABC-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="中国农业银行" src="/upfile/css/i/ABC-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="GDB-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="广东发展银行" src="/upfile/css/i/GDB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="CIB-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="兴业银行" src="/upfile/css/i/CIB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="CEB-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="光大银行" src="/upfile/css/i/CEB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="POST-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="中国邮政" src="/upfile/css/i/POST-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="ECITIC-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="中信银行" src="/upfile/css/i/ECITIC-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="SPDB-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="上海浦发银行" src="/upfile/css/i/SPDB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="BOC-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="中国银行" src="/upfile/css/i/BOC-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="SDB-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="深圳发展银行" src="/upfile/css/i/SDB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="CMBC-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="中国民生银行" src="/upfile/css/i/CMBC-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="BCCB-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="北京银行" src="/upfile/css/i/BCCB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="CBHB-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="渤海银行" src="/upfile/css/i/CBHB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="NJCB-NET" name="pd_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="南京银行" src="/upfile/css/i/NJCB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                </ul>
                                <% }%>
                                <% }%>
                            </div>
                            <div class="mpart fore1">
                                <%if (sysmodel.tenpaymid != "" && _system["iscftbank"] != null && _system["iscftbank"].ToString() != "" && _system["iscftbank"].ToString() == "1")
                                  {%>
                                <div class="mp-t">
                                    <strong>财付通支付</strong>
                                </div>
                                <input type="hidden" id="Hidden1" value="<%=_system["iscftbank"]%>" />
                                <ul class="bank-list" id="Ul1">
                                    <li>
                                        <input type="radio" class="radio" value="1002" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="工商银行" src="/upfile/css/i/ICBC-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1003" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="建设银行" src="/upfile/css/i/CCB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1001" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="招商银行" src="/upfile/css/i/CMBCHINA-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1020" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="交通银行" src="/upfile/css/i/BOCO-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1005" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="中国农业银行" src="/upfile/css/i/ABC-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1027" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="广东发展银行" src="/upfile/css/i/GDB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1009" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="兴业银行" src="/upfile/css/i/CIB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1022" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="光大银行" src="/upfile/css/i/CEB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1028" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="中国邮政" src="/upfile/css/i/POST-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1021" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="中信银行" src="/upfile/css/i/ECITIC-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1004" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="上海浦发银行" src="/upfile/css/i/SPDB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1052" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="中国银行" src="/upfile/css/i/BOC-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1008" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="深圳发展银行" src="/upfile/css/i/SDB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1006" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="中国民生银行" src="/upfile/css/i/CMBC-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                    <li>
                                        <input type="radio" class="radio" value="1032" name="cft_FrpId"/>
                                        <div class="bank-info">
                                            <label>
                                                <img width="125" height="28" alt="北京银行" src="/upfile/css/i/BCCB-NET.png"/>
                                            </label>
                                        </div>
                                    </li>
                                </ul>
                                <% }%>
                            </div>
                            <div class="mpart fore1">
                                <%if (sysmodel.alipaymid != "")
                                  { %>
                                <div class="mp-t">
                                    <strong>支付宝支付</strong>
                                </div>
                                <ul class="bank-list">
                                    <li>
                                        <input id="Radio5" type="radio" style="float: left; position: relative; top: 10px;" name="paytype" value="alipay" />

                                        <div class="bank-info">
                                            <img width="125" height="28" src="/upfile/css/i/alipay.png" />
                                            <br />
                                            <br />
                                        </div>
                                    </li>
                                </ul>
                                <% }%>
                            </div>
                            <div class="mpart fore1">
                                <%if (sysmodel.yeepaymid != "" && _system["isybbank"] != null && _system["isybbank"].ToString() != "" && _system["isybbank"].ToString() == "0")
                                  { %>
                                <div class="mp-t">
                                    <strong>易宝支付</strong>

                                </div>
                                <ul class="bank-list">
                                    <li>
                                        <input id="Radio6" style="float: left; position: relative; top: 10px;" type="radio" name="paytype" value="yeepay" />

                                        <div class="bank-info">
                                            <img width="125" height="28" src="/upfile/css/i/yeepay.gif" />  </div>
                                    </li>

                                </ul>
                                <%}%>
                            </div>
                            <div class="mpart fore1">
                                <%if (sysmodel.tenpaymid != "" && _system["iscftbank"] != null && _system["iscftbank"].ToString() != "" && _system["iscftbank"].ToString() == "0")
                                  { %>
                                <div class="mp-t">
                                    <strong>财付通支付</strong>

                                </div>
                                <ul class="bank-list">
                                    <li>
                                        	 <input id="Radio7" style="float: left; position: relative; top: 10px;" type="radio" name="paytype" value="tenpay" {$ordercheck['tenpay']} />

                                        <div class="bank-info">
                                            <img width="125" height="28" src="/upfile/css/i/tenpay_1301.png" /></div>

                                    </li>
                                </ul>
                                <%}%>
                            </div>
                            <div class="mpart fore1">
                                <% if (sysmodel.chinabankmid != null && CookieUtils.GetCookieValue("alipay_token") == "" && sysmodel.chinabanksec != null && sysmodel.chinabankmid.Trim() != "" && sysmodel.chinabanksec.Trim() != "")
                                   {%>
                                <div class="mp-t">
                                    <strong>网银支付</strong>
                                </div>
                                <ul class="bank-list">
                                    <li>
                                        	<input id="Radio8" style="float: left; position: relative; top: 10px;" type="radio" name="paytype" value="chinabank" {$ordercheck['chinabank']} />

                                        <div class="bank-info">
                                            <img width="125" height="28" src="/upfile/css/i/chinabank.gif" /></div>

                                    </li>

                                </ul>
                                <% }%>
                            </div>
                            <div class="mpart fore1">
                                <% if (sysmodel.paypalmid != null && sysmodel.paypalmid.Trim() != "")
                                   {%>
                                <div class="mp-t">
                                    <strong>PayPal贝宝支付</strong>

                                </div>
                                <ul class="bank-list">
                                    <li>
                                        	<input id="Radio9" style="float: left; position: relative; top: 10px;" type="radio" name="paytype" value="paypal" {$ordercheck['paypal']} />

                                        <div class="bank-info">
                                            <img width="125" height="28" src="/upfile/css/i/paypal.gif" /></div>

                                    </li>

                                </ul>
                                <% }%>
                            </div>
                            <% if (_system["allinpaymid"] != "")
                               {%>
                            <% }%>
                            <%--2.28货到付款开始--%>
                            <% if ((ordermodel.Service == "cashondelivery" || show == true) && ordermodel.Express == "Y")
                               { %>
                            <div class="bank_way">
                                <div class="mp-t">
                                     <strong>货到付款</strong>
                                </div>
                                 <ul class="bank-list">
                                <li>
                                    <input id="Radio10" type="radio" style="float: left; position: relative; top: 10px;"  name="paytype" value="cashondelivery" />
                                       <div class="bank-info">
                                      <img width="125" height="28" src="/upfile/css/i/cash.gif" />
                                    </div>
                                </li>
                                     </ul>
                            </div>
                            <%} %>
                             <%if (user.Money > ordermodel.Origin)
                               { %>
                             <div class="bank_way">
                                <div class="mp-t">
                                     <strong>使用余额全额支付</strong>
                                </div>
                                 <ul class="bank-list">
                                <li>
                                    <input id="Radio1" type="radio" style="float: left; position: relative; top: 10px;"  name="paytype" value="credit" />
                                       <div class="bank-info">
                                      <img width="125" height="28" src="/upfile/css/i/balance-pay.gif" />
                                    </div>
                                </li>
                                 </ul>
                            </div>
                            <%} %>
                            <div class="btns">
                                <p class="check-act">
                                    <input type="submit" id="btnadd" value="确认订单，付款" class="btn-surepay" name="btnadd" group="a" />
                                </p>
                            </div>
                             <%if (user.Money < ordermodel.Origin)
                               {%>
                            <br />
                            <p style="color: Red;">友情提示：由于支付宝或网银通知消息可能会有延迟,如果您已经支付过该订单,请不要再修改订单或付款. 稍后更新订单状态! </p>
                            <%}%>
                        </div>
                    </div>
                </div>
            </div>
        </form>
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
