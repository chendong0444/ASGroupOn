using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
   public class Feedback:Obj,IFeedback
    {
       /// <summary>
        /// 主键
       /// </summary>
       public virtual int Id { get; set; }
       /// <summary>
       /// 城市ID
       /// </summary>
       public virtual int City_id { get; set; }
       /// <summary>
       /// 用户ID(如果用户没有登录则为0）
       /// </summary>
       public virtual int User_id { get; set; }
       /// <summary>
       /// 意见反馈类型
       /// </summary>
       public virtual string Category { get; set; }
       /// <summary>
       /// 称呼
       /// </summary>
       public virtual string title { get; set; }
       /// <summary>
       /// 联系方式
       /// </summary>
       public virtual string Contact { get; set; }
       /// <summary>
       /// 内容
       /// </summary>
       public virtual string Content { get; set; }
       /// <summary>
       /// 提交时间
       /// </summary>
       public virtual DateTime Create_time { get; set; }

       private IUser _user = null;
       /// <summary>
       /// 返回组对象
       /// </summary>
       public virtual IUser User
       {
           get
           {
               if (_user == null)
               {
                   using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                   {
                       _user = session.Users.GetByID(this.User_id);
                   }
               }
               return _user;
           }
       }
    }
}
