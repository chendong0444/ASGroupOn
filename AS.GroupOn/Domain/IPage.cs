using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface IPage : IObj
    {
        /// <summary>
        /// 页面名称
        /// </summary>
        string Id { get; set; }
        /// <summary>
        /// 页面信息
        /// </summary>
        string Value { get; set; }
    }
}
