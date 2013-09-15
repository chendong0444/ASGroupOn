/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
   public class YizhantongFilters:FilterBase
    {
        public const string ID_ASC = "id ASC";
        public const string ID_DESC = "id DESC";

        public int? User_ID { get; set; }
        public string Name { get; set; }
        public string SafeKey { get; set; }

    }
}
