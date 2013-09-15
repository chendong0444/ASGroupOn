/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public  interface IYizhantong:IObj //一站通
    {
        //主键Id
        int id { get; set; }

        //用户Id
        int userid { get; set; }

        //一站通用户标识
        string name { get; set; }

        //安全码
        string  safekey { get; set; }

    }
}
