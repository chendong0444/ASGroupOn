using System;
using System.Collections.Generic;
using System.Text;


namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public class MailserverFilter:FilterBase 
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";

        public const string sendcount_ASC = "sendcount asc";
        public const string sendcount_DESC = "sendcount desc";

        /// <summary>
        /// id号
        /// </summary>
        public int? id { get; set; }
        /// <summary>
        /// 一次最多发送数量
        /// </summary>
        public int? sendcount { get; set; }

    }
}
