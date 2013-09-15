using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
   public interface IFarecitys:IObj
    {
       /// <summary>
       /// 主键
       /// </summary>
       int id { get; set; }
       /// <summary>
       /// 父类ID
       /// </summary>
       int pid { get; set; }
       /// <summary>
       /// 城市名称
       /// </summary>
       string name { get; set; }

      

    }
}
