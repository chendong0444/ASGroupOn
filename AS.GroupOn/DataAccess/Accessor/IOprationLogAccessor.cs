using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.DataAccess.Accessor
{
   public interface IOprationLogAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="draw"></param>
        /// <returns></returns>
        int Insert(IOprationLog oprationlog);
        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="draw"></param>
        /// <returns></returns>
        int Update(IOprationLog oprationlog);
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
        IOprationLog Get(OprationLogFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IOprationLog> GetList(OprationLogFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPagers<IOprationLog> GetPager(OprationLogFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="Id"></param>
        /// <returns></returns>
       
     
    }
}
