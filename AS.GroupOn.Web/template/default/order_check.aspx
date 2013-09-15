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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public IList<IOrder> orderlist = null;
    public ITeam teammodel = null;
    public ITeam frontTeammodel = null;
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
    public int fare_shoping;
    public decimal jian;
    public decimal fan;
    public bool youhui = false;
    bool isSame = false;//判断用户的选择的规格是否有一样的
    public bool isinvent = false;//判断订单的数量是否已经超出了库存
    public IList<IOrderDetail> detaillist = null;
    public NameValueCollection _system = new NameValueCollection();
    protected bool isCreditseconds = false; //仅余额可秒杀
    protected bool orderemailvalidVisble = false;
    public string mobilemessage = ""; //验证手机信息
    public decimal summoney = 0;
    public decimal inputmoney = 0;
    public ISystem system = Store.CreateSystem();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NeedLogin();
        _system = PageValue.CurrentSystemConfig;
        system = PageValue.CurrentSystem;
        using (IDataSession session = Store.OpenSession(false))
        {
            ordermodel = session.Orders.GetByID(Helper.GetInt(Request["orderid"], 0));
        }

        frontTeammodel = ordermodel.Team;
        form.Action = GetUrl("优惠卷确认", "order_check.aspx?orderid=" + Helper.GetInt(Request["orderid"], 0));
        totalprice = OrderMethod.GetTeamTotalPrice(ordermodel.Id) + ordermodel.Fare;
        summoney = ordermodel.Quantity * ordermodel.Price;
        CookieUtils.SetCookie("summoney", summoney.ToString());
        GetCuXiao(summoney);
        if (jian != 0)
        {
            totalprice = OrderMethod.GetTeamTotalPrice(ordermodel.Id) - jian;
        }
        //OrderMethod.GetCuXiao(summoney, ordermodel);
        ordermodel.Origin = totalprice;
        ordermodel.discount = Helper.GetInt(ActionHelper.GetUserLevelMoney(AsUser.totalamount), 0);
        string username = ordermodel.Realname;
        user = ordermodel.User;
        if (user != null)
        {
            ordermodel.Realname = user.Realname;
            ordermodel.Mobile = user.Mobile;
            ordermodel.Address = user.Address;
            ordermodel.Zipcode = user.Zipcode;
            ordermodel.Origin = totalprice;
        }
        if (ordermodel == null || ordermodel.User_id != AsUser.Id)
        {
            SetError("不存在此订单");
            Response.Redirect(WebRoot + "index.aspx");
            Response.End();
            return;
        }
        if (ordermodel != null)
        {
            if (ordermodel.Team_id == 0 || ordermodel.Team_id.ToString() == "" || ordermodel.Team_id.ToString() == null)
            {
                Response.Redirect(GetUrl("购物车订单", "shopcart_confirmation.aspx?orderid=" + ordermodel.Id + ""));
            }
            //判断项目是否过期或者卖光
            using (IDataSession session = Store.OpenSession(false))
            {
                teammodel = session.Teams.GetByID(ordermodel.Team_id);
            }
            if (teammodel != null)
            {
                /*2011-04-27 修改仅余额可秒杀开始*/
                if (teammodel.Team_type == "seconds")
                {
                    if (ASSystem != null)
                    {
                        if (ASSystem.creditseconds == 1)//开启余额秒杀
                        {
                            isCreditseconds = true;
                        }
                    }
                }
                /*2011-04-27 修改仅余额可秒杀结束*/
                AS.Enum.TeamState ts = GetState(teammodel);
                if (ts != AS.Enum.TeamState.begin && ts != AS.Enum.TeamState.successbuy)
                {
                    SetError("该项目已过期或已卖光，不能支付！");
                    Response.Redirect(WebRoot + "index.aspx");
                    Response.End();
                    return;
                }
            }
        }
        else
        {
            SetError("订单不存在");
            Response.Redirect(WebRoot + "index.aspx");
            Response.End();
            return;
        }
        //通过手机号获取认证码
        if (Request["loginsubmit"] == "获取验证码")
        {
            if (DrawMethod.isUserMobile(Helper.GetString(Request["tv_mobile"], ""), Helper.GetInt(teammodel.Id, 0)))
            {
                mobilemessage = "此手机号已参加此抽奖活动";
            }
            else
            {
                GetUesrCode(ordermodel.Id);
                mobilemessage = "认证码已发送手机上，请注意查收";
            }
        }
        if (Request.Form["btnadd"] == "确认订单，付款")
        {
            NeedLogin();
            //用户无法修改其他用户的额单子
            if (OrderMethod.IsUserOrder(AsUser.Id, Helper.GetInt(Request["orderid"], 0)))
            {
                SetError("友情提示：无法操作其他用户的订单");
                Response.Redirect(WebRoot + "index.aspx");
                Response.End();
                return;
            }
            string strEmail = Helper.GetString(Request.Form["tv_email"], String.Empty);
            if (_system["orderemailvalid"] == "1")
            {
                if (!Helper.ValidateString(strEmail, "email"))
                {
                    SetError("电子邮件输入的格式不正确");
                    Response.Redirect(GetUrl("优惠卷确认", "order_check.aspx"));
                    Response.End();
                    return;
                }
            }
            teammodel = ordermodel.Team;
            if (teammodel != null)
            {
                if (teammodel.Delivery == "draw")
                {
                    if (teammodel.codeswitch == "yes")
                    {
                        if (!DrawMethod.ischeckcode(Helper.GetString(Request["tv_code"], ""), AsUser.Id))
                        {
                            SetError("此认证码已无效，请输入有效的认证码");
                            return;
                        }
                    }
                }

            }
            CookieCar.ClearCar();
            ConfirmOrder(ordermodel);
        }
    }
    //生成认证码给用户
    public void GetUesrCode(int orderid)
    {
        IOrder ordermodelcode = null;
        ITeam teammodelcode = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            ordermodelcode = session.Orders.GetByID(orderid);
        }
        if (ordermodelcode != null && ordermodelcode.Team != null)
        {
            teammodelcode = ordermodelcode.Team;
            ordermodelcode.checkcode = DrawMethod.GetCode(0);
            ordermodel.Mobile = Helper.GetString(Request["tv_mobile"], "");
            using (IDataSession session = Store.OpenSession(false))
            {
                session.Orders.Update(ordermodelcode);
            }
        }
        //抽奖验证码
        NameValueCollection values = new NameValueCollection();
        values.Add("网站简称", ASSystem.abbreviation);
        values.Add("用户名", UserName);
        values.Add("商品名称", teammodel.Product);
        values.Add("认证码", ordermodel.checkcode);
        string message = ReplaceStr("drawcode", values);
        setPhone(Helper.GetString(Request["tv_mobile"], ""), message);
    }
    private bool setPhone(string telNumber, string telContent)
    {
        List<string> lists = new List<string>();
        string[] s = telNumber.Split(',');
        for (int i = 0; i < s.Length; i++)
        {
            lists.Add(s[i]);
        }
        return OrderMethod.SendSMS(lists, telContent);
    }
    //如果用户当前余额可以付款，那么修改订单状态
    public void ConfirmOrder(IOrder ordermodel)
    {
        IUser usermodel = null;
        UserFilter uf = new UserFilter();
        IList<IUser> list = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            usermodel = session.Users.GetbyUName(UserName);
        }
        usermodel = user;
        if (_system["orderemailvalid"] == "1")
        {
            string email = Helper.GetString(Request["tv_email"], String.Empty);
            if (email.Length > 0 && Helper.ValidateString(email, "email"))
            {
                uf.LoginName = email;
                using (IDataSession session = Store.OpenSession(false))
                {
                    list = session.Users.GetList(uf);
                }
                IUser otheruser = null;
                if (list != null && list.Count > 0)
                    otheruser = list[0];
                if (otheruser != null && otheruser.Id != AsUser.Id)
                {
                    SetError("您填写的邮箱已被别人使用，请更换");
                    Response.Redirect(Request.Url.AbsoluteUri);
                    Response.End();
                    return;
                }
                usermodel.Email = email;
            }
            else
            {
                SetError("邮箱不能为空或者格式不正确");
                Response.Redirect(Request.Url.AbsoluteUri);
                Response.End();
                return;
            }

        }
        if (Helper.GetString(Request["mobile"], "") != "")
        {
            usermodel.Mobile = Helper.GetString(Request["mobile"], String.Empty);
        }

        if (Helper.GetString(Request["mobile"], "") != "")
        {
            ordermodel.Mobile = Helper.GetString(Request["mobile"], String.Empty);
        }
        else
        {
            ordermodel.Mobile = usermodel.Mobile;
        }
        using (IDataSession session = Store.OpenSession(false))
        {
            session.Users.Update(usermodel);
            session.Orders.Update(ordermodel);
        }

        if (ordermodel != null)
        {
            inputmoney = Helper.GetDecimal(Request["inputmoney"], 0);//用户输入金额
            if (Request["pd_FrpId"] != null && _system["isybbank"] == "1") //如果用户选择了某个银行那么，支付网关就是选中的银行
            {
                service = "yeepay";
            }
            else if (Request["paytype"] != null)
            {
                service = Request["paytype"].ToString();
            }
            else if (Request["cft_FrpId"] != null && _system["iscftbank"] == "1")
            {
                service = "tenpay";
            }
            else if (Request["paypal"] != null) //paypal支付
            {
                service = Request["paypal"].ToString();
            }
            else
            {
                service = "credit"; //用户没有选择支付网关，默认为支付宝
            }
            if (service != "credit")
            {
                if (inputmoney != 0)
                {
                    if (inputmoney > ordermodel.Origin || inputmoney > usermodel.Money)
                    {
                        if (inputmoney > ordermodel.Origin)
                        {
                            SetError("您输入的金额超出订单金额,请您重新输入");
                        }
                        if (inputmoney > usermodel.Money)
                        {
                            SetError("您输入的金额超出您的帐户余额,请您重新输入");
                        }
                        Response.Redirect(GetUrl("优惠卷确认", "order_check.aspx?orderid=" + Helper.GetInt(Request["orderid"], 0)));
                    }
                }
            }
            else
            {
                inputmoney = 0;
            }
            //修改订单的支付网关,同时生成交易单号
            OrderMethod.Updatebyservice(ordermodel.Id, service, OrderMethod.Getorder(ordermodel.User_id, ordermodel.Team_id, ordermodel.Id), ordermodel.Origin);
            GoToPayUrl(ordermodel);

        }
        else
        {
            SetError("订单不存在");
            Response.Redirect(WebRoot + "index.aspx");
            Response.End();
            return;
        }
    }
    public virtual void GoToPayUrl(IOrder ordermodel)
    {
        if (ordermodel != null)
        {
            orderid = ordermodel.Id.ToString();
            #region 写入cps
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
                        if (namevalue == "51fanli" && _system["open51fanli"] == "1")//从51fanli来的
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
                            sb.Append(" shop_key=\"" + m_k + "\" u_id=\"" + u_id + "\" username=\"" + username + "\" is_pay=\"" + GetPay(ordermodel.State) + "\" pay_type=\"0\" order_status=\"" + getPayState(ordermodel.State) + "\"");
                            sb.Append(" deli_name=\"\"  deli_no =\"\" tracking_code=\"" + cps.Values["tracking_code"] + "\" pass_code=\"" + strPassCode + "\">\r\n");
                            sb.Append("<products_all>\r\n");

                            sb.Append("<product>\r\n");
                            sb.Append("<product_id>" + ordermodel.Team_id + "</product_id>\r\n");
                            sb.Append("<product_url>" + WWWprefix + "team.aspx?id=" + ordermodel.Team_id + " </product_url>\r\n");
                            sb.Append("<product_qty> " + ordermodel.Quantity + " </product_qty>\r\n");
                            sb.Append("<product_price > " + ordermodel.Price + " </product_price>\r\n");
                            sb.Append("<product_comm> 0</product_comm>\r\n");
                            sb.Append("<comm_no></comm_no>\r\n");
                            sb.Append("</product>\r\n");
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

                            bool notify = false;
                            string result = String.Empty;
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
                        else if (namevalue == "linktech" && _system["openlinktech"] == "1") //从linktech来的
                        {
                            try
                            {
                                string ltinfo = cps.Values["LTINFO"];
                                if (_system["linktechid"] != null && ltinfo != null)
                                {
                                    string linktechm_id = _system["linktechid"];
                                    bool notify = false;
                                    string url = "http://service.linktech.cn/purchase_cps.php?a_id=" + ltinfo + "&m_id=" + linktechm_id + "&mbr_id=" + 0 + "&o_cd=" + orderid + "&p_cd=" + ordermodel.Team_id + "&price=" + ordermodel.Price + "&it_cnt=" + ordermodel.Quantity + "&c_cd=COM";
                                    string result = String.Empty;
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
                        else if (namevalue == "tuanmatuanba" && _system["opentmtb"] == "1") //从团妈团爸来的
                        {
                            try
                            {
                                if (_system["tmtbkey"] != null)
                                {
                                    string key = _system["tmtbkey"];
                                    string result = String.Empty;
                                    string url = "http://api.tmtb.cn/tmtbquan/user_order.php?o_key=" + Server.HtmlEncode(cps.Values["o_key_tmtb"]) + "&uid=" + Server.HtmlEncode(cps.Values["uid_tmtb"]) + "&sid=" + Server.HtmlEncode(cps.Values["sid_tmtb"]) + "&time=" + ordermodel.Create_time + "&o_cd=" + ordermodel.Id + "&total_price=" + (ordermodel.Origin - ordermodel.Fare) + "&key=" + System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(key + ordermodel.Create_time + Server.HtmlEncode(cps.Values["uid_tmtb"]) + Server.HtmlEncode(cps.Values["sid_tmtb"]) + ordermodel.Id + (ordermodel.Origin - ordermodel.Fare), "md5").ToLower() + "&suid=" + ordermodel.User_id;
                                    result = url;
                                    System.Net.WebClient wc = new System.Net.WebClient();
                                    result = wc.DownloadString(url);
                                    decimal price = Helper.GetDecimal(result, 0);
                                    Response.Write("<script src='" + url + "'></" + "script>");
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
                            catch (Exception ex) { WebUtils.LogWrite("团吧团妈cps", ex.Message); }
                        }
                        else if (namevalue == "yotao" && _system["openyotao"] == "1") //从yotao来的
                        {
                            try
                            {
                                string url = "http://www.yotao.com/orderback/?sid=" + _system["yotaokey"] + "&uid=" + cps.Values["uid"] + "&aid=" + cps.Values["aid"] + "&yid=" + cps.Values["yid"] + "&oid=" + ordermodel.Id + "&amount=" + (ordermodel.Origin - ordermodel.Fare) + "&cback=&mcode=" + Helper.MD5(_system["yotaosecret"] + cps.Values["uid"] + ordermodel.Id);
                                string result = url;
                                Response.Write("<script src='" + url + "'></" + "script>");
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
                        else if (namevalue == "tpycps" && _system["opentpy"] == "1")  //来自太平洋CPS
                        {
                            try
                            {
                                string userid = Server.UrlDecode(cps.Values["userid"]); //需要解码
                                if (userid != null && userid.Length > 0)
                                {
                                    string id = _system["tpykey"];
                                    string key = _system["tpysecret"];
                                    string url = "http://news.tpy100.com/UnionCompany/unioncompanyinterface.aspx?userid=" + Server.UrlEncode(userid) + "&codeid=" + id + "&order_date=" + ordermodel.Create_time.ToString("yyyyMMdd") + "&order_time=" + ordermodel.Create_time.ToString("HHmmss") + "&orderid=" + ordermodel.Id + "&price=" + (ordermodel.Origin - ordermodel.Fare) + "&zhuangtai=c&key=" + Helper.MD5(userid + id + ordermodel.Id + (ordermodel.Origin - ordermodel.Fare) + "c" + key);
                                    Response.Write("<script src='" + url + "'></" + "script>");
                                    bool notify = false;
                                    string result = String.Empty;
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
                            catch (Exception ex) { WebUtils.LogWrite("youhuacps", ex.Message); }
                        }
                        else if (namevalue == "renrenzhe")//人人折
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
                            IList<IOrderDetail> ordermodellist = null;
                            if (ordermodel != null && ordermodel.OrderDetail != null)
                            {
                                ordermodellist = ordermodel.OrderDetail;
                            }
                            if (ordermodellist != null && ordermodellist.Count > 0)
                            {
                                for (int i = 0; i < ordermodellist.Count; i++)
                                {
                                    IOrderDetail orderdetail = ordermodellist[i];
                                    ITeam teammodel = null;
                                    string catalogname = "无";
                                    if (ordermodel.Team != null)
                                        teammodel = ordermodel.Team;
                                    o_cd = o_cd + ordermodel.Id;
                                    if (teammodel != null)
                                    {
                                        p_title = p_title + Server.UrlEncode(teammodel.Title) + "|_|";
                                        if (teammodel.TeamCatalogs != null)
                                        {
                                            catalogname = teammodel.TeamCatalogs.catalogname;
                                        }
                                    }
                                    p_url = p_url + Server.UrlEncode(WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + getTeamPageUrl(int.Parse(ordermodellist[i].Teamid.ToString()))) + "|_|";
                                    p_cd = p_cd + ordermodellist[i].Teamid + "|_|";
                                    price = price + ordermodel.Price + "|_|";
                                    it_cnt = it_cnt + ordermodel.Quantity + "|_|";
                                    c_cd = c_cd + Server.UrlEncode(catalogname) + "|_|";
                                }
                            }
                            string title = p_title.Replace("!", "%21").ToUpper().Replace("(", "%28").ToUpper().Replace(")", "%29").ToUpper().Replace("（", "%28").ToUpper().Replace("）", "%29").ToUpper();

                            string u = "it_cnt=" + it_cnt + "&k=" + k + "&o_cd=" + o_cd + "&o_time=" + o_time + "&p_cd=" + p_cd + "&p_title=" + title + "&p_url=" + p_url.ToUpper() + "&price=" + price + "&u_id=" + u_id + "";
                            string Md5code = u + cps.Values["ss"];
                            string code = Helper.MD5(Md5code);
                            string url = "http://union.renrenzhe.com/union/submitOrder.jspx";
                            sb.Append(u + "&code=" + code + "");

                            string result = String.Empty;
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
            #endregion
            Response.Write("<script>window.location.href='" + Page.ResolveUrl(GetUrl("银行支付", "order_pay.aspx?orderid=" + ordermodel.Id + "&pd_FrpId=" + Request["pd_FrpId"] + "&cft_FrpId=" + Request["cft_FrpId"] + "&p=" + inputmoney)) + "';</" + "script>");
            Response.End();
        }
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
    public virtual void CPS()
    {

    }
    public string GetTeam(string id, int orderid)
    {
        string str = "";
        ITeam teammodel = null;
        IOrder ordermodel = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(Helper.GetInt(id, 0));
            ordermodel = session.Orders.GetByID(orderid);
        }
        if (teammodel != null)
        {
            str = "<a  href='" + getTeamPageUrl(teammodel.Id) + "' target=_blank>" + teammodel.Title + "</a>";
        }
        else
        {
            detaillist = ordermodel.OrderDetail;
            if (detaillist != null)
            {
                int num = 0;
                foreach (var model in detaillist)
                {
                    ITeam detailteam = null;
                    num++;
                    str += "<a href='" + getTeamPageUrl(Helper.GetInt(model.Teamid.ToString(), 0)) + "'>" + num + ":";
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        detailteam = session.Teams.GetByID(model.Teamid);
                    }
                    str += detailteam == null ? "" : detailteam.Title;
                    str += "</a><br>";
                }
            }
            else
            {
                str = "";
            }
        }
        return str;
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
            else
            {
                youhui = false;
            }
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
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
            nownumber = nownumber + parseInt($(texts[i]).val());
        }
        if (totalnumber <= nownumber) {
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
        obj.value = obj.value.replace(/[^\d.]/g, "");  //清除“数字”和“.”以外的字符 
        obj.value = obj.value.replace(/^\./g, "");  //验证第一个字符是数字而不是. 
        obj.value = obj.value.replace(/\.{2,}/g, "."); //只保留第一个. 清除多余的. 
        obj.value = obj.value.replace(".", "$#$").replace(/\./g, "").replace("$#$", ".");
    }
    function secondCounter1(defSec, func, dispObj) {
        document.getElementById(dispObj).value = defSec-- + "秒后重新获取";
        document.getElementById("dynapwdevice_btn").onclick = "";
        if (defSec < 0) {
            document.getElementById(dispObj).value = "发送验证码";
            document.getElementById("dynapwdevice_btn").onclick = function () { initRemit(); };
        }
        else
            window.setTimeout("secondCounter1(" + defSec + ",\"" + func + "\",\"" + dispObj + "\")", 1000);
    }
    function initRemit(mobile, teamid, orderid) {
        $.ajax({
            type: "POST",
            url: webroot+"ajax/ajax_draw.aspx?mobile=" + mobile + "&teamid=" + teamid + "&orderid=" + orderid,
            success: function (msg) {
                if (msg == "认证码已发送手机上，请注意查收") {
                    secondCounter1(60, "", "dynapwdevice_btn");
                }
                $("#mess").html(msg);
            }
        });
    }
</script>
<script>
    $(document).ready(function () {
        jQuery("input[name='pd_FrpId']").click(function () {
            jQuery("input[name='paytype']").attr("checked", false);
            jQuery("input[name='cft_FrpId']").attr("checked", false);
        });
        jQuery("input[name='paytype']").click(function () {

            jQuery("input[name='pd_FrpId']").attr("checked", false);
            jQuery("input[name='cft_FrpId']").attr("checked", false);
        });
        jQuery("input[name='cft_FrpId']").click(function () {
            jQuery("input[name='pd_FrpId']").attr("checked", false);
            jQuery("input[name='paytype']").attr("checked", false);
        });
    });
    $(document).ready(function () {
        $("#btnadd").click(function () {
            var money = parseFloat("<%=inputmoney %>");
            var pm = parseFloat("<%=ordermodel.Origin %>");
            var um = parseFloat("<%=user.Money%>");
            var im = $("#inputmoney").val();
            var paytype = $("input[name='paytype']:checked");
            var cft_FrpId = $("input[name='cft_FrpId']:checked");
            var pd_FrpId = $("input[name='pd_FrpId']:checked");
            if (pm!=0) {
                if (paytype.length <= 0 && cft_FrpId.length <= 0 && pd_FrpId.length <= 0) {
                    alert("请选择支付方式");
                    return false;
                }
            }
            if ($("input:radio:checked").val() != "credit") {
                if (im > 0) {
                    if (im > pm) {
                        alert("您输入的金额超出订单金额,请您重新输入");
                        return false;
                    }
                    else if (im == pm) {
                        alert("您输入的金额请不要大于或等于订单金额,请您重新输入");
                        return false;
                    }
                    if (im > um) {
                        alert("您输入的金额超出您的帐户余额,请您重新输入");
                        return false;
                    }
                }
            }
        });
    });
</script>
<form id="form" runat="server">
<div id="bdw" class="bdw">
    <%if (ordermodel != null)
      { %>
    <div id="bd" class="cf">
        <div id="account-charge">
            <div id="deal-buy" class="box">
                <div class="box-content">
                    <div class="head">
                        <h2>您的订单<span class="deal-buy-desc"></span></h2>
                    </div>
                    <div class="sect">
                        <table class="order-table">
                            <tr>
                                <th class="deal-buy-desc">项目名称
                                </th>
                                <th class="deal-buy-quantity">数量
                                </th>
                                <th class="deal-buy-multi"></th>
                                <th class="deal-buy-price">价格
                                </th>
                                <th class="deal-buy-price"></th>
                                <th class="deal-buy-total">总价
                                </th>
                                <th class="deal-buy-total">代金券
                                </th>
                                <th></th>
                            </tr>
                            <tr>
                                <td class="deal-buy-desc">
                                    <%= GetTeam(ordermodel.Team_id.ToString(),ordermodel.Id)%><br />
                                    <%if (ordermodel.result != null && ordermodel.result.Length > 0)
                                      { %>
                                    <font style="color: red; font-size: 12px;"><strong>规格</strong></font>: <font style="font-size: 12px;">[<%=ordermodel.result.Replace("{", "").Replace("}", "").Replace("[", "").Replace("]", "")%>]   </font>

                                    <% } %>
                                </td>
                                <td tid="<%=ordermodel.Team_id %>" class="deal-buy-quantity">
                                    <%=ordermodel.Quantity%>
                                </td>
                                <td class="deal-buy-multi">x
                                </td>
                                <td class="deal-buy-price" id="deal-buy-price">
                                    <span class="money"><span>
                                        <%=ASSystem.currency %><%=ordermodel.Price%>
                                </td>
                                <td class="deal-buy-price">=
                                </td>
                                <td class="deal-buy-total" id="deal-buy-total">
                                    <span class="money"></span>
                                    <%=ASSystem.currency %><%=summoney%>
                                </td>
                                <td class="deal-buy-price" style="width: 90px; text-align: right;">
                                    <%if (ordermodel.Card_id != null && ordermodel.Card_id != "")
                                      {
                                          Response.Write("已经使用代金券");
                                      }
                                      else
                                      {
                                          if (frontTeammodel.Card > 0) { Response.Write("<a class='ajaxlink' href='" + WebRoot + "ajax/coupon.aspx?action=card&orderid=" + ordermodel.Id + "'>使用代金券</a>"); } else { Response.Write("不能使用"); }
                                      } %>
                                </td>
                                <td></td>
                            </tr>
                            <%if (ordermodel.Express == "Y")
                              { %>
                            <tr>
                                <td class="deal-buy-desc">快递
                                </td>
                                <td class="deal-buy-quantity"></td>
                                <td class="deal-buy-multi"></td>
                                <td class="deal-buy-price">
                                    <span class="money"></span><span id="deal-express-price">
                                        <% 
                                 
                                  if (frontTeammodel != null)
                                  {
                                        %>
                                        <%if (frontTeammodel.Farefree == 0)
                                          { %>
                                        <%=ASSystem.currency %><%=ordermodel.Fare%>
                                        <% }
                                          else
                                          {%>
                                        <%if (ordermodel.Quantity < frontTeammodel.Farefree)
                                          { %>
                                        <%=ASSystem.currency %><%=ordermodel.Fare%>
                                        <% }
                                          else
                                          {%>
                                                0
                                                <% }%>
                                        <% }%>
                                        <% }%>
                                    </span>
                                </td>
                                <td class="deal-buy-equal"></td>
                                <td class="deal-buy-total">
                                    <span class="money"></span><span id="deal-express-total"></td>
                                <td></td>
                                <td></td>
                            </tr>
                            <% }%>
                            <%if (ordermodel.Disinfos.Length > 0)
                              { %>
                            <tr>
                                <td class="deal-buy-desc">
                                    <%=ordermodel.Disinfos%>
                                </td>
                                <td class="deal-buy-quantity"></td>
                                <td class="deal-buy-multi"></td>
                                <td class="deal-buy-price">
                                    <span class="money"></span><span id="Span1">
                                        <%=ASSystem.currency %>-<%=(ordermodel.disamount) %>
                                    </span>
                                </td>
                                <td class="deal-buy-equal">=
                                </td>
                                <td class="deal-buy-total">
                                    <span class="money"></span><span id="Span3"></td>
                                <td></td>
                                <td></td>
                            </tr>
                            <% }%>
                            <%if (ordermodel.Card_id != "")
                              { %>
                            <tr id="cardcode-row">
                                <td class="deal-buy-desc">代金券：<span id="cardcode-row-n"><%=ordermodel.Card_id%></span>
                                </td>
                                <td class="deal-buy-quantity"></td>
                                <td class="deal-buy-multi"></td>
                                <td class="deal-buy-price">
                                    <span class="money"></span>
                                </td>
                                <td class="deal-buy-equal">=
                                </td>
                                <td class="deal-buy-total">-<span class="money"><%=ASSystem.currency%></span><span id="cardcode-row-t"><%=ordermodel.Card%></span>
                                </td>
                                <td></td>
                            </tr>
                            <% }%>
                            <%if (ordermodel.State != "scoreunpay")
                              { %>
                            <%if (ActionHelper.GetUserLevelMoney(AsUser.totalamount) != 1)
                              { %>
                            <tr>
                                <td class="deal-buy-desc"></td>
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
                                <td class="deal-buy-total">
                                    <span class="money">
                                        <%--<%=Utils.DBHelper.GetTeamtotalamount(ordermodel.Id)%>--%></span><span id="Span2">
                                </td>
                                <td></td>
                                <td></td>
                                <td></td>
                            </tr>

                            <% }
                              }%>

                            <%if (youhui == true)
                              { %>
                            <tr id="Tr1" class="order-total" runat="server">
                                <td class="deal-buy-desc">
                                    <strong>享受的优惠:</strong>
                                </td>
                                <td colspan="3" style="color: red">
                                    <asp:literal id="Literal1" runat="server"></asp:literal>
                                </td>
                            </tr>
                            <%} %>

                            <tr class="order-total">
                                <td class="deal-buy-desc">
                                    <strong>应付总额：</strong>
                                </td>
                                <td class="deal-buy-quantity"></td>
                                <td class="deal-buy-multi"></td>
                                <td class="deal-buy-price"></td>
                                <td class="deal-buy-equal">=
                                </td>
                                <td class="deal-buy-total">
                                    <span class="money"></span>
                                    <%=ASSystem.currency%><%=totalprice%>
                                </td>
                                <td></td>
                            </tr>
                            <%if (frontTeammodel.Delivery == "coupon" || frontTeammodel.Delivery == "pcoupon")
                              { 
                            %>
                            <tr>
                                <td class="deal-buy-desc">手机号:
                                </td>
                                <td class="deal-buy-desc">
                                    <input type="text" name="mobile" group="a" require="true" msg="手机号格式不正确" datatype="mobile"
                                        id="mobile" class="number" value="<%=AsUser.Mobile %>" />
                                </td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td colspan="2"></td>
                            </tr>
                            <% }
                              else if (frontTeammodel.Delivery.Trim() == "draw")
                              {%>
                            <%if (frontTeammodel.codeswitch == "yes")
                              { %>
                            <tr>
                                <td class="deal-buy-desc">手机号:
                                </td>
                                <td class="deal-buy-desc">
                                    <input type="text" name="tv_mobile" group="b" require="true" datatype="mobile" msg="手机号不能为空"
                                        id="tv_mobile" class="number" value="<%=AsUser.Mobile %>" />
                                </td>
                                <td></td>
                                <td>
                                    <input id="dynapwdevice_btn" type="button" value="发送验证码" onclick="initRemit(document.getElementById('tv_mobile').value,'<%=frontTeammodel.Id %>    ','<%=ordermodel.Id %>    ');"
                                        class="formbutton validator" group="b" />
                                </td>
                                <td id="mess" colspan="3">
                                    <%=mobilemessage%>
                                </td>
                                <td></td>
                                <td></td>
                            </tr>
                            <tr>
                                <td class="deal-buy-desc">认证码:
                                </td>
                                <td class="deal-buy-desc">
                                    <input type="text" name="tv_code" group="a" style="margin: 3px 10px 0 0;" require="true" datatype="require" id="tv_code"
                                        class="number" msg="认证码不能为空" value="" />
                                </td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td></td>
                            </tr>
                            <% }

                              }%>
                            <%if (_system["orderemailvalid"] == "1")
                              {%>
                            <tr>
                                <td class="deal-buy-desc">我的邮箱:
                                </td>
                                <td class="deal-buy-desc">
                                    <input type="text" name="tv_email" group="a" require="true" datatype="email|ajax"
                                        id="tv_email" class="f-input" url="<%=WebRoot %>ajax/user.aspx" vname="editemail" value="<%=AsUser.Email%>"
                                        msg="邮箱格式不正确|" msgid="emailerr" />
                                </td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td></td>
                            </tr>
                            <%} %>
                        </table>
                        <div class="paytype">
                        <%if (ordermodel.State == "unpay")
                          {%>
                        </div>
                        <div class="order-check-form ">
                            <div class="order-pay-credit">
                                <h3>您的余额</h3>
                                <p>
                                    账户余额：<strong><span class="money"></span><%=ASSystem.currency%><%=user.Money%></strong>
                                    <%if (!isCreditseconds)//没有开启余额秒杀
                                      {%>
                                     <%if (ordermodel.Origin > user.Money)
                                       { %>
                                            ,您的余额不够完成本次付款，还需支付
                         <strong><span class="money"></span><%=ASSystem.currency%><%=OrderMethod.Getyumoney(user.Money, ordermodel.Origin)%> </strong>

                                        <%} %>
                                           <%if (user.Money > 0 && ordermodel.Origin != 0)
                                             {%>
                                        使用账户余额支付
                                              <input id="inputmoney" name="inputmoney" type="text" value="<%=Helper.GetDecimal(Request["inputmoney"],0)%>" style="width:50px" />
                                          <%}%>
                                      <%}
                                      else//开启余额秒杀
                                      { %>
                                      <%if (user.Money > ordermodel.Origin)
                                        { %>
                                      <input type="hidden" name="paytype"  value="credit" />
                                            您的余额足够本次购买，请直接确认订单，完成付款。
                                        <%}
                                        else
                                        { %>
                                            ,此项目只能余额秒杀，您的余额不足，还应给您账号充值：<%=ASSystem.currency%><%=OrderMethod.Getyumoney(user.Money, DBHelper.GetTeamTotalPriceWithFare(ordermodel.Id))%>。点击此处进行<a
                                                href="<%=GetUrl("支付方式","credit_charge.aspx")%>">充值</a>。
                                    <%}%>
                                    <%}%>
                                  
                            </div>
                            <!--判断是否是余额可秒杀-->
                            <%if (!isCreditseconds && ordermodel.Origin != 0)//没有开启余额秒杀
                              {%>
                            <ul class="typelist">
                                <%if (system != null)
                                  { %>
                                <%if (system.yeepaymid != "" && CookieUtils.GetCookieValue("alipay_token") == "" && _system["isybbank"] != null && _system["isybbank"].ToString() != "" && _system["isybbank"].ToString() == "1")
                                  {  %>
                                <div class="bank_way" id="ybbankdiv">
                                    <div class="bank_buy">
                                        <p class="choose-pay-type">
                                            易宝支付
                                        </p>
                                    </div>
                                    <li>
                                        <input type="hidden" id="ybbank" value="<%=_system["isybbank"]%>" />
                                        <table class="banktable" id="order-check-banktable">
                                            <tr>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" id="abc" title="招商银行" value="CMBCHINA-NET">
                                                    <label class="CMBCHINA-NET" title="招商银行">
                                                    </label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="工商银行" value="ICBC-NET"><label title="工商银行"
                                                        class="ICBC-NET"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="建设银行" value="CCB-NET"><label class="CCB-NET"
                                                        title="建设银行"></label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="中国农业银行" value="ABC-NET"><label class="ABC-NET"
                                                        title="中国农业银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="北京银行" value="BCCB-NET"><label class="BCCB-NET"
                                                        title="北京银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="交通银行" value="BOCO-NET"><label class="BOCO-NET"
                                                        title="交通银行"></label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="兴业银行" value="CIB-NET"><label class="CIB-NET"
                                                        title="兴业银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="南京银行" value="NJCB-NET"><label class="NJCB-NET"
                                                        title="南京银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="中国民生银行" value="CMBC-NET"><label class="CMBC-NET"
                                                        title="中国民生银行"></label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="光大银行" value="CEB-NET"><label class="CEB-NET"
                                                        title="光大银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="中国银行" value="BOC-NET"><label class="BOC-NET"
                                                        title="中国银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="平安银行" value="PAB-NET"><label class="PAB-NET"
                                                        title="平安银行"></label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="渤海银行" value="CBHB-NET"><label class="CBHB-NET"
                                                        title="渤海银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" value="HKBEA-NET" title="东亚银行"><label class="HKBEA-NET"
                                                        title="东亚银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="宁波银行" value="NBCB-NET"><label class="NBCB-NET"
                                                        title="宁波银行"></label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="中信银行" value="ECITIC-NET"><label class="ECITIC-NET"
                                                        title="中信银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="深圳发展银行" value="SDB-NET"><label class="SDB-NET"
                                                        title="深圳发展银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="广东发展银行" value="GDB-NET"><label class="GDB-NET"
                                                        title="广东发展银行"></label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="上海浦东发展银行" value="SPDB-NET"><label class="SPDB-NET"
                                                        title="上海浦东发展银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" value="POST-NET" title="中国邮政"><label class="POST-NET"
                                                        title="中国邮政"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="pd_FrpId" title="北京农村商业银行" value="BJRCB-NET"><label class="BJRCB-NET"
                                                        title="北京农村商业银行"></label>
                                                </td>
                                            </tr>

                                        </table>
                                    </li>
                                </div>
                                <% }%>
                                <%if (system.tenpaymid != "" && _system["iscftbank"] != null && _system["iscftbank"].ToString() != "" && _system["iscftbank"].ToString() == "1")
                                  { %>
                                <div class="bank_way" id="cftbankdiv">
                                    <div class="bank_buy">
                                        <p class="choose-pay-type">
                                            财付通支付
                                        </p>
                                    </div>
                                    <li>
                                        <input type="hidden" id="cftbank" value="<%=_system["iscftbank"]%>" />
                                        <table class="banktable" id="CFT">
                                            <tr>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" id="zs" title="招商银行" value="1001">
                                                    <label class="CMBCHINA-NET" title="招商银行">
                                                    </label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="工商银行" value="1002"><label title="工商银行"
                                                        class="ICBC-NET"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="建设银行" value="1003"><label class="CCB-NET"
                                                        title="建设银行"></label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="中国农业银行" value="1005"><label class="ABC-NET"
                                                        title="中国农业银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="上海浦东发展银行" value="1004"><label class="SPDB-NET"
                                                        title="上海浦东发展银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="北京银行" value="1032"><label class="BCCB-NET"
                                                        title="北京银行"></label>
                                                </td>

                                            </tr>
                                            <tr>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="兴业银行" value="1009T"><label class="CIB-NET"
                                                        title="兴业银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="上海银行" value="1024"><label class="SHCB-NET"
                                                        title="上海银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="中国民生银行" value="1006"><label class="CMBC-NET"
                                                        title="中国民生银行"></label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="光大银行" value="1022"><label class="CEB-NET"
                                                        title="光大银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="中国银行" value="1052"><label class="BOC-NET"
                                                        title="中国银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="平安银行" value="1010"><label class="PAB-NET"
                                                        title="平安银行"></label>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="华夏银行" value="1025"><label class="HXHB-NET"
                                                        title="华夏银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" value="1033" title="网汇通"><label class="WHT-NET"
                                                        title="网汇通"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" value="1028" title="中国邮政"><label class="POST-NET"
                                                        title="中国邮政"></label>
                                                </td>
                                                <%--  <td>
                                                            <input type="radio" name="pd_FrpId" title="宁波银行" value="NBCB-NET"><label class="NBCB-NET"
                                                                title="宁波银行"></label>
                                                        </td>--%>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="中信银行" value="1021"><label class="ECITIC-NET"
                                                        title="中信银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="深圳发展银行" value="1008"><label class="SDB-NET"
                                                        title="深圳发展银行"></label>
                                                </td>
                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="广东发展银行" value="1028"><label class="GDB-NET"
                                                        title="广东发展银行"></label>
                                                </td>
                                            </tr>
                                            <tr>

                                                <td>
                                                    <input type="radio" name="cft_FrpId" title="交通银行" value="1020"><label class="BOCO-NET"
                                                        title="交通银行"></label>
                                                </td>
                                            </tr>

                                        </table>
                                    </li>
                                </div>
                                <% }%>
                                <%if (system.alipaymid != "")
                                  { %>
                                <div class="bank_way">
                                    <div class="bank_buy">
                                        <p class="choose-pay-type">
                                            支付宝支付
                                        </p>
                                    </div>
                                    <li>
                                        <input id="check-alipay" type="radio" name="paytype" value="alipay" /><label for="check-alipay"
                                            class="biglabel alipay">支付宝交易，推荐淘宝用户使用</label>
                                        <br />
                                        <br />
                                    </li>
                                </div>
                                <% }%>
                                <%if (system.yeepaymid != "" && _system["isybbank"] != null && _system["isybbank"].ToString() != "" && _system["isybbank"].ToString() == "0")
                                  { %>
                                <div class="bank_way" id="ybzfdiv">
                                    <div class="bank_buy">
                                        <p class="choose-pay-type">
                                            易宝支付
                                        </p>
                                    </div>
                                    <li>
                                        <input id="ybzhf-yeepay" type="radio" name="paytype" value="yeepay" /><label for="ybzhf-yeepay"
                                            class="biglabel yeepay">易宝交易，支持招商、工行、建行、中行等主流银行</label></li>
                                </div>
                                <%}
                                  if (system.tenpaymid != "" && _system["iscftbank"] != null && _system["iscftbank"].ToString() != "" && _system["iscftbank"].ToString() == "0")
                                  { %>
                                <div class="bank_way" id="cfttlbankdiv">
                                    <div class="bank_buy">
                                        <p class="choose-pay-type">
                                            财付通支付
                                        </p>
                                    </div>
                                    <li>
                                        <input id="check-tenpay" type="radio" name="paytype" value="tenpay" /><label for="check-tenpay"
                                            class="biglabel tenpay">财付通交易，推荐拍拍用户使用</label></li>
                                </div>
                                <%}
                                  if (system.chinabankmid != "" && CookieUtils.GetCookieValue("alipay_token") == "")
                                  { %>
                                <div class="bank_way">
                                    <div class="bank_buy">
                                        <p class="choose-pay-type">
                                            网银支付
                                        </p>
                                    </div>
                                    <li>
                                        <input id="Radio2" type="radio" name="paytype" value="chinabank" /><label for="check-tenpay"
                                            class="biglabel chinabank">网银支付交易，支持招商、工行、建行、中行等主流银行</label></li>
                                </div>
                                <%} %>

                                <% if (system.paypalmid != null && system.paypalmid.Trim() != "")
                                   {%>
                                <div class="bank_way">
                                    <div class="bank_buy">
                                        <p class="choose-pay-type">PayPal贝宝支付</p>
                                    </div>
                                    <li><input id="check-paypal" type="radio" name="paytype" value="paypal" {$ordercheck['paypal']} /><label for="check-paypal" class="biglabel paypal">贝宝交易,支持招商、工行、建行、农行等银行（仅支持人民币）</label></li>
                                </div>

                                <% }%>
                                <% if (frontTeammodel.cashOnDelivery != null)
                                   { %>
                                <% if (frontTeammodel.cashOnDelivery != "" && frontTeammodel.cashOnDelivery.ToString() == "1" && ordermodel.Express == "Y")
                                   { %>
                                <div class="bank_way">
                                    <div class="bank_buy">
                                        <p class="choose-pay-type">
                                            货到付款
                                        </p>
                                    </div>
                                       <li class="bankbuy-up">
                                                        <input id="check-cashondelivery" type="radio" name="paytype" value="cashondelivery" />
                                                        <label for="check-tenpay" class="biglabel cash">
                                                        </label>
                                                    </li>
                                </div>
                                <%} %>
                                <%} %>
                                  <%if (user.Money > ordermodel.Origin)
                                    { %>
                                 <div class="bank_way">
                                    <div class="bank_buy">
                                        <p class="choose-pay-type">使用余额全额支付</p>
                                    </div>
                                    <li>  
                                        <input id="Radio1" type="radio" name="paytype"  value="credit" /> 
                                        <img height="39" src="/upfile/css/i/balance-pay.gif" /></li>
                                </div>
                            <%}%>
                            </ul>
                            <%}%>
                            <%}%>
                            <div class="clear">
                            </div>
                            <p class="check-act">
                                <input type="submit" value="确认订单，付款" class="formbutton validator" group="a" name="btnadd" id="btnadd" />
                                <a href="<%=GetUrl("优惠卷购买", "team_buy.aspx?orderid="+ordermodel.Id)%>" style="margin-left: 1em;">返回修改订单</a>
                            </p>
                            <% if (user.Money < ordermodel.Origin)
                               { %>
                            <br />
                            <p style="color: Red;">
                                友情提示：由于支付宝或网银通知消息可能会有延迟,如果您已经支付过该订单,请不要再修改订单或付款. 稍后更新订单状态!
                            </p>
                            <%} %>
                        </div>
                        <% }%>
                    </div>
                </div>
            </div>
        </div>
        <div id="sidebar">
        </div>
    </div>
    <% }%>
</div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>