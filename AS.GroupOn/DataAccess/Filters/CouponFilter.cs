using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
   public class CouponFilter:FilterBase
    {
       public const string Create_time_ASC = "Create_time ASC";
       public const string Create_time_DESC = "Create_time DESC";
       
       public const string ID_ASC = "ID ASC";
       public const string ID_DESC = "ID DESC";

       public string Id { get; set; }

       public int? User_id { get; set; }

       public int? Partner_id { get; set; }

       public int? inOrder_id { get; set; }

       public int? Team_id { get; set; }

       public int? Order_id { get; set; }

       public string Consume { get; set; }

       public string Secret { get; set; }

       public int? shoptypes { get; set; }
       /// <summary>
       /// 优惠券结束时间
       /// </summary>
       public DateTime? FromExpire_time { get; set; } 
       public DateTime? ToExpire_time { get; set; }
       /// <summary>
       /// 优惠券使用时间
       /// </summary>
       public DateTime? FromConsume_time { get; set; }
       public DateTime? ToConsume_time { get; set; }
       /// <summary>
       /// 生成时间 
       /// </summary>
       public DateTime? FromCreate_time { get; set; }
       public DateTime? ToCreate_time { get; set; }
       /// <summary>
       /// 优惠卷开始时间
       /// </summary>
       public DateTime? FromStart_time { get; set; }
       public DateTime? ToStart_time { get; set; }

       public int? Team_ids { get; set; }
       public string Consumes { get; set; }

       public string where { get; set; }

       public string table { get; set; }
    }
}
