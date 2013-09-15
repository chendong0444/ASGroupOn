using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：促销活动规则
    /// </summary>
    public interface IPromotion_rules:IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 满足的金额（满足本金额可参与此促销活动）
        /// </summary>
        decimal full_money { get; set; }
        /// <summary>
        /// 类别id(促销活动类别：免运费，减现金，送余额)
        /// </summary>
        int typeid { get; set; }
        /// <summary>
        /// 所送金额
        /// </summary>
        decimal feeding_amount { get; set; }
        /// <summary>
        /// 开始时间
        /// </summary>
        DateTime start_time { get; set; }
        /// <summary>
        /// 结束时间
        /// </summary>
        DateTime end_time { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        int sort { get; set; }
        /// <summary>
        /// 描述
        /// </summary>
        string rule_description { get; set; }
        /// <summary>
        /// 是否启用
        /// </summary>
        int enable { get; set; }
        /// <summary>
        /// 是否免运费
        /// </summary>
        int free_shipping { get; set; }
        /// <summary>
        /// 减免的金额
        /// </summary>
        decimal deduction { get; set; }
        /// <summary>
        /// 活动编号（促销活动表）
        /// </summary>
        int activtyid { get; set; }

        /// <summary>
        /// 得到促销活动规则ID
        /// </summary>
        string getPromotionID { get; }


    }
}
