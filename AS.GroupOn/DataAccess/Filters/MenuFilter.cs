using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建时间 ： 2012-10-24 
    /// 创建人:     zlj
    /// </summary>
   public  class MenuFilter:FilterBase
   {
       #region 操作页面表排序字段
       public const string ID_ASC = "id asc";
       public const string ID_DESC = "id desc";
       public const string SORT_ASC = "sort asc";
       public const string SORT_DESC = "sort desc";

       /// <summary>
       /// ID 号
       /// </summary>
       public int? id { get; set; }
       /// <summary>
       /// 排序
       /// </summary>
       public int? sort { get; set; }
       #endregion

   }
}
