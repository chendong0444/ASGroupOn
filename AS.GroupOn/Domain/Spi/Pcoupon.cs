using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：站外优惠劵
    /// </summary>
    public class Pcoupon:Obj,IPcoupon
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 站外优惠券内容
        /// </summary>
        public virtual string number { get; set; }
        /// <summary>
        /// 用户ID
        /// </summary>
        public virtual int userid { get; set; }
        /// <summary>
        /// 拥有此券的商户编号
        /// </summary>
        public virtual int partnerid { get; set; }
        /// <summary>
        /// in Orderid
        /// </summary>
        public virtual int inOrderid { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
        public virtual int teamid { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        public virtual DateTime create_time { get; set; }
        /// <summary>
        /// 购买时间
        /// </summary>
        public virtual DateTime? buy_time { get; set; }
        /// <summary>
        /// 优惠券状态是否被购买 nobuy,buy
        /// </summary>
        public virtual string state { get; set; }
        /// <summary>
        /// 优惠券开始时间
        /// </summary>
        public virtual DateTime? start_time { get; set; }
        /// <summary>
        /// 优惠券结束时间
        /// </summary>
        public virtual DateTime expire_time { get; set; }
        /// <summary>
        /// 订单ID
        /// </summary>
        public virtual int orderid { get; set; }
        /// <summary>
        /// 短信发送次数
        /// </summary>
        public virtual int sms { get; set; }
        /// <summary>
        /// 短信发送时间
        /// </summary>
        public virtual DateTime? sms_time { get; set; }

        /////////////////////////////////////////////////////////////////
        private ITeam _team = null;
        /// <summary>
        /// 站外券所属的项目
        /// </summary>
        public virtual ITeam Team
        {
            get
            {
                if (_team == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _team = session.Teams.GetByID(this.teamid);
                    }
                }
                return _team;
            }
        }
        private IUser _user = null;
        /// <summary>
        /// 站外券所属的用户
        /// </summary>
        public virtual IUser User
        {
            get
            {
                if (_user == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _user = session.Users.GetByID(this.userid);
                    }
                }
                return _user;
            }
        }
        private IOrder _order = null;
        /// <summary>
        /// 站外券所属的订单
        /// </summary>
        public virtual IOrder Order
        {
            get
            {
                if (_order == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _order = session.Orders.GetByID(this.orderid);
                    }
                }
                return _order;
            }
        }

    }
}
