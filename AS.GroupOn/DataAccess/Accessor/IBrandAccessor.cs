using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
   public interface IBrandAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="brand"></param>
        /// <returns></returns>
        int Insert(IBrand brand);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="brand"></param>
        /// <returns></returns>
        int Update(IBrand brand);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="brand"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IBrand Get(BrandFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IBrand> GetList(BrandFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IBrand> GetPager(BrandFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IBrand GetByID(int id);
    }
}
