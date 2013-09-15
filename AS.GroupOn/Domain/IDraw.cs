using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public interface IDraw : IObj
    {
        /// <summary>
        /// 主键
        /// </summary>
        int id { get; }
        /// <summary>
        /// 得奖主用户ID
        /// </summary>
        int userid { get; set; }
        /// <summary>
        /// 创建时间
        /// </summary>
        DateTime createtime { get; set; }
        /// <summary>
        /// 抽奖号码
        /// </summary>
        string number { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
        int teamid { get; set; }
        /// <summary>
        /// 订单ID
        /// </summary>
        int orderid { get; set; }
        /// <summary>
        /// 邀请人ID
        /// </summary>
        int inviteid { get; set; }
        /// <summary>
        /// 邀请状态Y代表已中奖 N代表未中奖
        /// </summary>
        string state { get; set; }
        /// <summary>
        /// count(id)
        /// </summary>
        int sum { get; set; }

        IUser User { get; }
    }
}
