using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：站外优惠劵
    /// </summary>
    public interface IPcoupon : IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 站外优惠券内容
        /// </summary>
        string number { get; set; }
        /// <summary>
        /// 用户ID
        /// </summary>
        int userid { get; set; }
        /// <summary>
        /// 拥有此券的商户编号
        /// </summary>
        int partnerid { get; set; }
        /// <summary>
        ///in Orderid
        /// </summary>
        int inOrderid { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
        int teamid { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        DateTime create_time { get; set; }
        /// <summary>
        /// 购买时间
        /// </summary>
        DateTime? buy_time { get; set; }
        /// <summary>
        /// 优惠券状态是否被购买 nobuy,buy
        /// </summary>
        string state { get; set; }
        /// <summary>
        /// 优惠券开始时间
        /// </summary>
        DateTime? start_time { get; set; }
        /// <summary>
        /// 优惠券结束时间
        /// </summary>
        DateTime expire_time { get; set; }
        /// <summary>
        /// 订单ID
        /// </summary>
        int orderid { get; set; }
        /// <summary>
        /// 短信发送次数
        /// </summary>
        int sms { get; set; }
        /// <summary>
        /// 短信发送时间
        /// </summary>
        DateTime? sms_time { get; set; }
        /////////////////////////////////////////////////////////////////
        /// <summary>
        /// 站外券所属的项目
        /// </summary>
        ITeam Team { get; }
        /// <summary>
        /// 站外券所属的用户
        /// </summary>
        IUser User { get; }
        /// <summary>
        /// 站外券所属的订单
        /// </summary>
        IOrder Order { get; }
    }
}
