/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class Vote_OptionsFilters:FilterBase
    {
        public const string ID_ASC = "id ASC";
        public const string ID_DESC = "id DESC";
        public const string Order_DESC = " [order] DESC";
        public const string Order_ASC = " [order] ASC ";

        public int? Question_ID { get; set; }
        public string Name { get; set; }
        public int?is_show { get; set; }

    }
}
