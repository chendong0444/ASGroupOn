using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface IRoleAuthority : IObj
    {
        /// <summary>
        /// 主键
        /// </summary>
        int ID { get; }
        /// <summary>
        ///角色id
        /// </summary>
        int RoleID { get; set; }
        /// <summary>
        ///操作id
        /// </summary>
        int AuthorityID { get; set; }

        IRole Role{get;}

        IAuthority Authority { get; }
      
    }
}
