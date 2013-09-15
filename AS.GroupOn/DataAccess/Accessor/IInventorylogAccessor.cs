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
    public interface IInventorylogAccessor
    {
        #region IInventorylogAccessor成员
        /// <summary>
        /// 添加一条记录，返回其ID
        /// </summary>
        /// <param name="Inventorylog"></param>
        /// <returns></returns>
        int Insert(Iinventorylog Inventorylog);
        /// <summary>
        /// 修改一条记录，返回受影响的行数
        /// </summary>
        /// <param name="Inventorylog"></param>
        /// <returns></returns>
        int Update(Iinventorylog Inventorylog);
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
        Iinventorylog Get(InventorylogFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<Iinventorylog> GetList(InventorylogFilter filter);
        /// <summary>
        /// 返回指定页数的记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPagers<Iinventorylog> GetPager(InventorylogFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        Iinventorylog GetByID(int id);
        /// <summary>
        /// 返回指定条件的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(InventorylogFilter filter);
        #endregion
    }
}
