using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface IPartner_Detail : IObj
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
        /// 创建时间
        /// </summary>
        DateTime createtime { get; set; }
        /// <summary>
        /// 管理员ID
        /// </summary>
        int adminid { get; set; }
        /// <summary>
        /// 结算金额
        /// </summary>
        decimal money { get; set; }
        /// <summary>
        /// 备注
        /// </summary>
        string remark { get; set; }
        /// <summary>
        /// 结算申请备注
        /// </summary>
        string settlementremark { get; set; }
        /// <summary>
        /// 结算状态--8代表已结算。1代表待审核. 2代表被拒绝 ,4代表正在结算
        /// </summary>
        int settlementstate { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
        int team_id { get; set; }
        /// <summary>
        /// 数量
        /// </summary>
        int num { get; set; }
        //返回管理员
        string GetAdminName { get; }
    }
}
