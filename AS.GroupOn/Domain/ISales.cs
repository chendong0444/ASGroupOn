using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-11-2
    /// </summary>
    public interface ISales:IObj
    {
        /// <summary>
        /// 主键
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 用户名
        /// </summary>
        string username { get; set; }
        /// <summary>
        /// 密码
        /// </summary>
        string password { get; set; }
        /// <summary>
        /// 真实姓名
        /// </summary>
        string realname { get; set; }
        /// <summary>
        /// 联系电话
        /// </summary>
        string contact { get; set; }
    }
}
