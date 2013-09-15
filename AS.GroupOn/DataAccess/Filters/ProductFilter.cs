using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：产品库
    /// </summary>
    public class ProductFilter : FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string SORTORDER_ASC = "sortorder asc";
        public const string SORTORDER_DESC = "sortorder desc";

        public int? Id { get; set; }
        public int? Status { get; set; }

        public string Productnamelike { get; set; }
        public int? Partnerid { get; set; }
        public int? partnerId { get; set; }
        public int? inpartnerId { get; set; }
        public string Productname { get; set; }
        public string Prnamelike { get; set; }

    }
}
