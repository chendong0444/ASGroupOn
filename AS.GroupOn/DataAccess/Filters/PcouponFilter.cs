using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：站外优惠劵
    /// </summary>
    public class PcouponFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string CREATE_TIME_ASC = "Create_time asc";
        public const string CREATE_TIME_DESC = "Create_time desc";

        public int? id { get; set; }

        public int? userid { get; set; }

        public int? teamid { get; set; }

        public int? partnerid { get; set; }

        public int? inOrderid { get; set; }
        /// <summary>
        /// 订单号
        /// </summary>
        public int? orderid { get; set; }
        /// <summary>
        /// 优惠劵号
        /// </summary>
        public string number { get; set; }

        public string state { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        public DateTime? FromCreate_time { get; set; }
        public DateTime? ToCreate_time { get; set; }
        /// <summary>
        /// 购买时间
        /// </summary>
        public DateTime? FromBuy_time { get; set; }
        public DateTime? ToBuy_time { get; set; }
        /// <summary>
        /// 优惠券开始时间
        /// </summary>
        public DateTime? FromStart_time { get; set; }
        public DateTime? ToStart_time { get; set; }
        /// <summary>
        /// 优惠券结束时间
        /// </summary>
        public DateTime? FromExpire_time { get; set; }
        public DateTime? ToExpire_time { get; set; }

        public string table { get; set; }
    }
}
