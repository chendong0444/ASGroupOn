using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Events
{
   public class EventResult
    {
       /// <summary>
       /// 执行结果:成功or 失败
       /// </summary>
       public bool Result { get; set; }
       /// <summary>
       /// 结果消息
       /// </summary>
       public string Message { get; set; }

       /// <summary>
       /// 返回结果中附带的对象
       /// </summary>
       public object Object { get; set; } 
    }
   /// <summary>
   /// 直接重定向到指定的地址
   /// </summary>
   public class ResponseEventResult : EventResult
   {
       string Url { get; set; }
   }
    /// <summary>
    /// 返回json格式的结果
    /// </summary>
   public class JsonEventResult : EventResult
   {
       string Json { get; set; }
   }


}

