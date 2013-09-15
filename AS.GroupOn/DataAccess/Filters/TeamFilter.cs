using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
namespace AS.GroupOn.DataAccess.Filters
{
    public class TeamFilter : FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Sort_Order_ASC = "Sort_Order ASC";
        public const string Sort_Order_DESC = "Sort_Order DESC";
        public const string Begin_time_ASC = "Begin_time ASC";
        public const string Begin_time_DESC = "Begin_time DESC";
        public const string Team_Price_ASC = "Team_Price ASC";
        public const string Team_Price_Desc = "Team_Price Desc";
        public const string Discount_ASC = " (Team_Price/Market_Price) DESC";
        public const string Nownumber_DESC = "Now_number desc";
        public const string Nownumber_ASC = "Now_number asc";
        public const string City_id_ASC = "City_id ASC";
        public const string City_id_DESC = "City_id DESC";
        public const string Discounts_ASC = "Team_price/case Market_price when 0 then null else Market_price end asc";
        public const string Discounts_DESC = "Team_price/case Market_price when 0 then null else Market_price end desc";

        /// <summary>
        /// 排序字段 sort_order desc,Begin_time desc,id desc
        /// </summary>
        public const string MoreSort = "sort_order desc,Begin_time desc,id desc";

        public const string MoreAsc = "sort_order asc,Begin_time asc,id asc";
        /// <summary>
        /// 排序字段 Now_number desc,sort_order desc,id desc
        /// </summary>
        public const string MoreSort2 = "Now_number desc,sort_order desc,id desc";
        /// <summary>
        /// 排序字段 sort_order desc,id desc
        /// </summary>
        public const string MoreSort3 = "sort_order desc,id desc";

        public int? City_id { get; set; }
        public int? Id { get; set; }
        public string TitleLike { get; set; }
        public int? CityID { get; set; }
        public int? Group_id { get; set; }
        public int? Partner_id { get; set; }
        public string Delivery { get; set; }
        public string Team_type { get; set; }
        public int? status { get; set; }
        public TeamState? State { get; set; }
        public int? CataID { get; set; }
        public string CataIDin { get; set; }
        public string CataIDNotin { get; set; }
        public int? OrderID { get; set; }
        public int? teamcata { get; set; }
        public int? teamcataor { get; set; }
        public int? BrandID { get; set; }
        public int? teamhost { get; set; }
        public int? teamnew { get; set; }
        public int? productid { get; set; }
        public DateTime? ToBegin_time { get; set; }
        public DateTime? FromBegin_time { get; set; }
        public DateTime? orBegin_time { get; set; }
        public DateTime? FromEndTime { get; set; }
        public DateTime? ToEndTime { get; set; }
        public DateTime? EndToTime { get; set; }
        public string IdnotIn { get; set; }
        public int? No_Id { get; set; }
        public int? Cityblockothers { get; set; }
        public int? DA_City_id { get; set; }
        public string Fromnownumber { get; set; }
        public string Tonownumber { get; set; }
        public int? isopen_invent { get; set; }
        public int? oropen_invent { get; set; }
        public string not { get; set; }
        /// <summary>
        /// None,success(成功),soldout(卖光了),failure(失败) default ‘none’(正在进行中)
        /// </summary>
        public string TypeIn { get; set; }
        public string unTeam_type { get; set; }
        public string othercity { get; set; }

        //积分检索
        public int? StarTeamScore { get; set; }
        public int? EndTeamScore { get; set; }

       /// <summary>
       /// 关键词检索
       /// </summary>
        public string KeyWord { get; set; }

        /// <summary>
        /// 城市检索
        /// </summary>
        public string cityidIn { get; set; }

        public string City_ids { get; set; }

        public int? mallstatus { get; set; }

        public int? BrandIDNotZero { get; set; }

        public int? FromBrand_id { get; set; }

        public double? FromMarketPrice { get; set; }
        public double? ToMarketPrice { get; set; }

        public string FromTeam_price { get; set; }
        public string ToTeam_price { get; set; }

        public string pl_teamid { get; set; }
        public int? pl_state { get; set; }

        public int? oper_teamid { get; set; }
        public int? dto_teamid { get; set; }

        public string NotDelivery { get; set; }

        public string unpoint { get; set; }

        public int? CurrentCityId { get; set; }
        /// <summary>
        /// 是否开启团购预告
        /// </summary>
        public int? isPredict { get; set; }
        /// <summary>
        /// sql语句条件
        /// </summary>
        public string sqlwhere { get; set; }

        public string where { get; set; }

        public string sql { get; set; }

        public string table { get; set; }

        public int? branch_id { get; set; }

        public int? userid { get; set; }
    }

}
