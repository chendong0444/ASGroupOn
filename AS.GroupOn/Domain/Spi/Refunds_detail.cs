using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：退款详情
    /// </summary>
    public class Refunds_detail:Obj,IRefunds_detail
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 退款记录id
        /// </summary>
        public virtual int refunds_id { get; set; }
        /// <summary>
        /// 退款项目数
        /// </summary>
        public virtual int teamnum { get; set; }
        /// <summary>
        /// 退款项目id
        /// </summary>
        public virtual int teamid { get; set; }
    }
}
