using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using System.Collections;
namespace AS.GroupOn.DataAccess.Accessor
{
    /// <summary>
    /// 创建人：耿丹
    /// 时间：2012-10-24
    /// </summary>
    public interface IFarecitysAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="flow"></param>
        /// <returns></returns>
        int Insert(IFarecitys farecitys);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="flow"></param>
        /// <returns></returns>
        int Update(IFarecitys farecitys);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="flow"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IFarecitys Get(FarecitysFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IFarecitys> GetList(FarecitysFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IFarecitys> GetPager(FarecitysFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IFarecitys GetByID(int Id);

        /// <summary>
        /// 返回指定父id的记录
        /// </summary>
        /// <param name="pid"></param>
        /// <returns></returns>
        IList<Hashtable> GetByPid(FarecitysFilter filter);
    }
}
