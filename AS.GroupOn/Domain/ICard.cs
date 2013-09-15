using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{

    /// <summary>
    /// zjq 修改
    /// 2012-10-24
    /// </summary>
    public interface ICard:IObj
    {
        /// <summary>
        /// 券号
        /// </summary>
        string Id { get; set; }
        /// <summary>
        /// 行动代号
        /// </summary>
        string Code { get; set; }
        /// <summary>
        /// 商户ID
        /// </summary>
        int Partner_id { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
        int Team_id { get; set; }

        /// <summary>
        /// 订单ID
        /// </summary>
        int Order_id { get; set; }
        /// <summary>
        /// /// <summary>
        /// in Order_id 
        /// </summary>
        int inOrder_id { get; set; }
        /// <summary>
        /// 可待金额
        /// </summary>
        int Credit { get; set; }
        /// <summary>
        /// 使用状态N 未使用 Y已使用
        /// </summary>
        string consume { get; set; }
        /// <summary>
        /// 使用者IP
        /// </summary>
        string Ip { get; set; }
        /// <summary>
        /// 开始时间
        /// </summary>
        DateTime Begin_time { get; set; }
        /// <summary>
        /// 结束时间
        /// </summary>
        DateTime End_time { get; set; }
        /// <summary>
        /// 使用者会员ID
        /// </summary>
        int user_id { get; set; }
        /// <summary>
        /// 是否领取
        /// </summary>
        int isGet { get; set; }
        /// <summary>
        /// 代金券状态 未使用 已使用 已过期
        /// </summary>
        string State { get; }

        /// <summary>
        /// 返回用户
        /// </summary>
        IUser User { get; }

        /// <summary>
        /// 返回商户
        /// </summary>
        IPartner Partner { get; }

        /// <summary>
        /// 返回项目
        /// </summary>
        ITeam Team { get; }

        /// <summary>
        /// 返回订单
        /// </summary>
        IOrder Order { get; }

        /// <summary>
        /// 返回分类
        /// </summary>
        ICategory Category { get; }

        int uId { get; set; }
        string uEmail { get; set; }
        string uUserName { get; set; }
        string uRealname { get; set; }
        int uCity_id { get; set; }
        decimal uMoney { get; set; }
        decimal uTotalamount { get; set; }
        string uZipcode { get; set; }
        DateTime uCreate_time { get; set; }
        string uMobile { get; set; }
        int oCount { get; set; } 
    }
}
