using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
  public  class SubscribeFilter:FilterBase
    {

      /// <summary>
      /// 邮箱
      /// </summary>
      public string Email { get; set; }
      /// <summary>
      /// 城市id      
      /// </summary>
      public int City_id { get; set; }
      /// <summary>
      /// 验证码
      /// </summary>
      public string Secret { get; set; }

    }
}
