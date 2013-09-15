using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public class GuidFilter:FilterBase
    {
        #region GuidFilter成员
        public const string Id_Desc = "Id desc";
        public const string ID_ASC = "Id asc";

        public const string guidsort_desc = "guidsort desc";
        public const string guidsort_asc = "guidsort asc";
       
        public int? id { get; set; }

        public int? guidopen { get; set; }

        public int? teamormall { get; set; }

        public string guidlink { get; set; }

        public string likeguidlink { get; set; }

        public string likeguidlinknew { get; set; }
        #endregion
    }
}
