using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
using AS.Common.Utils;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：zjq
    /// 时间：2012-10-25
    /// </summary>
    public class Category:Obj,ICategory
    {
        /// <summary>
        /// ID
        /// </summary>
        public virtual int Id { get; set; }
        /// <summary>
        /// 类别
        /// </summary>
        public virtual string Zone { get; set; }
        /// <summary>
        /// 自定义分组
        /// </summary>
        public virtual string Czone { get; set; }
        /// <summary>
        /// 名称
        /// </summary>
        public virtual string Name { get; set; }
        /// <summary>
        /// 英文名称
        /// </summary>
        public virtual string Ename { get; set; }
        /// <summary>
        /// 英文首字母
        /// </summary>
        public virtual string Letter { get; set; }
        /// <summary>
        /// 排序
        /// </summary>
        public virtual int Sort_order { get; set; }
        /// <summary>
        /// 导航显示
        /// </summary>
        public virtual string Display { get; set; }
        /// <summary>
        /// 城市公告
        /// </summary>
        public virtual string content { get; set; }
        /// <summary>
        /// 2.28新增二级城市id
        /// </summary>
        public virtual int City_pid { get; set; }
       /// <summary>
       /// 快递数量
       /// </summary>
        public virtual int Num { get; set; }


        //private IMailtasks _mailtasks = null;
        ///// <summary>
        ///// 返回组对象
        ///// </summary>
        //public virtual IMailtasks Mailtasks
        //{
        //    get
        //    {
        //        if (_mailtasks == null)
        //        {
        //            using (AS.GroupOn.DataAccess.IDataSession session = App.Store.OpenSession(false))
        //            {
        //                _mailtasks = session.Users.GetByID(this.user_id);
        //            }
        //        }
        //        return _mailtasks;
        //    }
        //}
        public virtual int number { get; set; }

    }
}
