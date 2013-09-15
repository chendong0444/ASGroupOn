using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class BranchFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";

        public int? id { get; set; }

        public int? partnerid { get; set; }
        
        public string branchname { get; set; }

        public string contact { get; set; }

        public string phone { get; set; }

        public string mobile { get; set; }

        public string point { get; set; }

        public string username { get; set; }

        public string userpwd { get; set; }

        public string table { get; set; }
    }
}
