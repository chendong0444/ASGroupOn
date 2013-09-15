using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
   public  class Template_print:Obj,ITemplate_print
    {
       /// <summary>
       /// 快递模版id号
       /// </summary>
       public virtual int id { get; set; }
       /// <summary>
       ///快递模版名称 
       /// </summary>
       public virtual string template_name { get; set; }
       /// <summary>
       /// 快递模版数据
       /// </summary>
       public virtual string template_value { get; set; }

    }
}
