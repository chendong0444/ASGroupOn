<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

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
    protected string alipay_sec = "";
    protected string alipay_mid = "";
    protected string alipay_acc = "";
    protected string yeepay_mid = "";
    protected string yeepay_sec = "";
    protected string chinabank_mid = "";
    protected string chinabank_sec = "";
    protected string tenpay_mid = "";
    protected string tenpay_sec = "";
    protected string bill_mid = "";
    protected string bill_sec = "";
    protected string paypal_mid = "";
    protected string paypal_sec = "";
    protected string allinpay_mid = "";
    protected string allinpay_sec = "";
    protected string alipay_dy = "";
    protected string fangshia = "";
    protected string fangshib = "";
    public WebUtils sysmodel = new WebUtils();
    protected ISystem system = Store.CreateSystem();
    public NameValueCollection _system = new NameValueCollection();
    public NameValueCollection _bank = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_PayMode))
        {
            SetError("你不具有查看支付的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (Request.HttpMethod == "POST")
        {
            setZhifu();
        }
        getZhifu();

    }
    private void setZhifu()
    {
        ISystem system = Store.CreateSystem();
        NameValueCollection values = new NameValueCollection();
        WebUtils systemmodel = new WebUtils();
        values.Add("alipay_SecuredTransactions", Request.Form["alipaytype"]);
        values.Add("alipay_anti_phishing", Request["alipay_anti_phishing"]);
        values.Add("alipay_Manual_SecuredTransactions", Request["alipay_Manual_SecuredTransactions"]);
        values.Add("autodeliver", autodeliver.SelectedIndex.ToString());
        values.Add("isybbank", Request.Form["isybbank"]);//易宝直连开关
        values.Add("is_Certify_Tenpay", Request.Form["ddltenpaytype"]);//财付通直连开关
        values.Add("iscftbank", Request.Form["iscftbank"]);//财付通直连开关
        systemmodel.CreateSystemByNameCollection(values);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(Helper.GetInt(Request.Form["id"], 1));
        }
        if (system != null)
        {
            system.alipayacc = Request.Form["alipay_acc"].ToString().Trim();
            system.alipaymid = Request.Form["alipay_mid"].ToString().Trim();
            system.alipaysec = Request.Form["alipay_sec"].ToString().Trim();
            system.yeepaymid = Request.Form["yeepay_mid"].ToString().Trim();
            system.yeepaysec = Request.Form["yeepay_sec"].ToString().Trim();
            system.chinabankmid = Request.Form["chinabank_mid"].ToString().Trim();
            system.chinabanksec = Request.Form["chinabank_sec"].ToString().Trim();
            system.tenpaymid = Request.Form["tenpay_mid"].ToString().Trim();
            system.tenpaysec = Request.Form["tenpay_sec"].ToString().Trim();
            system.paypalmid = Request.Form["paypal_mid"].ToString().Trim();
            system.paypalsec = Request.Form["paypal_sec"].ToString().Trim();
            system.id = Helper.GetInt(Request.Form["id"], 1);
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.System.Update(system);
            }
            if (i > 0) SetSuccess("更新成功！"); Response.Redirect("SheZhi_Zhifu.aspx");
        }
    }
    private void getZhifu()
    {
        NameValueCollection _system = new NameValueCollection();
        _system = WebUtils.GetSystem();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
        }
        alipay_mid = system.alipaymid;
        alipay_sec = system.alipaysec;
        alipay_acc = system.alipayacc;
        yeepay_mid = system.yeepaymid;
        yeepay_sec = system.yeepaysec;
        chinabank_mid = system.chinabankmid;
        chinabank_sec = system.chinabanksec;
        tenpay_mid = system.tenpaymid;
        tenpay_sec = system.tenpaysec;
        paypal_mid = system.paypalmid;
        paypal_sec = system.paypalsec;
        allinpay_mid = _system["allinpaymid"];
        allinpay_sec = _system["allinpaysec"];
        ddltenpaytype.Value = _system["is_Certify_Tenpay"];
        isybbank.Value = _system["isybbank"];
        if (_system["autodeliver"] == "1")//支付宝自动发货开关
            autodeliver.SelectedIndex = 1;
        if (_system["iscftbank"] == "1")
        {
            iscftbank.SelectedIndex = 1;
        }
        iscftbank.Value = _system["iscftbank"];

        //支付接口类型
        if (_system["alipay_SecuredTransactions"] == "1")
        {
            alipaytype.Value = "1";
        }
        else if (_system["alipay_SecuredTransactions"] == "2")
        {
            alipaytype.Value = "2";
        }
        else if (_system["alipay_SecuredTransactions"] == "0")
        {
            alipaytype.Value = "0";
        }
        if (!string.IsNullOrEmpty(_system["alipay_Manual_SecuredTransactions"]))
        {
            if (_system["alipay_Manual_SecuredTransactions"] == "1")
            {
                fangshia = "checked";
            }
            else
            {
                fangshib = "checked";
            }
        }
        if (!string.IsNullOrEmpty(_system["alipay_anti_phishing"]))
        {
            if (_system["alipay_anti_phishing"] == "1")
            {
                alipay_dy = "checked";
            }
        }
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="partner">
                    <div id="content" class="box-content clear mainwide">
                        <div class="clear box">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        支付方式</h2>
                                </div>
                                <div class="sect">
                                    <div class="wholetip clear">
                                        <h3>
                                            1、支付宝（没有的话，保留为空）</h3>
                                    </div>
                                    <div class="field">
                                        <input type="hidden" id="id" name="id" value="<%=system.id %>" />
                                        <label>
                                            支付接口类型</label>
                                        <select id="alipaytype" name="alipaytype" runat="server" onclick="select1(this)">
                                            <option value="0">即时到帐接口</option>
                                            <option value="1">担保交易接口</option>
                                            <option value="2">双功能接口</option>
                                        </select><span id="SPAN4" style="width: 200px; padding-top: 10px;"><a target="_blank"
                                            href="http://bizpartner.alipay.com/asdht/index.htm">点此签约开通支付宝</a></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            支付宝邮箱</label>
                                        <input type="text" size="30" style="width: 300px;" id="alipay_acc" name="alipay_acc"
                                            class="f-input" value="<%=alipay_acc %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            合作者身份(PID)</label>
                                        <input type="text" size="30" id="alipay_mid" style="width: 300px;" name="alipay_mid"
                                            class="f-input" value="<%=alipay_mid %>" /><span id="getPid" style="width: 200px;
                                                float: left; padding-top: 10px;"><a target='_blank' href='https://b.alipay.com/order/pidKey.htm?pid=2088301351056172&product=fastpay'>获取PID、KEY</a></span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            安全校验码(Key)</label>
                                        <input type="password" size="30" id="alipay_sec" name="alipay_sec" class="f-input"
                                            value="<%=alipay_sec %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            防钓鱼功能</label>
                                        <input id="alipay_anti_phishing" name="alipay_anti_phishing" type="checkbox" value="1"
                                            <%=alipay_dy %> />
                                        <span id="SPAN2" class="hint">防钓鱼功能开关,一旦开启，就无法关闭，根据商家自身网站情况请慎重选择是否开启,申请开通方法：联系支付宝的客户经理或拨打商户服务电话0571-88158090，帮忙申请开通</span>
                                    </div>
                                    <script>
                                        function select1(obj) {

                                            var product = "fastpay";
                                            var alipaytype = $("#alipaytype").val();
                                            if (alipaytype == "0") {
                                                product = "fastpay";
                                            }
                                            else if (alipaytype == "1") {
                                                product = "escrow";
                                            }
                                            else if (alipaytype == "2") {
                                                product = "dualpay";
                                            }

                                            $("#getPid").html("<a target='_blank' href='https://b.alipay.com/order/pidKey.htm?pid=2088301351056172&product=" + product + "'>获取PID、KEY</a>");
                                        }


                                    </script>
                                    <div class="field">
                                        <label>
                                            担保接口方式</label>
                                        <span class="hint" id="SPAN1">如果您的支付宝接口为担保交易接口,请勾选此功能。<br>
                                            方式A：客户付款后，要进入支付宝点击"确认收货"，订单才能从"未付款"转为"已付款"状态。<br>
                                            方式B：客户付款后，不用进入支付宝点击"确认收货"，订单就是“付款”状态。</span>
                                        <input name="alipay_Manual_SecuredTransactions" type="radio" value="1" <%=fangshia %> />方式A
                                        <input name="alipay_Manual_SecuredTransactions" type="radio" value="0" <%=fangshib %> />方式B
                                    </div>
                                    <div class="field">
                                        <label>
                                            自动发货</label>
                                        <select id="autodeliver" runat="server" name="autodeliver" style="float: left;">
                                            <option value="0">开启</option>
                                            <option value="1">关闭</option>
                                        </select>
                                        <span class="inputtip">开启时,用户付款后系统自动给支付宝发送已发货通知</span>
                                    </div>
                                    <div class="field">
                                        <div class="field1">
                                        </div>
                                        <div class="field2">
                                            <a target="_blank" href="http://help.alipay.com/lab/help_detail.htm?help_id=211802">
                                                <img src="css/i/alp_c.gif" /></a>&nbsp;&nbsp;个人认证-如果您的支付宝账户没有进行实名认证请您点击该按钮进入支付宝官方网站进行实名认证。</div>
                                    </div>
                                    <div class="field">
                                        <div class="field1">
                                        </div>
                                        <div class="field2">
                                            <a target="_blank" href="http://help.alipay.com/lab/help_detail.htm?help_id=1503">
                                                <img src="css/i/alp_d.gif" /></a>&nbsp;&nbsp;公司认证-如果您的支付宝账户没有进行实名认证请您点击该按钮进入支付宝官方网站进行实名认证。</div>
                                    </div>
                                    <div class="field">
                                        <div class="field1">
                                        </div>
                                        <div class="field2">
                                            <a target="_blank" href="https://certify.alipay.com/certifyUpgradeStatus.htm?upgradeFrom=3">
                                                <img src="css/i/alp_e.gif" /></a>&nbsp;&nbsp;升级认证：如果您的支付宝认证需要升级，请点击该按钮进入支付宝官方网站进行升级操作。</div>
                                    </div>
                                    <!-- yeepay -->
                                    <div class="wholetip clear">
                                        <h3>
                                            2、易宝支付（没有的话，保留为空）</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户ID号</label>
                                        <input type="text" size="30" id="yeepay_mid" name="yeepay_mid" class="f-input" value="<%=yeepay_mid %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            交易密钥</label>
                                        <input type="password" size="30" id="yeepay_sec" name="yeepay_sec" class="f-input"
                                            value="<%=yeepay_sec %>" />
                                    </div>
                                    <div class="field" style="display: none;">
                                        <label>
                                            易宝直连</label>
                                        <select id="isybbank" name="isybbank" runat="server" style="float: left;">
                                            <option value="1">开启</option>
                                            <%-- <option value="0">关闭</option>--%>
                                        </select>
                                        <span class="inputtip">开启时,用户可以使用易宝支付的直连方式支付</span>
                                    </div>
                                    <!-- Chinabank -->
                                    <div class="wholetip clear">
                                        <h3>
                                            3、网银在线（没有的话，保留为空）</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户ID号</label>
                                        <input type="text" size="30" id="chinabank_mid" name="chinabank_mid" class="f-input"
                                            value="<%=chinabank_mid %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            交易密钥</label>
                                        <input type="password" size="30" id="chinabank_sec" name="chinabank_sec" class="f-input"
                                            value="<%=chinabank_sec %>" />
                                    </div>
                                    <!-- Tenpay -->
                                    <div class="wholetip clear">
                                        <h3>
                                            4、财付通（没有的话，保留为空）</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            支付接口类型</label>
                                        <select id="ddltenpaytype" name="ddltenpaytype" runat="server" style="float: left;">
                                            <option value="0">即时到帐接口</option>
                                            <option value="1">担保交易接口</option>
                                        </select>
                                    </div>
                                    <%--2.28添加--%>
                                    <div class="field" id="iscftbankdiv">
                                        <label>
                                            是否开启网银直连</label>
                                        <select id="iscftbank" name="iscftbank" runat="server" style="float: left;">
                                            <option value="1">是</option>
                                            <option value="0">否</option>
                                        </select>
                                        <span class="inputtip">开启时,用户可使用财付通直连的方式支付</span>
                                    </div>
                                    <%--2.28结束--%>
                                    <div class="field">
                                        <label>
                                            商户ID号</label>
                                        <input type="text" size="30" id="tenpay_mid" name="tenpay_mid" class="f-input" value="<%=tenpay_mid %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            交易密钥</label>
                                        <input type="password" size="30" id="tenpay_sec" name="tenpay_sec" class="f-input"
                                            value="<%=tenpay_sec %>" />
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            5、PayPal贝宝支付（没有的话，保留为空）</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户账号</label>
                                        <input type="text" size="30" id="paypal_mid" name="paypal_mid" class="f-input" value="<%=paypal_mid %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            交易密钥</label>
                                        <input type="text" size="30" id="paypal_sec" name="paypal_sec" class="f-input" value="<%=paypal_sec %>" />
                                    </div>
                                    <div class="act">
                                      <%--  <input type="hidden" name="action" value="upzhifu" />--%>
                                        <input id="commit" type="submit" class="formbutton" value="保存" />
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
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>