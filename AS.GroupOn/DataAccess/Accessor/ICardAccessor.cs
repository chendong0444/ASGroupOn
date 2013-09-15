using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using System.Collections;
namespace AS.GroupOn.DataAccess.Accessor
{
   public interface ICardAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="card"></param>
        /// <returns></returns>
        int Insert(ICard card);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="card"></param>
        /// <returns></returns>
        int Update(ICard card);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="card"></param>
        /// <returns></returns>
        int Delete(string id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        ICard Get(CardFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ICard> GetList(CardFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<ICard> GetPager(CardFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ICard GetByID(string id);

        Hashtable CardDown(CardFilter filter);

        /// <summary>
        /// 红包筛选
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<ICard> GetPagerHBShaiXuan(CardFilter filter);
        /// <summary>
        /// 红包筛选
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<ICard> GetPagerHBShaiXuanTid(CardFilter filter);

        IList<ICard> GetList(string filter);

        IPagers<ICard> GetMobilCard(CardFilter filter);
    }
}
