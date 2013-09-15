using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：积分消费记录
    /// </summary>
    public class Scorelog:Obj,IScorelog
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 积分值 正为收入负为花费
        /// </summary>
        public virtual int score { get; set; }
        /// <summary>
        /// 行为：'下单','退单','积分兑换','取消兑换','签到' 
        /// </summary>
        public virtual string action { get; set; }
        /// <summary>
        /// 关联ID (订单ID)
        /// </summary>
        public virtual string key { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        public virtual DateTime create_time { get; set; }
        /// <summary>
        /// 不是管理员操作此项默认为0
        /// </summary>
        public virtual int adminid { get; set; }
        /// <summary>
        /// 对应的用户ID
        /// </summary>
        public virtual int user_id { get; set; }

        
        private IUser _user = null;
        /// <summary>
        /// 订单下面的用户
        /// </summary>
        public virtual IUser User
        {
            get
            {
                if (_user == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _user = session.Users.GetByID(user_id);
                    }
                }
                return _user;
            }

        }
    }
}
