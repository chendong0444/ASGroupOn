using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：积分消费记录
    /// </summary>
    public interface IScorelog:IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 积分值 正为收入负为花费
        /// </summary>
        int score { get; set; }
        /// <summary>
        /// 行为：'下单','退单','积分兑换','取消兑换','签到' 
        /// </summary>
        string action { get; set; }
        /// <summary>
        /// 关联ID (订单ID)
        /// </summary>
        string key { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        DateTime create_time { get; set; }
        /// <summary>
        /// 不是管理员操作此项默认为0
        /// </summary>
        int adminid { get; set; }
        /// <summary>
        /// 对应的用户ID
        /// </summary>
        int user_id { get; set; }

        IUser User { get; }

    }
}
