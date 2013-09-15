using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
       
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
   
    public class Guid:Obj,IGuid
   {
       #region 导航栏目表
       /// <summary>
        /// 主键
        /// </summary>
       public virtual int id { get; set; }
        /// <summary>
        /// 栏目标题
        /// </summary>
       public virtual string guidtitle { get; set; }
        /// <summary>
        /// 栏目链接地址
        /// </summary>
       public virtual string guidlink { get; set; }
        /// <summary>
        /// 显示状态 0显示 1隐藏
        /// </summary>
       public virtual int guidopen { get; set; }
        /// <summary>
        /// 新窗口打开 0否 1是
        /// </summary>
       public virtual int guidparent { get; set; }
        /// <summary>
        /// 栏目排序
        /// </summary>
       public virtual int guidsort { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
       public virtual DateTime createtime { get; set; }
       /// <summary>
       /// 导航分类 0：团购1：商城
       /// </summary>
       public virtual int teamormall { get; set; }
       #endregion
   }
}
