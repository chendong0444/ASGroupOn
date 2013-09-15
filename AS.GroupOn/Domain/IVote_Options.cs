/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public  interface IVote_Options:IObj //调查问题选项表
    {
        //主键Id
        int id { get; set; }

        //问题Id
        int question_id { get; set; }

        //选项名称
        string name { get; set; }

        //是否换行
        int is_br { get; set; }

        //是否有输入框
        int is_input { get; set; }

        //是否显示
        int is_show { get; set; }

        //排序
        int order { get; set; }

    }
}
