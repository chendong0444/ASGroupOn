using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
    public interface IPayAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="pay"></param>
        /// <returns></returns>
        void Insert(IPay pay);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="pay"></param>
        /// <returns></returns>
        int Update(IPay pay);

        int UpdateMoney(IPay pay);

        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="pay"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPay Get(PayFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IPay> GetList(PayFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IPay> GetPager(PayFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IPay GetByID(string id);

        IPay GetByBank(PayFilter filter);
    }
}
