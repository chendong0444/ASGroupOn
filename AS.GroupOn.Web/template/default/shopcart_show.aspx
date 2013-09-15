<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="AS.GroupOn.Domain.Spi" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public ITeam teammodel = Store.CreateTeam();
    public IPromotion_rules p = Store.CreatePromotion_rules();
    public IOrder ordermodel = Store.CreateOrder();
    public IOrder orderNewmodel = Store.CreateOrder();
    public IOrderDetail orderdemodel = Store.CreateOrderDetail();
    public ICatalogs catamodel = Store.CreateCatalogs();
    protected NameValueCollection configs = new NameValueCollection();
    public List<Car> carlist = new List<Car>();
    public IPagers<ITeam> pager = null;
    public IList<ITeam> teamlist = null;
    public IList<ITeam> goodlist = null;
    public int count = 0;
    protected string url = "";
    public string pagenum = "1";
    public string page = "1";
    public int farfee = 0;//免单数量
    public string strpage;//团购项目分页数
    public string strpageGood;//热销商品分页数
    public int pagecount = 0;
    public int fare_shoping;
    public decimal jian;
    public decimal fan;
    public string child = "";//记录父类下面的子类
    public string keyid = "";//分类的编号
    public bool flag = false;
    public string keyname = "";//分类的名称
    public string kfid = "";
    public int cataid = 0;//获取项目的分类的编号
    public string name = "";//获取项目的分类的名称
    public List<key> keylist = new List<key>();
    public IList<ICatalogs> catalist = null;//显示大类
    public IList<ICatalogs> cataloglist = null;//根据条件显示全部类别
    public IList<ICatalogs> catafatherlist = null;//查询全部的父类
    public IList<ICatalogs> catachildlist = null;//查询父类下的子类
    public IList<ICatalogs> childlist = null;//查询子类下的子类
    public int currentcityid = 0;
    public decimal sums;
    public string rulemoney = "999999";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (CurrentCity != null)
        {
            currentcityid = CurrentCity.Id;
        }
        //初始化参数
        configs = WebUtils.GetSystem();
        if (Request["pagenum"] != null)
        {
            if (NumberUtils.IsNum(Request["pagenum"].ToString()))
            {
                pagenum = Request["pagenum"].ToString();
            }
            else
            {
                SetError("您输入的参数非法");
            }
        }
        if (Request["page"] != null)
        {
            if (NumberUtils.IsNum(Request["page"].ToString()))
            {
                page = Request["page"].ToString();
            }
            else
            {
                SetError("您输入的参数非法");
            }
        }
        Search();
        if (Request["s"] != null)
        {
            AddCar();
        }
        SearchTodayTeam();
        SearchTodayGoods();

    }
    public string Getcarresult(string result, string quality)
    {
        string carresult = Utility.GetCarfont(Server.UrlDecode(result));
        if (!carresult.Contains(","))
        {
            carresult = "[" + quality + "]";
        }
        else
        {
            //carresult = carresult.Substring(0, carresult.LastIndexOf(',') + 1) + quality + "]";
        }
        return carresult;
    }
    //根据分类编号，显示分类下面的信息
    public string GetBycata(int cataid, string key)
    {
        string cid = "0";
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            catamodel = seion.Catalogs.GetByID(cataid);
        }

        if (catamodel != null)
        {
            if (Helper.GetString(catamodel.ids, "") != "")
            {
                cid = catamodel.ids + "," + cataid;
            }
            else
            {
                cid = cataid.ToString();
            }
        }
        string str = " ";

        if (cid != "0")
        {
            str += " and cataid in (" + cid + ")";
        }
        if (key != "")
        {
            str += " and catakey like '%" + key + "%'";
        }
        return str;
    }
    //获取cookie里面的项目编号
    public string GetTeamid()
    {
        string str = string.Empty;
        carlist = CookieCar.GetCarData();
        if (carlist != null && carlist.Count > 0)
        {
            str += " and Id not in (";
            foreach (Car carmodel in carlist)
            {
                str += Helper.GetInt(carmodel.Qid, 0) + ",";
            }
            str = str.Substring(0, str.Length - 1); ;
            str += ")";
        }
        return str;
    }
    #region 显示子类下面的子类
    public void GetChildList(int id)
    {
        childlist = AS.GroupOn.Controls.Catalogs.GetCata(" parent_id=" + id + "");
    }
    #endregion


    #region 显示大类
    public void GetCata()
    {
        catalist = AS.GroupOn.Controls.Catalogs.GettopCata(8);
    }
    #endregion

    #region 根据条件显示全部类别
    public void Getcatalist()
    {
        cataloglist = AS.GroupOn.Controls.Catalogs.GetCata("");
    }
    #endregion
    #region 显示所有父类
    public void Getfather()
    {
        int city = 0;
        if (CurrentCity != null)
        {
            city = CurrentCity.Id;
        }
        catafatherlist = AS.GroupOn.Controls.Catalogs.GettopCata(city);
    }
    #endregion
    #region 显示关键字
    public void GetKey(string key)
    {
        string city = "0";
        if (CurrentCity != null)
        {
            city = CurrentCity.Id.ToString();
        }
        keylist = TeamMethod.Getkey(key, city);

    }
    #endregion
    #region 提交订单
    public virtual int AddCar()
    {
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
        int cashnum = 0;
        int orderid = 0;
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
                // ordermodel.CashParent_orderid = 0;
                ordermodel.Express = "Y";
                ordermodel.IP_Address = CookieUtils.GetCookieValue("gourl");
                ordermodel.fromdomain = CookieUtils.GetCookieValue("fromdomain");
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    seion.Orders.Insert(ordermodel);
                }

                int orderNewId = 0;
                if (flag == true)
                {
                    //添加一个条件（如果选择拆分则拆分） if()
                    orderNewmodel.User_id = AsUser.Id;
                    orderNewmodel.State = "unpay";
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
                    orderNewmodel.CashParent_orderid = orderid;
                    orderNewmodel.Service = "cashondelivery";
                    orderNewmodel.Express = "Y";
                    orderNewmodel.IP_Address = CookieUtils.GetCookieValue("gourl");
                    orderNewmodel.fromdomain = CookieUtils.GetCookieValue("fromdomain");
                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        orderNewId = seion.Orders.Insert(orderNewmodel);
                    }


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

                                        if (Server.UrlDecode(carmodel.Result) != "" && teammodel.invent_result.Contains("价格"))
                                        {
                                            orderdemodel.Teamprice = Convert.ToDecimal(Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, Server.UrlDecode(carmodel.Result).Replace("{", "").Replace("}", "").Substring(0, Server.UrlDecode(carmodel.Result).LastIndexOf('.') - 1).Replace("-", "|").Replace(".", ",")));
                                        }
                                        else//没有规格或者有规格没有设置不同价格
                                        {
                                            orderdemodel.Teamprice = teammodel.Team_price;
                                        }

                                        //orderdemodel.Teamprice = teammodel.Team_price;
                                        if (flag == true)
                                        {
                                            if (teammodel.cashOnDelivery == "0" || teammodel.cashOnDelivery == null || teammodel.cashOnDelivery == "")
                                            {
                                                orderdemodel.Order_id = orderid;
                                            }
                                            else//没有规格或者有规格没有设置不同价格
                                            {
                                                orderdemodel.Teamprice = teammodel.Team_price;
                                            }

                                            //orderdemodel.Teamprice = teammodel.Team_price;
                                            if (flag == true)
                                            {
                                                if (teammodel.cashOnDelivery == "0" || teammodel.cashOnDelivery == null || teammodel.cashOnDelivery == "")
                                                {
                                                    orderdemodel.Order_id = orderid;
                                                }
                                                else
                                                {
                                                    orderdemodel.Order_id = orderNewId;
                                                }

                                            }
                                            else
                                            {
                                                orderdemodel.Order_id = orderNewId;
                                            }
                                        }
                                        else
                                        {
                                            orderdemodel.Order_id = orderid;
                                        }

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
                                // orderdemodel.Teamprice = teammodel.Team_price;
                                //找到不同规格下的价格
                                if (Server.UrlDecode(carmodel.Result) != "" && teammodel.invent_result.Contains("价格"))
                                {
                                    orderdemodel.Teamprice = Convert.ToDecimal(Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, Server.UrlDecode(carmodel.Result).Replace("{", "").Replace("}", "").Substring(0, Server.UrlDecode(carmodel.Result).LastIndexOf('.') - 1).Replace("-", "|").Replace(".", ",")));
                                }
                                else//没有规格或者有规格没有设置不同价格
                                {
                                    orderdemodel.Teamprice = teammodel.Team_price;
                                }
                                if (flag == true)
                                {
                                    if (teammodel.cashOnDelivery == "0" || teammodel.cashOnDelivery == null || teammodel.cashOnDelivery == "")
                                    {
                                        orderdemodel.Order_id = orderid;
                                    }
                                    else
                                    {
                                        orderdemodel.Order_id = orderNewId;
                                    }
                                }
                                else
                                {
                                    orderdemodel.Order_id = orderid;
                                }
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

                if (fare_shoping == 1)
                {
                    orderf.Fare = 0;
                    orderf.Id = orderid;
                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        seion.Orders.UpdateFare(orderf);
                    }
                }
                else
                {
                    orderf.Fare = ActionHelper.System_GetFare(orderid, WebUtils.config, String.Empty, 0);
                    orderf.Id = orderid;
                }
                if (jian != 0)
                {
                    orderf.Origin = Helper.GetDecimal((DBHelper.GetTeamTotalPriceWithFare(orderid) - jian), 0);
                    orderf.Id = orderid;

                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        seion.Orders.UpdateOrigin(orderf);
                    }

                }
                else
                {
                    orderf.Origin = DBHelper.GetTeamTotalPriceWithFare(orderid);
                    orderf.Id = orderid;

                    using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        seion.Orders.UpdateOrigin(orderf);
                    }

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

    #region 显示购物车
    public void Search()
    {
        carlist = CookieCar.GetCarData();
        GetFarfee();
    }
    #endregion


    #region 快递费的计算规则
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
                TeamFilter tf = new TeamFilter();
                tf.Id = Convert.ToInt32(carlist[i].Qid);
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teammodel = seion.Teams.Get(tf);
                }
                if (teammodel.Begin_time <= DateTime.Now && teammodel.End_time >= DateTime.Now)
                {
                    if (teammodel.Delivery != "coupon" && teammodel.Team_type == "normal")
                    {
                        if (((teammodel.Max_number > 0 && teammodel.Now_number < teammodel.Max_number) || (teammodel.Max_number == 0)))
                        {
                            num[i] = decimal.Parse(carlist[i].Fee);
                            sum += Convert.ToInt32(carlist[i].Quantity);
                        }
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
    #endregion
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
            string sql = "  teamcata=0 and Begin_time<='" + DateTime.Now.ToString() + "' and End_time>='" + DateTime.Now.ToString() + "' and ((Delivery!='coupon' and Delivery!='draw' and Delivery!='pcoupon') and ((Max_number>0 and Now_number<Max_number) or(Max_number=0))) and((open_invent=1 and inventory>0)or(open_invent=0))";
            int cityid = Helper.GetInt(CookieUtils.GetCookieValue("cityid"), 0);
            if (cityid != 0)
            {
                sql = sql + " and (City_id=0 or City_id=" + cityid + ")";
            }
            return sql;
        }

    }
    #endregion

    #region 显示今日团购平且是快递
    public void SearchTodayTeam()
    {
        TeamFilter tf = new TeamFilter();

        string sqlwhere1 = sqlWhere;
        if (ASSystem.guowushu == 0)
        {
            pagecount = 12;
        }
        else
        {
            pagecount = ASSystem.guowushu;
        }
        string txt2 = GetTeamid();

        sqlwhere1 += " and Team_type='normal' " + GetTeamid() + " ";
        string txt = sqlwhere1;

        //*************分页显示********

        url = url + "&pagenum={0}";
        url = GetUrl("购物车列表", "shopcart_show.aspx?" + url.Substring(1));
        tf.where = sqlwhere1;
        tf.PageSize = pagecount;
        tf.CurrentPage = Helper.GetInt(Request.QueryString["pagenum"], 1);
        tf.AddSortOrder(TeamFilter.MoreSort);
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = seion.Teams.GetPager(tf);
        }
        teamlist = pager.Objects;

        //if (teamlist.Count == 0)
        //{
        //    strpage = "对不起，没有相关数据team";
        //}
        //else
        //{
            if (pager.TotalRecords >= pagecount)
            {
                strpage = AS.Common.Utils.WebUtils.GetPagerHtml(pagecount, pager.TotalRecords, pager.CurrentPage, url);
            }
        //}
    }
    #endregion
    #region 显示今日热销平且是快递
    public void SearchTodayGoods()
    {
        TeamFilter tf = new TeamFilter();
        if (Helper.GetInt(configs["txtshuGood"], 0) > 0)
        {
            pagecount = Helper.GetInt(configs["txtshuGood"], 0);
        }
        else
        {
            pagecount = 12;
        }

        string sqlwhere1 = sqlWhere;

        sqlwhere1 += " and Team_type='goods' " + GetTeamid();
        string txt = sqlwhere1;


        //*************分页显示********

        url = url + "&page={0}";
        url = GetUrl("购物车列表", "shopcart_show.aspx?" + url.Substring(1));
        tf.where = sqlwhere1;
        tf.PageSize = pagecount;
        tf.CurrentPage = Helper.GetInt(Request.QueryString["page"], 1);
        tf.AddSortOrder(TeamFilter.MoreSort);
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = seion.Teams.GetPager(tf);
        }
        goodlist = pager.Objects;

        //if (goodlist.Count == 0)
        //{
        //    strpageGood = "对不起，没有相关数据good";
        //}
        //else
        //{
            if (pager.TotalRecords >= pagecount)
            {
                strpageGood = WebUtils.GetPagerHtml(pagecount, pager.TotalRecords, pager.CurrentPage, url);
            }
        //}
    }
    #endregion
    public void GetCuXiao(decimal totalprice)
    {
        Sales_promotionFilter sf = new Sales_promotionFilter();
        IList<ISales_promotion> sallist = null;
        sf.start_time = DateTime.Now;
        sf.end_time = DateTime.Now;
        sf.enable = 1;
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            sallist = seion.Sales_promotion.GetList(sf);
        }

        StringBuilder sb1 = new StringBuilder();
        jian = 0;

        if (sallist != null && sallist.Count > 0)
        {
            foreach (ISales_promotion sale_pro in sallist)
            {

                Promotion_rulesFilter pf = new Promotion_rulesFilter();
                IList<IPromotion_rules> prolist = null;
                pf.Tostart_time = DateTime.Now;
                pf.Fromend_time = DateTime.Now;
                pf.enable = 1;
                pf.Tofull_money = totalprice;
                pf.activtyid = sale_pro.id;
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
    
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta name="keywords" content="<%=PageValue.KeyWord %>"/>
<meta name="description" content="<%=PageValue.Description %>" />
<script type='text/javascript' src="<%=PageValue.WebRoot %>upfile/js/index.js"></script>
<script type="text/javascript" src="<%=PageValue.WebRoot %>upfile/js/srolltop.js"></script>
<%if (IsTotw)
  {%>
<script>totw = true;</script>
<script type='text/javascript' src="<%=PageValue.WebRoot %>upfile/js/zhtotw.js" + "></script>
<%}
  else
  {%>
<script>      totw = false;</script>
  <%} %>
<script type='text/javascript'>webroot = '<%=PageValue.WebRoot %>'; LOGINUID = '<%=PageValue.CurrentUser %>';</script>
<link rel="stylesheet" href="<%=PageValue.CssPath %>/css/index.css" type="text/css" media="screen" charset="utf-8" />
<title><%=PageValue.Title%></title>
</head>
<body class="newbie">
<div id="pagemasker">
</div>
<div id="dialog" style="display: none; background-color: rgb(255, 255, 255); left: 517.5px; top: 73.8px; z-index: 10000;">
</div>
<div id="doc">
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
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
        X.get(webroot + "ajax/car.aspx?proid=" + teamid + "&num=" + n);

    }
    function show(teamid, num, price, total, max, min, teamcata) {
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
        if (n <= 0) {
            document.getElementById(num).value = 1;
            n = 1;
        }
        if (max != 0 & teamcata == 0) {
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
        X.get(webroot + "ajax/car.aspx?teamid=" + teamid + "&num=" + n);

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
    function show1(teamid, num, price, total, max, min, teamcata) {
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

        if (max != 0 & teamcata == 0) {
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
        X.get(webroot + "ajax/car.aspx?teamid=" + teamid + "&num=" + n);

    }
    function show2(teamid, num, price, total, max, min, teamcata) {
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
        if (max != 0 & teamcata == 0) {
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
        X.get(webroot + "ajax/car.aspx?teamid=" + teamid + "&num=" + n);

    }
    function shopcar(teamid, count, reresult) {
        $("#num" + teamid).blur();
        X.get(webroot + "ajax/coupon.aspx?action=shopcar&teamid=" + teamid + "&count=" + count + "&result=" + reresult + "");
    }
</script>
<style type="text/css">
    .style1
    {
        width: 329px;
    }
</style>
<input type="hidden" name="totalNumber" value="" />
<div id="header_container">
    <div class="bdw" id="bdw">
        <div class="cf" id="bd">
            <div class="box-content">
                <table width="958" border="0" align="center" cellpadding="0" cellspacing="0" style="padding-left: 10px; padding-right: 10px;">
                    <tr bgcolor="#FFFFFF">
                        <td>
                            <table width="938px" border="0" align="center" cellpadding="0">
                                <tr>
                                    <td>
                                        <img src="<%=(ImagePath()+"step1.png") %>" />
                                    </td>
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
                                        <%if (carlist != null)
                                          {
                                              decimal sum = 0;
                                        %>
                                        <table width="930" border="0" cellspacing="0" cellpadding="0">
                                            <tr bgcolor="#F2F2F2">
                                                <td colspan="2" align="center">项目
                                                </td>
                                                <td width="300" align="center">规格
                                                </td>
                                                <td width="174" align="center">数量
                                                </td>
                                                <td width="27" align="center">&nbsp;
                                                </td>
                                                <td width="96" align="center">价格
                                                </td>
                                                <td width="29" align="center">&nbsp;
                                                </td>
                                                <td width="80" align="center">总价
                                                </td>
                                                <td width="100" align="center">操作
                                                </td>
                                            </tr>
                                            <%foreach (Car model in carlist)
                                              {
                                                  using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                                                  {
                                                      teammodel = seion.Teams.GetByID(Helper.GetInt(model.Qid, 0));
                                                  }
                                                  if (teammodel != null)
                                                  {
                                                      if ((teammodel.Begin_time <= DateTime.Now && teammodel.End_time >= DateTime.Now) || teammodel.teamcata == 1)
                                                      {
                                                          if (teammodel.Delivery != "coupon" && teammodel.Team_type != "seconds" && teammodel.Delivery != "draw" && teammodel.Delivery != "pcoupon")
                                                          {
                                                              if (((teammodel.Max_number > 0 && teammodel.Now_number < teammodel.Max_number) || (teammodel.Max_number == 0) || (teammodel.teamcata == 1)))
                                                              {
                                                                  //找到不同规格下的价格

                                                                  string result = Server.UrlDecode(model.Result).Replace("-", "|").Replace(".", ",");
                                                                  if (teammodel.invent_result != null && teammodel.invent_result.ToString()!="")
                                                                  {
                                                                      if (Server.UrlDecode(model.Result) != "" && teammodel.invent_result.Contains("价格"))
                                                                      {
                                                                          rulemoney = Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, Server.UrlDecode(model.Result).Replace("-", "|").Replace(".", ","));
                                                                      }
                                                                      else 
                                                                      {
                                                                          rulemoney = teammodel.Team_price.ToString();
                                                                      }
                                                                  }
                                                                  else//没有规格或者有规格没有设置不同价格
                                                                  {
                                                                      rulemoney = teammodel.Team_price.ToString();
                                                                  }
                                                                  sum += Convert.ToDecimal(rulemoney) * model.Quantity;

                                                                 
                                                        
                                            %>
                                            <tr>
                                                <td width="132" align="center" style="padding: 10px">
                                                    <a href="<%=getTeamPageUrl(int.Parse(model.Qid))  %>"
                                                        target="_blank">
                                                        <img src="<%=ImageHelper.getSmallImgUrl(model.Pic) %>" class="dynload" style="width: 110px; height: 70px; border: 1px #aeaeae solid" /></a>
                                                </td>
                                                <td width="307" style="padding: 10px">
                                                    <a href="<%=getTeamPageUrl(int.Parse(model.Qid))  %>" target="_blank" title="<%=teammodel.Title %>" >
                                                    <%=Helper.GetSubString(teammodel.Title.ToString(), 65) + Getcarresult(Server.UrlDecode(model.Result), model.Quantity.ToString())%></a>

                                                </td>
                                                <td align="center" valign="middle" style="padding: 0px; width: 190px; font-size: 12px;">
                                                    <%
                                                                  if (teammodel != null)
                                                                  {
                                                                      if (Utility.Getbulletin(teammodel.bulletin) != "")
                                                                      {
                                                                          if (model.Result == "")
                                                                          {       
                                                               
                                                                                  
                                                    %>
                                                    <a select="no" href="javascript:shopcar(<%=model.Qid %>, <%=model.Quantity %>, encodeURIComponent('<%=Server.UrlDecode(model.Result) %>'))"
                                                        style="color: red">
                                                        <img src="<%=PageValue.WebRoot%>upfile/css/i/02461220.gif" width="16px" height="17px"><br />
                                                        【请点击选择规格】 </a>
                                                    <% }
                                                                      else
                                                                      {%>
                                                    <img src="<%=PageValue.WebRoot%>upfile/css/i/pcde_416.png" />
                                                    <br />
                                                    <a href="javascript:shopcar(<%=model.Qid %>,<%=model.Quantity %>,encodeURIComponent('<%=Server.UrlDecode(model.Result) %>'))"
                                                        style="color: red; line-height: 20px;">修改 </a>
                                                    <% }
                                                                  }
                                                              }%>
                                                </td>
                                                <td align="center" style="padding: 10px">
                                                    <div class="num_div">
                                                        <%if (Utility.Getbulletin(teammodel.bulletin) != "")
                                                          { %>
                                                        <input type="text" carnum="<%=model.Quantity %>" id="num<%=model.Qid %>" idval="<%=model.Qid %>"
                                                            maxval="<%=model.Weight %>" minval="<%=model.min %>" onclick="shopcar(<%=model.Qid %>,this.value, encodeURIComponent('<%=Server.UrlDecode(model.Result) %>    '))"
                                                            class="input-text f-input1 deal-buy-quantity-input lf_input1" maxlength="4" name="guigeshuliang"
                                                            value="<%=model.Quantity %>" alt="socking1027" category="product" />
                                                        <% }
                                                          else
                                                          {
                                                              ITeam teamm = Store.CreateTeam();
                                                              using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                                                              {
                                                                  teamm = seion.Teams.GetByID(Helper.GetInt(model.Qid, 0));
                                                              }
                                                            
                                                        %>
                                                        <span class="crease decrease" onclick="show2('<%=model.Qid %>','num<%=model.Qid %>','price<%=model.Qid %>','total<%=model.Qid %>','<%=model.Weight %>','<%=model.min %>','<%=teamm.teamcata%>')"></span>
                                                        <span class="crease" onclick="show1('<%=model.Qid %>','num<%=model.Qid %>','price<%=model.Qid %>','total<%=model.Qid %>','<%=model.Weight %>','<%=model.min %>','<%=teamm.teamcata%>')"></span>
                                                        <input type="text" id="num<%=model.Qid %>" idval="<%=model.Qid %>" maxval="<%=model.Weight %>"
                                                            minval="<%=model.min %>" onchange="show('<%=model.Qid %>','num<%=model.Qid %>','price<%=model.Qid %>','total<%=model.Qid %>','<%=model.Weight %>','<%=model.min %>','<%=teamm.teamcata%>')"
                                                            class="input-text f-input1 deal-buy-quantity-input lf_input1" maxlength="4" name="shuliang"
                                                            value="<%=model.Quantity %>" alt="socking1027" category="product" />
                                                        <% }%>
                                                        <br />
                                                        <br />
                                                        <%if (model.Farfee != "0")
                                                          { %>
                                                        <font style='color: #999999; font-size: 12px;'>包邮≥<%=model.Farfee%>件</font>
                                                        <% }%>
                                                    </div>
                                                   
                                                </td>
                                                <td align="center" style="padding: 10px">x
                                                </td>
                                                <td align="center" style="padding: 10px">
                                                    <%=ASSystem.currency%><span id="price<%=model.Qid %>"><%=rulemoney%></span>
                                                </td>
                                                <td align="center" style="padding: 10px">=
                                                </td>
                                                <td align="center" style="padding: 10px">
                                                    <%=ASSystem.currency%><span id="total<%=model.Qid %>" title="total"><%=Convert.ToDecimal(rulemoney) * model.Quantity%></span>
                                                </td>
                                                <td align="center" style="padding: 10px">
                                                    <a href="<%=WebRoot%>ajax/car.aspx?delid=<%=model.Qid %>&result=<%=Utility.GetCarfont(Server.UrlDecode(model.Result)) %>"
                                                        ask="确认不购买此商品?">删除</a>
                                                </td>
                                            </tr>
                                            <%  }
                                                          }
                                                      }
                                                  }
                                              }%>
                                            <tr>
                                                <td colspan="2" style="padding: 10px">
                                                    <span style="color: #f00; font-size: 16px; padding-bottom: 5px">应付总额（不含运费）</span>
                                                </td>
                                                <td style="padding: 10px">&nbsp;
                                                </td>
                                                <td style="padding: 10px">&nbsp;
                                                </td>
                                                <td style="padding: 10px">&nbsp;
                                                </td>
                                                <td style="padding: 10px"></td>
                                                <td style="padding: 10px">=
                                                </td>
                                                <td style="padding: 10px">
                                                    <span style="color: #f00; font-size: 12px; padding-bottom: 5px">
                                                        <%=ASSystem.currency %><span id="sum">
                                                            <%=sum%>
                                                        </span></span>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="8">
                                                    <input type="button" onclick="checksubmit()" class="formbutton" name="buy2" value="确认无误，去结算" />
                                                    <a href="<%=WebRoot%>index.aspx">继续挑选其他商品</a>
                                                </td>
                                            </tr>
                                        </table>
                                        <script>
                                            function checksubmit() {
                                                if ($("a[select='no']").length > 0) {
                                                    alert("请先选择产品的规格，再提交订单");
                                                    return;
                                                }
                                                $.ajax({
                                                    type: "POST",
                                                    url: webroot + 'ajax/car.aspx?SplitOrder=choice',
                                                    success: function (msg) {
                                                        var arrg = msg.split(',');
                                                        if (arrg[0] == "1") {
                                                            location.href = '<%=GetUrl("购物车订单", "shopcart_confirmation.aspx")%>' + '?orderid=' + arrg[1];
                                                        }
                                                        else if (msg == "2") {

                                                            location.href = '<%=GetUrl("用户注册", "account_loginandreg.aspx")%>';
                                                        }
                                                        else if (msg != "2" && arrg[0] != "1") {
                                                            $("#dialog").html(msg);
                                                            $("#dialog").css("display", "block");
                                                            $("#pagemasker").css({ 'position': 'absolute', 'z-index': '3000', 'width': '1423px', 'height': '2249px', 'filter': 'alpha(opacity=0.5)', 'opacity': ' 0.5', 'top': '0', 'left': '0', 'background': '#CCC', 'display': 'block' });
                                                        }

                                                    }
                                                });
                                            }
                                        </script>
                                        <%}
                                          else
                                          { %>
                                        <table width="958" border="0" cellspacing="10" cellpadding="0">
                                            <tr>
                                                <td>
                                                    <a href="<%=WebRoot%>Index.aspx">
                                                        <img src="<%=(ImagePath()+"empty_cart.png") %>" width="442" height="173" /></a>
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
                                                <td bgcolor="#FFFFFF">
                                                    <strong><span class="have_tg">还有以下团购项目正在团购 </span></strong>
                                                </td>
                                            </tr>
                                        </table>
                                        <div class="list_grid">
                                            <!--循环开始（循环deal_shop这个div）-->
                                            <%foreach (ITeam teammodel in teamlist)
                                              {%>
                                            <!--正在团购商品开始-->
                                            <div class="deal_shop">
                                                <div class="list_img">
                                                    <a href="<%=getTeamPageUrl(teammodel.Id)  %>"
                                                        target="_blank">
                                                        <img alt="<%=teammodel.Title%>" <%=ashelper.getimgsrc(ImageHelper.getSmallImgUrl(teammodel.Image)) %>
                                                            width="218" class="dynload" height="139"></a>
                                                </div>
                                                <div class="list_bt">
                                                    <a href="<%=getTeamPageUrl(teammodel.Id)  %>"
                                                        target="_blank">
                                                        <%=teammodel.Product %></a>
                                                </div>
                                                <div class="list_jg">
                                                    <span>
                                                        <%=ASSystem.currency%><%=teammodel.Team_price%></span> <span class="cart-discount">(<%=WebUtils.GetDiscount(Helper.GetDecimal(teammodel.Market_price, 0),Helper.GetDecimal(teammodel.Team_price, 0)).Replace("折", "")%>折)</span>
                                                    <%if (teammodel.Farefree != 0)
                                                      {%>
                                                    <span class="cart-by">
                                                        <%=teammodel.Farefree %>件或以上包邮</span>
                                                    <% }%>
                                                </div>
                                                
                                                <% if (Utilys.GetTeamType(teammodel.Id))
                                                    {%>
                                                <div class="list_botton-detail">
                                                    <a target="_blank" href="<%=getTeamPageUrl(teammodel.Id) %>" title="去看看"></a>
                                                </div> 
                                                    <%}else{%>
                                                <div class="list_botton">
                                                    <a class="formbutton" href='<%=WebRoot%>ajax/car.aspx?id=<%=teammodel.Id%>'></a>
                                                </div>
                                                    <%}%>
                                            </div>
                                            <% 
                                              }%>
                                            <!--循环结束-->
                                            <div class="clear">
                                            </div>
                                            <div>
                                                <%=strpage %>
                                            </div>
                                        </div>
                                        <%if (goodlist.Count > 0)
                                          {%>
                                        <table width="938px" border="0" align="center" cellpadding="0">
                                            <tr>
                                                <td bgcolor="#FFFFFF">
                                                    <strong><span class="have_rx">还有以下热销项目正在团购 </span></strong>
                                                </td>
                                            </tr>
                                        </table>
                                        <%} %>
                                        <div class="list_grid">
                                            <!--循环开始（循环deal_shop这个div）-->
                                            <%foreach (ITeam teammodel in goodlist)
                                              {
                                                  
                                            %>
                                            <!--正在热销商品开始-->
                                            <div class="deal_shop">
                                                <div class="list_img">
                                                    <a href="<%=getTeamPageUrl(teammodel.Id)  %>"
                                                        target="_blank">
                                                        <img alt="<%=teammodel.Title%>" <%=ashelper.getimgsrc(ImageHelper.getSmallImgUrl(teammodel.Image)) %>
                                                            class="dynload" width="218" height="139"></a>
                                                </div>
                                                <div class="list_bt">
                                                    <a href="<%=getTeamPageUrl(teammodel.Id)  %>"
                                                        target="_blank">
                                                        <%=teammodel.Product %></a>
                                                </div>
                                                <div class="list_jg">
                                                    <span>
                                                        <%=ASSystem.currency%><%=teammodel.Team_price%></span> <span class="cart-discount">(<%=WebUtils.GetDiscount(Helper.GetDecimal(teammodel.Market_price, 0), Helper.GetDecimal(teammodel.Team_price, 0)).Replace("折", "")%>折)</span>
                                                    <% if (teammodel.Farefree != 0)
                                                       {%>
                                                    <span class="cart-by">
                                                        <%=teammodel.Farefree%>件或以上包邮 </span>
                                                    <% }%>
                                                </div>
                                                  <% if (!Utilys.GetTeamType(teammodel.Id))
                                                       {%>
                                                    <div class="list_botton">
                                                         <a class="formbutton" href='<%=WebRoot%>ajax/car.aspx?id=<%=teammodel.Id%>'></a>
                                                    </div>
                                                      <%}else
                                                       { %>
                                                    <div class="list_botton-detail">
                                                       <a title="去看看" target="_blank" href="<%=getTeamPageUrl(teammodel.Id) %>"></a>
                                                    </div>
                                                    <%}%>
                                         
                                            </div>
                                            <% 
                                              }%>
                                            <!--循环结束-->
                                            <div class="clear">
                                            </div>
                                            <div>
                                                <%=strpageGood %>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
