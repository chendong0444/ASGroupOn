using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：zjq
    /// 时间：2012-10-24
    /// </summary>
    public class Area:Obj,IArea
    {
        /// <summary>
        /// ID
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 区域名成
        /// </summary>        
        public virtual string areaname { get; set; }
        /// <summary>
        /// 城市ID
        /// </summary>
        public virtual int cityid { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        public virtual int sort { get; set; }
        /// <summary>
        /// 英文名称
        /// </summary>
        public virtual string ename { get; set; }
        /// <summary>
        /// 是否显示
        /// </summary>
        public virtual string display { get; set; }
        /// <summary>
        /// 类型
        /// </summary>
        public virtual string type { get; set; }
        /// <summary>
        /// 商圈ID
        /// </summary>
        public virtual int circle_id {get;set;}

        /// <summary>
        ///or_in_circle_pid
        /// </summary>
        public virtual int or_in_circle_pid { get; set; }
    }
}
