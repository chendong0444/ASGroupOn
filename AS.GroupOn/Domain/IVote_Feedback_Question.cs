/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public  interface IVote_Feedback_Question:IObj //调查问卷人员回答的问题
    {
        //主键ID
        int id { get; set; }

        //参与调查的人员的Id
        int feedback_id { get; set; }

        //问题Id
        int question_id { get; set; }

        //问题选项Id
        int options_id { get; set; }

    }
}
