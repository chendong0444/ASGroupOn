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
    public interface IExpresspriceAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="flow"></param>
        /// <returns></returns>
        int Insert(IExpressprice expressprice);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="flow"></param>
        /// <returns></returns>
        int Update(IExpressprice expressprice);
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
        IExpressprice Get(ExpresspriceFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IExpressprice> GetList(ExpresspriceFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IExpressprice> GetPager(ExpresspriceFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IExpressprice GetByID(int id);
        /// <summary>
        /// 返回指定expressid的记录
        /// </summary>
        /// <param name="expressid"></param>
        /// <returns></returns>
        IExpressprice GetByExpressID(int expressid);
    }
}
