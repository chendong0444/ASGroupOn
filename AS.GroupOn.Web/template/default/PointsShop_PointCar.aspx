<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Net" %>
<script runat="server">
    public IPagers<ITeam> pager = null;
    public ITeam teammodel = Store.CreateTeam();
    public IList<ITeam> teamlist = null;
    public List<Car> carlist = new List<Car>();
    public int count = 0;
    public string url = "";
    public IOrder ordermodel = Store.CreateOrder();
    public string pagenum = "1";
    public IOrderDetail orderdemodel = Store.CreateOrderDetail();
    public int farfee = 0;//免单数量
    public string strpage;
    public int pagecount = 0;
    protected NameValueCollection configs = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (ASSystem.title == String.Empty)
        {
            PageValue.Title = "积分商城";
        }
        form.Action = GetUrl("积分购物车", "PointsShop_PointCar.aspx");
        //初始化参数
        configs = WebUtils.GetSystem();
        if (Request["pgnum"] != null)
        {
            if (NumberUtils.IsNum(Request["pgnum"].ToString()))
            {
                pagenum = Request["pgnum"].ToString();
            }
            else
            {
                SetError("您输入的参数非法");
            }
        }
        Search();
        SearchTodayTeam();
        if (Request["s"] != null)
        {
            AddCar();
        }
        if (Request["buy2"] == "确认无误，去结算")
        {
            AddCar();
        }
    }
    //提交订单
    public virtual void AddCar()
    {
        NeedLogin();
        //未付款订单处理方法：在生成订单前。得到1个小时内，此用户的未付款的，购物车的订单。然后将状态更改为cancel 在创建新 订单 
        //OrderFilter of = new OrderFilter();
        //of.State = "scoreunpay";
        //of.User_id = AsUser.Id;

        //using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        //{
        //    seion.Orders.UpdateUnpayOrder(of);
        //}
        bool isfei = false;
        decimal total = 0;
        int num = 0;
        carlist = CookieCar.GetCarData();
        if (carlist != null)
        {
            foreach (Car carmodel in carlist)
            {
                using (IDataSession seion = Store.OpenSession(false))
                {
                    teammodel = seion.Teams.GetByID(Convert.ToInt32(carmodel.Qid));
                }
                if (teammodel != null)
                {
                    if (teammodel.Begin_time <= DateTime.Now && teammodel.End_time >= DateTime.Now && (teammodel.teamscore > 0 || teammodel.Team_type == "point"))
                    {
                        if (Utility.Getbulletin(teammodel.bulletin) != "")
                        {
                            if (carmodel.Result == "")
                            {
                                SetError("友情提示：请选择项目的规格");
                                return;
                            }
                        }
                        if (Helper.GetString(carmodel.Result, "") != "")
                        {
                            num += Utility.Getnum(Server.UrlDecode(carmodel.Result).Replace(".", ",").Replace("-", "|"));
                            total += carmodel.Price * num;
                        }
                        else
                        {
                            num += carmodel.Quantity;
                            total += carmodel.Price * carmodel.Quantity;
                        }
                        if (carmodel.Quantity < 0)
                        {
                            isfei = true;
                        }
                    }
                }
            }
            if (isfei)
            {
                SetError("友情提示：请输入正确的数字");
            }
            else
            {
                ordermodel.User_id = AsUser.Id;
                ordermodel.State = "scoreunpay";//积分购买的订单状态
                ordermodel.Quantity = num;
                ordermodel.Create_time = DateTime.Now;
                if (CurrentCity != null)
                {
                    ordermodel.City_id = CurrentCity.Id;
                }
                else
                {
                    ordermodel.City_id = 0;
                }
                ordermodel.totalscore = Convert.ToInt32(total);
                ordermodel.Express = "Y";
                ordermodel.IP_Address = CookieUtils.GetCookieValue("gourl");
                ordermodel.fromdomain = CookieUtils.GetCookieValue("fromdomain");
                ordermodel.Partner_id = Helper.GetInt(teammodel.Partner_id, 0);
                int orderid = 0;
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    orderid = seion.Orders.Insert(ordermodel);
                }
                foreach (Car carmodel in carlist)
                {
                    using (IDataSession seion = Store.OpenSession(false))
                    {
                        teammodel = seion.Teams.GetByID(Convert.ToInt32(carmodel.Qid));
                    }

                    if (teammodel != null)
                    {
                        if (teammodel.Begin_time <= DateTime.Now && teammodel.End_time >= DateTime.Now && (teammodel.teamscore > 0 || teammodel.Team_type == "point"))
                        {

                            if (Helper.GetString(carmodel.Result, "") != "")
                            {
                                orderdemodel.Num = Utility.Getnum(Server.UrlDecode(carmodel.Result).Replace(".", ",").Replace("-", "|"));
                            }
                            else
                            {
                                orderdemodel.Num = carmodel.Quantity;
                            }
                            orderdemodel.Teamid = Convert.ToInt32(carmodel.Qid);
                            orderdemodel.totalscore = Convert.ToInt32(carmodel.Price);
                            orderdemodel.Order_id = orderid;
                            orderdemodel.result = Server.UrlDecode(carmodel.Result.Replace("-", "|").Replace(".", ","));
                            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                seion.OrderDetail.Insert(orderdemodel);
                            }
                        }
                    }
                }
                //如果启用360并且是360一站通用户(可通过cookie是否存在360_uid判断)则回传订单信息
                if (configs["is360login"] == "1" && CookieUtils.GetCookieValue("360_qid").Length > 0)
                {

                    try
                    {
                        WebClient wc = new WebClient();
                        NameValueCollection updata = new NameValueCollection();
                        updata.Add("key", configs["login360key"]);
                        updata.Add("qid", CookieUtils.GetCookieValue("360_qid"));
                        updata.Add("order_id", orderid.ToString());
                        updata.Add("order_time", ordermodel.Create_time.ToString("yyyyMMddHHmmss"));
                        updata.Add("pid", orderid.ToString());
                        updata.Add("price", ordermodel.Origin.ToString());
                        updata.Add("number", "1");
                        updata.Add("total_price", ordermodel.Origin.ToString());
                        string goods_url = Server.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + GetUrl("订单详情", "order_view.aspx?userid=" + AsUser.Id + "&id=" + orderid));
                        updata.Add("goods_url", goods_url);
                        string title = Server.UrlEncode(String.Format("您在{0}的订单号{0}", ASSystem.abbreviation, orderid));
                        updata.Add("title", title);
                        string desc = Server.UrlEncode(String.Format("您在{0}的订单号{0}", ASSystem.abbreviation, orderid));
                        updata.Add("desc", desc);
                        updata.Add("spend_close_time", String.Empty);
                        string merchant_addr = Server.UrlEncode(ASSystem.abbreviation);
                        updata.Add("merchant_addr", merchant_addr);
                        string temp_sign = Helper.MD5(String.Format("{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}|{9}|{10}|{11}|{12}|{13}", new object[] { updata["key"], updata["qid"], updata["order_id"], updata["order_time"], updata["pid"], updata["price"], updata["number"], updata["total_price"], goods_url, title, desc, updata["spend_close_time"], merchant_addr, configs["login360secret"] }));
                        updata.Add("sign", temp_sign);
                        byte[] temp_result = wc.UploadValues("http://tuan.360.cn/api/deal.php", "POST", updata);
                        string temp_result_string = System.Text.Encoding.UTF8.GetString(temp_result);
                    }
                    catch { }
                }
                CreateOrderOK(orderid);
                Response.Redirect(GetUrl("积分支付", "PointsShop_Pconfir.aspx?orderid=" + orderid + ""));
            }
        }
    }
    /// <summary>
    /// 下单成功后执行的操作
    /// </summary>
    /// <param name="orderid"></param>
    public virtual void CreateOrderOK(int orderid)
    {

    }
    public void Search()
    {
        carlist = CookieCar.GetCarData();
        GetFarfee();
    }
    //快递费的计算规则
    public decimal GetFarfee()
    {
        decimal fee = 0;
        int sum = 0;
        try
        {

            carlist = CookieCar.GetCarData();
            decimal[] num = new decimal[carlist.Count];
            //计算快递费,找出购物车中最大的运费
            for (int i = 0; i < carlist.Count; i++)
            {
                using (IDataSession seion = Store.OpenSession(false))
                {
                    teammodel = seion.Teams.GetByID(Convert.ToInt32(carlist[i].Qid));
                }

                if (teammodel.Begin_time <= DateTime.Now && teammodel.End_time >= DateTime.Now)
                {
                    if (teammodel.Delivery != "coupon")
                    {
                        num[i] = decimal.Parse(carlist[i].Fee);
                        sum += Convert.ToInt32(carlist[i].Quantity);
                    }
                }
            }
            num = Utility.sort(num);
            fee = num[0];
            //根据最大运费，找到项目编号，根据项目编号，找出项目的免单数量
            farfee = Convert.ToInt32(CookieCar.GetProid(fee.ToString()));

            //同时判断全部项目的数量>=运费最大的项目的免单数量如果成立则免运费，不成立则为有运费（为购物车中最大的运费）
            if (sum >= farfee)
            {
                fee = 0;
            }
            else
            {
                fee = num[0];
            }
        }
        catch (Exception ex)
        {

        }
        return fee;
    }

    #region 视图
    public int pages
    {
        get
        {
            if (this.ViewState["pages"] != null)
                return Convert.ToInt32(this.ViewState["pages"].ToString());
            else
                return 1;
        }
        set
        {
            this.ViewState["pages"] = value;
        }
    }

    public string sqlWhere
    {
        get
        {
            string sql = "  teamcata=0 and Begin_time<='" + DateTime.Now.ToString() + "' and End_time>='" + DateTime.Now.ToString() + "' and ((Delivery!='coupon') and ((Max_number>0 and Now_number<Max_number) or(Max_number=0))) and((open_invent=1 and inventory>0)or(open_invent=0))and (Team_type='point')";
            int cityid = Helper.GetInt(CookieUtils.GetCookieValue("cityid"), 0);
            if (cityid != 0)
            {
                sql = sql + " and (City_id=0 or City_id=" + cityid + ")";
            }
            return sql;
        }

    }
    #endregion

    //显示今日积分
    public void SearchTodayTeam()
    {
        int count;
        string txt = sqlWhere;
        url = url + "&pgnum={0}";
        url = GetUrl("积分购物车", "PointsShop_PointCar.aspx?" + url.Substring(1));
        TeamFilter tf = new TeamFilter();
        tf.where = sqlWhere;
        tf.PageSize = 28;
        tf.CurrentPage = Helper.GetInt(Request.QueryString["pgnum"], 1);
        tf.AddSortOrder(TeamFilter.MoreSort);
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = seion.Teams.GetPager(tf);
        }
        teamlist = pager.Objects;
        if (pager.TotalRecords >= 28)
        {
            strpage = WebUtils.GetPagerHtml(28, pager.TotalRecords, pager.CurrentPage, url);
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    jQuery(document).ready(function () {
        jQuery("input[name='quantity-socking']").bind("blur", function () {
            var idval = jQuery(this).attr("idval");
            var maxval = jQuery(this).attr("maxval");
            var minval = jQuery(this).attr("minval");
            shownew(idval, "num" + idval, "price" + idval, "total" + idval, maxval, minval);
        });
    });
    function shownew(teamid, num, price, total, max, min) {
        var s = parseFloat(document.getElementById("sum").innerHTML);
        var n = parseInt(document.getElementById(num).value);
        var p = parseFloat(document.getElementById(price).innerHTML);
        n = isNaN(n) ? '' : n;
        document.getElementById(num).value = n;
        if (n <= 0) {
            document.getElementById(num).value = 1;
            n = 1;
        }
        if (max != 0) {
            if (n > max) {
                document.getElementById(num).value = max;
                n = max;
                alert("友情提示：此项目只可以购买" + max + "个");
            }
        }
        if (min != 0) {
            if (n < min) {
                document.getElementById(num).value = min;
                n = min;
                alert("友情提示：此项目最低购买" + min + "个");
            }
        }
        var t = parseFloat(n * p);
        document.getElementById(total).innerHTML = t.toFixed(2);
        X.get(webroot + "ajax/PCar.aspx?teamid=" + teamid + "&num=" + n);
    }
    function show(teamid, num, price, total, max, min) {
        var s = parseFloat(document.getElementById("sum").innerHTML);
        var n = parseInt(document.getElementById(num).value);
        var p = parseFloat(document.getElementById(price).innerHTML);
        n = isNaN(n) ? '' : n;
        document.getElementById(num).value = n;
        if (isNaN(n)) {
            if (n <= 0) {
                document.getElementById(num).value = 1;
                n = 1;
            }
        }
        if (max != 0) {
            if (n > max) {
                document.getElementById(num).value = max;
                n = max;

                alert("友情提示：此项目只可以购买" + max + "个");
            }
        }
        if (min != 0) {
            if (n < min) {
                document.getElementById(num).value = min;
                n = min;

                alert("友情提示：此项目最低购买" + min + "个");
            }
        }
        var t = parseFloat(n * p);
        document.getElementById(total).innerHTML = t.toFixed(2);
        X.get(webroot + "ajax/PCar.aspx?teamid=" + teamid + "&num=" + n);
    }
    function toal() {

        var t = document.getElementsByTagName("span")

        var n = 0.0;
        for (var i = 0; i < t.length; i++) {
            if (t[i].title == "total") {
                n += parseFloat(t[i].innerHTML);
            }
        }
        document.getElementById("sum").innerHTML = n.toFixed(2);
    }
    function show1(teamid, num, price, total, max, min) {
        var n;
        if (parseInt(document.getElementById(num).value) <= 1) {
            n = 1;
        }
        else {
            n = parseInt(document.getElementById(num).value) - 1;
        }
        var p = parseFloat(document.getElementById(price).innerHTML);
        n = isNaN(n) ? '' : n;
        document.getElementById(num).value = n;
        if (isNaN(n)) {
            if (n <= 0) {
                document.getElementById(num).value = 1;
                n = 1;
            }
        }
        if (max != 0) {
            if (n > max) {
                document.getElementById(num).value = max;
                n = max;

                alert("友情提示：此项目只可以购买" + max + "个");
            }
        }
        if (min != 0) {
            if (n < min) {
                document.getElementById(num).value = min;
                n = min;

                alert("友情提示：此项目最低购买" + min + "个");
            }
        }
        var t = parseFloat(n * p);

        document.getElementById(total).innerHTML = t.toFixed(2); ;
        X.get(webroot + "ajax/PCar.aspx?teamid=" + teamid + "&num=" + n);
    }
    function show2(teamid, num, price, total, max, min) {
        var n = parseInt(document.getElementById(num).value) + 1;
        var p = parseFloat(document.getElementById(price).innerHTML);
        n = isNaN(n) ? '' : n;
        document.getElementById(num).value = n;
        if (isNaN(n)) {
            if (n <= 0) {
                document.getElementById(num).value = 1;
                n = 1;
            }
        }
        if (max != 0) {
            if (n > max) {
                document.getElementById(num).value = max;
                n = max;

                alert("友情提示：此项目只可以购买" + max + "个");
            }
        }
        if (min != 0) {
            if (n < min) {
                document.getElementById(num).value = min;
                n = min;

                alert("友情提示：此项目最低购买" + min + "个");
            }
        }
        var t = parseFloat(n * p);
        document.getElementById(total).innerHTML = t.toFixed(2);
        X.get(webroot + "ajax/PCar.aspx?teamid=" + teamid + "&num=" + n);
    }
    function shopcar(teamid, count, reresult) {
        X.get(webroot + "ajax/coupon.aspx?action=shopcar&teamid=" + teamid + "&count=" + count + "&result=" + reresult + "");
    }
</script>
<form id="form" runat="server">
    <div class="bdw" id="bdw">
        <div class="cf" id="bd">
            <div class="box-content">
                <table width="958" border="0" align="center" cellpadding="0" cellspacing="0" style="padding-left: 10px; padding-right: 10px;">
                    <tr bgcolor="#FFFFFF">
                        <td>
                            <table width="938px" border="0" align="center" cellpadding="0">
                                <tr>
                                    <td>
                                        <img src="<%=PageValue.WebRoot%>upfile/css/i/step1.png" />
                                    </td>
                                </tr>
                            </table>
                            <table width="938px" border="0" align="center" cellpadding="0">
                                <tr>
                                    <td style="border-bottom: 1px dashed rgb(174, 174, 174);"></td>
                                </tr>
                            </table>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td>&nbsp;
                                    </td>
                                </tr>
                            </table>
                            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                <tr>
                                    <td>
                                        <input id="sumhid" type="hidden" />
                                        <% carlist = CookieCar.GetCarData(); %>
                                        <%if (carlist != null)
                                          {
                                              decimal sum = 0;
                                        %>
                                        <table width="930" border="0" cellspacing="0" cellpadding="0">
                                            <tr>
                                                <td colspan="2" align="center" bgcolor="#F2F2F2">项目
                                                </td>
                                                <td width="100" align="center" bgcolor="#F2F2F2">规格
                                                </td>
                                                <td width="174" align="center" bgcolor="#F2F2F2">数量
                                                </td>
                                                <td width="27" align="center" bgcolor="#F2F2F2">&nbsp;
                                                </td>
                                                <td width="96" align="center" bgcolor="#F2F2F2">积分
                                                </td>
                                                <td width="29" align="center" bgcolor="#F2F2F2">&nbsp;
                                                </td>
                                                <td width="100" align="center" bgcolor="#F2F2F2">总积分
                                                </td>
                                                <td width="60" align="center" bgcolor="#F2F2F2">操作
                                                </td>
                                            </tr>
                                            <%foreach (Car model in carlist)
                                              {
                                                  using (IDataSession seion = Store.OpenSession(false))
                                                  {
                                                      teammodel = seion.Teams.GetByID(Convert.ToInt32(model.Qid));
                                                  }

                                                  if (teammodel != null)
                                                  {
                                                      if (teammodel.Begin_time <= DateTime.Now && teammodel.End_time >= DateTime.Now && teammodel.Team_type == "point")
                                                      {

                                                          sum += model.Price * model.Quantity; 
                                                              
                    
                                            %>
                                            <tr>
                                                <td width="132" align="center" bgcolor="#FFFFFF" style="padding: 10px">
                                                    <a href="<%=GetUrl("积分详情","pointsshop_index.aspx?id="+model.Qid)%>"
                                                        target="_blank">
                                                        <img <%=ashelper.getimgsrc(model.Pic) %> class="dynload" style="width: 110px; height: 70px; border: 1px #aeaeae solid" /></a>
                                                </td>
                                                <td width="307" bgcolor="#FFFFFF" style="padding: 10px">
                                                    <a href="<%=GetUrl("积分详情","pointsshop_index.aspx?id="+model.Qid) %>">
                                                        <%=teammodel.Title%></a>
                                                </td>
                                                <td align="center" bgcolor="#FFFFFF" style="padding: 0px; width: 150px;">
                                                    <%
                                                            
                                                          if (Utility.Getbulletin(teammodel.bulletin) != "")
                                                          {
                                                              if (model.Result == "")
                                                              { %>
                                                    <a select="no" href="javascript:shopcar(<%=model.Qid %>, document.getElementById('num<%=model.Qid %>').value, encodeURIComponent('<%=Server.UrlDecode(model.Result) %>'))"
                                                        style="color: red">请选择规格 </a>
                                                    <% }
                                                              else
                                                              {%>
                                                    <img src="<%=PageValue.WebRoot%>upfile/css/i/pcde_416.png" />
                                                    <br />
                                                    <a href="javascript:shopcar(<%=model.Qid %>, document.getElementById('num<%=model.Qid %>').value, encodeURIComponent('<%=Server.UrlDecode(model.Result) %>'))"
                                                        style="color: red">修改 </a>
                                                    <% }
                                                          }
                                                    %>
                                                </td>
                                                <td align="center" bgcolor="#FFFFFF" style="padding: 10px">
                                                    <div class="num_div">
                                                        <%if (Utility.Getbulletin(teammodel.bulletin) != "")
                                                          { %>
                                                        <input type="text" carnum="<%=model.Quantity %>" id="num<%=model.Qid %>" idval="<%=model.Qid %>"
                                                            maxval="<%=model.Weight %>" minval="<%=model.min %>" onclick="shopcar(<%=model.Qid %>,this.value, encodeURIComponent('<%=Server.UrlDecode(model.Result) %>    '))"
                                                            onkeyup="show('<%=model.Qid %>','num<%=model.Qid %>','price<%=model.Qid %>','total<%=model.Qid %>','<%=model.Weight %>','<%=model.min %>')"
                                                            class="input-text f-input1 deal-buy-quantity-input" maxlength="4" name="quantity-socking"
                                                            value="<%=model.Quantity %>" alt="socking1027" category="product" />
                                                        <% }
                                                          else
                                                          {%>
                                                        <span class="crease decrease" onclick="show2('<%=model.Qid %>','num<%=model.Qid %>','price<%=model.Qid %>','total<%=model.Qid %>','<%=model.Weight %>','<%=model.min %>')"></span><span class="crease" onclick="show1('<%=model.Qid %>','num<%=model.Qid %>','price<%=model.Qid %>','total<%=model.Qid %>','<%=model.Weight %>','<%=model.min %>')"></span>
                                                        <input type="text" id="num<%=model.Qid %>" idval="<%=model.Qid %>" maxval="<%=model.Weight %>"
                                                            minval="<%=model.min %>" onkeyup="show('<%=model.Qid %>','num<%=model.Qid %>','price<%=model.Qid %>','total<%=model.Qid %>','<%=model.Weight %>','<%=model.min %>')"
                                                            class="input-text f-input1 deal-buy-quantity-input" maxlength="4" name="quantity-socking"
                                                            value="<%=model.Quantity %>" alt="socking1027" category="product" />
                                                        <% }%>
                                                        <br />
                                                        <br />
                                                    </div>
                                                </td>
                                                <td align="center" bgcolor="#FFFFFF" style="padding: 10px">x
                                                </td>
                                                <td align="center" bgcolor="#FFFFFF" style="padding: 10px">
                                                    <span id="price<%=model.Qid %>">
                                                        <%=model.Price%>积分</span>
                                                </td>
                                                <td align="center" bgcolor="#FFFFFF" style="padding: 10px">=
                                                </td>
                                                <td align="center" bgcolor="#FFFFFF" style="padding: 10px">
                                                    <span id="total<%=model.Qid %>" title="total">
                                                        <%=model.Price * model.Quantity%>积分</span>
                                                </td>
                                                <td align="center" bgcolor="#FFFFFF" style="padding: 10px">
                                                    <a href="<%=PageValue.WebRoot%>ajax/PCar.aspx?delid=<%=model.Qid %>" ask="确认不购买此商品?">删除</a>
                                                </td>
                                            </tr>
                                            <%  
                                                      }
                                                  }
                                              }%>
                                            <tr>
                                                <td colspan="2" bgcolor="#FFFFFF" style="padding: 10px">
                                                    <span style="color: #f00; font-size: 16px; padding-bottom: 5px">兑换积分</span>
                                                </td>
                                                <td bgcolor="#FFFFFF" style="padding: 10px">&nbsp;
                                                </td>
                                                <td bgcolor="#FFFFFF" style="padding: 10px">&nbsp;
                                                </td>
                                                <td bgcolor="#FFFFFF" style="padding: 10px">&nbsp;
                                                </td>
                                                <td bgcolor="#FFFFFF" style="padding: 10px">&nbsp;
                                                </td>
                                                <td bgcolor="#FFFFFF" style="padding: 10px">=
                                                </td>
                                                <td bgcolor="#FFFFFF" style="padding: 10px">
                                                    <span style="color: #f00; font-size: 12px; padding-bottom: 5px"><span id="sum">
                                                        <%=sum%>积分 </span></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="8" bgcolor="#FFFFFF" style="padding: 10px; border-bottom: 0px dashed rgb(174, 174, 174);">
                                                    <input type="submit" onclick="return checksubmit()" class="formbutton" name="buy2"
                                                        value="确认无误，去结算" />
                                                </td>
                                            </tr>
                                        </table>
                                        <script>
                                            function checksubmit() {
                                                if ($("a[select='no']").length > 0) {
                                                    alert("请先选择产品的规格，在提交订单");
                                                    return false;
                                                }
                                                if ($("input[carnum='0']").length > 0) {
                                                    alert("购买产品的数量不能小于0");
                                                    return false;
                                                }
                                                return true;
                                            }
                                        </script>
                                        <%}
                                          else
                                          { %>
                                        <table width="958" border="0" cellspacing="10" cellpadding="0">
                                            <tr>
                                                <td>
                                                    <a href="<%=GetUrl("积分商城","PointsShop_PointList.aspx")%>">
                                                        <img src="<%=ImagePath() %>empty_cart.png" width="442" height="173" /></a>
                                                </td>
                                            </tr>
                                        </table>
                                        <% }%>
                                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                            <tr bgcolor="#FFFFFF">
                                                <td>&nbsp;
                                                </td>
                                            </tr>
                                        </table>
                                        <table width="938px" border="0" align="center" cellpadding="0">
                                            <tr>
                                                <td bgcolor="#FFFFFF" style="border-bottom: 0px dashed rgb(174, 174, 174);">
                                                    <strong><span style="color: #f00; font-size: 16px; padding-bottom: 5px; padding-left: 10px">
                                                        <%if (carlist != null)
                                                          {%>
                                                            还有以下积分项目
                                                            <% }%>
                                                    </span></strong>
                                                </td>
                                            </tr>
                                        </table>
                                        <div class="list_grid">
                                            <!--循环开始（循环deal_shop这个div）-->
                                            <%foreach (ITeam teammodel in teamlist)
                                              {

                                                  if (CookieCar.VerDictCarIsExit(teammodel.Id.ToString()) == false)
                                                  {
                                            %>
                                            <!--正在团购商品开始-->
                                            <div class="deal_shop">
                                                <div class="list_img">
                                                    <a href="<%=GetUrl("积分详情","pointsshop_index.aspx?id="+teammodel.Id)%>"
                                                        target="_blank">
                                                        <img alt="<%=teammodel.Title%>" <%=ashelper.getimgsrc(teammodel.Image) %> class="dynload"
                                                            width="218" height="139"></a>
                                                </div>
                                                <div class="list_bt">
                                                    <a title="<%=GetUrl("积分详情","pointsshop_index.aspx?id="+teammodel.Id)%>"
                                                        target="_blank">
                                                        <%=teammodel.Product %></a>
                                                </div>
                                                <div class="list_jg">
                                                    已有<font><%=teammodel.Now_number%></font>人购买</b><br />
                                                    <div class="dh_price">
                                                        <div class='scj'>
                                                            市场价：<span class='money'><%=ASSystem.currency%></span><%=teammodel.Team_price %>
                                                        </div>
                                                        <br />
                                                        <div class='jifen'>
                                                            积分：<%=teammodel.teamscore%>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="list_botton">
                                                    <a href='<%=PageValue.WebRoot%>ajax/PCar.aspx?id=<%=teammodel.Id%>' title="去看看"></a>
                                                </div>
                                            </div>
                                            <% }
                                              }%>
                                            <!--循环结束-->
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <%=strpage %>
            </div>
        </div>
    </div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>

