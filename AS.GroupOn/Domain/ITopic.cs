using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface ITopic : IObj
    {
      
        /// <summary>
        /// 讨论Id号
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 父讨论id号
        /// </summary>
        int Parent_id { get; set; }
        /// <summary>
        ///会员id
        /// </summary>
        int User_id { get; set; }
        /// <summary>
        /// 标题
        /// </summary>
        string Title { get; set; }
        /// <summary>
        /// 项目id
        /// </summary>
        int Team_id { get; set; }
        /// <summary>
        /// 城市id
        /// </summary>
        int City_id { get; set; }
        /// <summary>
        /// 分类表id
        /// </summary>
        int Public_id { get; set; }
        /// <summary>
        /// 内容
        /// </summary>
        string Content { get; set; }
        /// <summary>
        /// 置顶操作
        /// </summary>
        long Head { get; set; }
        /// <summary>
        /// 回复数
        /// </summary>
        int Reply_number { get; set; }
        /// <summary>
        /// 查看数
        /// </summary>
        int View_number { get; set; }
        /// <summary>
        /// 最后回复id
        /// </summary>
        int Last_user_id { get; set; }
        /// <summary>
        /// 最后回复时间 
        /// </summary>
        DateTime Last_time { get; set; }
       /// <summary>
       /// 创建时间
       /// </summary>
        DateTime create_time { get; set; }

    }
}
