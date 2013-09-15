using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface IAuthority:IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int ID { get; set; }
        /// <summary>
        /// 权限名称
        /// </summary>
        string AuthorityName { get; set; }
         
    }
}
