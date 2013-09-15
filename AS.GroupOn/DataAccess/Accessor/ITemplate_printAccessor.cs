using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.DataAccess.Accessor
{
  public  interface ITemplate_printAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="ask"></param>
        /// <returns></returns>
      int Insert(ITemplate_print Template_print);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="ask"></param>
        /// <returns></returns>
      int Update(ITemplate_print Template_print);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="ask"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        ITemplate_print Get(Template_printFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ITemplate_print> GetList(Template_printFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<ITemplate_print> GetPager(Template_printFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ITemplate_print GetByID(int id);
        /// <summary>
        /// 返回指定条件的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(Template_printFilter filter);


    }
}
