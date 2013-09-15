/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class Vote_Feedback_QuestionFilters:FilterBase
    {
        public const string ID_ASC = "id ASC";
        public const string ID_DESC = "id DESC";

        public int? Feedback_ID { get; set; }
        public int? Options_ID { get; set; }
        public int? Question_ID { get; set; }
    }
}
