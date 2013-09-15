using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：退款
    /// </summary>
    public class RefundsFilter : FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";

        public int? Id { get; set; }
        public int? Order_Id { get; set; }

        public int? State { get; set; }  //状态字段 1客服申请 2商户审核通过 4等待财务接受 8财务接受 16财务处理完毕

        public int? PartnerID { get; set; }

        public string Reason { get; set; }

        public int? AdminID { get; set; }
        public int? inorder_id { get; set; }
        public DateTime? FromCreate_time { get; set; }  //退款时间
        public DateTime? ToCreate_time { get; set; }
    }
}
