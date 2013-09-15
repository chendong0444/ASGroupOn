using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class AuthorFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Sort_Order_ASC = "Sort_Order ASC";
        public const string Sort_Order_DESC = "Sort_Order DESC";

        //public int? ID { get; set; }

       
        public int? IDS { get; set; }

    }

}
