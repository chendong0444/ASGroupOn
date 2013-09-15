using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.DataAccess.Accessor
{
    public interface IRoleAuthorityAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="flow"></param>
        /// <returns></returns>
       int Insert(IRoleAuthority RoleAuthority);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="flow"></param>
        /// <returns></returns>
       int Update(IRoleAuthority RoleAuthority);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="flow"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IRoleAuthority Get(RoleAuthorityFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IRoleAuthority> GetList(RoleAuthorityFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IRoleAuthority> GetPager(RoleAuthorityFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IRoleAuthority GetByID(int id);

        int DelByRoleID(int id);
    }
}
