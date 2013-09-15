using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
   public  class Smssubscribedetail:Obj,ISmssubscribedetail
    {

       /// <summary>
       /// ID号
       /// </summary>
       public virtual int id { get; set; }

       /// <summary>
       /// 项目ID
       /// </summary>
       public virtual int teamid { get; set; }
       
       /// <summary>
       /// 订阅手机
       /// </summary>
       
       public virtual string mobile { get; set; }
       
       /// <summary>
       /// 发送时间
       /// </summary>
       public virtual int sendtime { get; set; }
       

       /// <summary>
       /// 是否已发送
       /// </summary>
       public virtual int issend { get; set; }

   
    }
}
