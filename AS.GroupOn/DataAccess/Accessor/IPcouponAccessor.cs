using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
namespace AS.GroupOn.DataAccess.Accessor
{
    /// <summary>
    /// 创建者：drl
    /// 创建时间：2012-10-24
    /// 修改：(日期+修改人)
    /// 内容：站外优惠劵
    /// </summary>
    public interface IPcouponAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="pcoupon"></param>
        /// <returns></returns>
        int Insert(IPcoupon pcoupon);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="pcoupon"></param>
        /// <returns></returns>
        int Update(IPcoupon pcoupon);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="pcoupon"></param>
        /// <returns></returns>
        int Delete(int id);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IPcoupon Get(PcouponFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<IPcoupon> GetList(PcouponFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<IPcoupon> GetPager(PcouponFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        IPcoupon GetByID(int id);
        /// <summary>
        /// 返回指定条件的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int GetCount(PcouponFilter filter);

        int SelectCount(PcouponFilter filter);

        int SelById1(PcouponFilter filter);

        int SelById2(PcouponFilter filter);

        int SelById3(PcouponFilter filter);

        IPagers<IPcoupon> GetPager2(PcouponFilter filter);

        IPagers<IPcoupon> PagerPcoupon(PcouponFilter filter);
    }
}
