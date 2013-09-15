using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 修改者：zjq 
    /// 2012-10-24
    /// </summary>
    public class Card:Obj,ICard
    {
        /// <summary>
        /// 券号
        /// </summary>
       public virtual string Id { get; set; }
        /// <summary>
        /// 行动代号
        /// </summary>
       public virtual string Code { get; set; }
        /// <summary>
        /// 商户ID
        /// </summary>
       public virtual int Partner_id { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
       public virtual int Team_id { get; set; }

        /// <summary>
        /// 订单ID
        /// </summary>
       public virtual int Order_id { get; set; }
       /// <summary>
       /// in Order_id
       /// </summary>
       public virtual int inOrder_id { get; set; }
        /// <summary>
        /// 可待金额
        /// </summary>
       public virtual int Credit { get; set; }
        /// <summary>
        /// 使用状态N 未使用 Y已使用
        /// </summary>
       public virtual string consume { get; set; }
        /// <summary>
        /// 使用者IP
        /// </summary>
       public virtual string Ip { get; set; }
        /// <summary>
        /// 开始时间
        /// </summary>
       public virtual DateTime Begin_time { get; set; }
        /// <summary>
        /// 结束时间
        /// </summary>
       public virtual DateTime End_time { get; set; }
        /// <summary>
        /// 使用者会员ID
        /// </summary>
       public virtual int user_id { get; set; }

       /// <summary>
       /// 是否领取
       /// </summary>
       public virtual int isGet { get; set; }

       /// <summary>
       /// 代金券状态 未使用 已使用 已过期
       /// </summary>
       public virtual string State
       {
           get
           {
               if (consume == "Y")
                   return "已使用";
               if (End_time < DateTime.Now)
                   return "已过期";
               return "未使用";
           }
       }

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
                       _user = session.Users.GetByID(this.user_id);
                   }
               }
               return _user;
           }
       }

       private IPartner _partner = null;
       /// <summary>
       /// 返回组对象
       /// </summary>
       public virtual IPartner Partner
       {
           get
           {
               if (_partner == null)
               {
                   using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                   {
                       _partner = session.Partners.GetByID(this.Partner_id);
                   }
               }
               return _partner;
           }
       }

       private ITeam _team = null;
       /// <summary>
       /// 返回组对象
       /// </summary>
       public virtual ITeam Team
       {
           get
           {
               if (_team == null)
               {
                   using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                   {
                       _team = session.Teams.GetByID(this.Team_id);
                   }
               }
               return _team;
           }
       }

       private IOrder _order = null;
       /// <summary>
       /// 返回组对象
       /// </summary>
       public virtual IOrder Order
       {
           get
           {
               if (_order == null)
               {
                   using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                   {
                       _order = session.Orders.GetByID(this.Order_id);
                   }
               }
               return _order;
           }
       }

       private ICategory _category = null;
       /// <summary>
       /// 返回组对象
       /// </summary>
       public virtual ICategory Category
       {
           get
           {
               if (_category == null)
               {
                   using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                   {
                       _category = session.Category.GetByID(this.uCity_id);
                   }
               }
               return _category;
           }
       }

       public virtual int uId { get; set; }
       public virtual string uEmail { get; set; }
       public virtual string uUserName { get; set; }
       public virtual string uRealname { get; set; }
       public virtual int uCity_id { get; set; }
       public virtual decimal uMoney { get; set; }
       public virtual decimal uTotalamount { get; set; }
       public virtual string uZipcode { get; set; }
       public virtual DateTime uCreate_time { get; set; }
       public virtual string uMobile { get; set; }
       public virtual int oCount { get; set; } 
    }
}
