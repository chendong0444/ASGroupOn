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
    public decimal inputmoney = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        sysmodel = PageValue.CurrentSystem;
        _system = PageValue.CurrentSystemConfig;
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
        form.Action = GetUrl("选择银行", "shopcart_service.aspx?orderid=" + Helper.GetInt(Request["orderid"], 0));
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
                SetError("友情提示：无法操作其他用户的订单");
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
                    SetError("友情提示：请您选择支付方式");
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
                                    SetError("友情提示：您输入的金额超出订单金额,请您重新输入");
                                }
                                if (inputmoney > usermodel.Money)
                                {
                                    SetError("友情提示：您输入的金额超出您的帐户余额,请您重新输入");
                                }
                                Response.Redirect(GetUrl("选择银行", "shopcart_service.aspx?orderid=" + Helper.GetInt(Request["orderid"], 0)));
                                Response.End();
                            }
                        }
                    }
                    else
                    {
                        inputmoney = 0; 
                    }
                    //修改订单的支付网关,同时生成交易单号
                    OrderMethod.Updatebyservice(ordermodel.Id, service, OrderMethod.Getorder(ordermodel.User_id, ordermodel.Team_id, ordermodel.Id), ordermodel.Origin);
                    Response.Redirect(GetUrl("银行支付", "order_pay.aspx?orderid=" + ordermodel.Id + "&pd_FrpId=" + Request["pd_FrpId"] + "&cft_FrpId=" + Request["cft_FrpId"] + "&fare=" + fare + "&p=" + inputmoney));
                }
            }
        }
        else
        {
            SetError("订单不存在");
            return;
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
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="form" runat="server">
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
    <asp:hiddenfield id="hiorderid" runat="server" />
    <input type="hidden" name="county" id="county">
    <div id="bdw" class="bdw">
        <%if (ordermodel != null)
          { %>
        <div id="bd" class="cf">
            <div id="account-charge">
                <div id="deal-buy" class="box">
                    <input type="hidden" name="totalNumber" value="" />
                    <div class="box-content">
                        <img <%=ashelper.getimgsrc(ImagePath()+"step2.png") %> class="dynload" width="660" height="69" />
                        <div class="head">
                            <h2>您的订单</h2>
                        </div>
                        <div class="sect">
                            <table width="1451" height="139" class="order-table">
                                <tr style="background: #EFF8FF repeat-x;">
                                    <th class="deal-buy-desc">项目名称</th>
                                    <th class="deal-buy-quantity">数量</th>
                                    <th class="deal-buy-multi"></th>
                                    <th class="deal-buy-price">价格</th>
                                    <th class="deal-buy-price"></th>
                                    <th class="deal-buy-total">总价</th>
                                </tr>
                                <%  int num = 0; %>
                                <%foreach (var model in detaillist)
                                  { %>
                                <tr>
                                    <td class="deal-buy-desc"><%=GetTeam(model.Teamid.ToString())%><font style="color: red"><%=WebUtils.Getbulletin(model.result)%></font></td>
                                    <td t="totalnum" tid="<%=model.Teamid %>" class="deal-buy-quantity"><%=model.Num%></td>
                                    <td class="deal-buy-multi">x</td>
                                    <td class="deal-buy-price" id="deal-buy-price"><span class="money"><span><%=ASSystem.currency%><%=model.Teamprice%></td>
                                    <td class="deal-buy-price">=</td>
                                    <td class="deal-buy-total" id="deal-buy-total" total="teamprice"><%=ASSystem.currency%><%=Convert.ToDecimal(model.Num*model.Teamprice-model.Credit)%></td>
                                </tr>
                                <% }%>
                                <tr>
                                    <td class="deal-buy-desc">快递</td>
                                    <td class="deal-buy-quantity"></td>
                                    <td class="deal-buy-multi"></td>
                                    <td class="deal-buy-price"><span id="deal-express-price" total="fareprice">
                                        <%=ASSystem.currency%><%=fare%>
                                    </span></td>
                                    <td class="deal-buy-price"></td>
                                    <td class="deal-buy-total"><span class="money"></span><span id="deal-express-total"></td>
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
                                        <span id="Span1" total="fareprice">
                                            <%=ASSystem.currency%>-<%=(ordermodel.disamount) %>
                                        </span>
                                    </td>
                                    <td></td>
                                    <td class="deal-buy-total">
                                        <span class="money"></span><span id="Span2"></span>
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
                            </table>
                            <div class="paytype">
                            <%if (ordermodel.State == "unpay")
                                  {%>
                            </div>
                            <div class="order-check-form ">
                                <div class="order-pay-credit">
                                    <h3>您的余额</h3>
                                    <p>
                                        账户余额：<strong><span class="money"></span><%=ASSystem.currency%><%=user.Money%></strong>
                                        <%if (ordermodel.Origin>user.Money)
                                          { %>
                         ,您的余额不够完成本次付款，还需支付 <strong><span class="money"></span><%=ASSystem.currency%><%=OrderMethod.Getyumoney(user.Money, ordermodel.Origin)%> </strong>。
                        
                        <%}
                          %>
                                        <%if (user.Money>0)
                                          {%>
                                        使用账户余额支付
                                              <input id="inputmoney" name="inputmoney" type="text" value="<%=Helper.GetDecimal(Request["inputmoney"],0)%>" style="width:50px" /> 
                                          <% } %>
                        
                                    </p>
                                    <div class="other_pay"></div>
                                </div>
                                <ul class="typelist">
                                    <%if (sysmodel != null)
                                      { %>
                                    <%if (sysmodel.yeepaymid != "" && CookieUtils.GetCookieValue("alipay_token") == "" && _system["isybbank"] != null && _system["isybbank"].ToString() != "" && _system["isybbank"].ToString() == "1")
                                      {%>
                                    <div class="bank_way" id="ybbankdiv">
                                        <div class="bank_buy">
                                            <p class="choose-pay-type">易宝支付</p>
                                        </div>
                                        <li>
                                            <input type="hidden" id="ybbank" value="<%=_system["isybbank"]%>" />
                                            <table class="banktable" id="order-check-banktable">
                                                <tr>
                                                    <td>

                                                        <input type="radio" name="pd_FrpId" id="abc" title="招商银行" value="CMBCHINA-NET">
                                                        <label class="CMBCHINA-NET" title="招商银行"></label>
                                                    </td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="工商银行" value="ICBC-NET"><label title="工商银行" class="ICBC-NET"></label></td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="建设银行" value="CCB-NET"><label class="CCB-NET" title="建设银行"></label></td>
                                                </tr>

                                                <tr>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="中国农业银行" value="ABC-NET"><label class="ABC-NET" title="中国农业银行"></label></td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="北京银行" value="BCCB-NET"><label class="BCCB-NET" title="北京银行"></label></td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="交通银行" value="BOCO-NET"><label class="BOCO-NET" title="交通银行"></label></td>
                                                </tr>

                                                <tr>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="兴业银行" value="CIB-NET"><label class="CIB-NET" title="兴业银行"></label></td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="南京银行" value="NJCB-NET"><label class="NJCB-NET" title="南京银行"></label></td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="中国民生银行" value="CMBC-NET"><label class="CMBC-NET" title="中国民生银行"></label></td>
                                                </tr>

                                                <tr>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="光大银行" value="CEB-NET"><label class="CEB-NET" title="光大银行"></label></td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="中国银行" value="BOC-NET"><label class="BOC-NET" title="中国银行"></label></td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="平安银行" value="PAB-NET"><label class="PAB-NET" title="平安银行"></label></td>
                                                </tr>

                                                <tr>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="渤海银行" value="CBHB-NET"><label class="CBHB-NET" title="渤海银行"></label></td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" value="HKBEA-NET" title="东亚银行"><label class="HKBEA-NET" title="东亚银行"></label></td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="宁波银行" value="NBCB-NET"><label class="NBCB-NET" title="宁波银行"></label></td>
                                                </tr>

                                                <tr>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="中信银行" value="ECITIC-NET"><label class="ECITIC-NET" title="中信银行"></label></td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="深圳发展银行" value="SDB-NET"><label class="SDB-NET" title="深圳发展银行"></label></td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="广东发展银行" value="GDB-NET"><label class="GDB-NET" title="广东发展银行"></label></td>
                                                </tr>

                                                <tr>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="上海浦东发展银行" value="SPDB-NET"><label class="SPDB-NET" title="上海浦东发展银行"></label></td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" value="POST-NET" title="中国邮政"><label class="POST-NET" title="中国邮政"></label></td>
                                                    <td>
                                                        <input type="radio" name="pd_FrpId" title="北京农村商业银行" value="BJRCB-NET"><label class="BJRCB-NET" title="北京农村商业银行"></label></td>
                                                </tr>
                                            </table>
                                        </li>
                                    </div>
                                    <% }%>
                                    <%if (sysmodel.tenpaymid != "" && _system["iscftbank"] != null && _system["iscftbank"].ToString() != "" && _system["iscftbank"].ToString() == "1")
                                      {%>
                                    <div class="bank_way" id="cftbankdiv">
                                        <div class="bank_buy">
                                            <p class="choose-pay-type">
                                                财付通支付
                                            </p>
                                        </div>
                                        <li>
                                            <input type="hidden" id="cftbank" value="<%=_system["iscftbank"]%>" />
                                            <table class="banktable" id="CFT">
                                                <tr>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" id="zs" title="招商银行" value="1001">
                                                        <label class="CMBCHINA-NET" title="招商银行">
                                                        </label>
                                                    </td>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="工商银行" value="1002"><label title="工商银行"
                                                            class="ICBC-NET"></label>
                                                    </td>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="建设银行" value="1003"><label class="CCB-NET"
                                                            title="建设银行"></label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="中国农业银行" value="1005"><label class="ABC-NET"
                                                            title="中国农业银行"></label>
                                                    </td>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="上海浦东发展银行" value="1004"><label class="SPDB-NET"
                                                            title="上海浦东发展银行"></label>
                                                    </td>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="北京银行" value="1032"><label class="BCCB-NET"
                                                            title="北京银行"></label>
                                                    </td>

                                                </tr>
                                                <tr>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="兴业银行" value="1009"><label class="CIB-NET"
                                                            title="兴业银行"></label>
                                                    </td>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="上海银行" value="1024"><label class="SHCB-NET"
                                                            title="上海银行"></label>
                                                    </td>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="中国民生银行" value="1006"><label class="CMBC-NET"
                                                            title="中国民生银行"></label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="光大银行" value="1022"><label class="CEB-NET"
                                                            title="光大银行"></label>
                                                    </td>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="中国银行" value="1052"><label class="BOC-NET"
                                                            title="中国银行"></label>
                                                    </td>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="平安银行" value="1010"><label class="PAB-NET"
                                                            title="平安银行"></label>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="华夏银行" value="1025"><label class="HXHB-NET"
                                                            title="华夏银行"></label>
                                                    </td>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="网汇通" value="1033"><label class="WHT-NET"
                                                            title="网汇通"></label>
                                                    </td>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="中国邮政" value="1028"><label class="POST-NET"
                                                            title="中国邮政"></label>
                                                    </td>

                                                </tr>
                                                <tr>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="中信银行" value="1021"><label class="ECITIC-NET"
                                                            title="中信银行"></label>
                                                    </td>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="深圳发展银行" value="1008"><label class="SDB-NET"
                                                            title="深圳发展银行"></label>
                                                    </td>
                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="广东发展银行" value="1027"><label class="GDB-NET"
                                                            title="广东发展银行"></label>
                                                    </td>
                                                </tr>
                                                <tr>

                                                    <td>
                                                        <input type="radio" name="cft_FrpId" title="交通银行" value="1020"><label class="BOCO-NET"
                                                            title="交通银行"></label>
                                                    </td>

                                                </tr>

                                            </table>
                                        </li>
                                    </div>
                                    <% }%>
                                    <%if (sysmodel.alipaymid != "")
                                      { %>
                                    <div class="bank_way">
                                        <div class="bank_buy">
                                            <p class="choose-pay-type">支付宝支付</p>
                                        </div>
                                        <li>
                                            <input id="check-alipay" type="radio" name="paytype" value="alipay" /><label for="check-alipay" class="biglabel alipay">支付宝交易，推荐淘宝用户使用</label>
                                            <br />
                                            <br />

                                        </li>
                                    </div>
                                    <% }%>
                                    <%if (sysmodel.yeepaymid != "" && _system["isybbank"] != null && _system["isybbank"].ToString() != "" && _system["isybbank"].ToString()=="0")
                                      { %>
                                    <div class="bank_way" id="ybzfdiv">
                                        <div class="bank_buy">
                                            <p class="choose-pay-type">
                                                易宝支付
                                            </p>
                                        </div>
                                        <li>
                                            <input id="ybzhf-yeepay" type="radio" name="paytype" value="yeepay" /><label for="ybzhf-yeepay"
                                                class="biglabel yeepay">易宝交易，支持招商、工行、建行、中行等主流银行</label></li>
                                    </div>
                                    <%}%>
                                     <%if (sysmodel.tenpaymid != "" && _system["iscftbank"] != null && _system["iscftbank"].ToString() != "" && _system["iscftbank"].ToString() == "0")
                                      { %>
                                    <div class="bank_way" id="cfttlbankdiv">
                                        <div class="bank_buy">
                                            <p class="choose-pay-type">财付通支付</p>
                                        </div>
                                        <li><input id="check-tenpay" type="radio" name="paytype" value="tenpay" {$ordercheck['tenpay']} /><label for="check-tenpay" class="biglabel tenpay">财付通交易，推荐拍拍用户使用</label></li>
                                    </div>
                                    <%}%>
                                    <% if (sysmodel.chinabankmid != null && CookieUtils.GetCookieValue("alipay_token") == "" && sysmodel.chinabanksec != null && sysmodel.chinabankmid.Trim() != "" && sysmodel.chinabanksec.Trim() != "")
                                       {%>
                                    <div class="bank_way">
                                        <div class="bank_buy">
                                            <p class="choose-pay-type">网银支付</p>
                                        </div>
                                        						<li><input id="check-chinabank" type="radio" name="paytype" value="chinabank" {$ordercheck['chinabank']} /><label for="check-chinabank" class="biglabel chinabank">网银支付交易，支持招商、工行、建行、中行等主流银行</label></li>
                                    </div>
                                    <% }%>
                                    <% if (sysmodel.paypalmid != null && sysmodel.paypalmid.Trim() != "")
                                       {%>
                                            <div class="bank_way">
    <div class="bank_buy">
                            <p class="choose-pay-type">PayPal贝宝支付</p></div>
	<li><input id="check-paypal" type="radio" name="paytype" value="paypal" {$ordercheck['paypal']} /><label for="check-paypal" class="biglabel paypal">贝宝交易,支持招商、工行、建行、农行等银行（仅支持人民币）</label></li>
    </div>

                                    <% }%>
                                    <%--2.28货到付款开始--%>
                                    <% if ((ordermodel.Service == "cashondelivery" || show == true) && ordermodel.Express == "Y")
                                       { %>
                                    <div class="bank_way">
                                        <div class="bank_buy">
                                            <p class="choose-pay-type">
                                                货到付款
                                            </p>
                                        </div>
                                        <li>
                                            <input id="check-cashondelivery" type="radio" name="paytype" value="cashondelivery" />
                                            <label for="check-tenpay" class="biglabel cash"></label>
                                        </li>
                                    </div>
                                    <%} %>
                                    <%--2.28货到付款结束--%>
                                      <%if (user.Money > ordermodel.Origin)
                                          { %>
                                     <div class="bank_way">
                                        <div class="bank_buy">
                                            <p class="choose-pay-type">
                                                使用余额全额支付
                                            </p>
                                        </div>
                                        <li>
                                            <input id="Radio1" type="radio" name="paytype"  value="credit" /> 
                                              <img height="39" src="/upfile/css/i/balance-pay.gif" />
                                        </li>
                                    </div>
                                   <%}%>
                                </ul>
                                <% }%>
                                <div class="clear"></div>
                                <p class="check-act">
                                    <input type="submit" value="确认订单，付款" class="formbutton validator" id="btnadd" name="btnadd" group="a" />

                                </p>
                                <%if (user.Money < ordermodel.Origin)
                                      {%>
                                <br />
                                <p style="color: Red;">友情提示：由于支付宝或网银通知消息可能会有延迟,如果您已经支付过该订单,请不要再修改订单或付款. 稍后更新订单状态! </p>
                                <%} %>
                            </div>
                            <% }%>
                        </div>
                    </div>
                </div>
            </div>
            <div id="sidebar">
            </div>
            <% }%>
        </div>
    </div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>