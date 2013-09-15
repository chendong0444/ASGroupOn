using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    public class Topic : Obj, ITopic
    {
        /// <summary>
        /// 讨论Id号
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 父讨论id号
        /// </summary>
        public virtual int Parent_id { get; set; }
        /// <summary>
        ///会员id
        /// </summary>
        public virtual int User_id { get; set; }
        /// <summary>
        /// 标题
        /// </summary>
        public virtual string Title { get; set; }
        /// <summary>
        /// 项目id
        /// </summary>
        public virtual int Team_id { get; set; }
        /// <summary>
        /// 城市id
        /// </summary>
        public virtual int City_id { get; set; }
        /// <summary>
        /// 分类表id
        /// </summary>
        public virtual int Public_id { get; set; }
        /// <summary>
        /// 内容
        /// </summary>
        public virtual string Content { get; set; }
        /// <summary>
        /// 置顶操作
        /// </summary>
        public virtual long Head { get; set; }
        /// <summary>
        /// 回复数
        /// </summary>
        public virtual int Reply_number { get; set; }
        /// <summary>
        /// 查看数
        /// </summary>
        public virtual int View_number { get; set; }
        /// <summary>
        /// 最后回复id
        /// </summary>
        public virtual int Last_user_id { get; set; }
        /// <summary>
        /// 最后回复时间 
        /// </summary>
        public virtual DateTime Last_time { get; set; }
        /// <summary>
        /// 创建时间
        /// </summary>
        public virtual DateTime create_time { get; set; }

    }
}
