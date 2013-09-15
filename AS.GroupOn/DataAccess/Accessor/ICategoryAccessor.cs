using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
    /// <summary>
    /// zjq
    /// 2012-10-29
    /// </summary>
    public interface ICategoryAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="card"></param>
        /// <returns></returns>
        int Insert(ICategory Category);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="card"></param>
        /// <returns></returns>
        int Update(ICategory Category);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="card"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        ICategory Get(CategoryFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ICategory> GetList(CategoryFilter filter);
        /// <summary>
        /// 返回首字母列表记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ICategory> GetletterList(CategoryFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<ICategory> GetPager(CategoryFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ICategory GetByID(int id);
        /// <summary>
        /// 判断是否存在
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        bool getCount1(int id);

        /// <summary>
        //得到快递公司
        IList<ICategory> GetByExpress(CategoryFilter filter);

        IList<ICategory> GetByCashExpress(CategoryFilter filter);

        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ICategory> SelsectByzd(CategoryFilter filter);
        /// <summary>
        /// 根据自定义分组更新数据
        /// </summary>
        /// <param name="Category"></param>
        /// <returns></returns>
        int UpByCzone(ICategory Category);

        ICategory SelectById(int id);

        int exts_proc_del_api(int id);
    }
}




