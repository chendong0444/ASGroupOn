using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public class DrawFilter:FilterBase
    {
        public const string ID_ASC = "Id asc";
        public const string ID_DESC = "Id desc";
        public const string CREATETIME_ASC = "createtime asc";
        public const string CREATETIME_DESC = "createtime desc";
        public const string TeamID_DESC = "teamid desc";
        public int? id { get; set; }
        public int? userid { get; set; }
        public DateTime? createtime { get; set; }
        public int? teamid { get; set; }
        public int? orderid { get; set; }
        public string state { get; set; }
        public string number { get; set; }
        public DateTime? FromCreateTime { get; set; }
        public DateTime? ToCreateTime { get; set; }
        public string table { get; set; }
    }
}
