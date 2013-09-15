using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
   public class FriendLink:Obj,IFriendLink
    {
       public virtual int Id { get; set; }
        /// <summary>
        /// 友情链接名称
        /// </summary>
       public virtual string Title { get; set; }
        /// <summary>
        /// 友情链接Url
        /// </summary>
       public virtual string url { get; set; }
        /// <summary>
        /// 友情链接Logo
        /// </summary>
       public virtual string Logo { get; set; }
        /// <summary>
        /// 友情链接排序
        /// </summary>
       public virtual int Sort_order { get; set; }
    }
}
