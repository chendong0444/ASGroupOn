/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public   class Vote_QuestionFilters:FilterBase
    {
        public const string ID_ASC = "id ASC";
        public const string ID_DESC = "id DESC";
        public const string AddTime_DESC = " addtime DESC";
        public const string AddTime_ASC = " addtime ASC ";
        public const string Order_DESC = " [order] DESC";
        public const string Order_ASC = " [order] ASC ";

        public string Title { get; set; }
        public string Type { get; set; }
        public int? IsShow { get; set; }
    }
}
