using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public class FeedbackFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";

        public const string CREATE_TIME_ASC="Create_time asc";
        public const string CREATE_TIEM_DESC="Create_time desc";

        public int? Id { get; set; }
        public int? City_id { get; set; }
        public int? User_id { get; set; }
        public string Category { get; set; }
        public string Content { get; set; }
    }
}
