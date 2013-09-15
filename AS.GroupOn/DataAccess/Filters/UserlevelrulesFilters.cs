/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public  class UserlevelrulesFilters:FilterBase
    {
        public const string ID_ASC = "id ASC";
        public const string ID_DESC = "id DESC";
        public const string MAXMONEY_ASC = "maxmoney ASC";
        public const string MAXMONEY_DESC = "maxmoney DESC";
        public const string MINMONEY_DESC = "minmoney DESC";

        public int? id { get; set; }
        public int? levelid { get; set; }
        public decimal? maxmoney { get; set; }
        public decimal? minmoney { get; set; }
        public double? discount { get; set; }
        public decimal? totalamount { get; set; }

    }
}
