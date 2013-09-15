using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
   public interface IFriendLink:IObj
    {
       int Id { get; set; }
       /// <summary>
       /// 友情链接名称
       /// </summary>
       string Title { get; set; }
       /// <summary>
       /// 友情链接Url
       /// </summary>
       string url { get; set; }
       /// <summary>
       /// 友情链接Logo
       /// </summary>
       string Logo { get; set; }
       /// <summary>
       /// 友情链接排序
       /// </summary>
       int Sort_order { get; set; }
    }
}
