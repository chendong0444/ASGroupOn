using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using System.Collections;
namespace AS.GroupOn.DataAccess.Accessor
{
   public  interface IOrderDetailAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="orderdetail"></param>
        /// <returns></returns>
        int Insert(IOrderDetail orderdetail);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="orderdetail"></param>
        /// <returns></returns>
        int Update(IOrderDetail orderdetail);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="orderdetail"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IOrderDetail Get(OrderDetailFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IOrderDetail> GetList(OrderDetailFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IOrderDetail> GetPager(OrderDetailFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IOrderDetail GetByID(int id);

        IList<IOrderDetail> GetByOrder_ID(int id);

        int GetByOrderid_team(int id);

        IList<IOrderDetail> GetDetailTeam(OrderDetailFilter filter);

        int GetDetailCount(OrderDetailFilter filter);

        int GetBuyCount2(OrderDetailFilter filter);

        int UpdateOrderScore(IOrderDetail orderdetail);

        IList<Hashtable> GetPartnerNum(OrderDetailFilter filter);

        //IOrderDetail GetPartnerNum(OrderDetailFilter filter);
    }
}
