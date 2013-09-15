using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.Domain.Spi
{
    public class Coupon : Obj, ICoupon
    {
        /// <summary>
        /// 券号
        /// </summary>
        public virtual string Id { get; set; }
        /// <summary>
        /// 用户ID
        /// </summary>
        public virtual int User_id { get; set; }
        /// <summary>
        /// 商户ID
        /// </summary>
        public virtual int Partner_id { get; set; }
        /// <summary>
        ///In Order_id
        /// </summary>
        public virtual int inOrder_id { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
        public virtual int Team_id { get; set; }
        /// <summary>
        /// 订单ID
        /// </summary>
        public virtual int Order_id { get; set; }
        /// <summary>
        /// 券类型
        /// </summary>
        public virtual string Type { get; set; }
        /// <summary>
        /// 消费返利金额
        /// </summary>
        public virtual int Credit { get; set; }
        /// <summary>
        /// 优惠券密码
        /// </summary>
        public virtual string Secret { get; set; }
        /// <summary>
        /// 消费状态
        /// </summary>
        public virtual string Consume { get; set; }
        /// <summary>
        /// 消费IP
        /// </summary>
        public virtual string IP { get; set; }
        /// <summary>
        /// 短信发送次数
        /// </summary>
        public virtual int Sms { get; set; }
        /// <summary>
        /// 优惠券过期时间
        /// </summary>
        public virtual DateTime Expire_time { get; set; }
        /// <summary>
        /// 消费时间
        /// </summary>
        public virtual DateTime? Consume_time { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        public virtual DateTime Create_time { get; set; }
        /// <summary>
        /// 短信发送时间
        /// </summary>
        public virtual DateTime? Sms_time { get; set; }
        /// <summary>
        /// 优惠券开始时间
        /// </summary>
        public virtual DateTime? start_time { get; set; }
        /// <summary>
        /// 所在店铺ID
        /// </summary>
        public virtual int shoptypes { get; set; }

        ///////////////////////////////////////////////////////////////////
        ITeam _team = null;
        /// <summary>
        /// 所属项目
        /// </summary>
        public virtual ITeam Team
        {
            get
            {
                if (_team == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _team = session.Teams.GetByID(Team_id);
                    }
                    if (_team == null)
                        _team = AS.GroupOn.Domain.Spi.Team.GetDefault();
                }
                return _team;
            }
        }
        IUser _user = null;
        /// <summary>
        /// 所属用户
        /// </summary>
        public virtual IUser User
        {
            get
            {
                if (_user == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _user = session.Users.GetByID(User_id);
                    }
                    if (_user == null)
                        _user = AS.GroupOn.Domain.Spi.User.GetDefault();
                }
                return _user;
            }
        }
        IOrder _order = null;
        /// <summary>
        /// 所属订单
        /// </summary>
        public virtual IOrder Order
        {
            get
            {
                if (_order == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _order = session.Orders.GetByID(Order_id);
                    }
                }
                return _order;
            }
        }
        IPartner _partner = null;
        /// <summary>
        /// 所属商户
        /// </summary>
        public virtual IPartner Partner
        {
            get
            {
                if (_partner==null)
                {
                    using (IDataSession session=App.Store.OpenSession(false))
                    {
                        _partner = session.Partners.GetByID(this.Partner_id);
                    }
                }
                return _partner;
            }
        }

        /// <summary>
        /// 优惠券状态,已使用，未使用，已过期
        /// </summary>
        public virtual string State
        {
            get
            {
                if (Consume.ToUpper() == "Y")
                {
                    return "已使用";
                }
                else if (DateTime.Now > Expire_time)
                    return "已过期";
                return "未使用";
            }
        }
    }
}
