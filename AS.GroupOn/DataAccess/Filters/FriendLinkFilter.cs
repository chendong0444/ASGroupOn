using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public class FriendLinkFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Sort_Order_ASC = "Sort_Order ASC";
        public const string Sort_Order_DESC = "Sort_Order DESC";

        public bool? Logo { get; set; }
    }
}
