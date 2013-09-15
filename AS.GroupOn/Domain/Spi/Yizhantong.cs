/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    public  class Yizhantong :Obj,IYizhantong
    {

        public int id
        {
            get;
            set;
        }

        public int userid
        {
            get;
            set;
        }

        public string name
        {
            get;
            set;
        }

        public string safekey
        {
            get;
            set;
        }
    }
}
