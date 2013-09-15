using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
    public class OrderFilter : FilterBase
    {
        public const string ID_ASC = "id asc";
        public const string ID_DESC = "id desc";
        public const string Create_time_ASC = "Create_time ASC";
        public const string Create_time_DESC = "Create_time DESC";
        public const string Pay_time_ASC = "Pay_time ASC";
        public const string Pay_time_DESC = "Pay_time DESC";
        public const string OCreate_time_ASC = "o.create_time";
        public const string OCreate_time_DESC = "o.create_time desc";
        public const string Teamid_DESC = "v_tt.Team_id desc";
        public const string Payid_ASC = "Pay_id desc";
        public const string Payid_DESC = "Pay_id desc";

        public int? Id { get; set; }
        public string Pay_id { get; set; }
        public int? User_id { get; set; }
        public string State { get; set; }
        public string orState { get; set; }
        public string UnState { get; set; }

        public string Realname { get; set; }
        public string Mobile { get; set; }
        public string Express { get; set; }

        public decimal? Fare { get; set; }
        public decimal? Origin { get; set; }


        public int? TeamOr { get; set; }

        public string Express_xx { get; set; }
        public string No_Express_xx { get; set; }

        public int? Express_id { get; set; }
        public int? No_Express_id { get; set; }
        /// <summary>
        /// 订单退款的状态
        /// </summary>
        public string RviewstateIn { get; set; }

        public string Express_no { get; set; }
        public DateTime? FromCreate_time { get; set; }
        public DateTime? ToCreate_time { get; set; }
        public DateTime? FromPay_time { get; set; }
        public DateTime? ToPay_time { get; set; }
        public int? Parent_orderid { get; set; }
        public int? Partner_id { get; set; }
        public string StateIn { get; set; }
        public string StateOr { get; set; }
        public string Address { get; set; }
        public int? City_id { get; set; }
        public string Service { get; set; }
        public string No_Service { get; set; }
        /// <summary>
        /// 抽奖项目的短信认证码 4位
        /// </summary>
        public string checkcode { get; set; }
        public int? Team_id { get; set; }
        /// <summary>
        /// 查询指定项目没有生成优惠券的订单
        /// </summary>
        public int? NoCouponTeamID { get; set; }
        public int? CashParent_orderid { get; set; }
        public int? LenDa_Express_no { get; set; }
        public int? Len_Express_no { get; set; }

        public int? Team_In { get; set; }
        public int? Incoupon { get; set; }
        public string where1 { get; set; }
        public string where2 { get; set; }
        public string where3 { get; set; }
        public int? strTeam_id { get; set; }
        public string sPay_time { get; set; }
        public string ePay_time { get; set; }
        public string sCreate_Time { get; set; }
        public string eCreate_Time { get; set; }
        public int? sPartner_id { get; set; }

        public string Wheresql1 { get; set; }
        public string Wheresql2 { get; set; }
        public string Wheresql3 { get; set; }
        public string Wheresql4 { get; set; }

        public string table { get; set; }

        public int? userid { get; set; }


    }
}
