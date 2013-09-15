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
    public interface  ILocationAccessor
    {
        #region ILocationAccessor成员
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="Location"></param>
        /// <returns></returns>
        int Insert(ILocation Location);
        /// <summary>
        /// 更新一条记录，返回受影响的行数
        /// </summary>
        /// <param name="Location"></param>
        /// <returns></returns>
        int Update(ILocation Location);
        /// <summary>
        /// 删除一条记录，返回受影响的行数
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        ILocation Get(LocationFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ILocation> GetList(LocationFilter filter);
        /// <summary>
        /// 返回指定页数的记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPagers<ILocation>GetPager(LocationFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ILocation GetByID(int id);
        /// <summary>
        /// 返回指定条件的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(LocationFilter filter);
        #endregion
    }
}
