using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.DataAccess.Accessor
{
   public interface ITopicAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="Topic"></param>
        /// <returns></returns>
       int Insert(ITopic Topic);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="Topic"></param>
        /// <returns></returns>
        int Update(ITopic Topic);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="Topic"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        ITopic Get(TopicFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ITopic> GetList(TopicFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<ITopic> GetPager(TopicFilter filter);
       /// <summary>
       /// 分页（讨论区）
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
        IPagers<ITopic> GetByPage(TopicFilter filter);
           /// <summary>
           /// 
           /// </summary>
           /// <param name="filter"></param>
           /// <returns></returns>
        IPagers<ITopic> GetByPageS(TopicFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ITopic GetByID(int id);
        /// <summary>
        /// 返回指定条件的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(TopicFilter filter);
        //返回符合条件的行数
        int GetCounts(TopicFilter filter);

    }
}
