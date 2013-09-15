using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
   public class OrderDetailFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Order_ID_ASC = "Order_id asc";
        public const string Order_ID_DESC = "Order_id desc";

        public int? Order_ID { get; set; }
       /// <summary>
       /// 查询已付款购物车项目
       /// </summary>
        public int? TeamidOrder { get; set; }

        public decimal? Teamprice  { get; set; }

        public int? Teamid { get; set; }

        public int? order_userid { get; set; }
        public string order_state { get; set; }

        public int? orderdetail_orderid { get; set; }
    }
}
