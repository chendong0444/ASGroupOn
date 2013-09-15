using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
  public  interface ISubscribe:IObj
    {

      /// <summary>
      /// ID号
      /// </summary>
      int Id { get; set; }
      /// <summary>
      /// 邮箱
      /// </summary>
      string email { get; set; }
      /// <summary>
      /// 城市id
      /// </summary>
      int City_id { get; set; }
      /// <summary>
      /// 验证码
      /// </summary>
      string Secret { get; set; }

    }
}
