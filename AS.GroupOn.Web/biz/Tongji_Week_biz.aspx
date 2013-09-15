<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>

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
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!Page.IsPostBack)
        {
            setValue();

        }

    }

    //Maticsoft.BLL.Order orderlist = new Maticsoft.BLL.Order();
    //Maticsoft.Model.Order order = new Maticsoft.Model.Order();

    /////////////////////////////声明///////////////////////////
    //卖出数
    protected string[] count = new string[7];
    //这周的卖出数
    protected string countSum = "";
    //总收款
    protected string[] money = new string[7];
    //这周的总收款
    protected string moneySum = "";
    //余额收款
    protected string[] Yue = new string[7];
    //这周的余额收款
    protected string YueSum = "";
    //支付宝收款
    protected string[] alipay = new string[7];
    //这周的支付宝收款
    protected string alipaySum = "";
    //易宝收款
    protected string[] yeepay = new string[7];
    //这周的易宝收款
    protected string yeepaySum = "";
    //财富通收款
    protected string[] tenpay = new string[7];
    //这周的财富通收款
    protected string tenpaySum = "";
    //移动收款
    protected string[] mobile = new string[7];
    //这周的移动收款
    protected string mobileSum = "";
    //网银收款
    protected string[] chinabank = new string[7];
    //这周的网银收款
    protected string chinabankSum = "";
    //货到付款
    protected string[] cod = new string[7];
    //这周的货到付款
    protected string codSum = "";
    //管理收款
    protected string[] guanli = new string[7];
    protected string guanliSum = "";
    //积分收入
    protected string[] jifen = new string[7];
    //这周的管理收款
    protected int jifenSum = 0;
    protected string jifenSuml = "";
    //实际收款
    protected string[] realPay = new string[7];
    //这周的实际收款
    protected string realPaySum = "";
    //注册用户统计
    int[] userDayTime = new int[7];
    //注册用户数
    protected string[] UserDay = new string[7];
    //这周的注册用户数
    protected string UserDaySum = "";

    //团购订单总数
    protected string[] OrderDay = new string[7];
    //这周的团购订单总数
    protected string OrderDaySum = "";
    //已付款
    protected string[] OrderDay_Pay = new string[7];
    //这周的已付款
    protected string OrderDay_PaySum = "";
    //之前下过订单今天付款的订单
    protected string[] OrderDay_Pay_Today = new string[7];
    //未付款
    protected string[] OrderDay_UnPay = new string[7];
    //这周的未付款
    protected string OrderDay_UnPaySum = "";
    // 取消的订单
    protected string[] OrderDay_Cancel = new string[7];
    //这周取消的订单
    protected string OrderDay_CancelSum = "";
    //易宝付款
    protected string[] yibao = new string[7];
    //这周的易宝付款
    protected string yibaoSum = "";
    //支付宝付款
    protected string[] zhifubao = new string[7];
    //这周的支付宝付款
    protected string zhifubaoSum = "";
    //财富通付款
    protected string[] caifutong = new string[7];
    //这周的财富通付款
    protected string caifutongSum = "";
    //移动付款
    protected string[] yidong = new string[7];
    //这周的移动付款
    protected string yidongSum = "";
    //网银付款
    protected string[] wangyin = new string[7];
    //这周的网银付款
    protected string wangyinSum = "";
    //货到付款
    protected string[] huodaofukuan = new string[7];
    //这周的货到付款
    protected string huodaofukuanSum = "";
    //余额付款
    protected string[] yue = new string[7];
    //这周的余额付款
    protected string yueSum = "";
    //积分订单数
    protected string[] score = new string[7];
    //protected int scoreSum = 0;
    protected string scoreSuml = "";
    //字体颜色判断
    protected string[] color = new string[7];

    protected string strTotalTeam = "";
    protected string strTmallTeam = "";
    protected string strUserTotal = "";
    protected string strOrderTotal = "";
    protected string strEmailTotal = "";
    protected string sql = "";
    //判断当前是星期几,并输出这周前几天和今天的时间,并加进背景颜色
    private List<string> getWeek()
    {
        List<string> week = new List<string>();

        string s = System.DateTime.Today.DayOfWeek.ToString();

        if (s == "Monday")
        {
            week.Clear();
            week.Add(System.DateTime.Now.ToString("yyyy-M-d"));
            color[0] = "style='color:red;'";
            color[1] = "";
            color[2] = "";
            color[3] = "";
            color[4] = "";
            color[5] = "";
            color[6] = "";
        }
        else if (s == "Tuesday")
        {
            week.Clear();
            week.Add(System.DateTime.Now.AddDays(-1).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.ToString("yyyy-M-d"));
            color[0] = "";
            color[1] = "style='color:red;'";
            color[2] = "";
            color[3] = "";
            color[4] = "";
            color[5] = "";
            color[6] = "";
        }
        else if (s == "Wednesday")
        {
            week.Clear();
            week.Add(System.DateTime.Now.AddDays(-2).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-1).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.ToString("yyyy-M-d"));
            color[0] = "";
            color[1] = "";
            color[2] = "style='color:red;'";
            color[3] = "";
            color[4] = "";
            color[5] = "";
            color[6] = "";
        }
        else if (s == "Thursday")
        {
            week.Clear();
            week.Add(System.DateTime.Now.AddDays(-3).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-2).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-1).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.ToString("yyyy-M-d"));
            color[0] = "";
            color[1] = "";
            color[2] = "";
            color[3] = "style='color:red;'";
            color[4] = "";
            color[5] = "";
            color[6] = "";
        }
        else if (s == "Friday")
        {
            week.Clear();
            week.Add(System.DateTime.Now.AddDays(-4).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-3).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-2).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-1).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.ToString("yyyy-M-d"));
            color[0] = "";
            color[1] = "";
            color[2] = "";
            color[3] = "";
            color[4] = "style='color:red;'";
            color[5] = "";
            color[6] = "";
        }
        else if (s == "Saturday")
        {
            week.Clear();
            week.Add(System.DateTime.Now.AddDays(-5).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-4).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-3).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-2).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-1).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.ToString("yyyy-M-d"));
            color[0] = "";
            color[1] = "";
            color[2] = "";
            color[3] = "";
            color[4] = "";
            color[5] = "style='color:red;'";
            color[6] = "";
        }
        else if (s == "Sunday")
        {
            week.Clear();
            week.Add(System.DateTime.Now.AddDays(-6).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-5).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-4).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-3).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-2).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.AddDays(-1).ToString("yyyy-M-d"));
            week.Add(System.DateTime.Now.ToString("yyyy-M-d"));
            color[0] = "";
            color[1] = "";
            color[2] = "";
            color[3] = "";
            color[4] = "";
            color[5] = "";
            color[6] = "style='color:red;'";
        }

        return week;

    }
    //判断是哪个列,并把查询语句添加进去
    private void setValue()
    {
        int yuesum = 0;
        int zhifubaosum = 0;
        int caifutongsum = 0;
        int yibaosum = 0;
        int yidongsum = 0;
        int wangyinsum = 0;
        int huodaofukuansum = 0;
        decimal realPaysum = 0;
        decimal yeepaysum = 0;
        decimal alipaysum = 0;
        decimal tenpaysum = 0;
        decimal mobilesum = 0;
        decimal Yuesum = 0;
        decimal moneysum = 0;
        decimal guanlisum = 0;
        decimal chinabanksum = 0;
        decimal codsum = 0;
        int countsum = 0;
        int userDaysum = 0;
        int OrderDay_UnPaysum = 0;
        int OrderDay_Paysum = 0;
        int OrderDay_Cancelsum = 0;
        int OrderDay_Allpaysum = 0;
        int Order_Sum = 0;
        int scoresum = 0;
        int i = 0;
        List<string> _weekday = getWeek();
        string monday = _weekday[0];//周一
        string sunday = _weekday[_weekday.Count - 1];//周日
        foreach (string item in _weekday)
        {

            int quantity = 0;//卖出数
            decimal Origin = 0;//总收款
            decimal Credit = 0; //余额收款
            decimal Money = 0;//支付宝
            decimal yeepayMoney = 0;//意宝
            decimal tenpayMoney = 0;//财富通收款
            decimal mobileMoney = 0;//移动收款
            decimal guanliMoney = 0; //线下充值
            int totlejifen = 0;//积分收入
            decimal realpayMoney = 0;//网银收款
            decimal codMoney = 0;//货到付款
            decimal chinabankMoney = 0;//余额付款
            //支付宝订单数
            int alipayPay = 0;
            //易宝订单数
            int yeepayPay = 0;
            //财富通订单数
            int tenpayPay = 0;
            //移动订单数
            int chinamobilepayPay = 0;
            //线下订单数
            int cashPay = 0;
            //网银订单数
            int chinabankPay = 0;
            //货到付款订单数
            int codPay = 0;
            //余额付款订单数
            int creditPay = 0;
            //付款的数目
            int paySum = 0;
            //未付款的数目
            int unpaySum = 0;
            //取消的订单
            int cancelSum = 0;
            int allpaySum = 0;
            //int OrderTotal = 0;
            int scoreSum = 0;
            //下订单时间
            OrderFilter orderfilter = new OrderFilter();
            IList<IOrder> ilistorder = null;
            orderfilter.Wheresql1 = "(Teamid in (select id from Team where Partner_id=" + Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0)
                + ") or Team_id in(SELECT id from team where Partner_id=" + Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0)
                + ")) and (Create_time BETWEEN '" + item + " 00:00:00' and '" + item + " 23:59:59')";
            orderfilter.StateIn = "'pay','scorepay'";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilistorder = session.Orders.OrderTongji(orderfilter);

            }
            if (ilistorder != null && ilistorder.Count != 0)
            {
                int j = 0;
                //for (int j = 0; j < ds.Tables[0].Rows.Count; j++)
                foreach (IOrder order in ilistorder)
                {
                    //OrderTotal++;
                    if (order.Service != null)
                    {

                        switch (order.Service.ToString().ToLower())
                        {
                            case "alipay":
                                //支付宝收款
                                Money += Convert.ToDecimal(order.Money.ToString());
                                //支付宝付款
                                alipayPay++;
                                break;
                            case "yeepay":
                                //易宝收款
                                yeepayMoney += Convert.ToDecimal(order.Money.ToString());
                                //易宝付款
                                yeepayPay++;
                                break;
                            case "tenpay":
                                //财富通收款
                                tenpayMoney += Convert.ToDecimal(order.Money.ToString());
                                //财富通付款
                                tenpayPay++;
                                break;
                            case "chinamobilepay":
                                //移动收款
                                mobileMoney += Convert.ToDecimal(order.Money.ToString());
                                //移动付款
                                chinamobilepayPay++;
                                break;
                            case "cash":
                                //线下充值
                                guanliMoney += Convert.ToDecimal(order.Origin.ToString()) - Convert.ToDecimal(order.Credit.ToString());
                                break;
                            case "chinabank":
                                //网银收款
                                chinabankMoney += Convert.ToDecimal(order.Money.ToString());
                                //网银付款
                                chinabankPay++;
                                break;
                            case "cashondelivery":
                                //货到付款
                                codMoney += Convert.ToDecimal(order.cashondelivery.ToString());
                                codPay++;
                                break;
                            case "credit":
                                //余额付款
                                if (order.State.ToString() == "pay")
                                {
                                    creditPay++;
                                }
                                break;
                        }
                    }
                    switch (order.State.ToString().ToLower())
                    {
                        //case "unpay":
                        //    unpaySum++;
                        //    break;
                        //case "nocod":
                        //    unpaySum++;
                        //    break;
                        case "pay":
                            paySum++;
                            break;
                        case "scorepay":
                            paySum++;
                            break;
                        //case "cancel":
                        //    cancelSum++;
                        //    break;
                        default:
                            break;
                    }
                    IList<IOrder> ilistallsum = null;
                    OrderFilter orallsumfilter = new OrderFilter();
                    orallsumfilter.Wheresql1 = "(Teamid in (select id from Team where Partner_id=" + Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0)
            + ") or Team_id in(SELECT id from team where Partner_id=" + Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0)
            + ")) and (Create_time BETWEEN '" + item + " 00:00:00' and '" + item + " 23:59:59')";
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        ilistallsum = session.Orders.OrderTongji(orallsumfilter);
                    }
                    if (ilistallsum != null && ilistallsum.Count != 0)
                    {
                        allpaySum = Convert.ToInt32(ilistallsum.Count.ToString());
                    }
                    //实际在线支付费用
                    if (order.Service != null)
                    {
                        if (order.Service.ToString().ToLower() != "credit" && order.Service.ToString().ToLower() != "cash")
                        {
                            realpayMoney += Convert.ToDecimal(order.Money.ToString());
                        }
                    }
                    //卖出数
                    quantity += Convert.ToInt32(order.Quantity.ToString());
                    //余额收款
                    Credit += Convert.ToDecimal(order.Credit.ToString());
                    //总收款
                    Origin += Convert.ToDecimal(order.Origin.ToString());
                    //积分收款
                    totlejifen += Convert.ToInt32(order.totalscore.ToString());
                    if (order.State.ToString() == "scorepay")
                    { scoreSum += 1; }
                    j++;
                }
                Order_Sum = allpaySum;
            }

            yeepay[i] = yeepayMoney + "元";
            yeepaysum += yeepayMoney;
            Yue[i] = Credit + "元";
            Yuesum += Credit;
            alipay[i] = Money + "元";
            alipaysum += Money;
            tenpay[i] = tenpayMoney + "元";
            tenpaysum += tenpayMoney;
            mobile[i] = mobileMoney + "元";
            mobilesum += mobileMoney;
            chinabank[i] = chinabankMoney + "元";
            chinabanksum += chinabankMoney;
            cod[i] = codMoney + "元";
            codsum += codMoney;
            guanli[i] = guanliMoney + "元";
            guanlisum += guanliMoney;
            jifen[i] = totlejifen + "积分";
            jifenSum += totlejifen;
            money[i] = Origin + "元";
            moneysum += Origin;
            count[i] = quantity + "个";
            //count[i] = allpaySum + "个";
            countsum += quantity;
            //countsum += allpaySum;
            //realPay[i] = realpayMoney + "元";//网银收入
            realPay[i] = Money + yeepayMoney + tenpayMoney + mobileMoney + chinabankMoney + codMoney + guanliMoney + "元";//实际收款
            //realPaysum += realpayMoney;
            realPaysum += Money + yeepayMoney + tenpayMoney + mobileMoney + chinabankMoney + codMoney + guanliMoney;
            //易宝付款
            yibao[i] = yeepayPay + "单";

            yibaosum += yeepayPay;
            //支付宝付款
            zhifubao[i] = alipayPay + "单";
            zhifubaosum += alipayPay;
            //财富通付款
            caifutong[i] = tenpayPay + "单";
            caifutongsum += tenpayPay;
            //移动付款
            yidong[i] = chinamobilepayPay + "单";
            yidongsum += chinamobilepayPay;
            //网银付款
            wangyin[i] = chinabankPay + "单";

            wangyinsum += chinabankPay;
            //货到付款
            huodaofukuan[i] = codPay + "单";
            huodaofukuansum += codPay;
            //余额付款           
            yue[i] = creditPay + "单";
            yuesum += creditPay;
            score[i] = scoreSum + "单";
            scoresum += scoreSum;
            //已付款订单数
            OrderDay_Pay[i] = "" + paySum + "单";

            //未付款订单
            OrderFilter unpaySumfilter = new OrderFilter();
            IList<IOrder> ilistunpaysum = null;
            unpaySumfilter.Wheresql1 = "(Teamid in (select id from Team where Partner_id=" + Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0)
            + ") or Team_id in(SELECT id from team where Partner_id=" + Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0)
            + ")) and (Create_time BETWEEN '" + item + " 00:00:00' and '" + item + " 23:59:59')";
            unpaySumfilter.StateIn = "'unpay','scoreunpay','nocod'";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilistunpaysum = session.Orders.OrderTongji(unpaySumfilter);
            }
            if (ilistunpaysum != null && ilistunpaysum.Count != 0)
            {
                //未付款订单数
                unpaySum = ilistunpaysum.Count;
            }
            OrderDay_UnPay[i] = unpaySum + "单";
            OrderDay_UnPaysum += unpaySum;

            //取消订单
            OrderFilter cancelSumfileter = new OrderFilter();
            IList<IOrder> ilistcancelsum = null;
            cancelSumfileter.Wheresql1 = "(Teamid in (select id from Team where Partner_id=" + Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0)
            + ") or Team_id in(SELECT id from team where Partner_id=" + Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0)
            + ")) and (Create_time BETWEEN '" + item + " 00:00:00' and '" + item + " 23:59:59')";
            cancelSumfileter.StateIn = "'cancel'";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilistcancelsum = session.Orders.OrderTongji(cancelSumfileter);
            }
            if (ilistcancelsum != null && ilistcancelsum.Count != 0)
            {
                //取消订单数
                cancelSum = ilistcancelsum.Count;
            }
            OrderDay_Cancel[i] = cancelSum + "单";
            OrderDay_Cancelsum += cancelSum;
            OrderDay_Paysum += paySum;
            //注册用户数
            //userDayTime[i] = int.Parse(GetCount("count(*)", "Create_time BETWEEN '" + item + " 00:00:00' AND '" + item + " 23:59:59'", "User"));
            UserFilter userfilter = new UserFilter();
            userfilter.FromCreate_time = Helper.GetDateTime(item + " 00:00:00", DateTime.Now);
            userfilter.ToCreate_time = Helper.GetDateTime(item + " 23:59:59", DateTime.Now);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                userDayTime[i] = session.Users.GetCountByCityId(userfilter);
            }

            UserDay[i] = userDayTime[i] + "个";
            userDaysum += userDayTime[i];
            //团购订单总数
            OrderDay[i] = allpaySum.ToString() + "单";
            OrderDay_Allpaysum += allpaySum;
            i++;
        }
        //团购项目数
        //strTotalTeam = GetCount("count(*)", " Partner_id=" + GetCookie("partnerid") + " and teamcata=0", "Team");

        TeamFilter teamfilter = new TeamFilter();
        teamfilter.Partner_id = Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0);
        teamfilter.teamcata = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            strTotalTeam = Helper.GetString(session.Teams.GetCount(teamfilter), string.Empty);
        }
        //商城项目数
        //strTmallTeam = GetCount("count(*)", " Partner_id=" + GetCookie("partnerid") + " and teamcata=1", "Team");
        TeamFilter teamfilter1 = new TeamFilter();
        teamfilter1.Partner_id = Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0);
        teamfilter1.teamcata = 1;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            strTmallTeam = Helper.GetString(session.Teams.GetCount(teamfilter1), string.Empty);
        }
        //所有订单数
        strOrderTotal = Order_Sum.ToString();
        //订单总数
        OrderDaySum = OrderDay_Allpaysum + "单";
        //未付款
        OrderDay_UnPaySum = OrderDay_UnPaysum + "单";
        //已付款
        OrderDay_PaySum = OrderDay_Paysum + "单";
        //已取消
        OrderDay_CancelSum = OrderDay_Cancelsum + "单";
        //卖出数
        countSum = countsum + "个";
        //总收款
        moneySum = moneysum + "元";
        //余额收款
        YueSum = Yuesum + "元";
        //支付宝收款
        alipaySum = alipaysum + "元";
        //移动收款
        mobileSum = mobilesum + "元";
        //易宝收款
        yeepaySum = yeepaysum + "元";
        //财富通收款
        tenpaySum = tenpaysum + "元";
        //网银收款
        chinabankSum = chinabanksum + "元";
        //货到付款
        codSum = codsum + "元";
        //线下充值
        guanliSum = guanlisum + "元";
        //积分收入
        jifenSuml = jifenSum + "积分";
        //实际收款
        realPaySum = realPaysum + "元";
        //易宝付款
        yibaoSum = yibaosum + "单";
        //支付宝付款
        zhifubaoSum = zhifubaosum + "单";
        //财富通付款
        caifutongSum = caifutongsum + "单";
        //移动付款
        yidongSum = yidongsum + "单";
        //网银付款
        wangyinSum = wangyinsum + "单";
        //货到付款
        huodaofukuanSum = huodaofukuansum + "单";
        //余额付款
        yueSum = yuesum + "单";
        scoreSuml = scoresum + "单";
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
                <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        本周统计</h2>
                                </div>
                                <div class="sect">
                                    <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                        <tr>
                                            <td bgcolor="#CCCCCC">
                                                <table width="100%" border="1" cellspacing="1" cellpadding="0">
                                                    <tr>
                                                        <td width="11%" bgcolor="#EFEFEF">
                                                            &nbsp;
                                                        </td>
                                                        <td width="11%" align="center" bgcolor="#EFEFEF">
                                                            <p <%=color[0] %>>
                                                                星期一</p>
                                                        </td>
                                                        <td width="11%" align="center" bgcolor="#EFEFEF">
                                                            <p <%=color[1] %>>
                                                                星期二</p>
                                                        </td>
                                                        <td width="11%" align="center" bgcolor="#EFEFEF">
                                                            <p <%=color[2] %>>
                                                                星期三</p>
                                                        </td>
                                                        <td width="11%" align="center" bgcolor="#EFEFEF">
                                                            <p <%=color[3] %>>
                                                                星期四</p>
                                                        </td>
                                                        <td width="11%" align="center" bgcolor="#EFEFEF">
                                                            <p <%=color[4] %>>
                                                                星期五</p>
                                                        </td>
                                                        <td width="11%" align="center" bgcolor="#EFEFEF">
                                                            <p <%=color[5] %>>
                                                                星期六</p>
                                                        </td>
                                                        <td width="11%" align="center" bgcolor="#EFEFEF">
                                                            <p <%=color[6] %>>
                                                                星期日</p>
                                                        </td>
                                                        <td width="11%" align="center" bgcolor="#EFEFEF">
                                                            一周总和
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>所有订单数：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=OrderDay[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=OrderDay[1] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=OrderDay[2] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=OrderDay[3] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=OrderDay[4] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=OrderDay[5] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=OrderDay[6] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=OrderDaySum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>未付款：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=OrderDay_UnPay[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=OrderDay_UnPay[1] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=OrderDay_UnPay[2] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=OrderDay_UnPay[3] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=OrderDay_UnPay[4] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=OrderDay_UnPay[5] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=OrderDay_UnPay[6] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=OrderDay_UnPaySum%></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td height="26" bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>已付款：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=OrderDay_Pay[0] %></p>
                                                                <p <%=color[0] %>>
                                                                    <%=OrderDay_Pay_Today[0]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=OrderDay_Pay[1] %></p>
                                                                <p <%=color[1] %>>
                                                                    <%=OrderDay_Pay_Today[1]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=OrderDay_Pay[2] %></p>
                                                                <p <%=color[2] %>>
                                                                    <%=OrderDay_Pay_Today[2]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=OrderDay_Pay[3] %></p>
                                                                <p <%=color[3] %>>
                                                                    <%=OrderDay_Pay_Today[3]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=OrderDay_Pay[4] %></p>
                                                                <p <%=color[4] %>>
                                                                    <%=OrderDay_Pay_Today[4]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=OrderDay_Pay[5] %></p>
                                                                <p <%=color[5] %>>
                                                                    <%=OrderDay_Pay_Today[5]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=OrderDay_Pay[6] %></p>
                                                                <p <%=color[6] %>>
                                                                    <%=OrderDay_Pay_Today[6]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=OrderDay_PaySum%></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td height="26" bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>已取消：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=OrderDay_Cancel[0]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=OrderDay_Cancel[1]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=OrderDay_Cancel[2]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=OrderDay_Cancel[3]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=OrderDay_Cancel[4]%></p>
                                                                </p></blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=OrderDay_Cancel[5]%></p>
                                                                </p></blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=OrderDay_Cancel[6]%></p>
                                                                </p></blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=OrderDay_CancelSum%></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>卖出数：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=count[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=count[1] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=count[2] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=count[3] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=count[4] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=count[5] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=count[6] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=countSum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>收款：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF" colspan="8">
                                                            &nbsp;
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>总收款：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=money[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=money[1] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=money[2] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=money[3] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=money[4] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=money[5] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=money[6] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=moneySum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>余额收款</strong>：</p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=Yue[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=Yue[1] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=Yue[2] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=Yue[3] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=Yue[4] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=Yue[5] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=Yue[6] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=YueSum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>支付宝收款：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=alipay[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=alipay[1] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=alipay[2] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=alipay[3] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=alipay[4] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=alipay[5] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=alipay[6] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=alipaySum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>易宝收款：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=yeepay[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=yeepay[1] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=yeepay[2] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=yeepay[3] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=yeepay[4] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=yeepay[5] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=yeepay[6] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=yeepaySum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>财付通收款：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=tenpay[0]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=tenpay[1]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=tenpay[2]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=tenpay[3]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=tenpay[4]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=tenpay[5]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=tenpay[6]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=tenpaySum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>移动收款：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=mobile[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=mobile[1]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=mobile[2]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=mobile[3]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=mobile[4]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=mobile[5]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=mobile[6]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=mobileSum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>网银收款：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=chinabank[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=chinabank[1]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=chinabank[2]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=chinabank[3]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=chinabank[4]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=chinabank[5]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=chinabank[6]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=chinabankSum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>货到付款：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=cod[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=cod[1]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=cod[2]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=cod[3]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=cod[4]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=cod[5]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=cod[6]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=codSum%></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>线下支付:</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=guanli[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=guanli[1]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=guanli[2]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=guanli[3]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=guanli[4]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=guanli[5]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=guanli[6]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=guanliSum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>积分付款:</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=jifen[0]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=jifen[1]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=jifen[2]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=jifen[3]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=jifen[4]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=jifen[5]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=jifen[6]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=jifenSuml%></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>实际收款：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong><font color='#990000'>
                                                                        <%=realPay[0] %></font></strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong><font color='#990000'>
                                                                        <%=realPay[1] %></font></strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong><font color='#990000'>
                                                                        <%=realPay[2] %></font></strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong><font color='#990000'>
                                                                        <%=realPay[3] %></font></strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong><font color='#990000'>
                                                                        <%=realPay[4] %></font></strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong><font color='#990000'>
                                                                        <%=realPay[5] %></font></strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong><font color='#990000'>
                                                                        <%=realPay[6] %></font></strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong><font color='#990000'>
                                                                        <%=realPaySum %></font></strong></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    <strong>支付方式：</strong></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF" colspan="8">
                                                            &nbsp;
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    易宝支付:
                                                                </p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=yibao[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=yibao[1] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=yibao[2] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=yibao[3] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=yibao[4] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=yibao[5] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=yibao[6] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=yibaoSum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    支付宝支付：</p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=zhifubao[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=zhifubao[1] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=zhifubao[2] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=zhifubao[3] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=zhifubao[4] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=zhifubao[5] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=zhifubao[6] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=zhifubaoSum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    财富通支付：</p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=caifutong[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=caifutong[1]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=caifutong[2]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=caifutong[3]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=caifutong[4]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=caifutong[5]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=caifutong[6]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=caifutongSum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    移动支付：</p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=yidong[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=yidong[1]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=yidong[2]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=yidong[3]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=yidong[4]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=yidong[5]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=yidong[6]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=yidongSum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    网银支付：</p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=wangyin[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=wangyin[1]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=wangyin[2]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=wangyin[3]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=wangyin[4]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=wangyin[5]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=wangyin[6]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=wangyinSum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    货到付款：</p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=huodaofukuan[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=huodaofukuan[1]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=huodaofukuan[2]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=huodaofukuan[3]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=huodaofukuan[4]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=huodaofukuan[5]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=huodaofukuan[6]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=huodaofukuanSum%></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    余额付款：</p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=yue[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=yue[1] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=yue[2] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=yue[3] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=yue[4] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=yue[5] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=yue[6] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=yueSum %></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                    <tr bgcolor="#FFFFFF">
                                                        <td bgcolor="#EFEFEF">
                                                            <blockquote>
                                                                <p>
                                                                    积分支付：</p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[0] %>>
                                                                    <%=score[0] %></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[1] %>>
                                                                    <%=score[1]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[2] %>>
                                                                    <%=score[2]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[3] %>>
                                                                    <%=score[3]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[4] %>>
                                                                    <%=score[4]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[5] %>>
                                                                    <%=score[5]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p <%=color[6] %>>
                                                                    <%=score[6]%></p>
                                                            </blockquote>
                                                        </td>
                                                        <td bgcolor="#FFFFFF">
                                                            <blockquote>
                                                                <p>
                                                                    <%=scoreSuml%></p>
                                                            </blockquote>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                    <div class='wholetip clear'>
                                        <h3>
                                            统计数据</h3>
                                    </div>
                                    <div style='margin: 0 20px;'>
                                        <p>
                                            团购项目数：<%=strTotalTeam %></p>
                                        <p>
                                            商城项目数：<%=strTmallTeam %></p>
                                        <%--  <p>用户注册数：<%=strUserTotal %></p>--%>
                                        <p>
                                            所有订单数：<%=strOrderTotal %></p>
                                        <%-- <p>邮件订阅数：<%=strEmailTotal %></p>--%>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>