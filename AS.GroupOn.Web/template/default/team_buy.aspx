<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public string strFarefree = "";
    public string strDelivery = "";
    public string strExpress = "";
    public string strPrice = "";
    public string strOrigin = "";
    public string strTitle = "";
    public string strQuantity = "1";
    public string strPer_number = "";
    public string strToTal = "";
    public string strMoney = "";
    protected int Farefree = 0;
    protected string str_Fare = "0";
    public IOrder ordermodel = Store.CreateOrder();
    public IList<IOrder> orderlist = null;
    public ITeam teammodel = Store.CreateTeam();
    public NameValueCollection _system = new NameValueCollection();
    protected NameValueCollection teamarr = new NameValueCollection();
    public IUser usermodel = null;
    int Order_ID = 0;//订单ID
    protected bool payselectexpress = false;
    public string strTeamID = "";
    public string stradress = "";
    protected decimal fare = 0;//应付运费
    protected decimal totalprice = 0;//应付总额
    protected bool receiveVisble = false;
    protected bool orderemailvalidVisble = false;
    public string result = "";
    public int userid;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //获取系统配置文件中的信息
        _system = WebUtils.GetSystem();
        if (_system["payselectexpress"] == "1")
        {
            payselectexpress = true;
        }
        form.Action = GetUrl("优惠卷购买", "team_buy.aspx?id=" + Helper.GetInt(Request["id"], 0));
        if (Helper.GetInt(Request["orderid"], 0) > 0)
        {
            form.Action += "&orderid=" + Helper.GetInt(Request["orderid"], 0);
        }
        if (!Page.IsPostBack)
        {
            if (Request["id"] != null)
            {
                if (!NumberUtils.IsNum(Request["id"].ToString()))
                {
                    SetError("参数错误！");
                    Response.Redirect(WebRoot + "index.aspx");
                    return;
                }
                //如果购物车中的项目编号不是当前的项目编号，那么清空cookie
                if (Helper.GetInt(OrderMethod.buyid(), 0) != Helper.GetInt(Request["id"].ToString(), 0))
                {
                    CookieCar.ClearCar();
                }
                else
                {
                    strQuantity = Utility.Getnum(Server.UrlDecode(OrderMethod.buyresult()).Replace(".", ",").Replace("-", "|")).ToString();
                }
                result = Server.UrlDecode(OrderMethod.buyresult()).Replace(".", ",").Replace("-", "|");
                //判断如果用户没有登录或者注册，那么不执行这段代码，
                if (AsUser.Id != 0)
                {
                    //判断如果项目之可以购买一次，并且，用户在项目下过成功订单，那么用户不可以购买此项目，
                    Judge(Helper.GetInt((Request["id"].ToString()), 0));
                }
            }
            initPostInfo();  //查询用户的信息
            initPage();      //查询项目的信息
        }

    }
    //写入order表中
    public virtual void AddCar(IOrder model)
    {
        NeedLogin();
        Judge(Helper.GetInt((model.Team_id), 0));
        if (teammodel != null)
        {
            if (teammodel.Farefree == 0)
            {
                ordermodel.Fare = model.Fare;
            }
            else
            {
                if (teammodel.Farefree >= model.Quantity)
                {
                    ordermodel.Fare = model.Fare;
                }
            }
        }
        ordermodel.Team_id = model.Team_id;
        ordermodel.Partner_id = model.Partner_id;
        ordermodel.Quantity = model.Quantity;
        ordermodel.Price = model.Price;
        ordermodel.Realname = model.Realname;
        ordermodel.Remark = model.Remark;
        ordermodel.User_id = AsUser.Id;
        ordermodel.Zipcode = model.Zipcode;
        ordermodel.Address = model.Address;
        ordermodel.State = "unpay";
        TeamFilter tf = new TeamFilter();
        tf.Id = Convert.ToInt32(model.Team_id);
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = seion.Teams.Get(tf);
        }
        ordermodel.result = model.result;
        ordermodel.Express = model.Express;
        ordermodel.Express_id = model.Express_id;
        ordermodel.Create_time = DateTime.Now;
        if (CurrentCity != null)
        {
            ordermodel.City_id = CurrentCity.Id;
        }
        ordermodel.Mobile = model.Mobile;
        ordermodel.Origin = model.Origin;
        ordermodel.IP_Address = CookieUtils.GetCookieValue("gourl");
        ordermodel.fromdomain = CookieUtils.GetCookieValue("fromdomain");
        AsUser.Realname = model.Realname;
        AsUser.Mobile = model.Mobile;
        AsUser.Address = Request["address"];
        AsUser.Zipcode = Request["zipcode"];
        AsUser.Id = AsUser.Id;
        int orderid;
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            seion.Users.Update(AsUser);
            seion.Orders.Insert(ordermodel);
            orderid = seion.Orders.GetMaxId();
        }
        Order_ID = orderid;
        CreateOrderOK(Order_ID);
    }
    /// <summary>
    /// 下单成功后执行的操作
    /// </summary>
    /// <param name="orderid"></param>
    public virtual void CreateOrderOK(int orderid)
    {

    }
    //判断如果项目之可以购买一次，并且，用户在项目下过成功订单，那么用户不可以购买此项目，
    public void Judge(int teamid)
    {
        IUser userinfo = Store.CreateUser();
        UserFilter uf = new UserFilter();
        uf.Username = UserName;
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            userinfo = seion.Users.GetByName(uf);
        }
        if (userinfo != null)
        {
            userid = userinfo.Id;
        }
        OrderFilter of = new OrderFilter();
        of.User_id = userid;
        of.Team_id = teamid;
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            orderlist = seion.Orders.GetList(of);
        }
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(teamid);
        }
        if (teammodel == null)
        {
            SetError("没有该项目");
            Response.Redirect(WebRoot + "index.aspx");
            Response.End();
            return;
        }
        int buycount = 0;
        bool unpay = false;
        int orderid = 0;
        if (orderlist != null && orderlist.Count > 0)
        {
            for (int i = 0; i < orderlist.Count; i++)
            {
                if (orderlist[i].State == "unpay")
                {
                    unpay = true;
                    orderid = orderlist[i].Id;
                    break;
                }
                else
                {
                    if (orderlist[i].State != "cancel")
                    {
                        buycount = buycount + 1;
                    }
                }
            }
        }
        if (unpay)
        {
            Response.Redirect(GetUrl("优惠卷确认","order_check.aspx?orderid=" + orderid));
            Response.End();
            return;
        }
        AS.Enum.TeamState ts = GetState(teammodel);
        if (ts != AS.Enum.TeamState.begin && ts != AS.Enum.TeamState.successbuy)
        {
            SetError("该项目不能购买");
            Response.Redirect(WebRoot + "index.aspx");
            Response.End();
            return;
        }
        if (teammodel.Buyonce == "Y")
        {
            if (buycount > 0)
            {
                SetError("您已经购买过此项目，当前项目只允许购买一次");
                //Response.Redirect(getTeamPageUrl(Helper.GetString(_system["isrewrite"], "0"), teamid));
                Response.Redirect(WebRoot + "index.aspx");
                Response.End();
                return;
            }
        }
    }
    //显示项目的信息
    private void initPage()//此代码太臃肿了，以后优化
    {
        StringBuilder sb = new StringBuilder();//显示项目信息
        StringBuilder sb1 = new StringBuilder();//显示快递信息
        StringBuilder sb2 = new StringBuilder();//显示订单总额信息
        if (Request["id"] == null || Request["id"].ToString() == "")
        {
            //根据订单编号，显示订单信息
            if (Request["orderid"] != null && Request["orderid"].ToString() != "")
            {
                if (!NumberUtils.IsNum(Request["orderid"].ToString()))
                {
                    SetError("参数错误！");
                    Response.Redirect(WebRoot + "index.aspx");
                    return;
                }
                //用户无法修改其他用户的额单子
                if (OrderMethod.IsUserOrder(AsUser.Id, Helper.GetInt(Request["orderid"], 0)))
                {
                    SetError("友情提示：无法操作其他用户的订单");
                    Response.Redirect(WebRoot + "index.aspx");
                    Response.End();
                    return;
                }

                IOrder mOrder = Store.CreateOrder();
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mOrder = seion.Orders.GetByID(Helper.GetInt(Request["orderid"], 0));
                }
                if (mOrder != null)
                {
                    strQuantity = mOrder.Quantity.ToString();
                    strTeamID = mOrder.Team_id.ToString();
                    txtremark.Value = mOrder.Remark;
                    result = mOrder.result.Replace(".", ",").Replace("-", "|");
                    if (CookieUtils.GetCookieValue("mobile_phone") != null && CookieUtils.GetCookieValue("mobile_phone") != "")
                    {
                        settingsmobile.Value = CookieUtils.GetCookieValue("mobile_phone");
                    }
                    else
                    {
                        settingsmobile.Value = mOrder.Mobile;
                    }
                    if (CookieUtils.GetCookieValue("address") != null && CookieUtils.GetCookieValue("address") != "")
                    {
                        stradress = CookieUtils.GetCookieValue("address");
                    }
                    else
                    {
                        if (AsUser.Id != 0)
                        {
                            stradress = AsUser.Address;
                        }
                        else
                        {
                            stradress = mOrder.Address;
                        }
                    }
                    if (CookieUtils.GetCookieValue("post") != null && CookieUtils.GetCookieValue("post") != "")
                    {
                        settingszipcode.Value = CookieUtils.GetCookieValue("post");
                    }
                    else
                    {
                        settingszipcode.Value = mOrder.Zipcode;
                    }
                    if (CookieUtils.GetCookieValue("fullname") != null && CookieUtils.GetCookieValue("fullname") != "")
                    {
                        settingsrealname.Value = CookieUtils.GetCookieValue("fullname");
                    }
                    else
                    {
                        settingsrealname.Value = mOrder.Realname;
                    }
                }
                else
                {
                    SetError("没有该订单！");
                    Response.Redirect(WebRoot + "index.aspx");
                    return;
                }
            }
            else
            {
                Response.Redirect(WebRoot + "index.aspx");
                Response.End();
                return;
            }
        }
        else
        {
            strTeamID = Request["id"].ToString();

        }
        hiteamid.Value = strTeamID;
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(int.Parse(strTeamID));
        }
        if (Request.Form["num"] == null || Request.Form["num"].ToString() == "")
        {
            if (teammodel.Per_minnumber != 0 && int.Parse(strQuantity) <= 1)
            {
                strQuantity = teammodel.Per_minnumber.ToString();
            }
        }
        else
        {
            strQuantity = Request.Form["num"].ToString();
        }
        if (teammodel == null)
        {
            SetError("没有该项目信息");
            Response.Redirect(WebRoot + "index.aspx");
            Response.End();
            return;
        }
        AS.Enum.TeamState ts = GetState(teammodel);
        if (ts != AS.Enum.TeamState.begin && ts != AS.Enum.TeamState.successbuy)
        {
            SetError("该项目不能购买");
            Response.Redirect(WebRoot + "index.aspx");
            Response.End();
            return;
        }
        strFarefree = teammodel.Farefree.ToString();
        Farefree = teammodel.Farefree;
        strDelivery = teammodel.Delivery;
        strExpress = teammodel.Express;
        strPrice = teammodel.Team_price.ToString();
        if (teammodel.invent_result != null)
        {
            if (Server.UrlDecode(OrderMethod.buyresult()).Replace(".", ",").Replace("-", "|") != "" && teammodel.invent_result.Contains("价格"))
            {
                string result = Server.UrlDecode(OrderMethod.buyresult()).Replace(".", ",").Replace("-", "|");
                strPrice = Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, result);
            }
        }
        if (strDelivery == "express")
        {
            pExpress.Visible = true;
        }
        teamarr = Helper.GetObjectProtery(teammodel);
        if (teammodel.Delivery == "express")
        {
            fare = ActionHelper.System_GetFare(int.Parse(strTeamID), int.Parse(strQuantity), _system, String.Empty, 0);
            totalprice = decimal.Parse(strQuantity) * decimal.Parse(strPrice.ToString());
            totalprice = fare + totalprice;
        }
        totalprice = decimal.Parse(strQuantity) * decimal.Parse(strPrice.ToString());
        totalprice = fare + totalprice;

    }
    //据用户名，显示用户的信息
    private void initPostInfo()
    {
        //是否是支付宝的一站通，如果是就提交到收获地址页面
        if (AsUser.Id != 0)
        {
            if (CookieUtils.GetCookieValue("post") != null && CookieUtils.GetCookieValue("post") != "")
            {
                settingszipcode.Value = CookieUtils.GetCookieValue("post");
            }
            else
            {
                settingszipcode.Value = AsUser.Zipcode;
            }
            if (CookieUtils.GetCookieValue("mobile_phone") != null && CookieUtils.GetCookieValue("mobile_phone") != "")
            {
                settingsmobile.Value = CookieUtils.GetCookieValue("mobile_phone");
            }
            else
            {
                settingsmobile.Value = AsUser.Mobile;
            }
            if (CookieUtils.GetCookieValue("address") != null && CookieUtils.GetCookieValue("address") != "")
            {
                stradress = CookieUtils.GetCookieValue("address");
            }
            else
            {
                stradress = AsUser.Address;
            }
            if (CookieUtils.GetCookieValue("fullname") != null && CookieUtils.GetCookieValue("fullname") != "")
            {
                settingsrealname.Value = CookieUtils.GetCookieValue("fullname");
            }
            else
            {
                settingsrealname.Value = AsUser.Realname;
            }
            strMoney = AsUser.Money.ToString();
        }
    }

    //提交按钮
    protected void submit_ServerClick(object sender, EventArgs e)
    {
        NeedLogin();
        string strOrderID = "";
        //orderid此参数，是否修改订单信息
        if (Request["orderid"] != null && Request["orderid"].ToString() != "")
        {
            if (!NumberUtils.IsNum(Request["orderid"].ToString()))
            {
                SetError("参数错误！");
                Response.Redirect(WebRoot + "index.aspx");
                return;
            }
            strOrderID = Request["orderid"].ToString();
            IOrder mOrder = Store.CreateOrder();
            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                mOrder = seion.Orders.GetByID(int.Parse(strOrderID));
            }
            if (mOrder != null)
            {
                strTeamID = mOrder.Team_id.ToString();
            }
        }
        else
        {
            if (!NumberUtils.IsNum(Request["id"].ToString()))
            {
                SetError("参数错误！");
                Response.Redirect(WebRoot + "index.aspx");
                return;
            }
            strTeamID = Request["id"].ToString();
            //判断如果项目之可以购买一次，并且，用户在项目下过成功订单，那么用户不可以购买此项目，
            Judge(Convert.ToInt32(Request["id"].ToString()));
        }
        //根据项目编号，查询项目的信息
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(int.Parse(strTeamID));
        }

        //2011-04-22修改，用户购买的数量超过最高数量减去已购买数量
        if (teammodel != null)
        {
            if (teammodel.Max_number != 0)
            {
                if (teammodel.Max_number - teammodel.Now_number < Convert.ToInt32(Request["num"]))
                {
                    SetError("您购买的数量已超过该项目的最高数量,您还能购买此项目" + (teammodel.Max_number - teammodel.Now_number).ToString() + "个！");
                    //Response.Redirect(getTeamPageUrl(Helper.GetString(_system["isrewrite"], "0"), int.Parse(strTeamID)));
                    Response.Redirect(WebRoot + "index.aspx");
                    return;
                }
            }
        }
        else
        {
            SetError("没有该项目信息！");
            return;
        }

        //如果没有选择规格，
        if (Helper.GetString(Utility.Getbulletin(teammodel.bulletin), "") != "")
        {
            if (OrderMethod.buyresult() == "")
            {
                SetError("友情提示：请选择项目的规格");
                return;
            }
        }
        if (teammodel != null)
        {
            if (teammodel.Delivery == "express")
                if (teamarr["payselectexpress"] == "1" && Request["express"] == null)
                {
                    SetError("友情提示：请选择物流公司");
                }
                else if (Request["province"] == null)
                {
                    SetError("友情提示：请选择城市");
                }
        }
        strFarefree = teammodel.Farefree.ToString(); //项目表中的免单数量
        strDelivery = teammodel.Delivery;            //项目表中的快递方式
        strExpress = teammodel.Express;              //项目表中的配送说明
        strPrice = teammodel.Team_price.ToString();  //项目表中的团购价格
        if (strOrderID != "")
        {
            str_Fare = ActionHelper.System_GetFare(int.Parse(strOrderID), _system, Helper.GetString(Request["province"], String.Empty), Helper.GetInt(Request["express"], 0)).ToString();//          //项目表中的快递费
        }
        else
        {
            str_Fare = teammodel.Fare.ToString();          //项目表中的快递费
        }
        //订单总额：商品数量*商品团购价格
        string strNum = Request.Form["num"].ToString();
        float iPTotal = int.Parse(Request.Form["num"].ToString()) * float.Parse(teammodel.Team_price.ToString());
        if (Server.UrlDecode(OrderMethod.buyresult()).Replace(".", ",").Replace("-", "|") != "" && teammodel.invent_result.Contains("价格"))
        {
            string result = Server.UrlDecode(OrderMethod.buyresult()).Replace(".", ",").Replace("-", "|");
            iPTotal = int.Parse(Request.Form["num"].ToString()) * float.Parse(Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, result));
        }
        //计算项目表中的免单数量
        if (teammodel.Delivery == "express")
        {
            if (int.Parse(Request.Form["num"].ToString()) < int.Parse(strFarefree)) //如果选取数量<免单数量，那么订单总额需要加上快递费
            {

                strOrigin = (iPTotal + teammodel.Fare).ToString();
            }
            else//     如果选取数量>免单数量，那么订单总额就不需要加上快递费                                               
            {
                if (Request["num"] == "1" && strFarefree != "1") //做这个判断是因为，页面初始化时，数量文本框默认为1，如果免单数量为0，根据判断，选取项目数量(1)>免单数量(0),那么订单总额就不需要加上快递费 ，逻辑有问题，在此判断一下
                {
                    strOrigin = (iPTotal + teammodel.Fare).ToString();
                }
                else
                {
                    if (strFarefree == "0")
                    {
                        strOrigin = (iPTotal + teammodel.Fare).ToString();
                    }
                    else
                    {
                        str_Fare = "0";
                        strOrigin = iPTotal.ToString();
                    }
                }

            }
        }
        else
        {
            str_Fare = "0";
            strOrigin = iPTotal.ToString();
        }
        int orderid = 0;
        if (Convert.ToInt32(Request["num"]) < 0)
        {
            SetError("友情提示：请输入正确的数字");
        }
        else
        {
            //判断订单是否需要修改
            if (Request["orderid"] != null && Request["orderid"].ToString() != "")
            {
                
                if (!NumberUtils.IsNum(Request["orderid"].ToString()))
                {
                    SetError("参数错误！");
                    Response.Redirect(WebRoot + "index.aspx");
                    return;
                }
                orderid = int.Parse(Request["orderid"].ToString());
                UpdateOrder(orderid, strOrigin, str_Fare);
                Response.Redirect(GetUrl("优惠卷确认","order_check.aspx?orderid=" + orderid));
                Response.End();
                return;

            }
            else
            {
                IOrder mOrder = Store.CreateOrder();

                if (Request["county"] != null && Request["address"] != null)
                {
                    mOrder.Address = Helper.GetSubString(Request["county"] + "-" + Request["address"], 128);
                }
                else
                {
                    mOrder.Address = Helper.GetSubString(Request["county"] + Request["address"], 128);
                }
                mOrder.Quantity = int.Parse(Request.Form["num"].ToString());
                mOrder.Create_time = DateTime.Now;
                mOrder.Zipcode = settingszipcode.Value;

                if (strDelivery == "express")
                {
                    mOrder.Express = "Y";
                }
                else if (strDelivery == "coupon")
                {
                    mOrder.Express = "N";
                }
                else if (strDelivery == "draw")//抽奖
                {
                    mOrder.Express = "D";
                }
                else if (strDelivery == "pcoupon")//商户优惠券
                {
                    mOrder.Express = "P";
                }
                mOrder.result = Server.UrlDecode(OrderMethod.buyresult()).Replace(".", ",").Replace("-", "|");//写入规格

                if (mOrder.result != "" && teammodel.invent_result.Contains("价格"))
                {
                    strPrice = Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, mOrder.result);
                }

                mOrder.Price = decimal.Parse(strPrice);
                if (teammodel.Delivery == "express")
                {
                    mOrder.Fare = ActionHelper.System_GetFare(int.Parse(strTeamID), int.Parse(Request.Form["num"].ToString()), _system, Helper.GetString(Request["province"], String.Empty), Helper.GetInt(Request["express"], 0));//快递费decimal.Parse(str_Fare);
                }
                mOrder.Mobile = settingsmobile.Value;
                mOrder.Express_id = Helper.GetInt(Request.Form["express"], 0);
                mOrder.Origin = decimal.Parse(strOrigin);
                //交易单号格式:TeamID +"as" + UserID + "as" + orderID +  "as" + 时间(hhmmss)
                mOrder.Realname = (settingsrealname.Value);
                string strremark = txtremark.Value;
                if (strremark.IndexOf(@"\") > 0)
                {
                    strremark = strremark.Replace(@"\", @"\\");
                }
                mOrder.Remark = (strremark);
                mOrder.State = "unpay";
                mOrder.Team_id = int.Parse(strTeamID);
                mOrder.Partner_id = Helper.GetInt(teammodel.Partner_id, 0);
                int iPer_number = 0;
                if (teammodel.Per_number == 0)
                {
                    iPer_number = 9999;
                }
                else
                {
                    iPer_number = int.Parse(teammodel.Per_number.ToString());
                }
                if (iPer_number < mOrder.Quantity)
                {
                    SetError("每人限购数量" + iPer_number.ToString());
                    Response.Redirect(GetUrl("优惠卷购买", "team_buy.aspx?id=" + strTeamID));
                    Response.End();
                    return;
                }

                if (CurrentCity != null)
                {
                    mOrder.City_id = CurrentCity.Id;
                }
                //判断url地址是否存在,如果存在则添加否则不添加
                mOrder.IP_Address = CookieUtils.GetCookieValue("gourl");
                mOrder.fromdomain = CookieUtils.GetCookieValue("fromdomain");
                AddCar(mOrder);
                Response.Redirect(GetUrl("优惠卷确认", "order_check.aspx?orderid=" + Order_ID));
                Response.End();
                return;

            }
        }
    }
    //通过订单编号更新用户表
    protected virtual void updateUser(string orderId)
    {
        IOrder ordermodel = Store.CreateOrder();
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            ordermodel = seion.Orders.GetByID(Convert.ToInt32(orderId));
        }
        if (ordermodel != null)
        {
            IUser user_model = Store.CreateUser();
            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                user_model = seion.Users.GetByID(Convert.ToInt32(ordermodel.User_id));
            }

            if (user_model != null)
            {
                string name = settingsrealname.Value;
                string mobile = settingsmobile.Value;
                string country = Request["county"];
                string ff = Request["address"];
                string dd = settingszipcode.Value;
                if (settingsrealname.Value != "" && settingsmobile.Value != "" && Request["county"] != "" && Request["address"] != "" && settingszipcode.Value != "")
                {
                    if (user_model.Realname == "")
                        user_model.Realname = settingsrealname.Value;
                    if (user_model.Mobile == "")
                        user_model.Mobile = settingsmobile.Value;
                    if (user_model.Address == "")
                        user_model.Address = Request["address"];
                    if (user_model.Zipcode == "")
                    {
                        user_model.Zipcode = settingszipcode.Value;
                    }
                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        seion.Users.UpdateBuy(user_model);

                    }
                }
            }
        }
    }
    //根据订单编号‘orderid’ 修改订单的总额，快递费，以及其他信息
    protected void UpdateOrder(int orderid, string strOrigin, string fare)
    {
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            ordermodel = seion.Orders.GetByID(orderid);
        }
        ordermodel.Id = orderid;
        ordermodel.Quantity = int.Parse(Request.Form["num"].ToString());
        ordermodel.Remark = txtremark.Value;
        ordermodel.Realname = settingsrealname.Value;
        ordermodel.Mobile = settingsmobile.Value;
        if (Request["county"] != null && Request["address"] != null)
        {
            ordermodel.Address = Request["county"] + "-" + Request["address"];
        }
        else
        {
            ordermodel.Address = Request["county"] + Request["address"];
        }
        ordermodel.Zipcode = settingszipcode.Value;
        ordermodel.Origin = decimal.Parse(strOrigin);
        ordermodel.Fare = ActionHelper.System_GetFare(ordermodel.Id, _system, Helper.GetString(Request["province"], String.Empty), Helper.GetInt(Request["express"], 0)); //decimal.Parse(fare);

        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            seion.Orders.UpdateOrder(ordermodel);
        }

    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<script type="text/javascript">
    function shopcar(teamid, count, reresult) {
        X.get(webroot + "ajax/coupon.aspx?action=shopcar&teamid=" + teamid + "&count=" + count + "&result=" + reresult + "");
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<script>
    function changecity(pid) {
        X.boxShow('正在加载省市区列表,请稍后...', false);
        var sels = $("#citylist").find("select");
        var str = "";
        var candel = false;
        var obj=null;
        var citynames="";
        var cityids="";
        for (var i = 0; i < sels.length; i++) {
            if (!candel)
            {
                str = str + "-"+sels.eq(i).val();
                citynames=citynames+","+sels.eq(i).val();
                cityids=cityids+","+sels.eq(i).find("option:selected").attr("oid");
            }
            else{
                sels.eq(i).remove();
            }
            if (sels.eq(i).attr("pid") == pid) {
                candel = true;
                obj = sels.eq(i);
            } 
        }
        if(pid==0&&$("select[pid='"+pid+"']").val()!="")//当选择省份时重新判断运费
        {
            getfare();
        }
        if(str.length>0)
            str=str.substr(1);
        if(citynames.length>0)
        {
            citynames=citynames.substr(1);
            cityids=cityids.substr(1);
        }
        $("#area").html(str);
        $("#county").val(str);
        if (obj != null) {
            var oid=obj.find("option:selected").attr("oid");
            if(oid!=null){
                var u = webroot+"ajax/citylist.aspx?pid=" + oid;
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
                        else
                        {
                        <%if (payselectexpress)
                          { %>

                            X.boxShow('正在加载快递公司信息,请稍后...', false);
                            $.ajax({
                                type: "POST",
                                url: webroot+"ajax/express.aspx",
                                data: {"citys":cityids},
                                success: function (msg) {
                                    X.boxClose();
                                    $("#expressarea").html(msg);
                                    getfare();
                                }
                            });
                            <%} %>
                        }
                    }});
            }
        }
    }
    function selectexpress(id)
    {
        getfare();
    }
    function getfare()
    {
        var teamid=$("#hiteamid").val();
        var qunlity = $("#num").val();
        var citynames="";
        var expressid=0;
        var tmp_city= $("select[name='province']");
        if(tmp_city.length==1)
        {
            citynames=tmp_city.val();
        }
        var tmp_express=$("input[name='express']:checked");
        if(tmp_express.length==1)
        {
            expressid=tmp_express.val();
        }
        $.ajax({
            type: "POST",
            url: webroot+"ajax/getfare.aspx",
            data: {"city":citynames,"expressid":expressid,"id":teamid,"type":"team","num":qunlity},
            success: function (msg) {     
                var teamprice=$("#price").html();         
                var totalprice=0;     
                totalprice=totalprice+parseFloat(teamprice*qunlity);           
                var fareprice=parseFloat(msg);   
                <%if (AsUser.Id != 0)
                  {  %>totalprice=(totalprice* <%=ActionHelper.GetUserLevelMoney(AsUser.totalamount)%>);<%}%>
                totalprice=totalprice+fareprice;
                $("span[total='fareprice']").html(fareprice);
                $("#sum").html(totalprice.toFixed(2));
            }
        });
    }
</script>
<script type="text/javascript">
    function show(teamid, num, price, total, max, min, per, inventory, open_invent) {
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
        if (n > per && per != 0) {
            document.getElementById("num").value = 1;
            n = 1;
            alert("友情提示：此项目只可以购买" + per + "个");
            return false;
        }
        if (max != 0) {
            if (n > max) {
                document.getElementById(num).value = max;
                n = max;
                alert("友情提示：此项目最多" + max + "个");
                return false;
            }
        }
        if (min != 0) {
            if (n < min) {
                document.getElementById(num).value = min;
                n = min;
                alert("友情提示：此项目最低购买" + min + "个");
                return false;
            }
        }
        if (open_invent == 1 && n > inventory) {
            document.getElementById(num).value = inventory;
            alert("友情提示：库存不足，此项目最多" + inventory + "个");
            return false;
        }
        var t = parseFloat(n * p);
        document.getElementById(total).innerHTML = t.toFixed(2);
        var fare = "0";
        if (document.getElementById("deal-express-price") != null) {
            var fare = document.getElementById("deal-express-price").innerHTML;
            if (n > parseFloat(fare)) {
                fare = "0";
                document.getElementById("deal-express-price").innerHTML = 0;
            }
            getfare();
        }
        document.getElementById("sum").innerHTML = (t + parseFloat(fare)).toFixed(2);
    }
    function show1(teamid, num, price, total, max, min, per, inventory, open_invent) {
        var n;
        if (parseInt(document.getElementById(num).value) <= 1) {
            alert("友情提示：此项目最低购买" + document.getElementById(num).value + "个");
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
                return false;
            }
        }
        if (min != 0) {
            if (n < min) {
                document.getElementById(num).value = min;
                n = min;
                alert("友情提示：此项目最低购买" + min + "个");
                return false;
            }
        }
        if (open_invent == 1 && n > inventory) {
            document.getElementById(num).value = inventory;
            alert("友情提示：库存不足，此项目最多" + inventory + "个");
            return false;
        }
        var t = parseFloat(n * p); 
        document.getElementById(total).innerHTML = t.toFixed(2);
        document.getElementById("sum").innerHTML = t.toFixed(2);
    }
    function show2(teamid, num, price, total, max, min, per, inventory, open_invent) {
        var n = parseInt(document.getElementById(num).value)+ 1;
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
                return false;
            }
        }
        if (min != 0) {
            if (n < min) {
                document.getElementById(num).value = min;
                n = min;
                alert("友情提示：此项目最低购买" + min + "个");
                return false;
            }
        }
        if (open_invent == 1 && n > inventory) {
            document.getElementById(num).value = inventory;
            alert("友情提示：库存不足，此项目最多" + inventory + "个");
            return false;
        }
        var t = parseFloat(n * p);
        document.getElementById(total).innerHTML = t.toFixed(2);
        document.getElementById("sum").innerHTML = t.toFixed(2);
    }
    function shopcar(teamid, count, reresult) {
        X.get(webroot + "ajax/coupon.aspx?action=buy&teamid=" + teamid + "&count=" + count + "&result=" + reresult + "");
    }
</script>
<form id="form" runat="server">
    <div id="bdw" class="bdw">
        <div id="bd" class="cf">
            <div id="content">
                <input type="hidden" name="county" id="county">
                <asp:hiddenfield id="hiteamid" runat="server" />
                <input id="deal-per-number" value="<%=teamarr["per_number"]%>" type="hidden" />
                <div id="deal-buy" class="box">
                    <div class="box-content">
                        <div class="head">
                            <h2>提交订单
                                <% if (Farefree > 0)
                                   { %>&nbsp;(<span class="currency"><%=strFarefree %></span>件免运费)<%} %></h2>
                        </div>
                        <div class="sect">
                            <table class="order-table">
                                <tr>
                                    <td colspan="2" align="center" bgcolor="#F2F2F2">项目
                                    </td>
                                    <td colspan="1" align="center" bgcolor="#F2F2F2">规格
                                    </td>
                                    <td width="174" align="center" bgcolor="#F2F2F2">数量
                                    </td>
                                    <td width="27" align="center" bgcolor="#F2F2F2">&nbsp;
                                        
                                    </td>
                                    <td width="96" align="center" bgcolor="#F2F2F2">价格
                                    </td>
                                    <td width="29" align="center" bgcolor="#F2F2F2">&nbsp;
                                        
                                    </td>
                                    <td width="80" align="center" bgcolor="#F2F2F2">总价
                                    </td>
                                </tr>
                                <tr>
                                    <td width="132" align="center" bgcolor="#FFFFFF" style="padding: 10px">
                                        <a href="<%=getTeamPageUrl(teammodel.Id)%>" target="_blank">
                                            <img <%=ashelper.getimgsrc(ImageHelper.getSmallImgUrl(teammodel.Image)) %> class="dynload" style="width: 110px; height: 70px; border: 1px #aeaeae solid" /></a> </td>
                                    <td width="307" bgcolor="#FFFFFF" style="padding: 10px">
                                        <div style="width: 130px; height: 54px; overflow: hidden; line-height: 18px;">
                                            <a href="<%=getTeamPageUrl(teammodel.Id)%>" target="_blank" title="<%=teammodel.Title%>">
                                                <%=teammodel.Title%>
                                            </a>
                                            <br />
                                            <%if (OrderMethod.buyresult() != "")
                                              { 
                                            %>
                                              [ <font style="color: Red">  <%=Server.UrlDecode(OrderMethod.buyresult()).Replace(".", ",").Replace("-", "|").Replace("{", "").Replace("}", "").Replace("[", "").Replace("]", "")%></font>]
                                             <% } %>
                                        </div>
                                    </td>
                                    <td width="307" bgcolor="#FFFFFF" style="margin-right: 10px;">
                                        <%if (teammodel.bulletin != null && Helper.GetString(Utility.Getbulletin(teammodel.bulletin), "") != "")
                                          { %>

                                        <%if (Helper.GetString(OrderMethod.buyresult(), "") == "")
                                          { %>
                                        <a select="no" href="javascript:shopcar(<%=teammodel.Id %>, document.getElementById('num').value, '')" style="color: red">
                                            <img <%=ashelper.getimgsrc(WebRoot+"upfile/css/i/02461220.gif") %> class="dynload" width="16px" height="17px" style="margin-left: 15px;"><br>
                                            选择规格
                                        </a>

                                        <% }
                                          else
                                          {%>
                                        <img <%=ashelper.getimgsrc(WebRoot+"upfile/css/i/pcde_416.png") %> class="dynload" />
                                        <br />
                                        <a href="javascript:shopcar(<%=teammodel.Id%>, document.getElementById('num').value,encodeURIComponent('<%=result %>'))" style="color: red">修改
                                        </a>
                                        <% }
                                          }%>
                                    </td>
                                    <td align="center" style="padding: 10px">
                                        <div class="num_div">

                                            <%if (Helper.GetString(Utility.Getbulletin(teammodel.bulletin), "") != "")
                                              { %>
                                            <input type="text" id="num" idval="<%=teammodel.Id %>" maxval="<%=teammodel.Max_number %>"
                                                minval="<%=teammodel.Min_number %>" onfocus="shopcar(<%=teammodel.Id %>,this.value, encodeURIComponent('<%=Server.UrlDecode(result) %>'))"
                                                class="input-text f-input1 deal-buy-quantity-input" maxlength="4" name="num"
                                                value="<%=strQuantity %>" category="product" />

                                            <% }
                                              else
                                              {%>
                                            <span class="crease decrease" onclick="show2('<%=teammodel.Id %>','num','price','total','<%=teammodel.Per_number %>','<%=teammodel.Per_minnumber %>','<%=teammodel.Per_number %>','<%=teammodel.inventory %>','<%=teammodel.open_invent %>')"></span><span class="crease" onclick="show1('<%=teammodel.Id %>','num','price','total','<%=teammodel.Max_number %>','<%=teammodel.Per_minnumber %>','<%=teammodel.Per_number %>','<%=teammodel.inventory %>','<%=teammodel.open_invent %>')"></span>
                                            <input type="text" id="num" idval="<%=teammodel.Id %>" maxval="<%=teammodel.Max_number %>"
                                                minval="<%=teammodel.Min_number %>" onkeyup="show('<%=teammodel.Id %>','num','price','total','<%=teammodel.Max_number %>','<%=teammodel.Per_minnumber %>','<%=teammodel.Per_number %>','<%=teammodel.inventory %>','<%=teammodel.open_invent %>')"
                                                class="input-text f-input1 deal-buy-quantity-input" maxlength="4" name="num"
                                                value="<%=strQuantity %>" category="product" />

                                            <% }%>

                                            <br />
                                            <br />
                                            <%if (teammodel.Farefree != 0)
                                              { %>
                                            <font style='color: #999999; font-size: 12px;'>包邮≥<span id="Farefree"><%=teammodel.Farefree%>件</span></font>
                                            <% }%>
                                        </div>
                                    </td>
                                    <td align="center" bgcolor="#FFFFFF" style="padding-left: 30px">x
                                    </td>
                                    <td align="center" bgcolor="#FFFFFF" style="padding: 10px">
                                        <%=ASSystem.currency%><span id="price"><%=strPrice%></span>
                                    </td>
                                    <td align="center" bgcolor="#FFFFFF" style="padding: 10px">=
                                    </td>
                                    <td align="center" bgcolor="#FFFFFF" style="padding: 10px">
                                        <%=ASSystem.currency%><span id="total" title="total"><%=decimal.Parse(strPrice) * int.Parse(strQuantity)%></span>
                                    </td>
                                </tr>
                                <%if (teammodel.Delivery == "express")
                                  {%>
                                <tr>
                                    <td class="deal-buy-desc" colspan="3">快递
                                    </td>
                                    <td class="deal-buy-quantity"></td>
                                    <td class="deal-buy-multi"></td>
                                    <td class="deal-buy-price">
                                        <%=ASSystem .currency %>
                                        <span id="deal-express-price" total="fareprice">
                                            <%=fare%>
                                        </span>
                                    </td>
                                    <td class="deal-buy-total"></td>
                                    <td class="deal-buy-total">
                                        <span class="money"></span><span id="deal-express-total"></span>
                                    </td>
                                </tr>
                                <%} %>
                                <tr class="order-total">
                                    <td class="deal-buy-desc" colspan="3">
                                        <strong>应付总额：</strong>
                                    </td>
                                    <td class="deal-buy-quantity"></td>
                                    <td class="deal-buy-multi"></td>
                                    <td class="deal-buy-price"></td>
                                    <td class="deal-buy-equal">=
                                    </td>
                                    <td class="deal-buy-total" total="totalprice">
                                        <span style="color: #f00; font-size: 12px; padding-bottom: 5px">
                                            <%=ASSystem.currency %><span id="sum"><%=totalprice%></span></span>
                                    </td>
                                </tr>
                            </table>
                            <asp:panel id="pExpress" runat="server" visible="false">
                                <%if (strExpress != "")
                                  { %>
                                <div class="expresstip">
                                    <%=strExpress%></div>
                                <% }%>
                                <div class="wholetip clear">
                                    <h3>
                                        快递信息</h3>
                                </div>
                                <div class="field username">
                                    <label>
                                        收件人</label>
                                    <input type="text" size="30" name="realname" id="settingsrealname" class="f-input"
                                        value="" require="true" datatype="require" group="a" runat="server" />
                                    <span class="hint">收件人请与有效证件姓名保持一致，便于收取物品</span>
                                </div>
                                <div class="field mobile">
                                    <label>
                                        手机号码</label>
                                    <input type="text" size="30" name="mobile" id="settingsmobile" class="number" value=""
                                        group="a" require="true" datatype="mobile" maxlength="11" runat="server" />
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
                                    <label> 街道地址(必填)</label>
                                    <% if (CookieUtils.GetCookieValue("address") != null && CookieUtils.GetCookieValue("address") != "")
                                       { %>
                                       <input type="text" size="30" name="address" id="Text2" class="f-input"
                                        value="<% if (AsUser != null)
                                                  {%><%=stradress %><%} %>" group="a" require="true"
                                        datatype="require" />
                                    <%}
                                       else
                                       { %>
                                       <input type="text" size="30" name="address" id="settingsaddress" class="f-input"
                                        value="<% if (AsUser != null)
                                                  {%><%=stradress %><%} %>" group="a" require="true"
                                        datatype="require" />
                                    <%} %>
                                    
                                    <span class="hint">街道具体地址</span>
                                </div>
                                <script>
                                    $("#citylist").load(webroot+"ajax/citylist.aspx?pid=0", null, function (data) {

                                    });
                                </script>
                                <div id="expressarea" class="field mobile">
                                </div>
                                <div class="field mobile">
                                    <label>
                                        邮政编码</label>
                                    <input type="text" size="30" name="zipcode" id="settingszipcode" class="number" value=""
                                        group="a" require="true" datatype="zip" maxlength="6" runat="server" />
                                </div>
                            </asp:panel>
                        </div>
                        <div class="field mobile">
                            <label>
                                订单附言</label>
                            <textarea name="remark" id="txtremark" runat="server" style="width: 500px; height: 80px;"></textarea>
                        </div>
                        <input id="deal-buy-cardcode" type="hidden" name="cardcode" maxlength="8" value="" />
                        <div class="form-submit">
                            <input id="Submit1" type="submit" group="a" class="formbutton validator" name="buy" onclick="return checksubmit()"
                                value="确认无误，购买" runat="server" onserverclick="submit_ServerClick" />
                        </div>
                        <script>
                            function checksubmit() {
                                if ($("a[select='no']").length > 0) {
                                    alert("请先选择产品的规格，在提交订单");
                                    return false;
                                }
                                return true;
                            }
                        </script>
                    </div>
                </div>
            </div>
            <div id="sidebar">
                <div class="sbox">
                    <div class="sbox-content">
                        <div class="r-top">
                        </div>
                        <div class="credit">
                            <h2>账户余额</h2>
                            <p>
                                您的账户余额：<span class="money"><%=ASSystem.currency %></span><%=strMoney %>
                            </p>
                        </div>
                        <div class="r-bottom">
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>