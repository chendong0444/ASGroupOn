using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 页面层次关系表
    /// </summary>
    public interface IMenuRelation : IObj
    {
        /// <summary>
        /// 主键
        /// </summary>
        int Id { get;}
        /// <summary>
        ///
        /// </summary>
        int farthermenuid { get; set; }
        /// <summary>
        ///
        /// </summary>
        int childmenuid { get; set; }
    }
}
