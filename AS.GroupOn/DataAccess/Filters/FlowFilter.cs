using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
   public class FlowFilter:FilterBase
    {
       
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Create_time_ASC = "Create_time asc";
        public const string Create_time_DESC = "Create_time desc";


        public int? Id { get; set; }

        public int? User_id { get; set; }
        public int? Admin_id { get; set; }

        public string Direction { get; set; }
        public string Action { get; set; }
        public string Detail_id { get; set; }
        public string Detail { get; set; }
        public decimal Money { get; set; }

        public DateTime? FromCreateTime { get; set; }
        public DateTime? ToCreateTime { get; set; }
        public DateTime? Create_time { get; set; }


    }
}
