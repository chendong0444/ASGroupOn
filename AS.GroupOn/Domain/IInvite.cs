using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public interface IInvite:IObj
    {
        #region 邀请表
        /// <summary>
        /// 主键
        /// </summary>
        int Id { get; set; }
        /// <summary>
        /// 主动邀请的会员ID
        /// </summary>
        int User_id { get; set; }
        /// <summary>
        /// 管理员ID
        /// </summary>
        int Admin_id { get; set; }
        /// <summary>
        /// 主动邀请的会员IP
        /// </summary>
        string User_ip { get; set; }
        /// <summary>
        /// 被邀请人ID
        /// </summary>
        int Other_user_id { get; set; }
        /// <summary>
        /// 被邀请人IP
        /// </summary>
        string Other_user_ip { get; set; }
        /// <summary>
        /// 被邀人购买的项目ID
        /// </summary>
        int Team_id { get; set; }
        /// <summary>
        /// 返利状态 N 未购买 Y 已购买 C 违规 P 已返利
        /// </summary>
        string Pay { get; set; }
        /// <summary>
        /// 返利金额
        /// </summary>
        int Credit { get; set; }
        /// <summary>
        /// 购买时间
        /// </summary>
        DateTime? Buy_time { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        DateTime Create_time { get; set; }
        /// <summary>
        /// 被邀请人
        /// </summary>
        IUser OtherUser { get; }

        /// <summary>
        /// 返回项目
        /// </summary>
        ITeam Team { get; }

        /// <summary>
        /// 返回项目
        /// </summary>
        IList<IOrderDetail> OrderDetails { get; }

        /// <summary>
        /// 主动用户
        /// </summary>
        IList<IUser> Users { get; }

        /// <summary>
        /// 用户
        /// </summary>
        IUser User { get; }

        /*--关联user|category表--*/
        string Username { get; set; }
        string Email { get; set; }
        string Mobile { get; set; }
        string IP_Address { get; set; }

        string Name { get; set; }
        int num { get; set; }
        #endregion
    }
}
