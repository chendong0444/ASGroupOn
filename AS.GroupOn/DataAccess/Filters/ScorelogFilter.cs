using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：积分消费记录
    /// </summary>
    public class ScorelogFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";

        public const string Create_time_ASC = "create_time asc";
        public const string Create_time_DESC = "create_time desc";

        public int? Score { get; set; } //积分值 正为收入 负为花费

        public string Action { get; set; }  //行为：'下单','退单','积分兑换','取消兑换','签到'

        public string Key { get; set; }  //关联ID (订单ID)

        public int? User_id { get; set; }

        public DateTime? FromCreate_time { get; set; }  //生成时间
        public DateTime? ToCreate_time { get; set; }
    }
}
