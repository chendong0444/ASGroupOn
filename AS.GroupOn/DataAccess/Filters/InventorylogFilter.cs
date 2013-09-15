using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public class InventorylogFilter:FilterBase
    {
        #region InventorylogFilter成员

        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";

        public const string Orderid_ASC = "orderid asc";
        public const string Orderid_DESC = "orderid desc";

        public const string adminid_ASC = "adminid asc";
        public const string adminid_DESC = "adminid desc";

        public const string create_time_ASC = "create_time asc";
        public const string create_time_DESC = " create_time desc";

        public const string teamid_ASC = "teamid asc";
        public const string teamid_DESC = "teamid desc";

        /// <summary>
        /// ID号
        /// </summary>
        public int? Id { get; set; }
        /// <summary>
        /// 订单号
        /// </summary>
        public int? orderid { get; set; }
        /// <summary>
        /// 管理员编号
        /// </summary>
        public int? adminid { get; set; }
       
        public DateTime? From_Createtime { get; set; }

        public DateTime? To_Createtime { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
        public int? teamid { get; set; }
        #endregion
    }
}
