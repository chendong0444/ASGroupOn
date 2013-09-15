using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface ICoupon:IObj
    {
        /// <summary>
        /// 券号
        /// </summary>
        string Id { get; set; }
        /// <summary>
        /// 用户ID
        /// </summary>
        int User_id { get; set; }
        /// <summary>
        /// 商户ID
        /// </summary>
        int Partner_id { get; set; }
        /// <summary>
        /// In Order_id
        /// </summary>
        int inOrder_id { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
        int Team_id { get; set; }
        /// <summary>
        /// 订单ID
        /// </summary>
        int Order_id { get; set; }
        /// <summary>
        /// 券类型
        /// </summary>
        string Type { get; set; }
        /// <summary>
        /// 消费返利金额
        /// </summary>
        int Credit { get; set; }
        /// <summary>
        /// 优惠券密码
        /// </summary>
        string Secret { get; set; }
        /// <summary>
        /// 消费状态
        /// </summary>
        string Consume { get; set; }
        /// <summary>
        /// 消费IP
        /// </summary>
        string IP { get; set; }
        /// <summary>
        /// 短信发送次数
        /// </summary>
        int Sms { get; set; }
        /// <summary>
        /// 优惠券过期时间
        /// </summary>
        DateTime Expire_time { get; set; }
        /// <summary>
        /// 消费时间
        /// </summary>
        DateTime? Consume_time { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        DateTime Create_time { get; set; }
        /// <summary>
        /// 短信发送时间
        /// </summary>
        DateTime? Sms_time { get; set; }
        /// <summary>
        /// 优惠券开始时间
        /// </summary>
        DateTime? start_time { get; set; }
        /// <summary>
        /// 所在店铺ID
        /// </summary>
        int shoptypes { get; set; }

        ////////////////////////////////////////////////////////////
        /// <summary>
        /// 所属项目
        /// </summary>
        ITeam Team { get; }
        /// <summary>
        /// 所属用户
        /// </summary>
        IUser User { get; }
        /// <summary>
        /// 所属订单
        /// </summary>
        IOrder Order { get; }
        /// <summary>
        /// 所属商户
        /// </summary>
        IPartner Partner { get; }
        /// <summary>
        /// 优惠券状态,已使用，未使用，已过期
        /// </summary>
        string State { get; }

    }
}
