using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    public class Page : Obj, IPage
    {
        /// <summary>
        /// 页面名称
        /// </summary>
        public virtual string Id { get; set; }
        /// <summary>
        /// 页面信息
        /// </summary>
        public virtual string Value { get; set; }
    }
}
