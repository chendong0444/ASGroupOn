using System;
using System.Collections.Generic;
using System.Text;
using AS.Common.Utils;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.Domain;
using System.Web;
using System.Collections.Specialized;
using System.Net;
namespace AS.GroupOn.Events
{
   public class Event
    {
       /// <summary>
       /// 订单付款
       /// </summary>
       /// <param name="payid">交易单号</param>
       /// <param name="money">在线付款金额，如果是余额付款请写0</param>
       /// <param name="service">付款方式</param>
       /// <returns></returns>
       public EventResult OrderPay(string payid, decimal money, string service,DateTime paytime)
       {
           EventResult result = new EventResult();
           string[] values = payid.Split(new string[] { "as" },StringSplitOptions.RemoveEmptyEntries);
           if (values.Length != 4)
           {
               result.Message = "交易单号格式不正确";
               result.Result = false;
               return result;
           }
           int teamid = Helper.GetInt(values[0],0);
           int userid = Helper.GetInt(values[1], 0);
           int orderid = Helper.GetInt(values[2], 0);
           if (userid == 0 || orderid == 0)
           {
               result.Message = "交易单号不正确";
               result.Result = false;
               return result;
           }
           IOrder order = null;
           IUser user = null;
           IInvite invite = null;
           OrderFilter of=new OrderFilter();
           List<ICoupon> couponList = new List<ICoupon>();//生成的优惠券
           List<IOrder> orderList = new List<IOrder>();//拆分的订单
           IFlow flow = null;//消费记录
           IPay pay = null;//付款记录
           of.User_id=userid;
           of.Id=orderid;
           InviteFilter ifilter = new InviteFilter();
           ifilter.Other_user_id = userid;
           ifilter.Pay = "N";
           using (IDataSession session = App.Store.OpenSession(false))
           {
               order = session.Orders.Get(of);
               user = session.Users.GetByID(userid);
               invite = session.Invite.Get(ifilter);
               pay = session.Pay.GetByID(payid);
           }
           if (pay != null)
           {
               result.Message = "付款记录已存在";
               result.Result = false;
               return result;
           }
           if (user == null)
           {
               result.Message = "不存在的用户";
               result.Result = false;
               return result;
           }
           if (order == null)
           {
               result.Message = "不存在的订单";
               result.Result = false;
               return result;
           }
           if (order.State == "pay" || order.State == "scorepay")
           {
               result.Message = "订单是已付款状态";
               result.Result = false;
               return result;
           }
           if (money + user.Money < order.Origin)
           {
               result.Message = "付款金额不正确";
               result.Result = false;
               return result;
           }
           order.Money = money;
           order.Pay_time = paytime;
           order.Credit = order.Origin - order.Money;
           order.State = "pay";
           user.Money = user.Money - order.Credit;
           if (invite != null)//被邀请来的
           {
               invite.Pay = "Y";
               ITeam bonusTeam=null;
               for (int i = 0; i < order.Teams.Count; i++)
               {
                   ITeam tempteam=order.Teams[i];
                   if (bonusTeam == null)
                       bonusTeam = tempteam;
                   else if (bonusTeam.Bonus < tempteam.Bonus)
                       bonusTeam = tempteam;
                   
               }
               if (bonusTeam != null)
               {
                   invite.Team_id = bonusTeam.Id;
                   invite.Credit = bonusTeam.Bonus;
               }
           }
           pay = App.Store.CreatePay();
           pay.Id = payid;
           pay.Money = money;
           pay.Order_id = orderid;
           pay.Service = service;
           pay.Bank = WebUtils.GetBank(service);
           pay.Create_time = DateTime.Now;
           pay.Currency = "CNY";
           
           flow = App.Store.CreateFlow();
           flow.Action = "buy";
           flow.Create_time = DateTime.Now;
           flow.Detail = "订单" + orderid + "在线付款" + money+"元";
           flow.Detail_id = payid;
           flow.Direction = "expense";
           flow.User_id = order.User_id;
           flow.Money = money;

           if (order.Team_id == 0)//走购物车
           {

               for (int i = 0; i < order.OrderDetail.Count; i++)
               {
                   IOrderDetail orderdetail = order.OrderDetail[i];
                   if (orderdetail.Team.Min_number > orderdetail.Team.Now_number && (orderdetail.Team.Now_number + orderdetail.Num) > orderdetail.Team.Min_number)
                   {
                       orderdetail.Team.Reach_time = DateTime.Now;
                   }
                   orderdetail.Team.Now_number = orderdetail.Team.Now_number + orderdetail.Num;
                   if (orderdetail.Team.Max_number > 0 && orderdetail.Team.Now_number >= orderdetail.Team.Max_number)
                   {
                       orderdetail.Team.Close_time = DateTime.Now;
                   }
                   if (orderdetail.Team.open_invent == 1)//开启库存
                   {
                       orderdetail.Team.inventory = orderdetail.Team.inventory - orderdetail.Num;
                       if (orderdetail.Team.inventory <= 0) orderdetail.Team.status = 8;
                       orderdetail.Team.invent_result = WebUtils.AddInventory(orderdetail.result, orderdetail.Team.invent_result, 1);
                   }
                   if (i == 0)
                   {
                       order.Partner_id = orderdetail.Team.Partner_id;
                       order.TempID = StringUtils.GetRandomString(6);

                   }
                   else
                   {
                       if (order.Partner_id == orderdetail.Team.Partner_id)
                       {
                           orderdetail.TempOrderID = order.TempID;
                       }
                       else
                       {
                           bool find = false;
                           for (int j = 0; j < orderList.Count; j++)
                           {
                               IOrder temporder = orderList[j];
                               if (temporder.Partner_id == orderdetail.Team.Partner_id)
                               {
                                   orderdetail.TempOrderID = temporder.TempID;
                                   find = true;
                                   decimal tempmoney=orderdetail.Teamprice * orderdetail.Num;
                                   temporder.Origin = temporder.Origin + tempmoney;
                                   if (order.Money >= tempmoney)
                                   {
                                       temporder.Money = temporder.Money + tempmoney;
                                       order.Money = order.Money - tempmoney;
                                   }
                                   else
                                   {
                                       temporder.Money = temporder.Money + order.Money;
                                       tempmoney = tempmoney - order.Money;
                                       order.Money = 0;
                                       if (order.Credit >= tempmoney)
                                       {
                                           temporder.Credit = temporder.Credit + tempmoney;
                                           order.Credit = order.Credit - tempmoney;
                                       }
                                       else
                                       {
                                           temporder.Credit = temporder.Credit + order.Credit;
                                           tempmoney = tempmoney - order.Credit;
                                           order.Credit = 0;

                                       }
                                   }
                                   break;
                               }
                           }
                           if (!find)
                           {
                               IOrder torder = WebUtils.GetObjectClone<IOrder>(order);
                               torder.TempID = StringUtils.GetRandomString(6);
                               orderdetail.TempOrderID = torder.TempID;
                               find = true;
                               decimal tempmoney = orderdetail.Teamprice * orderdetail.Num;
                               torder.Origin =  tempmoney;
                               if (order.Money >= tempmoney)
                               {
                                   torder.Money =  tempmoney;
                                   order.Money = order.Money - tempmoney;
                               }
                               else
                               {
                                   torder.Money = torder.Money + order.Money;
                                   tempmoney = tempmoney - order.Money;
                                   order.Money = 0;
                                   if (order.Credit >= tempmoney)
                                   {
                                       torder.Credit = torder.Credit + tempmoney;
                                       order.Credit = order.Credit - tempmoney;
                                   }
                                   else
                                   {
                                       torder.Credit = torder.Credit + order.Credit;
                                       tempmoney = tempmoney - order.Credit;
                                       order.Credit = 0;

                                   }
                               }
                               orderList.Add(torder);
                           }
                       }
                   }
                   
               }
           }
           else
           {
               if (order.Team.Min_number > order.Team.Now_number && (order.Team.Now_number + order.Quantity) > order.Team.Min_number)
               {
                   order.Team.Reach_time = DateTime.Now;
                   if (order.Express == "N")//优惠券订单,需要生成优惠券号并发送短信
                   {
                       IList<IOrder> orders = null;//没有生成优惠券的订单
                       OrderFilter of1 = new OrderFilter();
                       of1.NoCouponTeamID = order.Team_id;
                       using (IDataSession session = App.Store.OpenSession(false))
                       {
                           orders = session.Orders.GetList(of1);
                       }
                       for (int i = 0; i < orders.Count; i++)
                       {
                           IOrder temporder = orders[i];
                           for (int j = 0; j < temporder.Quantity; j++)
                           {
                               ICoupon coupon = App.Store.CreateCoupon();
                               coupon.Consume = "N";
                               coupon.Create_time = DateTime.Now;
                               coupon.Credit = temporder.Team.Credit;
                               coupon.Expire_time = temporder.Team.Expire_time;
                               coupon.Id = StringUtils.GetRandomString(12);
                               coupon.Order_id = temporder.Id;
                               coupon.Partner_id = temporder.Team.Partner_id;
                               coupon.Secret = StringUtils.GetRandomString(6);
                               coupon.Sms = 1;
                               coupon.Sms_time = DateTime.Now;
                               if (temporder.Team.start_time.HasValue)
                                   coupon.start_time = temporder.Team.start_time.Value;
                               else
                                   coupon.start_time = temporder.Team.Begin_time;
                               coupon.Type = "consume";
                               coupon.User_id = temporder.User_id;
                               couponList.Add(coupon);
                           }
                       }
                   }
               }
               else if(order.Team.Min_number <= order.Team.Now_number) //只给此订单发送优惠券
               {
                   for (int j = 0; j < order.Quantity; j++)
                   {
                       ICoupon coupon = App.Store.CreateCoupon();
                       coupon.Consume = "N";
                       coupon.Create_time = DateTime.Now;
                       coupon.Credit = order.Team.Credit;
                       coupon.Expire_time = order.Team.Expire_time;
                       coupon.Id = StringUtils.GetRandomString(12);
                       coupon.Order_id = order.Id;
                       coupon.Partner_id = order.Team.Partner_id;
                       coupon.Secret = StringUtils.GetRandomString(6);
                       coupon.Sms = 1;
                       coupon.Sms_time = DateTime.Now;
                       if (order.Team.start_time.HasValue)
                           coupon.start_time = order.Team.start_time.Value;
                       else
                           coupon.start_time = order.Team.Begin_time;
                       coupon.Type = "consume";
                       coupon.User_id = order.User_id;
                       couponList.Add(coupon);
                   }
               }
               order.Team.Now_number = order.Team.Now_number + order.Quantity;
               if (order.Team.Max_number > 0 && order.Team.Now_number >= order.Team.Max_number)
               {
                   order.Team.Close_time = DateTime.Now;
               }
               if (order.Team.open_invent == 1)//开启库存
               {
                   order.Team.inventory = order.Team.inventory - order.Quantity;
                   if (order.Team.inventory <= 0)
                   {
                       order.Team.status = 8;
                   }
                   order.Team.invent_result = WebUtils.AddInventory(order.result, order.Team.invent_result, 1);
               }
               
           }

           using (IDataSession session = App.Store.OpenSession(true))
           {
               for (int i = 0; i < couponList.Count; i++)
               {
                   session.Coupon.Insert(couponList[i]);
               }
               session.Flow.Insert(flow);
               if (invite != null)
                   session.Invite.Update(invite);
               session.Orders.Update(order);
               if (order.Team_id == 0)
               {
                   for (int i = 0; i < orderList.Count; i++)
                   {
                       int oid = session.Orders.Insert(orderList[i]);
                       for (int j = 0; j < order.OrderDetail.Count; j++)
                       {
                           if (order.OrderDetail[j].TempOrderID == orderList[i].TempID)
                           {
                               order.OrderDetail[j].Order_id = oid;
                               session.OrderDetail.Update(order.OrderDetail[j]);
                               session.Teams.Update(order.OrderDetail[j].Team);
                           }
                       }
                   }
               }
               else
               {
                   session.Teams.Update(order.Team);
               }
               session.Pay.Insert(pay);
               session.Users.Update(user);
               session.Commit();
           }
           result.Result = true;
           return result;

       }

       public EventResult PushCps(int orderid,HttpCookie cpscookie)
       {
           EventResult result = new EventResult();
           result.Result = false;
           result.Message = "不是cps订单";
           if (cpscookie != null)
           {
               ICps cps = null;
               IOrder order = null;
               using (IDataSession session = App.Store.OpenSession(false))
               {
                   order = session.Orders.GetByID(orderid);
               }
               if (order == null)
               {
                   result.Message = "订单不能为空";
                   result.Result = false;
                   return result;
               }
               NameValueCollection cpsvalues = cpscookie.Values;
               string cpsname = cpsvalues["cpsname"];
               if (!String.IsNullOrEmpty(cpsname))
               {
                   WebClient wc = new WebClient();
                   string r = String.Empty;//推送返回结果
                   string u = String.Empty;
                   switch (cpsname)
                   {
                       case "yiqifa":
                           string productnames = String.Empty;
                           foreach (ITeam team in order.Teams)
                           {
                               productnames = productnames + "," + team.Product;
                           }
                           if (productnames.Length > 0) productnames = productnames.Substring(1);

                           u = "http://o.yiqifa.com/servlet/handleCpsIn?cid=" + Utils.Helper.GetString(cpsvalues["cid"], String.Empty) + "&wi=" + Utils.Helper.GetString(cpsvalues["wi"], String.Empty) + "&on=" + order.Id + "&ta=1&pp=" + (order.Origin - order.Fare) + "&pna=" + HttpContext.Current.Server.UrlEncode(productnames) + "&sd=" + order.Create_time.ToString("yyyy-MM-dd HH:mm:ss") + "&encoding=utf-8";
                           r = wc.DownloadString(u);
                           cps.channelId = "yiqifa";
                           cps.result = u + "，通知结果：" + r;
                           break;
                       case "tuan800":
                           u = "http://cps.tuan800.com/handleCpsIn?sk=" + cpsvalues["sk"] + "&cid=" + cpsvalues["cid"] + "&wi=" + cpsvalues["wi"] + "&uid=" + cpsvalues["uid"] + "&on=" + order.Id + "&ta=1&pp=" + Convert.ToInt32((order.Origin - order.Fare) * 100) + "&sd=" + Utils.Helper.GetTimeFix(order.Create_time) + "000&status=0&encoding=utf-8&sign=" + Utils.Helper.MD5(cpsvalues["sk"] + "|" + cpsvalues["cid"] + "|" + cpsvalues["wi"] + "|" + cpsvalues["uid"] + "|" + order.Id + "|" + "1" + "|" + Convert.ToInt32((order.Origin - order.Fare) * 100) + "|" + Utils.Helper.GetTimeFix(order.Create_time) + "000|" + "0" + "|" + cpsvalues["sk"] + "|" + cpsvalues["ss"]);
                           string p_cd = String.Empty;
                           string p_price = String.Empty;
                           string it_cnt = String.Empty;
                           string comm = String.Empty;
                           string c_cd = String.Empty;
                           decimal zongyongjin = 0;
                           decimal yongjin = 0;
                           for (int i = 0; i < order.Teams.Count; i++)
                           {
                               p_cd = p_cd + order.Teams[i].Id + "|_|";
                               p_price = p_price + Convert.ToInt32(order.Price * 100) + "|_|";
                               it_cnt = it_cnt + order.Quantity + "|_|";
                               yongjin = order.Price * 100 * 0.15M;
                               comm = comm + ((yongjin).ToString("0")) + "|_|";
                               zongyongjin = zongyongjin + yongjin;
                               c_cd = c_cd + "0|_|";
                           }
                           u = u + "&p_cd=" + p_cd + "&price=" + p_price + "&t_comm=" + zongyongjin.ToString("0") + "&c_cd=" + c_cd + "&it_cnt=" + it_cnt + "&comm=" + comm;
                           r = wc.DownloadString(u);
                           cps.result = u;
                           cps.channelId = "tuan800";
                           cps.username = r;
                           break;

                   }
               }


           }
           return result;
       }

    }
}
