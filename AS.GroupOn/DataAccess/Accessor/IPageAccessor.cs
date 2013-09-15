using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
    public interface IPageAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="page"></param>
        /// <returns></returns>
        void Insert(IPage page);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="page"></param>
        /// <returns></returns>
        int Update(IPage page);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="page"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPage Get(PageFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IPage> GetList(PageFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IPage> GetPager(PageFilter filter);
        /// <summary>
        /// 返回指定页的记录数 inner jion Team 
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IPage> GetPagerTm(PageFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IPage GetByID(string id);
    }
}
