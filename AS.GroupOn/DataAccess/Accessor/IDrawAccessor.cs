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
    public interface IDrawAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="draw"></param>
        /// <returns></returns>
        int Insert(IDraw draw);
        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="draw"></param>
        /// <returns></returns>
        int Update(IDraw draw);
        /// <summary>
        ///  删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="Id"></param>
        /// <returns></returns>
        int Delete(int Id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IDraw Get(DrawFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IDraw> GetList(DrawFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPagers<IDraw> GetPager(DrawFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPagers<IDraw> GetSumPager(DrawFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="Id"></param>
        /// <returns></returns>
        IDraw GetByID(int Id);

        int GetCount(DrawFilter filter);

        int GetChou(DrawFilter filter);
        IPagers<IDraw> GetPageChou(DrawFilter filter);
    }
}
