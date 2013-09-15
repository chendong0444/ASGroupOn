using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
  public  interface ISmstemplate:IObj
    {
      /// <summary>
      /// 短信模版名称
      /// </summary>
      string name { get; set; }

      /// <summary>
      /// 短信模版内容
      /// </summary>
      string value { get; set; }

    }
}
