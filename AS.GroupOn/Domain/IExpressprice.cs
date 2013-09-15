using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public interface IExpressprice:IObj
    {
        /// <summary>
        /// 主键
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 快递公司ID
        /// </summary>
        int expressid { get; set; }
        /// <summary>
        /// 首件运费
        /// </summary>
        decimal oneprice { get; set; }
        /// <summary>
        /// 次件运费
        /// </summary>
        decimal twoprice { get; set; }
    }
}
