using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    public class RoleAuthority : Obj, IRoleAuthority
    {
        /// <summary>
        /// 主键
        /// </summary>
       public virtual int ID { get; set; }
        /// <summary>
        ///角色id
        /// </summary>
       public virtual int RoleID { get; set; }
        /// <summary>
        ///操作id
        /// </summary>
       public virtual int AuthorityID { get; set; }

       private IRole _role = null;
       /// <summary>
       /// 返回组对象
       /// </summary>
       public virtual IRole Role
       {
           get
           {
               if (_role == null)
               {
                   using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                   {
                       _role = session.Role.GetByID(this.RoleID);
                   }
               }
               return _role;
           }
       }


       private IAuthority _authority = null;
       public virtual IAuthority Authority
       {
           get
           {
               if (_authority == null)
               {
                   using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                   {
                       _authority = session.Authority.GetByID(this.AuthorityID);
                   }
               }
               return _authority;
           }
       }
    }
}
