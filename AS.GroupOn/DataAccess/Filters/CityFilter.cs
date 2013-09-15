using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
   public class CityFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Sort_Order_ASC = "Sort_Order ASC";
        public const string Sort_Order_DESC = "Sort_Order DESC";

        public int? ID { get; set; }

        public string Ename { get; set; }

        public string Display { get; set; }

        public string Letter { get; set; }

        public string Name { get; set; }

        public int? City_pid { get; set; }

        public string Zone
        {
            get
            {
                return "city";
            }
        }

    }
}
