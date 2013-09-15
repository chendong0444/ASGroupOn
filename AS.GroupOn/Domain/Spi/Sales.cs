using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-11-2
    /// </summary>
   public  class Sales:Obj,ISales
    {
       /// <summary>
       /// 主键
       /// </summary>
       public virtual int id { get; set; }
       /// <summary>
       /// 用户名
       /// </summary>
       public virtual string username { get; set; }
       /// <summary>
       /// 密码
       /// </summary>
       public virtual string password { get; set; }
       /// <summary>
       /// 真实姓名
       /// </summary>
       public virtual string realname { get; set; }
       /// <summary>
       /// 联系电话
       /// </summary>
       public virtual string contact { get; set; }
    }
}
