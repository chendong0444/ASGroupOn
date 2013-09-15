/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
   
    public class Vote_FeedbackFilters:FilterBase
    {
        public const string ID_ASC = "id ASC";
        public const string ID_DESC = "id DESC";
        public const string Addtime_ASC = "Addtime ASC";
        public const string Addtime_DESC = "Addtime DESC";


        public int? ID { get; set; }

        public int? User_ID { get; set; }

        public string Username { get; set; }

        public string IP { get; set; }

        public DateTime? Fromadd_time { get; set; }

        public DateTime? Toadd_time { get; set; }

    }
}
