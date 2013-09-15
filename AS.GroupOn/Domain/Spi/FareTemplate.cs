using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
   public class FareTemplate:Obj,IFareTemplate
    {
        /// <summary>
        /// ID
        /// </summary>
       public virtual int id { get; set; }
        /// <summary>
        /// 运费模版
        /// </summary>
       public virtual string name { get; set; }
        /// <summary>
        /// 模版内容
        /// </summary>
       public virtual string value { get; set; }
    }
}
