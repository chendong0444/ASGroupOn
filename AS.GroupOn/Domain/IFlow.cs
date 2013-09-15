using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public interface IFlow : IObj
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
        /// 如果此记录是后台充值记录，则此字段保存为用户充值的管理员的UserID
        /// </summary>
        int Admin_id { get; set; }
        /// <summary>
        /// 记录订单交易号(如果是在线支付格式为：项目IDas用户idas订单idashhmmss，如果是在线充值为0as用户IDas0ashhmmss，如果是管理员人工充值则为0，如果是优惠券返利则记录的是优惠券表的ID，如果是邀请返利则为0)
        /// </summary>
        string Detail_id { get; set; }
        /// <summary>
        /// 描述
        /// </summary>
        string Detail { get; set; }
        /// <summary>
        /// 消费类型( 收益:income, 花费:expense)
        /// </summary>
        string Direction { get; set; }
        /// <summary>
        /// 收益或消费金额
        /// </summary>
        decimal Money { get; set; }
        /// <summary>
        /// 消费方式(购买:buy,在线充值 charge,优惠券返利:coupon,邀请好友:invite,store:线下充值,withdraw:提现,cash:现金支付,refund:退款,review:到货评价)
        /// </summary>
        string Action { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        DateTime Create_time { get; set; }

        IUser User { get; }

        IPay Pay { get; }

        ITeam Team { get; }

        IUser UserAdmin { get; }

    }
}