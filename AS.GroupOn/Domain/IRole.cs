using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：角色
    /// </summary>
    public interface IRole:IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int Id { get; set; }
        /// <summary>
        /// 角色名称
        /// </summary>
        string rolename { get; set; }

        /// <summary>
        /// 简称
        /// </summary>
        string code { get; set; }
       
    }
}
