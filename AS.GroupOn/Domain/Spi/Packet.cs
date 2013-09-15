using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 红包表
    /// </summary>
    public class Packet : Obj, IPacket
    {
        /// <summary>
        /// 主键
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 用户ID
        /// </summary>
        public virtual int User_id { get; set; }
        /// <summary>
        /// 金额
        /// </summary>
        public virtual decimal Money { get; set; }
        /// <summary>
        /// 代金券号
        /// </summary>
        public virtual string Number { get; set; }
        /// <summary>
        /// 管理员ID
        /// </summary>
        public virtual int Admin_Id { get; set; }
        /// <summary>
        /// 红包类型（money:金额 card:代金券）
        /// </summary>
        public virtual string Type { get; set; }
        /// <summary>
        /// 状态（0：未领取1：领取）
        /// </summary>
        public virtual int State { get; set; }
        /// <summary>
        /// 发送时间
        /// </summary>
        public virtual DateTime Send_Time { get; set; }
        /// <summary>
        /// 领取时间
        /// </summary>
        public virtual DateTime Get_Time { get; set; }
    }
}
