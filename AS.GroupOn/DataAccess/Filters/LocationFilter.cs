using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public class LocationFilter : FilterBase
    {
        #region LocationFilter成员
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Createdate_ASC = "createdate asc";
        public const string Createdate_DESC = "createdate desc";
        /// <summary>
        /// 排序：type desc, id desc
        /// </summary>
        public const string More_DESC = "type desc, id desc";

        public int? id { get; set; }
        /// <summary>
        /// 显示位置 1首页 2右侧
        /// </summary>
        public int? Location { get; set; }
        /// <summary>
        /// 是否显示 0隐藏 1显示
        /// </summary>
        public int? visibility { get; set; }
        public int? visibilityS { get; set; }
        public string height { get; set; }
        public DateTime? From_Createdate { get; set; }
        public DateTime? To_Createdate { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
        public string Cityid { get; set; }

        public string CityidS { get; set; }


        public DateTime? From_Begintime { get; set; }
        public DateTime? To_Begintime { get; set; }

        public DateTime? From_Endtime { get; set; }
        public DateTime? To_Endtime { get; set; }

        public int? type { get; set; }


        #endregion

    }
}
