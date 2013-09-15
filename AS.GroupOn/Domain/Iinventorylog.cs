using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建时间 20102-10-24
    /// 创建人   郑立军
    /// </summary>
   public interface Iinventorylog:IObj
   {
       #region 库存变更记录表接口
       /// <summary>
        /// ID号
        /// </summary>
        int Id { get; set; }
        /// <summary>
        /// 进出库数量 入库为正 出库为负
        /// </summary>
        int num { get; set; }
        /// <summary>
        /// 如果是下单或退单 此字段为订单号 否则为0
        /// </summary>
        int orderid { get; set; }
        /// <summary>
        /// 如果是管理员出入库 则此字段为管理员ID,否则为0 
        /// </summary>
        int adminid { get; set; }
        /// <summary>
        /// 状态 1管理员入库 2管理员出库 3下单出库 4退单入库
        /// </summary>
        int state { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        DateTime create_time { get; set; }
        /// <summary>
        /// 备注。保留空
        /// </summary>
        string remark { get; set; }
        /// <summary>
        /// 项目ID
        /// </summary>
        int teamid { get; set; }
        /// <summary>
        /// 类型 0项目 1产品
        /// </summary>
        int type { get; set; }

       #endregion
   }
}
