using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class CategoryFilter:FilterBase
    {
        public const string ID_ASC = "Id asc";
        public const string ID_DESC = "Id desc";
        public const string Sort_Order_ASC = "Sort_order ASC";
        public const string Sort_Order_DESC = "Sort_order DESC";
        public const string Letter_ASC = "Letter ASC";

        public int? Id { get; set; }

        public string Zone { get; set; }

        public string Name { get; set; }

        public string Ename { get; set; }

        public string orEname { get; set; }

        public string Letter { get; set; }

        public string Display { get; set; }

        public int? City_pid { get; set; }

        public string Czone { get; set; }

        public int? Sort_order { get; set; }

        public string NameLike { get; set; }

        public string Where { get; set; }
    }
}
