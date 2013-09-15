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
    public interface IUserReivewAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="userReview"></param>
        /// <returns></returns>
        int Insert(IUserReview userReview);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="userReview"></param>
        /// <returns></returns>
        int Update(IUserReview userReview);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="userReview"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IUserReview Get(UserReviewFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IUserReview> GetList(UserReviewFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IUserReview> GetPager(UserReviewFilter filter);

        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IUserReview> GetPager2(UserReviewFilter filter);

        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IUserReview GetByID(int id);

       IList<IUserReview> GetByContent(UserReviewFilter filter);

       int GetTop1Id(UserReviewFilter filter);

       IPagers<IUserReview> GetPager3(UserReviewFilter filter);

    }
}
