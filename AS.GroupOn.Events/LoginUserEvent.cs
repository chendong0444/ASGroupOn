using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess;
using AS.Common.Utils;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.Events
{
   public class LoginUserEvent
    {
        /// <summary>
        /// 生成优惠券订单 此方法会将优惠券订单ID返回
        /// </summary>
        /// <param name="userID"></param>
        /// <param name="Service"></param>
        /// <param name="teamid"></param>
        /// <param name="quantity"></param>
        /// <param name="mobile"></param>
        /// <param name="createTime"></param>
        /// <param name="ipAddress"></param>
        /// <param name="fromDomain"></param>
        /// <returns></returns>
        public EventResult CreateCouponOrder(int userID, string Service, Cart cart, DateTime createTime, string ipAddress, string fromDomain)
        {
            EventResult result = new EventResult();
            if (cart.TeamList[0].TeamNum < 1)
            {
                result.Result = false;
                result.Message = "购买数量不正确";
                return result;
            }
            if (String.IsNullOrEmpty(cart.Mobile))
            {
                result.Result = false;
                result.Message = "手机号不能为空";
                return result;
            }
            if (!AS.Common.Utils.StringUtils.ValidateString(cart.Mobile, "mobile"))
            {
                result.Result = false;
                result.Message = "手机号格式不正确";
                return result;
            }
            if (String.IsNullOrEmpty(Service))
            {
                result.Result = false;
                result.Message = "付款方式不能为空";
                return result;
            }
            IUser user = null;
            ITeam team = null;
            using (IDataSession session = App.Store.OpenSession(false))
            {
                user = session.Users.GetByID(userID);
                team = session.Teams.GetByID(cart.TeamList[0].TeamID);
            }
            if (user == null)
            {
                result.Result = false;
                result.Message = "没有登录，无法进行购买";
            }
            if (team == null)
            {
                result.Result = false;
                result.Message = "不存在此项目";
            }
            if (!team.CanBuy)
            {
                result.Result = false;
                result.Message = "此项目已卖光无法进行购买";
            }
            IOrder order = App.Store.CreateOrder();
            ICard card = null;
            order.City_id = team.City_id;
            order.Create_time = createTime;
            order.Express = "N";
            order.Team_id = team.Id;
            order.Quantity = cart.TeamList[0].TeamNum;
            order.Price = team.Team_price;
            order.fromdomain = fromDomain;
            order.IP_Address = ipAddress;
            order.Mobile = cart.Mobile;
            if (cart.Card != null && cart.Card.consume == "N" && cart.Card.Begin_time <= createTime && cart.Card.End_time >= createTime)//如果有代金券并且未使用
            {
                order.Card_id = cart.CardID;
                order.Card = cart.GetCardPrice;
                cart.Card.consume = "Y";
                cart.Card.Ip = WebUtils.GetClientIP;
                cart.Card.user_id = userID;
                card = cart.Card;
            }
            order.Origin = cart.NeedPayPrice;
            order.Service = Service;
            if (order.Service != "alipay") order.Service = "yeepay";
            order.State = "unpay";
            order.User_id = userID;
            int orderid = 0;
            using (IDataSession session = App.Store.OpenSession(true))
            {

                orderid = session.Orders.Insert(order);
                if (orderid > 0&&card!=null)
                {
                    card.Order_id = orderid;
                    session.Card.Update(card);
                }
                session.Commit();
            }
            if (orderid > 0)
            {
                result.Result = true;
                result.Object = orderid;
            }
            else
            {
                result.Result = false;
                result.Message = "下单失败";
            }

            return result;
        }

       /// <summary>
       /// 生成实物类订单
       /// </summary>
       /// <param name="userID"></param>
       /// <param name="Service"></param>
       /// <param name="teamid"></param>
       /// <param name="quantity"></param>
       /// <param name="mobile"></param>
       /// <param name="createTime"></param>
       /// <param name="ipAddress"></param>
       /// <param name="fromDomain"></param>
       /// <returns></returns>
        public EventResult CreateDeliveryOrder(int userID, string Service, Cart cart, DateTime createTime, string ipAddress, string fromDomain,int cityid,string disamountinfo,decimal disamount)
        {
            EventResult result = new EventResult();
            if (cart.TeamList.Count < 1)
            {
                result.Result = false;
                result.Message = "购买数量不正确";
                return result;
            }
            int quantity = 0;//购物车总数量
            List<IOrderDetail> orderdetails = new List<IOrderDetail>();//订单详情
            for (int i = 0; i < cart.TeamList.Count; i++)
            {
                if (cart.TeamList[i].TeamNum < 1)
                {
                    result.Result = false;
                    result.Message = "购买数量不正确";
                    return result;
                }
                if (cart.TeamList[i].Team == null)
                {
                    result.Result = false;
                    result.Message = "您购买了不存在的项目";
                    return result;
                }
                if (!cart.TeamList[i].Team.CanBuy)
                {
                    result.Result = false;
                    result.Message = "项目" + cart.TeamList[i].Team.Product + "已卖光";
                    return result;
                }
                quantity = quantity + cart.TeamList[i].TeamNum;
                IOrderDetail orderdetail = App.Store.CreateOrderDetail();
                orderdetail.Num = cart.TeamList[i].TeamNum;
                orderdetail.result = cart.TeamList[i].Bllin;
                orderdetail.Teamid = cart.TeamList[i].TeamID;
                orderdetail.Teamprice = cart.TeamList[i].Team.Team_price;
                orderdetails.Add(orderdetail);
                
            }
            if (String.IsNullOrEmpty(cart.Mobile))
            {
                result.Result = false;
                result.Message = "手机号不能为空";
                return result;
            }
            if (!AS.Common.Utils.StringUtils.ValidateString(cart.Mobile, "mobile"))
            {
                result.Result = false;
                result.Message = "手机号格式不正确";
                return result;
            }
            if (String.IsNullOrEmpty(cart.RealName))
            {
                result.Result = false;
                result.Message = "收货人不能为空";
                return result;
            }
            if (String.IsNullOrEmpty(cart.Address))
            {
                result.Result = false;
                result.Message = "收货地址不能为空";
                return result;
            }
            if (String.IsNullOrEmpty(cart.Remark))
            {
                result.Result = false;
                result.Message = "送货时间不能为空";
                return result;
            }
            if (String.IsNullOrEmpty(cart.Zip))
            {
                result.Result = false;
                result.Message = "邮编不能为空";
                return result;
            }

            if (String.IsNullOrEmpty(Service))
            {
                result.Result = false;
                result.Message = "付款方式不能为空";
                return result;
            }
            IUser user = null;
            using (IDataSession session = App.Store.OpenSession(false))
            {
                user = session.Users.GetByID(userID);
            }
            if (user == null)
            {
                result.Result = false;
                result.Message = "没有登录，无法进行购买";
            }

            ICard card = null;//代金券
            IOrder order = App.Store.CreateOrder();
            order.City_id = cityid;
            order.Create_time = createTime;
            order.Express = "N";
            order.Team_id = 0;
            order.Quantity = quantity;
            order.Price = 0;
            order.fromdomain = fromDomain;
            order.IP_Address = ipAddress;
            order.Mobile = cart.Mobile;
            order.Address =cart.Region+"-"+ cart.Address;
            order.Origin = cart.TotalPrice;//不含运费不含代金券金额
            order.disamount = disamount;
            order.disinfo = disamountinfo;
            order.Remark = cart.Remark;
            order.Zipcode=cart.Zip;
            if (cart.Region.Length > 0)
            {
                order.Fare = cart.Fare(cart.Region.Split('-')[0]);
                order.Origin = order.Origin + order.Fare;
            }
            if (cart.Card != null && cart.Card.consume == "N"&&cart.Card.Begin_time<=createTime&&cart.Card.End_time>=createTime)//如果有代金券并且未使用
            {
                for (int i = 0; i < cart.Card.CodePriceList.Count; i++)
                {
                    ICodePrice codePrice = cart.Card.CodePriceList[i];
                    if (codePrice.orderprice <= cart.TotalPrice || codePrice.orderprice == 0)
                    {
                        order.Card_id = cart.Card.Id;
                        order.Card = codePrice.credit;
                        order.Origin= order.Origin - order.Card;
                        cart.Card.consume = "Y";
                        cart.Card.Ip = WebUtils.GetClientIP;
                        cart.Card.user_id = userID;
                        card = cart.Card;
                    }
                }
            }
            order.Service = Service;
            if (order.Service != "alipay") order.Service = "yeepay";
            order.State = "unpay";
            order.User_id = userID;
            int orderid = 0;
            using (IDataSession session = App.Store.OpenSession(true))
            {
                orderid = session.Orders.Insert(order);
                if (orderid > 0)
                {
                    if (card != null)
                    {
                        card.Order_id = orderid;
                        session.Card.Update(card);
                    }
                    order = session.Orders.GetByID(orderid);
                    session.Orders.Update(order);
                    for (int i = 0; i < orderdetails.Count; i++)
                    {
                        IOrderDetail orderdetail = orderdetails[i];
                        orderdetail.Order_id = orderid;
                        session.OrderDetail.Insert(orderdetail);
                    }
                }
                session.Commit();
            }
            if (orderid > 0)
            {
                result.Result = true;
                result.Object = orderid;
            }
            else
            {
                result.Result = false;
                result.Message = "下单失败";
            }

            return result;
        }

       /// <summary>
       /// 删除收货地址
       /// </summary>
       /// <param name="addressId"></param>
       /// <returns></returns>
        public EventResult DeleteAddress(int addressId)
        {
            int success=0;
            EventResult result = new EventResult();
             using (IDataSession session = App.Store.OpenSession(false))
            {
                success = session.DeliverAddress.Delete(addressId);
            }
             if (success > 0)
             {
                 result.Result = true;
                 result.Message = "删除收货地址成功！";
             }
             else
             {
                 result.Result = true;
                 result.Message = "删除收货地址失败！";
             }
             return result;
        }
        /// <summary>
        /// 更新收货地址
        /// </summary>
        /// <param name="id">地址ID</param>
        /// <param name="realName">收货人</param>
        /// <param name="area">省市区</param>
        /// <param name="address">地址</param>
        /// <param name="zip">邮编</param>
        /// <param name="Default">是否默认</param>
        /// <returns></returns>
        public EventResult UpdateAddress(int id, string realName, string area, string address, string zip, bool Default, string mobile)
        {
            EventResult result = new EventResult();
            if (String.IsNullOrEmpty(realName))
            {
                result.Result = false;
                result.Message = "收货人不能为空";
                return result;
            }
            if (StringUtils.GetStringByteLength(realName) > 100)
            {
                result.Result = false;
                result.Message = "收货人长度超过100个字符";
                return result;
            }
            if (String.IsNullOrEmpty(area))
            {
                result.Result = false;
                result.Message = "省市区不能为空";
                return result;
            }
            if (StringUtils.GetStringByteLength(area) > 200)
            {
                result.Result = false;
                result.Message = "省市区长度超过200个字符";
                return result;
            }
            if (String.IsNullOrEmpty(address))
            {
                result.Result = false;
                result.Message = "省市区不能为空";
                return result;
            }
            if (StringUtils.GetStringByteLength(address) > 500)
            {
                result.Result = false;
                result.Message = "收货地址长度超过500个字符";
                return result;
            }
            if (String.IsNullOrEmpty(zip))
            {
                result.Result = false;
                result.Message = "邮编不能为空";
                return result;
            }
            if (!StringUtils.ValidateString(zip, "zip"))
            {
                result.Result = false;
                result.Message = "邮编格式不正确";
                return result;
            }
            if (String.IsNullOrEmpty(mobile))
            {
                result.Result = false;
                result.Message = "联系电话不能为空";
                return result;
            }
            if (!StringUtils.ValidateString(mobile, "mobile"))
            {
                result.Result = false;
                result.Message = "联系电话格式不正确";
                return result;
            }
            if (id < 1)
            {
                result.Result = false;
                result.Message = "请先选择收货地址在进行修改";
                return result;
            }
           
            IDeliverAddress deliveryaddress = App.Store.CreateDeliverAddress();
            using (IDataSession session = App.Store.OpenSession(false))
            {
                    deliveryaddress = session.DeliverAddress.GetByID(id);
            }
            if (deliveryaddress != null)
            {
                deliveryaddress.Address = address;
                deliveryaddress.Area = area;
                if (Default)
                    deliveryaddress.Default = 1;
                else
                    deliveryaddress.Default = 0;
                deliveryaddress.RealName = realName;
                deliveryaddress.Mobile = mobile;
                deliveryaddress.Zip = zip;
                using (IDataSession session = App.Store.OpenSession(false))
                {
                    if (Default)
                    {
                        IList<IDeliverAddress> deliverys = null;
                        DeliverAddressFilter daf = new DeliverAddressFilter();
                        daf.UserID = deliveryaddress.UserID;
                        daf.Default = 1;
                        deliverys = session.DeliverAddress.GetList(daf);
                        for (int i = 0; i < deliverys.Count; i++)
                        {
                            deliverys[i].Default = 0;
                            session.DeliverAddress.Update(deliverys[i]);
                        }
                    }
                   int count = session.DeliverAddress.Update(deliveryaddress);
                   if (count > 0)
                   {
                       result.Result = true;
                       result.Message = "更新收货地址成功";
                       result.Object = deliveryaddress;
                   }
                   else
                   {
                       result.Result = false;
                       result.Message = "更新收货地址失败";
                   }
                }

            }
            else
            {
                result.Result = false;
                result.Message = "更新收货地址失败";
            }

            return result;

        }
       /// <summary>
       /// 新增收货地址
       /// </summary>
       /// <param name="userid">用户ID</param>
       /// <param name="realName">收货人</param>
       /// <param name="area">省市区</param>
       /// <param name="address">地址</param>
       /// <param name="zip">邮编</param>
       /// <param name="Default">是否默认</param>
       /// <returns></returns>
        public  EventResult CreateAddress(int userid, string realName, string area, string address, string zip, bool Default,string mobile)
        {
            EventResult result = new EventResult();
            if (String.IsNullOrEmpty(realName))
            {
                result.Result = false;
                result.Message = "收货人不能为空";
                return result;
            }
            if (StringUtils.GetStringByteLength(realName) > 100)
            {
                result.Result = false;
                result.Message = "收货人长度超过100个字符";
                return result;
            }
            if (String.IsNullOrEmpty(area))
            {
                result.Result = false;
                result.Message = "省市区不能为空";
                return result;
            }
            if (StringUtils.GetStringByteLength(area) > 200)
            {
                result.Result = false;
                result.Message = "省市区长度超过200个字符";
                return result;
            }
            if (String.IsNullOrEmpty(address))
            {
                result.Result = false;
                result.Message = "省市区不能为空";
                return result;
            }
            if (StringUtils.GetStringByteLength(address) > 500)
            {
                result.Result = false;
                result.Message = "收货地址长度超过500个字符";
                return result;
            }
            if (String.IsNullOrEmpty(zip))
            {
                result.Result = false;
                result.Message = "邮编不能为空";
                return result;
            }
            if (!StringUtils.ValidateString(zip, "zip"))
            {
                result.Result = false;
                result.Message = "邮编格式不正确";
                return result;
            }
            if (String.IsNullOrEmpty(mobile))
            {
                result.Result = false;
                result.Message = "联系电话不能为空";
                return result;
            }
            if (!StringUtils.ValidateString(mobile, "mobile"))
            {
                result.Result = false;
                result.Message = "联系电话格式不正确";
                return result;
            }
            if(userid<1)
            {
                result.Result = false;
                result.Message = "请先登录再添加收货地址";
                return result;
            }
            IUser user=null;
            int count = 0;
            DeliverAddressFilter daf = new DeliverAddressFilter();
            daf.UserID = userid;
            using (IDataSession session = App.Store.OpenSession(false))
            {
                user = session.Users.GetByID(userid);
                count = session.DeliverAddress.GetCount(daf);
            }
            if (count >= 10)
            {
                result.Result = false;
                result.Message = "最多允许添加10个收货地址";
                return result;
            }
            if (user == null)
            {
                result.Result = false;
                result.Message = "不存在此用户";
                return result;
            }
            IDeliverAddress deliveryaddress = App.Store.CreateDeliverAddress();
            deliveryaddress.Address = address;
            deliveryaddress.Area = area;
            if (Default)
                deliveryaddress.Default = 1;
            else
                deliveryaddress.Default = 0;
            deliveryaddress.RealName = realName;
            deliveryaddress.Mobile = mobile;
            deliveryaddress.UserID = user.Id;
            deliveryaddress.Zip = zip;
            int id = 0;
            IList<IDeliverAddress> deliverys = null;
            DeliverAddressFilter daf1 = new DeliverAddressFilter();
            daf1.UserID = userid;
            daf1.Default = 1;
            using (IDataSession session = App.Store.OpenSession(false))
            {
                if (Default)
                {
                    deliverys = session.DeliverAddress.GetList(daf1);
                    for (int i = 0; i < deliverys.Count; i++)
                    {
                        deliverys[i].Default = 0;
                        session.DeliverAddress.Update(deliverys[i]);
                    }
                }
               id= session.DeliverAddress.Insert(deliveryaddress);

            }
            if (id > 0)
            {
                result.Result = true;
                result.Object = id;
            }
            return result;

        }


       /// <summary>
       /// 设置默认收货地址
       /// </summary>
       /// <param name="userid"></param>
       /// <param name="id"></param>
       /// <returns></returns>
        public EventResult SetDefaultAddress(int userid,int id)
        {
            EventResult result = new EventResult();
            IUser user = null;
            IDeliverAddress deliveryaddress = null;
            DeliverAddressFilter daf = new DeliverAddressFilter();
            daf.UserID = userid;
            daf.ID = id;
            using (IDataSession session = App.Store.OpenSession(false))
            {
                user = session.Users.GetByID(userid);
                deliveryaddress = session.DeliverAddress.Get(daf);
                
            }
            if (user == null)
            {
                result.Result = false;
                result.Message = "不存在此用户";
                return result;
            }
            if (deliveryaddress == null)
            {
                result.Result = false;
                result.Message = "不存在此地址";
                return result;
            }
            deliveryaddress.Default = 1;
            using (IDataSession session = App.Store.OpenSession(false))
            {
                session.DeliverAddress.Update(deliveryaddress);
            }
            return result;

        }
       /// <summary>
       /// 修改收货地址
       /// </summary>
       /// <param name="userid">用户ID</param>
       /// <param name="realName">收货人</param>
       /// <param name="area">省市区</param>
       /// <param name="address">收货地址</param>
       /// <param name="zip">邮编</param>
       /// <param name="Default">是否默认</param>
       /// <param name="mobile">手机号</param>
       /// <param name="id">记录ID</param>
       /// <returns></returns>
        public  EventResult ModifyAddress(int userid, string realName, string area, string address, string zip, bool Default, string mobile,int id)
        {
            EventResult result = new EventResult();
            if (String.IsNullOrEmpty(realName))
            {
                result.Result = false;
                result.Message = "收货人不能为空";
                return result;
            }
            if (StringUtils.GetStringByteLength(realName) > 100)
            {
                result.Result = false;
                result.Message = "收货人长度超过100个字符";
                return result;
            }
            if (String.IsNullOrEmpty(area))
            {
                result.Result = false;
                result.Message = "省市区不能为空";
                return result;
            }
            if (StringUtils.GetStringByteLength(area) > 200)
            {
                result.Result = false;
                result.Message = "省市区长度超过200个字符";
                return result;
            }
            if (String.IsNullOrEmpty(address))
            {
                result.Result = false;
                result.Message = "省市区不能为空";
                return result;
            }
            if (StringUtils.GetStringByteLength(address) > 500)
            {
                result.Result = false;
                result.Message = "收货地址长度超过500个字符";
                return result;
            }
            if (String.IsNullOrEmpty(zip))
            {
                result.Result = false;
                result.Message = "邮编不能为空";
                return result;
            }
            if (!StringUtils.ValidateString(zip, "zip"))
            {
                result.Result = false;
                result.Message = "邮编格式不正确";
                return result;
            }
            if (String.IsNullOrEmpty(mobile))
            {
                result.Result = false;
                result.Message = "联系电话不能为空";
                return result;
            }
            if (!StringUtils.ValidateString(mobile, "mobile"))
            {
                result.Result = false;
                result.Message = "联系电话格式不正确";
                return result;
            }
            if (userid < 1)
            {
                result.Result = false;
                result.Message = "请先登录再添加收货地址";
                return result;
            }
            IUser user = null;
            int count = 0;
            DeliverAddressFilter daf = new DeliverAddressFilter();
            IDeliverAddress deliveryaddress = null;
            daf.UserID = userid;
            daf.ID = id;
            using (IDataSession session = App.Store.OpenSession(false))
            {
                user = session.Users.GetByID(userid);
                deliveryaddress = session.DeliverAddress.GetByID(userid);
            }
            if (user == null)
            {
                result.Result = false;
                result.Message = "不存在此用户";
                return result;
            }
            if (deliveryaddress == null)
            {
                result.Result = false;
                result.Message = "不存在此收货地址";
                return result;
            }
            deliveryaddress.Address = address;
            deliveryaddress.Area = area;
            if (Default)
                deliveryaddress.Default = 1;
            else
                deliveryaddress.Default = 0;
            deliveryaddress.RealName = realName;
            deliveryaddress.Mobile = mobile;
            deliveryaddress.UserID = user.Id;
            deliveryaddress.Zip = zip;
            IList<IDeliverAddress> deliverys = null;
            DeliverAddressFilter daf1 = new DeliverAddressFilter();
            daf1.UserID = userid;
            daf1.Default = 1;
            using (IDataSession session = App.Store.OpenSession(false))
            {
                if (Default)
                {
                    deliverys = session.DeliverAddress.GetList(daf1);
                    for (int i = 0; i < deliverys.Count; i++)
                    {
                        deliverys[i].Default = 0;
                        session.DeliverAddress.Update(deliverys[i]);
                    }
                }
                session.DeliverAddress.Update(deliveryaddress);

            }
            result.Result = true;
            return result;

        }

        /// <summary>
        /// 更新用户信息
        /// </summary>
        /// <param name="email">邮件</param>
        /// <param name="username">用户名</param>
        /// <param name="password">密码</param>
        /// <param name="cpass">确认密码</param>
        /// <param name="Gender">性别</param>
        /// <param name="mobile">手机</param>
        /// <param name="cityid">城市id</param>
        /// <param name="qq">qq号码</param>
        /// <param name="avatar">头像</param>
        /// <returns></returns>
        public EventResult UserUpdate(string email, string username, string password,string cpass,string Gender, string mobile, int cityid, string qq,string avatar)
        {
            EventResult eResult = new EventResult();
            if (String.IsNullOrEmpty(email))
            {
                eResult.Result = false;
                eResult.Message = "Email不能为空";
                return eResult;
            }
            if (!AS.Common.Utils.StringUtils.ValidateString(email, "email"))
            {
                eResult.Result = false;
                eResult.Message = "Email格式不正确";
                return eResult;
            }
            if (AS.Common.Utils.StringUtils.GetStringByteLength(email) > 128)
            {
                eResult.Result = false;
                eResult.Message = "Email长度不正确,应小于128字节";
                return eResult;
            }
            if (!String.IsNullOrEmpty(password) && password != cpass)
            {
                eResult.Result = false;
                eResult.Message = "您两次输入的密码不一致，请修改！";
                return eResult;
            }
            if (String.IsNullOrEmpty(mobile))
            {
                eResult.Result = false;
                eResult.Message = "手机号不能为空";
                return eResult;
            }
            if (!AS.Common.Utils.StringUtils.ValidateString(mobile, "mobile"))
            {
                eResult.Result = false;
                eResult.Message = "手机号码格式不正确";
                return eResult;
            }
            IUser user = null;
          

            //获取当前用户信息
            UserFilter userFilter = new UserFilter();
            userFilter.Username = username;
            using (IDataSession session = App.Store.OpenSession(false))
            {
                user = session.Users.Get(userFilter);
            }
            if (user== null)
            {
                eResult.Result = false;
                eResult.Message = "请您登陆后在设置基本信息！谢谢！";
                return eResult;
            }
            user.City_id = cityid;
            if (user.Email != email)
            {
                //判断更改后的EMAIL是否重复
                userFilter.LoginName = email;
                IUser mailUser = null;
                using (IDataSession session = App.Store.OpenSession(false))
                {
                    mailUser = session.Users.Get(userFilter);
                }
                if (mailUser != null)
                {
                    eResult.Result = false;
                    eResult.Message = "当前Email已存在，请更换";
                    return eResult;
                }
                user.Email = email;
            }
            user.Gender =Gender;
            if(!String.IsNullOrEmpty(avatar))
                user.Avatar = avatar;
            user.Mobile = mobile;
            user.Qq = qq;
            if(password!="")
                user.Password = AS.Common.Utils.StringUtils.MD5(password + AS.Common.Utils.WebUtils.PassWordKey());
            int resultcount = 0;
            using (IDataSession session = App.Store.OpenSession(true))
            {
                resultcount=session.Users.Update(user);
                session.Commit();
            }
            if (resultcount > 0)
            {
                eResult.Result = true;
                eResult.Message = "更新基本信息成功！";
                eResult.Object = user;
                return eResult;
            }
            else
            {
                eResult.Result = false;
                eResult.Message = "更新基本信息失败！";
                return eResult;
            }
 
        }



        /// <summary>
        /// 使用代金券
        /// </summary>
        /// <param name="cart"></param>
        /// <param name="carttype">券类型</param>
        /// <param name="cardid">券号</param>
       /// <param name="userid">使用者用户ID</param>
       /// <returns></returns>
        public EventResult UseCard(Cart cart, string carttype,string cardid,int userid)
        {
            EventResult result = new EventResult();
            ICard card = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                card = session.Card.GetByID(cardid);
            }
            if (card == null)
            {
                result.Message = "不存在此代金券";
                result.Result = false;
                return result;
            }
            if (card.State == "已使用")
            {
                result.Message = "此代金券已被使用";
                result.Result = false;
                return result;
            }
            if (card.State == "已过期")
            {
                result.Message = "此代金券已过期";
                result.Result = false;
                return result;
            }
            if (card.user_id > 0 && card.user_id != userid)
            {
                result.Message = "您不能使用别人的代金券";
                result.Result = false;
                return result;
            }
            bool canuser = false;//是否可以使用代金券
            decimal usemoney = 99999;//订单金额需要满足多少元才能使用
            for (int i = 0; i < card.CodePriceList.Count; i++)
            {
                ICodePrice codeprice = card.CodePriceList[i];
                if (cart.TotalPrice >= codeprice.orderprice)
                {
                    cart.CardID = card.Id;
                    canuser = true;
                    break;
                }
                usemoney = codeprice.orderprice;
            }
            if (!canuser)
            {
                result.Message = "代金券使用失败，订单金额需满足" + usemoney + "元";
                result.Result = false;
                return result;
            }
            UserEvent ue = new UserEvent();
            ue.SaveCart(cart, carttype);
            result.Result = true;
            return result;
        }
       /// <summary>
       /// 会员删除订单
       /// </summary>
       /// <param name="orderid">订单ID</param>
       /// <param name="userid">会员ID</param>
       /// <returns></returns>
        public EventResult DeleteOrder(int orderid, int userid)
        {
            EventResult result = new EventResult();
            IOrder order = null;
            OrderFilter of = new OrderFilter();
            of.Id = orderid;
            of.User_id = userid;
            using (IDataSession session = App.Store.OpenSession(false))
            {
                order = session.Orders.Get(of);            
            }
            if (order == null)
            {
                result.Result = false;
                result.Message = "不存在此订单";
                return result;
            }
            if (order.State != "unpay")
            {
                result.Result = false;
                result.Message = "当前订单不能被删除";
                return result;
            }
            order.State = "cancel";
            using (IDataSession session = App.Store.OpenSession(false))
            {
                session.Orders.Update(order);
            }
            result.Result = true;
            result.Message = "订单"+order.Id+"取消成功";
            return result;


        }



        /// <summary>
        /// 会员提交咨询
        /// </summary>
        /// <param name="userid">会员ID</param>
        /// <param name="content">咨询内容</param>
        /// <param name="createtime"></param>
        /// <param name="teamid">项目ID</param>
       /// <param name="cityid">城市ID</param>
       /// <returns></returns>
        public EventResult CreateAsk(int userid, string content,DateTime createtime, int teamid = 0,int cityid=0)
        {
            EventResult result = new EventResult();
            if (String.IsNullOrEmpty(content))
            {
                result.Message = "资讯内容不能为空";
                result.Result = false;
                return result;
            }
            IUser user = null;
            IAsk ask = App.Store.CreateAsk();
            using (IDataSession session = App.Store.OpenSession(false))
            {
                user = session.Users.GetByID(userid);
            }
            if (user == null)
            {
                result.Message = "您还没有登录";
                result.Result = false;
                return result;
            }
            ask.User_id = userid;
            ask.Team_id = teamid;
            ask.Create_time = createtime;
            ask.Content = content;
            ask.City_id = cityid;
            int askid = 0;
            using (IDataSession session = App.Store.OpenSession(false))
            {
                askid= session.Ask.Insert(ask);
            }
            if (askid > 0)
            {
                result.Result = true;
                return result;
            }
            result.Message = "提交失败";
            result.Result = false;
            return result;

        }
        /// <summary>
        /// 邮件订阅功能
        /// </summary>
        /// <param name="userid"></param>
        /// <param name="id"></param>
        /// <returns></returns>
        public EventResult MailSubscription(string mail, int cityid)
        {
            EventResult result = new EventResult();
            if (!AS.Common.Utils.StringUtils.ValidateString(mail, "email"))
            {
                result.Message = "邮箱格式不正确，请重新输入您的邮箱！";
                result.Result = false;
                return result;
            }
            if (AS.Common.Utils.StringUtils.GetStringByteLength(mail) > 128)
            {
                result.Result = false;
                result.Message = "Email长度不正确,应小于128字节";
                return result;
            }
            if (mail == String.Empty)
            {
                result.Message = "请输入邮件地址";
                result.Result = false;
                return result;
            }
            else
            {
                MailerFilter filter = new MailerFilter();
                IMailer mailer = null;
                filter.Email = mail;
                using (IDataSession session = App.Store.OpenSession(false))
                {
                    mailer = session.Mailers.Get(filter);
                }
                if (mailer == null)
                {
                    mailer = App.Store.CreateMailer();
                    mailer.City_id = cityid;
                    mailer.Email = mail;
                    mailer.Secret = Guid.NewGuid().ToString();
                    int ret = 0;
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        ret = session.Mailers.Insert(mailer);
                    }
                    if (ret > 0)
                    {
                        result.Message = "订阅邮件成功";
                        result.Result = true;
                        return result;
                    }
                    else
                    {
                        result.Message = "订阅邮件失败";
                        result.Result = false;
                        return result;
                    }
                }
                else
                {
                    if (mailer.City_id == cityid)
                    {
                        result.Message = "您已经订阅过此城市了";
                        result.Result = false;
                        return result;
                    }
                    mailer = App.Store.CreateMailer();
                    mailer.City_id = cityid;
                    mailer.Email = mail;
                    mailer.Secret = Guid.NewGuid().ToString();
                    int ret = 0;
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        ret = session.Mailers.Insert(mailer);
                    }
                    if (ret > 0)
                    {
                        result.Message = "订阅邮件成功";
                        result.Result = true;
                        return result;
                    }
                    else
                    {
                        result.Message = "订阅邮件失败";
                        result.Result = false;
                        return result;
                    }
                }
            }
        }

    }
}
