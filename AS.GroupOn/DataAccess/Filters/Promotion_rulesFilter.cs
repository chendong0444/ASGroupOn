using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：促销活动规则
    /// </summary>
    public class Promotion_rulesFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string SORT_ASC = "sort asc";
        public const string SORT_DESC = "sort desc"; 

        public int? enable { get; set; }
        public int? activtyid { get; set; }

        public DateTime? Fromend_time { get; set; }
        public DateTime? Tostart_time { get; set; }
        public decimal? Tofull_money { get; set; }

    }
}
