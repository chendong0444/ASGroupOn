using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface IAuthor
    {
        /// <summary>
        /// ID号
        /// </summary>
        int Id { get; set; }
        /// <summary>
        /// 角色id
        /// </summary>
        int Roleid { get; set; }
        /// <summary>
        /// 页面id
        /// </summary>
        int Menuid { get; set; }
    }
}
