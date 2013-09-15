using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：短信订阅
    /// </summary>
    public class SmssubscribeFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";

        public string Mobile { get; set; }

        public string Enable { get; set; }  //激活状态 Y or N

        public int? City_id { get; set; }
    }
}
