using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public class Cps:Obj,ICps
    {
        /// <summary>
        /// 主键
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 合作商家标识
        /// </summary>
       public virtual string channelId { get; set; }
        /// <summary>
        /// 存储合作商家需要的int类型数据
        /// </summary>
       public virtual int u_id { get; set; }
        /// <summary>
        /// 存储订单号
        /// </summary>
       public virtual int order_id { get; set; }
        /// <summary>
        /// 通知地址和结果
        /// </summary>
       public virtual string result { get; set; }
        /// <summary>
        /// 存储合作商家需要的string类型数据
        /// </summary>
       public virtual string value1 { get; set; }
        /// <summary>
        /// 存储合作商家需要的string类型数据
        /// </summary>
       public virtual string username { get; set; }
        /// <summary>
        /// 存储跟踪信息（返利）
        /// </summary>
       public virtual string tracking_code { get; set; }
    }
}
