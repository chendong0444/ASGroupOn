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
    public interface IVote_Feedback_InputAccessor
    {
        /// <summary>
        /// 增加一条记录，返回其ID
        /// </summary>
        /// <param name="vote_feedback_input"></param>
        /// <returns></returns>
        int Insert(IVote_Feedback_Input vote_feedback_input);
        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="vote_feedback_input"></param>
        /// <returns></returns>
        int Update(IVote_Feedback_Input vote_feedback_input);
        /// <summary>
        /// 删除一条数据，返回受影响行数
        /// </summary>
        /// <param name="Id"></param>
        /// <returns></returns>
        int Delete(int Id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IVote_Feedback_Input Get(Vote_Feedback_InputFilters filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IVote_Feedback_Input> GetList(Vote_Feedback_InputFilters filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IVote_Feedback_Input> GetPager(Vote_Feedback_InputFilters filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IVote_Feedback_Input GetByID(int id);
    }
}
