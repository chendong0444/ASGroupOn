using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：退款详情
    /// </summary>
    public interface IRefunds_detailAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="refunds_detail"></param>
        /// <returns></returns>
        int Insert(IRefunds_detail refunds_detail);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="refunds_detail"></param>
        /// <returns></returns>
        int Update(IRefunds_detail refunds_detail);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="refunds_detail"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IRefunds_detail Get(Refunds_detailFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IRefunds_detail> GetList(Refunds_detailFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IRefunds_detail> GetPager(Refunds_detailFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IRefunds_detail GetByID(int id);
        /// <summary>
        /// 返回指定条件的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(Refunds_detailFilter filter);
    }
}
