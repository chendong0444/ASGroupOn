using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public class Expressnocitys:Obj,IExpressnocitys
    {
        /// <summary>
        /// 主键
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 快递公司ID
        /// </summary>
        public virtual int expressid { get; set; }
        /// <summary>
        /// 城市列表格式如（22,3,4,5,6,7,8）记录城市ID
        /// </summary>
        public virtual string nocitys { get; set; }
    }
}
