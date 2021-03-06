﻿using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
   public interface ICatalogsAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="catalogs"></param>
        /// <returns></returns>
        int Insert(ICatalogs catalogs);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="catalogs"></param>
        /// <returns></returns>
        int Update(ICatalogs catalogs);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="catalogs"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        ICatalogs Get(CatalogsFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ICatalogs> GetList(CatalogsFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<ICatalogs> GetPager(CatalogsFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ICatalogs GetByID(int id);
       /// <summary>
       ///
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
        IList<ICatalogs> GetDetail(CatalogsFilter filter);

    }
}
