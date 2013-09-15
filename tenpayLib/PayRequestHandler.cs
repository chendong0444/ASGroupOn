using System;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Collections;

namespace tenpay
{
	/// <summary>
	/// PayRequestHandler 的摘要说明。
	/// </summary>
	/**
	* 即时到帐请求类
	* ============================================================================
	* api说明：
	* init(),初始化函数，默认给一些参数赋值，如cmdno,date等。
	* getGateURL()/setGateURL(),获取/设置入口地址,不包含参数值
	* getKey()/setKey(),获取/设置密钥
	* getParameter()/setParameter(),获取/设置参数值
	* getAllParameters(),获取所有参数
	* getRequestURL(),获取带参数的请求URL
	* doSend(),重定向到财付通支付
	* getDebugInfo(),获取debug信息
	* 
	* ============================================================================
	*
	*/
	public class PayRequestHandler:RequestHandler
	{
		public PayRequestHandler(HttpContext httpContext) : base(httpContext)
		{
			
			//this.setGateUrl("http://service.tenpay.com/cgi-bin/v3.0/payservice.cgi");
            this.setGateUrl("https://www.tenpay.com/cgi-bin/v1.0/service_gate.cgi");
            //this.setGateUrl("https://gw.tenpay.com/gateway/pay.htm");
		}


		/**
			* @Override
			* 初始化函数，默认给一些参数赋值，如cmdno,date等。
		*/
		public override void init() 
		{

			//任务代码 
			this.setParameter("cmdno", "1");
		
			//日期
            this.setParameter("time_start", DateTime.Now.ToString("yyyyMMddHHmmss"));
		
			//商户号
            this.setParameter("partner", "");
		
			//财付通交易单号   
			this.setParameter("transaction_id", "");
		
			//商家订单号
            this.setParameter("out_trade_no", "");
		
			//商品价格，以分为单位
			this.setParameter("total_fee", "");
		
			//货币类型 
			this.setParameter("fee_type",  "1");
		
			//返回url
			this.setParameter("return_url",  "");
		
			//自定义参数
			this.setParameter("attach",  "");
		
			//用户ip
            this.setParameter("spbill_create_ip", "");
		
			//商品名称
            this.setParameter("subject", "");
		
			//银行编码
			this.setParameter("bank_type",  "0");
		
			//字符集编码
            this.setParameter("input_charset", "gb2312");
		


			//摘要   ? 
			this.setParameter("sign", "");
		}



		/**
	 * @Override
	 * 创建签名
	 */
		protected override void createSign() 
		{
		
			//获取参数
            //string cmdno = getParameter("cmdno");
            //string date = getParameter("time_start");
            //string bargainor_id = getParameter("partner");
            //string transaction_id = getParameter("transaction_id");
            //string sp_billno = getParameter("out_trade_no");
            //string total_fee = getParameter("total_fee");
            //string fee_type = getParameter("fee_type");
            //string return_url = getParameter("return_url");
            //string attach = getParameter("attach");
            //string spbill_create_ip = getParameter("spbill_create_ip");
            //string key = getParameter("key");
		
			//组织签名
			StringBuilder sb = new StringBuilder();
            //sb.Append("cmdno=" + cmdno + "&");
            //sb.Append("time_start=" + date + "&");
            //sb.Append("partner=" + bargainor_id + "&");
            //sb.Append("transaction_id=" + transaction_id + "&");
            //sb.Append("out_trade_no=" + sp_billno + "&");
            //sb.Append("total_fee=" + total_fee + "&");
            //sb.Append("fee_type=" + fee_type + "&");
            //sb.Append("return_url=" + return_url + "&");
            //sb.Append("attach=" + attach + "&");
            //if( !"".Equals(spbill_create_ip) ) 
            //{
            //    sb.Append("spbill_create_ip=" + spbill_create_ip + "&");
            //}
            /////
            ArrayList akeys = new ArrayList(parameters.Keys);
            akeys.Sort();
            foreach (string k in akeys)
            {
                string v = (string)parameters[k];
                if (null != v && "".CompareTo(v) != 0
                    && "sign".CompareTo(k) != 0 && "key".CompareTo(k) != 0)
                {
                    sb.Append(k + "=" + v + "&");
                }
            }
            /////
			sb.Append("key=" + getKey());
			//算出摘要
			string sign = MD5Util.GetMD5(sb.ToString(),getCharset()).ToLower();
				
			this.setParameter("sign", sign);
	
			//debug信息
			setDebugInfo(sb.ToString() + " => sign:"  + sign);
		
		}

	}
}
