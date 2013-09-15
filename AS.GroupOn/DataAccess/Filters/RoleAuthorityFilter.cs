using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
   public class RoleAuthorityFilter:FilterBase
    {
        public const string ID_ASC = "ID asc";
        public const string ID_DESC = "ID desc";
     /// <summary>
     /// 角色id
     /// </summary>
        public int? RoleID { get; set; }

       /// <summary>
       /// 权限id
       /// </summary>
        public int? AuthorityID { get; set; }
    }
}
