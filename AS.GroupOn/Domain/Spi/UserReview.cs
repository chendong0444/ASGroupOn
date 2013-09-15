/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
namespace AS.GroupOn.Domain.Spi
{
   public class UserReview:Obj,IUserReview
    {
       public int id
       {
           get;
           set;
       }

       public int user_id
       {
           get;
           set;
       }

       public int team_id
       {
           get;
           set;
       }

       public DateTime create_time
       {
           get;
           set;
       }

       public string comment
       {
           get;
           set;
       }

       public int score
       {
           get;
           set;
       }

       public DateTime? rebate_time
       {
           get;
           set;
       }

       public decimal rebate_price
       {
           get;
           set;
       }

       public int state
       {
           get;
           set;
       }

       public int admin_id
       {
           get;
           set;
       }

       public int? isgo
       {
           get;
           set;
       }

       public int? partner_id
       {
           get;
           set;
       }

       public string type
       {
           get;
           set;
       }
       //Team表关联
       private ITeam _team = null;
       /// <summary>
       /// 返回team
       /// </summary>
       public virtual ITeam team
       {
           get
           {
               if (_team == null)
               {
                   using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                   {
                       _team = session.Teams.GetByID(this.team_id);
                   }
               }
               return _team;
           }
       }

       //User表关联
       private IUser _user = null;
       /// <summary>
       /// 返回User
       /// </summary>
       public virtual IUser user
       {
           get
           {
               if (_user == null)
               {
                   using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                   {
                       _user = session.Users.GetByID(this.user_id);
                   }

               }
                 return _user; 
           }
       }


       //User表关联
       private IUser _aduser = null;
       /// <summary>
       /// 返回User
       /// </summary>
       public virtual IUser aduser
       {
           get
           {
               if (_aduser == null)
               {
                   using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                   {
                       _aduser = session.Users.GetByID(this.admin_id);
                   }

               }
               return _aduser;
           }
       }


       //partner表关联
       private IPartner _partner = null;
       /// <summary>
       /// 返回partner
       /// </summary>
       public virtual IPartner partner
       {
           get
           {
               if (_partner == null)
               {
                   using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                   {

                       if (this.partner_id.HasValue)
                       {
                           _partner = session.Partners.GetByID(this.partner_id.Value);
                       }
                   }
               }
               return _partner;
           }
       }


       public virtual int? review_teamid { get; set; }
       public virtual string username { get; set; }
       public virtual string Title { get; set; }
       public virtual string Image { get; set; }
       public virtual decimal? totalamount { get; set; }


    }
}
