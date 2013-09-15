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
    public IList<IOrder> orderlist = null;
    public ITeam teammodel = null;
    public IOrder ordermodel = null;
    public IDraw drawmodel = Store.CreateDraw();
    protected IUser user = null;
    public bool falg = false;
    public string orderid = "A007"; //订单编号
    public string strpage;
    public string pagenum = "1";
    public string service = "";//支付网关默认为账户余额
    bool isRedirect = false;
    protected decimal totalprice = 0;//应付总额
    public bool isExistrule = false;//判断用户是否选择项目所没有的规格
    public bool youhui = false;
    bool isSame = false;//判断用户的选择的规格是否有一样的
    public bool isinvent = false;//判断订单的数量是否已经超出了库存
    public IList<IOrderDetail> detaillist = null;
    protected bool isCreditseconds = false; //仅余额可秒杀
    protected bool orderemailvalidVisble = false;
    public string mobilemessage = ""; //验证手机信息
    public decimal summoney = 0;
    public decimal inputmoney = 0;
    public decimal needmoney = 0;
    public ISystem system = Store.CreateSystem();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.WapBodyID = "order-check";
        PageValue.Title = "确认订单";
        MobileNeedLogin();
        system = PageValue.CurrentSystem;
        using (IDataSession session = Store.OpenSession(false))
        {
            ordermodel = session.Orders.GetByID(Helper.GetInt(Request["orderid"], 0));
        }
        if (ordermodel != null)
        {
            //用户无法修改其他用户的额单子
            if (OrderMethod.IsUserOrder(AsUser.Id, Helper.GetInt(Request["orderid"], 0)))
            {
                SetError("友情提示：无法操作其他用户的订单");
                Response.Redirect(GetUrl("手机版首页", "index.aspx"));
                Response.End();
                return;
            }
            if (ordermodel.Express == "Y")
            {
                totalprice = OrderMethod.GetTeamTotalPrice(ordermodel.Id) + ordermodel.Fare;
                summoney = ordermodel.Quantity * ordermodel.Price;
            }
            else
            {
                totalprice = OrderMethod.GetTeamTotalPrice(ordermodel.Id);
                summoney = ordermodel.Quantity * ordermodel.Price;
            }
            bool isfreefare = OrderMethod.GetIsFreeFare(summoney);
            if (isfreefare)
            {
                ordermodel.Fare = 0;
            }
            CookieUtils.SetCookie("summoney", summoney.ToString());
            decimal jian = GetCuXiao(summoney);
            if (jian != 0)
            {
                totalprice = OrderMethod.GetTeamTotalPrice(ordermodel.Id) - jian;
            }
            ordermodel.Origin = totalprice;
            ordermodel.discount = Helper.GetDouble(ActionHelper.GetUserLevelMoney(AsUser.totalamount).ToString("0.00"), 0);
            if (ordermodel.User != null && ordermodel.User.Money > 0)
            {
                if (ordermodel.Origin > ordermodel.User.Money)
                {
                    needmoney = ordermodel.Origin - ordermodel.User.Money;
                }
            }
            else
            {
                needmoney = ordermodel.Origin;
            }
            //判断项目是否过期或者卖光
            using (IDataSession session = Store.OpenSession(false))
            {
                session.Orders.Update(ordermodel);
                teammodel = session.Teams.GetByID(ordermodel.teamid);
            }
            if (teammodel != null)
            {
                CheckExpired(teammodel);
            }
            else if (ordermodel.OrderDetail[0].Team != null)
            {
                CheckExpired(ordermodel.OrderDetail[0].Team);
            }
            //团购项目才验证购买次数
            if (isbuy(ordermodel.Id, ordermodel.Team_id, ordermodel.User_id))
            {
                SetError("友情提示：您已经超过了购买次数");
                Response.Redirect(GetUrl("手机版首页", "index.aspx"));
                Response.End();
                return;
            }
        }
        else
        {
            SetError("订单不存在");
            Response.Redirect(GetUrl("手机版首页", "index.aspx"));
            Response.End();
            return;
        }
    }
    public void CheckExpired(ITeam team)
    {
        if (team != null)
        {
            teammodel = team;
            /*2011-04-27 修改仅余额可秒杀结束*/
            AS.Enum.TeamState ts = GetState(teammodel);
            if (ts != AS.Enum.TeamState.begin && ts != AS.Enum.TeamState.successbuy)
            {
                SetError("该项目已过期或已卖光，不能支付！");
                Response.Redirect(GetUrl("手机版首页", "index.aspx"));
                Response.End();
                return;
            }
        }
    }
    //根据项目编号和用户编号判断此项目是否仅可以购买一次
    public bool isbuy(int orderid, int teamid, int userid)
    {
        bool falg = false;
        IOrder order = null;
        IList<Hashtable> hs = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            order = session.Orders.GetByID(orderid);
        }
        if (order != null && order.OrderDetail != null)
        {
            foreach (var model in order.OrderDetail)
            {
                ITeam team = null;
                team = model.Team;
                if (team != null && team.teamcata == 0)  //团购项目才验证购买次数
                {
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        hs = session.Custom.Query("select Teamid,Order_id from [Order],orderdetail where [Order].User_id=" + AsUser.Id + " and [Order].Id=orderdetail.Order_id and Teamid=" + model.Teamid + " and State='pay'");
                    }
                    if (hs != null && hs.Count > 0)
                    {
                        if (hs.Count > 1 && team.Buyonce == "Y")
                        {
                            falg = true;
                        }
                    }
                }
            }
        }
        return falg;
    }
    public static decimal GetCuXiao(decimal totalprice)
    {
        IList<ISales_promotion> sallist = null;
        Sales_promotionFilter salespfilter = new Sales_promotionFilter();
        salespfilter.end_time = DateTime.Now;
        salespfilter.Tostart_time = DateTime.Now;
        salespfilter.enable = 1;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            sallist = session.Sales_promotion.GetList(salespfilter);
        }
        decimal jian = 0;
        foreach (ISales_promotion sale_pro in sallist)
        {
            IList<IPromotion_rules> prolist = null;
            Promotion_rulesFilter prulesfilter = new Promotion_rulesFilter();
            prulesfilter.Tostart_time = DateTime.Now;
            prulesfilter.Fromend_time = DateTime.Now;
            prulesfilter.Tofull_money = totalprice;
            prulesfilter.enable = 1;
            prulesfilter.activtyid = sale_pro.id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                prolist = session.Promotion_rules.GetList(prulesfilter);
            }
            IPromotion_rules iprules = Store.CreatePromotion_rules();
            string PromotionID = iprules.getPromotionID;
            string[] Pid = PromotionID.Split(',');
            int free_shipping = Helper.GetInt(Pid[0], 0);
            int Deduction = Helper.GetInt(Pid[1], 0);
            int Feeding_amount = Helper.GetInt(Pid[2], 0);

            foreach (IPromotion_rules promotion_rules in prolist)
            {
                //满额减
                if (promotion_rules.typeid == Deduction)
                {
                    jian += promotion_rules.deduction;
                }
            }
        }
        return jian;
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<%if (ordermodel != null && ordermodel.State == "unpay")
  {%>
<div class="body">
    <div class="common-title">订单信息</div>

    <section class="common-items">
        <div class="common-item">
            <span class="item-label">项目：</span>
            <div class="item-content"><a href="<%=GetMobilePageUrl(teammodel.Id)%>"><%=teammodel.Product%></a></div>
        </div>
        <%if (ordermodel.OrderDetail != null && ordermodel.OrderDetail[0].result != null && ordermodel.OrderDetail.Count > 0)
          { %>
        <%foreach (var item in ordermodel.OrderDetail)
          {%>
        <div class="common-item">
            <span class="item-label">所选类型：</span>
            <div class="item-content"><%=WebUtils.Getbulletin(item.result)%></div>
        </div>
        <%}%>
        <%}%>
        <div class="common-item">
            <span class="item-label">购买数量：</span>
            <div class="item-content"><%=ordermodel.Quantity %></div>
        </div>
        <div class="common-item">
            <span class="item-label">项目单价：</span>
            <div class="item-content"><%=ASSystemArr["currency"] %><%=ordermodel.teamid!=0?ordermodel.Price:ordermodel.OrderDetail[0].Teamprice%></div>
        </div>
        <div class="common-item">
            <span class="item-label">运费：</span>
            <div class="item-content"><%=ASSystemArr["currency"] %><%=ordermodel.Fare %></div>
        </div>
        <%if (ordermodel.State != "scoreunpay")
          { %>
        <%if (ActionHelper.GetUserLevelMoney(AsUser.totalamount) != 1)
          { %>
        <div class="common-item">
            <span class="item-label">等级：</span>
            <div class="item-content">
                <strong><%=Utilys.GetUserLevel(AsUser.totalamount)%></strong>
            </div>
        </div>
        <div class="common-item">
            <span class="item-label">折扣：</span>
            <div class="item-content">
                <strong>
                    <%if (ActionHelper.GetUserLevelMoney(AsUser.totalamount) < 1)
                      {%>
                    <%=ActionHelper.GetUserLevelMoney(AsUser.totalamount)*10 + "折"%>
                    <% }
                      else
                      {%>
                    不打折
                    <%}%>
                </strong>
            </div>
        </div>
        <%}%>
        <%}%>
        <div class="common-item">
            <span class="item-label">总额：</span>
            <div class="item-content"><strong><%=ASSystemArr["currency"] %><%=totalprice %></strong></div>
        </div>
    </section>

    <%if (teammodel.Card != null && teammodel.Card > 0)
      {%>
    <div class="common-title">代金券</div>
    <section class="common-items">
        <div class="common-item">
            <span class="item-label">代金券：</span>
            <div class="item-content">
                <%if (!String.IsNullOrEmpty(ordermodel.Card_id) && ordermodel.Card != null)
                  { %>
                <p>已使用<%=ordermodel.Card_id %></p>
                <%}
                  else
                  { %>
                <p><a href="<%=GetUrl("手机版使用代金券","order_verifycard.aspx")+ordermodel.Id %>">使用代金券</a></p>
                <%}%>
            </div>
        </div>
    </section>
    <%}%>
    <div class="common-title">使用余额支付</div>
    <section class="common-items">
        <div class="common-item">
            <span class="item-label">订单金额：</span>
            <div class="item-content"><%=ASSystemArr["currency"] %><%=totalprice %></div>
        </div>
        <div class="common-item">
            <span class="item-label">我的余额：</span>
            <%if (ordermodel.User != null && ordermodel.User.Money < 0)
              {%>
            <div class="item-content"><%=ASSystemArr["currency"] %><%=ordermodel.User.Money %></div>
            <%}
              else
              {%>
            <div class="item-content credit-info">
                <label id="credit-value" class="credit-value" for="use-credit"><%=ASSystemArr["currency"] %><%=ordermodel.User.Money %></label>
                <%if (ordermodel.User.Money != 0)
                  { %>
                <input type="checkbox" class="use-credit" id="use-credit" checked="checked">
                <%} %>
            </div>
            <%} %>
        </div>
        <div class="common-item">
            <span class="item-label">还需支付：</span>
            <div class="item-content">
                <p><strong><%=ASSystemArr["currency"] %><span class="need-pay"><%=needmoney%></span></strong></p>
            </div>
        </div>
    </section>

    <form id="form" action="<%=GetUrl("手机版支付跳转","order_pay.aspx") %><%=Request["orderid"] %>" method="POST">
        <input type="hidden" name="orderid" value="<%=Request["orderid"] %>" />
        <input type="hidden" name="cashierCode" checked="checked" value="" />
        <input type="hidden" name="paytype" value="credit" />
        <input type="hidden" name="paymoney" value="<%=needmoney%>"/>
        <%if (PageValue.CurrentSystem != null && (!String.IsNullOrEmpty(PageValue.CurrentSystem.tenpaymid) || !String.IsNullOrEmpty(PageValue.CurrentSystem.alipaymid)))
          {%>
        <div id="pay-methods-panel" class="pay-methods-panel">
            <div id="normal-fieldset" class="normal-fieldset">
                <div class="common-title">选择支付方式</div>
                <section class="common-items common-radio-box">
                    <%if (PageValue.CurrentSystem!=null&&!String.IsNullOrEmpty(PageValue.CurrentSystem.tenpaymid)&&!String.IsNullOrEmpty(PageValue.CurrentSystem.tenpaysec))
                      {%>
                     <div class="common-item">
                        <label id="recentpay" class="needsfocus" data-banktype="tenpaywap" data-bankcode="">
                            <input type="radio" value="tenpaywap" checked="checked" name="paypath" />财付通支付</label>
                    </div>     
                     <%}%>
                  <%if (PageValue.CurrentSystem!=null&&!String.IsNullOrEmpty(PageValue.CurrentSystem.alipaymid)&&!String.IsNullOrEmpty(PageValue.CurrentSystem.alipaysec))
                      {%>
                    <div class="common-item" >
                        <label class="needsfocus" data-banktype="bank_type" data-bankcode="" onclick="">支付宝支付<input id="pay-alipayWap" type="radio" value="alipaywap" name="paypath" /></label>
                    </div>
                    <%} %>
                </section>
            </div>
        </div>
       <%}%>
        <p class="c-submit ">
            <input type="submit"  value="确认支付" />
        </p>
    </form>
</div>
<%}%>
<%LoadUserControl("_footer.ascx", null); %>
<script>
    $(function () {
        var needVerify = false,
            useCredit = true,
            mtBalance = Number('<%=AsUser.Money%>'),
            totalPrice = Number('<%=totalprice%>'),
            needPay = Number('<%=needmoney%>'),
            $errMsg = $('#errMsg').length > 0 ? $('#errMsg') : $('.errMsg'),
            tapOrClick = MT.util.tapOrClick,
            errMsgFadeIn = MT.util.errMsgFadeIn,
            $form = $('#form'),
            $recent = $form.find('#recentpay'),
            $submit = $form.find('.c-submit input'),
            order = $form.find('input[name=orderid]').val(),
            $normalField = $('#normal-fieldset'),
            $payMethodsPanel = $('#pay-methods-panel'),
            $needPay = $('.need-pay'),
            isPoping = false, hasPoped = false, payPath, timeId, boxHeight;

        if (needPay == 0) {
            $normalField.hide();
        }
        else {
            $normalField.show();
        }
        if (mtBalance > 0) {
            $('#use-credit').attr("checked", true);
        }

        initRecentPayMethods();

        $('#use-credit').on('change', function (e) {
            var $that = $(this), $paymoney = $form.find('input[name=paymoney]'),
            useCredit = $that.prop('checked');
            if (useCredit && mtBalance >= totalPrice) {
                $form.attr('action', $form.data('creditAction'));
                $normalField.hide();
                $normalField.css('height', '0').find('input').prop('disabled', 'disabled');

                $needPay.text(0);

            } else {
                $form.attr('action', $form.data('normalAction'));
                $normalField.show();
                $normalField.css('height', boxHeight).find('input').prop('disabled', '');
                if (useCredit && mtBalance > 0) {
                    $needPay.text(needPay);
                    $paymoney.val(needPay);
                } else {
                    $normalField.find('input[name=useCredit]').prop('disabled', 'disabled');
                    $paymoney.val(totalPrice);
                    $needPay.text(totalPrice);
                }
            }
        });

        $submit.on(tapOrClick, function (e, immediately) {
            e.preventDefault();
            var showVerify = $form.find(':checked').val() !== 'unionpay' && $form.find(':checked').val() !== 'creditcard';

            if (!immediately && needVerify && useCredit && showVerify) {
                verifyAccount();
            } else {
                $form.find('input[name=checkcode]').val($('#sms-captcha').val());

                submitForm();
            }
        });

        function submitForm() {

            var $checked = $form.find(':checked'),
                type = $checked.val(),
                banktype = $checked.parent().data('bankcode'),
                $payType = $form.find('input[name=paytype]'),
                $paymoney = $form.find('input[name=paymoney]'),
                $alipayCode = $form.find('input[name=cashierCode]'),
                $tenpayCode = $form.find('input[name=bank_type]'),
                qs = location.search || '';

            qs = qs.slice(1).split('&').filter(function (s) {
                if (!~s.indexOf('ErrMsg'))
                    return true;
            }).join('&');

            if (qs)
                qs = '?' + qs;

            if ($needPay.text() == 0) {
                type = 'credit';
            }
            if (type === 'tenpaywap') {
                _changeForm2TenPay($alipayCode, $tenpayCode, $payType, banktype);
            } else if (type === 'alipaywap') {
                _changeForm2AliPay($alipayCode, $tenpayCode, $payType, banktype);
            }
            else if (type === 'credit') {
                _changeFormCredit($payType);
            }
            $form.submit();


        }

        /**
         * 支付方式改为财付通
         * @param {Object} $alipayCode alipay节点，zepto对象
         * @param {Object} $tenpayCode tenpay节点，zepto对象
         * @param {Object} $payType 隐藏的bank_type节点，zepto对象
         * @param {String} bankcode 银行码
         * @private
         */
        function _changeForm2TenPay($alipayCode, $tenpayCode, $payType, bankcode) {
            if ($alipayCode.length > 0) {
                var sourceCode = '<input type="hidden" name="bank_type" value="' + bankcode + '" />';
                $alipayCode.replaceWith($(sourceCode));
            } else {
                $tenpayCode.val(bankcode);
            }
            $payType.val('tenpaywap');
        }

        /**
         * 支付方式改为财付通
         * @param {Object} $alipayCode alipay节点，zepto对象
         * @param {Object} $tenpayCode tenpay节点，zepto对象
         * @param {Object} $payType 隐藏的paytype节点，zepto对象
         * @param {String} bankcode 银行码
         * @private
         */
        function _changeForm2AliPay($alipayCode, $tenpayCode, $payType, bankcode) {
            if ($tenpayCode.length > 0) {
                var sourceCode = '<input type="hidden" name="cashierCode" value="' + bankcode + '" />';
                $tenpayCode.replaceWith($(sourceCode));
            } else {
                $alipayCode.val(bankcode);
            }
            $payType.val('alipaywap');
        }


        function _changeFormCredit($payType) {
            $payType.val('credit');
        }

        /**
         * 显示更多支付方式
         */
        function initRecentPayMethods() {
            var $morePay = $('#morePayMethods'),
                $payItems = $form.find('.common-item'),
                $title = $normalField.find('.common-title'),
                payItemsHeight, titleHeight = Number($title.height()) + parseInt($title.css('margin-top'), 10);

            // 没有过最近支付记录的话，默认选择支付宝
            if ($form.find(':checked').length === 0) {
                $form.find('#pay-alipayWap').prop('checked', 'checked');
            }
            // fix PC 上chrome的bug: “返回”按钮后最近支付没有被选中
            if ($recent.length > 0) {
                $form.find(':checked').prop('checked', '');
                $recent.find('input').prop('checked', 'checked');
            }

            $morePay.on(util.tapOrClick, function (e) {
                e.preventDefault();

                $morePay.hide();
                $payItems.show();

                if (!payItemsHeight) {
                    payItemsHeight = $normalField.find('.common-items').height();
                    boxHeight = payItemsHeight + titleHeight;
                }

                $normalField.css({ 'height': boxHeight });
            });
        }

        function resetPos($pop, $mask) {
            var docHeight = $(window).height(),
                maskHeight = document.height > docHeight ? document.height : docHeight,
                $content = $pop.find('#content'),
                // 这里的100是content的height
                contentTop = 100 + $(window).scrollTop();

            if (!hasPoped) {
                $mask.css({ opacity: 0, display: '-webkit-box', height: maskHeight })
                        .animate({ opacity: 0.8 }, 150, 'ease-in');
                $content.css('top', contentTop);
                $pop.css({ opacity: 0, display: '-webkit-box', zIndex: 998, height: maskHeight })
                        .animate({ opacity: 1 }, 150, 'ease-in');
            } else {
                $mask.css({ opacity: 0, display: '-webkit-box' })
                        .animate({ opacity: 0.8 }, 150, 'ease-in');
                $pop.css({ opacity: 0, display: '-webkit-box', zIndex: 998 })
                        .animate({ opacity: 1 }, 150, 'ease-in');
            }
        }

        function removePop() {
            var $pop = $('#pop-wrapper');

            if ($pop.length || isPoping) {
                isPoping = false;
                $pop.fadeOut();
                $('#mask').fadeOut();
            }
        }
    });
</script>
<%LoadUserControl("_htmlfooter.ascx", null); %>