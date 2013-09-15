using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.DataAccess.Accessor
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-11-2
    /// </summary>
    public interface ISalesAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="sales"></param>
        /// <returns></returns>
        int Insert(ISales sales);
        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="sales"></param>
        /// <returns></returns>
        int Update(ISales sales);
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
        ISales Get(SalesFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ISales> GetList(SalesFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPagers<ISales> GetPager(SalesFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ISales GetByID(int id);
    }
}
