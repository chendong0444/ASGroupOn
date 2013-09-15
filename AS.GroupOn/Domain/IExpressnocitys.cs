using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public interface IExpressnocitys:IObj
    {
        /// <summary>
        /// 主键
        /// </summary>
        int id { get; }
        /// <summary>
        /// 快递公司ID
        /// </summary>
        int expressid { get; set; }
        /// <summary>
        /// 城市列表格式如（22,3,4,5,6,7,8）记录城市ID
        /// </summary>
        string nocitys { get; set; }
    }
}
