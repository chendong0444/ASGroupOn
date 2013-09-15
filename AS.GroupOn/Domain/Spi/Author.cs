using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：zjq
    /// 时间：2012-10-24
    /// </summary>
    public class Author:Obj,IAuthor
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 角色id
        /// </summary>
        public virtual int Roleid { get; set; }
        /// <summary>
        /// 页面id
        /// </summary>
        public virtual int Menuid { get; set; }
    }
}
