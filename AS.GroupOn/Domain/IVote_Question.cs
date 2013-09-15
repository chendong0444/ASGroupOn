/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface IVote_Question:IObj    //调查问卷问题
    {
        //主键Id
        int id { get; set; }

        //问题名称
        string Title { get; set; }

        //问题类型
        string Type { get; set; }

        //是否显示
        int is_show { get; set; }

        //添加时间
        DateTime Addtime { get; set; }

        //排序
        int order { get; set; }

    }
}
