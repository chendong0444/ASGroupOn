using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    public class Authority : Obj, IAuthority
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int ID { get; set; }
        /// <summary>
        /// 权限名称
        /// </summary>
        public virtual string AuthorityName { get; set; }
    }
}
