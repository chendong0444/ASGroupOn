using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public interface ICps:IObj
    {
        /// <summary>
        /// 主键
        /// </summary>
        int id { get; }
        /// <summary>
        /// 合作商家标识
        /// </summary>
        string channelId { get; set; }
        /// <summary>
        /// 存储合作商家需要的int类型数据
        /// </summary>
        int u_id { get; set; }
        /// <summary>
        /// 存储订单号
        /// </summary>
        int order_id { get; set; }
        /// <summary>
        /// 通知地址和结果
        /// </summary>
        string result { get; set; }
        /// <summary>
        /// 存储合作商家需要的string类型数据
        /// </summary>
        string value1 { get; set; }
        /// <summary>
        /// 存储合作商家需要的string类型数据
        /// </summary>
        string username { get; set; }
        /// <summary>
        /// 存储跟踪信息（返利）
        /// </summary>
        string tracking_code { get; set; }
    }
}
