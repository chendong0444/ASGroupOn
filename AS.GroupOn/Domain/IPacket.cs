using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 红包表
    /// </summary>
    public interface IPacket : IObj
    {
        /// <summary>
        /// 主键
        /// </summary>
        int Id { get; }
        /// <summary>
        /// 用户ID
        /// </summary>
        int User_id { get; set; }
        /// <summary>
        /// 金额
        /// </summary>
        decimal Money { get; set; }
        /// <summary>
        /// 代金券号
        /// </summary>
        string Number { get; set; }
        /// <summary>
        /// 管理员ID
        /// </summary>
        int Admin_Id { get; set; }
        /// <summary>
        /// 红包类型（money:金额 card:代金券）
        /// </summary>
        string Type { get; set; }
        /// <summary>
        /// 状态（0：未领取1：领取）
        /// </summary>
        int State { get; set; }
        /// <summary>
        /// 发送时间
        /// </summary>
        DateTime Send_Time { get; set; }
        /// <summary>
        /// 领取时间
        /// </summary>
        DateTime Get_Time { get; set; }
    }
}
