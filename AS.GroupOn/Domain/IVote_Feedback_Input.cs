/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public  interface IVote_Feedback_Input:IObj //参与调查的用户提交的文本信息
    {
        //主键ID
        int id { get; set; }

        //参与调查人员的ＩＤ
        int feedback_id { get; set; }

        //调查项目Id
        int options_id { get; set; }

        //参与调查人员回答的信息
        string value { get; set; }

    }
}
