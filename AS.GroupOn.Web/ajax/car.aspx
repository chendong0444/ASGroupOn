<%@ Page Language="C#" AutoEventWireup="true" Debug="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public List<Car> carlist = new List<Car>();
    private NameValueCollection _system = new NameValueCollection();
    public int num = 0;
    public bool invent = false;
    public decimal sums;
    public int fare_shoping;
    public decimal jian;
    public decimal fan;
    public bool flag = false;
    ITeam teammodel = Store.CreateTeam();
    IOrder ordermodel = Store.CreateOrder();
    IOrderDetail orderdemodel = Store.CreateOrderDetail();

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();
        if (!Page.IsPostBack)
        {
            
            GetRedirect(Convert.ToInt32(Request["proid"]), Request["result"]);//根据项目类型跳转到不同的 页面
            if (Request["id"] != null)
            {
                if (Helper.GetString(Request["type"],String.Empty) == "mall")
                {
                    AddMallCar(Request["id"].ToString());
                }
                else
                {
                    AddCar(Request["id"].ToString());
                }
            }
            if (Request["delid"] != null)
            {
                delete(Request["delid"].ToString());
            }
            if (Request["action"] != null && Request["action"].ToString() != "" && Request["action"].ToString() == "notprice")//处理不同价格
            {
                string teamid =Helper.GetString(Request["addteamid"],String.Empty);
                string num = Helper.GetString(Request["num"], String.Empty);
                string result = Helper.GetString(Request["result"], String.Empty);
                string m_rule = Helper.GetString(Request["m_rule"], String.Empty);
                string type = Helper.GetString(Request["ty"], String.Empty);
                if (teamid != String.Empty && num != String.Empty && result != String.Empty && m_rule != String.Empty)
                {
                    if (CookieUtils.GetCookieValue("username") == String.Empty) //没有登录
                    {
                        Response.Write(JsonUtils.GetJson("location.href='" + GetUrl("用户登录", "account_login.aspx") + "'", "eval"));
                        Response.End();
                    }
                    string mesage = CreateOrder(teamid, num, result, m_rule);
                    if (Helper.GetInt(mesage, 0) == 0)
                    {
                        Response.Write(JsonUtils.GetJson(mesage, "alert"));
                    }
                    else
                    {
                        if (type == "jd")
                        {
                            Response.Write(JsonUtils.GetJson("location.href='" + GetUrl("京东购物车订单", "shop_jdconfirmation.aspx?orderid=" + mesage) + "'", "eval"));
                            Response.End();  
                        }
                        else
                        {
                            Response.Write(JsonUtils.GetJson("location.href='" + GetUrl("不同价格订单", "shopcart_notpriceation.aspx?orderid=" + mesage) + "'", "eval"));
                            Response.End();  
                        }
                    }
                }
            }
            if (Request["action"] != null && Request["action"].ToString() != "" && Request["action"].ToString() == "carinfo")
            {
                string teamid = Request["addteamid"];
                string num = Request["num"];
                string result = Request["result"];
                string m_rule = Request["m_rule"];
                string html = WebUtils.LoadPageString(PageValue.WebRoot + "ajaxpage/ajax_dialog_showcarinfo.aspx?addteamid=" + teamid + "&num=" + num + "&result=" + result + "&m_rule=" + m_rule + "&type=" + Helper.GetString(Request["type"], String.Empty));
                Response.Write(JsonUtils.GetJson(html, "dialog"));
                
            }
            if (Request["proid"] != null && Request["proid"] != "")
            {
                if (Request["result"] != null && Request["result"] != "")
                {
                    num = Utility.Getnum(Request["result"]);
                    judge(Convert.ToInt32(Request["proid"].ToString()), num, Request["result"]);
                }
                else
                {
                    num = Helper.GetInt(Request["num"], 1);
                    judge(Convert.ToInt32(Request["proid"].ToString()), num, Helper.GetString(Server.UrlDecode(CookieCar.GetProductInfo(Request["proid"]).Split(',')[8].ToString()), ""));
                }
            }
            if (Request["teamid"] != null)
            {
                update(Request["teamid"], Helper.GetInt(Request["num"], 1), "", 0);
            }
            if (Request["SplitOrder"] != null && Request["SplitOrder"].ToString() != "" && Request["SplitOrder"].ToString() == "choice")
            {
                if (CookieUtils.GetCookieValue("username") == String.Empty)
                {
                    if (Request["ty"] != null)
                    {
                        if (Request["ty"] == "jd")
                        {
                            SetRefer(GetUrl("京东购物车列表", "mall_jdcart.aspx"));
                        }

                    }
                    else
                    {
                        SetRefer(GetUrl("购物车列表", "shopcart_show.aspx"));
                    }
                    Response.Write("2");
                    Response.End();

                }
                else
                {
                    TeamFilter tf = new TeamFilter();
                    carlist = CookieCar.GetCarData();
                    int num = 0;
                    int newnum = 0;
                    if (carlist.Count>0)
                    {
                        foreach (Car carmodel in carlist)
                    {
                        tf.Id = Convert.ToInt32(carmodel.Qid);
                        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            teammodel = seion.Teams.Get(tf);
                        }
                        if (teammodel != null)
                        {
                            int cash = Helper.GetInt(teammodel.cashOnDelivery, 0);
                            if (cash == 0)
                            {
                                num += carmodel.Quantity;
                            }
                            else
                            {
                                newnum += carmodel.Quantity;
                            }
                        }
                    }
                    }
                    
                    if (num > 0 && newnum > 0)
                    {
                         string html=string.Empty;
                        if (Request["ty"] != null)
                        {
                            if (Request["ty"] == "jd")
                            {
                               html = WebUtils.LoadPageString(PageValue.WebRoot + "ajax/ajax_SplitOrder.aspx?ty=jd");
                            }

                        }
                        else
                        {
                             html = WebUtils.LoadPageString(PageValue.WebRoot + "ajax/ajax_SplitOrder.aspx");
                        }
                        Response.Write(html);
                    }
                    else
                    {

                        int orderid = Helper.GetInt(AddCar(), 0);
                        if (Request["ty"] != null)
                        {
                            if (Request["ty"] == "jd")
                            {
                                SetRefer(GetUrl("京东购物车列表", "shop_jdconfirmation.aspx?orderid=" + orderid));
                            }

                        }
                        else
                        {
                            SetRefer(GetUrl("购物车订单", "shopcart_confirmation.aspx?orderid=" + orderid));
                        }
                        Response.Write("1," + orderid);
                        Response.End();
                    }
                }

            }
        }
    }
    /// <summary>
    /// 处理不同价格(生成订单)
    /// </summary>
    public string CreateOrder(string teamid, string num, string result, string money)
    {
        string message = String.Empty;
        string _result = String.Empty;
        ITeam teammodel = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(Helper.GetInt(teamid, 0));
        }
        if (teammodel != null)
        {
            if (teammodel.Delivery == "express")
            {
                if (num != "" && num.Length <= 6)
                {
                    bool isExistrule = false;
                    if (teammodel.open_invent == 1)//开启库存
                    {
                        invent = Utility.isinvent(Helper.GetString(result, ""), Helper.GetString(teammodel.invent_result, ""));
                        isExistrule = Utility.GetNewOld(result, teammodel.invent_result);
                    }
                    if (Utility.Getnum(result) <= 0)
                    {
                        message = "您的购买数量不能小于1";
                    }
                    else if (Utility.Getrule(result))
                    {
                        message = "您不可以选择一样的规格，请重新选择";
                    }
                    else if (isExistrule)
                    {
                        message = "您选择了此项目所没有的规格，请重新选择";
                    }
                    else if (invent)
                    {
                        message = "您购买的数量超过了库存数量，请减少一些";
                    }
                    else if (teammodel.teamcata == 0 && Utility.Getnum(result) > teammodel.Per_number && teammodel.Per_number > 0)
                    {
                        message = "您最多可以购买" + teammodel.Per_number + "个";
                    }
                    else if (Utility.Getnum(result) < teammodel.Per_minnumber && teammodel.Per_minnumber > 0)
                    {
                        message = "您最低必须购买" + teammodel.Per_minnumber + "个";
                    }
                    else
                    {
                        string fee = "";
                        fee = teammodel.Fare.ToString();
                        string max = teammodel.Per_number.ToString();
                        string min = teammodel.Per_minnumber.ToString();

                        if (Helper.GetInt(teammodel.open_invent, 0) == 1)  //开启库存功能
                        {
                            max = Math.Min(Helper.GetInt(teammodel.Per_number, 0), Helper.GetInt(teammodel.inventory, 0)).ToString();
                            if (teammodel.Per_number == 0)
                            {
                                max = teammodel.inventory.ToString();
                            }
                        }
                        int orderid = 0;
                        OrderFilter of = new OrderFilter();
                        of.State = "unpay";
                        of.User_id = AsUser.Id;
                        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            seion.Orders.UpdateUnpayOrder(of);
                        }
                        IOrder ordermodel = Store.CreateOrder();
                        IOrderDetail orderdemodel = Store.CreateOrderDetail();
                        ordermodel.User_id = AsUser.Id;
                        ordermodel.State = "unpay";
                        ordermodel.Quantity = int.Parse(num);
                        ordermodel.Create_time = DateTime.Now;
                        if (CurrentCity != null)
                        {
                            ordermodel.City_id = CurrentCity.Id;
                        }
                        else
                        {
                            ordermodel.City_id = 0;
                        }
                        ordermodel.Express = "Y";
                        ordermodel.IP_Address = CookieUtils.GetCookieValue("gourl");
                        ordermodel.fromdomain = CookieUtils.GetCookieValue("fromdomain");
                        ordermodel.Partner_id = Helper.GetInt(teammodel.Partner_id, 0);
                        orderdemodel.Num = int.Parse(num);
                        orderdemodel.Teamid = teammodel.Id;
                        if (Helper.GetDecimal(money, 0) > 0)
                        {
                            orderdemodel.Teamprice = Helper.GetDecimal(money, 0);
                            orderdemodel.result = Server.UrlDecode(result.Replace("-", "|").Replace(".", ","));
                            orderdemodel.discount = 0;
                            sums += Helper.GetDecimal(orderdemodel.Num * orderdemodel.Teamprice, 0);
                            CookieUtils.SetCookie("summoney", sums.ToString());
                            GetCuXiao(sums);
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                orderid = session.Orders.Insert(ordermodel);
                            }
                            if (orderid > 0)
                            {
                                message = orderid.ToString();
                                orderdemodel.Order_id = orderid;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    session.OrderDetail.Insert(orderdemodel);
                                }
                            }
                        }
                        else
                        {
                            message = "";
                        }
                    }
                }
                else if (num == "")
                {
                    message = "请选择购买数量";
                }
                else
                {
                    message = "您放入购物车的数量已超出交易数量上限999999，请减少一些！";
                }
            }
            else
            {
                message = "项目规格选择有误";
            }
        }
        else
        {
            message = "项目不存在";
        }
        return message;
    }
    #region 提交订单
    public virtual int AddCar()
    {
        int orderid = 0;
        NeedLogin();
        //未付款订单处理方法：在生成订单前。得到1个小时内，此用户的未付款的，购物车的订单。然后将状态更改为cancel 在创建新 订单 
        OrderFilter of = new OrderFilter();
        of.State = "unpay";
        of.User_id = AsUser.Id;
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            seion.Orders.UpdateUnpayOrder(of);
        }
        bool isfei = false;
        decimal total = 0;
        int num = 0;
        carlist = CookieCar.GetCarData();
        DataTable dtCount = new DataTable();
        //解决购物车中不同项目相同产品库存问题
        dtCount.Columns.Add("id", typeof(int));
        dtCount.Columns.Add("num", Type.GetType("System.String"));
        dtCount.Columns.Add("result", Type.GetType("System.String"));
        if (carlist != null)
        {
            foreach (Car carmodel in carlist)
            {
                TeamFilter tf = new TeamFilter();
                tf.Id = Convert.ToInt32(carmodel.Qid);
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teammodel = seion.Teams.Get(tf);
                }

                if (teammodel != null)
                {
                    if ((teammodel.Begin_time <= DateTime.Now && teammodel.End_time >= DateTime.Now) || (teammodel.teamcata == 1))
                    {
                        if (teammodel.Delivery != "coupon" && teammodel.Team_type != "seconds" && teammodel.Delivery != "draw" && teammodel.Delivery != "pcoupon")
                        {
                            if (((teammodel.Max_number > 0 && teammodel.Now_number < teammodel.Max_number) || (teammodel.Max_number == 0) || (teammodel.teamcata == 1)))
                            {
                                //产品不为空、开启了库存
                                if (teammodel.productid != 0 && teammodel.open_invent == 1)
                                {
                                    if (dtCount.Rows.Count > 0)
                                    {
                                        bool isT = false;
                                        int allCount = 0;
                                        for (int i = 0; i < dtCount.Rows.Count; i++)
                                        {
                                            if (teammodel.productid.ToString() == dtCount.Rows[i]["id"].ToString())
                                            {
                                                isT = true;
                                                allCount = carmodel.Quantity + int.Parse(dtCount.Rows[i]["num"].ToString());
                                                dtCount.Rows[i]["num"] = allCount.ToString();
                                                ProductFilter pf = new ProductFilter();
                                                IProduct product = Store.CreateProduct();
                                                pf.Id = teammodel.productid;

                                                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                                                {
                                                    product = seion.Product.Get(pf);
                                                }

                                                if (product != null)
                                                {
                                                    //product
                                                }
                                                break;
                                            }
                                        }
                                        if (isT == false)
                                        {
                                            DataRow drCount = dtCount.NewRow();
                                            drCount["id"] = teammodel.productid;
                                            drCount["num"] = carmodel.Quantity;
                                            dtCount.Rows.Add(drCount);
                                        }
                                    }
                                    else
                                    {
                                        DataRow drCount = dtCount.NewRow();
                                        drCount["id"] = teammodel.productid;
                                        drCount["num"] = carmodel.Quantity;
                                        drCount["result"] = Server.UrlDecode(carmodel.Result.Replace("-", "|").Replace(".", ","));
                                        dtCount.Rows.Add(drCount);
                                    }
                                }
                                num += carmodel.Quantity;
                                total += carmodel.Price * carmodel.Quantity;
                                //}
                                if (Utility.Getbulletin(teammodel.bulletin) != "")
                                {
                                    if (carmodel.Result == "")
                                    {

                                        SetError("友情提示：请选择项目的规格");
                                        return 0;
                                    }
                                }
                                if (carmodel.Quantity < 0)
                                {
                                    isfei = true;
                                }
                            }
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
                ordermodel.State = "unpay";
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
                ordermodel.Express = "Y";
                ordermodel.IP_Address = CookieUtils.GetCookieValue("gourl");
                ordermodel.fromdomain = CookieUtils.GetCookieValue("fromdomain");
                ordermodel.Partner_id = Helper.GetInt(teammodel.Partner_id, 0);
             
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    orderid = session.Orders.Insert(ordermodel);
                }

                foreach (Car carmodel in carlist)
                {
                    TeamFilter tf = new TeamFilter();
                    tf.Id = Convert.ToInt32(carmodel.Qid);
                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        teammodel = seion.Teams.Get(tf);
                    }
                    if (teammodel != null)
                    {
                        if (teammodel.teamcata == 0)
                        {
                            if (teammodel.Begin_time <= DateTime.Now && teammodel.End_time >= DateTime.Now)
                            {
                                if (teammodel.Delivery != "coupon" && teammodel.Team_type != "seconds" && teammodel.Delivery != "draw" && teammodel.Delivery != "pcoupon")
                                {
                                    if (((teammodel.Max_number > 0 && teammodel.Now_number < teammodel.Max_number) || (teammodel.Max_number == 0)))
                                    {
                                        orderdemodel.Num = carmodel.Quantity;
                                        orderdemodel.Teamid = Convert.ToInt32(carmodel.Qid);
                                        //找到不同规格下的价格
                                        if (Server.UrlDecode(carmodel.Result) != "" && teammodel.invent_result!=null&&teammodel.invent_result.Contains("价格"))
                                        {
                                            //orderdemodel.Teamprice = Convert.ToDecimal(Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, Server.UrlDecode(carmodel.Result).Replace("{", "").Replace("}", "").Substring(0, Server.UrlDecode(carmodel.Result).LastIndexOf('.') - 1).Replace("-", "|").Replace(".", ",")));
                                            orderdemodel.Teamprice = Convert.ToDecimal(Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, Server.UrlDecode(carmodel.Result).Replace("-", "|").Replace(".", ",")));
                                        }
                                        else//没有规格或者有规格没有设置不同价格
                                        {
                                            orderdemodel.Teamprice = teammodel.Team_price;
                                        }
                                        orderdemodel.Order_id = orderid;
                                        orderdemodel.result = Server.UrlDecode(carmodel.Result.Replace("-", "|").Replace(".", ","));
                                        orderdemodel.discount = 0;
                                        sums += Helper.GetDecimal(orderdemodel.Num * orderdemodel.Teamprice, 0);
                                        CookieUtils.SetCookie("summoney", sums.ToString());
                                        GetCuXiao(sums);
                                        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            seion.OrderDetail.Insert(orderdemodel);
                                        }
                                    }
                                }
                            }
                        }
                        else if (teammodel.teamcata == 1)
                        {
                            if (teammodel.Delivery == "express")
                            {
                                orderdemodel.Num = carmodel.Quantity;
                                orderdemodel.Teamid = Convert.ToInt32(carmodel.Qid);
                                //找到不同规格下的价格
                                if (Server.UrlDecode(carmodel.Result) != "" &&teammodel.invent_result!=null&& teammodel.invent_result.Contains("价格"))
                                {
                                    orderdemodel.Teamprice = Convert.ToDecimal(Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, Server.UrlDecode(carmodel.Result).Replace("{", "").Replace("}", "").Substring(0, Server.UrlDecode(carmodel.Result).LastIndexOf('.') - 1).Replace("-", "|").Replace(".", ",")));
                                }
                                else//没有规格或者有规格没有设置不同价格
                                {
                                    orderdemodel.Teamprice = teammodel.Team_price;
                                }
                                orderdemodel.Order_id = orderid;
                                orderdemodel.result = Server.UrlDecode(carmodel.Result.Replace("-", "|").Replace(".", ","));
                                orderdemodel.discount = 0;
                                sums += Helper.GetDecimal(orderdemodel.Num * orderdemodel.Teamprice, 0);
                                CookieUtils.SetCookie("summoney", sums.ToString());
                                GetCuXiao(sums);
                                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    seion.OrderDetail.Insert(orderdemodel);
                                }
                            }
                        }
                    }
                }
                OrderFilter orderf = new OrderFilter();
                OrderFilter jianof = new OrderFilter();
                if (fare_shoping == 1)
                {
                    orderf.Fare = 0;
                    orderf.Id = orderid;
                }
                else
                {
                    orderf.Fare = ActionHelper.System_GetFare(orderid, WebUtils.config, String.Empty, 0);
                    orderf.Id = orderid;
                }
                if (jian != 0)
                {
                    jianof.Origin = Helper.GetDecimal((DBHelper.GetTeamTotalPriceWithFare(orderid) - jian), 0);
                    jianof.Id = orderid;
                }
                else
                {
                    jianof.Origin = DBHelper.GetTeamTotalPriceWithFare(orderid);
                    jianof.Id = orderid;
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Orders.UpdateFare(orderf);
                    session.Orders.UpdateOrigin(jianof);
                }
                
            }
            CreateOrderOK(orderid);
        }
        return orderid;
    }
    #endregion
    /// <summary>
    /// 下单成功后执行的操作
    /// </summary>
    /// <param name="orderid"></param>
    public virtual void CreateOrderOK(int orderid)
    {

    }
    public void GetCuXiao(decimal totalprice)
    {
        IList<ISales_promotion> listsales = null;
        Sales_promotionFilter sf = new Sales_promotionFilter();
        sf.enable = 1;
        sf.start_time = DateTime.Now;
        sf.end_time = DateTime.Now;
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            listsales = seion.Sales_promotion.GetList(sf);
        }
        StringBuilder sb1 = new StringBuilder();
        jian = 0;
        if (listsales != null && listsales.Count > 0)
        {
            foreach (ISales_promotion sale_pro in listsales)
            {
                Promotion_rulesFilter pf = new Promotion_rulesFilter();
                IList<IPromotion_rules> prolist = null;
                pf.enable = 1;
                pf.Tostart_time = DateTime.Now;
                pf.Fromend_time = DateTime.Now;
                pf.activtyid = sale_pro.id;
                pf.Tofull_money = totalprice;
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    prolist = seion.Promotion_rules.GetList(pf);
                }
                string PromotionID = getPromotionID();
                string[] Pid = PromotionID.Split(',');
                int free_shipping = Helper.GetInt(Pid[0], 0);
                int Deduction = Helper.GetInt(Pid[1], 0);
                int Feeding_amount = Helper.GetInt(Pid[2], 0);

                if (prolist != null && prolist.Count > 0)
                {
                    foreach (IPromotion_rules promotion_rules in prolist)
                    {
                        if (promotion_rules.typeid == free_shipping)
                        {
                            fare_shoping = promotion_rules.free_shipping;

                        }
                        if (promotion_rules.typeid == Deduction)
                        {
                            jian += promotion_rules.deduction;

                        }
                        if (promotion_rules.typeid == Feeding_amount)
                        {
                            fan += promotion_rules.feeding_amount;
                        }
                    }
                }
            }
        }
    }
    #region
    public void judge(int teamid, int num, string carresult)
    {
        ITeam teammodel = Store.CreateTeam();
        string result = "";
        bool isExistrule = false;
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(teamid);
        }
        if (teammodel != null)
        {
            if (teammodel.open_invent == 1)//开启库存
            {
                invent = Utility.isinvent(Helper.GetString(carresult, ""), Helper.GetString(teammodel.invent_result, ""));
                isExistrule = Utility.GetNewOld(carresult, teammodel.invent_result);
            }
            if (Utility.Getnum(carresult) > 0)
            {
                if (Utility.Getrule(carresult))
                {
                    result = "友情提示：您不可以选择一样的规格，请重新选择";
                }
                else if (isExistrule)
                {
                    //result = "友情提示:您选择的产品库存数量为0，无法购买";
                    result = "友情提示:您选择了此项目所没有的规格，请重新选择";
                }
                else if (invent)
                {
                    result = "友情提示:您购买的数量超过了库存数量，请减少一些";
                }
                else if (teammodel.teamcata == 0 && Utility.Getnum(carresult) > teammodel.Per_number && teammodel.Per_number > 0)
                {
                    result = "友情提示:您最多可以购买" + teammodel.Per_number + "个";
                }
                else if (Utility.Getnum(carresult) < teammodel.Per_minnumber && teammodel.Per_minnumber > 0)
                {
                    result = "友情提示:您最低必须购买" + teammodel.Per_minnumber + "个";
                }
            }
            else
            {
                result = "友情提示:您购买数量不能小于1个";
            }
            if (result != "")
            {
                OrderedDictionary list = new OrderedDictionary();
                list.Add("html", result);
                list.Add("id", "coupon-dialog-display-id1");
                Response.Write(JsonUtils.GetJson(list, "updater"));
            }
            else if (Request["action"] == "check")
            {
                OrderedDictionary list = new OrderedDictionary();
                list.Add("html", String.Empty);
                list.Add("id", "coupon-dialog-display-id1");
                Response.Write(JsonUtils.GetJson(list, "updater"));

            }
            else
            {
                update(teamid.ToString(), num, carresult, 1);
            }
        }
    }
    #endregion


    #region 根据后台设置的是否开启购物车的开启
    public void GetRedirectBuy(int teamid, string result)
    {
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(teamid);
        }

        System.Collections.Specialized.NameValueCollection configs = WebUtils.GetSystem();
        if (teammodel.Delivery == "coupon" || teammodel.Team_type == "seconds" || configs["closeshopcar"] == "1")
        {
            Response.Redirect(GetUrl("优惠卷购买", "team_buy.aspx?proid=" + teammodel.Id + "&result='" + result + "'"));
        }
    }
    #endregion

    #region 根据项目类型的不同，跳转到不同的页面
    public void GetRedirect(int Teamid, string result)
    {
        if (Teamid != 0)
        {
            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                teammodel = seion.Teams.GetByID(Teamid);
            }
            if (teammodel.Team_type == "point")//积分项目跳转到积分页面
            {
                Response.Redirect(WebRoot + "ajax/PCar.aspx?proid=" + Teamid + "&result=" + result + "");
            }
        }
    }

    #endregion

    #region 修改临时购物车的信息
    public void update(string teamid, int num, string result, int back)
    {
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(Convert.ToInt32(teamid));
        }
        //判断这个项目的数量是否>=免单数量，如果成立，没有运费，不成立，有运费
        string fee = "fee";

        fee = teammodel.Fare.ToString();
        string max = teammodel.Per_number.ToString();
        string min = teammodel.Per_minnumber.ToString();
        if (Helper.GetInt(teammodel.open_invent, 0) == 1)  //开启库存功能
        {
            max = Math.Min(Helper.GetInt(teammodel.Per_number, 0), Helper.GetInt(teammodel.inventory, 0)).ToString();
           
            if (teammodel.Per_number == 0)
            {
                max = teammodel.inventory.ToString();
            }
            if (teammodel.open_invent==1)
            {
                if (num>teammodel.inventory)
                {
                    num = teammodel.inventory;
                }
            }
            string oldrule = teammodel.invent_result;
            string nowrule = result;
            //如果项目规格包含价格，那么购物车的项目需要根据规格来拆分项目，以区别不同规格项目价格不同
            if (Helper.GetString(nowrule, "") != "" && Helper.GetString(oldrule, "") != "")
            {
                if (oldrule.Contains("价格"))
                {
                    //1:首先删除购物车中当前项目的信息，然后根据不同规格价格不同的项目分别加入购物车
                    // CookieCar.DeleteProduct(teamid);
                    string[] newrules = nowrule.Replace("{", "").Replace("}", "").Split('|');
                    for (int j = 0; j < newrules.Length; j++)
                    {
                        // 颜色:[红色],尺寸:[S],数量:[1]
                        if (newrules[j] != "")
                        {
                            string strquantity = newrules[j].Substring(newrules[j].LastIndexOf(':') + 1).Replace("[", "").Replace("]", "");
                            int quantity = int.Parse(strquantity);
                            handelCarData(teamid, newrules[j], Getdrulemoney(teamid, newrules[j]), max, fee, min, quantity);
                        }

                    }
                }
                else
                {

                }
            }


        }
       
            CookieCar.UpdateQuantity(teamid, num, "", Getdrulemoney(teamid, result), teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);
 
     
       
        if (back == 0)
        {
            Response.Write(JsonUtils.GetJson("toal();", "eval"));
        }
        else
        {
            if (Request["ty"] != null)
            {
                if (Request["ty"] == "jd")
                {
                    Response.Write(JsonUtils.GetJson("location.href='" + GetUrl("京东购物车列表", "mall_jdcart.aspx") + "'", "eval"));
                }

            }
            else
            {
                Response.Write(JsonUtils.GetJson("location.href='" + GetUrl("购物车列表", "shopcart_show.aspx") + "'", "eval"));
            }
        }

    }
    #endregion


    void handelCarData(string teamid, string result, decimal money, string max, string fee, string min, int quantity)
    {
        System.Collections.Generic.List<Car> carlist = new System.Collections.Generic.List<Car>();
        carlist = CookieCar.GetCarData();
        int sumQuantity = 0;



        //判断购物车是否有项目信息，没有则往购物车中添加
        if (carlist != null)
        {

            string strRule = "0"; //标志购物车中 相同项目是否存在相同规格信息 0：不同规格的相同项目  1： 表示相同规格的相同项目
            string strTeamCar = ""; //标志购物车中是否有该项目信息 1:表示有该项目
            foreach (Car model in carlist)
            {

                //teammodel = teambll.GetModel(Convert.ToInt32(model.Qid), false);
                if (teammodel != null)
                {
                    if (teamid == model.Qid)
                    {
                        strTeamCar = "1";
                    }
                    string str = Server.UrlDecode(model.Result);
                    //判断是否相同规格项目
                    if (Utility.IsSameResultCar(result.Replace(",", "."), Server.UrlDecode(model.Result)) || Server.UrlDecode(model.Result) == "")
                    {
                        if (teamid == model.Qid)
                        {
                            sumQuantity = quantity;
                            //相同则修改数量
                            strRule = "1";
                        }

                    }
 


                }
            }

            //标志购物车中是否有该项目信息
            if (strTeamCar == "1")
            {
                //判断是否是同意规格项目
                if (strRule == "1")
                {

                    string sum_num = sumQuantity.ToString();
                    if (Helper.GetString(teammodel.invent_result, "") != "")//有规格的商品
                    {
                        //开启库存并且每超出库存  或者没开启库存 则修改cookie，否则提示出错
                        if ((teammodel.open_invent == 1 && !Utility.isinventsum(sumQuantity, Helper.GetString(result, ""), Helper.GetString(teammodel.invent_result, ""))) || teammodel.open_invent == 0)
                        {
                            //相同则修改数量
                            CookieCar.UpdateQuantity(teamid, int.Parse(sum_num), "", money, teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);

                        }
                        else
                        {
                            SetError("超出库存数量了！");
                        }
                    }
                    else//没有规格的商品
                    {
                        //开启库存并且购物车的数量加上当前购买的数量已超出库存     提示出错
                        if (teammodel.open_invent == 1 && int.Parse(sum_num) > Helper.GetInt(teammodel.inventory, 0))
                        {
                            SetError("选择的数量超出库存了！");
                        }
                        else
                        {

                            CookieCar.UpdateQuantityById(teamid, int.Parse(sum_num), "", money, teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);

                        }

                    }
                }
                else if (strRule == "0")
                {
                    //物车中没有该项目信息
                    // CookieCar.AddProductToCar(teamid, num.ToString(), "", money, teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);

                    CookieCar.AddSameProductToCar(teamid, quantity.ToString(), "", money, teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);

                }
            }
            else
            {
                //物车中没有该项目信息
                CookieCar.AddProductToCar(teamid, quantity.ToString(), "", money, teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);

            }


        }
        else
        {
            //购物车中不存在
            CookieCar.AddProductToCar(teamid, quantity.ToString(), "", Convert.ToDecimal(money), teammodel.Image, max, teammodel.Farefree.ToString(), fee, Server.UrlEncode(result.Replace("|", "-").Replace(",", ".")), min);

        }

    }

    
    /// <summary>
    /// 得到促销活动规则ID
    /// </summary>
    /// <returns></returns>
    public string getPromotionID()
    {
        ICategory category = Store.CreateCategory();
        CategoryFilter cf = new CategoryFilter();
        CategoryFilter cf1 = new CategoryFilter();
        CategoryFilter cf2 = new CategoryFilter();
        int free_shipping;
        int Deduction;
        int Feeding_amount;
        cf.Ename = "Free_shipping";
        cf.Zone = "activity";
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            free_shipping = seion.Category.Get(cf).Id;
        }

        cf1.Ename = "Deduction";
        cf1.Zone = "activity";
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            Deduction = seion.Category.Get(cf1).Id;
        }

        cf2.Ename = "Feeding_amount";
        cf2.Zone = "activity";
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            Feeding_amount = seion.Category.Get(cf2).Id;
        }

        string PromotionID = free_shipping + "," + Deduction + "," + Feeding_amount;
        return PromotionID;
    }


    #region 删除购物车中的信息
    public void delete(string teamid)
    {
        CookieCar.DeleteProduct(teamid);
        if (Request["ty"] == "jd")
        {
            Response.Redirect(GetUrl("京东购物车列表", "mall_jdcart.aspx"));
        }
        else
        {
            Response.Redirect(GetUrl("购物车列表", "shopcart_show.aspx"));
        }
        
    }

    #endregion


    #region 把选中的商品添加到临时购物车
    public void AddCar(string teamid)
    {

        Judge(Convert.ToInt32(teamid));
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(Convert.ToInt32(teamid));
        }
        //判断这个项目的数量是否>=免单数量，如果成立，没有运费，不成立，有运费
        if (teammodel != null)
        {
            if (teammodel.Delivery == "coupon" || teammodel.Delivery == "draw" || teammodel.Delivery == "pcoupon" || teammodel.Team_type == "seconds" || PageValue.CurrentSystemConfig["closeshopcar"] == "1")
            {
                if (teammodel.Delivery == "pcoupon")
                {
                    if (!ActionHelper.isCoupon(Helper.GetInt(teamid, 0)))//如果商户优惠券，没有，那么无法进行购买
                    {
                        SetError("友情提示：此项目暂时无法进行购买");
                        Response.Redirect(WebRoot + "index.aspx");
                        Response.End();
                        return;
                    }
                }
                Response.Redirect(GetUrl("优惠卷购买", "team_buy.aspx?id=" + teammodel.Id + ""));
            }
            else
            {

                string fee = "";
                fee = teammodel.Fare.ToString();
                string max = teammodel.Per_number.ToString();
                string min = teammodel.Per_minnumber.ToString();
                string num = "1";
                if (min != "0")
                {
                    num = min;
                }
                if (Helper.GetInt(teammodel.open_invent, 0) == 1)  //开启库存功能
                {
                    max = Math.Min(Helper.GetInt(teammodel.Per_number, 0), Helper.GetInt(teammodel.inventory, 0)).ToString();
                    if (teammodel.Per_number == 0)
                    {
                        max = teammodel.inventory.ToString();
                    }
                }
                CookieCar.AddProductToCar(teamid, num, "", teammodel.Team_price, teammodel.Image, max, teammodel.Farefree.ToString(), fee, "", min);
                Response.Redirect(GetUrl("购物车列表", "shopcart_show.aspx"));
            }
        }
    }
    #endregion

    public void AddMallCar(string teamid)
    {
        Judge(Convert.ToInt32(teamid));
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(Convert.ToInt32(teamid));
        }
        System.Collections.Specialized.NameValueCollection configs = WebUtils.GetSystem();
        //判断这个项目的数量是否>=免单数量，如果成立，没有运费，不成立，有运费
        if (teammodel.Delivery == "coupon" || teammodel.Delivery == "draw" || teammodel.Delivery == "pcoupon" || teammodel.Team_type == "seconds")
        {
            if (teammodel.Delivery == "pcoupon")
            {
                if (!ActionHelper.isCoupon(Helper.GetInt(teamid, 0)))//如果商户优惠券，没有，那么无法进行购买
                {
                    SetError("友情提示：此项目暂时无法进行购买");
                    Response.Redirect(WebRoot + "index.aspx");
                    Response.End();
                    return;
                }
            }
            Response.Redirect(GetUrl("优惠卷购买", "team_buy.aspx?id=" + teammodel.Id + ""));
        }
        else
        {
            string fee = "";
            fee = teammodel.Fare.ToString();
            string max = teammodel.Per_number.ToString();
            string min = teammodel.Per_minnumber.ToString();
            string num = "1";
            if (min != "0")
            {
                num = min;
            }
            if (Helper.GetInt(teammodel.open_invent, 0) == 1)  //开启库存功能
            {
                max = Math.Min(Helper.GetInt(teammodel.Per_number, 0), Helper.GetInt(teammodel.inventory, 0)).ToString();
                if (teammodel.Per_number == 0)
                {
                    max = teammodel.inventory.ToString();
                }
            }
            CookieCar.AddProductToCar(teamid, num, "", teammodel.Team_price, teammodel.Image, max, teammodel.Farefree.ToString(), fee, "", min);
            if (Request["go"] != null && Request["go"].ToString() == "show")
            {
                if (Helper.GetString(Request["ty"], String.Empty) == "jd")
                {
                    Response.Redirect(GetUrl("京东购物车列表", "mall_jdcart.aspx"));
                }
                else
                {
                    Response.Redirect(GetUrl("购物车列表", "shopcart_show.aspx"));
                }
            }
            else
            {
                Response.Write("1");
            }
        }
    }

    #region 把选中的商品添加到临时购物车
    /// <summary>
    /// 选中的商品添加到临时购物车
    /// </summary>
    /// <param name="teamid">项目id</param>
    /// <param name="num">数量</param>
    /// <param name="result">规格</param>
    public void AddCar(string teamid, string num, string result)
    {
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(Convert.ToInt32(teamid));
        }

        string htmlresult = "";

        bool isExistrule = false;

        if (teammodel.open_invent == 1)//开启库存
        {
            invent = Utility.isinvent(Helper.GetString(result, ""), Helper.GetString(teammodel.invent_result, ""));
            isExistrule = Utility.GetNewOld(result, teammodel.invent_result);
        }
        if (Utility.Getnum(result) > 0)
        {
            if (Utility.Getrule(result))
            {
                htmlresult = "友情提示：您不可以选择一样的规格，请重新选择";
            }
            else if (isExistrule)
            {
                //result = "友情提示:您选择的产品库存数量为0，无法购买";
                htmlresult = "友情提示:您选择了此项目所没有的规格，请重新选择";
            }
            else if (invent)
            {
                htmlresult = "友情提示:您购买的数量超过了库存数量，请减少一些";
            }
            else if (teammodel.teamcata == 0 && Utility.Getnum(result) > teammodel.Per_number && teammodel.Per_number > 0)
            {
                htmlresult = "友情提示:您最多可以购买" + teammodel.Per_number + "个";
            }
            else if (Utility.Getnum(result) < teammodel.Per_minnumber && teammodel.Per_minnumber > 0)
            {
                htmlresult = "友情提示:您最低必须购买" + teammodel.Per_minnumber + "个";
            }
        }
        else
        {
            htmlresult = "友情提示:您的购买数量不能小于1个";
        }

        if (htmlresult != "")
        {

            Response.Write(htmlresult);
        }
        else
        {
            string fee = "";
            fee = teammodel.Fare.ToString();
            string max = teammodel.Per_number.ToString();
            string min = teammodel.Per_minnumber.ToString();
            if (min != "0")
            {
                num = min;
            }
            if (Helper.GetInt(teammodel.open_invent, 0) == 1)  //开启库存功能
            {
                max = Math.Min(Helper.GetInt(teammodel.Per_number, 0), Helper.GetInt(teammodel.inventory, 0)).ToString();
                if (teammodel.Per_number == 0)
                {
                    max = teammodel.inventory.ToString();
                }
            }
            CookieCar.AddProductToCar(teamid, num, "", Getdrulemoney(teamid, result), teammodel.Image, max, teammodel.Farefree.ToString(), fee, result.Replace("|", "-").Replace(",", "."), min);
            Response.Write("true");
        }

    }
    #endregion



    #region 判断如果项目之可以购买一次，并且，用户在项目下过成功订单，那么用户不可以购买此项目，
    public void Judge(int teamid)
    {
        // orderlist = orderbll.GetByUserid(userbll.Getuserid(UserName), teamid);

        // DataSet ds = new DataSet();
        // ds = Maticsoft.DBUtility.DbHelperSQL.Query("select * from [Order],orderdetail where [Order].Id=orderdetail.Order_id and  Teamid=" + teamid + " and User_id=" + userbll.Getuserid(UserName) + "");

        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(Convert.ToInt32(teamid));
        }
        if (teammodel == null)
        {
            SetError("没有该项目");
            Response.Redirect(WebRoot + "index.aspx");
            Response.End();
            return;
        }
        if (CookieUtils.GetCookieValue("username").Length > 0)
        {
            if (teammodel.teamcata == 0)
            {
                int detailcount;
                int ordercount;
                OrderDetailFilter of = new OrderDetailFilter();
                of.order_userid = AsUser.Id;
                of.Teamid = teamid;
                of.order_state = "pay";
                //统计订单详情里的项目
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    detailcount = seion.OrderDetail.GetDetailCount(of);
                }

                OrderFilter orderf = new OrderFilter();
                orderf.User_id = AsUser.Id;
                orderf.Team_id = teamid;
                orderf.State = "pay";

                //统计订单里的项目
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ordercount = seion.Orders.GetCount(orderf);
                }

                if (teammodel.Buyonce == "Y")
                {
                    if (detailcount + ordercount > 0)
                    {
                        SetError("您已经购买过此项目，当前项目只允许购买一次");
                        Response.Redirect(WebRoot + "index.aspx");
                        Response.End();
                        return;
                    }
                }
                else if (teammodel.Buyonce == "N") //可以购买多次
                {
                    if (teammodel.Team_type == "normal")
                    { }
                    else
                    {
                        if (teammodel.Now_number < teammodel.Max_number || teammodel.Max_number == 0)
                        {

                            //当前项目购买数量
                            int buycount = TeamMethod.GetBuyCount(AsUser.Id, teammodel.Id);

                            if (teammodel.Per_number > 0)//当前项目设置了每人限购数量
                            {
                                if (buycount >= teammodel.Per_number)//当前用户的购买数量大于限购数量 
                                {
                                    SetError("您购买本单产品的数量已经达到上限，快去关注一下其他产品吧！");
                                    Response.Redirect(WebRoot + "index.aspx");
                                    Response.End();
                                    return;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    #endregion

    #region 找到不同规格下的价格
    public decimal Getdrulemoney(string teamid, string result)
    {
        decimal rulemoney = 999999;
        if (result != "")//没有规格
        {
            //result = result.Replace("{", "").Replace("}", "").Substring(0, result.LastIndexOf(',') - 1);

            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                teammodel = seion.Teams.GetByID(Convert.ToInt32(teamid));
            }
            if (teammodel.invent_result!=null&&teammodel.invent_result.Contains("价格"))//有规格但没有设置不同价格
            {
                rulemoney = Convert.ToDecimal(Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, result));
            }
            else
            {
                rulemoney = teammodel.Team_price;
            }
        }
        else
        {
            rulemoney = teammodel.Team_price;
        }
        return rulemoney;
    }


    #endregion

    //快递费的计算规则
    public decimal GetFarfee(string teamid, int n, string f)
    {
        decimal fee = 0;
        int sum = 0;
        try
        {
            int farfee;
            carlist = CookieCar.GetCarData();
            decimal[] num = new decimal[carlist.Count];
            //计算快递费,找出购物车中最大的运费
            for (int i = 0; i < carlist.Count; i++)
            {
                if (carlist[i].Qid == teamid)
                {
                    sum += n;
                    num[i] = decimal.Parse(f);
                }
                else
                {
                    num[i] = decimal.Parse(carlist[i].Fee);
                    sum += Convert.ToInt32(CookieCar.GetProductInfo(carlist[i].Qid).Split(',')[1]);
                }
                //  decimal.Parse[carlist[0+1].Fee]
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
</script>
