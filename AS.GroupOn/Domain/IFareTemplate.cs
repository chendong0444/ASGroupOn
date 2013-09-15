using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    /// <summary>
    /// 运费模版
    /// </summary>
   public interface IFareTemplate:IObj
    {
       /// <summary>
       /// ID
       /// </summary>
       int id { get; set; }
       /// <summary>
       /// 运费模版
       /// </summary>
       string name { get; set; }
       /// <summary>
       /// 模版内容
       /// </summary>
       string value { get; set; }
    }
}
