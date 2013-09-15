using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 新闻公告
    /// </summary>
    public class News : Obj, INews
    {
        /// <summary>
        /// ID号
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 标题
        /// </summary>
        public virtual string title { get; set; }
        /// <summary>
        /// 内容
        /// </summary>
        public virtual string content { get; set; }
        /// <summary>
        /// 创建时间
        /// </summary>
        public virtual DateTime create_time { get; set; }
        /// <summary>
        /// 0代表新闻 这个值目前不用处理
        /// </summary>
        public virtual int type { get; set; }
        /// <summary>
        /// 链接地址 当有链接值时跳转对应的链接，否则显示地址
        /// </summary>
        public virtual string link { get; set; }
        /// <summary>
        /// 管理员ID
        /// </summary>
        public virtual int adminid { get; set; }
        /// <summary>
        /// 新闻SEO标题
        /// </summary>
        public virtual string seotitle { get; set; }
        /// <summary>
        /// 新闻SEO关键词
        /// </summary>
        public virtual string seokeyword { get; set; }
        /// <summary>
        /// 新闻SEO描述
        /// </summary>
        public virtual string seodescription { get; set; }

        private IUser _user = null;
        /// <summary>
        /// 返回组对象
        /// </summary>
        public virtual IUser User
        {
            get
            {
                if (_user == null)
                {
                    using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
                    {
                        _user = session.Users.GetByID(this.adminid);
                    }
                }
                return _user;
            }
        }
    }
}
