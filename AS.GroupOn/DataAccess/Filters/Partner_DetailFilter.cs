using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class Partner_DetailFilter : FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Create_time_ASC = "Createtime ASC";
        public const string Create_time_DESC = "Createtime DESC";

        public int? id { get; set; }

        public int? partnerid { get; set; }

        public DateTime? FromCreate_time { get; set; }

        public DateTime? ToCreate_time { get; set; }

        public int? settlementstate { get; set; }

        /// <summary>
        /// 项目ID
        /// </summary>
        public int? team_id { get; set; }

        public int? Parid { get; set; }


    }
}
