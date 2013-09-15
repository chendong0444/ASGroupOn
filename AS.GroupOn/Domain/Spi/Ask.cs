using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess;
namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：zjq
    /// 时间：2012-10-24
    /// </summary>
    public class Ask :Obj,IAsk
    {
        /// <summary>
        /// ID号
        /// </summary>
       public virtual int Id { get; set; }
        /// <summary>
        /// 会员ID
        /// </summary>
       public virtual int User_id { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
       public virtual int Team_id { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
       public virtual int City_id { get; set; }
        /// <summary>
        /// 咨询内容
        /// </summary>
       public virtual string Content { get; set; }
        /// <summary>
        /// 回复
        /// </summary>
       public virtual string Comment { get; set; }
        /// <summary>
        /// 咨询时间
        /// </summary>
       public virtual DateTime Create_time { get; set; }

       ////////////////////////////////////////////////
       private IUser user = null;
       /// <summary>
       /// 咨询用户
       /// </summary>
       public virtual IUser User
       {
           get
           {
               if (user == null)
               {
                   using (IDataSession session = App.Store.OpenSession(false))
                   {
                       user= session.Users.GetByID(User_id);
                   }
                   if (user == null) user = AS.GroupOn.Domain.Spi.User.GetDefault();
               }
               return user;
           }
       }
       ////////////////////////////////////////////////
       private ITeam _team = null;
       /// <summary>
       ///项目
       /// </summary>
       public virtual ITeam team
       {
           get
           {
               if (_team == null)
               {
                   using (IDataSession session = App.Store.OpenSession(false))
                   {
                       _team = session.Teams.GetByID(this.Team_id);
                   }
                   if (_team == null) _team = AS.GroupOn.Domain.Spi.Team.GetDefault();
               }
               return _team;
           }
       }
    }
}
