using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
   public class TopicFilter:FilterBase
    {
       public const string Create_Time_ASC = "create_time asc";
       public const string Create_Time_DESC = "create_time desc";
       public const string Head_ASC = "Head asc";
       public const string Head_DESC = "Head desc";

       /// <summary>
       /// 会员id
       /// </summary>
       public int? User_ID { get; set; }
       /// <summary>
       /// 项目id
       /// </summary>
       public int? Team_ID { get; set; }
       /// <summary>
       /// 城市id
       /// </summary>
       public int? City_ID { get; set; }
       /// <summary>
       /// 内容
       /// </summary>
       public string Content { get; set; }
       /// <summary>
       /// 创建时间
       /// </summary>
       public DateTime? Create_Time { get; set; }
       /// <summary>
       /// 父ID? 0表示发表的讨论区 >0表示回复
       /// </summary>
       public int? Parent_id { get; set; }
       /// <summary>
       /// 分类表ID
       /// </summary>
       public int? Public_id { get; set; }

       public string wheresqls { get; set; }

    }
}
