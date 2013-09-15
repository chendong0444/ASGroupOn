using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
    public interface ISystemAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="system"></param>
        /// <returns></returns>
        int Insert(ISystem system);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="system"></param>
        /// <returns></returns>
        int Update(ISystem system);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="system"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        ISystem Get(SystemFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ISystem> GetList(SystemFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<ISystem> GetPager(SystemFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ISystem GetByID(int id);
    }
}
