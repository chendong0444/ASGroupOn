using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface IAdjunct:IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 图片路径
        /// </summary>
        string url { get; set; }
        /// <summary>
        /// 图片描述
        /// </summary>
        string decription { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        int sort { get; set; }
        /// <summary>
        /// 是否显示
        /// </summary>
        int display { get; set; }
        /// <summary>
        /// 上传时间
        /// </summary>
        DateTime uploadTime { get; set; }
    }
}
