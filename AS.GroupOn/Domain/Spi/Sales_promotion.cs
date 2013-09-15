using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：促销活动
    /// </summary>
    public class Sales_promotion:Obj,ISales_promotion
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 促销活动名称
        /// </summary>
        public virtual string name { get; set; }
        /// <summary>
        /// 促销活动描述
        /// </summary>
        public virtual string description { get; set; }
        /// <summary>
        /// 是否发布
        /// </summary>
        public virtual int enable { get; set; }
        /// <summary>
        /// 活动开始时间
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
    }
}
