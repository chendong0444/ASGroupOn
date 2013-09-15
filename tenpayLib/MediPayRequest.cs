using System;
using System.Text;
using System.Web;
using System.Web.UI;

namespace tenpay
{
	/// <summary>
	/// MediPayRequest 的摘要说明。
	/// </summary>
	/// 	
	/**
	* 中介担保请求类
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
	public class MediPayRequest:RequestHandler
	{
		public MediPayRequest(HttpContext httpContext) : base(httpContext)
		{
            this.setGateUrl("https://www.tenpay.com/cgi-bin/med/show_opentrans.cgi");
		}

		/**
			* @Override
			* 初始化函数，默认给一些参数赋值，如cmdno,date等。
		*/
		public override void init() 
		{

			//版本号
			this.setParameter("version", "2");
		
			//任务代码
			this.setParameter("cmdno","12");
		
			//编码类型
			this.setParameter("encode_type", "1");
		
			//平台提供者的财付通账号
			this.setParameter("chnid", "");
		
			//收款方财付通帐号
			this.setParameter("seller", "");
		
			//商品名称
			this.setParameter("mch_name", "");
		
			//商品总价
			this.setParameter("mch_price",  "1");
		
			//物流说明
			this.setParameter("transport_desc",  "");
		
			//物流费用
			this.setParameter("transport_fee",  "");
		
			//交易说明
			this.setParameter("mch_desc",  "");
		
			//是否需要在财付通显示物流信息
			this.setParameter("need_buyerinfo",  "");
		
			//交易类型
			this.setParameter("mch_type",  "");
		
			//商户订单号
			this.setParameter("mch_vno","");

			//返回url
			this.setParameter("mch_returl","");

			//支付结果显示页面
			this.setParameter("show_url","");

			//自定义参数
			this.setParameter("attach","");
		
			//摘要
			this.setParameter("sign", "");
		}


		

	}
}
