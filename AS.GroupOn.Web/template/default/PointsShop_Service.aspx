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
    public int totalpoint = 0;//总积分
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (CookieUtils.GetCookieValue("alipay_token") != "" && (CookieUtils.GetCookieValue("address") == null || CookieUtils.GetCookieValue("address") == ""))
        {
            SetRefer();
            Response.Redirect(WebRoot + "oauth/alipay/receiveAddress.aspx");
        }
        sysmodel = PageValue.CurrentSystem;
        _system = PageValue.CurrentSystemConfig;
        if (_system["payselectexpress"] == "1")
        {
            payselectexpress = true;
        }
        NeedLogin();
        using (IDataSession session=Store.OpenSession(false))
        {
            ordermodel = session.Orders.GetByID(Helper.GetInt(Request["orderid"], 0));
        }
        form.Action = GetUrl("积分确认", "PointsShop_Service.aspx?orderid=" + Helper.GetInt(Request["orderid"], 0));
        hiorderid.Value = Request["orderid"];
        if (ordermodel == null || ordermodel.User_id != AsUser.Id)
        {
            SetError("不存在此订单");
            Response.Redirect(WebRoot + "index.aspx");
            Response.End();
            return;
        }
        else
        {
            user = ordermodel.User;
            totalpoint = ordermodel.totalscore;
            totalprice = ordermodel.Origin;
            fare = ordermodel.Fare; 
        }
        if (Request.Form["btnadd"] == "确认订单，付款")
        {
            CookieUtils.ClearCar();//清除积分的cookie
            ConfirmOrder();
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

    public void ConfirmOrder()
    {
        IOrder ordermodel = null;
        IUser usermodel = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            ordermodel = session.Orders.GetByID(Helper.GetInt(hiorderid.Value, 0));
        }
        if (ordermodel != null)
        {
            usermodel = ordermodel.User;
            if (usermodel.userscore < ordermodel.totalscore)
            {
                SetError("友情提示：您的积分无法支付订单");
            }
            else
            {
                if (usermodel.Money < ordermodel.Origin) //如果用户的余额无法支付费用，那么跳到支付页面，用户可以去自己选择的银行进行支付,支付网关默认为为账户余额
                {
                    if (Request["pd_FrpId"] != null) //如果用户选择了某个银行那么，支付网关就是选中的银行
                    {
                        service = "yeepay";
                    }
                    else if (Request["paytype"] != null)
                    {
                        service = Request["paytype"].ToString();
                    }
                    else
                    {
                        service = ""; //用户没有选择支付网关，默认为支付宝
                    }
                    if (service == "")
                    {
                        SetError("请您选择支付方式");
                    }
                    else
                    {
                        #region 修改订单的支付网关,同时生成交易单号
                        OrderMethod.Updatebyservice(ordermodel.Id, service, OrderMethod.Getorder(ordermodel.User_id, ordermodel.Team_id, ordermodel.Id), ordermodel.Origin);
                        #endregion
                        Response.Redirect(GetUrl("银行支付", "order_pay.aspx?orderid=" + ordermodel.Id + "&pd_FrpId=" + Request["pd_FrpId"]+ ""));
                    }
                }
                else
                {
                   service = "credit";
                    OrderMethod.Updatebyservice(ordermodel.Id, service, OrderMethod.Getorder(ordermodel.User_id, ordermodel.Team_id, ordermodel.Id), ordermodel.Origin);
                   
                    Response.Redirect(GetUrl("银行支付", "order_pay.aspx?orderid=" + ordermodel.Id + "&pd_FrpId=" + Request["pd_FrpId"] + ""));
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
            });
            jQuery("input[name='paytype']").click(function () {

                jQuery("input[name='pd_FrpId']").attr("checked", false);
            });
        })
    </script>
        <asp:HiddenField ID="hiorderid" runat="server" />
        <input type="hidden" name="county" id="county">
        <div id="bdw" class="bdw">
            <%if (ordermodel != null)
              { %>
            <div id="bd" class="cf">
                <div id="account-charge">
                    <div id="deal-buy" class="box">
                        <input type="hidden" name="totalNumber" value="" />
                        <div class="box-content">
                            <img src="<%=ImagePath()%>step2.png" width="660" height="69" />
                            <div class="head">
                                <h2>
                                    您的订单</h2>
                            </div>
                            <div class="sect">
                                <table class="order-table">
                                    <tr>
                                        <th class="deal-buy-desc">
                                            项目名称
                                        </th>
                                        <th class="deal-buy-quantity">
                                            数量
                                        </th>
                                        <th class="deal-buy-multi">
                                        </th>
                                        <th class="deal-buy-price">
                                            积分
                                        </th>
                                        <th class="deal-buy-price">
                                        </th>
                                        <th class="deal-buy-total">
                                            总积分
                                        </th>
                                    </tr>
                                    <% detaillist = ordermodel.OrderDetail; %>
                                    <%  int num = 0; %>
                                    <%foreach (var model in detaillist)
                                      { %>
                                    <tr>
                                        <td class="deal-buy-desc">
                                            <%= GetTeam(model.Teamid.ToString())%><font style="color: red"><%=WebUtils.Getbulletin(model.result)%></font>
                                        </td>
                                        <td t="totalnum" tid="<%=model.Teamid %>" class="deal-buy-quantity">
                                            <%=model.Num%>
                                        </td>
                                        <td class="deal-buy-multi">
                                            x
                                        </td>
                                        <td class="deal-buy-price" id="deal-buy-price">
                                            <span class="money"><span>
                                                <%=model.totalscore%>积分
                                        </td>
                                        <td class="deal-buy-price">
                                            =
                                        </td>
                                        <td class="deal-buy-total" id="deal-buy-total" total="teamprice">
                                            <%=Math.Max(Convert.ToDecimal(model.Num*model.totalscore-model.Credit),0)%>积分
                                        </td>
                                    </tr>
                                    <% }%>
                                    <tr>
                                        <td class="deal-buy-desc">
                                            快递
                                        </td>
                                        <td class="deal-buy-quantity">
                                        </td>
                                        <td class="deal-buy-multi">
                                        </td>
                                        <td class="deal-buy-price">
                                            <span id="deal-express-price" total="fareprice">
                                                <%=ASSystem.currency%><%=fare%>
                                            </span>
                                        </td>
                                        <td class="deal-buy-equal">
                                        </td>
                                        <td class="deal-buy-total">
                                            <span class="money"></span><span id="deal-express-total">
                                        </td>
                                    </tr>
                                    <tr class="order-total">
                                        <td class="deal-buy-desc">
                                            <strong>应付总积分：</strong>
                                        </td>
                                        <td class="deal-buy-quantity">
                                        </td>
                                        <td class="deal-buy-multi">
                                        </td>
                                        <td class="deal-buy-price">
                                        </td>
                                        <td class="deal-buy-price">
                                            =
                                        </td>
                                        <td class="deal-buy-total" total="totalprice">
                                            <%=totalpoint%>积分
                                        </td>
                                    </tr>
                                    <tr class="order-total">
                                        <td class="deal-buy-desc">
                                            <strong>应付总额：</strong>
                                        </td>
                                        <td class="deal-buy-quantity">
                                        </td>
                                        <td class="deal-buy-multi">
                                        </td>
                                        <td class="deal-buy-price">
                                        </td>
                                        <td class="deal-buy-price">
                                            =
                                        </td>
                                        <td class="deal-buy-total" total="totalprice">
                                            <%=ASSystem.currency%><%=totalprice %>
                                        </td>
                                    </tr>
                                </table>
                                <div class="paytype">
                                    <%if (ordermodel.State == "scoreunpay")
                                      {%>
                                </div>
                                <div class="order-check-form ">
                                    <div class="order-pay-credit">
                                        <h3>
                                            您的余额</h3>
                                        <p>
                                            账户余额：<strong><span class="money"></span><%=ASSystem.currency%><%=user.Money%></strong>
                                            <%if (user.Money < ordermodel.Origin)
                                              { %>
                                            您的余额不够完成本次付款，还需支付 <strong><span class="money"></span>
                                                <%=ASSystem.currency%><%=OrderMethod.Getyumoney(user.Money, ordermodel.Origin)%>
                                            </strong>。
                                            <%}
                                              else
                                              {%>
                                        </p>
                                        <% }%>
                                        <div class="other_pay">
                                        </div>
                                    </div>
                                    <div class="order-pay-credit">
                                        <h3>
                                            您的积分</h3>
                                        <p>
                                            用户积分：<strong><span class="money"></span><%=user.userscore%>积分</strong>
                                            <%if (user.userscore < ordermodel.totalscore)
                                              { %>
                                            <%}
                                              else
                                              {%>
                                        </p>
                                        <% }%>
                                        <div class="other_pay">
                                        </div>
                                    </div>
                                    <%if (user.Money < ordermodel.Origin)
                                      { %>
                                    <ul class="typelist">
                                        <%if (sysmodel != null)
                                          { %>
                                        <%if (sysmodel.yeepaymid != "" && CookieUtils.GetCookieValue("alipay_token") == "")
                                          { 
                     
                                        %>
                                        <div class="bank_way">
                                            <div class="bank_buy">
                                                <p class="choose-pay-type">
                                                    易宝支付</p>
                                            </div>
                                            <li>
                                                <table class="banktable" id="order-check-banktable">
                                                    <tr>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" id="abc" title="招商银行" value="CMBCHINA-NET">
                                                            <label class="CMBCHINA-NET" title="招商银行">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="工商银行" value="ICBC-NET"><label title="工商银行"
                                                                class="ICBC-NET"></label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="建设银行" value="CCB-NET"><label class="CCB-NET"
                                                                title="建设银行"></label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="中国农业银行" value="ABC-NET"><label class="ABC-NET"
                                                                title="中国农业银行"></label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="北京银行" value="BCCB-NET"><label class="BCCB-NET"
                                                                title="北京银行"></label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="交通银行" value="BOCO-NET"><label class="BOCO-NET"
                                                                title="交通银行"></label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="兴业银行" value="CIB-NET"><label class="CIB-NET"
                                                                title="兴业银行"></label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="南京银行" value="NJCB-NET"><label class="NJCB-NET"
                                                                title="南京银行"></label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="中国民生银行" value="CMBC-NET"><label class="CMBC-NET"
                                                                title="中国民生银行"></label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="光大银行" value="CEB-NET"><label class="CEB-NET"
                                                                title="光大银行"></label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="中国银行" value="BOC-NET"><label class="BOC-NET"
                                                                title="中国银行"></label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="平安银行" value="PAB-NET"><label class="PAB-NET"
                                                                title="平安银行"></label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="渤海银行" value="CBHB-NET"><label class="CBHB-NET"
                                                                title="渤海银行"></label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" value="HKBEA-NET" title="东亚银行"><label class="HKBEA-NET"
                                                                title="东亚银行"></label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="宁波银行" value="NBCB-NET"><label class="NBCB-NET"
                                                                title="宁波银行"></label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="中信银行" value="ECITIC-NET"><label class="ECITIC-NET"
                                                                title="中信银行"></label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="深圳发展银行" value="SDB-NET"><label class="SDB-NET"
                                                                title="深圳发展银行"></label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="广东发展银行" value="GDB-NET"><label class="GDB-NET"
                                                                title="广东发展银行"></label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="上海浦东发展银行" value="SPDB-NET"><label class="SPDB-NET"
                                                                title="上海浦东发展银行"></label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" value="POST-NET" title="中国邮政"><label class="POST-NET"
                                                                title="中国邮政"></label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="北京农村商业银行" value="BJRCB-NET"><label class="BJRCB-NET"
                                                                title="北京农村商业银行"></label>
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
                                                <p class="choose-pay-type">
                                                    支付宝支付</p>
                                            </div>
                                            <li>
                                                <input id="check-alipay" type="radio" name="paytype" value="alipay" /><label for="check-alipay"
                                                    class="biglabel alipay">支付宝交易，推荐淘宝用户使用</label>
                                                <br />
                                                <br />
                                            </li>
                                        </div>
                                        <% }%>
                                        <%if (sysmodel.tenpaymid != "" && CookieUtils.GetCookieValue("alipay_token") == "")
                                          { %>
                                        <div class="bank_way">
                                            <div class="bank_buy">
                                               <p class="choose-pay-type">财付通支付</p></div>
						                          <li><input id="check-tenpay" type="radio" name="paytype" value="tenpay" {$ordercheck['tenpay']} /><label for="check-tenpay" class="biglabel tenpay">财付通交易，推荐拍拍用户使用</label></li>
                                        </div>
				
                                       <%} %>
                                        <% if (sysmodel.chinabankmid != null && _system["Isalipaylogin"] != "1" && sysmodel.chinabanksec != null && sysmodel.chinabankmid.Trim() != "" && sysmodel.chinabanksec.Trim() != "")
                                           {%>
                                        <div class="bank_way">
                                            <div class="bank_buy">
                                                <p class="choose-pay-type">
                                                    网银支付</p>
                                            </div>
						                    <li><input id="check-chinabank" type="radio" name="paytype" value="chinabank" {$ordercheck['chinabank']} /><label for="check-chinabank" class="biglabel chinabank">网银支付交易，支持招商、工行、建行、中行等主流银行</label></li>
                                        </div>
	
                                        <% }%>

					                   </ul>

                                         <% }%>

                                         <% }%>
                                    <div class="clear">
                                    </div>
                                    <p class="check-act">
                                        <input type="submit" value="确认订单，付款" class="formbutton validator" name="btnadd" group="a" />
                                    </p>
                                    <%
                                          if (user.Money < ordermodel.Origin)
                                        {%>
                                    <br />
                                    <p style="color: Red;">
                                        友情提示：由于支付宝或网银通知消息可能会有延迟,如果您已经支付过该订单,请不要再修改订单或付款. 稍后更新订单状态!
                                    </p>
                                    <%}
                                    %>
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