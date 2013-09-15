using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class PacketFilter : FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Send_time_ASC = "Send_Time ASC";
        public const string Send_time_DESC = "Send_Time DESC";
        public const string Get_time_ASC = "Get_Time ASC";
        public const string Get_time_DESC = "Get_Time DESC";

        public int? Id { get; set; }
        public int? User_id { get; set; }
        public string State { get; set; }
        public DateTime Send_Time { get; set; }
        public DateTime? Get_Time { get; set; }
        public int Admin_Id { get; set; }
        public DateTime? FromSend_time { get; set; }
        public DateTime? ToSend_time { get; set; }
        public DateTime? FromGet_time { get; set; }
        public DateTime? ToGet_time { get; set; }


    }
}
