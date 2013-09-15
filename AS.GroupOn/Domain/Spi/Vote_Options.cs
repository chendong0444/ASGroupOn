/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    public class Vote_Options:Obj,IVote_Options
    {


        public int id
        {
            get;
            set;
        }

        public int question_id
        {
            get;
            set;
        }

        public string name
        {
            get;
            set;
        }

        public int is_br
        {
            get;
            set;
        }

        public int is_input
        {
            get;
            set;
        }

        public int is_show
        {
            get;
            set;
        }

        public int order
        {
            get;
            set;
        }
    }
}
