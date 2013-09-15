using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
   public interface IMenuAccessor
    {
       /// <summary>
       /// 写入一条记录，返回其ID
       /// </summary>
       /// <param name="Menu"></param>
       /// <returns></returns>
       int Insert(IMenu Menu);
       /// <summary>
       /// 更新一条记录，返回受影响的行数
       /// </summary>
       /// <param name="Menu"></param>
       /// <returns></returns>
       int Update(IMenu Menu);
       /// <summary>
       /// 删除一条记录，返回受影响的行数
       /// </summary>
       /// <param name="Menu"></param>
       /// <returns></returns>
       int Delete(int id);
       /// <summary>
       /// 返回符合条件的一条记录
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
       IMenu Get(MenuFilter filter);
       /// <summary>
       /// 返回符合条件的一组记录
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
       IList<IMenu> GetList(MenuFilter filter);
       /// <summary>
       /// 返回指定也的记录数
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
       IPagers<IMenu> GetPager(MenuFilter filter);
       /// <summary>
       /// 返回指定ID的记录
       /// </summary>
       /// <param name="id"></param>
       /// <returns></returns>
       IMenu GetByID(int id);
       /// <summary>
       /// 返回指定条件的记录数
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
       int GetCount(MenuFilter filter);
    }
}
