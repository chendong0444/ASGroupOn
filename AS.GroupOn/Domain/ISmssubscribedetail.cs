using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
  public interface  ISmssubscribedetail:IObj
    {
      /// <summary>
      /// ID号
      /// </summary>
      int id { get; set; }

      /// <summary>
      /// 项目ID
      /// </summary>
      int teamid { get; set; }

      /// <summary>
      /// 订阅手机
      /// </summary>
      string mobile { get; set; }

      /// <summary>
      /// 发送时间
      /// </summary>
      int sendtime { get; set; }

      /// <summary>
      /// 是否已发送
      /// </summary>
      int issend { get; set; }

    }
}
