using System;
using System.Collections.Generic;
using System.Text;
using AS.Common.Utils;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：促销活动规则
    /// </summary>
    public class Promotion_rules:Obj,IPromotion_rules
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 满足的金额（满足本金额可参与此促销活动）
        /// </summary>
        public virtual decimal full_money { get; set; }
        /// <summary>
        /// 类别id(促销活动类别：免运费，减现金，送余额)
        /// </summary>
        public virtual int typeid { get; set; }
        /// <summary>
        /// 所送金额
        /// </summary>
        public virtual decimal feeding_amount { get; set; }
        /// <summary>
        /// 开始时间
        /// </summary>
        public virtual DateTime start_time { get; set; }
        /// <summary>
        /// 结束时间
        /// </summary>
        public virtual DateTime end_time { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        public virtual int sort { get; set; }
        /// <summary>
        /// 描述
        /// </summary>
        public virtual string rule_description { get; set; }
        /// <summary>
        /// 是否启用
        /// </summary>
        public virtual int enable { get; set; }
        /// <summary>
        /// 是否免运费
        /// </summary>
        public virtual int free_shipping { get; set; }
        /// <summary>
        /// 减免的金额
        /// </summary>
        public virtual decimal deduction { get; set; }
        /// <summary>
        /// 活动编号（促销活动表）
        /// </summary>
        public virtual int activtyid { get; set; }

        /// <summary>
        /// 得到促销活动规则ID
        /// </summary>
        /// <returns></returns>
        public string getPromotionID
        {
            get
            {
                ICategory icategory = null;
                ICategory icategory2 = null;
                ICategory icategory3 = null;
                CategoryFilter categoryfilter = new CategoryFilter();
                categoryfilter.Ename = "Free_shipping";
                categoryfilter.Zone = "activity";
                CategoryFilter categoryfilter2 = new CategoryFilter();
                categoryfilter2.Ename = "Deduction";
                categoryfilter2.Zone = "activity";
                CategoryFilter categoryfilter3 = new CategoryFilter();
                categoryfilter3.Ename = "Feeding_amount";
                categoryfilter3.Zone = "activity";
                using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                {
                    icategory = session.Category.Get(categoryfilter);
                    icategory2 = session.Category.Get(categoryfilter2);
                    icategory3 = session.Category.Get(categoryfilter3);
                }
                int free_shipping = Helper.GetInt(icategory.Id, 0);
                int Deduction = Helper.GetInt(icategory2.Id, 0);
                int Feeding_amount = Helper.GetInt(icategory3.Id, 0);
                string PromotionID = free_shipping + "," + Deduction + "," + Feeding_amount;
                return PromotionID;
            }
        }

    }
}
