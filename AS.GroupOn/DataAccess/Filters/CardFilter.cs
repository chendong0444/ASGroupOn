using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
   public class CardFilter:FilterBase
    {
       public const string End_time_Desc = "End_time Desc";
       public const string Begin_time_Desc = "Begin_time Desc";
       public const string Id_Desc = "Id Desc";
       public const string uId_ASC = "uId asc";
       public const string uId_Desc = "uId Desc";

       public string Id { get; set; }

       public string Code { get; set; }

       public string consume { get; set; }

       public int? user_id { get; set; }

       public int? isGet { get; set; }

       public int? Team_id { get; set; }

       public int? Partner_id { get; set; }

       public int? WhereUser_id { get; set; }

       public int? Fromuser_id { get; set; }  //已派发

       public int? Order_id { get; set; }

       public int? inOrder_id { get; set; }

       public DateTime? FromEnd_time { get; set; }  //有效期开始时间
       public DateTime? ToEnd_time { get; set; }

       public DateTime? ToBegin_time { get; set; }

       
       public DateTime? FromuCreate_time { get; set; }
       public DateTime? TouCreate_time { get; set; }
       public int? FromoCount { get; set; }
       public string uCity_id { get; set; }
       public string FromuTotalamount { get; set; }
       public string TouTotalamount { get; set; }
       public int? teamid { get; set; }
    }
}
