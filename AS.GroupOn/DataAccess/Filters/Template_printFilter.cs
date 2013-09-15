using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
   public class Template_printFilter:FilterBase
    {

        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";

       /// <summary>
       /// 快递公司模版ID
       /// </summary>
       public int id { get; set;}
       /// <summary>
       /// 快递公司模版名称
       /// </summary>
       public string template_name { get; set; }
       
       /// <summary>
       /// 快递公司模版内容
       /// </summary>
       public string template_value { get; set; }


    }
}
