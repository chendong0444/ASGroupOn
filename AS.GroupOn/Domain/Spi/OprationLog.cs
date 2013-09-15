using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess;


namespace AS.GroupOn.Domain.Spi
{
  public class OprationLog:Obj,IOprationLog
    {
      /// <summary>
        /// id
      /// </summary>
      public virtual int id { get; set; }
      /// <summary>
      ///  操作管理员id
      /// </summary>
      public virtual int adminid { get; set; }
      /// <summary>
      /// 日志类型  如：删除线下充值记录、删除在线充值记录
      /// </summary>
      public virtual string type { get; set; }
      /// <summary>
      /// 日志内容
      /// </summary>
      public virtual string logcontent { get; set; }
      /// <summary>
      /// 操作时间
      /// </summary>
      public virtual DateTime createtime { get; set; }

      IUser _user = null;
      public virtual IUser User
      {
          get
          {
              if (_user == null)
              {
                  using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                  {
                      _user = session.Users.GetByID(this.adminid);
                  }
                  if (_user == null)
                      _user = AS.GroupOn.Domain.Spi.User.GetDefault();
              }
              return _user;
          }
      }
    }
}
