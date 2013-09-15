using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public class MailtasksFilter:FilterBase 
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Cityid_ASC = "cityid asc";
        public const string Cityid_Desc = "cityid desc";

        /// <summary>
        /// ID号
        /// </summary>
        public int? id { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
        public string cityid { get; set; }

        public int? state { get; set; }

    }
}
