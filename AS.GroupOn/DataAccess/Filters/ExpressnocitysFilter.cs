using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
   public class ExpressnocitysFilter:FilterBase
    {
       public const string ID_ASC = "Id asc";
       public const string ID_DESC = "Id desc";

       public int? id { get; set; }
       public int? expressid { get; set; }
       public string nocitys { get; set; }
    }
}
