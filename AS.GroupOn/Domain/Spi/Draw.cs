using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
   public class Draw:Obj,IDraw
    {
       /// <summary>
       /// 主键
       /// </summary>
       public virtual int id { get; set; }
       /// <summary>
       /// 得奖主用户ID
       /// </summary>
       public virtual int userid { get; set; }
       /// <summary>
       /// 创建时间
       /// </summary>
       public virtual DateTime createtime { get; set; }
       /// <summary>
       /// 抽奖号码
       /// </summary>
       public virtual string number { get; set; }
       /// <summary>
       /// 项目ID
       /// </summary>
       public virtual int teamid { get; set; }
       /// <summary>
       /// 订单ID
       /// </summary>
       public virtual int orderid { get; set; }
       /// <summary>
       /// 邀请人ID
       /// </summary>
       public virtual int inviteid { get; set; }
       /// <summary>
       /// 邀请状态Y代表已中奖 N代表未中奖
       /// </summary>
       public virtual string state { get; set; }

       private IUser user = null;

       public virtual IUser User
       {

           get
           {
               using (IDataSession session = App.Store.OpenSession(false))
               {
                   user = session.Users.GetByID(this.userid);
               }
               return user;
           }
       }
       public virtual int sum { get; set; }
    }
}
