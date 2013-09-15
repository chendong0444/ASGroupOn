using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
  public  class SmstemplateFilter:FilterBase
    {
        /// <summary>
        /// 短信模版名称
        /// </summary>
        public string Name { get; set; }
        /// <summary>
        /// 短信模版内容
        /// </summary>
        public string Value { get; set; }

    }
}
