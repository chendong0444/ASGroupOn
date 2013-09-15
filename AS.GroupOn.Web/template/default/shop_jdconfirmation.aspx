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
    public IOrder ordermodel = null;
    public IUser user = null;
    public bool falg = false;
    public string orderid = "A007"; //订单编号
    public string strpage;
    public string pagenum = "1";
    public string service = "";//支付网关默认为账户余额
    public IList<IOrderDetail> detaillist = null;
    public NameValueCollection _system = new NameValueCollection();
    bool isRedirect = false;
    bool isSame = false;//判断用户的选择的规格是否有一样的
    protected decimal totalprice = 0;//应付总额
    protected decimal fare = 0;//应付运费
    protected bool payselectexpress = false;
    protected bool receiveVisble;
    public bool isinvent = false;//判断订单的数量是否已经超出了库存
    protected bool orderemailvalidVisble = false;
    public bool isExistrule = false;//判断用户是否选择项目所没有的规格
    public int fare_shoping;
    public decimal jian;
    public decimal fan;
    public string orderNewId = "";
    public string dispaly = "";
    public bool youhui = false;
    protected string headlogo = String.Empty;
    protected string sitename = String.Empty;
    protected string icp = String.Empty;
    protected string statcode = String.Empty;
    protected string abbreviation = String.Empty;//网站简称
    protected string footlogo = String.Empty;
    protected IUser iuser = null;
    protected bool isPacket = false;
    protected IList<IPacket> iListPacket = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NeedLogin();
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
        _system = PageValue.CurrentSystemConfig;
        if (_system["payselectexpress"] == "1")
        {
            payselectexpress = true;
        }
        NeedLogin();
        int orderid = Helper.GetInt(Request["orderid"], 0);
        form1.Action = GetUrl("京东购物车订单", "shop_jdconfirmation.aspx?orderid=" + orderid);
        using (IDataSession session = Store.OpenSession(false))
        {
            ordermodel = session.Orders.GetByID(orderid);
        }
        if (ordermodel != null)
        {
            Cashorder(orderid, Helper.GetInt(ordermodel.CashParent_orderid, 0));
        }
        decimal m = Helper.GetDecimal(CookieUtils.GetCookieValue("summoney"), 0);
        if (m <= 0)
        {
            GetCuXiao(ordermodel.Origin);
        }
        GetCuXiao(m);
        if (Request.HttpMethod == "POST")
        {
            string strEmail = Helper.GetString(Request.Form["con_email"], String.Empty);
            NeedLogin();
            using (IDataSession session = Store.OpenSession(false))
            {
                ordermodel = session.Orders.GetByID(Helper.GetInt(hiorderid.Value, 0));
            }
            if (ordermodel != null)
            {
                if (ordermodel.OrderDetail.Count > 0)
                {
                    if (ordermodel.User != null)
                    {
                        user = ordermodel.User;
                    }
                    else if (AsUser.Id != 0)
                    {
                        user = AsUser;
                    }
                    AddReceive();//修改收货人信息
                    setUserTable();//修改用户信息
                    if (_system["payselectexpress"] == "1" && (Request["express"] == null || Request["province"] == ""))
                    {
                        SetError("友情提示：请选择物流公司");

                    }
                    else if (Request["province"] == null || Request["province"] == "")
                    {
                        SetError("友情提示：请选择城市");
                    }
                    else
                    {
                        ConfirmOrder(ordermodel);
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
            //用户无法修改其他用户的额单子
            if (OrderMethod.IsUserOrder(AsUser.Id, Helper.GetInt(Request["orderid"], 0)))
            {
                SetError("友情提示：无法操作其他用户的订单");
                Response.Redirect(WebRoot + "index.aspx");
                Response.End();
                return;

            }
            if (NumberUtils.IsNum(Request["orderid"].ToString()))
            {
                hiorderid.Value = Request["orderid"].ToString();
                using (IDataSession session = Store.OpenSession(false))
                {
                    ordermodel = session.Orders.GetByID(Helper.GetInt(hiorderid.Value, 0));
                }
                if (ordermodel != null && ordermodel.State != "cancel")
                {
                    string username = ordermodel.Realname;
                    if (ordermodel.User != null)
                    {
                        user = ordermodel.User;
                    }
                    else if (AsUser.Id != 0)
                    {
                        user = AsUser;
                    }
                    if (user != null)
                    {
                        ordermodel.Realname = user.Realname;
                        ordermodel.Mobile = user.Mobile;
                        ordermodel.Address = user.Address;
                        ordermodel.Zipcode = user.Zipcode;
                        ordermodel.Origin = totalprice;
                    }
                    if (!Page.IsPostBack)
                    {
                        fare = ActionHelper.System_GetFare(ordermodel.Id, _system, String.Empty, 0);
                        totalprice = OrderMethod.GetTeamTotalPrice(ordermodel.Id);
                        CookieUtils.SetCookie("fare", "0");
                        CookieUtils.SetCookie("jian", "0");
                        CookieUtils.SetCookie("fare_shoping", "0");
                        if (fare_shoping == 1)
                        {
                            CookieUtils.SetCookie("fare", fare.ToString());
                            CookieUtils.SetCookie("fare_shoping", fare_shoping.ToString());
                            fare = 0;
                        }
                        else
                        {
                            CookieUtils.SetCookie("fare", fare.ToString());
                            CookieUtils.SetCookie("fare_shoping", fare_shoping.ToString());
                        }
                        if (jian != 0)
                        {
                            CookieUtils.SetCookie("jian", jian.ToString());
                            totalprice = totalprice - jian;
                        }
                        if (OrderMethod.GetIsFreeFare(totalprice))
                        {
                            fare = 0;
                        }
                        else
                        {
                            fare = ActionHelper.System_GetFare(ordermodel.Id, _system, String.Empty, 0);
                        }
                        totalprice = fare + totalprice;
                        ordermodel.discount = Helper.GetDouble(ActionHelper.GetUserLevelMoney(AsUser.totalamount).ToString("0.00"), 0);

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
                        //团购项目才验证购买次数
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
                Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
            }
        }
    }
    /// <summary>
    /// 拆分后得到另一个货到付款的订单信息
    /// </summary>
    public void Cashorder(int orderid, int cashorderid)
    {
        IOrder norder = null;
        IList<IOrder> cashorderlist = null;
        IList<IOrderDetail> detailNewlist = null;
        OrderFilter of = new OrderFilter();
        using (IDataSession session = Store.OpenSession(false))
        {
            norder = session.Orders.GetByID(orderid);
        }
        if (norder != null)
        {
            detailNewlist = norder.OrderDetail;
            if (norder.CashParent_orderid != 0)
            {
                of.Id = cashorderid;
                of.State = "unpay";
            }
            else
            {
                of.CashParent_orderid = orderid;
                of.State = "unpay";
            }
            using (IDataSession session = Store.OpenSession(false))
            {
                cashorderlist = session.Orders.GetList(of);
            }
            if (cashorderlist != null && cashorderlist.Count > 0)
            {
                dispaly = "style='display:block;'";
                orderNewId = cashorderlist[0].Id.ToString();
            }
            else
            {
                dispaly = " style='display:none;'";
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
    //修改收货人信息
    public void AddReceive()
    {
        decimal fare = Helper.GetDecimal(CookieUtils.GetCookieValue("fare"), 0);
        int fare_shoping = Helper.GetInt(CookieUtils.GetCookieValue("fare_shoping"), 0);
        decimal jian = Helper.GetDecimal(CookieUtils.GetCookieValue("jian"), 0);
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

        ordermodel.discount = Helper.GetInt(ActionHelper.GetUserLevelMoney(AsUser.totalamount), 0);
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
                    if (_system["orderemailvalid"] == "1")
                    {
                        string email = Helper.GetString(Request["con_email"], "");
                        if (email.Length > 0 && Helper.ValidateString(email, "email"))
                        {
                            usermodel.Email = email;
                        }
                    }
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        session.Users.Update(usermodel);
                    }
                }
            }
        }
    }
    public virtual void CPS(IOrder ordermodel)
    {

    }
    //跳转到支付页面
    public void ConfirmOrder(IOrder ordermodel)
    {
        CookieCar.ClearCar();
        if (ordermodel != null)
        {
            orderid = ordermodel.Id.ToString();

            IList<IOrderDetail> orderdetailmodellist = null;
            if (ordermodel.OrderDetail != null && ordermodel.OrderDetail.Count > 0)
            {
                orderdetailmodellist = ordermodel.OrderDetail;
            }
            //先判断是否存在cps这个cookie,然后判断cookie中name的名称。之后在执行不同cps推送订单的过程
            try
            {
                HttpCookie cps = Request.Cookies["cps"];
                if (cps != null)//说明是从cps过来的,接下来判断name名称
                {
                    string namevalue = cps.Values["name"];
                    if (namevalue != null) //判断一下为了防止cookie发生异常
                    {
                        ICps cpsmodel = Store.CreateCps();
                        if (namevalue == "51fanli")//从51fanli来的
                        {
                            int u_id = Helper.GetInt(cps.Values["u_id"], 0); //51返利传过来的用户Id
                            string username = Helper.GetString(cps.Values["username"], String.Empty);
                            string m_id = cps.Values["51fanliid"]; //51返利的key 从配置文件中获得，是51返利分配给网站的
                            string m_k = cps.Values["51fanlisecret"];    //51返利的密钥 从配置文件中获得，是51返利分配给网站的

                            string strPassCode = getPassCode(ordermodel.Id.ToString(), cps.Values["51fanlishopno"].ToString(), cps.Values["u_id"].ToString(), cps.Values["51fanlisecret"].ToString());
                            System.Text.StringBuilder sb = new System.Text.StringBuilder();

                            sb.Append("<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n");
                            sb.Append("<fanli_data version=\"3.0\" >\r\n");
                            sb.Append("<order order_time=\"" + ordermodel.Create_time + "\" order_no=\"" + ordermodel.Id + "\" shop_no=\"" + cps.Values["51fanlishopno"] + "\" total_price=\"" + ordermodel.Origin + "\" total_qty=\"" + ordermodel.Quantity + "\"");
                            sb.Append(" shop_key=\"" + m_k + "\" u_id=\"" + cps.Values["u_id"] + "\" username=\"" + cps.Values["username"] + "\" is_pay=\"" + GetPay(ordermodel.State) + "\" pay_type=\"0\" order_status=\"" + getPayState(ordermodel.State) + "\"");
                            sb.Append(" deli_name=\"\"  deli_no =\"\" tracking_code=\"" + cps.Values["tracking_code"] + "\" pass_code=\"" + strPassCode + "\">\r\n");
                            sb.Append("<products_all>\r\n");

                            if (orderdetailmodellist != null)
                            {
                                for (int i = 0; i < orderdetailmodellist.Count; i++)
                                {
                                    sb.Append("<product>\r\n");
                                    sb.Append("<product_id>" + orderdetailmodellist[i].Teamid + "</product_id>\r\n");
                                    sb.Append("<product_url>" + getTeamPageUrl(Helper.GetInt(orderdetailmodellist[i].Teamid.ToString(), 0)) + " </product_url>\r\n");
                                    sb.Append("<product_qty> " + orderdetailmodellist[i].Num + " </product_qty>\r\n");
                                    sb.Append("<product_price > " + orderdetailmodellist[i].Teamprice + " </product_price>\r\n");
                                    sb.Append("<product_comm> 0</product_comm>\r\n");
                                    sb.Append("<comm_no></comm_no>\r\n");
                                    sb.Append("</product>\r\n");
                                }
                            }
                            else
                            {
                                sb.Append("<product>\r\n");
                                sb.Append("<product_id>" + ordermodel.Team_id + "</product_id>\r\n");
                                sb.Append("<product_url>" + getTeamPageUrl(Helper.GetInt(ordermodel.Team_id.ToString(), 0)) + " </product_url>\r\n");
                                sb.Append("<product_qty> " + ordermodel.Quantity + " </product_qty>\r\n");
                                sb.Append("<product_price > " + ordermodel.Price + " </product_price>\r\n");
                                sb.Append("<product_comm> 0</product_comm>\r\n");
                                sb.Append("<comm_no></comm_no>\r\n");
                                sb.Append("</product>\r\n");
                            }
                            sb.Append("</products_all>\r\n");
                            sb.Append("<coupons_all>\r\n");
                            sb.Append("<coupon>\r\n");  // 如果订单中有多个商品，那么<coupons_all>节点下面就有多个<coupon>节点
                            sb.Append("<coupon_no></coupon_no>\r\n");
                            sb.Append("<coupon_qty></coupon_qty>\r\n");
                            sb.Append("<coupon_price>-" + ordermodel.Card + "</coupon_price>\r\n");
                            sb.Append("<comm_no></comm_no>\r\n");
                            sb.Append("</coupon>\r\n");
                            sb.Append("</coupons_all>\r\n");
                            sb.Append("</order>");
                            sb.Append("</fanli_data>");
                            string url = "http://data2.51fanli.com/index.php/DataHandle/handlePostData";

                            string result = String.Empty;
                            bool notify = false;
                            try
                            {
                                System.Net.WebClient netclient = new System.Net.WebClient();
                                result = netclient.UploadString(url, "POST", sb.ToString());
                                netclient.Dispose();
                                notify = true;
                            }
                            catch (Exception ex) { result = result + ex.Message; }
                            cpsmodel.channelId = namevalue;
                            cpsmodel.u_id = u_id;
                            cpsmodel.order_id = Helper.GetInt(orderid, 0);
                            cpsmodel.value1 = u_id.ToString();
                            cpsmodel.username = username;
                            if (!notify)
                            {
                                cpsmodel.result = Helper.GetString(url, String.Empty) + "通知失败:" + Helper.GetString(result, String.Empty);
                            }
                            else
                            {
                                cpsmodel.result = Helper.GetString(url, String.Empty) + "通知成功:" + Helper.GetString(result, String.Empty);
                            }
                            using (IDataSession session = Store.OpenSession(false))
                            {
                                session.Cps.Insert(cpsmodel);
                            }
                        }
                        else if (namevalue == "linktech") //从linktech来的
                        {
                            try
                            {
                                string ltinfo = cps.Values["LTINFO"];
                                if (System.Configuration.ConfigurationManager.AppSettings["linktech_m_id"] != null && ltinfo != null)
                                {
                                    string linktechm_id = System.Configuration.ConfigurationManager.AppSettings["linktech_m_id"];
                                    string c_cd = String.Empty;
                                    string p_cd = String.Empty;
                                    string It_cnt = String.Empty;
                                    string price = String.Empty;

                                    for (int i = 0; i < orderdetailmodellist.Count; i++)
                                    {
                                        c_cd = c_cd + "||COM";
                                        p_cd = p_cd + "||" + orderdetailmodellist[i].Teamid;
                                        It_cnt = It_cnt + "||" + orderdetailmodellist[i].Num;
                                        price = price + "||" + orderdetailmodellist[i].Teamprice;
                                    }
                                    if (c_cd.Length > 0)
                                    {
                                        c_cd = c_cd.Substring(2);
                                        p_cd = p_cd.Substring(2);
                                        It_cnt = It_cnt.Substring(2);
                                        price = price.Substring(2);
                                    }
                                    string url = "http://service.linktech.cn/purchase_cps.php?a_id=" + ltinfo + "&m_id=" + linktechm_id + "&mbr_id=" + 0 + "&o_cd=" + orderid + "&p_cd=" + p_cd + "&price=" + price + "&it_cnt=" + It_cnt + "&c_cd=" + c_cd;
                                    string result = String.Empty;
                                    bool notify = false;
                                    try
                                    {
                                        System.Net.WebClient netclient = new System.Net.WebClient();
                                        result = netclient.DownloadString(url);
                                        netclient.Dispose();
                                        notify = true;
                                    }
                                    catch (Exception ex) { result = result + ex.Message; notify = false; }
                                    if (notify)
                                    {
                                        result = url + "通知成功" + result;
                                    }
                                    else
                                        result = url + "通知失败" + result;
                                    cpsmodel.channelId = namevalue;
                                    cpsmodel.u_id = 0;
                                    cpsmodel.order_id = Helper.GetInt(orderid, 0);
                                    cpsmodel.result = result;
                                    cpsmodel.value1 = ltinfo.ToString();
                                    using (IDataSession session = Store.OpenSession(false))
                                    {
                                        session.Cps.Insert(cpsmodel);
                                    }
                                }
                            }
                            catch (Exception ex) { WebUtils.LogWrite("linktechcps", ex.Message); }
                        }
                        else if (namevalue == "tuanmatuanba") //从团妈团爸来的
                        {
                            try
                            {
                                if (cps.Values["sitekey"] != null)
                                {
                                    string key = cps.Values["sitekey"];
                                    string result = String.Empty;
                                    string url = "http://api.tmtb.cn/tmtbquan/user_order.php?o_key=" + Server.HtmlEncode(cps.Values["o_key_tmtb"]) + "&uid=" + Server.HtmlEncode(cps.Values["uid_tmtb"]) + "&sid=" + Server.HtmlEncode(cps.Values["sid_tmtb"]) + "&time=" + ordermodel.Create_time + "&o_cd=" + ordermodel.Id + "&total_price=" + (ordermodel.Origin - ordermodel.Fare) + "&key=" + System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(key + ordermodel.Create_time + Server.HtmlEncode(cps.Values["uid_tmtb"]) + Server.HtmlEncode(cps.Values["sid_tmtb"]) + ordermodel.Id + (ordermodel.Origin - ordermodel.Fare), "md5").ToLower() + "&suid=" + ordermodel.User_id;
                                    System.Net.WebClient wc = new System.Net.WebClient();
                                    result = wc.DownloadString(url);

                                    decimal price = Helper.GetDecimal(result, 0);
                                    cpsmodel.channelId = "tuanmatuanba";
                                    cpsmodel.u_id = Helper.GetInt(cps.Values["uid_tmtb"], 0);
                                    cpsmodel.order_id = Helper.GetInt(orderid, 0);
                                    cpsmodel.result = url;
                                    cpsmodel.value1 = result.ToString();
                                    cpsmodel.username = Helper.GetString(cps.Values["o_key_tmtb"], String.Empty);
                                    using (IDataSession session = Store.OpenSession(false))
                                    {
                                        session.Cps.Insert(cpsmodel);
                                    }
                                }
                            }
                            catch (Exception ex) { WebUtils.LogWrite("tuanmatuanbacps", ex.Message); }
                        }
                        else if (namevalue == "yotao") //从yotao来的
                        {
                            try
                            {
                                string url = "http://www.yotao.com/orderback/?sid=" + cps.Values["sid"] + "&uid=" + cps.Values["uid"] + "&aid=" + cps.Values["aid"] + "&yid=" + cps.Values["yid"] + "&oid=" + ordermodel.Id + "&amount=" + (ordermodel.Origin - ordermodel.Fare) + "&cback=&mcode=" + Helper.MD5(cps.Values["key"] + cps.Values["uid"] + ordermodel.Id);
                                string result = url;
                                Response.Write("<" + "script src='" + url + "'></" + "script>");
                                cpsmodel.channelId = namevalue;
                                cpsmodel.u_id = 0;
                                cpsmodel.order_id = Helper.GetInt(orderid, 0);
                                cpsmodel.result = result;
                                cpsmodel.value1 = "sid=" + PageValue.CurrentSystemConfig["yotaokey"] + "&uid=" + cps.Values["uid"] + "&aid=" + cps.Values["aid"] + "&yid=" + cps.Values["yid"];
                                using (IDataSession session = Store.OpenSession(false))
                                {
                                    session.Cps.Insert(cpsmodel);
                                }
                            }
                            catch (Exception ex) { WebUtils.LogWrite("yotaocps", ex.Message); }
                        }
                        else if (namevalue == "tpycps") //来自太平洋cps
                        {
                            try
                            {
                                string userid = Server.UrlDecode(cps.Values["userid"]); //需要解码
                                if (userid != null && userid.Length > 0)
                                {
                                    string id = System.Configuration.ConfigurationManager.AppSettings["taipingyangid"];
                                    string key = System.Configuration.ConfigurationManager.AppSettings["taipingyangkey"];
                                    string url = "http://news.tpy100.com/UnionCompany/unioncompanyinterface.aspx?userid=" + Server.UrlEncode(userid) + "&codeid=" + id + "&order_date=" + ordermodel.Create_time.ToString("yyyyMMdd") + "&order_time=" + ordermodel.Create_time.ToString("HHmmss") + "&orderid=" + ordermodel.Id + "&price=" + (ordermodel.Origin - ordermodel.Fare) + "&zhuangtai=c&key=" + Helper.MD5(userid + id + ordermodel.Id + (ordermodel.Origin - ordermodel.Fare) + "c" + key);
                                    Response.Write("<" + "script src='" + url + "'></" + "script>");
                                    string result = String.Empty;
                                    cpsmodel.channelId = "taipingyangcps";
                                    cpsmodel.u_id = 0;
                                    cpsmodel.order_id = Helper.GetInt(orderid, 0);
                                    cpsmodel.result = result;
                                    using (IDataSession session = Store.OpenSession(false))
                                    {
                                        session.Cps.Insert(cpsmodel);
                                    }
                                }
                            }
                            catch (Exception ex) { WebUtils.LogWrite("tpycps", ex.Message); }
                        }
                        else if (namevalue == "youhua")//来自优哈联盟
                        {
                            try
                            {
                                string value1 = cps.Values["hashid"];//优哈Id
                                if (!String.IsNullOrEmpty(value1))
                                {
                                    cpsmodel.channelId = "youha";
                                    cpsmodel.order_id = Helper.GetInt(orderid, 0);
                                    cpsmodel.value1 = value1;
                                    using (IDataSession session = Store.OpenSession(false))
                                    {
                                        session.Cps.Insert(cpsmodel);
                                    }
                                }
                            }
                            catch { }
                        }
                        else if (namevalue == "renrenzhe") //人人折
                        {
                            int u_id = Helper.GetInt(cps.Values["u_id"], 0); //人人折返利传过来的用户Id
                            string uname = Helper.GetString(cps.Values["uname"], String.Empty);
                            StringBuilder sb = new StringBuilder();
                            //团购网站识别码
                            string k = cps.Values["sk"];
                            long o_time = Helper.GetTimeFix(ordermodel.Create_time);
                            string o_cd = String.Empty;     //定单号
                            string p_title = String.Empty;  //商品名称
                            string p_url = String.Empty;    //商品url
                            string p_cd = String.Empty;     //商品编号
                            string price = String.Empty;    //商品单价
                            string it_cnt = String.Empty;   //商品数量
                            string c_cd = String.Empty;     //分类编号
                            if (orderdetailmodellist != null)
                            {
                                for (int i = 0; i < orderdetailmodellist.Count; i++)
                                {
                                    IOrderDetail orderdetailmodel = orderdetailmodellist[i];
                                    ITeam tempteammodel = null;
                                    string catalogname = "无";
                                    if (orderdetailmodel.Team != null)
                                    {
                                        tempteammodel = orderdetailmodel.Team;
                                        p_title = p_title + Server.UrlEncode(tempteammodel.Title) + "|_|";
                                        if (orderdetailmodel.Team.TeamCatalogs != null)
                                        {
                                            catalogname = orderdetailmodel.Team.TeamCatalogs.catalogname;
                                        }
                                    }
                                    o_cd = orderdetailmodel.Order_id.ToString();
                                    p_url = p_url + Server.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + getTeamPageUrl(int.Parse(orderdetailmodellist[i].Teamid.ToString()))) + "|_|";
                                    p_cd = p_cd + orderdetailmodel.Teamid + "|_|";
                                    price = price + orderdetailmodel.Teamprice + "|_|";
                                    it_cnt = it_cnt + orderdetailmodel.Num + "|_|";
                                    c_cd = c_cd + Server.UrlEncode(catalogname) + "|_|";
                                }
                            }

                            string title = p_title.Replace("!", "%21").ToUpper().Replace("(", "%28").ToUpper().Replace(")", "%29").ToUpper().Replace("（", "%28").ToUpper().Replace("）", "%29").ToUpper();
                            string u = "it_cnt=" + it_cnt + "&k=" + k + "&o_cd=" + o_cd + "&o_time=" + o_time + "&p_cd=" + p_cd + "&p_title=" + title + "&p_url=" + p_url.ToUpper() + "&price=" + price + "&u_id=" + u_id + "";
                            string Md5code = u + cps.Values["ss"];
                            string code = Helper.MD5(Md5code);
                            string url = "http://union.renrenzhe.com/union/submitOrder.jspx";
                            sb.Append(u + "&code=" + code + "");
                            Encoding encoding = Encoding.GetEncoding("GB2312");
                            byte[] data = encoding.GetBytes(sb.ToString());

                            // Prepare web request
                            System.Net.HttpWebRequest myRequest =
                            (System.Net.HttpWebRequest)System.Net.WebRequest.Create(url);
                            myRequest.Method = "POST";
                            myRequest.ContentType = "application/x-www-form-urlencoded";
                            myRequest.ContentLength = data.Length;
                            System.IO.Stream newStream = myRequest.GetRequestStream();

                            // Send the data.
                            newStream.Write(data, 0, data.Length);
                            newStream.Close();

                            // Get response
                            System.Net.HttpWebResponse myResponse = (System.Net.HttpWebResponse)myRequest.GetResponse();
                            System.IO.Stream receiveStream = myResponse.GetResponseStream();
                            Encoding encode = System.Text.Encoding.GetEncoding("GB2312");

                            System.IO.StreamReader reader = new System.IO.StreamReader(receiveStream, encode);
                            string content = reader.ReadToEnd();
                            myResponse.Close();
                            reader.Close();
                            cpsmodel.channelId = namevalue;
                            cpsmodel.u_id = u_id;
                            cpsmodel.order_id = Helper.GetInt(orderid, 0);
                            cpsmodel.result = Helper.GetString(url, String.Empty) + "通知成功:" + Helper.GetString(content, String.Empty);
                            cpsmodel.username = uname;
                            using (IDataSession session = Store.OpenSession(false))
                            {
                                session.Cps.Insert(cpsmodel);
                            }
                        }
                    }
                }
            }
            catch (Exception ex) { WebUtils.LogWrite("cps推送订单错误", ex.Message); }
        }
        try
        {
            CPS(ordermodel);
        }
        catch { }

        Response.Write("<script>window.location.href='" + Page.ResolveUrl(GetUrl("京东选择银行", "shop_jdservice.aspx?orderid=" + ordermodel.Id)) + "';</" + "script>");
        Response.End();
    }
    private string getPassCode(string order_no, string shop_no, string u_id, string shop_key)
    {
        //步骤1：strPassCode = order_no + shop_no + u_id + shop_key (备注：将四个字段累加成一个字符串)；
        string strPassCode = order_no + shop_no + u_id + shop_key;

        //步骤2：strPassCode = toLower(strPassCode) (备注：将字符串转换成小写)；
        strPassCode = strPassCode.ToLower();

        //步骤3：strPassCode = MD5(strPassCode) (备注：将字符串进行MD5加密)。
        strPassCode = Helper.MD5(strPassCode);
        return strPassCode;

    }
    private string getPayState(string state)
    {
        switch (state)
        {
            case "pay":
                return "1";
            case "cancel":
                return "-1";
            case "refund":
                return "7";
        }
        return "0";
    }
    private int GetPay(string state)
    {
        switch (state)
        {
            case "pay":
                return 1;
            case "unpay":
                return 0;
        }
        return 0;
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
        StringBuilder sb1 = new StringBuilder();
        jian = 0;
        fare = 0;
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
                sb1.Append("<tr><td>" + promotion_rules.rule_description + "</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>");
                Literal1.Text = sb1.ToString();
            }
            if (Literal1.Text != null || Literal1.Text != "")
            {
                youhui = true;
            }
        }
    }
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head">
    <meta name="keywords" content="<%=PageValue.KeyWord %>"/>
    <meta name="description" content="<%=PageValue.Description %>" />
    <title>我的购物车 - <%=PageValue.CurrentSystemConfig["malltitle"]%></title>
    <script type='text/javascript' src="<%=PageValue.WebRoot %>upfile/js/index.js"></script>
    <link href="<%=PageValue.WebRoot %>upfile/css/orderInfo.css" rel="stylesheet" type="text/css" />
</head>
<body class="newbie">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <form id="form1" runat="server">
        <div class="Wrap_cart">
            <div class="w" id="headers">
                <div id="logo">
                    <a href="<%=GetUrl("商城首页","mall_index.aspx")%>">
                        <b></b>
                        <img src="<%=headlogo %>" width="259" height="50" alt="<%= PageValue.CurrentSystemConfig["mallsitename"]%>"></a>
                </div>
                <div id="step2" class="step" style="margin-right: 60px;">
                    <ul>
                        <li class="fore1"><a href="<%=GetUrl("京东购物车列表","mall_jdcart.aspx")%>" style="color: #000">1.我的购物车</a><b></b></li>
                        <li class="fore2">2.填写核对订单信息<b></b></li>
                        <li class="fore3">3.成功提交订单</li>
                    </ul>
                </div>
                <div class="clr"></div>
            </div>
            <div class="List_cart marginb10" id="show" name="show">
                <asp:HiddenField ID="hiorderid" runat="server" />
                <script type="text/javascript">
                    function changecity(pid) { 
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
                            else
                                sels.eq(i).remove();
  
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
                                var u ="<%=PageValue.WebRoot %>ajax/citylist.aspx?pid=" + oid;
                                $.ajax({
                                    type: "POST",
                                    url: "<%=PageValue.WebRoot %>ajax/citylist.aspx",
                                    data: {"pid":oid },
                                    success: function (msg) {
                                        // X.boxClose();
                                        if (msg != "") {
                                            $("#citylist").append(msg);
                                            $("#expressarea").html("");
                                        }
                                        else
                                        {
                                   <%if (payselectexpress)
                                     { %>

                                   //X.boxShow('正在加载快递公司信息,请稍后...', false);
                                   $.ajax({
                                       type: "POST",
                                       url: "<%=PageValue.WebRoot %>ajax/express.aspx",
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
                        var orderid=$("#hiorderid").val();
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
                            url: "<%=PageValue.WebRoot %>ajax/getfare.aspx",
                            data: {"city":citynames,"expressid":expressid,"id":orderid},
                            success: function (msg) {
                                var teamprice=$("span[total='teamprice']");
                                //alert(teamprice);
                                var totalprice=0;
                                for(var i=0;i<teamprice.length;i++)
                                {
                                    totalprice=totalprice+parseFloat(teamprice.eq(i).html());
                                    //alert(totalprice);
                                }
                                var fareprice=parseFloat(msg);
                                         

                                totalprice=(totalprice*<%=ActionHelper.GetUserLevelMoney(AsUser.totalamount)%>)
                                //alert(<%=fare_shoping%>);
                                if(<%=fare_shoping%>==1)
                                {
                                    fareprice=0;
                                }
                                totalprice=totalprice+fareprice-<%=jian%>;
                                // alert(totalprice);
                                if($("span[total='disamount']")&&$("span[total='disamount']").length>0)
                                {
                                    if(!isNaN($("span[total='disamount']").eq(0).html()))
                                        totalprice=totalprice+parseFloat($("span[total='disamount']").eq(0).html());
                                }
                                           
                                $("span[total='fareprice']").html(fareprice);
                                $("span[total='totalprice']").html(totalprice.toFixed(2));
                            }
                        });
                    }
                </script>
                <h2>
                    <strong>填写核对订单信息</strong></h2>
                <div class="cart_table">
                    <!--收货人地址开始-->
                    <div id="part_consignee">
                        <div class="o_show">
                            <h1>收货人信息&nbsp; 
                            </h1>
                            <div class="middle">
                                <%if (ordermodel != null)
                                  { %>
                                <table>
                                    <tbody>
                                        <tr>
                                            <td style="width: 80px;" align="right">收货人姓名：
                                            </td>
                                            <td>
                                                <%if (CookieUtils.GetCookieValue("fullname") != null && CookieUtils.GetCookieValue("fullname") != "")
                                                  { %>
                                                <input type="text" size="30" name="realname" id="Text1" class="f-input" value="<%=CookieUtils.GetCookieValue("fullname") %>"
                                                    require="true" datatype="require" group="a" />
                                                <%}
                                                  else
                                                  { %>
                                                <input type="text" size="30" name="realname" id="settingsrealname" class="f-input"
                                                    value="<%=user.Realname%>" require="true" datatype="require" group="a" />
                                                <%} %>
                                                <span class="hint">收件人请与有效证件姓名保持一致，便于收取物品</span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right">省 份：
                                            </td>
                                            <td>
                                                <div id="citylist" class="cityclass">
                                                </div>
                                                <span id="area" class=""></span>

                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right">地 址：
                                            </td>
                                            <td>
                                                <%if (CookieUtils.GetCookieValue("address") != null && CookieUtils.GetCookieValue("address") != "")
                                                  { %>
                                                <input type="text" size="30" name="address" id="Text3" class="f-input" value="<%=CookieUtils.GetCookieValue("address") %>"
                                                    group="a" require="true" datatype="require" />
                                                <%}
                                                  else
                                                  { %>
                                                <input type="text" size="30" name="address" id="settingsaddress" class="f-input"
                                                    value="<%=user.Address %>" group="a" require="true" datatype="require" />
                                                <%} %>
                                                <span class="hint">街道具体地址</span>
                                                <script>
                                                    $("#citylist").load("<%=PageValue.WebRoot %>ajax/citylist.aspx?pid=0", null, function (data) {

                                                    });
                                                </script>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right"></td>
                                            <td>
                                                <div id="expressarea" class="field mobile">
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td align="right">手机号码：
                                            </td>
                                            <td>
                                                <%if (CookieUtils.GetCookieValue("mobile_phone") != null && CookieUtils.GetCookieValue("mobile_phone") != "")
                                                  {%>
                                                <input type="text" size="30" name="mobile" id="settingsmobile" class="number" value="<%=CookieUtils.GetCookieValue("mobile_phone") %>"
                                                    group="a" require="true" datatype="mobile" maxlength="11" />
                                                <% }
                                                  else
                                                  { %>
                                                <input type="text" size="30" name="mobile" id="Text2" class="number" value="<%=user.Mobile %>"
                                                    group="a" require="true" datatype="mobile" maxlength="11" />
                                                <%} %>
                                                <span class="hint">手机号码是我们联系您最重要的方式，请准确填写</span>
                                            </td>
                                        </tr>
                                        <%if (_system["orderemailvalid"] == "1")
                                          {%>
                                        <tr>
                                            <td align="right">电子邮件：
                                            </td>
                                            <td>
                                                <input type="text" size="30" name="con_email" id="settingemail" class="f-input" value="<%=user.Email %>"
                                                    group="a" require="true" datatype="email|ajax" vname="editemail" url="<%=WebRoot%>ajax/user.aspx"
                                                    msg="邮箱格式不正确|" msgid="emailerr" />
                                            </td>
                                        </tr>
                                        <% }%>
                                        <tr>
                                            <td align="right">邮 编：
                                            </td>
                                            <td>
                                                <%if (CookieUtils.GetCookieValue("post") != null && CookieUtils.GetCookieValue("post") != "")
                                                  {%>
                                                <input type="text" size="30" name="zipcode" id="Text4" class="number" value="<%=CookieUtils.GetCookieValue("post") %>"
                                                    group="a" require="true" datatype="zip" maxlength="6" />
                                                <%}
                                                  else
                                                  { %>
                                                <input type="text" size="30" name="zipcode" id="settingszipcode" class="number" value="<%=user.Zipcode %>"
                                                    group="a" require="true" datatype="zip" maxlength="6" />
                                                <%} %>
                                            </td>
                                        </tr>
                                        <tr class="field mobile">
                                            <td align="right">订单附言：
                                            </td>
                                            <td>
                                                <textarea name="remark" style="width: 300px;" id="txtremark" rows="6" size="100"
                                                    cols="6" runat="server" class="f-input"></textarea>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                                <% }%>
                            </div>
                        </div>
                    </div>
                    <!--收货人地址结束-->
                    <!--Cart信息开始-->
                    <div id="part_cart">
                        <div class="o_show">
                            <h1>
                                <span style="margin-right: 700px;">商品清单</span>
                                  <% if (ordermodel.Teams!=null&&ordermodel.Teams.Count>0&&!Utilys.GetTeamType(ordermodel.Teams[0].Id))
                                   { %>
                                <a style="color: #0070D7" href="<%=GetUrl("京东购物车列表","mall_jdcart.aspx")%>">返回修改购物车</a>
                                <%} %>
                            </h1>
                            <div id="promiseDate" style="color: #FF9900">
                            </div>
                            <div class="middle">
                                <table class="Table" cellpadding="0" cellspacing="0" width="100%">
                                    <tbody>
                                        <tr class="align_Center Thead">
                                            <td width="55%">商品名称
                                            </td>
                                            <td width="7%">数量
                                            </td>
                                            <td width="10%">价格
                                            </td>
                                            <td width="10%"></td>
                                            <td width="8%">总价
                                            </td>
                                            <td width="10%">代金券
                                            </td>
                                        </tr>
                                        <!-- **************************单品和赠品显示 ***************************** -->
                                        <!-- 买多赠多——主商品 -->
                                        <% detaillist = ordermodel.OrderDetail;
                                            //string rulemoney = "0"; %>
                                        <%int jj = 0;
                                          foreach (var model in detaillist)
                                          {
                                              jj++;
                                              ITeam team = null;
                                              team = model.Team;
                                              if (team != null)
                                              {
                                                  if (jj % 2 != 0)
                                                  {%>
                                        <tr class="align_Center">
                                            <%}
                                                  else
                                                  {%>
                                            <tr class="align_Center suitPromItem">
                                                <% }
                                                %>
                                                <td class="align_Left">
                                                    <%= team.Title%>
                                                    <%if (team.bulletin != "" && team.bulletin != null && team.bulletin != "{}")
                                                      {%>
                                                    <font style="color: red"><%=WebUtils.Getbulletin(model.result)%></font>
                                                    <%} %>
                                               
                                                </td>
                                                <td style="padding: 5px 0 5px 0;">
                                                    <%=model.Num%>
                                                </td>
                                                <td>
                                                    <span class="price"><span class="money"><span>
                                                        <%=ASSystem.currency%><%=model.Teamprice%></span>
                                                </td>
                                                <td>=
                                                </td>
                                                <td>
                                                    <%=ASSystem.currency %><span total="teamprice"><%=Convert.ToDecimal(model.Num * model.Teamprice - model.Credit)%></span>
                                                </td>
                                                <%if (GetTeamid(Convert.ToInt32(model.Teamid), Convert.ToInt32(model.Order_id)) == null)
                                                  {
                                                      if (team.Card > 0)
                                                      {
                                                %>
                                                <td style="width: 80px; text-align: right;">
                                                    <a href="<%=WebRoot%>ajax/coupon.aspx?action=card&detailid=<%=model.id %>&orderid=<%=ordermodel.Id %>&ty=jd"
                                                        style="color: #EC6D20;" class="ajaxlink">代金券</a>
                                                </td>
                                                <% }
                                                      else
                                                      {%>
                                                <td style="width: 80px; text-align: right;">不能使用
                                                </td>
                                                <% }
                                                  }
                                                  else
                                                  {%>
                                                <td style="width: 80px; text-align: right;">已经使用代金券<%=model.carno%>
                                                </td>
                                                <% }%>
                                            </tr>
                                            <% }
                                          }%>
                                        </tr>
                                        <!-- 显示延保服务 -->
                                        <!-- 找到主商品 -->
                                        <tr class="align_Center Thead">
                                            <td class="deal-buy-desc">快递
                                            </td>
                                            <td class="deal-buy-quantity"></td>
                                            <td class="deal-buy-price" style="width: 80px;">
                                                <%=ASSystem.currency%><span id="deal-express-price" total="fareprice">
                                                    <%=fare%>
                                                </span>
                                            </td>
                                            <td class="deal-buy-multi"></td>

                                            <td></td>
                                            <td class="deal-buy-total">
                                                <span class="money"></span><span id="deal-express-total"></span>
                                            </td>
                                            <td></td>
                                        </tr>
                                        <%if (ordermodel.disamount > 0)
                                          { %>
                                        <tr class="align_Center Thead">
                                            <td class="deal-buy-desc">
                                                <%=ordermodel.Disinfos %>
                                            </td>
                                            <td class="deal-buy-quantity"></td>
                                            <td class="deal-buy-multi"></td>
                                            <td class="deal-buy-price">
                                                <%=ASSystem.currency%><span id="Span1" total="disamount"> -<%=(ordermodel.disamount) %>
                                                </span>
                                            </td>
                                            <td></td>
                                            <td class="deal-buy-total">
                                                <span class="money"></span><span id="Span2"></span>
                                            </td>
                                            <td></td>
                                        </tr>
                                        <%} %>
                                        <%if (ordermodel.State != "scoreunpay")
                                          { %>
                                        <%if (ActionHelper.GetUserLevelMoney(AsUser.totalamount) != 1)
                                          { %>
                                        <tr class="align_Center Thead">
                                            <td></td>
                                            <td colspan="3" style="color: red">等级：<%=Utilys.GetUserLevel(AsUser.totalamount)%>,折扣：
                                                <% if (ActionHelper.GetUserLevelMoney(AsUser.totalamount) < 1)
                                                   {%>
                                                <%=ActionHelper.GetUserLevelMoney(AsUser.totalamount)*10 + "折"%>
                                                <% }
                                                   else
                                                   {%>
                                                不打折
                                                <% }%>
                                            </td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                        </tr>
                                        <% }
                                          }%>
                                        <tr class="align_Center Thead">
                                            <td class="align_Center Thead">
                                                <strong>应付总额：</strong>
                                            </td>
                                            <td class="deal-buy-quantity"></td>
                                            <td class="deal-buy-multi"></td>
                                            <td class="deal-buy-price">=
                                            </td>
                                            <td class="deal-buy-total">
                                                <%=ASSystem.currency%><span total="totalprice"><%=totalprice%></span>
                                            </td>
                                            <td class="deal-buy-price"></td>
                                            <td></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <!--Cart信息结束-->
                    <!--有货先发开始-->
                    <div id="part_FirstInstockShip" style="padding: 8px 0px 8px 30px; color: red;">
                        <%if (youhui == true)
                          { %>
                        <tr id="Tr1" class="order-total" runat="server">
                            <td class="deal-buy-desc">
                                <strong>享受的优惠:</strong>
                            </td>
                            <td colspan="3" style="color: red">
                                <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                            </td>
                        </tr>
                        <%} %>
                    </div>
                    <!--有货先发结束-->
                    <!-- 支付密码 -->
                    <!-- end支付密码 -->
                    <!--提交-->
                    <div class="o_show submit">
                        <div>
                            <span id="submitWaitInfo"></span>
                        </div>
                        <div id="show_error">
                        </div>
                        <div id="submit_btn">
                            <span id="ccPanel" name="ccPanel"></span>
                            <table cellpadding="0" cellspacing="0" width="100%">
                                <tbody>
                                    <tr>
                                        <td style="padding: 0; text-align: left; vertical-align: top;">
                                            <div style="width: 600px;" id="part_remark">
                                                <div id="show_remark" style="display: none;">
                                                </div>
                                            </div>
                                        </td>
                                        <td style="width: 100px; padding: 0;">
                                            <input type="hidden" id="Consignee_Hidden_Type" value="0">
                                            <input type="hidden" id="PayType_Hidden_Type" value="0">
                                            <input type="hidden" id="PartInvoice_Hidden_Type" value="0">
                                            <input style="margin-top: 2px; border: none; cursor: pointer; width: 160px; height: 53px; background: url(<%=PageValue.WebRoot %>upfile/css/i/submit.jpg)"
                                                type="submit" value="" class="formbutton validator" id="" name="btnadd" group="a" />
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </div>
                <div class="round">
                    <div class="lround">
                    </div>
                    <div class="rround">
                    </div>
                    <!--提交结束-->
                </div>
            </div>
            <div class="Footer_Link">
                <div class="copyright">
                    &copy;<span>2010</span>&nbsp;<%=sitename
                    %>（<%=WWWprefix %>）版权所有&nbsp;<a href="<%=GetUrl("用户协议","about_terms.aspx")%>">使用<%=abbreviation
                    %>前必读</a><br />
                    <a href="http://www.miibeian.gov.cn/" target="_blank"><%=icp %></a>&nbsp;&nbsp;<%=statcode
                    %> &nbsp;Powered by ASdht(<a target="_blank" href="http://www.asdht.com">艾尚团购系统程序</a>)
    Software V_<%=ASSystemArr["siteversion"] %>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
