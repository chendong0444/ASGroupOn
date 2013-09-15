using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public interface IFriendLinkAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="friendLink"></param>
        /// <returns></returns>
        int Insert(IFriendLink friendLink);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="friendLink"></param>
        /// <returns></returns>
        int Update(IFriendLink friendLink);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="friendLink"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IFriendLink Get(FriendLinkFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IFriendLink> GetList(FriendLinkFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IFriendLink> GetPager(FriendLinkFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IFriendLink GetByID(int id);
    }
}
