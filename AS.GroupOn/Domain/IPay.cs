using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Domain
{
    public interface IPay : IObj
    {
        /// <summary>
        /// 网银支付交易单号
        /// </summary>
        string Id { get; set; }
        /// <summary>
        /// 网站订单ID
        /// </summary>
        int Order_id { get; set; }
        /// <summary>
        /// 网银名称
        /// </summary>
        string Bank { get; set; }
        /// <summary>
        /// 支付金额
        /// </summary>
        decimal Money { get; set; }
        /// <summary>
        /// 币种 CNY or USD
        /// </summary>
        string Currency { get; set; }
        /// <summary>
        /// 付款方式(alipay:支付宝,yeepay:易宝,tenpay:财付通,chinabank:网银在线,credit:余额付款,cash:线下支付)
        /// </summary>
        string Service { get; set; }
        /// <summary>
        /// 生成时间
        /// </summary>
        DateTime Create_time { get; set; }

        /// <summary>
        /// 记录下面的订单
        /// </summary>
        IOrder Order { get; }

    }
}
