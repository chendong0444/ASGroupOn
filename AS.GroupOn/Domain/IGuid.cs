using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建时间  2012-10-24
    /// 创建人   郑立军
    /// </summary>
   public interface IGuid:IObj
   {
       #region 导航栏目表
       /// <summary>
       /// 主键
       /// </summary>
       int id { get; set; }
       /// <summary>
       /// 栏目标题
       /// </summary>
       string guidtitle { get; set; }
       /// <summary>
       /// 栏目链接地址
       /// </summary>
       string guidlink { get; set; }
       /// <summary>
       /// 显示状态 0显示 1隐藏
       /// </summary>
       int guidopen { get; set; }
       /// <summary>
       /// 新窗口打开 0否 1是
       /// </summary>
       int guidparent { get; set; }
       /// <summary>
       /// 栏目排序
       /// </summary>
       int guidsort { get; set; }
       /// <summary>
       /// 生成时间
       /// </summary>
       DateTime createtime { get; set; }
       /// <summary>
       /// 导航分类 0：团购1：商城
       /// </summary>
       int teamormall { get; set; }
       #endregion
   }
}
