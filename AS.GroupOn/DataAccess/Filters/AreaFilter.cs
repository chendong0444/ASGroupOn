using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class AreaFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Sort_Order_ASC = "sort ASC";
        public const string Sort_Order_DESC = "sort DESC";

        public int? id { get; set; }

        public string areaname { get; set; }

        public int? cityid { get; set; }

        public int? or_in_circle_pid { get; set; }

        public int? circle_id { get; set; }

        public string ename { get; set; }

        public string display { get; set; }

        public string type { get; set; }
    }
}
