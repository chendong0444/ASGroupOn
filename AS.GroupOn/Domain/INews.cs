using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 新闻公告
    /// </summary>
    public interface INews : IObj
    {
        /// <summary>
        /// ID号
        /// </summary>
        int id { get; set; }
        /// <summary>
        /// 标题
        /// </summary>
        string title { get; set; }
        /// <summary>
        /// 内容
        /// </summary>
        string content { get; set; }
        /// <summary>
        /// 创建时间
        /// </summary>
        DateTime create_time { get; set; }
        /// <summary>
        /// 0代表新闻 这个值目前不用处理
        /// </summary>
        int type { get; set; }
        /// <summary>
        /// 链接地址 当有链接值时跳转对应的链接，否则显示地址
        /// </summary>
        string link { get; set; }
        /// <summary>
        /// 管理员ID
        /// </summary>
        int adminid { get; set; }
        /// <summary>
        /// 新闻SEO标题
        /// </summary>
        string seotitle { get; set; }
        /// <summary>
        /// 新闻SEO关键词
        /// </summary>
        string seokeyword { get; set; }
        /// <summary>
        /// 新闻SEO描述
        /// </summary>
        string seodescription { get; set; }

        /// <summary>
        /// 返回用户
        /// </summary>
        IUser User { get; }
    }
}
