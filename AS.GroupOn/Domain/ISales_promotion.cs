using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：促销活动
    /// </summary>
    public interface ISales_promotion:IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 促销活动名称
        /// </summary>
        string name { get; set; }
        /// <summary>
        /// 促销活动描述
        /// </summary>
        string description { get; set; }
        /// <summary>
        /// 是否发布
        /// </summary>
        int enable { get; set; }
        /// <summary>
        /// 活动开始时间
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


    }
}
