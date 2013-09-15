using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using System.Collections;
namespace AS.GroupOn.DataAccess.Accessor
{
    public interface ICouponAccessor
    {
        /// <summary>
        /// 写入一条记录，返回其ID
        /// </summary>
        /// <param name="coupon"></param>
        /// <returns></returns>
        int Insert(ICoupon coupon);

        /// <summary>
        /// 更新一条记录，返回受影响行数
        /// </summary>
        /// <param name="coupon"></param>
        /// <returns></returns>
        int Update(ICoupon coupon);
        /// <summary>
        /// 删除一条记录，返回受影响行数
        /// </summary>
        /// <param name="coupon"></param>
        /// <returns></returns>
        int Delete(string id);
        /// <summary>
        /// 根据券号和密码删除一条记录,返回受影响的行数
        /// </summary>
        /// <param name="fileter"></param>
        /// <returns></returns>
        int Delete(CouponFilter fileter);
        /// <summary>
        /// 返回符合条件的一条记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        ICoupon Get(CouponFilter filter);
        /// <summary>
        /// 返回符合条件的一组记录
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        IList<ICoupon> GetList(CouponFilter filter);
        /// <summary>
        /// 返回指定页的记录数
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="pageSize"></param>
        /// <param name="currentPage"></param>
        /// <returns></returns>
        IPagers<ICoupon> GetPager(CouponFilter filter);
        /// <summary>
        /// 返回指定ID的记录
        /// </summary>
        /// <param name="id"></param>
        /// <returns></returns>
        ICoupon GetByID(string id);
        /// <summary>
        /// 返回数量
        /// </summary>
        /// <param name="filter"></param>
        /// <returns></returns>
        int CouponNumber(CouponFilter filter);

        int GetCount(CouponFilter filter);

        int SelectCount(CouponFilter filter);

        int SelById1(CouponFilter filter);

        int SelById2(CouponFilter filter);

        int SelById3(CouponFilter filter);

        IPagers<ICoupon> GetPager2(CouponFilter filter);

        int UpdateCoupon(ICoupon coupon);

        int UpCoupon(ICoupon coupon);

        int UpdateShoptypes(ICoupon coupon);

        IPagers<ICoupon> PagerCoupon(CouponFilter filter);
    }
}
