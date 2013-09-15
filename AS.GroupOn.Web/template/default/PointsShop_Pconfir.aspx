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
    public IOrder ordermodel = null;
    public IUser user = null;
    public bool falg = false;
    public IList<IOrderDetail> detaillist = null;
    public NameValueCollection _system = new NameValueCollection();
    bool isRedirect = false;
    bool isSame = false;//判断用户的选择的规格是否有一样的
    protected decimal totalprice = 0;//应付总额
    protected decimal fare = 0;//应付运费
    protected bool payselectexpress = false;
    protected ITeam teamodel = null;
    protected bool receiveVisble;
    public bool isinvent = false;//判断订单的数量是否已经超出了库存
    protected bool orderemailvalidVisble = false;
    public bool isExistrule = false;//判断用户是否选择项目所没有的规格
    public int fare_shoping;
    public decimal jian;
    public decimal fan;
    public bool youhui = false;
    public string orderNewId = "";
    public string dispaly = "";
    public int totalpoint = 0;//总积分
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = PageValue.CurrentSystemConfig;
        if (_system["payselectexpress"] == "1")
        {
            payselectexpress = true;
        }
        NeedLogin();
        int orderid = Helper.GetInt(Request["orderid"], 0);
        form.Action = GetUrl("积分支付", "PointsShop_Pconfir.aspx?orderid=" + orderid);
        if (Request.Form["btnadd"] == "确认订单，付款")
        {
            if (IsLogin == false && UserName == "")  //判断普通用户访问讨论区的权限
            {
                Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
            }
            using (IDataSession session = Store.OpenSession(false))
            {
                ordermodel = session.Orders.GetByID(Helper.GetInt(hiorderid.Value, 0));
            }
            if (ordermodel != null && ordermodel.User_id == AsUser.Id)
            {
                if (ordermodel.OrderDetail != null && ordermodel.OrderDetail.Count > 0)
                {
                    AddReceive();//修改收货人信息
                    setUserTable();//修改用户信息
                    if (_system["payselectexpress"] == "1" && Request["express"] == null)
                    {
                        SetError("友情提示：请选择物流公司");
                    }
                    else if (Request["province"] == null)
                    {
                        SetError("友情提示：请选择城市");
                    }
                    else
                    {
                        ConfirmOrder();
                    }

                }
                else
                {
                    SetError("友情提示：请选择购买的项目");
                }
            }
        }

        if (Request["orderid"] != null)
        {
            if (NumberUtils.IsNum(Request["orderid"].ToString()))
            {
                hiorderid.Value = Request["orderid"].ToString();
                using (IDataSession session = Store.OpenSession(false))
                {
                    ordermodel = session.Orders.GetByID(Helper.GetInt(hiorderid.Value, 0));
                }
                if (ordermodel.User_id != AsUser.Id)
                {
                    SetError("友情提示：无法操作其他用户的订单");
                    Response.Redirect(WebRoot + "index.aspx");
                    Response.End();
                    return;

                }
                if (ordermodel != null)
                {
                    if (!Page.IsPostBack)
                    {
                        fare = ActionHelper.System_GetFare(ordermodel.Id, _system, String.Empty, 0);
                        totalpoint = ordermodel.totalscore;
                        totalprice = fare;
                    }
                    string username = ordermodel.Realname;
                    if (ordermodel.User != null)
                    {
                        user = ordermodel.User;
                    }
                    if (user != null)
                    {
                        ordermodel.Realname = user.Realname;
                        ordermodel.Mobile = user.Mobile;
                        ordermodel.Address = user.Address;
                        ordermodel.Zipcode = user.Zipcode;
                    }

                    if (ordermodel.OrderDetail != null && ordermodel.OrderDetail.Count > 0)
                    {
                        //判断项目是否过期或者卖光

                        this.txtremark.Value = ordermodel.Remark;
                        foreach (var model in ordermodel.OrderDetail)
                        {
                            ITeam team = null;
                            team = model.Team;
                            if (team != null)
                            {
                                AS.Enum.TeamState ts = GetState(team);
                                if (team.teamcata == 0)
                                {
                                    if (ts != AS.Enum.TeamState.begin && ts != AS.Enum.TeamState.successbuy)
                                    {
                                        SetError("订单中存在已过期或已卖光的项目，不能支付！");
                                        Response.Redirect(WebRoot + "index.aspx");
                                        Response.End();
                                        return;
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        SetError("友情提示：请选择购买的项目");
                    }
                    if (isbuy(ordermodel.Id, ordermodel.Team_id, ordermodel.User_id))
                    {
                        SetError("友情提示：您已经超过了购买次数");
                        Response.Redirect(WebRoot + "index.aspx");
                        Response.End();
                        return;
                    }
                }
                else
                {
                    SetError("订单不存在");
                    return;
                }
            }
            else
            {
                SetError("您输入的参数非法");
                return;
            }
        }
        else
        {
            SetRefer();
            Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
            Response.End();
            return;
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
    //修改收货人信息
    public void AddReceive()
    {
        ordermodel.Realname = Request["realname"];
        ordermodel.Mobile = Request["mobile"];
        if (Request["county"] != null && Request["address"] != null)
        {
            ordermodel.Address = Request["county"] + "-" + Request["address"];
        }
        else
        {
            ordermodel.Address = Request["county"] + Request["address"];
        }
        ordermodel.Zipcode = Request["zipcode"];
        ordermodel.Fare = ActionHelper.System_GetFare(ordermodel.Id, _system, Helper.GetString(Request["province"], String.Empty), Helper.GetInt(Request["express"], 0));//快递费
        ordermodel.Origin = ordermodel.Fare;
        ordermodel.Express_id = Helper.GetInt(Request["express"], 0);
        string strremark = txtremark.Value;
        if (strremark.IndexOf(@"\") > 0)
        {
            strremark = strremark.Replace(@"\", @"\\");
        }
        ordermodel.Remark = strremark;
        AsUser.Realname = Request["realname"];
        AsUser.Mobile = Request["mobile"];
        AsUser.Address = Request["address"];
        AsUser.Zipcode = Request["zipcode"];
        AsUser.Id = AsUser.Id;
        using (IDataSession session = Store.OpenSession(false))
        {
            session.Users.Update(AsUser);
            session.Orders.Update(ordermodel);
        }
    }
    //根据订单的编号，获取用户表是否存在，如果存在则不增加，如果存在则添加
    public void setUserTable()
    {
        if (ordermodel != null)
        {
            IUser usermodel = ordermodel.User;
            if (usermodel != null)
            {
                if (Request.Form["realname"] != null && Request.Form["mobile"] != null && Request.Form["address"] != null && Request.Form["zipcode"] != null)
                {
                    if (usermodel.Realname == "")
                        usermodel.Realname = Request.Form["realname"].ToString();
                    if (usermodel.Mobile == "")
                        usermodel.Mobile = Request.Form["mobile"].ToString();
                    if (usermodel.Address == "")
                        usermodel.Address = Request.Form["address"].ToString();
                    if (usermodel.Zipcode == "")
                        usermodel.Zipcode = Request.Form["zipcode"].ToString();
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        session.Users.Update(usermodel);
                    }
                }
            }
        }
    }
    public ICard GetTeamid(int teamid, int orderid)
    {
        ICard card = null;
        IList<ICard> cardlist = null;
        CardFilter cf = new CardFilter();
        cf.Team_id = teamid;
        cf.Order_id = orderid;
        using (IDataSession session = Store.OpenSession(false))
        {
            cardlist = session.Card.GetList(cf);
        }
        if (cardlist != null && cardlist.Count > 0)
        {
            card = cardlist[0];
        }
        return card;
    }
    #region 如果用户当前余额可以付款，那么修改订单状态
    public void ConfirmOrder()
    {
        Response.Redirect(GetUrl("积分确认", "PointsShop_Service.aspx?orderid=" + hiorderid.Value + ""));
        Response.End();
        return;
    }
    #endregion

    //根据项目编号，查询项目内容
    public string GetTeam(string id)
    {
        using (IDataSession session = Store.OpenSession(false))
        {
            teamodel = session.Teams.GetByID(Helper.GetInt(id, 0));
        }
        if (teamodel != null)
            return teamodel.Title;
        else
            return "";
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript" language="javascript">
    var num = 0;
    var txt;
    var sum = 0;
    function additem(id, rule, obj, txt, teamid) {
        var texts = $("input[num_tid='" + teamid + "'][type='text']");
        var td = $("td[tid='" + teamid + "']");
        var nownumber = 0;
        var totalnumber = 0;
        totalnumber = parseInt($(td).html());
        for (var i = 0; i < $(texts).length; i++) {
            if (parseInt($(texts).eq(i).val()) <= 0) {
                alert("数量应大于0");
                return false;
            }
            nownumber = nownumber + parseInt($(texts).eq(i).val());
        }

        if (nownumber >= totalnumber) {
            alert("数量已满,不能增加");
            return;
        }
        var row, cell, str;
        row = document.getElementById(id).insertRow(-1);
        if (row != null) {
            cell = row.insertCell(-1);
            cell.innerHTML = document.getElementById(rule).innerHTML;
            cell.className = "deal-buy-desc";
            cell.style.backgroundColor = "#e4e4e4";
            cell.setAttribute("colspan", 6)
            cell.id = "rule";
            var t = cell.getElementsByTagName("input");
            t[0].value = totalnumber - nownumber;

        }
        num++
        document.getElementsByName("totalNumber")[0].value = num;
    }
    function deleteitem(obj, id, teamid, totalnumber) {
        var texts = $("input[num_tid='" + teamid + "'][type='text']");
        var rowNum, curRow, ce;
        curRow = obj.parentNode.parentNode;
        rowNum = document.getElementById(id).rows.length - 1;
        ce = document.getElementById(id).rows[rowNum].getElementsByTagName("input")[0].value;
        if (rowNum >= 1) {

            if (parseInt($(texts[0]).val()) + parseInt(ce) > totalnumber) {
                alert("数量已满,不能增加");
                document.getElementById(id).deleteRow(curRow.rowIndex);
                return;
            }
            $(texts[0]).val(parseInt($(texts[0]).val()) + parseInt(ce));
            document.getElementById(id).deleteRow(curRow.rowIndex);
        }

    }
    function isNum() {
        if (event.keyCode < 48 || event.keyCode > 57) {
            event.keyCode = 0;
        }
    }
    function clearNoNum(obj) {
        if ((obj.value != "") && (isNaN(obj.value) || parseInt(obj.value) <= 0)) {
            obj.value = "1";
        }

    }
</script>
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
        function changecity(pid) {
            X.boxShow('正在加载省市区列表,请稍后...', false);
            var sels = $("#citylist").find("select");
            var str = "";
            var candel = false;
            var obj = null;
            var citynames = "";
            var cityids = "";
            for (var i = 0; i < sels.length; i++) {
                if (!candel) {
                    str = str + "-" + sels.eq(i).val();
                    citynames = citynames + "," + sels.eq(i).val();
                    cityids = cityids + "," + sels.eq(i).find("option:selected").attr("oid");

                }
                else
                    sels.eq(i).remove();

                if (sels.eq(i).attr("pid") == pid) {
                    candel = true;
                    obj = sels.eq(i);
                }
            }
            if (pid == 0 && $("select[pid='" + pid + "']").val() != "")//当选择省份时重新判断运费
            {
                getfare();
            }
            if (str.length > 0)
                str = str.substr(1);
            if (citynames.length > 0) {
                citynames = citynames.substr(1);
                cityids = cityids.substr(1);
            }
            $("#area").html(str);
            $("#county").val(str);
            if (obj != null) {
                var oid = obj.find("option:selected").attr("oid");
                if (oid != null) {
                    var u = webroot + "ajax/citylist.aspx?pid=" + oid;
                    $.ajax({
                        type: "POST",
                        url: u,
                        data: null,
                        success: function (msg) {
                            X.boxClose();
                            if (msg != "") {
                                $("#citylist").append(msg);
                                $("#expressarea").html("");
                            }
                            else {
                        <%if (payselectexpress)
                          { %>

                                X.boxShow('正在加载快递公司信息,请稍后...', false);
                                $.ajax({
                                    type: "POST",
                                    url: webroot + "ajax/express.aspx",
                                    data: { "citys": cityids },
                                    success: function (msg) {
                                        X.boxClose();
                                        $("#expressarea").html(msg);
                                        getfare();
                                    }
                                });

                            <%} %>

                            }
                        }
                    });
                }
            }
        }
        function selectexpress(id) {
            getfare();
        }
        function getfare() {
            var orderid = $("#hiorderid").val();
            var citynames = "";
            var expressid = 0;
            var tmp_city = $("select[name='province']");
            if (tmp_city.length == 1) {
                citynames = tmp_city.val();
            }
            var tmp_express = $("input[name='express']:checked");
            if (tmp_express.length == 1) {
                expressid = tmp_express.val();
            }
            $.ajax({
                type: "POST",
                url: webroot + "ajax/getfare.aspx",
                data: { "city": citynames, "expressid": expressid, "id": orderid },
                success: function (msg) {
                    var teamprice = $("td[total='teamprice']");
                    var totalprice = 0;
                    for (var i = 0; i < teamprice.length; i++) {
                        totalprice = totalprice + parseFloat(teamprice.eq(i).html());
                    }
                    var fareprice = parseFloat(msg);
                    totalprice = fareprice;

                    $("span[total='fareprice']").html("<%=ASSystem.currency%>" + fareprice);
                    $("td[total='totalprice']").html("<%=ASSystem.currency%>" + totalprice.toFixed(2));
                }
            });
        }

    </script>
    <asp:hiddenfield id="hiorderid" runat="server" />
    <input type="hidden" name="county" id="county">
    <div id="bdw" class="bdw">
        <%if (ordermodel != null)
          { %>
        <div id="bd" class="cf">
            <div id="content">
                <div id="deal-buy" class="box">
                    <input type="hidden" name="totalNumber" value="" />
                    <div class="box-content">
                        <img src="<%=ImagePath()%>step2.png" width="660" height="69" />
                        <div class="head">
                            <h2>您的订单</h2>
                        </div>
                        <div class="sect">
                            <table class="order-table">
                                <tr>
                                    <th class="deal-buy-desc">项目名称
                                    </th>
                                    <th class="deal-buy-quantity">数量
                                    </th>
                                    <th class="deal-buy-multi"></th>
                                    <th class="deal-buy-price">积分
                                    </th>
                                    <th class="deal-buy-price"></th>
                                    <th class="deal-buy-total">总积分
                                    </th>
                                </tr>
                                <% detaillist = ordermodel.OrderDetail; %>
                                <%  int num = 0; %>
                                <%foreach (var model in detaillist)
                                  { %>
                                <tr>
                                    <td class="deal-buy-desc" style="width: 400px;">
                                        <%= GetTeam(model.Teamid.ToString())%><font style="color: red"><%=WebUtils.Getbulletin(model.result)%></font>
                                    </td>
                                    <td t="totalnum" tid="<%=model.Teamid %>" class="deal-buy-quantity">
                                        <%=model.Num%>
                                    </td>
                                    <td class="deal-buy-multi">x
                                    </td>
                                    <td class="deal-buy-price" id="deal-buy-price">
                                        <span class="money"><span>
                                            <%=model.totalscore%>积分
                                    </td>
                                    <td class="deal-buy-price">=
                                    </td>
                                    <td class="deal-buy-total" id="deal-buy-total" total="teamprice">
                                        <%=Math.Max(Convert.ToDecimal(model.Num*model.totalscore-model.Credit),0)%>积分
                                    </td>
                                </tr>
                                <% }%>
                                <tr>
                                    <td class="deal-buy-desc">快递
                                    </td>
                                    <td class="deal-buy-quantity"></td>
                                    <td class="deal-buy-multi"></td>
                                    <td class="deal-buy-price">
                                        <span id="deal-express-price" total="fareprice">
                                            <%=ASSystem.currency%><%=fare%>
                                        </span>
                                    </td>
                                    <td class="deal-buy-price"></td>
                                    <td class="deal-buy-total"></td>
                                </tr>
                                <tr class="order-total">
                                    <td class="deal-buy-desc">
                                        <strong>应付总积分：</strong>
                                    </td>
                                    <td class="deal-buy-quantity"></td>
                                    <td class="deal-buy-multi"></td>
                                    <td class="deal-buy-price"></td>
                                    <td class="deal-buy-price">=
                                    </td>
                                    <td class="deal-buy-total">
                                        <%=totalpoint%>积分
                                    </td>
                                </tr>
                                <tr class="order-total">
                                    <td class="deal-buy-desc">
                                        <strong>应付总额：</strong>
                                    </td>
                                    <td class="deal-buy-quantity"></td>
                                    <td class="deal-buy-multi"></td>
                                    <td class="deal-buy-price"></td>
                                    <td class="deal-buy-price">=
                                    </td>
                                    <td class="deal-buy-total" total="totalprice">
                                        <%=ASSystem.currency%><%=totalprice%>
                                    </td>
                                </tr>
                            </table>
                            <div class="field username">
                                <label>
                                    收件人</label>
                                <%if (CookieUtils.GetCookieValue("fullname") != null && CookieUtils.GetCookieValue("fullname") != "")
                                  {%>
                                <input type="text" size="30" name="realname" id="Text4" class="f-input" value="<%=CookieUtils.GetCookieValue("fullname")%>"
                                    require="true" datatype="require" group="a" />
                                <%}
                                  else
                                  { %>
                                <input type="text" size="30" name="realname" id="settingsrealname" class="f-input"
                                    value="<%= user.Realname%>" require="true" datatype="require" group="a" />
                                <%} %>
                                <span class="hint">收件人请与有效证件姓名保持一致，便于收取物品</span>
                            </div>
                            <div class="field mobile">
                                <label>
                                    手机号码</label>
                                <%if (CookieUtils.GetCookieValue("mobile_phone") != null && CookieUtils.GetCookieValue("mobile_phone") != "")
                                  {%>
                                <input type="text" size="30" name="mobile" id="Text1" class="number" value="<%=CookieUtils.GetCookieValue("mobile_phone") %>"
                                    group="a" require="true" datatype="mobile" maxlength="11" />
                                <%}
                                  else
                                  { %>
                                <input type="text" size="30" name="mobile" id="settingsmobile" class="number" value="<%=user.Mobile %>"
                                    group="a" require="true" datatype="mobile" maxlength="11" />
                                <%} %>
                                <span class="hint">手机号码是我们联系您最重要的方式，请准确填写</span>
                            </div>
                            <div class="field username">
                                <label>
                                    省市区(必填)</label>
                                <div id="citylist" class="cityclass">
                                </div>
                                <span id="area" class="hint_kd"></span><span class="hint">城市必须选择</span>
                            </div>
                            <div class="field username">
                                <label>
                                    街道地址(必填)</label>
                                <%if (CookieUtils.GetCookieValue("address") != null && CookieUtils.GetCookieValue("address") != "")
                                  {%>
                                <input type="text" size="30" name="address" id="Text2" class="f-input" value="<%=CookieUtils.GetCookieValue("address") %>"
                                    group="a" require="true" datatype="require" />
                                <% }
                                  else
                                  {%>
                                <input type="text" size="30" name="address" id="settingsaddress" class="f-input"
                                    value="<%=user.Address %>" group="a" require="true" datatype="require" />
                                <%} %>
                                <span class="hint">街道具体地址</span>
                            </div>
                            <script>
                                $("#citylist").load(webroot + "ajax/citylist.aspx?pid=0", null, function (data) {

                                });
                            </script>
                            <div id="expressarea" class="field mobile">
                            </div>
                            <div class="field mobile">
                                <label>
                                    邮政编码</label>
                                <%if (CookieUtils.GetCookieValue("post") != null && CookieUtils.GetCookieValue("post") != "")
                                  {%>
                                <input type="text" size="30" name="zipcode" id="Text3" class="number" value="<%=CookieUtils.GetCookieValue("post") %>"
                                    group="a" require="true" datatype="zip" maxlength="6" />
                                <%}
                                  else
                                  { %>
                                <input type="text" size="30" name="zipcode" id="settingszipcode" class="number" value="<%=user.Zipcode %>"
                                    group="a" require="true" datatype="zip" maxlength="6" />
                                <%} %>
                            </div>
                            <div class="field mobile">
                                <label>
                                    订单附言</label>
                                <textarea name="remark" id="txtremark" rows="6" size="30" cols="6" runat="server"
                                    class="f-input"></textarea>
                            </div>
                        </div>
                        <div class="clear">
                        </div>
                        <div style="margin-bottom: 10px; margin-left: 10px;">
                            <input type="submit" value="确认订单，付款" class="formbutton validator" name="btnadd" group="a" />
                            <span id="errorexpressarea"></span><span id="errorcitylist"></span>&nbsp;&nbsp;
                                <a href="<%=GetUrl("积分购物车", "PointsShop_PointCar.aspx")%>">返回修改订单</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <%} %>
    </div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>