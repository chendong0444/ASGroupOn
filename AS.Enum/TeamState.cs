using System;
using System.Collections.Generic;
using System.Text;

namespace AS.Enum
{
    /// <summary>
    /// 项目状态
    /// </summary>
    public enum TeamState
    {
        /// <summary>
        /// 未开始
        /// </summary>
        none = 0,
        /// <summary>
        /// 正在进行
        /// </summary>
        begin = 1,
        /// <summary>
        /// 已成功未过期还可以购买
        /// </summary>
        successbuy = 2,
        /// <summary>
        /// 已成功未过期不可以购买已卖光
        /// </summary>
        successnobuy = 4,
        /// <summary>
        /// 已成功已过期
        /// </summary>
        successtimeover = 8,
        /// <summary>
        /// 未成功已过期
        /// </summary>
        fail = 16,

    }


}
