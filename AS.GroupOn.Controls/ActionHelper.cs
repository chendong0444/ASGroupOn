using System;
using System.Collections.Generic;
using System.Text;
using System.Data.SqlClient;
using System.Data;
using System.Collections.Specialized;
using System.Web;
using System.Data.OleDb;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Controls;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.App;

namespace AS.Common.Utils
{
    public class ActionHelper
    {
        #region 枚举数据
        public enum RefundType
        {

            none = 0,
            /// <summary>
            /// 退款到余额
            /// </summary>
            UserCredit = 1,
            /// <summary>
            /// 其他方式退款
            /// </summary>
            Others = 2,
        }
        public enum Flow_Direction
        {
            /// <summary>
            /// 收益
            /// </summary>
            income = 1,
            /// <summary>
            /// 花费
            /// </summary>
            expense = 2,
        }
        public enum Flow_Action
        {
            /// <summary>
            /// 购买
            /// </summary>
            buy = 1,
            /// <summary>
            /// 在线充值
            /// </summary>
            charge = 2,
            /// <summary>
            /// 优惠券返利
            /// </summary>
            coupon = 3,
            /// <summary>
            /// 邀请好友返利
            /// </summary>
            invite = 4,
            /// <summary>
            /// 线下充值
            /// </summary>
            store = 5,
            /// <summary>
            /// 提现
            /// </summary>
            withdraw = 6,
            /// <summary>
            /// 现金支付
            /// </summary>
            cash = 7,
            /// <summary>
            /// 退款
            /// </summary>
            refund = 8,
        }
        #region
        public static string Mananger_RefundMent(int orderid, int adminid, RefundType refundtype, out string message)
        {
            string error = String.Empty;
            message = String.Empty;

            if (refundtype != RefundType.none)
            {

                error = "";
                if (error.Length == 0)
                {

                    IOrder orderdro = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {

                        orderdro = session.Orders.GetByID(orderid);
                    }
                    if (orderdro == null)
                        error = "不存在此订单";
                    else
                    {
                        if (orderdro.State != "pay" && orderdro.State != "scorepay")
                        {
                            error = "当前订单不是已付款状态不能退款";
                        }
                        else
                        {


                            //退单入库
                            string state = orderdro.State;
                            decimal credit = Helper.GetDecimal(orderdro.Credit, 0);
                            decimal money = Helper.GetDecimal(orderdro.Money, 0);//在线支付
                            decimal cashondelivery = Helper.GetDecimal(orderdro.cashondelivery, 0);
                            decimal fare = Helper.GetDecimal(orderdro.Fare, 0);
                            int userid = Helper.GetInt(orderdro.User_id, 0);
                            int quantity = Helper.GetInt(orderdro.Quantity, 0);//购买数量
                            bool express = (orderdro.Express == "Y") ? true : false;
                            if (refundtype == RefundType.UserCredit)//余额退款
                            {
                                if (express) //快递订单
                                {

                                    decimal totalmoney = 0;
                                    if (orderdro.Service == "cashondelivery")
                                    {
                                        totalmoney = credit + cashondelivery;
                                    }
                                    else
                                    {
                                        totalmoney = credit + money;
                                    }
                                    AdminPage.Flow_Insert(userid, adminid, orderid.ToString(), "订单ID" + orderid + "退款到账户余额" + totalmoney, Flow_Direction.income, totalmoney, Flow_Action.refund);

                                    if (state == "pay")//非积分项目
                                    {
                                        //Maticsoft.Model.scorelog scroelogModel = new Maticsoft.Model.scorelog();
                                        List<Hashtable> hashtable = null;
                                        DataTable table = new DataTable();
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList("update [order] set state='refund',pay_time='" + DateTime.Now + "', credit=" + totalmoney + ",money=0 where id=" + orderid);
                                        }
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList("update [user] set totalamount=totalamount-" + (totalmoney - fare) + ",money=money+" + totalmoney + ",userscore=userscore-" + orderdro.orderscore.ToString() + " where id=" + userid);
                                        }
                                        if (Convert.ToInt32(orderdro.orderscore.ToString()) != 0)
                                        {
                                            IScorelog scroelogModel = AS.GroupOn.App.Store.CreateScorelog();
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                scroelogModel.score = -Convert.ToInt32(orderdro.orderscore.ToString());
                                                scroelogModel.action = "退单";
                                                scroelogModel.key = orderid.ToString();
                                                scroelogModel.adminid = adminid;
                                                scroelogModel.create_time = System.DateTime.Now;
                                                scroelogModel.user_id = userid;
                                                int i = 0;
                                                i = session.Scorelog.Insert(scroelogModel);
                                            }
                                        }
                                        //if (scroelogModel.score != 0)
                                        //{
                                        //    scroelogDal.Add(scroelogModel);
                                        //}
                                        message = "订单ID" + orderid + "退款到账户余额" + totalmoney + ",退还积分" + orderdro.orderscore.ToString();
                                        //如果订单使用了代金券则取消代金券
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList("update card set consume='N' where order_id=" + orderid);
                                        }
                                    }
                                    else if (state == "scorepay")//积分项目
                                    {
                                        List<Hashtable> hashtable = null;
                                        IScorelog scroelogModel = AS.GroupOn.App.Store.CreateScorelog();
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList("update [order] set state='scorrefund',pay_time='" + DateTime.Now + "', credit=" + totalmoney + ",money=0 where id=" + orderid);
                                        }
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList("update [user] set money=money+" + totalmoney + ",userscore=userscore+" + orderdro.totalscore.ToString() + " where id=" + userid);
                                        }
                                        if (Convert.ToInt32(orderdro.totalscore.ToString()) != 0)
                                        {
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                scroelogModel.score = Convert.ToInt32(orderdro.totalscore.ToString());
                                                scroelogModel.action = "退单";
                                                scroelogModel.key = orderid.ToString();
                                                scroelogModel.adminid = adminid;
                                                scroelogModel.create_time = System.DateTime.Now;
                                                scroelogModel.user_id = userid;
                                                int i = 0;
                                                i = session.Scorelog.Insert(scroelogModel);

                                            }

                                        }
                                        //if (scroelogModel.score != 0)
                                        //{
                                        //    scroelogDal.Add(scroelogModel);
                                        //}
                                        message = "订单ID" + orderid + "退款到账户余额" + totalmoney;
                                        //如果订单使用了代金券则取消代金券
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList("update card set consume='N' where order_id=" + orderid);
                                        }

                                    }
                                }
                                else //优惠券订单
                                {

                                    //得到已使用的优惠券数量
                                    List<Hashtable> hashtable = null;
                                    DataTable table = new DataTable();
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        hashtable = session.GetData.GetDataList("select COUNT(*) as num from coupon where Order_id=" + orderid + " and Consume='Y'");
                                    }
                                    table = Helper.ConvertDataTable(hashtable);
                                    DataRowObject dro = null;
                                    if (table.Rows.Count > 0)
                                    {
                                        if (table.Rows.Count > 0)
                                        {
                                            dro = new DataRowObject(table.Rows[0]);
                                        }
                                    }
                                    int usecouponcount = dro.ToInt("num");
                                    if (quantity == usecouponcount)//判断优惠券是否已被全部使用
                                    {
                                        error = "订单:" + orderid + "的优惠券已经全部消费了，无法进行退款";
                                        return error;
                                    }
                                    else
                                    {
                                        decimal price = Helper.GetDecimal(orderdro.Price, 0);
                                        decimal totalmoney = credit + money - price * usecouponcount;
                                        if (usecouponcount > 0)//有已使用的优惠券
                                        {
                                            decimal nousecouponprice = price * (quantity - usecouponcount);//未使用的优惠券的总额,也就是应退款的金额
                                            decimal changecredit = credit;//改变后的用户余额
                                            decimal changemoney = money;//改变后的在线支付金额
                                            if (nousecouponprice > credit)
                                            {
                                                nousecouponprice = nousecouponprice - credit;
                                            }
                                            else
                                            {
                                                changecredit = credit - nousecouponprice;
                                                nousecouponprice = 0;
                                            }
                                            if (nousecouponprice > money)
                                            {
                                                nousecouponprice = nousecouponprice - money;
                                            }
                                            else
                                            {
                                                changemoney = money - nousecouponprice;
                                                nousecouponprice = 0;
                                            }
                                            decimal changetotalmoney = changecredit + changemoney;
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                hashtable = session.GetData.GetDataList("update [order] set origin=" + changetotalmoney + ",quantity=" + usecouponcount + ",credit=" + changecredit + ",money=" + changemoney + " where id=" + orderid);
                                            }
                                            AdminPage.Flow_Insert(userid, adminid, orderid.ToString(), "订单ID" + orderid + "退款到账户余额" + totalmoney, Flow_Direction.income, totalmoney, Flow_Action.refund);
                                            message = "订单ID" + orderid + "退款到账户余额" + totalmoney + ",退还优惠券数量:" + (quantity - usecouponcount);
                                        }
                                        else
                                        {
                                            AdminPage.Flow_Insert(userid, adminid, orderid.ToString(), "订单ID" + orderid + "退款到账户余额" + totalmoney, Flow_Direction.income, totalmoney, Flow_Action.refund);

                                            IScorelog scroelogModel = AS.GroupOn.App.Store.CreateScorelog();
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                hashtable = session.GetData.GetDataList("update [order] set state='refund',pay_time='" + DateTime.Now + "',credit=" + totalmoney + ",money=0 where id=" + orderid);
                                            }
                                            if (Convert.ToInt32(orderdro.orderscore.ToString()) != 0)
                                            {
                                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                {
                                                    scroelogModel.score = -Convert.ToInt32(orderdro.orderscore.ToString());
                                                    scroelogModel.action = "退单";
                                                    scroelogModel.key = orderid.ToString();
                                                    scroelogModel.adminid = adminid;
                                                    scroelogModel.create_time = System.DateTime.Now;
                                                    scroelogModel.user_id = userid;
                                                    int i = 0;
                                                    i = session.Scorelog.Insert(scroelogModel);
                                                }
                                            }
                                            message = "订单ID" + orderid + "退款到账户余额" + totalmoney;
                                            //如果订单使用了代金券则取消代金券
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                hashtable = session.GetData.GetDataList("update card set consume='N' where order_id=" + orderid);
                                            }
                                        }
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList("delete from coupon where Consume='N' and order_id=" + orderid);
                                        }
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList("update [user] set totalamount=totalamount-" + (totalmoney - fare) + ",money=money+" + totalmoney + ",userscore=userscore-" + orderdro.orderscore.ToString() + " where id=" + userid);
                                        }
                                    }

                                }
                            }
                            else if (refundtype == RefundType.Others)
                            {
                                if (express) //快递订单
                                {
                                    decimal totalmoney = credit + money;
                                    AdminPage.Flow_Insert(userid, adminid, orderid.ToString(), "订单ID" + orderid + "退款到账户余额" + credit + ",还需人工退款" + money, Flow_Direction.income, totalmoney, Flow_Action.refund);
                                    List<Hashtable> hashtable = null;
                                    if (state == "pay")//非积分项目
                                    {
                                        IScorelog scroelogModel = AS.GroupOn.App.Store.CreateScorelog();
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList("update [order] set state='refund',pay_time='" + DateTime.Now + "' where id=" + orderid);
                                        }
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList("update [user] set totalamount=totalamount-" + (credit - fare) + ",money=money+" + credit + ",userscore=userscore-" + orderdro.orderscore.ToString() + " where id=" + userid);
                                        }
                                        if (Convert.ToInt32(orderdro.orderscore.ToString()) != 0)
                                        {
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                scroelogModel.score = -Convert.ToInt32(orderdro.orderscore.ToString());
                                                scroelogModel.action = "退单";
                                                scroelogModel.key = orderid.ToString();
                                                scroelogModel.adminid = adminid;
                                                scroelogModel.create_time = System.DateTime.Now;
                                                scroelogModel.user_id = userid;
                                                int i = 0;
                                                i = session.Scorelog.Insert(scroelogModel);
                                            }
                                        }
                                        message = "订单ID" + orderid + "退款到账户余额" + credit + ",还需人工退款" + money + ",退还积分" + orderdro.orderscore.ToString();
                                        //如果订单使用了代金券则取消代金券
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList("update card set consume='N' where order_id=" + orderid);
                                        }
                                    }
                                    else if (state == "scorepay")//积分项目
                                    {
                                        IScorelog scroelogModel = AS.GroupOn.App.Store.CreateScorelog();
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList("update [order] set state='scorrefund',pay_time='" + DateTime.Now + "' where id=" + orderid);
                                        }
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList("update [user] set money=money+" + credit + ",userscore=userscore+" + orderdro.totalscore.ToString() + " where id=" + userid);
                                        }
                                        if (Convert.ToInt32(orderdro.totalscore.ToString()) != 0)
                                        {
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                scroelogModel.score = Convert.ToInt32(orderdro.totalscore.ToString());
                                                scroelogModel.action = "退单";
                                                scroelogModel.key = orderid.ToString();
                                                scroelogModel.adminid = adminid;
                                                scroelogModel.create_time = System.DateTime.Now;
                                                scroelogModel.user_id = userid;
                                                int i = 0;
                                                i = session.Scorelog.Insert(scroelogModel);
                                            }
                                        }
                                        //if (scroelogModel.score != 0)
                                        //{
                                        //    scroelogDal.Add(scroelogModel);
                                        //}
                                        message = "订单ID" + orderid + "退款到账户余额" + credit + ",还需人工退款" + money;
                                    }
                                }
                                else //优惠券订单
                                {


                                    //得到已使用的优惠券数量
                                    List<Hashtable> hashtable = null;
                                    DataTable table = new DataTable();
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        hashtable = session.GetData.GetDataList("select COUNT(*) as num from coupon where Order_id=" + orderid + " and Consume='Y'");
                                    }
                                    table = Helper.ConvertDataTable(hashtable);
                                    DataRowObject dro = null;
                                    if (table.Rows.Count > 0)
                                    {
                                        if (table.Rows.Count > 0)
                                        {
                                            dro = new DataRowObject(table.Rows[0]);
                                        }
                                    }
                                    int usecouponcount = dro.ToInt("num");
                                    if (quantity == usecouponcount)//判断优惠券是否已被全部使用
                                    {
                                        error = "订单:" + orderid + "的优惠券已经全部消费了，无法进行退款";
                                        return error;
                                    }
                                    else
                                    {
                                        decimal price = Helper.GetDecimal(orderdro.Price, 0);
                                        decimal totalmoney = credit + money - price * usecouponcount;

                                        #region 删除未使用的优惠券
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            hashtable = session.GetData.GetDataList(String.Format("delete from coupon where Consume='N' and order_id={0}", orderid));
                                        }
                                        #endregion

                                        if (usecouponcount == 0)//使用数量为0
                                        {
                                            IScorelog scroelogModel = AS.GroupOn.App.Store.CreateScorelog();
                                            AdminPage.Flow_Insert(userid, adminid, orderid.ToString(), "订单ID" + orderid + "退款到账户余额" + credit + ",还需人工退款" + money, Flow_Direction.income, totalmoney, Flow_Action.refund);
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                hashtable = session.GetData.GetDataList("update [order] set state='refund',pay_time='" + DateTime.Now + "' where id=" + orderid);
                                            }
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                hashtable = session.GetData.GetDataList("update [user] set totalamount=totalamount-" + (credit - fare) + ",money=money+" + credit + ",userscore=userscore-" + orderdro.orderscore.ToString() + " where id=" + userid);
                                            }
                                            if (Convert.ToInt32(orderdro.orderscore.ToString()) != 0)
                                            {
                                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                {
                                                    scroelogModel.score = -Convert.ToInt32(orderdro.orderscore.ToString());
                                                    scroelogModel.action = "退单";
                                                    scroelogModel.key = orderid.ToString();
                                                    scroelogModel.adminid = adminid;
                                                    scroelogModel.create_time = System.DateTime.Now;
                                                    scroelogModel.user_id = userid;
                                                    int i = 0;
                                                    i = session.Scorelog.Insert(scroelogModel);
                                                }
                                            }
                                            message = "订单ID" + orderid + "退款到账户余额" + credit + ",还需人工退款" + money;
                                            //如果订单使用了代金券则取消代金券
                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                            {
                                                hashtable = session.GetData.GetDataList("update card set consume='N' where order_id=" + orderid);
                                            }
                                        }
                                        else
                                        {
                                            if (usecouponcount > 0)//有已使用的优惠券
                                            {
                                                decimal nousecouponprice = price * (quantity - usecouponcount);//未使用的优惠券的总额,也就是应退款的金额
                                                decimal changecredit = credit;//改变后的用户余额
                                                decimal changemoney = money;//改变后的在线支付金额
                                                if (nousecouponprice > credit)
                                                {
                                                    nousecouponprice = nousecouponprice - credit;
                                                }
                                                else
                                                {
                                                    changecredit = credit - nousecouponprice;
                                                    nousecouponprice = 0;
                                                }
                                                if (nousecouponprice > money)
                                                {
                                                    nousecouponprice = nousecouponprice - money;
                                                }
                                                else
                                                {
                                                    changemoney = money - nousecouponprice;
                                                    nousecouponprice = 0;
                                                }
                                                decimal changetotalmoney = changecredit + changemoney;
                                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                {
                                                    hashtable = session.GetData.GetDataList("update [order] set origin=" + changetotalmoney + ",quantity=" + usecouponcount + ",credit=" + changecredit + ",money=" + changemoney + " where id=" + orderid);
                                                }
                                                message = "订单ID" + orderid + "需人工退款" + totalmoney + ",退还优惠券数量:" + (quantity - usecouponcount);
                                            }
                                            else
                                            {
                                                if (money == 0)//用余额付款
                                                {
                                                    IScorelog scroelogModel = AS.GroupOn.App.Store.CreateScorelog();
                                                    AdminPage.Flow_Insert(userid, adminid, orderid.ToString(), "订单ID" + orderid + "退款到账户余额" + totalmoney, Flow_Direction.income, totalmoney, Flow_Action.refund);
                                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                    {
                                                        hashtable = session.GetData.GetDataList("update [order] set state='refund',pay_time='" + DateTime.Now + "',credit=" + totalmoney + ",money=0 where id=" + orderid);
                                                    }
                                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                    {
                                                        hashtable = session.GetData.GetDataList("update [user] set totalamount=totalamount-" + (credit - fare) + ",money=money+" + totalmoney + ",userscore=userscore-" + orderdro.orderscore.ToString() + " where id=" + userid);
                                                    }
                                                    if (Convert.ToInt32(orderdro.orderscore.ToString()) != 0)
                                                    {
                                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                        {
                                                            scroelogModel.score = -Convert.ToInt32(orderdro.orderscore.ToString());
                                                            scroelogModel.action = "退单";
                                                            scroelogModel.key = orderid.ToString();
                                                            scroelogModel.adminid = adminid;
                                                            scroelogModel.create_time = System.DateTime.Now;
                                                            scroelogModel.user_id = userid;
                                                            int i = 0;
                                                            i = session.Scorelog.Insert(scroelogModel);
                                                        }
                                                    }
                                                    message = "订单ID" + orderid + "退款到账户余额" + totalmoney;
                                                    //如果订单使用了代金券则取消代金券
                                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                    {
                                                        hashtable = session.GetData.GetDataList("update card set consume='N' where order_id=" + orderid);
                                                    }
                                                }
                                                else
                                                {
                                                    AdminPage.Flow_Insert(userid, adminid, orderid.ToString(), "订单ID" + orderid + "需人工退款" + totalmoney, Flow_Direction.income, totalmoney, Flow_Action.refund);
                                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                    {
                                                        hashtable = session.GetData.GetDataList("update [order] set state='refund',pay_time='" + DateTime.Now + "',credit=0,money=" + totalmoney + " where id=" + orderid);
                                                    }
                                                    message = "订单ID" + orderid + "需人工退款" + totalmoney;
                                                }
                                                //如果订单使用了代金券则取消代金券
                                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                {
                                                    hashtable = session.GetData.GetDataList("update card set consume='N' where order_id=" + orderid);
                                                }
                                            }  
                                        }
                                    }
                                }
                            }

                        }
                    }
                }

            }
            else
                error = "请选择退款方式";

            return error;
        }
        #endregion
        #region 判断是否报警
        public static bool IsWar(ITeam model)
        {
            bool falg = false;
            if (model.inventory < model.invent_war)
            {
                falg = true;
            }
            return falg;
        }
        #endregion

        #endregion

        #region 1管理员入库 2管理员出库 3下单出库 4下单入库
        public static void intoorder(int orderid, int num, int state, int teamid, int userid, string guige, int type)
        {

            Iinventorylog logmodel = AS.GroupOn.App.Store.CreateInventorylog();
            //Maticsoft.Model.inventorylog logmodel = new Maticsoft.Model.inventorylog();
            //Maticsoft.DAL.inventorylog logdal = new Maticsoft.DAL.inventorylog();
            logmodel.num = num;
            logmodel.orderid = orderid;
            if (state == 1)
            {
                logmodel.remark = "管理员入库" + guige;
            }
            else if (state == 2)
            {
                logmodel.remark = "管理员出库" + guige;
            }
            else if (state == 3)
            {
                logmodel.remark = "下单出库" + guige;
            }
            else if (state == 4)
            {
                logmodel.remark = "退单入库" + guige;
            }
            logmodel.teamid = teamid;
            logmodel.state = state;
            logmodel.adminid = userid;
            logmodel.create_time = DateTime.Now;
            logmodel.type = type;
            using (IDataSession session =AS.GroupOn.App.Store.OpenSession(false))
            {
                int s = 0;
                s = session.Inventorylog.Insert(logmodel);
            }
        }
        #endregion
        #region 系统操作

        /// <summary>
        /// 如果订单ID为0 则以项目ID为准
        /// </summary>
        /// <param name="orderid">订单ID</param>
        /// <param name="sysconfig"></param>
        /// <param name="cityname"></param>
        /// <param name="expressid"></param>
        /// <param name="teamid">项目ID</param>
        /// <param name="num">数量</param>
        /// <returns></returns>
        private static decimal System_GetFare(int orderid, NameValueCollection sysconfig, string cityname, int expressid, int teamid, int quantity)
        {
            List<Hashtable> hashtable = null;
            List<Hashtable> hashtable1 = null;
            decimal fare = 0;
            DataTable table = new DataTable();
            string where = " where 1=1 ";
            bool spanprojectems = (sysconfig["spanprojectems"] == "1") ? true : false;
            string sql = String.Empty;
            ArrayList al = new ArrayList();
            IExpressprice expressprice = Store.CreateExpresspric();
            if (spanprojectems)
            {
                if (sysconfig["samefreight_spanprojectems"] == "1")
                {
                    sql = sql + ",fare,freighttype";
                }
                if (sysconfig["sameseller_spanprojectems"] == "1")
                {
                    sql = sql + ",partner_id";
                }
                if (sysconfig["samenumber_spanprojectems"] == "1")
                {
                    sql = sql + ",farefree";
                }
                if (sql.Length > 0)
                {
                    sql = sql.Substring(1);
                }
                string groupby = String.Empty;
                string select = " isnull(SUM(num),0) as sumnum,isnull(MAX(farefree),0) as maxfarefree,isnull(MIN(farefree),0) as minfarefree,isnull(AVG(farefree),0) as avgfarefree";
                if (sql.Length > 0)
                {
                    groupby = " group by " + sql;
                    select = select + "," + sql;
                }
                string s = String.Empty;
                if (orderid > 0)
                    s = "select " + select + " from(select t.*,faretemplate.id as templateid,value as templatevalue from (select t.*,team.Fare,Farefree,freighttype,partner_id from (select teamid,num from [order] left join orderdetail on([order].id=orderdetail.order_id)where [order].id=" + orderid + ")t inner join team on(team.id=t.teamid))t left join faretemplate on(t.freighttype=faretemplate.id))t where farefree>0 " + groupby;
                else//计算项目的
                    s = "select " + select + " from(select t.*,faretemplate.id as templateid,value as templatevalue from (select " + quantity + " as num,team.Fare,Farefree,freighttype,partner_id from team where id=" + teamid + " )t left join faretemplate on(t.freighttype=faretemplate.id))t where farefree>0 " + groupby;


                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    hashtable = seion.GetData.GetDataList(s);
                }

                table = Helper.ConvertDataTable(hashtable);

                string tempwhere = String.Empty;
                for (int i = 0; i < table.Rows.Count; i++)
                {
                    DataRowObject dro = new DataRowObject(table.Rows[i]);
                    if ((Utils.Helper.GetInt(PageValue.CurrentSystemConfig["baoyoushuliang"], 0) == 0 && dro.ToInt("sumnum") >= dro.ToInt("maxfarefree")) || (PageValue.CurrentSystemConfig["baoyoushuliang"] == "1" && dro.ToInt("sumnum") >= dro.ToInt("minfarefree")) || (PageValue.CurrentSystemConfig["baoyoushuliang"] == "2" && dro.ToInt("sumnum") >= dro.ToInt("avgfarefree")))//此条记录免单
                    {
                        bool shu = false;//没有分组需要判断数量
                        if (dro.HasColumnName("fare") && dro.ToInt("fare") > 0)
                        {
                            shu = true;
                            tempwhere = tempwhere + " or (fare<>" + dro["fare"] + ")";
                        }
                        if (dro.HasColumnName("partner_id"))
                        {
                            shu = true;
                            tempwhere = tempwhere + " or (partner_id<>" + dro["partner_id"] + ")";
                        }
                        if (dro.HasColumnName("farefree"))
                        {
                            shu = true;
                            tempwhere = tempwhere + " or (farefree<>" + dro["farefree"] + ")";
                        }
                        if (dro.HasColumnName("freigttype") && dro.IsInt("freigttype") > 0)
                        {
                            shu = true;
                            tempwhere = tempwhere + " or (freighttype<>" + dro["freighttype"] + ")";
                        }
                        if (!shu) tempwhere = tempwhere + " and(farefree=0) ";
                    }
                }
                if (tempwhere.Length > 0)
                {
                    tempwhere = tempwhere.Substring(4);
                    where = where + " and (" + tempwhere + ")";
                }
            }
            else
            {
                where = where + " and (num<farefree or farefree=0)";
            }
            if (orderid > 0)
                sql = "select * from(select t.*,faretemplate.id as templateid,value as templatevalue from (select t.*,team.Fare,Farefree,freighttype,partner_id from (select teamid,num from [order] left join orderdetail on([order].id=orderdetail.order_id)where [order].id=" + orderid + ")t inner join team on(team.id=t.teamid))t left join faretemplate on(t.freighttype=faretemplate.id))t " + where;
            else
                sql = "select * from(select t.*,faretemplate.id as templateid,value as templatevalue from (select team.id as teamid," + quantity + " as num, team.Fare,Farefree,freighttype,partner_id from team where id=" + teamid + ")t left join faretemplate on(t.freighttype=faretemplate.id))t " + where;
            string getexpresspricesql = String.Empty;
            if (expressid > 0)
            {

                ExpresspriceFilter ef = new ExpresspriceFilter();
                ef.expressid = expressid;
                //getexpresspricesql = "select * from expressprice where expressid=" + expressid;
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    expressprice = seion.Expressprice.Get(ef);
                }

            }

            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                hashtable1 = seion.GetData.GetDataList(sql);
            }

            table = Helper.ConvertDataTable(hashtable1);

            int bestteamnum = 1; //项目数量
            decimal bestteamone = 0; //首件价格
            decimal bestteamtwo = 0; //次件价格
            int bestteamnumber = 1;  //最高运费项目递增数量
            decimal bestteamfare = 0; //最高运费
            string parentsid = String.Empty;//记录不同商家ID 之间用, ,分割

            for (int i = 0; i < table.Rows.Count; i++)
            {
                DataRowObject dro = new DataRowObject(table.Rows[i]);

                int num = dro.ToInt("num");
                if (dro.ToInt("freighttype") > 0 && dro["templatevalue"].Length > 0)//启用快递模版
                {
                    Dictionary<string, object> obj = JsonUtils.JsonToObject(dro["templatevalue"]);
                    List<object> objarr = (List<object>)obj["fare"];
                    decimal one = 0;
                    decimal two = 0;
                    int number = 1;
                    for (int j = 0; j < objarr.Count; j++)
                    {
                        Dictionary<string, object> o = (Dictionary<string, object>)objarr[j];
                        string tempcityname = o["cityname"].ToString();
                        if (cityname.Length > 0 && tempcityname.IndexOf(cityname) >= 0) //找到了对应的城市
                        {
                            one = Helper.GetDecimal(o["one"], 0);
                            two = Helper.GetDecimal(o["two"], 0);
                            if (expressprice != null)
                            {
                                one = one + expressprice.oneprice;
                                two = two + expressprice.twoprice;
                            }
                            number = Helper.GetInt(o["number"], 1);
                            break;
                        }
                        else if (tempcityname == "默认城市")
                        {
                            one = Helper.GetDecimal(o["one"], 0);
                            two = Helper.GetDecimal(o["two"], 0);
                            number = Helper.GetInt(o["number"], 1);
                            if (expressprice != null)
                            {
                                one = one + expressprice.oneprice;
                                two = two + expressprice.twoprice;
                            }
                            if (cityname.Length == 0)
                                break;
                        }
                    }
                    if (number < 1) number = 1;
                    decimal temp_fare = 0;
                    int tempnum = num - 1;
                    temp_fare = one + two * (tempnum / number);
                    if (spanprojectems && sysconfig["computemode"] == "2")
                    {
                        if (bestteamfare < temp_fare) //最高运费小于当前运费
                        {
                            if (sysconfig["sameseller_spanprojectems"] == "1" && parentsid.IndexOf("," + dro["partner_id"] + ",") < 0) //还没有加过这个商家的首件运费
                            {
                                fare = fare + temp_fare;
                                parentsid += "," + dro["partner_id"] + ",";
                            }
                            else
                            {
                                fare = fare - bestteamfare + temp_fare + bestteamtwo * ((bestteamnum + 1) / number);
                            }
                            bestteamfare = temp_fare;
                            bestteamnum = num;
                            bestteamnumber = number;
                            bestteamone = one;
                            bestteamtwo = two;
                        }
                        else
                        {
                            if (sysconfig["sameseller_spanprojectems"] == "1" && parentsid.IndexOf("," + dro["partner_id"] + ",") < 0) //还没有加过这个商家的首件运费
                            {
                                fare = fare + temp_fare;
                                parentsid += "," + dro["partner_id"] + ",";
                            }
                            else
                            {
                                fare = fare + temp_fare - one + two;
                            }
                        }
                    }
                    else
                    {
                        fare = fare + temp_fare;
                    }

                }
                else
                {
                    if (spanprojectems && sysconfig["computemode"] == "2")
                    {
                        decimal temp_fare = dro.ToDecimal("fare");
                        if (temp_fare > bestteamfare)
                        {
                            if (sysconfig["sameseller_spanprojectems"] == "1" && parentsid.IndexOf("," + dro["partner_id"] + ",") < 0) //还没有加过这个商家的首件运费
                            {
                                fare = fare + temp_fare;
                                parentsid += "," + dro["partner_id"] + ",";

                            }
                            else
                            {
                                fare = fare - bestteamfare + temp_fare + bestteamtwo * (bestteamnum);
                            }
                            bestteamfare = temp_fare;
                            bestteamnum = num;
                            bestteamnumber = 1;
                            bestteamone = temp_fare;
                            bestteamtwo = 0;
                        }
                    }
                    else
                    {
                        string falg = "0";
                        for (int j = 0; j < al.Count; j++)
                        {
                            if (al.Contains(dro["teamid"].ToString()))
                            {
                                falg = "1";
                            }
                        }
                        al.Add(dro["teamid"].ToString());
                        if (falg == "0")
                            fare = fare + dro.ToDecimal("fare");
                    }


                }

            }


            return fare;
        }

        #region 计算运费
        /// <summary>
        /// 计算运费
        /// </summary>
        /// <param name="orderid">订单ID</param>
        /// <param name="sysconfig">配置信息</param>
        /// <param name="cityname">城市名称 没有则为空</param>
        /// <param name="expressid">快递公司ID 没有则为0</param>
        /// <returns></returns>
        public static decimal System_GetFare(int orderid, NameValueCollection sysconfig, string cityname, int expressid)
        {

            return System_GetFare(orderid, sysconfig, cityname, expressid, 0, 0);

        }
        /// <summary>
        /// 计算运费
        /// </summary>
        /// <param name="teamid">项目ID</param>
        /// <param name="quantity">购买数量</param>
        /// <param name="sysconfig">config信息</param>
        /// <param name="cityname">城市名称</param>
        /// <param name="expressid">快递公司ID</param>
        /// <returns></returns>
        public static decimal System_GetFare(int teamid, int quantity, NameValueCollection sysconfig, string cityname, int expressid)
        {

            return System_GetFare(0, sysconfig, cityname, expressid, teamid, quantity);

        }
        #endregion



        #endregion

        #region 查询用户的等级所匹配的打折率.
        public static float GetUserLevelMoney(decimal totalamount)
        {
            double money = 1;
            //float money = 1;
            IList<IUserlevelrules> listulr = null;
            IUserlevelrules Userlevelrules = Store.CreateUserlevelrules();
            UserlevelrulesFilters ulf = new UserlevelrulesFilters();
            UserlevelrulesFilters ulf1 = new UserlevelrulesFilters();
            ulf.totalamount = totalamount;
            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                listulr = seion.Userlevelrelus.GetList(ulf);
            }
            if (listulr != null && listulr.Count > 0)
            {
                money = listulr[0].discount;
            }

            ulf1.AddSortOrder(UserlevelrulesFilters.MAXMONEY_DESC);
            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                Userlevelrules = seion.Userlevelrelus.Get(ulf1);
            }

            if (Userlevelrules != null)
            {
                if (totalamount > Userlevelrules.maxmoney)
                {
                    money = Userlevelrules.discount;
                }
            }
            return float.Parse(money.ToString());
        }
        #endregion

        #region 查询此项目是否存在商户优惠券
        public static bool isCoupon(int teamid)
        {
            bool falg = false;
            PcouponFilter pf = new PcouponFilter();
            IList<IPcoupon> listPcoupon = null;

            pf.teamid = teamid;
            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                listPcoupon = seion.Pcoupon.GetList(pf);
            }

            if (listPcoupon != null && listPcoupon.Count > 0)
            {
                falg = true;
            }

            return falg;
        }
        #endregion


        #region 用户取消订单
        public static string User_CancelOrder(IOrder ordermodel, int teamid)
        {
            CardFilter cardefile = new CardFilter();
            IList<ICard> icard = null;
            ICard icards = null;

            OrderDetailFilter orderdetafile = new OrderDetailFilter();
            IList<IOrderDetail> iorderdeta = null;
            orderdetafile.Order_ID = ordermodel.Id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iorderdeta = session.OrderDetail.GetList(orderdetafile);
            }

            OrderFilter orderfile = new OrderFilter();
            IList<IOrder> iorder = null;
            orderfile.Team_id = Convert.ToInt32(teamid);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iorder = session.Orders.GetList(orderfile);
            }
            IOrder iorders = null;
            string error = String.Empty;
            // Maticsoft.DAL.Order mbod = new Maticsoft.DAL.Order();
            //处理过程 该订单必须为未付款状态 不应为其他状态

            if (Utils.Helper.GetInt(teamid, 0) == 0)//购物车
            {
                foreach (IOrderDetail model in iorderdeta)
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        cardefile.Team_id = Convert.ToInt32(model.Teamid);
                        cardefile.Order_id = Convert.ToInt32(model.Order_id);
                        icard = session.Card.GetList(cardefile);
                    }
                    if (icards != null)
                    {
                        icards.Team_id = 0;
                        icards.Partner_id = 0;
                        icards.consume = "N";
                        icards.Order_id = 0;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int i = 0;
                            i = session.Card.Update(icards);
                        }

                    }
                }
            }
            else
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    cardefile.Team_id = teamid;
                    cardefile.Order_id = ordermodel.Id;
                    icard = session.Card.GetList(cardefile);
                }
                if (icards != null)
                {
                    icards.Team_id = 0;
                    icards.Partner_id = 0;
                    icards.consume = "N";
                    icards.Order_id = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int i = 0;
                        i = session.Card.Update(icards);
                    }
                }
            }

            //using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            //{

            //    iorders = session.Orders.GetByID(iorder[0].Id);
            //}
            ordermodel.State = "cancel";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int i = 0;
                i = session.Orders.Update(ordermodel);
            }
            return error;
        }
        #endregion

        #region 用户发表商品评价操作
        /// <summary>
        /// 用户发表商品评价
        /// </summary>
        /// <param name="score">评分</param>
        /// <param name="comment">内容</param>
        /// <param name="userid">用户ID</param>
        /// <param name="teamid">项目ID</param>
        /// <param name="sysconfig">配置文件</param>
        /// <returns></returns>
        public static string User_ReView(int score, string type, string comment, int userid, int teamid, NameValueCollection sysconfig)
        {
            string error = String.Empty;
            //处理过程判断内容是否为空，用户ID,项目ID是否大于0评论返现 flow表 action='review'
            //判断内容是否为空，项目ID，用户ID是否大于0
            ITeam teammodel = null;
            TeamFilter teamft = new TeamFilter();
            if (comment.Trim() != "" && userid > 0 && teamid > 0)
            {
                //1.该用户是否购买过这个项目，如果购买进行，下一步判断,否则退出操作
                //DataTable dt = Maticsoft.DBUtility.DbHelperSQL.SelectByFilter("[Service]", "(Team_id=" + teamid + " or TeamId=" + teamid + ") and (State='pay' or State='scorepay') and User_id=" + userid + "", "[Service] desc", "[order] left join orderdetail on [order].Id=orderdetail.order_id");
                List<Hashtable> hs = null;
                List<Hashtable> hs2 = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    hs = session.GetData.GetDataList("select [Service] from [order] left join orderdetail on [order].Id=orderdetail.order_id  where (Team_id=" + teamid + " or TeamId=" + teamid + ") and (State='pay' or State='scorepay') and User_id=" + userid + " order by [Service] desc");

                }
                if (hs.Count > 0)
                {
                    decimal price = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        teammodel = session.Teams.GetByID(teamid);
                    }
                    //teammodel = teamdal.GetModel(teamid);
                    if (teammodel != null)
                    {
                        price = Utils.Helper.GetDecimal(teammodel.commentscore, 0);//买家评论返利金额根据项目来
                    }
                    if (price == 0)
                    {
                        if (sysconfig["userreview_rebate"] != null && sysconfig["userreview_rebate"].ToString().Trim() != "")
                        {
                            price = Convert.ToDecimal(sysconfig["userreview_rebate"].ToString());
                        }
                    }
                    bool result = false;
                    int id3 = 0;
                    //2.该用户是否参与评论过，如果没有评论则进行下一步操作，否则退出操作
                    //DataTable dt1 = Maticsoft.DBUtility.DbHelperSQL.SelectByFilter("Id", "user_id=" + userid + " and (partner_id=0 or partner_id is null) and team_id=" + teamid + "", "Id desc", "userreview");

                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        hs2 = session.GetData.GetDataList("select Id from userreview  where user_id=" + userid + " and (partner_id=0 or partner_id is null) and team_id=" + teamid + " order by Id desc");

                    }
                    if (hs2.Count <= 0)
                    {
                        if (!(sysconfig["UserreviewYN"] != null && sysconfig["UserreviewYN"].ToString().Trim() == "1"))
                        {
                            result = true; //true自动 false 手动
                        }
                        UserReviewFilter userreviewft = new UserReviewFilter();
                        IUserReview userreviewModel = AS.GroupOn.App.Store.CreateUserReview();
                        FlowFilter flowft = new FlowFilter();
                        IFlow flowModel = AS.GroupOn.App.Store.CreateFlow();
                        UserFilter userft = new UserFilter();
                        IUser userModel = null;

                        userreviewModel.comment = HttpContext.Current.Server.HtmlEncode(comment);
                        userreviewModel.user_id = userid;
                        userreviewModel.team_id = teamid;
                        userreviewModel.score = score;
                        userreviewModel.type = type;
                        userreviewModel.create_time = DateTime.Now;
                        if (result)
                        {
                            userreviewModel.rebate_price = price;
                            userreviewModel.rebate_time = System.DateTime.Now;
                            userreviewModel.admin_id = 0;
                            userreviewModel.state = 1;
                        }
                        try
                        {
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                id3 = session.UserReview.Insert(userreviewModel);
                            }
                            sysconfig = new NameValueCollection();
                            //3.判断返利金额
                            //是否为手动

                            if (result)
                            {
                                //3.1更新用户表
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    userModel = session.Users.GetByID(userid);
                                }
                                if (userModel != null)
                                {
                                    userModel.Money += price;
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        int id2 = session.Users.Update(userModel);
                                    }
                                }
                                //3.2先查找刚增加的买家评论ID

                                if (id3 > 0)
                                {
                                    //3.3增加消费记录
                                    flowModel.Detail_id = id3.ToString();
                                    flowModel.Action = "review";
                                    flowModel.Direction = "income";
                                    flowModel.User_id = userid;
                                    flowModel.Money = price;
                                    flowModel.Admin_id = 0;
                                    flowModel.Create_time = DateTime.Now;
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        int id = session.Flow.Insert(flowModel);
                                    }
                                }

                            }


                            error = "";
                        }
                        catch (Exception e)
                        {

                            error = "评论失败";
                        }

                    }
                    else
                    {
                        error = "已参与过评论";
                    }
                }
                else
                {
                    error = "没有购买过此项目";
                }
            }
            else
            {
                error = "内容为空";
            }
            return error;
        }

        #endregion
        #region
        /// <summary>
        /// 用户发表商户评价操作
        /// </summary>
        /// <param name="score"></param>
        /// <param name="type"></param>
        /// <param name="comment"></param>
        /// <param name="userid"></param>
        /// <param name="partnerid"></param>
        /// <param name="teamid"></param>
        /// <param name="sysconfig"></param>
        /// <returns></returns>
        public static string User_ReViewP(int score, int isGo, string type, string comment, int userid, int partnerid, int teamid, NameValueCollection sysconfig)
        {
            string error = String.Empty;
            //评论内容、用户、商家、项目、评分、是否再去不能为空
            if (comment.Trim() != "" && userid > 0 && partnerid > 0 && teamid > 0 && (isGo == 0 || isGo == 1))
            {
                //该用户是否购买过这个项目，如果购买进行，下一步判断,否则退出操作
                List<Hashtable> hs = null;
                List<Hashtable> hs2 = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    hs = session.GetData.GetDataList("select [Service] from [order] left join orderdetail on [order].Id=orderdetail.order_id  where (Team_id=" + teamid + " or TeamId=" + teamid + ") and (State='pay' or State='scorepay') and User_id=" + userid + " order by [Service] desc");

                }
                //DataTable dt = Maticsoft.DBUtility.DbHelperSQL.SelectByFilter("[Service]", "(Team_id=" + teamid + " or TeamId=" + teamid + ") and (State='pay' or State='scorepay') and User_id=" + userid + "", "[Service] desc", "[order] left join orderdetail on [order].Id=orderdetail.order_id");
                if (hs.Count > 0)
                {
                    //商家是否正确\
                    TeamFilter teamft = new TeamFilter();
                    ITeam team = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        team = session.Teams.GetByID(teamid);
                    }
                    if (team.Partner_id == partnerid)
                    {
                        //是否已经评论过
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            hs2 = session.GetData.GetDataList("select count(1) as count from userreview  where user_id= " + userid + "  and partner_id= " + partnerid + " and team_id= " + teamid + " and type='partner' ");
                        }
                        if (hs2[0]["count"].ToString() == "0")
                        {
                            IUserReview userreview = AS.GroupOn.App.Store.CreateUserReview();
                            userreview.type = "partner";
                            userreview.user_id = userid;
                            userreview.team_id = teamid;
                            userreview.partner_id = partnerid;
                            userreview.comment = comment;
                            userreview.score = score;
                            userreview.isgo = isGo;
                            userreview.create_time = DateTime.Now;
                            userreview.rebate_price = 0;
                            if (sysconfig["doUserreviewPartner"] != null && sysconfig["doUserreviewPartner"] == "1")
                            {
                                userreview.state = 1;
                            }
                            else
                            {
                                userreview.state = 0;
                            }
                            userreview.admin_id = 0;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id = session.UserReview.Insert(userreview);
                            }
                        }
                        else
                        {
                            error = "已经评论过了";
                        }
                    }
                    else
                    {
                        error = "商户不正确";
                    }
                }
                else
                {
                    error = "没有购买过此项目";
                }
            }
            else
            {
                error = "内容为空";
            }
            return error;
        }
        #endregion

        #region 设置某快递公司不能送到的城市
        /// <summary>
        /// 设置某快递公司不能送到的城市
        /// </summary>
        /// <param name="cityid">城市ID</param>
        /// <param name="expressid">快递公司ID</param>
        /// <param name="no">true 为不送 false为送</param>
        /// <returns></returns>
        public static string Manager_SetNoCitys(int cityid, int expressid, bool no)
        {
            string error = String.Empty;
            string citys = String.Empty;
            if (cityid > 0 && expressid > 0)
            {
                IExpressnocitys expressnocitys = Store.CreateExpressnocitys();
                ExpressnocitysFilter expressfilter = new ExpressnocitysFilter();
                expressfilter.expressid = expressid;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    expressnocitys = session.Expressnocitys.Get(expressfilter);
                }
                if (expressnocitys != null)
                {
                    citys = expressnocitys.nocitys;

                }
                citys = "," + citys + ",";
                if (no)
                {
                    if (citys.Length > 0)
                    {
                        if (citys.IndexOf("," + cityid.ToString() + ",") < 0)
                            citys = citys + cityid + ",";

                    }
                    else
                        citys = "," + cityid.ToString() + ",";
                    citys = citys.Trim(',');
                    if (expressnocitys == null)
                    {
                        IExpressnocitys exprecity = Store.CreateExpressnocitys();
                        exprecity.expressid = expressid;
                        exprecity.nocitys = citys;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int insertresult = session.Expressnocitys.Insert(exprecity);
                        }
                    }
                    else
                    {
                        expressnocitys.expressid = expressid;
                        expressnocitys.nocitys = citys;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int updateresult = session.Expressnocitys.UpdateNocitys(expressnocitys);

                        }
                    }
                }

                else
                {
                    if (citys.Length > 0)
                    {
                        if (citys.IndexOf("," + cityid.ToString() + ",") >= 0)
                        {
                            citys = citys.Replace("," + cityid + ",", ",");
                        }
                        citys = citys.Trim(',');
                    }
                    if (expressnocitys == null)
                    {
                        IExpressnocitys exprecity = Store.CreateExpressnocitys();
                        exprecity.expressid = expressid;
                        exprecity.nocitys = citys;
                        //expressnocitys.expressid = expressid;
                        //expressnocitys.nocitys = citys;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int insertresult = session.Expressnocitys.Insert(exprecity);
                        }
                    }
                    else
                    {
                        expressnocitys.expressid = expressid;
                        expressnocitys.nocitys = citys;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int updateresult = session.Expressnocitys.UpdateNocitys(expressnocitys);

                        }
                    }
                }


            }
            return error;
        }


        #endregion

        #region 将用户评价设置为有效
        /// <summary>
        /// 将用户评价设置为有效
        /// </summary>
        /// <param name="reviewid">评价ID</param>
        /// <param name="sysconfig">系统配置文件</param>
        /// <param name="adminid">管理员ID</param>
        /// <returns></returns>
        public static string Manager_SetValidUserReview(int reviewid, NameValueCollection sysconfig, int adminid)
        {    

            string error = String.Empty;
            //设置为有效 1评价为无效2更新相应的字段3返利并flow写入

            //viewmodel = viewdal.GetModel(reviewid);//得到一个实体
            //usermodel = userdal.GetModel(viewmodel.user_id);//得到用户实体
            //Maticsoft.DAL.Flow flowdal = new Maticsoft.DAL.Flow();//消费记录业务
            //Maticsoft.Model.Flow flowmodel = new Maticsoft.Model.Flow();//消费记录实体
            IFlow flowmodel = AS.GroupOn.App.Store.CreateFlow();
            IUserReview viewmodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                viewmodel = session.UserReview.GetByID(reviewid);
            }

            IUser usermodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                usermodel = session.Users.GetByID(viewmodel.user_id);
            }
            string userview = sysconfig["UserreviewYN"];
            if (viewmodel.state == 0 && viewmodel.state != 2)
            {
                if (sysconfig["UserreviewYN"] != null && sysconfig["UserreviewYN"].ToString() != "")//如果为无效，修改有效
                {
                    flowmodel.Action = "review";
                    flowmodel.Admin_id = adminid;
                    flowmodel.Create_time = DateTime.Now;
                    if (sysconfig["userreview_rebate"] != null && sysconfig["userreview_rebate"].ToString() != "")
                    {
                        flowmodel.Money = decimal.Parse(sysconfig["userreview_rebate"].ToString());//设置买家评论返利金额
                    }

                    flowmodel.Direction = "income";
                    flowmodel.User_id = viewmodel.user_id;
                    flowmodel.Detail_id = reviewid.ToString();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int i = session.Flow.Insert(flowmodel);
                    }
                   // flowdal.Add(flowmodel);
                    viewmodel.state = 1;//有效地状态

                    //修改用户账号余额
                    if (sysconfig["userreview_rebate"] != null && sysconfig["userreview_rebate"].ToString() != "")
                    {
                        usermodel.Money = usermodel.Money + decimal.Parse(sysconfig["userreview_rebate"].ToString());
                    }
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int i = session.Users.Update(usermodel);
                    }
                   // userdal.Update(usermodel);

                    if (sysconfig["userreview_rebate"] != null && sysconfig["userreview_rebate"].ToString() != "")
                    {
                        viewmodel.rebate_price = decimal.Parse(sysconfig["userreview_rebate"].ToString());
                    }
                    viewmodel.admin_id = adminid;
                    viewmodel.rebate_time = DateTime.Now;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int i = session.UserReview.Update(viewmodel);
                    }
                   // viewdal.Update(viewmodel);
                    error = "";
                }
                else
                {
                    error = "友情提示:您没有设置手动返利，请设置";
                }
            }
            else
            {
                error = "友情提示：用户评价为有效，无法进行修改";
            }


            return error;
        }
        #endregion

    }


}