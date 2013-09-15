using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建时间 2012-10-24 
    /// 创建人   郑立军
    /// </summary>
    public class Invite : Obj, IInvite
    {
        #region 邀请表
        /// <summary>
        /// 主键
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 主动邀请的会员ID
        /// </summary>
        public virtual int User_id { get; set; }
        /// <summary>
        /// 管理员ID
        /// </summary>
        public virtual int Admin_id { get; set; }
        /// <summary>
        /// 主动邀请的会员IP
        /// </summary>
        public virtual string User_ip { get; set; }
        /// <summary>
        /// 被邀请人ID
        /// </summary>
        public virtual int Other_user_id { get; set; }
        /// <summary>
        /// 被邀请人IP
        /// </summary>
        public virtual string Other_user_ip { get; set; }
        /// <summary>
        /// 被邀人购买的项目ID
        /// </summary>
        public virtual int Team_id { get; set; }
        /// <summary>
        /// 返利状态 N 未购买 Y 已购买 C 违规 P 已返利
        /// </summary>
        public virtual string Pay { get; set; }
        /// <summary>
        /// 返利金额
        /// </summary>
        public virtual int Credit { get; set; }
        /// <summary>
        /// 购买时间
        /// </summary>
        public virtual DateTime? Buy_time { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        public virtual DateTime Create_time { get; set; }

        private IUser _otheruser = null;
        /// <summary>
        /// 被邀请人
        /// </summary>
        public virtual IUser OtherUser
        {
            get
            {
                if (_otheruser == null)
                {

                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _otheruser = session.Users.GetByID(Other_user_id);
                    }
                    if (_otheruser == null)
                        _otheruser = AS.GroupOn.Domain.Spi.User.GetDefault();
                }
                return _otheruser;
            }
        }

        private ITeam _team = null;
        /// <summary>
        /// 返回组对象
        /// </summary>
        public virtual ITeam Team
        {
            get
            {
                if (_team == null)
                {
                    using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                    {
                        _team = session.Teams.GetByID(this.Team_id);
                    }
                }
                return _team;
            }
        }

        private IList<IOrderDetail> _orderdetails = null;
        /// <summary>
        /// 返回组对象
        /// </summary>
        public virtual IList<IOrderDetail> OrderDetails
        {
            get
            {
                if (_orderdetails == null)
                {
                    using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                    {
                        OrderDetailFilter odf = new OrderDetailFilter();
                        odf.Order_ID = this.Id;
                        _orderdetails = session.OrderDetail.GetList(odf);
                    }
                }
                return _orderdetails;
            }
        }

        private IList<IUser> _users = null;
        /// <summary>
        /// 主动用户
        /// </summary>
        public virtual IList<IUser> Users
        {
            get
            {
                if (_users == null)
                {

                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        UserFilter userfilter = new UserFilter();
                        userfilter.ID = this.User_id;
                        _users = session.Users.GetList(userfilter);
                    }
                }
                return _users;
            }
        }

        private IUser _user = null;
        /// <summary>
        /// 用户
        /// </summary>
        public virtual IUser User
        {
            get
            {
                if (_user == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _user = session.Users.GetByID(this.User_id);
                    }
                }
                return _user;
            }
        }

        /*--关联user|category表--*/
        public virtual string Username { get; set; }
        public virtual string Email { get; set; }
        public virtual string Mobile { get; set; }
        public virtual string IP_Address { get; set; }

        public virtual string Name { get; set; }
        public virtual int num { get; set; }
        #endregion
    }
}
