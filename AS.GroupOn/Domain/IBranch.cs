using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建者：zjq
    /// 时间：2012-10-26
    /// </summary>
    public interface IBranch
    {
        /// <summary>
        /// 主键
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 商家ID
        /// </summary>
        int partnerid { get; set; }
        /// <summary>
        /// 分站名称
        /// </summary>
        string branchname { get; set; }
        /// <summary>
        /// 联系人
        /// </summary>
        string contact { get; set; }
        /// <summary>
        /// 联系电话
        /// </summary>
        string phone { get; set; }
        /// <summary>
        /// 联系地址
        /// </summary>
        string address { get; set; }
        /// <summary>
        /// 联系人手机
        /// </summary>
        string mobile { get; set; }
        /// <summary>
        /// 经纬度
        /// </summary>
        string point { get; set; }
        /// <summary>
        /// 消费密码
        /// </summary>
        string secret { get; set; }
        /// <summary>
        /// 分店登录名
        /// </summary>
        string username { get; set; }
        /// <summary>
        /// 分店密码
        /// </summary>
        string userpwd { get; set; }
        /// <summary>
        /// 400验证电话
        /// </summary>
        string verifymobile { get; set; }
        /// <summary>
        /// 返回商家名称
        /// </summary>
        IPartner getPartnerTitle { get; }
        /// <summary>
        /// 返回以消费优惠券数量
        /// </summary>
        int GetYXJbyGroup { get; }
    }
}
