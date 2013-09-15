using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：zjq
    /// 时间：2012-10-24
    /// </summary>
    public class Adjunct:Obj,IAdjunct
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 图片路径
        /// </summary>
        public virtual string url { get; set; }
        /// <summary>
        /// 图片描述
        /// </summary>
        public virtual string decription { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        public virtual int sort { get; set; }
        /// <summary>
        /// 是否显示
        /// </summary>
        public virtual int display { get; set; }
        /// <summary>
        /// 上传时间
        /// </summary>
        public virtual DateTime uploadTime { get; set; }
    }
}
