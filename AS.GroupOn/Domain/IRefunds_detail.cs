using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：退款详情
    /// </summary>
    public interface IRefunds_detail:IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int Id { get; set; }
        /// <summary>
        /// 退款记录id
        /// </summary>
        int refunds_id { get; set; }
        /// <summary>
        /// 退款项目数
        /// </summary>
        int teamnum { get; set; }
        /// <summary>
        /// 退款项目id
        /// </summary>
        int teamid { get; set; }

    }
}
