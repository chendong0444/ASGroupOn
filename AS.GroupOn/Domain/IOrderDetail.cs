using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 订单详情表只显示快递项目
    /// </summary>
    public interface IOrderDetail : IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int id { get; }
        /// <summary>
        /// 订单ID
        /// </summary>
        int Order_id { get; set; }
        /// <summary>
        /// 数量
        /// </summary>
        int Num { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
        int Teamid { get; set; }
        /// <summary>
        /// 单价
        /// </summary>
        decimal Teamprice { get; set; }
        /// <summary>
        /// 规格
        /// </summary>
        string result { get; set; }
        /// <summary>
        /// 券号
        /// </summary>
        string carno { get; set; }
        /// <summary>
        /// 代金券金额
        /// </summary>
        int Credit { get; set; }
        /// <summary>
        /// 折扣率
        /// </summary>
        int discount { get; set; }
        /// <summary>
        /// 项目花费积分/个
        /// </summary>
        int totalscore { get; set; }
        /// <summary>
        /// 订单返积分明细
        /// </summary>
        int orderscore { get; set; }

        ////////////////////////////////////
        /// <summary>
        /// 订单
        /// </summary>
        IOrder Order { get; }
        /// <summary>
        /// 项目
        /// </summary>
        ITeam Team { get; }

        /// <summary>
        /// 临时订单号 不需要存入数据库
        /// </summary>
        string TempOrderID { get; set; }

        /*--关联Team表--*/
        string Title { get; set; }
        string Product { get; set; }
    }
}
