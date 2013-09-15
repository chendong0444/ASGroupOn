using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;

namespace AS.GroupOn.Domain.Spi
{
    /// <summary>
    /// 创建者：zjq
    /// 时间：2012-10-24
    /// </summary>
    public class Branch:Obj,IBranch
    {
        /// <summary>
        /// 主键
        /// </summary>
        public virtual int id { get; set; }
        /// <summary>
        /// 商家ID
        /// </summary>
        public virtual int partnerid { get; set; }
        /// <summary>
        /// 分站名称
        /// </summary>
        public virtual string branchname { get; set; }
        /// <summary>
        /// 联系人
        /// </summary>
        public virtual string contact { get; set; }
        /// <summary>
        /// 联系电话
        /// </summary>
        public virtual string phone { get; set; }
        /// <summary>
        /// 联系地址
        /// </summary>
        public virtual string address { get; set; }
        /// <summary>
        /// 联系人手机
        /// </summary>
        public virtual string mobile { get; set; }
        /// <summary>
        /// 经纬度
        /// </summary>
        public virtual string point { get; set; }
        /// <summary>
        /// 消费密码
        /// </summary>
        public virtual string secret { get; set; }
        /// <summary>
        /// 分店登录名
        /// </summary>
        public virtual string username { get; set; }
        /// <summary>
        /// 分店密码
        /// </summary>
        public virtual string userpwd { get; set; }
        /// <summary>
        /// 400验证电话
        /// </summary>
        public virtual string verifymobile { get; set; }
        /// <summary>
        /// 返回商家名称
        /// </summary>
        private IPartner partner = null;
        public virtual IPartner getPartnerTitle
        {
            get 
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                {
                    partner = session.Partners.GetByID(this.partnerid);
                }
                return partner;
            }
        }
        /// <summary>
        /// 返回以消费优惠券数量
        /// </summary>
        private int coupon = 0;
        public virtual int GetYXJbyGroup 
        {
            get 
            {
                CouponFilter filter = new CouponFilter();
                filter.shoptypes = this.id;
                filter.Consume = "Y";
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
                {
                    coupon = session.Coupon.GetCount(filter);
                }
                return coupon;
            }
        
        }
    }
}
