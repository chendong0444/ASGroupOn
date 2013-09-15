using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess.SqlBat;
namespace AS.GroupOn.DataAccess.Accessor
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   zlj
    /// </summary>
   public interface IAskAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="ask"></param>
        /// <returns></returns>
        int Insert(IAsk ask);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="ask"></param>
        /// <returns></returns>
        int Update(IAsk ask);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="ask"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IAsk Get(AskFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IAsk> GetList(AskFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IAsk> GetPager(AskFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IAsk> GetPagerTm(AskFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IAsk GetByID(int id);
       /// <summary>
       /// 返回指定条件的记录数
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
        int GetCount(AskFilter filter);
        /// <summary>
        /// 批量更新一组记录
        /// </summary>
        /// <param name="Params">更新参数</param>
        /// <param name="filter">查询条件</param>
        /// <returns></returns>
        int UpdateBat(AskBat Params);
        /// <summary>
        /// 批量删除符合条件的记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int DeleteBat(AskFilter filter);
    }
}
