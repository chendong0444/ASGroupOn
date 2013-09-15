using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class CatalogsFilter : FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Sort_Order_ASC = "sort_order ASC";
        public const string Sort_Order_DESC = "sort_order DESC";
        /// <summary>
        /// 排序字段 sort_order desc,id desc
        /// </summary>
        public const string MoreSort = "sort_order desc,id desc";
        public const string MoreSort_ASC = "sort_order asc,id asc";
        public const string MoreSort_DESC_ASC = "sort_order desc,id asc";

        public int? id { get; set; }

        public int? parent_id { get; set; }

        public string ids { get; set; }

        public int? visibility { get; set; }

        public int? catahost { get; set; }

        public string cityid { get; set; }

        public int? CatalogType { get; set; }

        public int? type { get; set; }

        public int? Location { get; set; }

        public string catalogname { get; set; }

        public string catalognameLike { get; set; }

        public string keywordLike { get; set; }

        public int? LocationOr { get; set; }

        public int? cityidLikeOr { get; set; }

        public int? parent_idNotZero { get; set; }

        public string Where { get; set; }
    }
}
