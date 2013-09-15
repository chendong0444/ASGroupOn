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
    public IPromotion_rules p = Store.CreatePromotion_rules();
    public IOrder ordermodel = Store.CreateOrder();
    public IOrder orderNewmodel = Store.CreateOrder();
    protected string abbreviation = String.Empty;//网站简称
    protected string footlogo = String.Empty;
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
    protected IUser iuser = null;
    protected IList<IPacket> iListPacket = null;
    protected bool isPacket = false;
    protected string headlogo = String.Empty;
    public NameValueCollection _system = new NameValueCollection();
    protected string sitename = String.Empty;
    protected string icp = String.Empty;
    protected string statcode = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();
        if (AsUser.Id != 0)
        {
            PacketFilter packetfilter = new PacketFilter();
            packetfilter.State = "0";
            packetfilter.User_id = AsUser.Id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iListPacket = session.Packet.GetList(packetfilter);
            }
            if (iListPacket != null && iListPacket.Count > 0)
            {
                isPacket = true;
            }
        }
        if (ASSystem != null)
        {
            abbreviation = ASSystem.abbreviation;
            if (PageValue.CurrentSystemConfig["mallheadlogo"] != null && PageValue.CurrentSystemConfig["mallheadlogo"].ToString() != "")
            {
                headlogo = PageValue.CurrentSystemConfig["mallheadlogo"];
            }
            else
            {
                headlogo = "/upfile/img/mall_logo.png";
            }
            if (PageValue.CurrentSystemConfig["mallfootlogo"] != null && PageValue.CurrentSystemConfig["mallfootlogo"].ToString() != "")
            {
                footlogo = _system["mallfootlogo"];
            }
            else
            {
                footlogo = ASSystem.footlogo;
            }
            abbreviation = ASSystem.abbreviation;
            sitename = ASSystem.sitename;
            icp = ASSystem.icp;
            statcode = ASSystem.statcode;
        }
        //删除选定
        if (Request.QueryString["item"] != null)
        {
            string items = Request.QueryString["item"];
            string[] item = items.Split(';');
            foreach (string itemreid in item)
            {
                string[] reid = itemreid.Split('|');
                int id = Helper.GetInt(reid[0], 0);
                string res = reid[1].ToString();
                if (id != 0)
                {
                    if (id != null)
                    {
                        if (id != null && id.ToString() != "")
                        {
                            CookieCar.DeleteProduct(id.ToString(), res);
                        }
                        else
                        {
                            delete(id.ToString());
                        }
                    }
                }

            }
            Response.Redirect(GetUrl("京东购物车列表", "mall_jdcart.aspx"));
        }
        if (ASSystem.title == String.Empty)
        {
            PageValue.Title = "购物车";
        }
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
    }
    #region 删除购物车中的信息
    public void delete(string teamid)
    {
        CookieCar.DeleteProduct(teamid);
        //Response.Redirect(Request.UrlReferrer.ToString());

        Response.Redirect(GetUrl("京东购物车列表", "mall_jdcart.aspx"));
    }

    #endregion
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
                ITeam teammodel = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teammodel = session.Teams.GetByID(Helper.GetInt(carmodel.Qid, 0));
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
                    ITeam teammodel = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        teammodel = session.Teams.GetByID(Helper.GetInt(carmodel.Qid, 0));
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
                ITeam teammodel = null;
                TeamFilter tf = new TeamFilter();
                tf.Id = Convert.ToInt32(carlist[i].Qid);
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teammodel = seion.Teams.Get(tf);
                }
                if (teammodel != null)
                {
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
            string sql = "  teamcata=1 and Begin_time<='" + DateTime.Now.ToString() + "' and End_time>='" + DateTime.Now.ToString() + "' and ((Max_number>0 and Now_number<Max_number) or(Max_number=0))) and((open_invent=1 and inventory>0)or(open_invent=0))";
            return sql;
        }

    }
    #endregion

    public void SearchTodayTeam()
    {
        if (ASSystem.guowushu == 0)
            pagecount = 30;
        else
            pagecount = ASSystem.guowushu;
        string notid = GetTeamid();
        string sql = "select top 31 * from team where teamcata=1 and ((open_invent=1 and inventory>0) or open_invent=0) and Delivery='express' " + notid + " order by  sort_order desc,Begin_time desc,id desc";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teamlist = session.Teams.GetList(sql);
        }
    }
  

    public void GetCuXiao(decimal totalprice)
    {
        Sales_promotionFilter sf = new Sales_promotionFilter();
        System.Collections.Generic.IList<ISales_promotion> sallist = null;
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
    <meta name="keywords" content="<%=PageValue.KeyWord %>" />
    <meta name="description" content="<%=PageValue.Description%>" />
    <link href="/upfile/css/index.css" rel="stylesheet" type="text/css" />
    <link href="/upfile/css/purchase.2012.css" rel="stylesheet" type="text/css" />
    <link rel="icon" href="<%=PageValue.WebRoot %>upfile/icon/favicon.ico" mce_href="<%=PageValue.WebRoot %>upfile/icon/favicon.ico" type="image/x-icon">
    <title>我的购物车 - <%=PageValue.CurrentSystemConfig["malltitle"]%></title>
    <script type='text/javascript' src="<%=PageValue.WebRoot %>upfile/js/index.js"></script>
    <script type='text/javascript'>webroot = '<%=PageValue.WebRoot %>'; LOGINUID = '<%=AsUser.Id %>';</script>
    <script type="text/javascript" charset="utf-8" src="<%=PageValue.WebRoot %>upfile/js/lrscroll.js"></script>
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
            X.get("<%=PageValue.WebRoot %>ajax/car.aspx?ty=jd&proid=" + teamid + "&num=" + n);

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
            X.get("<%=PageValue.WebRoot %>ajax/car.aspx?ty=jd&teamid=" + teamid + "&num=" + n);
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
            X.get(webroot+"ajax/car.aspx?ty=jd&teamid=" + teamid + "&num=" + n);

        }
        function show2(teamid, num, price, total, max, min, teamcata, alls, isalls) {
       
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
            if (isalls == 1) {
                if (alls != 0) {
                    if (n > alls) {
                        document.getElementById(num).value = alls;
                        n = alls;
                        alert("友情提示：已经超出库存，请少买一点点！");
                        return;
                    }
                }
            }
            var t = parseFloat(n * p);
            document.getElementById(total).innerHTML = t.toFixed(2);
            X.get("<%=PageValue.WebRoot %>ajax/car.aspx?ty=jd&teamid=" + teamid + "&num=" + n);
        }
        function shopcar(teamid, count, reresult) {

            $("#num" + teamid).blur();
            
            X.get("<%=PageValue.WebRoot %>ajax/coupon.aspx?action=shopcar&ty=jd&teamid=" + teamid + "&count=" + count + "&result=" + reresult + "");
           
        }
    </script>
    <script type="text/javascript">
        X.coupon.shopcar = function (id, result) {
            if (id) return !X.get('<%=PageValue.WebRoot %>ajax/car.aspx?ty=jd&proid=' + encodeURIComponent(id) + "&result=" + result + "&a=" + Math.random());
            else
                return false;
        };
        function addToFavorite() {
            var d = "<%=PageValue.WWWprefix%>";
            var c = '<%=PageValue.CurrentSystemConfig["mallsitename"] %>';
            if (document.all) {
                window.external.AddFavorite(d, c)
            } else {
                if (window.sidebar) {
                    window.sidebar.addPanel(c, d, "")
                } else {
                    alert("\u5bf9\u4e0d\u8d77\uff0c\u60a8\u7684\u6d4f\u89c8\u5668\u4e0d\u652f\u6301\u6b64\u64cd\u4f5c!\n\u8bf7\u60a8\u4f7f\u7528\u83dc\u5355\u680f\u6216Ctrl+D\u6536\u85cf\u672c\u7ad9\u3002")
                }
            }
        }
    </script>
</head>
<body>
    <div id="pagemasker">
    </div>
    <div id="dialog" style="display: none; background-color: rgb(255, 255, 255); left: 517.5px; top: 73.8px; z-index: 10000;">
    </div>
    <div id="shortcut-2013">
        <div class="w">
            <ul class="fl lh">
                <li class="fore1 ld"><b></b><a rel="nofollow" href="javascript:addToFavorite()">收藏<%= PageValue.CurrentSystemConfig["mallsitename"]%></a>
                </li>
            </ul>
            <ul class="fr lh">
                <%if (IsLogin && AsUser.Id != 0)
                  { %>
                <% if (AsUser.Realname != null && AsUser.Realname != "")
                   {%>

                <li class="fore1" id="loginbar">您好，
                        <%=AsUser.Realname%>！<a href="<%=PageValue.WebRoot %>loginout.aspx" class="link-logout">[退出]</a></li>
                <li class="fore2 ld"><s></s><a href="<%=GetUrl("我的订单", "order_index.aspx")%>" rel="nofollow">我的订单</a></li>
                <%if (isPacket == true)
                  {%>
                <li class="fore3 ld"><s></s><a href="<%=GetUrl("我的红包", "order_packet.aspx")%>" rel="nofollow">我的红包</a></li>
                <%} %>
                <%}
                   else
                   { %>

                <li class="fore1" id="loginbar">您好，<%=AsUser.Username%>！<a href="<%=PageValue.WebRoot %>loginout.aspx"
                    class="link-logout">[退出]</a></li>
                <li class="fore2 ld"><s></s><a href="<%=GetUrl("我的订单", "order_index.aspx")%>" rel="nofollow">我的订单</a></li>
                <%} %>
                <%}
                  else
                  {%>
                <li class="fore1" id="loginbar">您好！欢迎来到<%= PageValue.CurrentSystemConfig["mallsitename"]%>！<span><a
                    href="<%=GetUrl("用户登录", "account_login.aspx")%>">[登录]</a>&nbsp;<a href="<%=GetUrl("用户注册", "account_loginandreg.aspx")%>">[免费注册]</a></span></li>
                <%} %>
                <span class="clr"></span>
            </ul>
        </div>
    </div>
    <!--shortcut end-->
    <div class="w w1 header clearfix">
        <div id="logo">
            <a href="<%=GetUrl("商城首页","mall_index.aspx")%>">
                <b></b>
                <img src="<%=headlogo %>" width="259" height="50" alt="<%= PageValue.CurrentSystemConfig["mallsitename"]%>"></a>
        </div>
        <div class="language">
            <a href="javascript:void(0);"></a>
        </div>
        <div class="progress clearfix">
            <ul class="progress-1">
                <li class="step-1"><b></b>1.我的购物车</li>
                <li class="step-2"><b></b>2.填写核对订单信息</li>
                <li class="step-3">3.成功提交订单</li>
            </ul>
        </div>
    </div>
    <div class="w cart">
        <div class="cart-hd group">
            <h2>我的购物车</h2>
            <span id="show2" class="fore"></span>
        </div>
        <div id="show">
            <!-- 延保和赠品宏定义开始 -->
            <!-- 延保和赠品宏定义结束 -->
            <div class="cart-frame">
                <div class="tl">
                </div>
                <div class="tr">
                </div>
            </div>
            <div class="cart-inner">
                <%if (carlist != null)
                  {%>
                <% decimal sum = 0; %>
                <div class="cart-thead clearfix">
                    <%--                    <div class="column t-checkbox form">
                     <input type="checkbox" id="ckalll" />
                      
                   </div>--%>
                    <div class="column t-goods">
                        商品
                    </div>
                    <div class="column t-promotion">
                        规格
                    </div>
                    <div class="column t-quantity">
                        数量
                    </div>
                    <div class="column t-price">
                        价格
                    </div>
                    <div class="column t-inventory">
                        <span id="location">总价</span>
                    </div>
                    <div class="column t-inventory">
                        操作
                    </div>
                </div>

            </div>
            <%foreach (Car model in carlist)
              {
                  ITeam teammodel = null;
                  using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                  {
                      teammodel = session.Teams.GetByID(Helper.GetInt(model.Qid, 0));
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

                                  if (Server.UrlDecode(model.Result) != "")
                                  {
                                      rulemoney = Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, Server.UrlDecode(model.Result).Replace("-", "|").Replace(".", ","));
                                  }
                                  else//没有规格或者有规格没有设置不同价格
                                  {
                                      rulemoney = teammodel.Team_price.ToString();
                                  }
                                  sum += Convert.ToDecimal(rulemoney) * model.Quantity;

                                                                 
                                                        
            %>
            <div id="product-list" class="cart-tbody">
                <!-- ************************商品开始********************* -->
                <!-- ***************************************************** -->
                <!-- 主商品 -->
                <div data-bind="rowid:1" class="item item_selected  item-last">
                    <div class="item_form clearfix">
                        <%--    <div class="cell p-checkbox">
                        <input name='checkboxs' type="checkbox" id="ckboxs" result="<%=Utility.GetCarfont(Server.UrlDecode(model.Result)) %>"  value="<%=model.Qid %>" />
                         </div>--%>
                        <div class="cell p-goods">
                            <div class="p-img" style="border: 1px solid #ddd;">
                                <a href="<%=getTeamPageUrl(int.Parse(model.Qid))  %>" target="_blank">
                                    <img src="<%=ImageHelper.getSmallImgUrl(model.Pic) %>" class="dynload" style="height: 52px; border: 1px #aeaeae solid" />
                                </a>
                            </div>
                            <div class="p-name">
                                <a class="clickcart|keycount|xincart|productnamelink" href="<%=getTeamPageUrl(int.Parse(model.Qid))  %>"
                                    target="_blank" title="<%=teammodel.Title %>">
                                    <%=Helper.GetSubString(teammodel.Title.ToString(), 65)%><k id="nn" style="color:Red"><%=Getcarresult(Server.UrlDecode(model.Result), model.Quantity.ToString()) %></k></a>
                            </div>
                        </div>
                        <input type="hidden" id="txt" runat="server" />
                        <div class="cell p-inventory stock-833547">
                            <%if (teammodel != null)
                              { %>
                            <% if (Utility.Getbulletin(teammodel.bulletin) != "")
                               {%>

                            <% if ((teammodel.open_invent.ToString() == "1" && Helper.GetInt(teammodel.inventory.ToString(), 0) > 0) || teammodel.open_invent.ToString() == "0")
                               {%>
                            <%if (model.Result == "")
                              {%>
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
                            <%}%>
                            <%}%>
                            <%}%>
                            <%}%>
                        </div>
                        <div class="cell p-quantity">
                            <div class="quantity-form" data-bind="">
                                <div class="num_div" style="width: 78px;">
                                    <%if (Utility.Getbulletin(teammodel.bulletin) != "")
                                      {%>
                                    <input type="text" class="quantity-text" carnum="<%=model.Quantity %>" id="num<%=model.Qid %>"
                                        idval="<%=model.Qid %>" maxval="<%=model.Weight %>" minval="<%=model.min %>"
                                        onclick="shopcar(<%=model.Qid %>,this.value, encodeURIComponent('<%=Server.UrlDecode(model.Result) %>'))"
                                        class="input-text f-input1 deal-buy-quantity-input lf_input1" maxlength="4" name="guigeshuliang"
                                        value="<%=model.Quantity %>" alt="socking1027" category="product" />
                                    <%}
                                      else
                                      {%>
                                    <a onclick="show1('<%=model.Qid %>','num<%=model.Qid %>','price<%=model.Qid %>','total<%=model.Qid %>','<%=model.Weight %>','<%=model.min %>','<%=teammodel.teamcata%>')"
                                        class="decrement" clstag="clickcart|keycount|xincart|diminish1" id="decrement-206767-1-11-49205595">-</a>

                                        <a onclick="show2('<%=model.Qid %>','num<%=model.Qid %>','price<%=model.Qid %>','total<%=model.Qid %>','<%=model.Weight %>','<%=model.min %>','<%=teammodel.teamcata%>','<%=teammodel.inventory %>','<%=teammodel.open_invent %>')"
                                            class="increment" clstag="clickcart|keycount|xincart|add1" id="increment-206767-1-11-0-49205595">
                                            +</a>
                                            
                                    <input type="text" class="quantity-text" id="num<%=model.Qid %>" idval="<%=model.Qid %>"
                                        maxval="<%=model.Weight %>" minval="<%=model.min %>" onchange="show('<%=model.Qid %>','num<%=model.Qid %>','price<%=model.Qid %>','total<%=model.Qid %>','<%=model.Weight %>','<%=model.min %>','<%=teammodel.teamcata%>')"
                                        class="input-text f-input1 deal-buy-quantity-input lf_input1" maxlength="4" name="shuliang"
                                        value="<%=model.Quantity %>" alt="socking1027" category="product" />
                                          
                                    <%}%>
                                    <br />
                                    <%if (model.Farfee != "0")
                                      { %>
                                    <font style="color: #999999; font-size: 12px;">包邮≥<%=model.Farfee%>件</font>
                                    <% }%>
                                </div>
                            </div>
                        </div>
                        <div class="cell p-price">
                            <span class="price">
                                <%=ASSystem.currency%><span id="price<%=model.Qid %>"><%=rulemoney%></span></span>
                        </div>
                        <div class="cell p-price" id="tol" style="height: 10px; text-align: center">
                             <span class="price"><%=ASSystem.currency%><span style="color: Black;" id="total<%=model.Qid %>" title="total">
                                <%=Convert.ToDecimal(rulemoney) * model.Quantity%></span></span>
                        </div>
                        <div class="cell p-remove">
                            <a class="cart-remove" href="<%=WebRoot%>ajax/car.aspx?ty=jd&delid=<%=model.Qid %>&result=<%=Utility.GetCarfont(Server.UrlDecode(model.Result)) %>"
                                ask="确认不购买此商品?">删除 </a>
                        </div>
                    </div>
                    <div class="item_extra">
                    </div>
                    <!-- 延保和赠品 -->
                </div>
            </div>
            <!-- product-list结束 -->
            <%}%>
            <%}%>
            <%}%>
            <%}%>
            <%}%>
            <div class="cart-toolbar clearfix">
                <%--                <div class="control fl">
                    <span class="delete"><b></b>
                   
                    <a href="javascript:void(0);" onclick="javascript:GetDeleteItem(); " clstag="clickcart|keycount|xincart|clearcartlink"
                        id="remove-batch">删除选中的商品</a></span>
                        <input id="items" runat="server" type="hidden" />
                </div>--%>
                <div class="total fr">
                </div>
            </div>
            <div class="cart-total clearfix">
                <div class="control fl clearfix">
                </div>
                <div class="total fr">
                    <span style="color: #f00; font-size: 12px; padding-bottom: 5px">
                        <span style="float: left; color: #c00; font-size: 20px; font-weight: 400; font-family: Verdana,Arial;"><%=ASSystem.currency %></span> <span id="sum">
                            <%=sum%>
                        </span></span>总计（不含运费）：
                </div>
            </div>
        </div>
        <!-- cart-inner结束 -->
        <div class="cart-frame">
            <div class="bl">
            </div>
            <div class="br">
            </div>
        </div>
        <div class="cart-button clearfix">
            <script type="text/javascript">
                function checksubmit() {
                    if ($("a[select='no']").length > 0) {
                        alert("请先选择产品的规格，再提交订单");
                        return;
                    }
                    $.ajax({
                        type: "POST",
                        url: '<%=WebRoot%>ajax/car.aspx?ty=jd&SplitOrder=choice',
                        success: function (msg) {

                            var arrg = msg.split(',');
                            if (arrg[0] == "1") {

                                location.href = '<%=GetUrl("京东购物车订单", "shop_jdconfirmation.aspx")%>' + '?orderid=' + arrg[1];
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
            <a class="btn continue" href="<%=GetUrl("商城首页","mall_index.aspx") %>" clstag="clickcart|keycount|xincart|continueBuyBtn"
                id="continue"><span class="btn-text">继续购物</span></a> <a href="javascript:void(0)"
                    onclick="checksubmit()" class="checkout" name="buy2" clstag="clickcart|keycount|xincart|gotoOrderInfo"
                    id="toSettlement">去结算</a>
        </div>
        <%}
                  else
                  {%>
        <div class="cart-inner cart-empty">
            <div class="message">
                <ul>
                    <li>购物车内暂时没有商品</li>
                    <a href="<%=GetUrl("商城首页","mall_index.aspx")%>">去首页</a>挑选喜欢的商品
                </ul>
            </div>
        </div>
        <%}%>
    </div>
    <div class="cart-removed" style="display: none;">
        <div class="r-title">
            已删除商品，您可以重新购买或加关注：
        </div>
    </div>
    <div id="c-tabs" class="w w1" data-widget="tabs" style="">
        <div class="m plist" style="width: 1000px;">
            <div class="cm fore1 curr" data-widget="tab-item" id="recommend-products" style="">
                <div class="cmt">
                    <h3>
                        <i></i>以下团购项目正在团购</h3>
                </div>
                <!--循环结束-->
                <script type="text/javascript">
                    $(function () {
                        $("#botton-scroll").jCarouselLite({
                            btnNext: "#recommend-rigth",
                            btnPrev: "#recommend-left"
                        });
                    });
                    $(function () {
                        $('#top-menu li').hover(
                        function () { $('ul', this).slideDown(200); },
                        function () {
                            $('ul', this).slideUp(200);
                        });
                    });

                    $(function () {
                        $(".click").click(function () {
                            $("#panel").slideToggle("slow");
                            $(this).toggleClass("active"); return false;
                        });
                    });

                    $(function () {
                        $('.fade').hover(
                    function () { $(this).fadeTo("slow", 0.5); },
                    function () {
                        $(this).fadeTo("slow", 5);
                    });
                    });
                    $(function () {
                        $("#botton-scroll").css('width', '1000px');
                    });
                </script>
                <div id="cmc" style="clear: both; padding: 10px 55px; border: 1px solid #ddd;">
                    <div id="feature">
                        <div id="block">
                            <div id="botton-scroll">
                                <ul class="featureUL">
                                    <%foreach (ITeam teammodel in teamlist)
                                      { %>
                                    <li style="float: left; width: 218px; padding: 0 8px;">
                                        <div class="p-img">
                                            <a href="<%=getTeamPageUrl(teammodel.Id)  %>" target="_blank">
                                                <img style="margin-left: 10px;" height="130" alt="<%=teammodel.Title%>" src="<%=teammodel.Image%>"  />
                                            </a>
                                        </div>
                                        <div class="p-name" style="margin-left: 10px;">
                                            <a href="<%=getTeamPageUrl(teammodel.Id)  %>" target="_blank">
                                                <%=Helper.GetSubString(teammodel.Product, 80)%></a>
                                        </div>
                                        <div class="p-price" style="margin-left: 10px;">
                                            <span>
                                                <%=ASSystem.currency%><%=teammodel.Team_price%></span>
                                        </div>
                                         <%if (Utilys.GetTeamType(teammodel.Id))
                                         {%>
                                         <div class="p-btn">
                                            <a href="<%=getTeamPageUrl(teammodel.Id)%>" class="btn">
                                            <span class="btn-icon"></span><span class="btn-text">查看详情</span></a>
                                        </div>  
                                        <%}
                                           else
                                           {%>
                                            <div class="p-btn">
                                            <a href="<%=WebRoot%>ajax/car.aspx?id=<%=teammodel.Id %>&type=mall&ty=jd&go=show" class="btn">
                                            <span class="btn-icon"></span><span class="btn-text">加入购物车</span></a>
                                        </div>    
                                         <%}%>
                                    </li>
                                    <%}%>
                                </ul>
                            </div>
                            <!-- /botton-scroll -->
                        </div>
                        <!-- /block -->

                        <!-- /feature -->
                    </div>
                    <div id="recommend-left" class="" href="javascript:void();">
                    </div>
                    <div id="recommend-rigth" href="javascript:void();"></div>
                    <!-- /featureContainer -->
                    <div id="wrap">
                        <span id="load">LOADING...</span>
                    </div>
                    <!-- /wrap -->
                </div>
                <!-- /featured -->
            </div>
        </div>
    </div>
    <!--@end #c-tabs-->
    <div style="clear: both">
    </div>
    <div class="w">
        <div id="service-2013">
            <dl class="fore1">
                <dt><b></b><strong></strong></dt>
                <dd>
                    <div>
                        <a href="<%=GetUrl("玩转东购团","help_tour.aspx")%>">玩转<%=abbreviation%></a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("常见问题","help_faqs.aspx")%>">常见问题</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("东购团概念","help_asdht.aspx")%>"><%=abbreviation%>概念</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("开发API","help_api.aspx")%>">开发API</a>
                    </div>

                </dd>
            </dl>
            <dl class="fore2">
                <dt><b></b><strong></strong></dt>
                <dd>
                    <div>
                        <a href="<%=GetUrl("邮件订阅","help_Email_Subscribe.aspx?cityid="+CurrentCity.Id)%>">邮件订阅</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("RSS订阅","help_RSS_feed.aspx?ename="+CurrentCity.Ename)%>">RSS订阅</a>
                    </div>
                    <%if (ASSystem.sinablog != "")
                      {%>
                    <div><a href="<%=ASSystem.sinablog %>" target="_blank">新浪微博</a></div>
                    <%} %>
                    <%if (ASSystem.qqblog != "")
                      {%>
                    <div><a href="<%=ASSystem.qqblog %>" target="_blank">腾讯微博</a></div>
                    <%} %>
                </dd>
            </dl>
            <dl class="fore4">
                <dt><b></b><strong></strong></dt>
                <dd>
                    <div>
                        <a href="<%=GetUrl("关于东购团","about_us.aspx")%>">关于<%=abbreviation %></a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("工作机会","about_job.aspx")%>">工作机会</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("联系方式","about_contact.aspx")%>">联系方式</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("用户协议","about_terms.aspx")%>">用户协议</a>
                    </div>
                </dd>
            </dl>
            <dl class="fore5">
                <dt><b></b><strong></strong></dt>
                <dd>
                    <div>
                        <a href="<%=GetUrl("商务合作","feedback_seller.aspx")%>">商务合作</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("友情链接","help_link.aspx")%>">友情链接</a>
                    </div>
                    <div>
                        <a href="<%=GetUrl("后台管理","Login.aspx")%>">后台管理</a>
                    </div>
                </dd>
            </dl>
            <div class="fr">
                <div class="sm" id="branch-office">
                    <%if (Request.Url.ToString().ToLower().IndexOf("/mall/") > 0)
                      { %>
                    <a href="<%=WebRoot%>mall/index.aspx">
                        <%if (_system != null && _system["mallfootlogo"] != null && _system["mallfootlogo"].ToString() != "")
                          { %>
                        <img src="<%=_system["mallfootlogo"].ToString() %>" />
                        <%}
                          else
                          { %>
                        <img src="/upfile/img/mall_logo.png" />
                        <%}%>
                    </a>
                    <%}
                      else
                      {%>
                    <a href="<%=GetUrl("商城首页","mall_index.aspx") %>">
                        <img src="<%=footlogo %>" /></a>
                    <%}%>
                </div>
            </div>
            <span class="clr"></span>
        </div>
    </div>
    <div class="w">
        <div id="footer-2013">
            <div class="copyright">
                &copy;<span>2010</span>&nbsp;<%=sitename
                %>（<%=WWWprefix %>）版权所有&nbsp;<a href="<%=GetUrl("用户协议","about_terms.aspx")%>">使用<%=abbreviation
                %>前必读</a><br />
                <a href="http://www.miibeian.gov.cn/" target="_blank"><%=icp %></a>&nbsp;&nbsp;<%=statcode
                %> &nbsp;Powered by 正大团(沪ICP备13015182号)
            </div>
        </div>
    </div>
</body>
</html>
