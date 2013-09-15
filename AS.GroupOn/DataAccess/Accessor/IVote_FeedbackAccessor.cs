/* ***********************************************
 * Author		:  lzmj
 * Date		:  2012-10-24 
 * ***********************************************/
using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.DataAccess.Accessor
{
   public  interface IVote_FeedbackAccessor
    {
       /// <summary>
       /// 插入一条数据，返回其ID
       /// </summary>
       /// <param name="vote_Feedback"></param>
       /// <returns></returns>
       int Insert(IVote_Feedback vote_Feedback);
       /// <summary>
       /// 更新一条记录，返回受影响行数
       /// </summary>
       /// <param name="vote_Feedback"></param>
       /// <returns></returns>
       int Update(IVote_Feedback vote_Feedback);
       /// <summary>
       /// 删除一条数据，返回受影响的行数
       /// </summary>
       /// <param name="Id"></param>
       /// <returns></returns>
       int Delete(int Id);
       /// <summary>
       /// 返回符合条件的一条记录
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
       IVote_Feedback Get(Vote_FeedbackFilters filter);
       /// <summary>
       /// 返回符合条件的一组记录
       /// </summary>
       /// <param name="filter"></param>
       /// <returns></returns>
       IList<IVote_Feedback> GetList(Vote_FeedbackFilters filter);
       /// <summary>
       /// 返回指定页的记录数
       /// </summary>
       /// <param name="filter"></param>
       /// <param name="pageSize"></param>
       /// <param name="currentPage"></param>
       /// <returns></returns>
       IPagers<IVote_Feedback> GetPager(Vote_FeedbackFilters filter);
       /// <summary>
       /// 返回指定ID的记录
       /// </summary>
       /// <param name="id"></param>
       /// <returns></returns>
       IVote_Feedback GetByID(int id);




    }
}
