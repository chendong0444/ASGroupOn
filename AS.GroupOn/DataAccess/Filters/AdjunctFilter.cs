using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class AdjunctFilter:FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string uploadTime_ASC = "uploadTime ASC";
        public const string uploadTime_DESC = "uploadTime DESC";

        public int? Id { get; set; }

        public string Url { get; set; }

        public int? display { get; set; }

        public string FromUploadTime { get; set; }

        public string ToUploadTime { get; set; }

        public int? reId { get; set; }

    }
}
