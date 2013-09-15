using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
  public class Smstemplate:Obj,ISmstemplate
    {
      /// <summary>
      /// 短信模版名称
      /// </summary>
      public virtual string name { get; set; }

      /// <summary>
      /// 短信模版内容
      /// </summary>
      public virtual string value { get; set; }


    }
}
