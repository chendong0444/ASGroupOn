using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
   public class Expressprice:Obj,IExpressprice
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
       /// 首件运费
       /// </summary>
       public virtual decimal oneprice { get; set; }
       /// <summary>
       /// 次件运费
       /// </summary>
       public virtual decimal twoprice { get; set; }

    }
}
