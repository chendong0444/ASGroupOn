using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public class Menu:Obj,IMenu
    {

        #region 操作页面表
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 页面名称
        /// </summary>
        public virtual string menuName { get; set; }
        /// <summary>
        /// 页面路径
        /// </summary>
        public virtual string menuUrl { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        public virtual int sort { get; set; }
        #endregion
    }
}
