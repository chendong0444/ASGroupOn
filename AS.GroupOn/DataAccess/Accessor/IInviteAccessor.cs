using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
   public interface IInviteAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="invite"></param>
        /// <returns></returns>
        int Insert(IInvite invite);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="invite"></param>
        /// <returns></returns>
        int Update(IInvite invite);

        int UpdatePayTime(IInvite invite);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="invite"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IInvite Get(InviteFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IInvite> GetList(InviteFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IInvite> GetPager(InviteFilter filter);

        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IInvite> GetPager2(InviteFilter filter);

        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IInvite GetByID(int id);

        IInvite GetByOther_Userid(int id);

        /// <summary>
        /// 返回邀请统计
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IInvite> GetYaoqingTongji(InviteFilter filter);

        int GetCount(InviteFilter filter);

    }
}
