using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建时间 2012-10-24、
    /// 创建人   zlj
    /// </summary>
   public class MailerFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        
        public string Id {get;set;}

        public string Email { get; set; }

        public string Secret { get; set; }

        public string sendmailids { get; set; }

        public int? City_id { get; set; }

        public string City_ids { get; set; }

        public int? cityid { get; set; }
    }
}
