using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.Domain;

namespace AS.GroupOn.DataAccess.Accessor
{
   public  interface ISubscribeAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="Subscribe"></param>
        /// <returns></returns>
        int Insert(ISubscribe Subscribe);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="Subscribe"></param>
        /// <returns></returns>
        int Update(ISubscribe Subscribe);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="Subscribe"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        ISubscribe Get(SubscribeFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ISubscribe> GetList(SubscribeFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<ISubscribe> GetPager(SubscribeFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ISubscribe GetByID(int id);
        /// <summary>
        /// 返回指定条件的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(SubscribeFilter filter);
    }
}
