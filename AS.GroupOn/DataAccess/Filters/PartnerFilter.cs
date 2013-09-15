using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
namespace AS.GroupOn.DataAccess.Filters
{
    public class PartnerFilter : FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string CreateTime_ASC = "Create_time ASC";
        public const string CreateTime_DESC = "Create_time DESC";
        public const string Head_ASC = "Head ASC";
        public const string Head_DESC = "Head DESC";

        public int? Id { get; set; }

        public string par_Id { get; set; }

        public string Username { get; set; }

        public string Password { get; set; }

        public int? Group_id { get; set; }

        public int? City_id { get; set; }

        public string Open { get; set; }

        public string Enable { get; set; }

        public DateTime? FromCreate_time { get; set; }

        public DateTime? ToCreate_time { get; set; }

        public int? sale_id { get; set; }

        public string Title { get; set; }

        public string Titlelike { get; set; }

        public string Titles { get; set; }

        public string saleid { get; set; }

        public string Contact { get; set; }

        public int? NotId { get; set; }

        public string table { get; set; }

        public string Image1 { get; set; }

        public string Image2 { get; set; }

        public int? ParentId { get; set; }
    }
}
