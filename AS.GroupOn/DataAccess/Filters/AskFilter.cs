using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
   public class AskFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Sort_Order_ASC = "Sort_Order ASC";
        public const string Sort_Order_DESC = "Sort_Order DESC";

        public const string Create_Time_ASC = "Create_time ASC";
        public const string Create_Time_DESC = "Create_time DESC";

        public int? User_id { get; set; }

        public int? Team_ID { get; set; }

        public int? City_ID { get; set; }

       /// <summary>
       /// 是否已回复
       /// </summary>
        public bool? IsComment { get; set; }
       /// <summary>
       /// 返回已回复或者自己发布的
       /// </summary>
        public int? CommentAndMy { get; set; }

      
        public DateTime? FromCreate_time { get; set; }

        public DateTime? ToCreate_time { get; set; }

    }
}
