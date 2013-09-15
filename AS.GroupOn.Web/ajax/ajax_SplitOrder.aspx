<%@ Page Language="C#" AutoEventWireup="true" Debug="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace=" System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public IPartner_Detail pdmodel = null;
    public List<Car> carlist = new List<Car>();
    public IOrder ordermodel = Store.CreateOrder();
    public IOrder orderNewmodel = Store.CreateOrder();
    public IOrderDetail orderdemodel = Store.CreateOrderDetail();
    public ITeam teammodel = null;
    public decimal sums;
    public int fare_shoping;
    public decimal jian;
    public decimal fan;
    public bool flag = false;
    public int orderid = 0;
    public NameValueCollection _system = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        _system = PageValue.CurrentSystemConfig;
        if (Request["split"] == "true")
        {
            flag = true;
            AddCar();
        }
        else if (Request["split"] == "false")
        {
            flag = false;
            AddCar();
        }
    }
    //提交订单
    public virtual void AddCar()
    {
        NeedLogin();
        //未付款订单处理方法：在生成订单前。得到1个小时内，此用户的未付款的，购物车的订单。然后将状态更改为cancel 在创建新 订单 
        bool isfei = false;
        decimal total = 0;
        //非货到付款的商品数量
        int num = 0;
        //货到付款的数量
        int cashnum = 0;

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
                using (IDataSession session = Store.OpenSession(false))
                {
                    teammodel = session.Teams.GetByID(Convert.ToInt32(carmodel.Qid));
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

                                                IProduct product = null;
                                                using (IDataSession session = Store.OpenSession(false))
                                                {
                                                    product = session.Product.GetByID(teammodel.productid);
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
                                if (flag == true)
                                {
                                    if (teammodel.cashOnDelivery == "0")
                                    {
                                        num += carmodel.Quantity;
                                    }
                                    else if (teammodel.cashOnDelivery == "1")
                                    {
                                        cashnum = carmodel.Quantity;
                                    }
                                }
                                else
                                {
                                    num += carmodel.Quantity;
                                }

                                total += carmodel.Price * carmodel.Quantity;

                                if (Utility.Getbulletin(teammodel.bulletin) != "")
                                {
                                    if (carmodel.Result == "")
                                    {

                                        SetError("友情提示：请选择项目的规格");
                                        return;
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
                if (AsUser.Id != 0)
                {
                    ordermodel.User_id = AsUser.Id;
                }
                ordermodel.State = "unpay";
                //记录非货到付款的数量
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
                using (IDataSession session = Store.OpenSession(false))
                {
                    orderid = session.Orders.Insert(ordermodel);
                }
                int orderNewId = 0;
                //flag为true时则是选择了订单拆分，需要拆分成两个订单
                if (flag == true)
                {
                    //添加一个条件（如果选择拆分则拆分） if()
                    orderNewmodel.User_id = AsUser.Id;
                    orderNewmodel.State = "unpay";
                    //拆分后的订单商品的数量
                    orderNewmodel.Quantity = cashnum;
                    orderNewmodel.Create_time = DateTime.Now;
                    if (CurrentCity != null)
                    {
                        orderNewmodel.City_id = CurrentCity.Id;
                    }
                    else
                    {
                        orderNewmodel.City_id = 0;
                    }
                    //添加一个父订单的编号数据库中添加一字段，记录其父订单的编号
                    //将order表中的service字段标记为cashondelivery
                    //将父订单的编号记录
                    orderNewmodel.CashParent_orderid = orderid;
                    orderNewmodel.Service = "cashondelivery";
                    orderNewmodel.Express = "Y";
                    orderNewmodel.IP_Address = CookieUtils.GetCookieValue("gourl");
                    orderNewmodel.fromdomain = CookieUtils.GetCookieValue("fromdomain");
                    //子订单的编号
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        orderNewId = session.Orders.Insert(orderNewmodel);
                    }
                }
                foreach (Car carmodel in carlist)
                {
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        teammodel = session.Teams.GetByID(Convert.ToInt32(carmodel.Qid));
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

                                        if (Server.UrlDecode(carmodel.Result) != "" && teammodel.invent_result != null && teammodel.invent_result.Contains("价格"))
                                        {
                                            orderdemodel.Teamprice = Convert.ToDecimal(Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, Server.UrlDecode(carmodel.Result).Replace("{", "").Replace("}", "").Substring(0, Server.UrlDecode(carmodel.Result).LastIndexOf('.') - 1).Replace("-", "|").Replace(".", ",")));
                                        }
                                        else//没有规格或者有规格没有设置不同价格
                                        {
                                            orderdemodel.Teamprice = teammodel.Team_price;
                                        }

                                        //订单拆分后在订单详情表中分别记录货到付款和非货到付款的订单号
                                        if (flag == true)
                                        {
                                            //根据项目是否为货到付款在订单详情表中记录订单号
                                            if (teammodel.cashOnDelivery == "0" || teammodel.cashOnDelivery == null || teammodel.cashOnDelivery == "")
                                            {
                                                //非货到付款的订单编号
                                                orderdemodel.Order_id = orderid;
                                            }
                                            else
                                            {
                                                //货到付款的订单编号
                                                orderdemodel.Order_id = orderNewId;
                                            }
                                        }
                                        //订单不拆分记录同一个订单号
                                        else
                                        {
                                            orderdemodel.Order_id = orderid;
                                        }

                                        orderdemodel.result = Server.UrlDecode(carmodel.Result.Replace("-", "|").Replace(".", ","));
                                        orderdemodel.discount = 0;
                                        sums += Helper.GetDecimal(orderdemodel.Num * orderdemodel.Teamprice, 0);
                                        CookieUtils.SetCookie("summoney", sums.ToString());
                                        GetCuXiao(sums);
                                        using (IDataSession session = Store.OpenSession(false))
                                        {
                                            session.OrderDetail.Insert(orderdemodel);
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
                                // orderdemodel.Teamprice = teammodel.Team_price;
                                //找到不同规格下的价格
                                if (Server.UrlDecode(carmodel.Result) != "" && teammodel.invent_result != null && teammodel.invent_result.Contains("价格"))
                                {
                                    orderdemodel.Teamprice = Convert.ToDecimal(Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, Server.UrlDecode(carmodel.Result).Replace("{", "").Replace("}", "").Substring(0, Server.UrlDecode(carmodel.Result).LastIndexOf('.') - 1).Replace("-", "|").Replace(".", ",")));
                                }
                                else//没有规格或者有规格没有设置不同价格
                                {
                                    orderdemodel.Teamprice = teammodel.Team_price;
                                }
                                //订单拆分
                                if (flag == true)
                                {
                                    //在订单详情表中记录非货到付款的订单编号
                                    if (teammodel.cashOnDelivery == "0" || teammodel.cashOnDelivery == null || teammodel.cashOnDelivery == "")
                                    {
                                        orderdemodel.Order_id = orderid;
                                    }
                                    //记录货到付款的订单编号
                                    else
                                    {
                                        orderdemodel.Order_id = orderNewId;
                                    }
                                }
                                //不拆分记录的订单编号
                                else
                                {
                                    orderdemodel.Order_id = orderid;
                                }
                                orderdemodel.result = Server.UrlDecode(carmodel.Result.Replace("-", "|").Replace(".", ","));
                                orderdemodel.discount = 0;
                                sums += Helper.GetDecimal(orderdemodel.Num * orderdemodel.Teamprice, 0);
                                CookieUtils.SetCookie("summoney", sums.ToString());
                                GetCuXiao(sums);
                                using (IDataSession session = Store.OpenSession(false))
                                {
                                    session.OrderDetail.Insert(orderdemodel);
                                }
                            }

                        }
                    }
                }
                if (fare_shoping == 1)
                {
                    ordermodel.Fare = 0;
                }
                else
                {
                    ordermodel.Fare = ActionHelper.System_GetFare(ordermodel.Id, _system, Helper.GetString(Request["province"], String.Empty), Helper.GetInt(Request["express"], 0));//快递费
                }
                if (jian != 0)
                {
                    ordermodel.Origin = OrderMethod.GetTeamTotalPrice(ordermodel.Id) + ordermodel.Fare - jian;

                }
                else
                {
                    ordermodel.Origin = OrderMethod.GetTeamTotalPrice(ordermodel.Id) + ordermodel.Fare;
                }
                CreateOrderOK(orderid);
                if (Request["ty"] != null)
                {
                    if (Request["ty"] == "jd")
                    {
                        Response.Redirect(GetUrl("京东购物车订单", "shop_jdconfirmation.aspx?orderid=" + orderid));
                    }
                }
                else
                {
                    Response.Redirect(GetUrl("购物车订单", "shopcart_confirmation.aspx?orderid=" + orderid));
                }
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
    public void GetCuXiao(decimal totalprice)
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
        fan = 0;
        jian = 0;
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
            foreach (IPromotion_rules promotion_rules in prolist)
            {
                IPromotion_rules iprules = Store.CreatePromotion_rules();
                string PromotionID = iprules.getPromotionID;
                string[] Pid = PromotionID.Split(',');
                int free_shipping = Helper.GetInt(Pid[0], 0);
                int Deduction = Helper.GetInt(Pid[1], 0);
                int Feeding_amount = Helper.GetInt(Pid[2], 0);
                //免运费
                if (promotion_rules.typeid == free_shipping)
                {
                    fare_shoping = promotion_rules.free_shipping;
                }
                //满额减
                if (promotion_rules.typeid == Deduction)
                {
                    jian += promotion_rules.deduction;
                }
                //满额返
                if (promotion_rules.typeid == Feeding_amount)
                {
                    fan += promotion_rules.feeding_amount;
                }
            }
        }
    }
</script>
<from runat="server">
<div id="showpaydialog" >
<div style="width: 430px;" class="order-pay-dialog-c" id="order-pay-dialog">
                <h3>
                    <span onclick="return X.boxClose();" class="close" id="order-pay-dialog-close">关闭</span></h3>
                <p class="info-sure-split">
                    订单中有货到付款的商品,请您确认是否要分开付款。</p>
                <p class="notice" id="notice-split">
                    分开付款是指把货到付款和在线支付的商品分开付款。<br />
                    请根据您的情况选择下面的支付模式：</p>
                <p class="split-pay" >
                <%if (Request["ty"] != null)
                        {
                            if (Request["ty"] == "jd")
                            { %>
                             <a  class="sure-split" href="<%=WebRoot%>ajax/ajax_SplitOrder.aspx?ty=jd&split=true" ><span style="color:#fff;">分开付款</span> 
                        </a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <a  class="sure-split" href="<%=WebRoot%>ajax/ajax_SplitOrder.aspx?ty=jd&split=false"><span style="color:#fff;">一起付款</span></a></p>
                            <%}

                        }
                  else
                  {%>
                        <a  class="sure-split" href="<%=WebRoot%>ajax/ajax_SplitOrder.aspx?split=true" ><span style="color:#fff;">分开付款</span> 
                        </a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        <a  class="sure-split" href="<%=WebRoot%>ajax/ajax_SplitOrder.aspx?split=false"><span style="color:#fff;">一起付款</span></a></p>
                <% }%>
                  
                   
            </div>
</div>
</from>
