/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
   public class Vote_Feedback:Obj,IVote_Feedback
    {
        public virtual int id { get; set; }

        public virtual string Username { get; set; }

        public virtual int User_id { get; set; }

        public virtual string Ip { get; set; }

        public virtual DateTime Addtime { get; set; }
    }
}
