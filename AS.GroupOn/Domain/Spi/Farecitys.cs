using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
   public class Farecitys:Obj,IFarecitys
    {
       /// <summary>
       /// 主键
       /// </summary>
       public virtual int id { get; set; }
       /// <summary>
       /// 父类ID
       /// </summary>
       public virtual int pid { get; set; }
       /// <summary>
       /// 城市名称
       /// </summary>
       public virtual string name { get; set; }

       
    }
}
