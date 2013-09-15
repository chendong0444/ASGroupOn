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
   public interface IExpressnocitysAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="expressnocitys"></param>
        /// <returns></returns>
       int Insert(IExpressnocitys expressnocitys);
        /// <summary
       /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="expressnocitys"></param>
        /// <returns></returns>
       int Update(IExpressnocitys expressnocitys);
        /// <summary>
       /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="Id"></param>
        /// <returns></returns>
        int Delete(int Id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IExpressnocitys Get(ExpressnocitysFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IExpressnocitys> GetList(ExpressnocitysFilter filter);
       /// <summary>
        /// 返回指定页的记录数
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
        IPagers<IExpressnocitys> GetPager(ExpressnocitysFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IExpressnocitys GetByID(int id);

        int UpdateNocitys(IExpressnocitys expressnocitys);
    }
}
