using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain.Spi;
using System.Data;
using AS.GroupOn.Domain;
using System.Collections;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
using AS.Common.Utils;
using AS.GroupOn.App;
using System.Collections.Specialized;

namespace AS.GroupOn.Controls
{
    public class CouponMethod
    {
        #region 根据订单ID返回已消费的优惠券数量
        public static int GetUseCouponCount(int orderid)
        {
            int count = 0;
            IList<ICoupon> couponlist = null;
            CouponFilter cf = new CouponFilter();
            cf.Consume = "Y";
            cf.Order_id = orderid;
            using (IDataSession session = Store.OpenSession(false))
            {
                couponlist = session.Coupon.GetList(cf);
            }
            if (couponlist != null)
                count = couponlist.Count;
            return count;
        }
        #endregion

        #region 根据订单ID返回未消费的优惠券数量
        public static int GetUnPayCouponCount(int orderid)
        {
            int count = 0;
            IList<ICoupon> couponlist = null;
            CouponFilter cf = new CouponFilter();
            cf.Consume = "N";
            cf.Order_id = orderid;
            using (IDataSession session = Store.OpenSession(false))
            {
                couponlist = session.Coupon.GetList(cf);
            }
            if (couponlist != null)
                count = couponlist.Count;
            return count;
        }
        #endregion

        #region 根据订单ID返回全部的优惠券数量
        public static int GetCouponCount(int orderid)
        {
            int count = 0;
            IList<ICoupon> couponlist = null;
            CouponFilter cf = new CouponFilter();
            cf.Order_id = orderid;
            using (IDataSession session = Store.OpenSession(false))
            {
                couponlist = session.Coupon.GetList(cf);
            }
            if (couponlist != null)
                count = couponlist.Count;
            return count;
        }
        #endregion
    }
}
