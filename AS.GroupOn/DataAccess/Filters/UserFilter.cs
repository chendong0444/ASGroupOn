using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
namespace AS.GroupOn.DataAccess.Filters
{
    public class UserFilter : FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string CreateTime_ASC = "CreateTime ASC";
        public const string CreateTime_DESC = "CreateTime DESC";


        public int? ID { get; set; }


        public string Email { get; set; }

        public string Username { get; set; }

        public string Realname { get; set; }

        public string Mobile { get; set; }

        public string Signmobile { get; set; }

        public string City_id { get; set; }

        public string City_ids { get; set; }

        public string Password { get; set; }

        public string LoginName { get; set; }

        public string Manager { get; set; }

       public string IsManBranch { get; set; }

        public string Enable { get; set; }

        public string Enables { get; set; }

        public string Newbie { get; set; }

        public string Newbies { get; set; }

        public string Genders { get; set; }

        public string Fromdomain { get; set; }

        public int? userscore { get; set; }

        public decimal? Money { get; set; }

        public decimal? totalamount { get; set; }

        public string ucsyc { get; set; }

        public string Recode { get; set; }
        public DateTime? FromCreate_time { get; set; }

        public DateTime? ToCreate_time { get; set; }

        //用户等级筛选
        public decimal? fromtotalamount{ get; set; }
        public decimal? tototalamount{ get; set; }

        public int? IDNotEqual { get; set; }

    }
}
