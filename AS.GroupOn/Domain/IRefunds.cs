using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：退款
    /// </summary>
    public interface IRefunds : IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int Id { get; set; }
        /// <summary>
        /// 状态字段1 客服申请2 商户审核通过 4等待财务接受 8财务接受 16 财务处理完毕
        /// </summary>
        int State { get; set; }
        /// <summary>
        /// 申请退款时间
        /// </summary>
        DateTime? Create_Time { get; set; }
        /// <summary>
        /// 商户查看时间
        /// </summary>
        DateTime? PartnerViewTime { get; set; }
        /// <summary>
        /// 订单ID
        /// </summary>
        int Order_ID { get; set; }
        /// <summary>
        /// 退款金额
        /// </summary>
        decimal Money { get; set; }
        /// <summary>
        /// 商户ID 
        /// </summary>
        int PartnerID { get; set; }
        /// <summary>
        /// 等待财务接受时间
        /// </summary>
        DateTime? FinanceBeginTime { get; set; }
        /// <summary>
        /// 财务处理时间
        /// </summary>
        DateTime? FinanceEndTime { get; set; }
        /// <summary>
        /// 1余额退款 2其他方式退款
        /// </summary>
        int RefundMeans { get; set; }
        /// <summary>
        /// 由客服填写 退款原因
        /// </summary>
        string Reason { get; set; }
        /// <summary>
        /// 由财务填写 退款结果
        /// </summary>
        string Result { get; set; }
        /// <summary>
        /// 申请退款的管理员ID
        /// </summary>
        int CreateUserID { get; set; }
        /// <summary>
        /// 处理的管理员ID
        /// </summary>
        int AdminID { get; set; }

        ////////////////////////////////////
        /// <summary>
        /// 退款详情
        /// </summary>
        IList<IRefunds_detail> Refunds_details { get;}
        /// <summary>
        /// 订单详情
        /// </summary>
        IOrder Order { get;}
        /// <summary>
        /// 所属商户
        /// </summary>
        IPartner Partner { get;}
        /// <summary>
        /// In Order.id where city_id
        /// </summary>
        int inorder_id { get; }
    }
}
