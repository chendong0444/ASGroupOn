using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.Domain;
using System.Web;
using AS.Common.Utils;
using AS.GroupOn.App;
using System.Collections.Specialized;
using System.Data;
using System.Collections;

namespace AS.GroupOn.Controls
{
    public class OrderMethod
    {
        public static decimal jian = 0;
        public static int fare_shoping;
        public static decimal fan = 0;

        public const string COOKIE_CAR = "carcoupon";     //cookie中的购物车

        public static void AddCar(string product)
        {

            HttpCookie car = new HttpCookie(COOKIE_CAR, product);
            car.Expires = DateTime.Now.AddDays(7);
            HttpContext.Current.Response.Cookies.Remove(COOKIE_CAR);
            HttpContext.Current.Response.Cookies.Add(car);

        }

        public static void ClearCar()
        {
            AddCar("");
        }

        /// <summary>
        /// 得到购物车
        /// </summary>
        /// <returns></returns>
        public static string GetCarInfo()
        {
            if (HttpContext.Current.Request.Cookies[COOKIE_CAR] != null)
            {
                string str = HttpContext.Current.Request.Cookies[COOKIE_CAR].Value.ToString();
                return HttpContext.Current.Request.Cookies[COOKIE_CAR].Value.ToString();
            }
            return "";
        }

        public static string buyresult()
        {
            string str = "";
            string carinfo = GetCarInfo();
            if (carinfo != "")
            {
                foreach (string product in carinfo.Split('|'))
                {
                    str = product.Split(',')[1].ToString();
                }
            }
            return str;
        }


        public static string buyid()
        {
            string str = "";
            string carinfo = GetCarInfo();
            if (carinfo != "")
            {
                foreach (string product in carinfo.Split('|'))
                {
                    str = product.Split(',')[0].ToString();
                }
            }
            return str;
        }

        #region 用户无法修改其他用户的额单子
        public static bool IsUserOrder(int userid, int orderid)
        {
            bool falg = false;
            OrderFilter of = new OrderFilter();
            IList<IOrder> listorder = null;
            of.State = "unpay";
            of.User_id = userid;
            of.Id = orderid;
            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                listorder = seion.Orders.GetList(of);
            }
            if (listorder.Count <= 0)
            {
                falg = true;
            }
            return falg;
        }
        #endregion

        #region 记录buy页面的规格()
        public static void AddProductToCar(string teamid, string result)
        {
            string product = teamid + "," + result;

            //购物车中没有该商品
            string oldCar = GetCarInfo();
            string newCar = null;
            if (oldCar != "")
            {
                oldCar += "|";
            }
            newCar += oldCar + product;
            AddCar(newCar);
        }
        #endregion

        #region 据交易单号返回是订单还是充值
        /// <summary>
        /// 根据交易单号返回是订单还是充值
        /// </summary>
        /// <param name="payid"></param>
        /// <returns>true订单 false充值</returns>
        public static bool GetPayType(string payid)
        {
            if (payid.Length > 0)
            {
                string[] arr = payid.Split(new string[] { "as" }, StringSplitOptions.RemoveEmptyEntries);
                if (arr.Length >= 3)
                {
                    if (arr[2] == "0")
                        return false;
                }
            }
            return true;
        }
        #endregion

        #region 根据订单交易单号返回订单需要支付的金额
        /// <summary>
        /// 根据订单交易单号返回订单需要支付的金额
        /// </summary>
        /// <param name="payid">交易单号</param>
        /// <returns></returns>
        public static decimal GetPayPrice(string payid)
        {
            string error = String.Empty;
            decimal payprice = 999999;
            //处理代码
            if (payid.Length == 0)
            {
                error = "交易单号不能为空";
            }
            else
            {
                string sql = String.Format("select origin,[user].money as user_money from [order] inner join [user] on([order].user_id=[user].id) where pay_id='{0}'", Helper.GetString(payid, "fdsafdsafdasfdas"));
                List<Hashtable> ht = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ht = session.Custom.Query(sql);
                }
                if (ht == null || ht.Count == 0)
                {
                    error = "不存在此交易单号的订单";
                }
                else
                {
                    decimal user_money = Helper.GetDecimal(ht[0]["user_money"], 0);
                    decimal origin = Helper.GetDecimal(ht[0]["origin"], 0);
                    if (user_money > 0 && user_money < origin)
                    {
                        payprice = origin - user_money;
                    }
                    else
                    {
                        payprice = origin;
                    }
                }
            }
            if (error.Length > 0)
            {
                throw new Exception(error);
            }
            return payprice;
        }

        #endregion

        #region 订单成功后，返回信息   修改方法之前，请写上自己的姓名+日期
        //从接口返回支付金额amt
        public static void Updateorder(string payid, string amt, string service, DateTime? pay_time)
        {
            string order = payid.Replace("as", ",");
            string[] str = order.Split(',');
            //订单编号格式：项目IDas用户IDas订单IDasHHMMSS
            if (str[2] == "0")//充值
            {
                Charge(payid, decimal.Parse(amt), service, Convert.ToInt32(str[1]), Convert.ToInt32(str[2]), pay_time);
            }
            else
            {
                Updateorder(Convert.ToInt32(str[2]), decimal.Parse(amt), service, 0, pay_time, payid);
            }

        }
        #endregion

        #region 账户充值
        public static void Charge(string payid, decimal amt, string service, int userid, int orderid, DateTime? pay_time)
        {
            IPay paymodel = null;
            IUser usermodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                paymodel = session.Pay.GetByID(payid);
                usermodel = session.Users.GetByID(userid);
            }
            if (paymodel == null)//判断是否有重复
            {
                AddFlow(userid, orderid, "income", amt, "charge", 0, pay_time, payid, service); //记录用户消费记录
                AddPay(orderid.ToString(), payid, WebUtils.GetPayCnName(WebUtils.GetPayType(service)), amt, "CNY", service, pay_time);//记录用户付款记录

                IUser user = Store.CreateUser();
                user.Money = amt + usermodel.Money;
                user.Id = userid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Users.UpdateMoney(user);
                }

                //充值送积分
                if (PageValue.CurrentSystemConfig["chargescore"] != null && PageValue.CurrentSystemConfig["chargescore"].ToString() != "" && PageValue.CurrentSystemConfig["chargescore"].ToString() != "0")
                {
                    UpdateScore(userid, usermodel.Score, int.Parse(PageValue.CurrentSystemConfig["chargescore"].ToString()));
                }
            }
        }
        #endregion

        #region 用户消费记录
        public static void AddFlow(int userid, int orderid, string Direction, decimal money, string action, int adminid, DateTime? pay_time, string payid, string service)
        {
            ISystem system = Store.CreateSystem();
            IFlow flow = Store.CreateFlow();
            IInvite invite = null;
            IOrder order = null;
            IUser user = null;
            IUser newuser = Store.CreateUser();
            int teamid = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                order = session.Orders.GetByID(orderid);
                user = session.Users.GetByID(userid);
            }
            flow.User_id = userid;
            if (order != null)
            {
                if (order.Pay_id != null && order.Pay_id.ToString() != "")
                {
                    flow.Detail_id = order.Pay_id;
                }
                else
                {
                    order.Pay_id = Getorder(userid, teamid, orderid);
                    int i = 0;
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        i = session.Orders.Update(order);
                    }
                    if (i > 0)
                        flow.Detail_id = order.Pay_id;
                    else
                        flow.Detail_id = "0";
                }
            }
            else
            {
                flow.Detail_id = "0";
            }
            flow.Direction = Direction;
            flow.Money = money;
            flow.Action = action;  //动作为buy购买
            if (pay_time.HasValue) flow.Create_time = pay_time.Value;
            else
                flow.Create_time = DateTime.Now;
            flow.Admin_id = adminid;//管理员
            if (orderid != 0) //判断此订单号是不是充值的订单号，如果是那么不执行下面的操作
            {
                if (user != null)
                {
                    if (user.Newbie != "C")
                    {
                        user.Newbie = "Y";
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            session.Users.UpdateNewBie(user);
                        }
                    }
                }
                if (Getinvite(userid))//此用户是否邀请了别人  :查询此用户是否被邀请
                {
                    invite = GetByfrom(userid);  //根据Other_user_id查询出邀【主动邀请人】在邀请表【invite】中的信息

                    //同时修改邀请表中的信息，Other_user_id ，被邀请人下订单购买成功，那么邀请表中【invite】中字段Pay 修改为'N'
                    //邀请表中的Pay  ‘Y’已返利，‘N’未返利，‘C’违规记录

                    //查询已购买，条件，Pay='N' and Buy_time != '

                    IUser users = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        users = session.Users.GetByID(user.Id);
                    }
                    if (users != null)
                    {
                        if (users.Newbie == "Y")//判断被邀请人是否第一次购买项目
                        {
                            if (order != null && invite != null)
                            {
                                if (invite.Team_id == 0)
                                {
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        teamid = session.OrderDetail.GetByOrderid_team(order.Id);
                                    }
                                    if (order.Team != null)
                                        invite.Team_id = order.Team.Id;
                                    else
                                        invite.Team_id = teamid;
                                }
                                invite.Pay = "Y";
                                invite.Buy_time = DateTime.Now; //被邀请人下订单的时间
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    session.Invite.Update(invite);
                                }
                            }
                            NameValueCollection configs = new NameValueCollection();
                            configs = WebUtils.GetSystem();
                            if (configs["invitescore"] != null && configs["invitescore"].ToString() != "" && configs["invitescore"].ToString() != "0")
                            {
                                IUser b_user = Store.CreateUser();
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    b_user = session.Users.GetByID(int.Parse(CookieUtils.GetCookieValue("invitor")));
                                }

                                if (b_user != null)
                                {
                                    UpdateScore(b_user.Id, b_user.userscore, int.Parse(configs["invitescore"].ToString()));
                                    IScorelog scorelogs = Store.CreateScorelog();
                                    scorelogs.action = "邀请好友";
                                    scorelogs.score = int.Parse(WebUtils.config["invitescore"].ToString());
                                    scorelogs.user_id = b_user.Id;
                                    scorelogs.adminid = 0;
                                    scorelogs.create_time = DateTime.Now;
                                    scorelogs.key = "0";
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        session.Scorelog.Insert(scorelogs);
                                    }
                                }
                            }
                            CookieUtils.ClearCookie("invitor");

                        }
                    }
                }
            }
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                session.Flow.Insert(flow);
            }
        }
        #endregion

        #region 查询此用户是否被邀请
        public static bool Getinvite(int userid)
        {
            bool falg = false;
            IInvite invite = Store.CreateInvite();

            invite = GetByfrom(userid);

            if (invite != null)
            {
                falg = true;
            }
            else
            {
                falg = false;
            }
            return falg;
        }
        #endregion

        #region 得到一个对象实体
        /// <summary>
        /// 得到一个对象实体
        /// </summary>
        public static IInvite GetByfrom(int Other_user_id)
        {
            IInvite invite = Store.CreateInvite();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                invite = session.Invite.GetByOther_Userid(Other_user_id);
            }
            if (invite != null)
                return invite;
            else
                return null;
        }
        #endregion

        #region 修改用户的积分
        /// <summary>
        /// 修改用户的积分
        /// </summary>
        /// <param name="userid">ID</param>
        /// <param name="summoeny">积分</param>
        /// <param name="yumongy">+ -积分</param>
        public static void UpdateScore(int userid, int userscore, int score)
        {
            int result = userscore + score;
            if (result < 0)
            {
                result = 0;
            }
            IUser s_user = Store.CreateUser();

            s_user.userscore = result;
            s_user.Id = userid;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                session.Users.UpdateUserScore(s_user);
            }

        }
        #endregion

        #region 用户付款记录
        public static void AddPay(string orderid, string payid, string bank, decimal money, string Currency, string service, DateTime? pay_time)
        {

            int oid = Helper.GetInt(orderid, 0);
            IPay pay = Store.CreatePay();
            IPay pays = Store.CreatePay();

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pay = session.Pay.GetByID(payid);
            }

            if (oid > 0 && pay == null || oid == 0)
            {
                pays.Id = payid;//网银交易单号
                pays.Order_id = oid;//订单号
                pays.Bank = bank;
                pays.Currency = Currency;
                pays.Service = service;
                if (pay_time.HasValue) pays.Create_time = pay_time.Value;
                else
                    pays.Create_time = DateTime.Now;
                pays.Money = money;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Pay.Insert(pays);
                }
            }

        }
        #endregion

        #region 订单付款成功后执行的方法
        private static object locker = new object();
        /// <summary>
        /// 更改订单付款状态
        /// </summary>
        /// <param name="orderid">订单ID</param>
        /// <param name="amt">订单金额，验证</param>
        /// <param name="service">支付方式</param>
        /// <param name="adminid">管理员ID,只有管理员手动点击付款才会大于0</param>
        /// <param name="pay_time">付款时间。目前保留不用 请传null</param>
        public static void Updateorder(int orderid, decimal amt, string service, int adminid, DateTime? pay_time, string payid)
        {
            NameValueCollection _system = new NameValueCollection();
            _system = WebUtils.GetSystem();
            IOrder ordermodel = null;
            IUser usermodel = null;
            ITeam mTeam = null;
            IList<IOrderDetail> detailist = null;

            lock (locker)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ordermodel = session.Orders.GetByID(orderid);
                }
                if (ordermodel != null)
                {
                    if (ordermodel.User != null)
                        usermodel = ordermodel.User;
                    if (ordermodel.Team != null)
                        mTeam = ordermodel.Team;
                }
                if (usermodel == null)
                {
                    return;
                }
                if (payid != null && payid.Length > 0)
                    ordermodel.Pay_id = payid;
                decimal credit = 0;

                decimal m = 0;
                #region  第一步 先判断订单是否存在并且为允许付款状态(cancel,unpay,scoreunpay)
                if ((ordermodel.State == "unpay" || ordermodel.State == "scoreunpay" || ordermodel.State == "cancel"))//判断是否未支付
                {

                    #region 第二步 在判断如果订单不是现金付款则支付金额+用户余额必须大于等于订单金额才允许往下执行
                    if (service != "cash")
                    {
                        if ((amt + usermodel.Money) < ordermodel.Origin)
                        {
                            return;
                        }
                        else
                        {
                            credit = ordermodel.Origin - amt;//  
                        }
                    }
                    #endregion


                    #region 第三步 如果是现金付款则把支付金额 赋值为 订单总金额-用户余额，如果减完小于0则设置为0
                    if (service == "cash")
                    {
                        if (usermodel.Money - ordermodel.Origin < 0)
                        {
                            amt = ordermodel.Origin - usermodel.Money;//在线支付金额

                            credit = usermodel.Money;//订单余额
                        }
                        else
                        {
                            amt = 0;//在线支付金额
                            credit = ordermodel.Origin - amt;
                        }
                    }
                    #endregion

                    //促销活动返给用户的金额
                    //GetCuXiao(amt, ordermodel);
                    GetCuXiao(Helper.GetDecimal(CookieUtils.GetCookieValue("summoney"), 0), ordermodel);
                    m = fan;
                    ordermodel.Returnmoney = m;
                    #region 第四步 更新用户余额,更新订单状态,付款方式,在线支付金额,余额付款金额
                    //如果不是货到付款才减余额，是货到付款，等后台确认已收货后才减余额
                    if (ordermodel.Service != "cashondelivery")
                    {
                        decimal summoeny = 0 - credit;
                        decimal yumongy = usermodel.Money;
                        decimal result = summoeny + yumongy;
                        if (result >= 0)
                        {
                            usermodel.Money = result;
                        }
                        else
                        {
                            usermodel.Money = 0;
                        }
                    }

                    //促销活动返给用户金额
                    //非货到付款项目
                    if (ordermodel.Service != "cashondelivery")
                    {
                        usermodel.Money += m;
                        if (m != 0)
                        {
                            AddFlow(usermodel.Id, ordermodel.Id, "income", m, "Feeding_amount", 0, DateTime.Now, ordermodel.Pay_id, "");
                        }
                    }
                    #endregion

                    #region 付款成功后赠送积分的记录
                    int scorecount = 0;
                    //订单花费总积分为0
                    //非货到付款项目
                    if (ordermodel.totalscore == 0 && ordermodel.Service != "cashondelivery")
                    {
                        if (ordermodel.Team_id == 0 || ordermodel.Team_id.ToString() == "") //走购物车
                        {
                            IList<IOrderDetail> detailist1 = null;
                            detailist1 = ordermodel.OrderDetail;
                            ITeam teamm = null;
                            if (detailist1 != null && detailist1.Count > 0)
                            {
                                foreach (var d in detailist1)
                                {
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        teamm = session.Teams.GetByID(d.Teamid);
                                    }
                                    if (teamm != null)
                                    {
                                        scorecount += teamm.score * d.Num;
                                        d.orderscore = d.Num * teamm.score;
                                    }
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        session.OrderDetail.UpdateOrderScore(d);
                                    }
                                }
                            }
                        }
                        else
                        {
                            scorecount = mTeam.score * ordermodel.Quantity;
                        }
                        //项目赠送积分为0的时候，不写入积分消费表
                        if (scorecount != 0)
                        {
                            Insert_scorelog(scorecount, "下单", ordermodel.Id.ToString(), 0, ordermodel.User_id);
                        }
                    }
                    else
                    {
                        //订单花费总积分不为0
                        //非货到付款项目
                        //积分购买为0的时候，不写入积分消费表
                        if (ordermodel.totalscore != 0 && ordermodel.Service != "cashondelivery")
                        {
                            Insert_scorelog(ordermodel.totalscore, "积分兑换", ordermodel.Id.ToString(), 0, ordermodel.User_id);
                        }
                    }
                    #endregion
                    //用户累计消费金额
                    //非货到付款项目
                    if (ordermodel.Service != "cashondelivery")
                    {
                        usermodel.totalamount = usermodel.totalamount + (ordermodel.Origin - ordermodel.Fare);
                    }
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        session.Users.Update(usermodel);
                    }

                    if (service == "cash")
                    {
                        AddFlow(ordermodel.User_id, ordermodel.Id, "expense", decimal.Parse(ordermodel.Origin.ToString()), "cash", adminid, pay_time, payid, service); //记录用户消费记录
                    }
                    else if (service != "cashondelivery")
                    {
                        IPay paymodel = null;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            paymodel = session.Pay.GetByID(ordermodel.Pay_id);
                        }

                        if (paymodel != null)
                        {
                            return;
                        }
                        if (paymodel == null)//判断是否有重复
                        {
                            AddFlow(ordermodel.User_id, ordermodel.Id, "expense", decimal.Parse(ordermodel.Origin.ToString()), "buy", 0, pay_time, payid, service); //记录用户消费记录
                            AddPay(orderid.ToString(), ordermodel.Pay_id, WebUtils.GetPayCnName(WebUtils.GetPayType(ordermodel.Service)), amt, "CNY", ordermodel.Service, pay_time);//记录用户付款记录
                        }
                    }
                    //修改项目状
                    if (ordermodel.Team_id == 0 || ordermodel.Team_id.ToString() == "")
                    {
                        #region 快递项目处理
                        detailist = ordermodel.OrderDetail;
                        if (detailist != null && detailist.Count > 0)
                        {
                            foreach (IOrderDetail model in detailist)
                            {
                                UpdateNumber(Convert.ToInt32(model.Teamid), Convert.ToInt32(model.Num));
                                mTeam = model.Team;
                                if (mTeam != null)
                                {
                                    if (model.result != "" && mTeam.invent_result != String.Empty)
                                    {
                                        mTeam.invent_result = Utility.GetOrderrule(model.result, mTeam.invent_result, 0);
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Teams.Update(mTeam);
                                        }
                                    }
                                    //下单出库，同时修改项目的库存数量
                                    if (mTeam.inventory != 0)
                                    {
                                        mTeam.inventory = mTeam.inventory - model.Num;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Teams.Update(mTeam);
                                        }
                                    }
                                    //inventorylog添加记录,1管理员入库 2管理员出库 3下单出库 4下单入库
                                    AdminPage.intoorder(ordermodel.Id, -model.Num, 3, mTeam.Id, ordermodel.User_id, model.result, 0);
                                    #region 处理产品库存
                                    IProduct promodel = null;
                                    promodel = mTeam.Products;
                                    if (promodel != null)
                                    {
                                        if (model.result != "")
                                        {
                                            promodel.invent_result = Utility.GetOrderrule(model.result, promodel.invent_result, 0);
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                session.Product.Update(promodel);
                                            }
                                        }
                                        if (promodel.inventory != 0)
                                        {
                                            promodel.inventory = promodel.inventory - model.Num;
                                            if (promodel.inventory > 0)
                                            {
                                                promodel.status = 1;
                                            }
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                session.Product.Update(promodel);
                                            }
                                        }
                                        else
                                        {
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                session.Product.Update(promodel);
                                            }
                                        }
                                        //退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                                        AdminPage.intoorder(ordermodel.Id, -model.Num, 3, promodel.id, ordermodel.User_id, model.result, 1);
                                    }
                                    #endregion

                                    #region 如果启动的报警开关，同时项目处于报警的状态，那么给管理员发送短信
                                    if (Helper.GetString(mTeam.warmobile, "") != "")
                                    {
                                        if (mTeam.open_war == 1)//开启库存报警功能
                                        {
                                            if (Utilys.IsWar(mTeam))
                                            {
                                                List<string> phone = new List<string>();
                                                phone.Add(mTeam.warmobile);
                                                //库存提醒
                                                NameValueCollection values = new NameValueCollection();
                                                values.Add("项目编号", mTeam.Id.ToString());
                                                string message = BasePage.ReplaceStr("inventory", values);
                                                SendSMS(phone, message);
                                            }
                                        }
                                    }
                                    #endregion

                                }
                                int Min_number = mTeam.Min_number;
                                int Max_number = mTeam.Max_number;
                                int Now_number = mTeam.Now_number;

                                //修改项目卖光时间
                                int inventory = mTeam.inventory;
                                if (mTeam.open_invent == 1)
                                {
                                    if (inventory == 0)
                                    {
                                        if (mTeam.Close_time == null || mTeam.Close_time.ToString() == "")
                                        {
                                            ITeam itm = Store.CreateTeam();
                                            itm.Close_time = DateTime.Now;
                                            itm.Id = model.Teamid;
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                session.Teams.UpdateCloseTime(itm);
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    if (Now_number >= Max_number && Max_number != 0)
                                    {
                                        if (mTeam.Close_time == null || mTeam.Close_time.ToString() == "")
                                        {
                                            ITeam itm = Store.CreateTeam();
                                            itm.Close_time = DateTime.Now;
                                            itm.Id = model.Teamid;
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                session.Teams.UpdateCloseTime(itm);
                                            }
                                        }
                                    }

                                }

                                if (Now_number >= Min_number)
                                {
                                    if (mTeam.Reach_time == null || mTeam.Reach_time.ToString() == "")
                                    {
                                        ITeam itm = Store.CreateTeam();
                                        itm.Reach_time = DateTime.Now;
                                        itm.Id = model.Teamid;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Teams.UpdateReachTime(itm);
                                        }
                                    }
                                }

                                //记录积分值
                                if (ordermodel.totalscore == 0)//如果是积分项目的订单，那么就不需要更新用户的积分，和订单的积分数 花费积分为0代表不是积分订单
                                {
                                    int score = mTeam.score;
                                    //非货到付款项目
                                    if (ordermodel.Service != "cashondelivery")
                                    {
                                        usermodel.userscore = usermodel.userscore + (score * model.Num);
                                    }
                                    //当前返还的积分数
                                    ordermodel.orderscore += score * model.Num;

                                    //保存所打折扣 折扣值正常应在1-0.01之间。
                                    ordermodel.discount = Helper.GetInt((ActionHelper.GetUserLevelMoney(usermodel.totalamount) / 100).ToString(), 0);
                                }
                            }
                            //非货到付款项目
                            if (ordermodel.totalscore != 0 && ordermodel.Service != "cashondelivery")
                            {
                                usermodel.userscore = usermodel.userscore - ordermodel.totalscore;
                            }
                        }
                        #endregion
                    }
                    else
                    {
                        #region 优惠卷项目处理
                        //str[0]项目订单号，str[1]用户编号，str[2]订单号
                        updatebyorder(orderid, amt, credit, ordermodel.Pay_id, service, "pay");
                        if (mTeam.Delivery == "pcoupon") //如果项目是商户优惠券，那么发送商户的优惠券，如果不是，那么发送系统生成的优惠券
                        {
                            GetPCoupon(ordermodel.Team_id, Convert.ToInt32(ordermodel.Quantity), ordermodel.User_id, orderid);
                        }
                        else
                        {
                            GetCoupon(ordermodel.Team_id, Convert.ToInt32(ordermodel.Quantity), ordermodel.User_id, orderid);
                        }
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            mTeam = session.Teams.GetByID(ordermodel.Team_id);
                        }
                        int Min_number = mTeam.Min_number;
                        int Max_number = mTeam.Max_number;
                        int Now_number = mTeam.Now_number;


                        if (mTeam != null)
                        {
                            if (mTeam.open_invent == 1)//开启库存功能
                            {
                                //下单出库，同时修改项目的库存数量

                                if (ordermodel.result != "")
                                {
                                    //mTeam.Invent_result=Utility.Getrule(model.Result, mTeam.Invent_result,1,1);
                                    mTeam.invent_result = Utility.GetOrderrule(ordermodel.result, mTeam.invent_result, 0);

                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        session.Teams.Update(mTeam);
                                    }
                                }
                                //下单出库，同时修改项目的库存数量
                                if (mTeam.inventory != 0)
                                {
                                    mTeam.inventory = mTeam.inventory - ordermodel.Quantity;
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        session.Teams.Update(mTeam);
                                    }
                                }
                                //inventorylog添加记录,1管理员入库 2管理员出库 3下单出库 4下单入库
                                AdminPage.intoorder(ordermodel.Id, -ordermodel.Quantity, 3, ordermodel.Team_id, ordermodel.User_id, ordermodel.result, 0);
                                //处理产品库存
                                IProduct promodel = null;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    promodel = session.Product.GetByID(mTeam.productid);
                                }
                                if (promodel != null)
                                {
                                    if (ordermodel.result != "")
                                    {

                                        promodel.invent_result = Utility.GetOrderrule(ordermodel.result, promodel.invent_result, 0);

                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Product.Update(promodel);
                                        }
                                    }
                                    if (promodel.inventory != 0)
                                    {
                                        promodel.inventory = promodel.inventory - ordermodel.Quantity;
                                        if (promodel.inventory > 0)
                                        {
                                            promodel.status = 1;
                                        }
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Product.Update(promodel);
                                        }
                                    }
                                    else
                                    {
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Product.Update(promodel);
                                        }
                                    }
                                    //退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                                    AdminPage.intoorder(ordermodel.Id, -ordermodel.Quantity, 3, promodel.id, ordermodel.User_id, ordermodel.result, 1);
                                }

                            }



                            //修改项目卖光时间
                            int inventory = mTeam.inventory;
                            if (mTeam.open_invent == 1)
                            {
                                if (inventory == 0)
                                {
                                    if (mTeam.Close_time == null || mTeam.Close_time.ToString() == "")
                                    {
                                        ITeam itm = Store.CreateTeam();
                                        itm.Close_time = DateTime.Now;
                                        itm.Id = ordermodel.Team_id;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Teams.UpdateCloseTime(itm);
                                        }
                                    }
                                }
                            }
                            else
                            {
                                if (Now_number >= Max_number && Max_number != 0)
                                {
                                    if (mTeam.Close_time == null || mTeam.Close_time.ToString() == "")
                                    {
                                        ITeam itm = Store.CreateTeam();
                                        itm.Close_time = DateTime.Now;
                                        itm.Id = ordermodel.Team_id;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Teams.UpdateCloseTime(itm);
                                        }
                                    }
                                }

                            }

                            if (Now_number >= Min_number)
                            {
                                if (mTeam.Reach_time == null || mTeam.Reach_time.ToString() == "")
                                {
                                    ITeam itm = Store.CreateTeam();
                                    itm.Reach_time = DateTime.Now;
                                    itm.Id = ordermodel.Team_id;
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        session.Teams.UpdateReachTime(itm);
                                    }
                                }
                            }

                            #region 如果启动的报警开关，同时项目处于报警的状态，那么给管理员发送短信
                            if (Helper.GetString(mTeam.warmobile, "") != "")
                            {
                                if (mTeam.open_war == 1)//开启库存报警功能
                                {
                                    if (Utilys.IsWar(mTeam))
                                    {
                                        List<string> phone = new List<string>();
                                        phone.Add(mTeam.warmobile);

                                        //库存提醒
                                        NameValueCollection values = new NameValueCollection();
                                        values.Add("项目编号", mTeam.Id.ToString());



                                        string message = BasePage.ReplaceStr("inventory", values);
                                        SendSMS(phone, message);
                                    }
                                }
                            }
                            #endregion
                        }

                        //记录积分值
                        if (ordermodel.totalscore == 0)//如果是积分项目的订单，那么就不需要更新用户的积分，和订单的积分数 花费积分为0代表不是积分订单
                        {

                            int score = mTeam.score;

                            if (ordermodel.Service != "cashondelivery")
                            {
                                usermodel.userscore = usermodel.userscore + (score * ordermodel.Quantity);
                            }
                            //当前返还的积分数
                            ordermodel.orderscore = score * ordermodel.Quantity;

                            //保存所打折扣 折扣值正常应在1-0.01之间。
                            ordermodel.discount = Helper.GetInt(ActionHelper.GetUserLevelMoney(usermodel.totalamount) / 100, 0);
                        }

                        #endregion
                    }
                    ordermodel.Admin_id = adminid;
                    usermodel.Newbie = "C";
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        session.Users.Update(usermodel);//更新用户表
                        session.Orders.Update(ordermodel);//更新订单表
                    }
                    if (ordermodel.totalscore == 0)//区分积分项目 花费积分为0代表不是积分订单
                    {
                        updatebyorder(orderid, amt, credit, payid, service, "pay");
                    }
                    else
                    {
                        updatebyorder(orderid, amt, credit, payid, service, "scorepay");
                    }

                    #region 如果项目是抽奖项目，那么生成抽奖号码
                    if (mTeam != null)
                    {
                        if (mTeam.Delivery == "draw")
                        {
                            AddDraw(ordermodel.Team_id, ordermodel.User_id, ordermodel.Id);
                        }
                    }
                    #endregion
                    //订单付款成功发短信
                    OrderpaySms(ordermodel.Id, _system);

                    #region 用户付款成功后，根据项目所属商家进行订单拆分
                    //判断是否启用了订单拆分功能
                    if (_system["opensplitorder"] == "1" && _system["closeshopcar"] == "0")
                    {
                        //订单
                        IOrder orderOld = null;
                        IOrder orderNew = Store.CreateOrder();
                        //项目
                        ITeam teamOld = null;
                        ITeam teamNew = null;
                        //判断这个订单是否走购物车并且Team_Id是否为0
                        if (ordermodel.Express == "Y" && ordermodel.Team_id == 0)
                        {
                            using (IDataSession session=Store.OpenSession(false))
                            {
                                orderOld = session.Orders.GetByID(ordermodel.Id);
                            }
                            //根据Order_Id查询orderdetail表
                            IList<IOrderDetail> ds = null;
                            ds = orderOld.OrderDetail;
                            //根据Order_Id查询商家，以确定是否需要拆分
                            IList<System.Collections.Hashtable> dss = null;
                            OrderDetailFilter ordetailfilters = new OrderDetailFilter();
                            ordetailfilters.orderdetail_orderid = orderOld.Id;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                dss = session.OrderDetail.GetPartnerNum(ordetailfilters);
                            }
                            //判断详情表中的数据行数是否大于1
                            if (ds != null && ds.Count > 1)
                            {
                                #region 判断商家的个数是否大于1
                                if (dss != null && dss.Count > 1)
                                {
                                    //根据Order_Id查询需要拆分订单的详细信息
                                    //订单详情
                                    IOrderDetail orderDetailOld = null;
                                    IOrderDetail orderDetailNew = null;

                                    //用户打折率
                                    decimal discount = Convert.ToDecimal(ActionHelper.GetUserLevelMoney(usermodel.totalamount - (orderOld.Origin - orderOld.Fare)));

                                    //将商户id以及订单id存储到dsPartner中
                                    DataTable dtPartner = new DataTable();
                                    DataRow dr;
                                    dtPartner.Columns.Add("Partner");
                                    dtPartner.Columns.Add("OrderId");

                                    #region 根据订单详情表数据行数进行for循环
                                    foreach (IOrderDetail iordetailInfo in ds)
                                    {
                                        //获取订单详细信息表中的id
                                        int id = iordetailInfo.id;
                                        //根据TeamId查询对应项目
                                        teamNew = iordetailInfo.Team;
                                        //根据Id查询订单详细表中数据
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            orderDetailNew = session.OrderDetail.GetByID(id);
                                        }
                                        if (dtPartner.Rows.Count >= 1)
                                        {
                                            string str = "";
                                            if (teamNew != null)
                                                 str = "Partner=" + teamNew.Partner_id + "";
                                            DataRow[] drw = dtPartner.Select(str);
                                            if (drw.Length < 1)
                                            {
                                                #region 增加数据
                                                orderNew.Card_id = orderDetailNew.carno;//代金券号
                                                orderNew.Card = orderDetailNew.Credit;//代金券费
                                                orderNew.Price = orderDetailNew.Teamprice;//商品单价
                                                orderNew.Quantity = orderDetailNew.Num;//数量
                                                if (orderNew.disamount != 0)
                                                {
                                                    orderNew.Origin = orderDetailNew.Num * orderDetailNew.Teamprice * discount + orderDetailNew.Team.Fare - jian;//总款 
                                                    if (orderNew.Origin < 0)
                                                    {
                                                        orderNew.disamount = -orderNew.Origin;
                                                        orderNew.Origin = 0;
                                                    }

                                                }
                                                else
                                                {
                                                    orderNew.Origin = orderDetailNew.Num * orderDetailNew.Teamprice * discount+orderDetailNew.Team.Fare;//总款  
                                                }

                                                //非货到付款项目
                                                if (orderOld.Service != "cashondelivery")
                                                {
                                                    //当原始订单中余额付款大于或等于拆分出订单中总款时
                                                    if (orderOld.Credit > 0 && orderOld.Credit >= orderNew.Origin)
                                                    {
                                                        orderNew.Credit = orderNew.Origin;//在线支付费用
                                                        orderNew.Money = 0;
                                                    }
                                                    //当原始订单中余额付款小于拆分出订单中总款时
                                                    else if (orderOld.Credit > 0 && orderOld.Credit < orderNew.Origin)
                                                    {
                                                        orderNew.Credit = orderOld.Credit;
                                                        orderNew.Money = orderNew.Origin - orderNew.Credit;
                                                    }
                                                    else
                                                    {
                                                        orderNew.Credit = 0;
                                                        orderNew.Money = orderNew.Origin;
                                                    }
                                                }
                                                //货到付款
                                                else if (orderOld.Service == "cashondelivery")
                                                {
                                                    //当原始订单中余额付款大于或等于拆分出订单中总款时
                                                    if (orderOld.Credit > 0 && orderOld.Credit >= orderNew.Origin)
                                                    {
                                                        orderNew.Credit = orderNew.Origin;//在线支付费用
                                                        orderNew.cashondelivery = 0;
                                                    }
                                                    //当原始订单中余额付款小于拆分出订单中总款时
                                                    else if (orderOld.Credit > 0 && orderOld.Credit < orderNew.Origin)
                                                    {
                                                        orderNew.Credit = orderOld.Credit;
                                                        orderNew.cashondelivery = orderNew.Origin - orderNew.Credit;
                                                    }
                                                    else
                                                    {
                                                        orderNew.Credit = 0;
                                                        orderNew.cashondelivery = orderNew.Origin;
                                                    }
                                                }
                                                orderNew.disamount = 0;
                                                orderNew.disinfo = "";
                                                orderNew.result = orderDetailNew.result;//产品规格
                                                orderNew.Fare = orderDetailNew.Team.Fare; //快递费
                                                orderNew.orderscore = orderDetailNew.Num * teamNew.score;//订单返还积分数
                                                orderNew.Parent_orderid = orderOld.Id; //父订单号
                                                orderNew.Partner_id = teamNew.Partner_id; //商户id
                                                int orderId = 0; //获取添加后得id
                                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                {
                                                    orderId = session.Orders.Insert(orderNew);
                                                }
                                                //修改拆分出订单的详细信息表
                                                orderDetailNew.Order_id = orderId;
                                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                {
                                                    session.OrderDetail.Update(orderDetailNew);
                                                }
                                                //修改原始订单
                                                orderOld.Money = orderOld.Money - orderNew.Money;
                                                orderOld.cashondelivery = orderOld.cashondelivery - orderNew.cashondelivery;
                                                orderOld.Origin = orderOld.Origin - orderNew.Origin;
                                                orderOld.Credit = orderOld.Credit - orderNew.Credit;

                                                //添加到dtPartner中
                                                dr = dtPartner.NewRow();
                                                dr["Partner"] = teamNew.Partner_id;
                                                dr["OrderId"] = orderId;
                                                dtPartner.Rows.Add(dr);
                                                #endregion
                                            }
                                            else
                                            {
                                                for (int i = 0; i < dtPartner.Rows.Count; i++)
                                                {
                                                    if (teamNew.Partner_id.ToString() == dtPartner.Rows[i]["Partner"].ToString())
                                                    {
                                                        #region 修改数据
                                                        int orderId = Convert.ToInt32(dtPartner.Rows[i]["OrderId"]);
                                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                        {
                                                            orderNew = session.Orders.GetByID(orderId);
                                                        }
                                                        //orderNew.Team_id = 0;//项目id
                                                        orderNew.Card_id = "";//代金券号
                                                        orderNew.Card = orderNew.Card + orderDetailNew.Credit;//代金券费
                                                        orderNew.Quantity = orderNew.Quantity + orderDetailNew.Num;//数量
                                                        orderNew.Price = 0;//商品单价

                                                        decimal newOrigin = orderDetailNew.Num * orderDetailNew.Teamprice * discount + orderDetailNew.Team.Fare;//新费用
                                                        orderNew.Origin = orderNew.Origin + newOrigin;//总款                                     

                                                        //非货到付款
                                                        if (orderOld.Service != "cashondelivery")
                                                        {
                                                            //当原始订单中余额付款大于或等于拆分出订单中总款时
                                                            if (orderOld.Credit > 0 && orderOld.Credit >= newOrigin)
                                                            {
                                                                orderNew.Credit = orderNew.Credit + newOrigin;//在线支付费用
                                                                orderNew.Money = 0;

                                                                //修改原始订单
                                                                orderOld.Money = orderOld.Money;
                                                                orderOld.Origin = orderOld.Origin - newOrigin;
                                                                orderOld.Credit = orderOld.Credit - newOrigin;
                                                            }
                                                            //当原始订单中余额付款小于拆分出订单中总款时
                                                            else if (orderOld.Credit > 0 && orderOld.Credit < newOrigin)
                                                            {
                                                                orderNew.Credit = orderNew.Credit + orderOld.Credit;
                                                                orderNew.Money = orderNew.Money + (newOrigin - orderOld.Credit);

                                                                //修改原始订单
                                                                orderOld.Money = orderOld.Money - (newOrigin - orderOld.Credit);
                                                                orderOld.Origin = orderOld.Origin - newOrigin;
                                                                orderOld.Credit = 0;
                                                            }
                                                            else
                                                            {
                                                                orderNew.Credit = orderNew.Credit;
                                                                orderNew.Money = orderNew.Money + newOrigin;

                                                                //修改原始订单
                                                                orderOld.Credit = 0;
                                                                orderOld.Origin = orderOld.Origin - newOrigin;
                                                                orderOld.Money = orderOld.Money - newOrigin;
                                                            }
                                                        }
                                                        //货到付款
                                                        else if (orderOld.Service == "cashondelivery")
                                                        {
                                                            //当原始订单中余额付款大于或等于拆分出订单中总款时
                                                            if (orderOld.Credit > 0 && orderOld.Credit >= newOrigin)
                                                            {
                                                                orderNew.Credit = orderNew.Credit + newOrigin;//在线支付费用
                                                                orderNew.cashondelivery = 0;

                                                                //修改原始订单
                                                                orderOld.cashondelivery = orderOld.cashondelivery;
                                                                orderOld.Origin = orderOld.Origin - newOrigin;
                                                                orderOld.Credit = orderOld.Credit - newOrigin;
                                                            }
                                                            //当原始订单中余额付款小于拆分出订单中总款时
                                                            else if (orderOld.Credit > 0 && orderOld.Credit < newOrigin)
                                                            {
                                                                orderNew.Credit = orderNew.Credit + orderOld.Credit;
                                                                orderNew.cashondelivery = orderNew.cashondelivery + (newOrigin - orderOld.Credit);

                                                                //修改原始订单
                                                                orderOld.cashondelivery = orderOld.cashondelivery - (newOrigin - orderOld.Credit);
                                                                orderOld.Origin = orderOld.Origin - newOrigin;
                                                                orderOld.Credit = 0;
                                                            }
                                                            else
                                                            {
                                                                orderNew.Credit = orderNew.Credit;
                                                                orderNew.cashondelivery = orderNew.cashondelivery + newOrigin;

                                                                //修改原始订单
                                                                orderOld.Credit = 0;
                                                                orderOld.Origin = orderOld.Origin - newOrigin;
                                                                orderOld.cashondelivery = orderOld.cashondelivery - newOrigin;
                                                            }
                                                        }
                                                        orderNew.Fare = orderDetailNew.Team.Fare;
                                                        orderNew.result = "";//产品规格
                                                        orderNew.Partner_id = orderNew.Partner_id;//商户id
                                                        orderNew.Parent_orderid = orderNew.Parent_orderid;//父订单号
                                                        orderNew.orderscore = orderNew.orderscore + (orderDetailNew.Num * teamNew.score);//订单返还积分数
                                                        orderNew.totalscore = orderNew.totalscore + orderDetailNew.totalscore;
                                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                        {
                                                            session.Orders.Update(orderNew);
                                                        }

                                                        //修改拆分出订单的详细信息表
                                                        orderDetailNew.Order_id = orderId;
                                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                        {
                                                            session.OrderDetail.Update(orderDetailNew);
                                                        }
                                                        break;
                                                        #endregion
                                                    }
                                                }
                                            }
                                        }
                                        else
                                        {
                                            #region 第一条数据 修改原始数据
                                            orderNew = WebUtils.GetObjectClone<IOrder>(orderOld);
                                            orderNew.Origin = orderDetailNew.Num * orderDetailNew.Teamprice * discount + orderDetailNew.Team.Fare - orderNew.disamount;//总款（含运费）
                                            orderNew.Fare = orderDetailNew.Team.Fare;//运费
                                            orderNew.Card_id = orderDetailNew.carno;//代金券号
                                            orderNew.Card = orderDetailNew.Credit;//代金券费
                                            orderNew.Quantity = orderDetailNew.Num;//数量
                                            orderNew.Price = orderDetailNew.Teamprice;//商品单价
                                            orderNew.result = orderDetailNew.result;//产品规格
                                            orderNew.orderscore = orderDetailNew.Num * teamNew.score;//订单返还积分数
                                            orderNew.Parent_orderid = 0; //父订单号
                                            orderNew.Partner_id = teamNew.Partner_id; //商户id
                                            //非货到付款
                                            if (orderOld.Service != "cashondelivery")
                                            {
                                                //当原始订单中余额付款大于或等于第一行订单中总款时
                                                if (orderOld.Credit > 0 && orderOld.Credit >= orderNew.Origin)
                                                {
                                                    orderNew.Credit = orderNew.Origin;//在线支付费用
                                                    orderNew.Money = 0;
                                                }
                                                //当原始订单中余额付款小于第一行订单中总款时
                                                else if (orderOld.Credit > 0 && orderOld.Credit < orderNew.Origin)
                                                {
                                                    orderNew.Credit = orderOld.Credit;
                                                    orderNew.Money = orderNew.Origin - orderNew.Credit;
                                                }
                                                else
                                                {
                                                    orderNew.Credit = 0;
                                                    orderNew.Money = orderNew.Origin;
                                                }
                                            }
                                            //货到付款
                                            else if (orderOld.Service == "cashondelivery")
                                            {
                                                //当原始订单中余额付款大于或等于第一行订单中总款时
                                                if (orderOld.Credit > 0 && orderOld.Credit >= orderNew.Origin)
                                                {
                                                    orderNew.Credit = orderNew.Origin;//在线支付费用
                                                    orderNew.cashondelivery = 0;
                                                }
                                                //当原始订单中余额付款小于第一行订单中总款时
                                                else if (orderOld.Credit > 0 && orderOld.Credit < orderNew.Origin)
                                                {
                                                    orderNew.Credit = orderOld.Credit;
                                                    orderNew.cashondelivery = orderNew.Origin - orderNew.Credit;
                                                }
                                                else
                                                {
                                                    orderNew.Credit = 0;
                                                    orderNew.cashondelivery = orderNew.Origin;
                                                }
                                            }
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                session.Orders.Update(orderNew);
                                            }
                                            //修改原始订单
                                            orderOld.Money = orderOld.Money - orderNew.Money;
                                            orderOld.cashondelivery = orderOld.cashondelivery - orderNew.cashondelivery;
                                            orderOld.Origin = orderOld.Origin - orderNew.Origin;
                                            orderOld.Credit = orderOld.Credit - orderNew.Credit;
                                            orderDetailNew.Order_id = orderOld.Id;
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                session.OrderDetail.Update(orderDetailNew);
                                            }
                                            //添加到dtPartner中
                                            dr = dtPartner.NewRow();
                                            dr["Partner"] = teamNew.Partner_id;
                                            dr["OrderId"] = orderOld.Id;
                                            dtPartner.Rows.Add(dr);
                                            #endregion
                                        }
                                    }
                                    #endregion
                                }
                                #endregion
                                else
                                {
                                    //商家个数等于1
                                    orderOld.Partner_id = Convert.ToInt32(dss[0]["Partner_id"]);
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        session.Orders.Update(orderOld);
                                    }
                                }
                            }
                            else
                            {
                                //详情表中的数据小于或等于1
                                orderOld.Partner_id = Convert.ToInt32(dss[0]["Partner_id"]);
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    session.Orders.Update(orderOld);
                                }
                            }
                        }
                        //走购物车，并且TeamId不为空
                        else if (ordermodel.Express == "Y" && ordermodel.Team_id != 0)
                        {
                            teamOld = ordermodel.Team;
                            if (teamOld != null)
                            {
                                ordermodel.Partner_id = teamOld.Partner_id;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    session.Orders.Update(ordermodel);
                                }
                            }
                        }
                        else
                        {
                            return;
                        }
                    }
                    else
                    {
                        return;
                    }
                    #endregion

                }
                #endregion
            }

        }
        #endregion

        #region 修改订单的支付网关,同时生成交易单号
        public static void Updatebyservice(int orderid, string service, string order, decimal money)
        {
            IOrder ordermodel = null;
            using (IDataSession session = Store.OpenSession(false))
            {
                ordermodel = session.Orders.GetByID(orderid);
            }
            if (ordermodel != null)
            {
                ordermodel.Service = service;
                ordermodel.Pay_id = order;
                ordermodel.Origin = money;
                ordermodel.Id = ordermodel.Id;
                using (IDataSession session = Store.OpenSession(false))
                {
                    session.Orders.Update(ordermodel);
                }
            }
        }
        #endregion

        #region 生成交易单号 项目IDas用户IDas订单IDasHHMMSS （如果该订单存在交易单号则返回之前单号，如果不存在则重新生成）
        public static string Getorder(int userid, int temaid, int orderid)
        {
            IOrder ordermodel = Store.CreateOrder();
            using (IDataSession session = Store.OpenSession(false))
            {
                ordermodel = session.Orders.GetByID(orderid);
            }
            string ordercode = temaid + "as" + userid + "as" + orderid + "as" + DateTime.Now.ToString("hhmmss");
            if (ordermodel != null)
            {
                if (ordermodel.Pay_id != null && ordermodel.Pay_id.Length > 0)
                {
                    return ordermodel.Pay_id;
                }
                else
                {
                    if (GetOrderid(ordercode))
                    {
                        Getorder(userid, temaid, orderid);
                    }
                    else
                    {
                        return ordercode;
                    }
                }
            }
            return ordercode;
        }
        #endregion

        #region 总价减去用户余额，显示用户应该缴纳的钱数
        public static decimal Getyumoney(decimal yumoney, decimal summoney)
        {
            return summoney - yumoney;
        }
        #endregion

        #region 判断是否存在交易单号
        public static bool GetOrderid(string payid)
        {
            bool isok = false;
            IList<IOrder> list = null;
            OrderFilter of = new OrderFilter();
            of.Pay_id = payid;
            using (IDataSession session = Store.OpenSession(false))
            {
                list = session.Orders.GetList(of);
            }
            if (list != null && list.Count > 0)
                isok = true;
            return isok;
        }
        #endregion

        #region 从促销规则中获取是否免运费
        public static bool GetIsFreeFare(decimal totalprice)
        {
            bool isok = false;
            IList<ISales_promotion> sallist = null;
            Sales_promotionFilter salespfilter = new Sales_promotionFilter();
            salespfilter.end_time = DateTime.Now;
            salespfilter.Tostart_time = DateTime.Now;
            salespfilter.enable = 1;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                sallist = session.Sales_promotion.GetList(salespfilter);
            }
            foreach (ISales_promotion sale_pro in sallist)
            {
                IList<IPromotion_rules> prolist = null;
                Promotion_rulesFilter prulesfilter = new Promotion_rulesFilter();
                prulesfilter.Tostart_time = DateTime.Now;
                prulesfilter.Fromend_time = DateTime.Now;
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
                        if (totalprice > promotion_rules.full_money)
                        {
                            isok = true;
                        }
                    }
                }
            }
            return isok;
        }
        #endregion

        #region 更新订单促销规则
        public static void GetCuXiao(decimal atm,IOrder ordermodel)
        {
            if (ordermodel == null) return;
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
            string disinfoid = String.Empty;
            foreach (ISales_promotion sale_pro in sallist)
            {
                IList<IPromotion_rules> prolist = null;
                Promotion_rulesFilter prulesfilter = new Promotion_rulesFilter();
                prulesfilter.Tostart_time = DateTime.Now;
                prulesfilter.Fromend_time = DateTime.Now;
                prulesfilter.Tofull_money = atm;
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
                    disinfoid = disinfoid + promotion_rules.id + "|";
                }
            }
            if (jian != 0)
            {
                ordermodel.disamount = jian;
            }
            if (disinfoid != String.Empty)
                ordermodel.disinfo = disinfoid;
            if (fan != 0)
                ordermodel.Returnmoney = fan;
            if (disinfoid != String.Empty & jian != 0 && fan != 0)
            {
                using (IDataSession session = Store.OpenSession(false))
                {
                    session.Orders.Update(ordermodel);
                }
            }
        }
        #endregion

        #region 积分消费记录表
        public static string Insert_scorelog(int score, string action, string orderid, int adminid, int userid)
        {
            string result = string.Empty;
            int cnt = 0;
            IScorelog scorelog = Store.CreateScorelog();
            scorelog.score = score;
            scorelog.action = action;
            scorelog.create_time = DateTime.Now;
            scorelog.adminid = adminid;
            scorelog.user_id = userid;
            scorelog.key = orderid;

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                cnt = session.Scorelog.Insert(scorelog);
            }

            if (cnt > 0)
            {
                result = "success";
            }
            else
            {
                result = "error";
            }
            return result;
        }
        #endregion

        #region 根据项目编号，更新已购买的数量
        public static void UpdateNumber(int teamid, int num)
        {
            ITeam teammodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teammodel = session.Teams.GetByID(teamid);
            }

            if (teammodel.Conduser == "Y")//以购买人数成团为标志
            {

                teammodel.Now_number = teammodel.Now_number + 1;
            }
            else if (teammodel.Conduser == "N")//以产品购买数量成团
            {

                teammodel.Now_number = teammodel.Now_number + num;
            }

            #region 查看项目是否达到了团购人数，如果达到了，那么修改项目的状态,修改当前购买人数
            if (istuan(Convert.ToInt32(teammodel.Now_number.ToString()), Convert.ToInt32(teammodel.Min_number)))
            {
                if (teammodel.Conduser == "Y")//以购买人数成团为标志
                {

                    teammodel.State = "success";
                    //teammodel.Now_number = teammodel.Now_number + 1;
                }
                else if (teammodel.Conduser == "N")//以产品购买数量成团
                {

                    teammodel.State = "success";
                    //teammodel.Now_number = teammodel.Now_number + num;
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Teams.Update(teammodel);
                }
            }
            else
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Teams.Update(teammodel);
                }
            }
            #endregion


        }
        #endregion

        #region 判断项目的团购人是否达到标准，
        public static bool istuan(int now_number, int min_number)
        {
            bool falg = false;
            if (now_number >= min_number)
            {
                falg = true;
            }
            else
            {
                falg = false;
            }
            return falg;
        }
        #endregion

        #region 发送短信
        public static bool SendSMS(List<string> mobiles, string content)
        {
            bool ok = false;
            ISystem sysmodel = GetModelByCache(1);
            WebUtils.LogWrite("message", content);
            if (sysmodel.smsuser == String.Empty || sysmodel.smspass == String.Empty) return false;
            if (mobiles.Count>0)
                ok = ChinaNetSMSWraper.SendSMS(mobiles, content);
                //ok = EmailMethod.SendSms(sysmodel.smsuser, sysmodel.smspass, mobile, content);
            return ok;
        }
        #endregion

        #region 得到一个对象实体，从缓存中。
        /// <summary>
        /// 得到一个对象实体，从缓存中。
        /// </summary>
        public static ISystem GetModelByCache(int Id)
        {

            string CacheKey = "SystemModel-" + Id;
            object objModel = LTP.Common.DataCache.GetCache(CacheKey);
            if (objModel == null)
            {
                try
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        objModel = session.System.GetByID(Id);
                    }
                    if (objModel != null)
                    {
                        int ModelCache = LTP.Common.ConfigHelper.GetConfigInt("ModelCache");
                        LTP.Common.DataCache.SetCache(CacheKey, objModel, DateTime.Now.AddMinutes(ModelCache), TimeSpan.Zero);
                    }
                }
                catch { }
            }
            return (ISystem)objModel;
        }
        #endregion

        #region 修改订单的状态
        public static void updatebyorder(int order_id, decimal money, decimal credit, string pay_id, string service, string pay)
        {
            if (service == "cashondelivery")
            {
                IOrder iorder = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iorder = session.Orders.GetByID(order_id);
                }
                iorder.State = "nocod";
                iorder.cashondelivery = money;
                iorder.Credit = credit;
                iorder.Pay_id = pay_id;
                iorder.Service = service;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Orders.Update(iorder);
                }
            }
            else
            {
                IOrder iorder = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iorder = session.Orders.GetByID(order_id);
                }
                iorder.State = pay;
                iorder.Money = money;
                iorder.Credit = credit;
                iorder.Pay_time = DateTime.Now;
                iorder.Pay_id = pay_id;
                iorder.Service = service;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Orders.Update(iorder);
                }
            }
        }
        #endregion

        #region 用户获取商户优惠券
        public static void GetPCoupon(int teamid, int num, int userid, int orderid)
        {
            ITeam teammodel = null;
            IPcoupon pcoumodel = null;
            ISystem sysmodels = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                sysmodels = session.System.GetByID(1);
            }
            NameValueCollection _system = new NameValueCollection();
            _system = WebUtils.GetSystem();

            //查询项目下面成功的订单
            IList<IOrder> orderlist = null;
            OrderFilter orderfilter = new OrderFilter();
            orderfilter.Team_id = teamid;
            orderfilter.State = "pay";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                orderlist = session.Orders.GetList(orderfilter);
            }

            IList<IPcoupon> pcoulist = null;
            //List<Maticsoft.Model.pcoupon> pcoulist = new List<Model.pcoupon>();


            //更新已购买的人数
            UpdateNumber(teamid, num);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teammodel = session.Teams.GetByID(teamid);
            }

            #region 第一步
            if (isConpon(teamid, "pcoupon")) //查询项目里面是否优惠券，如果是，那么给用户插入优惠券记录
            {
                #region 第二步 查看项目是否达到了团购人数，如果达到了，那么发优惠券
                if (istuan(Convert.ToInt32(teammodel.Now_number.ToString()), Convert.ToInt32(teammodel.Min_number)))
                {
                    //查询此项目在优惠券中是否有记录，如果没有，那么在项目团购成功是，给之前在这个项目下单且成功的用户发优惠券，如果有，那么说明项目在优惠券中有记录，说明在这个用户之前下订单的用户已经发了优惠券，跳过
                    // coupmodel = coupbll.GetCouponTeamid(teamid);
                    if (GetPCouponTeamid(teamid) == false)
                    {
                        #region
                        if (orderlist.Count > 0)
                        {
                            string tuanphone = "";
                            if (sysmodels != null && !String.IsNullOrEmpty(sysmodels.tuanphone))
                            {
                                tuanphone = sysmodels.tuanphone;
                            }
                            #region
                            foreach (IOrder order in orderlist)
                            {
                                #region 第四步，订单的数量 c//如果下的订单里面有产品有n个，那么优惠券也是n个

                                PcouponFilter pcouponfilter = new PcouponFilter();
                                pcouponfilter.teamid = teamid;
                                pcouponfilter.state = "nobuy";
                                pcouponfilter.Top = order.Quantity;

                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    pcoulist = session.Pcoupon.GetList(pcouponfilter);
                                }
                                //**********此处做了修改【优惠券:一个劵号多个密码，生成一条短信】--drl--【2013/04/02】**************开始//
                                #region
                                if (_system["couponPattern"] == "1")//一对多
                                {
                                    string strcouponCode = "";
                                    foreach (IPcoupon model in pcoulist)
                                    {
                                        #region 修改商户优惠券的信息
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            pcoumodel = session.Pcoupon.GetByID(model.id);
                                        }
                                        strcouponCode = strcouponCode + model.number + "|";
                                        pcoumodel.teamid = order.Team_id;
                                        if (teammodel != null)
                                        {
                                            pcoumodel.start_time = teammodel.start_time;
                                        }
                                        pcoumodel.orderid = order.Id;


                                        //coupmodel.Credit = teambll.GetModel(order.Team_id).Credit; //teammodel.Credit;

                                        pcoumodel.userid = order.User_id;
                                        pcoumodel.create_time = DateTime.Now;
                                        pcoumodel.expire_time = teammodel.Expire_time;
                                        pcoumodel.partnerid = teammodel.Partner_id;
                                        pcoumodel.id = model.id;
                                        pcoumodel.number = model.number;
                                        pcoumodel.state = "buy";//购买的状态
                                        pcoumodel.buy_time = DateTime.Now;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Pcoupon.Update(pcoumodel);
                                        }
                                        #endregion
                                    }
                                    #region 发送短信
                                    ISystem sysmodel = GetModelByCache(1);
                                    List<string> phone = new List<string>();
                                    string tuangou = "";
                                    if (sysmodel != null)
                                    {
                                        tuangou = sysmodel.abbreviation;
                                    }

                                    if (order.Mobile != "")
                                    {
                                        phone.Add(order.Mobile);
                                    }
                                    else
                                    {
                                        IUser ius = null;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            ius = session.Users.GetByID(order.User_id);
                                        }
                                        if (ius != null)
                                        {
                                            phone.Add(ius.Mobile);
                                        }
                                    }
                                    string partnername = "";
                                    string partnermobile = "";
                                    if (teammodel.Partner != null)
                                    {
                                        partnername = teammodel.Partner.Title;
                                        partnermobile = teammodel.Partner.Phone;
                                    }


                                    //站外优惠券信息
                                    NameValueCollection values = new NameValueCollection();
                                    values.Add("网站简称", tuangou);
                                    values.Add("商品名称", teammodel.Product);
                                    values.Add("商户优惠券", strcouponCode.Substring(0,strcouponCode.Length-1));

                                    values.Add("优惠券开始时间", pcoumodel.start_time.Value.ToString("yyyy年MM月dd日"));
                                    values.Add("优惠券结束时间", pcoumodel.expire_time.ToString("yyyy年MM月dd日"));
                                    values.Add("商户名称", partnername);
                                    values.Add("商户电话", partnermobile);
                                    values.Add("团购电话", tuanphone);
                                    string message = BasePage.ReplaceStr("bizcouponsms", values);

                                    string txt = message;
                                    SendSMS(phone, txt);
                                    #endregion
                                }
                                else
                                {
                                    foreach (IPcoupon model in pcoulist)
                                    {
                                        #region 修改商户优惠券的信息
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            pcoumodel = session.Pcoupon.GetByID(model.id);
                                        }
                                        pcoumodel.teamid = order.Team_id;
                                        if (teammodel != null)
                                        {
                                            pcoumodel.start_time = teammodel.start_time;
                                        }
                                        pcoumodel.orderid = order.Id;


                                        //coupmodel.Credit = teambll.GetModel(order.Team_id).Credit; //teammodel.Credit;

                                        pcoumodel.userid = order.User_id;
                                        pcoumodel.create_time = DateTime.Now;
                                        pcoumodel.expire_time = teammodel.Expire_time;
                                        pcoumodel.partnerid = teammodel.Partner_id;
                                        pcoumodel.id = model.id;
                                        pcoumodel.number = model.number;
                                        pcoumodel.state = "buy";//购买的状态
                                        pcoumodel.buy_time = DateTime.Now;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Pcoupon.Update(pcoumodel);
                                        }
                                        #endregion


                                        #region 发送短信
                                        ISystem sysmodel = GetModelByCache(1);
                                        List<string> phone = new List<string>();
                                        string tuangou = "";
                                        if (sysmodel != null)
                                        {
                                            tuangou = sysmodel.abbreviation;
                                        }

                                        if (order.Mobile != "")
                                        {
                                            phone.Add(order.Mobile);
                                        }
                                        else
                                        {
                                            IUser ius = null;
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                ius = session.Users.GetByID(order.User_id);
                                            }
                                            if (ius != null)
                                            {
                                                phone.Add(ius.Mobile);
                                            }
                                        }
                                        string partnername = "";
                                        string partnermobile = "";
                                        if (teammodel.Partner != null)
                                        {
                                            partnername = teammodel.Partner.Title;
                                            partnermobile = teammodel.Partner.Phone;
                                        }


                                        //站外优惠券信息
                                        NameValueCollection values = new NameValueCollection();
                                        values.Add("网站简称", tuangou);
                                        values.Add("商品名称", teammodel.Product);
                                        values.Add("商户优惠券", pcoumodel.number);

                                        values.Add("优惠券开始时间", pcoumodel.start_time.Value.ToString("yyyy年MM月dd日"));
                                        values.Add("优惠券结束时间", pcoumodel.expire_time.ToString("yyyy年MM月dd日"));
                                        values.Add("商户名称", partnername);
                                        values.Add("商户电话", partnermobile);
                                        values.Add("团购电话", tuanphone);
                                        string message = BasePage.ReplaceStr("bizcouponsms", values);

                                        string txt = message;
                                        SendSMS(phone, txt);
                                        #endregion
                                    }
                                    
                                }
                                #endregion
                                //**********此处做了修改【优惠券:一个劵号多个密码，生成一条短信】--drl--【2013/04/02】**************结束//
                                #endregion
                            }
                            #endregion
                        }

                        #endregion
                    }
                    else
                    {
                        #region 如果项目编号，在优惠中有记录，说明团购成功之前用户已经发了优惠券，只执行下面关于当前用户动作
                        PcouponFilter pcouponfilter = new PcouponFilter();
                        pcouponfilter.teamid = teamid;
                        pcouponfilter.state = "nobuy";
                        pcouponfilter.Top = num;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            pcoulist = session.Pcoupon.GetList(pcouponfilter);
                        }
                        //**********此处做了修改【优惠券:一个劵号多个密码，生成一条短信】--drl--【2013/04/02】**************开始//
                        #region
                        if (_system["couponPattern"] == "1")//一对多
                        {
                            string strcouponCode = "";
                            foreach (IPcoupon model in pcoulist)//如果下的订单里面有产品有n个，那么优惠券也是n个
                            {
                                #region 修改商户优惠券的信息
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    pcoumodel = session.Pcoupon.GetByID(model.id);
                                }
                                strcouponCode = strcouponCode + model.number + "|";
                                pcoumodel.teamid = teamid;
                                if (teammodel != null)
                                {
                                    pcoumodel.start_time = teammodel.start_time;
                                }
                                pcoumodel.orderid = orderid;
                                pcoumodel.userid = userid;
                                pcoumodel.create_time = DateTime.Now;
                                pcoumodel.expire_time = teammodel.Expire_time;
                                pcoumodel.partnerid = teammodel.Partner_id;
                                pcoumodel.id = model.id;
                                pcoumodel.state = "buy";//购买的状态
                                pcoumodel.number = model.number;
                                pcoumodel.buy_time = DateTime.Now;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    session.Pcoupon.Update(pcoumodel);
                                }
                                #endregion
                            }
                            #region 发送短信
                            ISystem sysmodel = GetModelByCache(1);
                            List<string> phone = new List<string>();
                            string tuangou = "";
                            string tuanphone = "";
                            if (sysmodel != null)
                            {
                                tuangou = sysmodel.abbreviation;
                                tuanphone = sysmodel.tuanphone;
                            }

                            IOrder ordermodel_new = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                ordermodel_new = session.Orders.GetByID(orderid);
                            }
                            if (ordermodel_new.Mobile != "")
                            {
                                phone.Add(ordermodel_new.Mobile);
                            }
                            else
                            {
                                IUser ius = null;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    ius = session.Users.GetByID(userid);
                                }
                                phone.Add(ius.Mobile);
                            }
                            string partnername = "";
                            string partnermobile = "";
                            if (teammodel.Partner != null)
                            {
                                partnername = teammodel.Partner.Title;
                                partnermobile = teammodel.Partner.Phone;
                            }
                            //站外优惠券信息
                            NameValueCollection values = new NameValueCollection();
                            values.Add("网站简称", tuangou);
                            values.Add("商品名称", teammodel.Product);
                            values.Add("商户优惠券", strcouponCode.Substring(0,strcouponCode.Length-1));
                            values.Add("优惠券开始时间", pcoumodel.start_time.Value.ToString("yyyy年MM月dd日"));
                            values.Add("优惠券结束时间", pcoumodel.expire_time.ToString("yyyy年MM月dd日"));
                            values.Add("商户名称", partnername);
                            values.Add("商户电话", partnermobile);
                            values.Add("团购电话", tuanphone);
                            string message = BasePage.ReplaceStr("bizcouponsms", values);
                            string txt = message;
                            SendSMS(phone, txt);
                            #endregion
                        }
                        else
                        {
                            foreach (IPcoupon model in pcoulist)//如果下的订单里面有产品有n个，那么优惠券也是n个
                            {
                                #region 修改商户优惠券的信息
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    pcoumodel = session.Pcoupon.GetByID(model.id);
                                }
                                pcoumodel.teamid = teamid;
                                if (teammodel != null)
                                {
                                    pcoumodel.start_time = teammodel.start_time;
                                }
                                pcoumodel.orderid = orderid;
                                pcoumodel.userid = userid;
                                pcoumodel.create_time = DateTime.Now;
                                pcoumodel.expire_time = teammodel.Expire_time;
                                pcoumodel.partnerid = teammodel.Partner_id;
                                pcoumodel.id = model.id;
                                pcoumodel.state = "buy";//购买的状态
                                pcoumodel.number = model.number;
                                pcoumodel.buy_time = DateTime.Now;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    session.Pcoupon.Update(pcoumodel);
                                }
                                #endregion


                                #region 发送短信
                                ISystem sysmodel = GetModelByCache(1);
                                List<string> phone = new List<string>();
                                string tuangou = "";
                                string tuanphone = "";
                                if (sysmodel != null)
                                {
                                    tuangou = sysmodel.abbreviation;
                                    tuanphone = sysmodel.tuanphone;
                                }

                                IOrder ordermodel_new = null;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    ordermodel_new = session.Orders.GetByID(orderid);
                                }
                                if (ordermodel_new.Mobile != "")
                                {
                                    phone.Add(ordermodel_new.Mobile);
                                }
                                else
                                {
                                    IUser ius = null;
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        ius = session.Users.GetByID(userid);
                                    }
                                    phone.Add(ius.Mobile);
                                }
                                string partnername = "";
                                string partnermobile = "";
                                if (teammodel.Partner != null)
                                {
                                    partnername = teammodel.Partner.Title;
                                    partnermobile = teammodel.Partner.Phone;
                                }
                                //站外优惠券信息
                                NameValueCollection values = new NameValueCollection();
                                values.Add("网站简称", tuangou);
                                values.Add("商品名称", teammodel.Product);
                                values.Add("商户优惠券", pcoumodel.number);
                                values.Add("优惠券开始时间", pcoumodel.start_time.Value.ToString("yyyy年MM月dd日"));
                                values.Add("优惠券结束时间", pcoumodel.expire_time.ToString("yyyy年MM月dd日"));
                                values.Add("商户名称", partnername);
                                values.Add("商户电话", partnermobile);
                                values.Add("团购电话", tuanphone);
                                string message = BasePage.ReplaceStr("bizcouponsms", values);
                                string txt = message;
                                SendSMS(phone, txt);
                                #endregion
                            }
                        }
                        #endregion
                        //**********此处做了修改【优惠券:一个劵号多个密码，生成一条短信】--drl--【2013/04/02】**************结束//
                        
                        #endregion

                    }
                }
                #endregion
            }
            #endregion

        }
        #endregion

        #region 用户获取优惠券 修改方法之前，请写上自己的姓名+日期
        public static void GetCoupon(int teamid, int num, int userid, int orderid)
        {
            ITeam teammodel = null;
            //查询项目下面成功的订单
            IList<IOrder> orderlist = null;
            OrderFilter orderfilter = new OrderFilter();
            orderfilter.Team_id = teamid;
            orderfilter.State = "pay";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                orderlist = session.Orders.GetList(orderfilter);
            }
            NameValueCollection _system = new NameValueCollection();
            ISystem sysmodels = null;
            _system = WebUtils.GetSystem();
            sysmodels = PageValue.CurrentSystem;
            //更新已购买的人数
            UpdateNumber(teamid, num);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teammodel = session.Teams.GetByID(teamid);
            }

            #region 第一步
            if (isConpon(teamid, "coupon")) //是否是优惠券项目，如果是，那么给用户插入优惠券记录
            {
                #region 第二步 查看项目是否达到了团购人数，如果达到了，那么发优惠券
                if (istuan(Convert.ToInt32(teammodel.Now_number.ToString()), Convert.ToInt32(teammodel.Min_number)))
                {
                    //查询此项目在优惠券中是否有记录，如果没有，那么在项目团购成功时，给之前在这个项目下单且成功的用户发优惠券，如果有，那么说明项目在优惠券中有记录，说明在这个用户之前下订单的用户已经发了优惠券，跳过
                    // coupmodel = coupbll.GetCouponTeamid(teamid);
                    if (GetCouponTeamid(teamid) == null)
                    {
                        #region
                        if (orderlist.Count > 0)
                        {
                            #region
                            foreach (IOrder order in orderlist)
                            {

                                #region  第三步：查询订单号在优惠券表里面是否有记录
                                // coupmodel = coupbll.Getorderid(order.Id);

                                #endregion

                                ICoupon icoupon = null;
                                CouponFilter couponfilter = new CouponFilter();
                                couponfilter.Order_id = order.Id;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    icoupon = session.Coupon.Get(couponfilter);
                                }

                                if (icoupon == null)//如果优惠券没有此订单的内容，那么给此订单的用户发优惠券
                                {

                                    #region 第四步，订单的数量
                                    if (order.Quantity > 0) //如果下的订单里面有产品有n个，那么优惠券也是n个
                                    {
                                        string couponid = "0";
                                        if (_system["couponlength"] != null && _system["couponlength"] != "")
                                        {
                                            int n = int.Parse(_system["couponlength"]);
                                            //获取优惠券号码
                                            string couponNum = Helper.GetRandomString(n);
                                            string NewcouponNum = "";
                                            getCouponID(couponNum, n, ref NewcouponNum);
                                            couponid = NewcouponNum;

                                        }
                                        else
                                        {
                                            //获取优惠券号码
                                            string couponNum = Helper.GetRandomString(12);
                                            string NewcouponNum = "";
                                            getCouponID(couponNum, 12, ref NewcouponNum);
                                            couponid = NewcouponNum;
                                        }
                                        int sms = order.Quantity;
                                        string tuanphone = "";
                                        if (sysmodels != null)
                                        {
                                            tuanphone = sysmodels.tuanphone;

                                        }
                                        //**********此处做了修改【优惠券:一个劵号多个密码，生成一条短信】--drl--【2013/04/02】**************开始//
                                        #region
                                        if (_system["couponPattern"] == "1")//一对多
                                        {
                                            string coupmodelid = "0"; //记录优惠劵号
                                            string strcouponPwd = ""; //记录优惠劵密码

                                            for (int i = 0; i < sms; i++)
                                            {
                                                // int num1 = order.Team_id;
                                                #region 往优惠券插入详细记录
                                                ICoupon coupmodel = Store.CreateCoupon();
                                                coupmodel.Team_id = order.Team_id;
                                                //判断项目是否存在，如果存在就把这个项目的优惠券开始时间插入到优惠券列表的开始时间
                                                if (teammodel != null)
                                                {
                                                    coupmodel.start_time = teammodel.start_time;
                                                }
                                                coupmodel.Order_id = order.Id;
                                                coupmodel.Type = "consume";
                                                coupmodel.Credit = teammodel.Credit;
                                                coupmodel.Consume = "N";
                                                coupmodel.User_id = order.User_id;
                                                coupmodel.Create_time = DateTime.Now;
                                                coupmodel.Expire_time = teammodel.Expire_time;
                                                coupmodel.Partner_id = teammodel.Partner_id;
                                                if (_system["couponPattern"] != null && _system["couponPattern"] == "1")
                                                {
                                                    coupmodel.Id = couponid;
                                                }
                                                else
                                                {
                                                    if (_system["couponlength"] != null && _system["couponlength"] != "")
                                                    {
                                                        int n = int.Parse(_system["couponlength"]);
                                                        string couponNum = Helper.GetRandomString(n);//获取优惠券号码
                                                        string NewcouponNum = "";
                                                        getCouponID(couponNum, n, ref NewcouponNum);
                                                        coupmodel.Id = NewcouponNum;

                                                    }
                                                    else
                                                    {
                                                        string couponNum = Helper.GetRandomString(12);//获取优惠券号码
                                                        string NewcouponNum = "";
                                                        getCouponID(couponNum, 12, ref NewcouponNum);
                                                        coupmodel.Id = NewcouponNum;
                                                    }
                                                }
                                                coupmodelid = coupmodel.Id;
                                                coupmodel.Secret = Helper.GetRandomString(6);//获取优惠券密码
                                                strcouponPwd = strcouponPwd + coupmodel.Secret + "|";
                                                coupmodel.Sms = 1;
                                                coupmodel.Sms_time = DateTime.Now;
                                                coupmodel.IP = String.Empty;
                                                coupmodel.Consume_time = null;
                                                coupmodel.shoptypes = 0;
                                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                {
                                                    session.Coupon.Insert(coupmodel);
                                                }
                                                #endregion
                                            }
                                            #region 发送短信
                                            ISystem sysmodel = null;
                                            sysmodel = GetModelByCache(1);
                                            List<string> phone = new List<string>();
                                            string tuangou = "";
                                            if (sysmodel != null)
                                            {
                                                tuangou = sysmodel.abbreviation;
                                            }
                                            //得到订单中手机号码，如果为空则给用户信息中的手机号码发优惠券信息
                                            if (order.Mobile != "")
                                            {
                                                phone.Add(order.Mobile);
                                            }
                                            else
                                            {
                                                IUser user = null;
                                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                {
                                                    user = session.Users.GetByID(order.User_id);
                                                }
                                                if (user != null)
                                                {
                                                    phone.Add(user.Mobile);
                                                }
                                            }


                                            IPartner partnermodel = null;
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                partnermodel = session.Partners.GetByID(teammodel.Partner_id);
                                            }
                                            string partnername = "";
                                            string partnermobile = "";
                                            if (partnermodel != null)
                                            {
                                                partnername = partnermodel.Title;
                                                partnermobile = partnermodel.Phone;
                                            }
                                            //站内优惠券信息
                                            NameValueCollection values = new NameValueCollection();
                                            values.Add("网站简称", tuangou);
                                            values.Add("商品名称", teammodel.Product);
                                            values.Add("券号", coupmodelid);
                                            values.Add("密码", strcouponPwd.Substring(0, strcouponPwd.Length - 1));
                                            values.Add("优惠券开始时间", teammodel.start_time.Value.ToString("yyyy年MM月dd日"));
                                            values.Add("优惠券结束时间", teammodel.Expire_time.ToString("yyyy年MM月dd日"));
                                            values.Add("商户名称", partnername);
                                            values.Add("商户电话", partnermobile);
                                            values.Add("团购电话", tuanphone);
                                            string message = BasePage.ReplaceStr("couponsms", values);

                                            string txt = message;
                                            SendSMS(phone, txt);
                                            #endregion
                                        }
                                        else
                                        {
                                            for (int i = 0; i < sms; i++)
                                            {

                                                // int num1 = order.Team_id;
                                                #region 往优惠券插入详细记录
                                                string coupmodelid = "0";
                                                ICoupon coupmodel = Store.CreateCoupon();
                                                coupmodel.Team_id = order.Team_id;
                                                //判断项目是否存在，如果存在就把这个项目的优惠券开始时间插入到优惠券列表的开始时间
                                                if (teammodel != null)
                                                {
                                                    coupmodel.start_time = teammodel.start_time;
                                                }
                                                coupmodel.Order_id = order.Id;
                                                coupmodel.Type = "consume";
                                                coupmodel.Credit = teammodel.Credit;
                                                coupmodel.Consume = "N";
                                                coupmodel.User_id = order.User_id;
                                                coupmodel.Create_time = DateTime.Now;
                                                coupmodel.Expire_time = teammodel.Expire_time;
                                                coupmodel.Partner_id = teammodel.Partner_id;
                                                if (_system["couponPattern"] != null && _system["couponPattern"] == "1")
                                                {
                                                    coupmodel.Id = couponid;
                                                }
                                                else
                                                {
                                                    if (_system["couponlength"] != null && _system["couponlength"] != "")
                                                    {
                                                        int n = int.Parse(_system["couponlength"]);
                                                        string couponNum = Helper.GetRandomString(n);//获取优惠券号码
                                                        string NewcouponNum = "";
                                                        getCouponID(couponNum, n, ref NewcouponNum);
                                                        coupmodel.Id = NewcouponNum;

                                                    }
                                                    else
                                                    {
                                                        string couponNum = Helper.GetRandomString(12);//获取优惠券号码
                                                        string NewcouponNum = "";
                                                        getCouponID(couponNum, 12, ref NewcouponNum);
                                                        coupmodel.Id = NewcouponNum;
                                                    }
                                                }
                                                coupmodelid = coupmodel.Id;
                                                coupmodel.Secret = Helper.GetRandomString(6);//获取优惠券密码
                                                coupmodel.Sms = 1;
                                                coupmodel.Sms_time = DateTime.Now;
                                                coupmodel.IP = String.Empty;
                                                coupmodel.Consume_time = null;
                                                coupmodel.shoptypes = 0;
                                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                {
                                                    session.Coupon.Insert(coupmodel);
                                                }
                                                #endregion

                                                #region 发送短信
                                                ISystem sysmodel = null;
                                                sysmodel = GetModelByCache(1);
                                                List<string> phone = new List<string>();
                                                string tuangou = "";
                                                if (sysmodel != null)
                                                {
                                                    tuangou = sysmodel.abbreviation;
                                                }
                                                //得到订单中手机号码，如果为空则给用户信息中的手机号码发优惠券信息
                                                if (order.Mobile != "")
                                                {
                                                    phone.Add(order.Mobile);
                                                }
                                                else
                                                {
                                                    IUser user = null;
                                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                    {
                                                        user = session.Users.GetByID(order.User_id);
                                                    }
                                                    if (user != null)
                                                    {
                                                        phone.Add(user.Mobile);
                                                    }
                                                }


                                                IPartner partnermodel = null;
                                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                {
                                                    partnermodel = session.Partners.GetByID(teammodel.Partner_id);
                                                }
                                                string partnername = "";
                                                string partnermobile = "";
                                                if (partnermodel != null)
                                                {
                                                    partnername = partnermodel.Title;
                                                    partnermobile = partnermodel.Phone;
                                                }
                                                //站内优惠券信息
                                                NameValueCollection values = new NameValueCollection();
                                                values.Add("网站简称", tuangou);
                                                values.Add("商品名称", teammodel.Product);
                                                values.Add("券号", coupmodelid);
                                                values.Add("密码", coupmodel.Secret);
                                                values.Add("优惠券开始时间", coupmodel.start_time.Value.ToString("yyyy年MM月dd日"));
                                                values.Add("优惠券结束时间", coupmodel.Expire_time.ToString("yyyy年MM月dd日"));
                                                values.Add("商户名称", partnername);
                                                values.Add("商户电话", partnermobile);
                                                values.Add("团购电话", tuanphone);
                                                string message = BasePage.ReplaceStr("couponsms", values);

                                                string txt = message;
                                                SendSMS(phone, txt);
                                                #endregion
                                            }
                                        }
                                        #endregion
                                        //**********此处做了修改【优惠券:一个劵号多个密码，生成一条短信】--drl--【2013/04/02】**************结束//
                                    }
                                    #endregion
                                }
                            }
                            #endregion
                        }
                        else
                        {
                            #region 如果项目编号，在优惠中有记录，说明团购成功之前用户已经发了优惠券，只执行下面关于当前用户动作
                            if (num > 0) //如果下的订单里面有产品有n个，那么优惠券也是n个
                            {
                                string couponid = "0";
                                if (_system["couponlength"] != null && _system["couponlength"] != "")
                                {
                                    int n = int.Parse(_system["couponlength"]);
                                    string couponNum = Helper.GetRandomString(n);//获取优惠券号码
                                    string NewcouponNum = "";
                                    getCouponID(couponNum, n, ref NewcouponNum);
                                    couponid = NewcouponNum;
                                }
                                else
                                {
                                    string couponNum = Helper.GetRandomString(12); //获取优惠券号码
                                    string NewcouponNum = "";
                                    getCouponID(couponNum, 12, ref NewcouponNum);
                                    couponid = NewcouponNum;
                                }
                                //**********此处做了修改【优惠券:一个劵号多个密码，生成一条短信】--drl--【2013/04/02】**************开始//
                                #region
                                if (_system["couponPattern"] == "1")//一对多
                                {
                                    string coupmodelid = "0"; //记录优惠劵号
                                    string strcouponPwd = ""; //记录优惠劵密码

                                    for (int i = 0; i < num; i++)
                                    {
                                        #region 往优惠券插入详细记录
                                        ICoupon coupmodel = Store.CreateCoupon();
                                        coupmodel.Team_id = teamid;
                                        coupmodel.Order_id = orderid;
                                        coupmodel.Type = "consume";
                                        coupmodel.Credit = teammodel.Credit;
                                        coupmodel.Consume = "N";
                                        coupmodel.User_id = userid;
                                        coupmodel.Sms = 1;
                                        coupmodel.Sms_time = DateTime.Now;
                                        coupmodel.Create_time = DateTime.Now;
                                        coupmodel.Expire_time = teammodel.Expire_time;
                                        coupmodel.start_time = teammodel.start_time;
                                        coupmodel.Partner_id = teammodel.Partner_id;
                                        if (_system["couponPattern"] != null && _system["couponPattern"] == "1")
                                        {
                                            coupmodel.Id = couponid;
                                        }
                                        else
                                        {
                                            if (_system["couponlength"] != null && _system["couponlength"] != "")
                                            {
                                                //获取优惠券号码
                                                int n = int.Parse(_system["couponlength"]);
                                                string couponNum = Helper.GetRandomString(n);
                                                string NewcouponNum = "";
                                                getCouponID(couponNum, n, ref NewcouponNum);
                                                coupmodel.Id = NewcouponNum;

                                            }
                                            else
                                            {
                                                //获取优惠券号码
                                                string couponNum = Helper.GetRandomString(12);
                                                string NewcouponNum = "";
                                                getCouponID(couponNum, 12, ref NewcouponNum);
                                                coupmodel.Id = NewcouponNum;
                                            }
                                        }
                                        coupmodelid = coupmodel.Id;
                                        coupmodel.Secret = Helper.GetRandomString(6);//获取优惠券密码
                                        strcouponPwd = strcouponPwd + coupmodel.Secret + "|";
                                        coupmodel.IP = String.Empty;
                                        coupmodel.Consume_time = null;
                                        coupmodel.shoptypes = 0;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Coupon.Insert(coupmodel);
                                        }
                                        #endregion
                                    }
                                    #region 发送短信
                                    ISystem sysmodel = null;
                                    sysmodel = GetModelByCache(1);
                                    List<string> phone = new List<string>();
                                    string tuangou = "";
                                    string tuanphone = "";
                                    if (sysmodel != null)
                                    {
                                        tuangou = sysmodel.abbreviation;
                                        tuanphone = sysmodel.tuanphone;
                                    }

                                    IOrder ordermodel_new = null;
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        ordermodel_new = session.Orders.GetByID(orderid);
                                    }
                                    //得到订单中手机号码，如果为空则给用户信息中的手机号码发优惠券信息
                                    if (ordermodel_new.Mobile != "")
                                    {
                                        phone.Add(ordermodel_new.Mobile);
                                    }
                                    else
                                    {
                                        IUser user = null;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            user = session.Users.GetByID(userid);
                                        }
                                        if (user != null)
                                        {
                                            phone.Add(user.Mobile);
                                        }
                                    }



                                    IPartner partnermodel = null;
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        partnermodel = session.Partners.GetByID(teammodel.Partner_id);
                                    }
                                    string partnername = "";
                                    string partnermobile = "";
                                    if (partnermodel != null)
                                    {
                                        partnername = partnermodel.Title;
                                        partnermobile = partnermodel.Phone;
                                    }

                                    //站内优惠券信息
                                    NameValueCollection values = new NameValueCollection();
                                    values.Add("网站简称", tuangou);
                                    values.Add("商品名称", teammodel.Product);
                                    values.Add("券号", coupmodelid);
                                    values.Add("密码", strcouponPwd.Substring(0, strcouponPwd.Length - 1));
                                    values.Add("优惠券开始时间", teammodel.start_time.Value.ToString("yyyy年MM月dd日"));
                                    values.Add("优惠券结束时间", teammodel.Expire_time.ToString("yyyy年MM月dd日"));
                                    values.Add("商户名称", partnername);
                                    values.Add("商户电话", partnermobile);
                                    values.Add("团购电话", tuanphone);
                                    string message = BasePage.ReplaceStr("couponsms", values);

                                    string txt = message;
                                    //string txt = tuangou + "项目：" + teammodel.Product + "，编号：" + coupmodel.Id + "，密码：" + coupmodel.Secret + "，有效期至：" + coupmodel.Expire_time.ToString("yyyy年MM月dd日");
                                    SendSMS(phone, txt);
                                    #endregion
                                }
                                else
                                {
                                    for (int i = 0; i < num; i++)
                                    {

                                        #region 往优惠券插入详细记录
                                        string coupmodelid = "0";
                                        ICoupon coupmodel = Store.CreateCoupon();
                                        coupmodel.Team_id = teamid;
                                        coupmodel.Order_id = orderid;
                                        coupmodel.Type = "consume";
                                        coupmodel.Credit = teammodel.Credit;
                                        coupmodel.Consume = "N";
                                        coupmodel.User_id = userid;
                                        coupmodel.Sms = 1;
                                        coupmodel.Sms_time = DateTime.Now;
                                        coupmodel.Create_time = DateTime.Now;
                                        coupmodel.Expire_time = teammodel.Expire_time;
                                        coupmodel.start_time = teammodel.start_time;
                                        coupmodel.Partner_id = teammodel.Partner_id;
                                        if (_system["couponPattern"] != null && _system["couponPattern"] == "1")
                                        {
                                            coupmodel.Id = couponid;
                                        }
                                        else
                                        {
                                            if (_system["couponlength"] != null && _system["couponlength"] != "")
                                            {
                                                //获取优惠券号码
                                                int n = int.Parse(_system["couponlength"]);
                                                string couponNum = Helper.GetRandomString(n);
                                                string NewcouponNum = "";
                                                getCouponID(couponNum, n, ref NewcouponNum);
                                                coupmodel.Id = NewcouponNum;

                                            }
                                            else
                                            {
                                                //获取优惠券号码
                                                string couponNum = Helper.GetRandomString(12);
                                                string NewcouponNum = "";
                                                getCouponID(couponNum, 12, ref NewcouponNum);
                                                coupmodel.Id = NewcouponNum;
                                            }
                                        }
                                        coupmodelid = coupmodel.Id;
                                        coupmodel.Secret = Helper.GetRandomString(6);//获取优惠券密码
                                        coupmodel.IP = String.Empty;
                                        coupmodel.Consume_time = null;
                                        coupmodel.shoptypes = 0;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.Coupon.Insert(coupmodel);
                                        }
                                        #endregion


                                        #region 发送短信
                                        ISystem sysmodel = null;
                                        sysmodel = GetModelByCache(1);
                                        List<string> phone = new List<string>();
                                        string tuangou = "";
                                        string tuanphone = "";
                                        if (sysmodel != null)
                                        {
                                            tuangou = sysmodel.abbreviation;
                                            tuanphone = sysmodel.tuanphone;
                                        }

                                        IOrder ordermodel_new = null;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            ordermodel_new = session.Orders.GetByID(coupmodel.Order_id);
                                        }
                                        //得到订单中手机号码，如果为空则给用户信息中的手机号码发优惠券信息
                                        if (ordermodel_new.Mobile != "")
                                        {
                                            phone.Add(ordermodel_new.Mobile);
                                        }
                                        else
                                        {
                                            IUser user = null;
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                user = session.Users.GetByID(userid);
                                            }
                                            if (user != null)
                                            {
                                                phone.Add(user.Mobile);
                                            }
                                        }



                                        IPartner partnermodel = null;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            partnermodel = session.Partners.GetByID(teammodel.Partner_id);
                                        }
                                        string partnername = "";
                                        string partnermobile = "";
                                        if (partnermodel != null)
                                        {
                                            partnername = partnermodel.Title;
                                            partnermobile = partnermodel.Phone;
                                        }

                                        //站内优惠券信息
                                        NameValueCollection values = new NameValueCollection();
                                        values.Add("网站简称", tuangou);
                                        values.Add("商品名称", teammodel.Product);
                                        values.Add("券号", coupmodelid);
                                        values.Add("密码", coupmodel.Secret);
                                        values.Add("优惠券开始时间", coupmodel.start_time.Value.ToString("yyyy年MM月dd日"));
                                        values.Add("优惠券结束时间", coupmodel.Expire_time.ToString("yyyy年MM月dd日"));
                                        values.Add("商户名称", partnername);
                                        values.Add("商户电话", partnermobile);
                                        values.Add("团购电话", tuanphone);
                                        string message = BasePage.ReplaceStr("couponsms", values);

                                        string txt = message;
                                        //string txt = tuangou + "项目：" + teammodel.Product + "，编号：" + coupmodel.Id + "，密码：" + coupmodel.Secret + "，有效期至：" + coupmodel.Expire_time.ToString("yyyy年MM月dd日");
                                        SendSMS(phone, txt);
                                        #endregion

                                    }
                                }
                                #endregion
                                //**********此处做了修改【优惠券:一个劵号多个密码，生成一条短信】--drl--【2013/04/02】**************结束//
                                
                            }
                            #endregion
                        }
                        #endregion
                    }
                    else
                    {
                        #region 如果项目编号，在优惠中有记录，说明团购成功之前用户已经发了优惠券，只执行下面关于当前用户动作
                        if (num > 0) //如果下的订单里面有产品有n个，那么优惠券也是n个
                        {
                            string couponid = "0";
                            if (_system["couponlength"] != null && _system["couponlength"].ToString() != "")
                            {

                                //获取优惠券号码
                                int n = Helper.GetInt(_system["couponlength"], 12);
                                string couponNum = Helper.GetRandomString(n);
                                string NewcouponNum = "";
                                getCouponID(couponNum, n, ref NewcouponNum);
                                couponid = NewcouponNum;
                            }
                            else
                            {
                                //获取优惠券号码
                                string couponNum = Helper.GetRandomString(12);
                                string NewcouponNum = "";
                                getCouponID(couponNum, 12, ref NewcouponNum);
                                couponid = NewcouponNum;
                            }
                            //**********此处做了修改【优惠券:一个劵号多个密码，生成一条短信】--drl--【2013/04/02】**************开始//
                            #region
                            if (_system["couponPattern"] == "1")//一对多
                            {
                                string coupmodelid = "0"; //记录优惠劵号
                                string strcouponPwd = ""; //记录优惠劵密码
                                for (int i = 0; i < num; i++)
                                {
                                    #region 往优惠券插入详细记录
                                    ICoupon coupmodel = Store.CreateCoupon();

                                    if (_system["couponPattern"] != null && _system["couponPattern"].ToString() == "1")
                                    {
                                        coupmodel.Id = couponid;
                                    }
                                    else
                                    {
                                        if (_system["couponlength"] != null && _system["couponlength"].ToString() != "")
                                        {
                                            int n = Helper.GetInt(_system["couponlength"], 12);
                                            string couponNum = Helper.GetRandomString(n);
                                            string NewcouponNum = "";
                                            getCouponID(couponNum, n, ref NewcouponNum);
                                            coupmodel.Id = NewcouponNum;
                                        }
                                        else
                                        {
                                            string couponNum = Helper.GetRandomString(12);
                                            string NewcouponNum = "";
                                            getCouponID(couponNum, 12, ref NewcouponNum);
                                            coupmodel.Id = NewcouponNum;
                                        }
                                    }
                                    coupmodelid = coupmodel.Id;
                                    coupmodel.Team_id = teamid;
                                    coupmodel.Order_id = orderid;
                                    coupmodel.Type = "consume";
                                    coupmodel.Credit = teammodel.Credit;
                                    coupmodel.Consume = "N";
                                    coupmodel.User_id = userid;
                                    coupmodel.Sms = 1;
                                    coupmodel.Sms_time = DateTime.Now;
                                    coupmodel.Create_time = DateTime.Now;
                                    coupmodel.Expire_time = teammodel.Expire_time;
                                    coupmodel.start_time = teammodel.start_time;
                                    coupmodel.Partner_id = teammodel.Partner_id;
                                    coupmodel.Secret = Helper.GetRandomString(6);//获取优惠券密码
                                    strcouponPwd = strcouponPwd + coupmodel.Secret + "|";
                                    coupmodel.IP = String.Empty;
                                    coupmodel.Consume_time = null;
                                    coupmodel.shoptypes = 0;
                                    int count = 0;
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        count = session.Coupon.Insert(coupmodel);
                                    }
                                    #endregion
                                }
                                #region 发送短信
                                ISystem sysmodel = null;
                                sysmodel = GetModelByCache(1);
                                List<string> phone = new List<string>();
                                string tuangou = "";
                                string tuanphone = "";
                                if (sysmodel != null)
                                {
                                    tuangou = sysmodel.abbreviation;
                                    tuanphone = sysmodel.tuanphone;
                                }

                                IOrder ordermodel_new = null;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    ordermodel_new = session.Orders.GetByID(orderid);
                                }
                                //得到订单中手机号码，如果为空则给用户信息中的手机号码发优惠券信息
                                if (ordermodel_new.Mobile != "")
                                {
                                    phone.Add(ordermodel_new.Mobile);
                                }
                                else
                                {
                                    IUser user = null;
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        user = session.Users.GetByID(userid);
                                    }
                                    if (user != null)
                                    {
                                        phone.Add(user.Mobile);
                                    }
                                }
                                string partnername = "";
                                string partnermobile = "";
                                if (teammodel.Partner != null)
                                {
                                    partnername = teammodel.Partner.Title;
                                    partnermobile = teammodel.Partner.Phone;
                                }

                                //站内优惠券信息
                                NameValueCollection values = new NameValueCollection();
                                values.Add("网站简称", tuangou);
                                values.Add("商品名称", teammodel.Product);
                                values.Add("券号", coupmodelid);
                                values.Add("密码", strcouponPwd.Substring(0,strcouponPwd.Length-1));
                                values.Add("优惠券开始时间", teammodel.start_time.Value.ToString("yyyy年MM月dd日"));
                                values.Add("优惠券结束时间", teammodel.Expire_time.ToString("yyyy年MM月dd日"));
                                values.Add("商户名称", partnername);
                                values.Add("商户电话", partnermobile);
                                values.Add("团购电话", tuanphone);
                                string message = BasePage.ReplaceStr("couponsms", values);

                                string txt = message;
                                //string txt = tuangou + "项目：" + teammodel.Product + "，编号：" + coupmodel.Id + "，密码：" + coupmodel.Secret + "，有效期至：" + coupmodel.Expire_time.ToString("yyyy年MM月dd日");  
                                SendSMS(phone, txt);
                                #endregion
                            }
                            else
                            {
                                for (int i = 0; i < num; i++)
                                {

                                    #region 往优惠券插入详细记录
                                    ICoupon coupmodel = Store.CreateCoupon();
                                    string coupmodelid = "0";
                                    if (_system["couponPattern"] != null && _system["couponPattern"].ToString() == "1")
                                    {
                                        coupmodel.Id = couponid;
                                    }
                                    else
                                    {
                                        if (_system["couponlength"] != null && _system["couponlength"].ToString() != "")
                                        {
                                            int n = Helper.GetInt(_system["couponlength"], 12);
                                            string couponNum = Helper.GetRandomString(n);
                                            string NewcouponNum = "";
                                            getCouponID(couponNum, n, ref NewcouponNum);
                                            coupmodel.Id = NewcouponNum;
                                        }
                                        else
                                        {
                                            string couponNum = Helper.GetRandomString(12);
                                            string NewcouponNum = "";
                                            getCouponID(couponNum, 12, ref NewcouponNum);
                                            coupmodel.Id = NewcouponNum;
                                        }
                                    }
                                    coupmodelid = coupmodel.Id;
                                    coupmodel.Team_id = teamid;
                                    coupmodel.Order_id = orderid;
                                    coupmodel.Type = "consume";
                                    coupmodel.Credit = teammodel.Credit;
                                    coupmodel.Consume = "N";
                                    coupmodel.User_id = userid;
                                    coupmodel.Sms = 1;
                                    coupmodel.Sms_time = DateTime.Now;
                                    coupmodel.Create_time = DateTime.Now;
                                    coupmodel.Expire_time = teammodel.Expire_time;
                                    coupmodel.start_time = teammodel.start_time;
                                    coupmodel.Partner_id = teammodel.Partner_id;
                                    coupmodel.Secret = Helper.GetRandomString(6);//获取优惠券密码
                                    coupmodel.IP = String.Empty;
                                    coupmodel.Consume_time = null;
                                    coupmodel.shoptypes = 0;
                                    int count = 0;
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        count = session.Coupon.Insert(coupmodel);
                                    }
                                    #endregion

                                    #region 发送短信
                                    ISystem sysmodel = null;
                                    sysmodel = GetModelByCache(1);
                                    List<string> phone = new List<string>();
                                    string tuangou = "";
                                    string tuanphone = "";
                                    if (sysmodel != null)
                                    {
                                        tuangou = sysmodel.abbreviation;
                                        tuanphone = sysmodel.tuanphone;
                                    }

                                    IOrder ordermodel_new = null;
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        ordermodel_new = session.Orders.GetByID(coupmodel.Order_id);
                                    }
                                    //得到订单中手机号码，如果为空则给用户信息中的手机号码发优惠券信息
                                    if (ordermodel_new.Mobile != "")
                                    {
                                        phone.Add(ordermodel_new.Mobile);
                                    }
                                    else
                                    {
                                        IUser user = null;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            user = session.Users.GetByID(userid);
                                        }
                                        if (user != null)
                                        {
                                            phone.Add(user.Mobile);
                                        }
                                    }
                                    string partnername = "";
                                    string partnermobile = "";
                                    if (teammodel.Partner != null)
                                    {
                                        partnername = teammodel.Partner.Title;
                                        partnermobile = teammodel.Partner.Phone;
                                    }

                                    //站内优惠券信息
                                    NameValueCollection values = new NameValueCollection();
                                    values.Add("网站简称", tuangou);
                                    values.Add("商品名称", teammodel.Product);
                                    values.Add("券号", coupmodelid);
                                    values.Add("密码", coupmodel.Secret);
                                    values.Add("优惠券开始时间", coupmodel.start_time.Value.ToString("yyyy年MM月dd日"));
                                    values.Add("优惠券结束时间", coupmodel.Expire_time.ToString("yyyy年MM月dd日"));
                                    values.Add("商户名称", partnername);
                                    values.Add("商户电话", partnermobile);
                                    values.Add("团购电话", tuanphone);
                                    string message = BasePage.ReplaceStr("couponsms", values);

                                    string txt = message;
                                    //string txt = tuangou + "项目：" + teammodel.Product + "，编号：" + coupmodel.Id + "，密码：" + coupmodel.Secret + "，有效期至：" + coupmodel.Expire_time.ToString("yyyy年MM月dd日");  
                                    SendSMS(phone, txt);
                                    #endregion

                                }
                            }
                            #endregion
                            //**********此处做了修改【优惠券:一个劵号多个密码，生成一条短信】--drl--【2013/04/02】**************结束//
                        }
                        #endregion

                    }
                }
                #endregion
            }
            #endregion



        }
        #endregion

        #region 查询这个项目是否是优惠券
        public static bool isConpon(int teamid, string deliver)
        {
            bool falg = false;
            int i = 0;
            TeamFilter teamfilter = new TeamFilter();
            teamfilter.teamcata = 0;
            teamfilter.Delivery = deliver;
            teamfilter.Id = teamid;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.Teams.GetCount(teamfilter);
            }
            if (i > 0)
            {
                falg = true;
            }
            else
            {
                falg = false;
            }
            return falg;
        }
        #endregion

        #region 根据项目编号，查询在商户优惠券是否有被购买记录
        public static bool GetPCouponTeamid(int Team_id)
        {
            bool falg = false;
            int i = 0;
            PcouponFilter pcouponfilter = new PcouponFilter();
            pcouponfilter.teamid = Team_id;
            pcouponfilter.state = "buy";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.Pcoupon.GetCount(pcouponfilter);
            }
            if (i > 0)
            {
                falg = true;
            }
            return falg;
        }
        #endregion

        #region 根据项目编号，查询在优惠券是否有记录
        public static ICoupon GetCouponTeamid(int Team_id)
        {
            ICoupon icoupon = null;
            CouponFilter couponfilter = new CouponFilter();
            couponfilter.Team_id = Team_id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                icoupon = session.Coupon.Get(couponfilter);
            }
            return icoupon;
        }
        #endregion

        #region 得到一个不重复的优惠券号
        /// <summary>
        /// 得到一个不重复的优惠券号
        /// </summary>
        /// <param name="couponNum">需要验证的优惠券id</param>
        /// <param name="length">优惠券长度</param>
        /// <param name="newcouponid">有效的优惠券id</param>
        public static void getCouponID(string couponNum, int length, ref string newcouponid)
        {
            ICoupon icoupon = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                icoupon = session.Coupon.GetByID(couponNum);
            }
            if (icoupon == null)
            {
                newcouponid = couponNum;
                return;
            }
            else
            {
                getCouponID(GetRandomString(length), length, ref newcouponid);
                return;
            }

        }
        #endregion

        #region 代金券规则
        /// <summary>
        /// //代金券规则
        /// </summary>
        public static string GetRandomString(int bit)
        {
            System.Random ran = new Random();
            string val = ran.Next(1, 10).ToString();


            for (int i = 1; i < bit; i++)
            {
                val = val + ran.Next(0, 10).ToString();
            }

            return val;

        }
        #endregion

        #region 生成抽奖信息
        public static void AddDraw(int teamid, int userid, int orderid)
        {
            IDraw drawmodel = Store.CreateDraw();

            IInvite invitemodel = null;

            #region 生成抽奖信息
            drawmodel.createtime = DateTime.Now;
            drawmodel.userid = userid;
            drawmodel.orderid = orderid;
            drawmodel.teamid = Helper.GetInt(teamid, 0);
            if (Getinvite(userid))
            {
                InviteFilter invitefilter = new InviteFilter();
                invitefilter.Other_user_id = userid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    invitemodel = session.Invite.Get(invitefilter);//根据Other_user_id查询出邀【主动邀请人】在邀请表【invite】中的信息
                }
                drawmodel.inviteid = invitemodel.User_id;////被邀请人的id
            }
            lock (drawcodelocker)
            {
                drawmodel.number = Getdrawcode(Helper.GetInt(teamid, 0));//抽奖号码
                drawmodel.state = "N";
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Draw.Insert(drawmodel);
                }
            }
            #endregion


            #region 如果此用户是被邀请，那么需要给邀请人一个抽奖号码
            if (Getinvite(userid))
            {
                InviteFilter invitefilter = new InviteFilter();
                invitefilter.Other_user_id = userid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    invitemodel = session.Invite.Get(invitefilter);//根据Other_user_id查询出邀【主动邀请人】在邀请表【invite】中的信息
                }
                IUser user = null;
                UserFilter userfilter = new UserFilter();
                userfilter.ID = userid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    user = session.Users.GetByID(userid);
                }
                if (user != null)
                {
                    if (user.Newbie == "Y")//判断用户是第一次下单
                    {
                        #region 生成抽奖信息
                        drawmodel.createtime = DateTime.Now;
                        drawmodel.userid = invitemodel.User_id;
                        drawmodel.orderid = 0;
                        drawmodel.teamid = Helper.GetInt(teamid, 0);
                        drawmodel.inviteid = userid;////被邀请人的id
                        lock (drawcodelocker)
                        {
                            drawmodel.number = Getdrawcode(Helper.GetInt(teamid, 0));//抽奖号码
                            drawmodel.state = "N";
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                session.Draw.Insert(drawmodel);
                            }
                        }
                        #endregion
                    }
                }
            }
            #endregion
        }
        #endregion

        #region 生成抽奖号码
        /// <summary>
        /// 生成抽奖号码的锁
        /// </summary>
        public static object drawcodelocker = new object();
       
        public static string Getdrawcode(int Teamid)
        {
            //00001
            string code = "";
            ITeam teammodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teammodel = session.Teams.GetByID(Teamid);
            }
            if (teammodel.drawType == 0)//0随机生产，1按顺序生成
            {
                code = Helper.GetRandomString(10);
            }
            else
            {
                DrawFilter drawfilter = new DrawFilter();
                drawfilter.teamid = Teamid;
                int sum = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    sum = session.Draw.GetCount(drawfilter);
                }
                if (sum.ToString().Length > 5)
                {
                    code = (1 + Helper.GetInt(sum, 0)).ToString();
                }
                else
                {
                    code = (1 + Helper.GetInt(sum.ToString(), 0)).ToString("00000");
                }

            }
            return code;
        }
        #endregion

        #region  订单付款成功发短信
        public static void OrderpaySms(int id, NameValueCollection configs)
        {
            if (configs["orderpay"] != null && configs["orderpay"].ToString() == "1")
            {
                IOrder ordermodel = null;
                IUser usermodel = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ordermodel = session.Orders.GetByID(id);
                }
                string money = "";
                string username = "";
                string mobile = "";
                string quantity = "";
                string strRealname = "";
                string strAddress = "";
                string strRemark = "";
                string strMobile = "";
                if (ordermodel != null)
                {
                    money = ordermodel.Origin.ToString();
                    strMobile = ordermodel.Mobile;
                    mobile = ordermodel.Mobile;
                    quantity = ordermodel.Quantity.ToString();
                    strRealname = ordermodel.Realname;
                    strAddress = ordermodel.Address;
                    strRemark = ordermodel.Remark;
                    usermodel = ordermodel.User;
                    if (usermodel != null)
                    {
                        username = usermodel.Username;
                        if (mobile == "")
                        {
                            mobile = usermodel.Mobile;
                        }
                    }
                }
                NameValueCollection values = new NameValueCollection();
                ISystem system = PageValue.CurrentSystem;
                if (system != null)
                {
                    values.Add("网站简称", system.abbreviation);
                }
                values.Add("订单号", id.ToString());
                values.Add("订单总金额", money);
                values.Add("用户名", username);
                values.Add("购买数量", quantity);
                values.Add("收货人", strRealname);
                values.Add("收货地址", strAddress);
                values.Add("联系电话", strMobile);
                values.Add("订单备注", strRemark);
                string message = BasePage.ReplaceStr("orderpay", values);
                List<string> mobilelist = new List<string>();
                mobilelist.Add(mobile);
                SendSMS(mobilelist, message);
            }

            //付款成功给商家发短信
            if (configs["orderpartner"] != null && configs["orderpartner"].ToString() == "1")
            {
                IOrder ordermodel = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ordermodel = session.Orders.GetByID(id);
                }
                IList<IOrderDetail> orderdetailmodels = null;
                ITeam teammodel = null;
                ISystem system = PageValue.CurrentSystem;
                NameValueCollection values = new NameValueCollection();
                values.Add("订单备注", ordermodel.Remark);
                values.Add("订单号", ordermodel.Id.ToString());
                values.Add("收货地址", ordermodel.Address);
                values.Add("联系电话", ordermodel.Mobile);
                values.Add("收货人", ordermodel.Realname);
                values.Add("商品名称", "");
                values.Add("购买数量", "");
                values.Add("网站简称", system.abbreviation);
                string mobile = "";
                if (ordermodel != null)
                {
                    if (ordermodel.Team_id == 0)//走购物车
                    {
                        orderdetailmodels = ordermodel.OrderDetail;
                        if (orderdetailmodels != null && orderdetailmodels.Count > 0)
                        {
                            foreach (IOrderDetail iorderdetailInfo in orderdetailmodels)
                            {
                                teammodel = iorderdetailInfo.Team;
                                if (teammodel != null)
                                {
                                    if (teammodel.Product != null)
                                    {
                                        values["商品名称"] = teammodel.Product;
                                    }
                                    values["购买数量"] = iorderdetailInfo.Num.ToString();
                                    if (teammodel.Partner != null && teammodel.Partner.Mobile != null && teammodel.Partner.Mobile.Length > 0)
                                    {
                                        mobile = teammodel.Partner.Mobile;
                                        string message = BasePage.ReplaceStr("orderpartner", values);
                                        List<string> mobilelist = new List<string>();
                                        mobilelist.Add(mobile);
                                        SendSMS(mobilelist, message);
                                    }
                                }
                            }
                        }
                    }
                    else //没走
                    {
                        if (ordermodel.Team != null)
                        {
                            if (ordermodel.Team.Product != null)
                            {
                                values["商品名称"] = ordermodel.Team.Product;
                            }
                            values["购买数量"] = ordermodel.Quantity.ToString();
                            if (ordermodel.Team.Partner != null && ordermodel.Team.Partner.Mobile != null && ordermodel.Team.Partner.Mobile.Length > 0)
                            {
                                mobile = ordermodel.Team.Partner.Mobile;
                                string message = BasePage.ReplaceStr("orderpartner", values);
                                List<string> mobilelist = new List<string>();
                                mobilelist.Add(mobile);
                                SendSMS(mobilelist, message);
                            }
                        }
                    }
                }

            }
        }
        #endregion

        #region 判断订单的项目总额
        public static decimal GetTeamTotalPrice(int orderid)
        {
            decimal totalprice = 0;
            decimal totalamount = 0;
            int userid = 0;
            IUser user = null;
            string sql = "select User_id,isnull(num,quantity) as num , isnull(teamprice,price) as price,ISNULL([orderdetail].Credit,Card) as cardprice from [order] left join [orderdetail] on([order].id=[orderdetail].order_id) where [order].id=" + orderid;
            string sqlrow = "select disamount,disinfo from [order] where id=" + orderid;
            List<Hashtable> ht = new List<Hashtable>();
            List<Hashtable> htrow = null;
            using (IDataSession session = Store.OpenSession(false))
            {
                ht = session.Custom.Query(sql);
                htrow = session.Custom.Query(sqlrow);
            }
            foreach (var item in ht)
            {
                decimal tempprice = Helper.GetInt(item["num"], 0) * Helper.GetDecimal(item["price"], 0);
                if (Helper.GetInt(item["cardprice"], 0) > 0)//当使用代金券后项目金额小于0时，将此代金券金额忽略
                {
                    tempprice = tempprice - Helper.GetInt(item["cardprice"], 0);
                    if (tempprice < 0) tempprice = 0;
                }
                userid = Helper.GetInt(item["User_id"], 0);
                totalprice = totalprice + tempprice;
            }
            if (userid != 0)
            {
                using (IDataSession session = Store.OpenSession(false))
                {
                    user = session.Users.GetByID(userid);
                }
                if (user != null)
                    totalamount = user.totalamount;
            }
            if (ActionHelper.GetUserLevelMoney(totalamount) > 0)
            {
                totalprice = Convert.ToDecimal((totalprice * Convert.ToDecimal(ActionHelper.GetUserLevelMoney(totalamount))).ToString("f2"));
            }
            if (htrow != null)
            {
                if (totalprice > Helper.GetDecimal(htrow[0]["disamount"], 0))
                {
                    totalprice = totalprice - Helper.GetDecimal(htrow[0]["disamount"], 0);
                }
            }
            return totalprice;
        }
        #endregion

        #region 判断指定的订单号是否允许付款
        /// <summary>
        /// 判断指定的订单号是否允许付款
        /// </summary>
        /// <param name="orderid">订单号</param>
        /// <param name="userid">当前用户ID</param>
        /// <param name="ok"></param>
        /// <returns></returns>
        public static string SystemAllowPayOrder(int orderid, int userid, out bool ok)
        {
            NameValueCollection configs = PageValue.CurrentSystemConfig;
            ok = false;
            string error = String.Empty;
            string tempsql = "select t.*,isnull(t1.buynum,0) as buynum from (select open_invent, Per_number,Max_number,Now_number,Buyonce,Begin_time,End_time,inventory,teamcata,t.* from team inner join (select state,isnull(teamid,team_id) as teamid,isnull(num,quantity) as num,[order].id from [order] left join [orderdetail] on([order].id=[orderdetail].order_id) where [order].id=" + orderid + ") t on(team.id=t.teamid)) t left join (select teamid,count(*) as buynum from (select isnull(teamid,team_id) as teamid,isnull(num,quantity) as num,user_id from [order] left join [orderdetail] on([order].id=[orderdetail].order_id) where ([order].state='pay' or [order].state='scorepay') and user_id=" + userid + " )t group by teamid) t1 on(t.teamid=t1.teamid)";
            List<Hashtable> ht = null;
            using (IDataSession session = Store.OpenSession(false))
            {
                ht = session.Custom.Query(tempsql);
            }
            if (ht == null)
            {
                error = "不存在此订单";
            }
            else
            {
                bool dingdancancel = false;
                for (int i = 0; i < ht.Count; i++)
                {
                    //1判断订单状态是否为未付款,unpay,scoreunpay
                    string state = Helper.GetString(ht[i]["state"], String.Empty);
                    string buyonce =Helper.GetString(ht[i]["buyonce"],String.Empty);
                    int buynum = Helper.GetInt(ht[i]["buynum"], 0);
                    if ((state != String.Empty) && (state == "unpay" || state == "scoreunpay"))
                    {
                        //2判断订单中的项目是否已经过期或者未开始
                        if (Helper.GetInt(ht[i]["teamcata"], 2) == 0)//商城项目不限制过期或者未开始  也不限制购买次数
                        {
                            if (Helper.GetDateTime(ht[i]["begin_time"], DateTime.Now) > DateTime.Now || Helper.GetDateTime(ht[i]["end_time"], DateTime.Now) < DateTime.Now)
                            {
                                dingdancancel = true;
                                ok = false;
                                error = "此订单中含有已过期项目，所以您不能进行付款了，请您重新选择商品下单";
                                break;
                            }

                            //3判断项目是否只允许购买一次
                            if ((buyonce != String.Empty && buynum != 0) && (buyonce == "Y" && buynum > 0))
                            {
                                dingdancancel = true;
                                ok = false;
                                error = "此订单中含有只允许购买一次的项目，所以您不能进行付款了，请您重新选择商品下单";
                                break;
                            }

                            //4判断项目是否有限购数量
                            if (Helper.GetInt(ht[i]["per_number"], 0) > 0 && Helper.GetInt(ht[i]["per_number"], 0) < Helper.GetInt(ht[i]["num"], 0))
                            {
                                dingdancancel = true;
                                ok = false;
                                error = "此订单中含有限购数量的项目，您购买的商品已经超出了限制数量。所以您不能进行付款了，请您重新选择商品下单";
                                break;
                            }
                        }
                        //5判断项目是否启用库存功能
                        if (Helper.GetInt(ht[i]["open_invent"], 0) == 1 && Helper.GetInt(ht[i]["inventory"], 0) <= 0)
                        {
                            dingdancancel = true;
                            ok = false;
                            error = "此订单中的项目已卖光，所以不能进行付款，请您重新选择商品下单";
                            break;
                        }
                    }
                    else
                    {
                        ok = false;
                        error = "此订单不是未付款状态，不能进行付款";
                        break;
                    }
                    ok = true;
                }
                if (!ok && dingdancancel == true)
                {
                    IOrder order = Store.CreateOrder();
                    order.Id = orderid;
                    order.State = "cancel";
                    int i = 0;
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        i = session.Orders.Update(order);
                    }
                    if (i == 0)
                    {
                        error = "订单更新失败";
                    }
                }
            }
            return error;
        }
        #endregion

        #region 判断用户账户余额是否大于订单金额
        public static bool Isjudge(decimal yumoney, decimal summoney)
        {
            bool falg = false;
            if (yumoney >= summoney)
            {
                falg = true;
            }
            else
            {
                falg = false;
            }
            return falg;
        }
        #endregion
    }
}
