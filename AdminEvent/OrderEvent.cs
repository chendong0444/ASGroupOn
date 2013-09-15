using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Controls;
using System.Data;
using AS.GroupOn.Domain.Spi;
using AS.Common.Utils;
using AS.GroupOn.DataAccess.Filters;
using System.Collections.Specialized;
using AS.GroupOn.App;
using System.Linq;

namespace AS.AdminEvent
{
    /// <summary>
    /// 订单后台事件
    /// </summary>
    public class OrderEvent
    {

        #region 订单备注事件
        /// <summary>
        /// 管理员给订单加备注（只允许管理员查看) 
        /// </summary>
        /// <param name="adminname">管理员帐号</param>
        /// <param name="content">备注内容</param>
        public static string Manager_AddReMark(int adminid, string content, int orderid)
        {
            string error = String.Empty;
            //处理代码
            content = content.Replace("|", "").Replace("^", "");
            if (content.Length == 0)
            {
                error = "备注内容不能为空！";
                return error;
            }
            if (adminid == 0)
            {
                error = "添加备注的管理员不能为空！";
                return error;
            }
            IOrder order = null;
            IUser user = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                order = session.Orders.GetByID(orderid);
                user = session.Users.GetByID(adminid);
            }
            if (order == null && user == null)
            {
                error = "不存在此订单或此管理员！";
                return error;
            }
            else
            {
                string adminremark = "";
                if (order.adminremark != null)
                    adminremark = order.adminremark + "^" + DateTime.Now + "|" + user.Username + "|" + content;
                else
                    adminremark = DateTime.Now + "|" + user.Username + "|" + content;
                order.adminremark = adminremark;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int i = session.Orders.Update(order);
                    if (i > 0)
                        return error;
                }
            }
            return error;
        }
        /// <summary>
        /// 返回订单管理员备注信息
        /// </summary>
        /// <param name="orderid"></param>
        /// <returns></returns>
        public static StringBuilder Manager_GetReMark(int orderid)
        {
            DataTable adminremark = null;//管理员备注
            StringBuilder sb = new StringBuilder();
            if (orderid > 0)
            {
                IOrder order = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    order = session.Orders.GetByID(orderid);
                }
                if (order != null)
                {
                    adminremark = GetOrder_AdminReMark(order.adminremark);
                }
                if (adminremark.Rows.Count > 0)
                {
                    sb.Append("<table width='100%'><tr><td width='20%'>时间</td>");
                    sb.Append("<td width='30%'>管理员</td>");
                    sb.Append("<td width='50%'>内容</td></tr>");
                    for (int i = 0; i < adminremark.Rows.Count; i++)
                    {
                        sb.Append("<tr><td>" + adminremark.Rows[i]["time"] + "</td>");
                        sb.Append("<td>" + adminremark.Rows[i]["adminname"] + "</td>");
                        sb.Append("<td>" + adminremark.Rows[i]["content"] + "</td></tr>");
                    }
                    sb.Append("</table>");
                }
            }
            return sb;
        }

        /// <summary>
        /// 返回table类型的订单的管理员备注信息
        /// </summary>
        /// <param name="adminremark"></param>
        /// <returns></returns>
        public static DataTable GetOrder_AdminReMark(string adminremark)
        {
            DataTable table = new DataTable();
            DataColumn time = new DataColumn("time", Type.GetType("System.DateTime"));
            DataColumn adminname = new DataColumn("adminname", Type.GetType("System.String"));
            DataColumn content = new DataColumn("content", Type.GetType("System.String"));
            table.Columns.Add(time);
            table.Columns.Add(adminname);
            table.Columns.Add(content);
            if (adminremark != null && adminremark.Length > 0)
            {
                string[] remarks = adminremark.Split('^');
                for (int i = 0; i < remarks.Length; i++)
                {
                    string[] remark = remarks[i].Split('|');
                    if (remark.Length == 3)
                    {
                        DataRow row = table.NewRow();
                        row["time"] = remark[0];
                        row["adminname"] = remark[1];
                        row["content"] = remark[2];
                        table.Rows.Add(row);
                    }
                }
            }
            return table;
        }
        #endregion

        #region 现金付款事件
        /// <summary>
        /// 现金付款
        /// </summary>
        /// <param name="orderid">订单ID</param>
        /// <param name="adminid">管理员ID</param>
        /// <returns></returns>
        public static string Manager_Cash(int orderid, int adminid)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Order_Cash))
            {
                return "你不具有确认现金支付的权限";
            }
            string error = String.Empty;
            //处理过程
            IOrder ordermodel = null;
            IUser usermodel = null;
            using (IDataSession session = Store.OpenSession(false))
            {
                ordermodel = session.Orders.GetByID(orderid);
                usermodel = session.Users.GetByID(adminid);
            }
            if (ordermodel == null)
                return error = "不存在此订单";
            else if (usermodel == null)
               return error = "不存在此管理员";
            else
            {
                if (ordermodel.State != "unpay")
                {
                    error = "当前订单不是未付款状态";
                }
            }
            if (error.Length == 0)
                #region 修改订单状态
                OrderMethod.Updateorder(orderid, 0, "cash", adminid, DateTime.Now, ordermodel.Pay_id);
                #endregion
            return error;
        }
        #endregion

        #region 处理退款事件


        #region 申请退款

        /// <summary>
        /// 申请退款
        /// </summary>
        /// <param name="orderid">订单ID</param>
        /// <param name="listrefundteams">要退款的项目列表</param>
        /// <param name="refundmoney">退款金额</param>
        /// <param name="remark">退款原因</param>
        /// <param name="adminid">管理员ID</param>
        /// <param name="refundtime">申请时间</param>
        /// <param name="refundType">退款方式</param>
        /// <returns>返回结果字符串。为空代表成功。否则返回失败原因</returns>
        public static string Refund_Apply(int orderid, List<RefundTeams> listrefundteams, decimal refundmoney, string remark, int adminid, DateTime refundTime, int refundType)
        {
            if (refundType <= 0) return "请选择退款方式";
            if (refundmoney <= 0) return "退款金额不能小于0元";
            if (listrefundteams.Count == 0) return "没有选择要退款的项目";
            IOrder orderRow = null;//订单
            ITeam teamrow = null; ;//退款的项目
            int couponrow = 0;//项目的未消费优惠券信息
            CouponFilter coufilter = new CouponFilter();
            TeamFilter teamfilter = new TeamFilter();
            OrderDetailFilter orderdetailfilter = new OrderDetailFilter();
            IList<IOrderDetail> orderdetaillist = null; ;//含指定订单的订单详情
            IRefunds refundsRow = null;//检查是否有此项目的退款记录或正在处理的此订单的退款记录
            RefundsFilter filter = new RefundsFilter();
            filter.Order_Id = orderid;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                orderRow = session.Orders.GetByID(orderid);
                refundsRow = session.Refunds.Get(filter);
                if (orderRow != null)
                {
                    if (orderRow.Express == "Y")
                    {
                        orderdetailfilter.Order_ID = orderRow.Id;
                        orderdetaillist = session.OrderDetail.GetList(orderdetailfilter);
                    }
                }
            }
            int partnerid = 0;//商户ID
            int state = 4;//申请退款记录状态 默认为等待财务接受 
            //判断订单是否存在并且是付款状态
            if (orderRow == null || (orderRow.State != "pay" && orderRow.State != "scorepay")) return "订单不是付款状态不能退款";
            if (refundmoney > orderRow.Origin) return "退款金额不能大于订单金额";
            if (orderdetaillist != null && orderdetaillist.Count>0)//走购物车
            {
                for (int j = 0; j < listrefundteams.Count; j++)
                {
                    RefundTeams refundteam = listrefundteams[j];
                    //查找订单里是否存在此项目
                    bool isfind = false;
                    for (int i = 0; i < orderdetaillist.Count; i++)
                    {
                        if (refundteam.teamid == orderdetaillist[i].Teamid)//找到了这个项目
                        {
                            isfind = true;//找到了这个项目
                            //判断项目数量是否正确
                            if (refundteam.teamnum > orderdetaillist[i].Num || refundteam.teamnum <= 0)
                            {
                                return "项目ID" + refundteam.teamid + "申请的退款数量不正确";
                            }
                        }
                    }
                    if (!isfind)//没有找到这个项目
                    {
                        bool isok = false;
                        if (refundteam.teamid == orderRow.teamid)//找到了这个项目
                        {
                            isok = true;//找到了这个项目
                            coufilter.Consume = "Y";
                            coufilter.Team_id = refundteam.teamid;
                            coufilter.Order_id = orderid;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                teamrow = session.Teams.GetByID(refundteam.teamid);
                                couponrow = session.Coupon.GetCount(coufilter);
                            }
                            if (teamrow == null)
                            {
                                return "退款的项目已不存在无法获取商户信息";
                            }
                            //判断项目数量是否正确
                            if (refundteam.teamnum > orderRow.Quantity || refundteam.teamnum <= 0)
                            {
                                return "项目ID" + refundteam.teamid + "申请的退款数量不正确";
                            }
                        }

                        if (!isok)//没有找到这个项目
                        {
                            return "不存在项目ID" + refundteam.teamid + ",无法申请退款";
                        }
                    }
                }
                partnerid = orderRow.Partner_id;
                if (orderRow.Express_id > 0 && orderRow.Express_no != null && orderRow.Express_no.Length > 0) //如果已发货则需要商家确认
                {
                    state = 1;
                }
            }
            else //没走购物车
            {
                for (int j = 0; j < listrefundteams.Count; j++)
                {
                    RefundTeams refundteam = listrefundteams[j];
                    //查找订单里是否存在此项目
                    bool isfind = false;

                    if (refundteam.teamid == orderRow.Team_id)//找到了这个项目
                    {
                        isfind = true;//找到了这个项目
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            teamrow = session.Teams.GetByID(refundteam.teamid);
                            couponrow = session.Coupon.GetCount(coufilter);
                        }
                        if (teamrow == null)
                        {
                            return "退款的项目已不存在无法获取商户信息";
                        }
                        //判断项目数量是否正确
                        if (refundteam.teamnum > orderRow.Quantity || refundteam.teamnum <= 0)
                        {
                            return "项目ID" + refundteam.teamid + "申请的退款数量不正确";
                        }
                    }
                    if (!isfind)//没有找到这个项目
                    {
                        return "不存在项目ID" + refundteam.teamid + ",无法申请退款";
                    }
                }
                partnerid = teamrow.Partner_id;
                if (couponrow > 0)
                    state = 1;
            }
            if (refundsRow != null)
                return "订单已有退款记录，无法进行退款";
            IRefunds refundinsert = AS.GroupOn.App.Store.CreateRefunds();
            IRefunds_detail refunddetailmodel = AS.GroupOn.App.Store.CreateRefunds_detail();
            refundinsert.Order_ID = orderid;
            refundinsert.State = state;
            refundinsert.Create_Time = DateTime.Now;
            refundinsert.Money = refundmoney;
            refundinsert.PartnerID = partnerid;
            refundinsert.RefundMeans = refundType;
            refundinsert.Reason = remark;
            refundinsert.CreateUserID = adminid;
            int insert = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                insert = session.Refunds.Insert(refundinsert);
                for (int i = 0; i < listrefundteams.Count; i++)
                {
                    refunddetailmodel.refunds_id = insert;
                    refunddetailmodel.teamid = listrefundteams[i].teamid;
                    refunddetailmodel.teamnum = listrefundteams[i].teamnum;
                    session.Refunds_detail.Insert(refunddetailmodel);
                }
                orderRow.State = "refunding";
                session.Orders.Update(orderRow);
            }
            if (insert > 0)
            {
                IOrder order = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    order = session.Orders.GetByID(orderRow.Id);
                }
                if (orderRow.State != "refunding")
                {
                    WebUtils.LogWrite("申请退款日志", "订单" + order.Id + "状态没有发生变化");
                }
                return String.Empty;
            }
            else
                return "退款失败。写入数据库失败";
        }
        #endregion

        #region 商户查看退款
        /// <summary>
        /// 商户查看退款
        /// </summary>
        /// <param name="refundid">退款记录ID</param>
        /// <param name="viewTime">查看时间</param>
        /// <param name="partnerid">商户ID</param>
        /// <returns>返回结果字符串。为空代表成功。否则返回失败原因</returns>
        public static string Refund_View(int refundid, DateTime viewTime, int partnerid)
        {
            DataRowObject partnerrow = null;//商户信息
            DataRowObject refundrow = null;//退款记录
            RefundsFilter refilter=new RefundsFilter ();
            PartnerFilter parfilter=new PartnerFilter ();
            IList<IRefunds> ilistrefunds=null;
            IList<IPartner> ilistpartner=null;
            refilter.Id=refundid;
            parfilter.Id=partnerid;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilistrefunds = session.Refunds.GetList(refilter);
                ilistpartner = session.Partners.GetList(parfilter);
            }
            refundrow=new DataRowObject(Helper.ToDataTable(ilistrefunds.ToList()).Rows[0]);
            partnerrow=new DataRowObject(Helper.ToDataTable(ilistpartner.ToList()).Rows[0]);


            if (partnerrow == null)
            {
                return "不存在此商家";
            }
            if (refundrow == null)
            {
                return "不存在此退款信息";
            }
            if (partnerrow.ToInt("id") != refundrow.ToInt("partnerid"))
            {
                return "您无法查看此退款记录";
            }
            if (refundrow.ToInt("state") != 1)
            {
                return "非商户确认状态您无法处理";
            }
            refundrow.SetValue("PartnerViewTime", DateTime.Now);
            refundrow.SetValue("state", 4);
            IRefunds refunds = Store.CreateRefunds();
            refunds.Id=refundrow.ToInt("id");
            refunds.State=refundrow.ToInt("State");
            refunds.Create_Time=Helper.GetDateTime(refundrow.ToObject("Create_Time"));
            refunds.PartnerViewTime=Helper.GetDateTime(refundrow.ToObject("PartnerViewTime"));
            refunds.Order_ID = Helper.GetInt(refundrow.ToObject("Order_ID"), 0);
            refunds.Money=Helper.GetDecimal(refundrow.ToObject("Money"),0);
            refunds.PartnerID = refundrow.ToInt("PartnerID");
            refunds.FinanceBeginTime = Helper.GetDateTime(refundrow.ToObject("FinanceBeginTime"));
            refunds.FinanceEndTime = Helper.GetDateTime(refundrow.ToObject("FinanceEndTime"));
            refunds.RefundMeans=refundrow.ToInt("RefundMeans");
            refunds.Reason=refundrow.ToObject("Reason").ToString();
            refunds.Result=refundrow.ToObject("Result").ToString();
            int id = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                id = session.Refunds.Update(refunds);
            }

            if (id > 0)
            {
                return String.Empty;//更新成功

            }
            else
            return "数据库更新失败";
        }

        #endregion

        #region 客服删除退款处理
        /// <summary>
        /// 客服删除退款处理,要求退款状态是财务已经接受状态之前
        /// </summary>
        public static string Refund_Delete(int refundid, int adminid, DateTime time)
        {
            string error = String.Empty;
            IRefunds refund = null;
            IOrder order = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                refund = session.Refunds.GetByID(refundid);
                if (refund == null) return "不存在此退款记录";
                if ((refund.State | 7) != 7) return "当前退款记录不能被删除";
                order = session.Orders.GetByID(refund.Order_ID);
                if (order == null) return "不存在的订单";
                order.State = "pay";
                int i = session.Orders.Update(order);
                int j = session.Refunds.Delete(refund.Id);
                if (i > 0 && j > 0)
                {
                    error = "退款记录删除成功！";
                }
            }
            return error;
        }
        #endregion

        #region 财务接受退款处理
        /// <summary>
        /// 财务接受退款处理
        /// </summary>
        public static string Refund_Receive(int refundid, int adminid, DateTime receivetime)
        {
            IRefunds refund = null;
            IOrder order = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                refund = session.Refunds.GetByID(refundid);
            }
            if (refund == null) return "不存在此退款记录";
            if ((refund.State | 5) != 5) return "当前退款记录不是待接受状态";
            refund.State = 8;
            refund.FinanceBeginTime = receivetime;
            refund.AdminID = adminid;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int i = session.Refunds.Update(refund);
                if (i > 0) return String.Empty;
                else
                    return "接受失败，数据库更新失败";
            }
        }
        #endregion

        #region 删除订单
        /// <summary>
        /// 删除订单
        /// </summary>
        public static RedirctResult Del_Order(int adminid, int orderid, string url)
        {
            RedirctResult result = null;
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Order_Delete))
            {
                PageValue.SetMessage(new ShowMessageResult("你不具有删除订单信息的权限！", false, false));
                result = new RedirctResult(url, true);
                return result;
            }
            IOrder order = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                order = session.Orders.GetByID(orderid);
            }
            if (adminid <= 0)
            {
                PageValue.SetMessage(new ShowMessageResult("管理员不存在！订单无法删除！", false, false));
                result = new RedirctResult(url, true);
                return result;
            }
            if (order != null)
            {
                if (order.State == "pay")
                {
                    PageValue.SetMessage(new ShowMessageResult("订单已付款！无法删除！", false, false));
                    result = new RedirctResult(url, true);
                    return result;
                }
                else
                {
                    int id = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        id = session.Orders.Delete(orderid);
                    }
                    if (id > 0)
                    {
                        string key = AS.Common.Utils.FileUtils.GetKey();
                        AS.AdminEvent.ConfigEvent.AddOprationLog(AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", key), 0), "删除订单", "删除订单 ID:" + id, DateTime.Now);
                        PageValue.SetMessage(new ShowMessageResult("订单ID" + order.Id + "删除成功", true, true));
                        result = new RedirctResult(url, true);
                        return result;
                    }
                }
            }
            else
            {
                PageValue.SetMessage(new ShowMessageResult("订单不存在！无法删除！", false, false));
                result = new RedirctResult(url, true);
                return result;
            }
            return result;
        }
        #endregion

        #region 财务确认退款
        /// <summary>
        /// 财务确认退款
        /// </summary>
        /// <param name="refundid">ID</param>
        /// <param name="adminid">财务管理员ID</param>
        /// <param name="confirTime">确认时间</param>
        /// <returns></returns>
        public static string Refund_Confir(int refundid, int adminid, DateTime confirTime, string Result)
        {
            //执行退款逻辑
            /*
             1更新退款表，2拆分订单表，3删除优惠券(区分模式1对1以及1对多)，4根据退款方式
             * 
             */
            NameValueCollection _system = new NameValueCollection();
            _system = PageValue.CurrentSystemConfig;
            int totalrefundcount = 0;//总退货数量
            IRefunds refundmodel = null;
            IUser usermodel = null;
            ITeam teammodel = null;
            IOrder ordermodel = null;
            IUser buyusermodel = null;
            IList<ICoupon> couponmodels = null;//未消费优惠券
            IList<ICoupon> couponconsumemodels = null;//已消费优惠券
            IList<IPcoupon> pcouponList = null;
            IList<IOrderDetail> orderdetailmodels = null;
            PcouponFilter pcoufilter = new PcouponFilter();
            IList<IRefunds_detail> refundsdetails = null;
            IList<IOrderDetail> new_orderdetails = null;
            Refunds_detailFilter r_detailfilter = new Refunds_detailFilter();
            CouponFilter couponfilter = new CouponFilter();
            CouponFilter couponsumfilter = new CouponFilter();
            CouponFilter coudelfilter = new CouponFilter();
            OrderDetailFilter o_detailfilter = new OrderDetailFilter();
            OrderDetailFilter new_detailfilter = new OrderDetailFilter();
            IFlow flow_model = Store.CreateFlow();
            IScorelog scroelogModel = Store.CreateScorelog();
            ICard card = null;
            CardFilter cardfilter = new CardFilter();
            string refundTeamIDS = String.Empty;//退款项目ID
            int order_ID = 0;//退款原始订单ID
            int avg_score = 0;
            int sum_score = 0;
            decimal sum_money = 0;
            string success = "";
            int sum_orderscore = 0;
            int tempid = NumberUtils.GetTempID();
            using (IDataSession session = Store.OpenSession(true))
            {
                #region 数据验证
                refundmodel = session.Refunds.GetByID(refundid);
                if (refundmodel == null) return "退款记录不存在";
                usermodel = session.Users.GetByID(adminid);
                if (usermodel == null) return "此管理员不存在";
                if (Result.Length == 0) return "退款结果不能为空";
                if (refundmodel.State != 8) return "订单状态不正确，无法确认退款";
                refundmodel.FinanceEndTime = confirTime;
                refundmodel.Result = Result;
                refundmodel.State = 16;
                session.Refunds.Update(refundmodel);
                ordermodel = session.Orders.GetByID(refundmodel.Order_ID);
                if (ordermodel == null) return "订单不存在";
                buyusermodel = session.Users.GetByID(ordermodel.User_id);
                if (buyusermodel == null) return "不存在购买者";
                if (ordermodel.State != "refunding") return "订单状态不正确，无法确认退款";
                order_ID = ordermodel.Id;
                #endregion

                #region 写入消费记录
                if (refundmodel.RefundMeans == 1 || refundmodel.RefundMeans == 2) //余额退款方式
                {
                    if (ordermodel.Service == "cashondelivery")
                        sum_money = ordermodel.Credit + ordermodel.cashondelivery;
                    else
                        sum_money = ordermodel.Credit + ordermodel.Money;
                    if (refundmodel.Money == sum_money)//是否为全部退款
                    {
                        if (ordermodel.Quantity == totalrefundcount && ordermodel.totalscore != 0)
                        {
                            buyusermodel.userscore += ordermodel.totalscore;
                        }
                        else
                        {
                            buyusermodel.userscore -= ordermodel.orderscore;
                        }
                        if (refundmodel.RefundMeans == 1)
                        {
                            flow_model.Detail = "订单号:" + ordermodel.Id + "退款到账户余额" + refundmodel.Money + "元！";
                            buyusermodel.Money = buyusermodel.Money + refundmodel.Money;
                        }
                        else
                        {
                            flow_model.Detail = "订单号:" + ordermodel.Id + "退款到账户余额" + ordermodel.Credit + ",还需人工退款" + ordermodel.Money + "元！";
                            buyusermodel.Money = buyusermodel.Money + ordermodel.Credit;
                        }
                    }
                    else
                    {
                        if (refundmodel.RefundMeans == 1)
                        {
                            flow_model.Detail = "订单号:" + ordermodel.Id + "退款到账户余额" + refundmodel.Money + "元！";
                            buyusermodel.Money = buyusermodel.Money + refundmodel.Money;
                        }
                        else
                        {
                            flow_model.Detail = "订单号:" + ordermodel.Id + "需人工退款" + refundmodel.Money + "元！";
                        }
                    }
                    success = flow_model.Detail;
                    flow_model.User_id = buyusermodel.Id;
                    flow_model.Admin_id = adminid;
                    flow_model.Create_time = DateTime.Now;
                    flow_model.Action = "refund";
                    flow_model.Detail_id = ordermodel.Pay_id;
                    flow_model.Direction = "income";
                    flow_model.Money = refundmodel.Money;
                    session.Flow.Insert(flow_model);
                    session.Users.Update(buyusermodel);
                }
                #endregion

                #region 操作优惠卷
                r_detailfilter.refunds_id = refundid;
                refundsdetails = session.Refunds_detail.GetList(r_detailfilter);
                for (int k = 0; k < refundsdetails.Count; k++)
                {
                    IRefunds_detail refunddetailmodel = refundsdetails[k];
                    totalrefundcount = totalrefundcount + refundsdetails[k].teamnum;
                    refundTeamIDS = refundTeamIDS + "," + refundsdetails[k].teamid;
                    teammodel = session.Teams.GetByID(refundsdetails[k].teamid);
                    couponfilter.Team_id = teammodel.Id;
                    couponfilter.Order_id = refundmodel.Order_ID;
                    couponfilter.Consume = "N";
                    couponsumfilter.Team_id = teammodel.Id;
                    couponsumfilter.Order_id = refundmodel.Order_ID;
                    couponsumfilter.Consume = "Y";
                    if (teammodel != null && teammodel.Delivery == "coupon")
                    {
                        couponmodels = session.Coupon.GetList(couponfilter);
                        couponconsumemodels = session.Coupon.GetList(couponsumfilter);
                    }
                    #region 删除优惠卷
                    if (teammodel.Delivery == "coupon")
                    {
                        if (refundmodel.Money != sum_money)
                        {
                            avg_score = ordermodel.orderscore / ordermodel.Quantity;
                            sum_score = avg_score * refunddetailmodel.teamnum;
                            buyusermodel.userscore -= sum_score;
                            ordermodel.orderscore -= sum_score;
                            session.Orders.Update(ordermodel);
                            session.Users.Update(buyusermodel);
                        }
                        //判断退款数量。并删掉优惠券
                        int i = 0;
                        while (i < refunddetailmodel.teamnum)
                        {
                            for (int j = 0; j < couponmodels.Count; j++)
                            {
                                if (_system != null)
                                {
                                    if (_system["couponPattern"] != null && _system["couponPattern"].ToString() != String.Empty && _system["couponPattern"] != "0")
                                    {
                                        coudelfilter.Id = couponmodels[j].Id;
                                        coudelfilter.Secret = couponmodels[j].Secret;
                                        session.Coupon.Delete(coudelfilter);
                                        i = i + 1;
                                        if (i >= refunddetailmodel.teamnum) break;
                                    }
                                    else
                                    {
                                        session.Coupon.Delete(couponmodels[j].Id);
                                        i = i + 1;
                                        if (i >= refunddetailmodel.teamnum) break;
                                    }
                                }
                            }
                            if (i >= refunddetailmodel.teamnum)
                            {
                                break;
                            }
                            for (int j = 0; j < couponconsumemodels.Count; j++)
                            {
                                //判断优惠卷生成模式，1对多 通过ID和密码删除优惠卷
                                if (_system != null)
                                {
                                    if (_system["couponPattern"] != null && _system["couponPattern"].ToString() != String.Empty && _system["couponPattern"] != "0")
                                    {
                                        coudelfilter.Id = couponconsumemodels[j].Id;
                                        coudelfilter.Secret = couponconsumemodels[j].Secret;
                                        session.Coupon.Delete(coudelfilter);
                                        i = i + 1;
                                        if (i >= refunddetailmodel.teamnum)
                                        {
                                            break;
                                        }
                                    }
                                    else//1对1 通过ID删除优惠卷
                                    {
                                        session.Coupon.Delete(couponconsumemodels[j].Id);
                                        i = i + 1;
                                        if (i >= refunddetailmodel.teamnum)
                                        {
                                            break;
                                        }
                                    }
                                }
                            }
                            i = i + 1;
                        }
                    }
                    if (teammodel != null && teammodel.Delivery == "pcoupon")
                    {
                        pcoufilter.orderid = ordermodel.Id;
                        pcoufilter.teamid = teammodel.Id;
                        pcoufilter.userid = ordermodel.User_id;
                        pcoufilter.state = "buy";
                        pcouponList = session.Pcoupon.GetList(pcoufilter);
                        for (int j = 0; j < refunddetailmodel.teamnum && j < pcouponList.Count; j++)
                        {
                            pcouponList[j].state = "refund";
                            pcouponList[j].userid = 0;
                            session.Pcoupon.Update(pcouponList[j]);
                        }
                    }
                    #endregion
                }
                #endregion

                #region 订单操作
                if (ordermodel.Quantity == totalrefundcount)
                {
                    #region 直接变更订单状态
                    cardfilter.Order_id = ordermodel.Id;
                    card = session.Card.Get(cardfilter);
                    if (card != null)
                        card.consume = "N";
                        session.Card.Update(card);
                    if (ordermodel.totalscore != 0)//积分项目
                    {
                        ordermodel.State = "scorrefund";
                    }
                    else
                    {
                        ordermodel.State = "refund";
                    }
                    ordermodel.refundTime = confirTime;
                    session.Orders.Update(ordermodel);
                    #endregion
                }
                else
                {
                    #region 拆分订单
                    int sum_tscore = 0;
                    o_detailfilter.Order_ID = ordermodel.Id;
                    orderdetailmodels = session.OrderDetail.GetList(o_detailfilter);
                    IOrder newordermodel = WebUtils.GetObjectClone<IOrder>(ordermodel);
                    newordermodel.State = "refund";
                    newordermodel.Quantity = totalrefundcount;
                    newordermodel.Origin = refundmodel.Money;
                    newordermodel.refundTime = confirTime;
                    ordermodel.Quantity = ordermodel.Quantity - newordermodel.Quantity;
                    newordermodel.Parent_orderid = ordermodel.Id;
                    if (ordermodel.totalscore != 0)
                    {
                        ordermodel.State = "scorepay";
                    }
                    else
                    {
                        ordermodel.State = "pay";
                    }
                    for (int k = 0; k < refundsdetails.Count; k++)
                    {
                        IRefunds_detail refunddetail = refundsdetails[k];

                        for (int i = 0; i < orderdetailmodels.Count; i++)
                        {
                            if (refunddetail.teamid == orderdetailmodels[i].Teamid)
                            {
                                if (refunddetail.teamnum == orderdetailmodels[i].Num)//退款数量和项目数量相等
                                {
                                    orderdetailmodels[i].Order_id = tempid;
                                    session.OrderDetail.Update(orderdetailmodels[0]);
                                }
                                else //不相等
                                {
                                    IOrderDetail neworderdetailmodel = WebUtils.GetObjectClone<IOrderDetail>(orderdetailmodels[i]);
                                    if (orderdetailmodels[i].totalscore != 0)
                                    {
                                        sum_tscore = orderdetailmodels[i].totalscore;
                                    }
                                    avg_score = orderdetailmodels[i].orderscore / orderdetailmodels[i].Num;
                                    neworderdetailmodel.Num = refunddetail.teamnum;
                                    orderdetailmodels[i].Num = orderdetailmodels[i].Num - refunddetail.teamnum;
                                    orderdetailmodels[i].orderscore = avg_score * orderdetailmodels[i].Num;
                                    sum_orderscore = sum_orderscore + avg_score * refunddetail.teamnum;
                                    neworderdetailmodel.Order_id = tempid;
                                    neworderdetailmodel.orderscore = 0;
                                    session.OrderDetail.Update(orderdetailmodels[i]);
                                    session.OrderDetail.Insert(neworderdetailmodel);
                                }
                                break;
                            }
                        }
                    }
                    if (sum_tscore != 0) ordermodel.totalscore = sum_tscore * ordermodel.Quantity;
                    if (ordermodel.Money >= refundmodel.Money)
                    {
                        if (ordermodel.totalscore == 0)
                        {
                            newordermodel.Money = refundmodel.Money;
                        }
                        else
                        {
                            newordermodel.Money = 0;
                        }
                        ordermodel.Money = ordermodel.Money - refundmodel.Money;
                        newordermodel.Card_id = String.Empty;
                        newordermodel.Card = 0;
                        newordermodel.Credit = 0;
                        newordermodel.disamount = 0;
                        newordermodel.disinfo = String.Empty;
                        newordermodel.Fare = 0;
                        if (sum_score != 0 || sum_orderscore != 0)
                        {
                            if (sum_score != 0)
                            {
                                newordermodel.orderscore = sum_score;
                            }
                            else
                            {
                                newordermodel.orderscore = sum_orderscore;
                            }
                        }
                        newordermodel.refundTime = DateTime.Now;
                        if (ordermodel.Credit < 0)
                        {
                            return "发生错误，订单异常";
                        }
                        else
                        {
                            session.Orders.Insert(newordermodel);
                        }
                    }
                    else//有余额付款处理
                    {
                        ordermodel.Money = 0;
                        decimal shengyujine = refundmodel.Money - newordermodel.Money;
                        if (ordermodel.totalscore == 0)
                        {
                            newordermodel.Credit = shengyujine;
                            ordermodel.Credit = ordermodel.Credit - newordermodel.Credit;
                        }
                        newordermodel.Card_id = String.Empty;
                        newordermodel.Card = 0;
                        newordermodel.disamount = 0;
                        newordermodel.disinfo = String.Empty;
                        newordermodel.Fare = 0;
                        if (sum_score != 0 || sum_orderscore != 0)
                        {
                            if (sum_score != 0)
                            {
                                newordermodel.orderscore = sum_score;
                            }
                            else
                            {
                                newordermodel.orderscore = sum_orderscore;
                            }
                        }
                        newordermodel.refundTime = DateTime.Now;
                        if (ordermodel.Credit < 0)
                        {
                            return "发生错误，订单异常";
                        }
                        else
                        {
                            session.Orders.Insert(newordermodel);
                        }
                    }
                    ordermodel.Origin = ordermodel.Origin - refundmodel.Money;
                    ordermodel.refundTime = DateTime.Now;
                    if (refundsdetails.Count > 0)
                    {
                        ordermodel.orderscore -= sum_orderscore;
                        if (ordermodel.totalscore != 0)
                        {
                            buyusermodel.userscore += ordermodel.totalscore;
                        }
                        else
                        {
                            buyusermodel.userscore -= sum_orderscore;
                        }
                        session.Users.Update(buyusermodel);
                        session.Orders.Update(ordermodel);
                    }
                    #endregion
                }
                #endregion

                #region 写入积分记录
                if (ordermodel.orderscore != 0)
                {
                    if (sum_score != 0 || sum_orderscore != 0)
                    {
                        if (sum_score != 0)
                            scroelogModel.score = -sum_score;
                        else
                            scroelogModel.score = -sum_orderscore;
                    }
                    else
                    {
                        scroelogModel.score = -ordermodel.orderscore;
                    }
                    scroelogModel.action = "退单";
                    scroelogModel.key = ordermodel.Id.ToString();
                    scroelogModel.adminid = adminid;
                    scroelogModel.create_time = DateTime.Now;
                    scroelogModel.user_id = ordermodel.User_id;
                    session.Scorelog.Insert(scroelogModel);
                }
                #endregion

                #region 订单更新
                int neworderid =session.Orders.GetMaxId();
                if (neworderid == 0)
                    return "订单异常!";
                else
                {
                    new_detailfilter.Order_ID = tempid;
                    new_orderdetails = session.OrderDetail.GetList(new_detailfilter);
                    for (int i = 0; i < new_orderdetails.Count; i++)
                    {
                        IOrderDetail r = new_orderdetails[i];
                        r.Order_id = neworderid;
                        session.OrderDetail.Update(r);
                    }
                }
                #endregion

                session.Commit();
            }
            return success;
        }
        #endregion


        #endregion

    }
}
