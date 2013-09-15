using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
  public class OprationLogFilter:FilterBase
    {
      public const string ID_ASC = "id asc";
      public const string ID_DESC = "id desc";
      public const string CREATE_TIME_ASC = "createtime asc";
      public const string CREATE_TIME_DESC = "createtime desc";

      public int? id { get; set; }

      public DateTime? FromCreateTime { get; set; }

      public DateTime? ToCreateTime { get; set; }


    }
}
