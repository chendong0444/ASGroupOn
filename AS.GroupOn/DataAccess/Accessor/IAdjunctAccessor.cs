using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
    /// <summary>
    /// zjq
    /// 2012-10-29
    /// </summary>
    public interface IAdjunctAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="card"></param>
        /// <returns></returns>
        int Insert(IAdjunct Adjunct);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="card"></param>
        /// <returns></returns>
        int Update(IAdjunct Adjunct);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="card"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IAdjunct Get(AdjunctFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IAdjunct> GetList(AdjunctFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IAdjunct> GetPager(AdjunctFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IAdjunct GetByID(int id);
    }
}
