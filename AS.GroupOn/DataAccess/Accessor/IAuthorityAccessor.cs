using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess.SqlBat;

namespace AS.GroupOn.DataAccess.Accessor
{
   public interface IAuthorityAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="ask"></param>
        /// <returns></returns>
       int Insert(IAuthority authority);

        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="ask"></param>
        /// <returns></returns>
        int Delete(int id);

        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IAuthority> GetList(AuthorityFilter filter);

        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IAuthority GetByID(int id);
        /// <summary>
        /// 返回指定条件的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(AuthorityFilter filter);

    }
}
