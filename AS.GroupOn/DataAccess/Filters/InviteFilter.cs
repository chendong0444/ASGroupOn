using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class InviteFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Create_time_ASC = "Create_time asc";
        public const string Create_time_DESC = "Create_time desc";
        public const string Buy_time_ASC = "Buy_time asc";
        public const string Buy_time_DESC = "Buy_time desc";
        public const string Num_ASC = "num asc";
        public const string Num_DESC = "num desc";


        public int? Id { get; set; }
        /// <summary>
        /// 邀请人ID
        /// </summary>
        public int? User_id { get; set; }
        /// <summary>
        /// 被邀请人购买状态N 未购买Y 已购买C 违规P 已返利
        /// </summary>
        public string Pay { get; set; }

        public DateTime? Buy_time { get; set; }
        /// <summary>
        /// 被邀请人ID
        /// </summary>
        public int? Other_user_id { get; set; }

        /// <summary>
        /// 金额
        /// </summary>
        public int? Credit { get; set; }

        /// <summary>
        /// 金额>*
        /// </summary>
        public int? FromCredit { get; set; }

        public int? Team_id { get; set; }

        public DateTime? FromCreate_time { get; set; }

        public DateTime? ToCreate_time { get; set; }

        public string Username { get; set; }
        public string Mobile { get; set; }
        public string email { get; set; }
        public string Name { get; set; }
        public string Ip_Address { get; set; }

        public int? TeamidNotZero { get; set; }

        public DateTime? FromBuy_time { get; set; }

        public DateTime? ToBuy_time { get; set; }
    }
}
