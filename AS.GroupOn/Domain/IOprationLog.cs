using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
   public interface IOprationLog:IObj
    {
       /// <summary>
       /// id
       /// </summary>
       int id { get; set; }
       /// <summary>
       /// 操作管理员id
       /// </summary>
       int adminid { get; set; }
       /// <summary>
       /// 日志类型  如：删除线下充值记录、删除在线充值记录
       /// </summary>
       string type { get; set; }
       /// <summary>
       /// 日志内容
       /// </summary>
       string logcontent { get; set; }
       /// <summary>
       /// 操作时间
       /// </summary>
       DateTime createtime { get; set; }

       IUser User { get; }
    }
}
