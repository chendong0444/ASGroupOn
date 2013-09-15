using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class NewsFilter : FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string CreateTime_ASC = "create_time ASC";
        public const string CreateTime_DESC = "create_time DESC";

        public int? id { get; set; }

        public DateTime? FromCreate_time { get; set; }

        public DateTime? ToCreate_time { get; set; }

        public int? type { get; set; }
    }
}
