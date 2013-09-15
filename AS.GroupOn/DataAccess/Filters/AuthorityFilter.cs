using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
   public class AuthorityFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";

        public int? ID { get; set; }
        public string AuthorityName { get; set; }


        
    }
}
