using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface IBrand:IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int Id { get; }
        /// <summary>
        /// 中文名称
        /// </summary>
        string Name { get; set; }
        /// <summary>
        /// 英文名称
        /// </summary>
        string Ename { get; set; }
        /// <summary>
        /// 首字母
        /// </summary>
        string Letter { get; set; }
        /// <summary>
        /// 排列序号
        /// </summary>
        int Sort_order { get; set; }
        /// <summary>
        /// 是否显示  Y显示 N不显示
        /// </summary>
        string Display { get; set; }


    }
}
