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
<%@ Import Namespace="System.IO" %>

<script runat="server">
    
    public NameValueCollection _system = new NameValueCollection();
    public IUser usermodel = null;
    public ISystem sysmodel = null;
    public string pd_FrpId = "";
    public string paytype = "";
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Form.Action = GetUrl("支付方式", "credit_charge.aspx");
        _system = WebUtils.GetSystem();
        NeedLogin();

        GetFee();

        if (Request.Form["pay"] == "确定，去付款")
        {
            if (Request["pd_FrpId"] != null && _system["isybbank"] == "1") //如果用户选择了某个银行那么，支付网关就是选中的银行
            {
                pd_FrpId = Request["pd_FrpId"].ToString();
                paytype = "yeepay";
            }
            else if (Request["paytype"] != null)
            {
                paytype = Request["paytype"].ToString();
            }
            else if (Request["cft_FrpId"] != null && _system["iscftbank"] == "1")
            {
                paytype = "tenpay";
                pd_FrpId = Request["cft_FrpId"].ToString();
            }
            else if (Request["paypal"] != null) //paypal支付
            {
                paytype = Request["paypal"].ToString();
            }
            else
            {
                paytype = ""; //用户没有选择支付网关，默认为支付宝
            }

            if (paytype == "")
            {
                SetError("友情提示：请选择支付方式");
            }
            else
            {
                Response.Redirect(GetUrl("个人中心账户充值", "order_charge.aspx?pd_FrpId=" + pd_FrpId + "&paytype=" + paytype + "&fee=" + Request["money"].ToString() + "&orderid=" + orderid(usermodel.Id.ToString())));
            }
        }

    }

    #region 根据用户名，查询用户账号余额
    public void GetFee()
    {
        
        UserFilter userft = new UserFilter();
        userft.Username = CookieUtils.GetCookieValue("username", AS.Common.Utils.FileUtils.GetKey());
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            usermodel = session.Users.GetByName(userft);
            sysmodel = session.System.GetByID(1);
        }
    }
    #endregion

    #region 生成充值的订单号
    public static string orderid(string userid)
    {
        return "0as" + userid + "as0as" + DateTime.Now.ToString("hhmmss");
    }
    #endregion
    
</script>

<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
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
<form id="form1" runat="server">
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="account-charge">
            <div id="content">
                <div class="box">
                    <div class="box-content">
                        <div class="head">
                            <h2>
                                充值</h2>
                        </div>
                        <div class="sect">
                            <div class="charge">
                                <p>
                                    请输入充值金额：</p>
                                <p class="number">
                                    <input type="text" maxlength="6" class="f-text" name="money" group="a" require="true"
                                        datatype="money" value='' />
                                    元 （不支持小数，最低 1 元）
                                </p>
                                <p id="account-charge-tip" class="tip" style="visibility: hidden;">
                                </p>
                                <div class="choose">
                                    <p class="choose-pay-way">
                                        请选择支付方式：</p>
                                    <ul class="typelist">
                                        <div class="bank_way">
                                            <%if (sysmodel != null)
                                              { %>
                                            <%if (sysmodel.yeepaymid != "" && CookieUtils.GetCookieValue("alipay_token") == "")
                                              { %>
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
                                                            <input type="radio" name="pd_FrpId" title="工商银行" value="ICBC-NET">
                                                            <label title="工商银行" class="ICBC-NET">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="建设银行" value="CCB-NET">
                                                            <label class="CCB-NET" title="建设银行">
                                                            </label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="中国农业银行" value="ABC-NET">
                                                            <label class="ABC-NET" title="中国农业银行">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="北京银行" value="BCCB-NET">
                                                            <label class="BCCB-NET" title="北京银行">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="交通银行" value="BOCO-NET">
                                                            <label class="BOCO-NET" title="交通银行">
                                                            </label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="兴业银行" value="CIB-NET">
                                                            <label class="CIB-NET" title="兴业银行">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="南京银行" value="NJCB-NET">
                                                            <label class="NJCB-NET" title="南京银行">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="中国民生银行" value="CMBC-NET">
                                                            <label class="CMBC-NET" title="中国民生银行">
                                                            </label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="光大银行" value="CEB-NET">
                                                            <label class="CEB-NET" title="光大银行">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="中国银行" value="BOC-NET">
                                                            <label class="BOC-NET" title="中国银行">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="平安银行" value="PAB-NET">
                                                            <label class="PAB-NET" title="平安银行">
                                                            </label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="渤海银行" value="CBHB-NET">
                                                            <label class="CBHB-NET" title="渤海银行">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" value="HKBEA-NET" title="东亚银行">
                                                            <label class="HKBEA-NET" title="东亚银行">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="宁波银行" value="NBCB-NET">
                                                            <label class="NBCB-NET" title="宁波银行">
                                                            </label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="中信银行" value="ECITIC-NET">
                                                            <label class="ECITIC-NET" title="中信银行">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="深圳发展银行" value="SDB-NET">
                                                            <label class="SDB-NET" title="深圳发展银行">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="广东发展银行" value="GDB-NET">
                                                            <label class="GDB-NET" title="广东发展银行">
                                                            </label>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="上海浦东发展银行" value="SPDB-NET">
                                                            <label class="SPDB-NET" title="上海浦东发展银行">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" value="POST-NET" title="中国邮政">
                                                            <label class="POST-NET" title="中国邮政">
                                                            </label>
                                                        </td>
                                                        <td>
                                                            <input type="radio" name="pd_FrpId" title="北京农村商业银行" value="BJRCB-NET">
                                                            <label class="BJRCB-NET" title="北京农村商业银行">
                                                            </label>
                                                        </td>
                                                    </tr>
                                                    <!--新增-->
                                                </table>
                                            </li>
                                        </div>
                                        <% }%>
                                     <%if (sysmodel.tenpaymid != "" && _system["iscftbank"] != null && _system["iscftbank"].ToString() != "" && _system["iscftbank"].ToString() == "1")
                                  { %>
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
                                                    <input type="radio" name="cft_FrpId" title="兴业银行" value="1009T"><label class="CIB-NET"
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
                                                    <input type="radio" name="cft_FrpId" value="1033" title="网汇通"><label class="WHT-NET"
                                                        title="网汇通"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" value="1028" title="中国邮政"><label class="POST-NET"
                                                        title="中国邮政"></label>
                                                </td>
                                                <%--  <td>
                                                            <input type="radio" name="pd_FrpId" title="宁波银行" value="NBCB-NET"><label class="NBCB-NET"
                                                                title="宁波银行"></label>
                                                        </td>--%>
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
                                                    <input type="radio" name="cft_FrpId" title="广东发展银行" value="1028"><label class="GDB-NET"
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
                                                <p class="choose-pay-type">
                                                    支付宝支付</p>
                                            </div>
                                            <li>
                                                <input id="check-alipay" type="radio" name="paytype" value="alipay" /><label for="check-alipay"
                                                    class="biglabel alipay">支付宝交易，推荐淘宝用户使用</label></li>
                                        </div>
                                        <% }%>
                                        <%if (sysmodel.tenpaymid != "" && _system["iscftbank"] != null && _system["iscftbank"].ToString() != "" && _system["iscftbank"].ToString() == "0")
                                          { %>
                                        <div class="bank_way">
                                            <div class="bank_buy">
                                                <p class="choose-pay-type">
                                                    财付通支付</p>
                                            </div>
                                            <li>
                                                <input id="check-tenpay" type="radio" name="paytype" value="tenpay" />
                                                <label for="check-tenpay" class="biglabel tenpay">
                                                    财付通交易，推荐QQ用户使用</label>
                                            </li>
                                        </div>
                                        <% }%>
                                        <% if (sysmodel.chinabankmid != "" && CookieUtils.GetCookieValue("alipay_token") == "")
                                           {%>
                                        <div class="bank_way">
                                            <div class="bank_buy">
                                                <p class="choose-pay-type">
                                                    网银支付</p>
                                            </div>
                                            <li>
                                                <input id="check-chinabank" type="radio" name="paytype" value="chinabank" /><label
                                                    for="check-chinabank" class="biglabel chinabank">支持招商、工行、建行、中行等主流银行的网银支付</label></li>
                                        </div>
                                        <% }%>
                                        <%if (sysmodel.paypalmid != "" && CookieUtils.GetCookieValue("alipay_token") == "")
                                          { %>
                                        <div class="bank_way">
                                            <div class="bank_buy">
                                                <p class="choose-pay-type">
                                                    PayPal贝宝支付</p>
                                            </div>
                                            <li>
                                                <input id="check-paypal" type="radio" name="paytype" value="paypal" /><label for="check-paypal"
                                                    class="biglabel paypal">贝宝交易,支持招商、工行、建行、农行等银行（仅支持人民币）</label></li>
                                        </div>
                                        <% }%>
                                        <% }%>
                                        </li>
                                    </ul>
                                </div>
                                <div class="clear">
                                </div>
                                <p class="commit">
                                    <input type="submit" value="确定，去付款" class="formbutton validator" name="pay" group="a" />
                                </p>
                                <br />
                                <p style="color: Red;">
                                    友情提示：由于支付宝或网银通知消息可能会有延迟,如果您已经支付过该订单,请不要再修改订单或付款. 稍后更新订单状态!
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- bd end -->
</div>
</form>
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %>  