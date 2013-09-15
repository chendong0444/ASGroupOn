using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface IArea
    {
        /// <summary>
        /// ID
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 区域名成
        /// </summary>        
        string areaname { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
        int cityid { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        int sort { get; set; }
        /// <summary>
        /// 英文名称
        /// </summary>
        string ename { get; set; }
        /// <summary>
        /// 是否显示
        /// </summary>
        string display { get; set; }
        /// <summary>
        /// 类型
        /// </summary>
        string type { get; set; }
        /// <summary>
        /// 商圈ID
        /// </summary>
        int circle_id { get; set; }
        /// <summary>
        ///or_in_circle_pid
        /// </summary>
        int or_in_circle_pid { get; set; }
    }
}
