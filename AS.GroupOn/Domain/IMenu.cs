using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public interface IMenu:IObj
    {
        #region 页面操作表
        /// <summary>
        /// ID号
        /// </summary>
        int Id { get; set; }
        /// <summary>
        /// 页面名称
        /// </summary>
        string menuName { get; set; }
        /// <summary>
        /// 页面路径
        /// </summary>
        string menuUrl { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        int sort { get; set; }
        #endregion
    }
}
