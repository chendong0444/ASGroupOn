using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class SmsLogFilter : FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string SENDTIME_ASC = "sendTime asc";
        public const string SENDTIME_DESC = "sendTime desc";
        /// <summary>
        /// 编号
        /// </summary>
        public int? Id { get; set; }

        public string Mobiles { get; set; }

        public DateTime? SendTime { get; set; }
        public DateTime? StartSendTime { get; set; }
        public DateTime? EndSendTime { get; set; }

        public int? Points { get; set; }

        /// <summary>
        /// 短信内容
        /// </summary>
        public string Content { get; set; }

    }
}
