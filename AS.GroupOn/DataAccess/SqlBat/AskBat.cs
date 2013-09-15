using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.SqlBat
{
    public class AskBat:AskFilter
    {
        /// <summary>
        /// 批量更新城市ID
        /// </summary>
        public int? Bat_CityID { get; set; }
    }
}
