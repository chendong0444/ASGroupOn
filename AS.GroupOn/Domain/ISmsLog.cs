using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
  public  interface ISmsLog:IObj
    {
      /// <summary>
      /// 编号
      /// </summary>
      int Id { get; set; }

      string Mobiles { get; set; }

      DateTime SendTime { get; set; }

      int Points { get; set; }

      /// <summary>
      /// 短信内容
      /// </summary>
      string Content { get; set; }

    }
}
