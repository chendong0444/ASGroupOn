using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class PayFilter : FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Create_time_ASC = "Create_time asc";
        public const string Create_time_DESC = "Create_time desc";

        public string Order_id { get; set; }
        public string Id { get; set; }
        public string Bank { get; set; }
    }
}
