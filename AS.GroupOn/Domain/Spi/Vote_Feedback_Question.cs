/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    public  class Vote_Feedback_Question:Obj,IVote_Feedback_Question
    {


        public int id
        {
            get;
            set;
        }

        public int feedback_id
        {
            get;
            set;
        }

        public int question_id
        {
            get;
            set;
        }

        public int options_id
        {
            get;
            set;
        }
    }
}
