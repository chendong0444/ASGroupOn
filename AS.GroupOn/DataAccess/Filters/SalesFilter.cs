using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-11-2
    /// </summary>
   public  class SalesFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";


        public int? id { get; set; }

        public string username { get; set; }

        public string password { get; set; }
    }
}
