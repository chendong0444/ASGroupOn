using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;

namespace AS.GroupOn.Domain.Spi
{
    public class Pay : Obj, IPay
    {
        /// <summary>
        /// 网银支付交易单号
        /// </summary>
        public virtual string Id { get; set; }
        /// <summary>
        /// 网站订单ID
        /// </summary>
        public virtual int Order_id { get; set; }
        /// <summary>
        /// 网银名称
        /// </summary>
        public virtual string Bank { get; set; }
        /// <summary>
        /// 支付金额
        /// </summary>
        public virtual decimal Money { get; set; }
        /// <summary>
        /// 币种 CNY or USD
        /// </summary>
        public virtual string Currency { get; set; }
        /// <summary>
        /// 付款方式(alipay:支付宝,yeepay:易宝,tenpay:财付通,chinabank:网银在线,credit:余额付款,cash:线下支付)
        /// </summary>
        public virtual string Service { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        public virtual DateTime Create_time { get; set; }

        private IOrder _order = null;
        /// <summary>
        /// 记录下面的订单
        /// </summary>
        public virtual IOrder Order
        {
            get
            {
                if (_order == null)
                {
                    using (IDataSession session = App.Store.OpenSession(false))
                    {
                        _order = session.Orders.GetByID(Order_id);
                    }
                }
                return _order;
            }
        }

    }
}
