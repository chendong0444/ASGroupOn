using System;
using System.Collections.Generic;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
   public interface ICityAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="city"></param>
        /// <returns></returns>
        int Insert(ICity city);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="city"></param>
        /// <returns></returns>
        int Update(ICity city);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="city"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        ICity Get(CityFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ICity> GetList(CityFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<ICity> GetPager(CityFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ICity GetByID(int id);
    }
}
