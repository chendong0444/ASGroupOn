/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface IVote_Feedback:IObj //调查参与人员信息
    {
        //调查人Id
        int id { get; set; }

        //用户名
        string Username { get; set; }

        //会员Id
        int User_id { get; set; }

        //会员IP
        string Ip { get; set; }

        //提交时间
        DateTime Addtime { get; set; }

    }
}
