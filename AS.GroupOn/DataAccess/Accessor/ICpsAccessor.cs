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
   public interface ICpsAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="cps"></param>
        /// <returns></returns>
        int Insert(ICps cps);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="cps"></param>
        /// <returns></returns>
        int Update(ICps cps);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        ICps Get(CpsFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ICps> GetList(CpsFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<ICps> GetPager(CpsFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ICps GetByID(int id);
        /// <summary>
        /// 返回指定条件的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(CpsFilter filter);
    }
}
