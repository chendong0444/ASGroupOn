using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
    /// <summary>
    /// 创建时间 2012-10-24
    /// 创建人   郑立军
    /// </summary>
    public interface IGuidAccessor
    {
        #region IGuidAccessor成员
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="guid"></param>
        /// <returns></returns>
        int Insert(IGuid guid);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="guid"></param>
        /// <returns></returns>
        int Update(IGuid guid);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="guid"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IGuid Get(GuidFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IGuid> GetList(GuidFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IGuid> GetPager(GuidFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IGuid GetByID(int id);
        #endregion
    }
}
