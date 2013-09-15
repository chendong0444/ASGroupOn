/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class UserReviewFilter:FilterBase
    {
        public const string ID_ASC = "id ASC";
        public const string ID_DESC = "id DESC";
        public const string Create_Time_ASC = "create_time ASC";
        public const string Create_Time_DESC = "create_time DESC";
        public const string Create_Time_DESC1 = "userreview.create_time DESC";

        public const string t1_desc = "t1.Id DESC";

        public int? id { get; set; }

        public int? admin_id { get; set; }

        public int? user_id { get; set; }

        public int? team_id { get; set; }

        public int? partner_id{ get; set; }

        public int? state { get; set; }

        public string type { get; set; }

        public int? unstate { get; set; }

        public string untype { get; set;  }

        public DateTime? FromCreate_time { get; set; }

        public DateTime? ToCreate_time { get; set; }

        public int? TState { get; set; }

        public int? TState2 { get; set; }

        public int? pidisnull { get; set; }

        public int? teamcata { get; set; }

        public string wheresql { get; set; }
    }
}
