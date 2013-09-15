using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：促销活动
    /// </summary>
    public class Sales_promotionFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string SORT_ASC = "Sort asc";
        public const string SORT_DESC = "Sort desc";


        public int? enable { get; set; }
        public DateTime? Fromstart_time { get; set; }
        public DateTime? Tostart_time { get; set; }


        public DateTime? start_time { get; set; }

        public DateTime? end_time { get; set; }



    }
}
