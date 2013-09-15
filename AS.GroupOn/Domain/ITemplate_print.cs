using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
   public   interface ITemplate_print:IObj
    {
       /// <summary>
       /// id号
       /// </summary>
       int id { get; set; }
       /// <summary>
       /// 快递模版名称
       /// </summary>
       string template_name { get; set; }
       /// <summary>
       /// 快递模版数据
       /// </summary>
       string template_value { get; set; }

    }
}
