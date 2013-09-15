using System;
using System.Collections;
using System.Text;
using System.Web;

namespace tenpay
{
	/// <summary>
	/// MediPayResponse 的摘要说明。
	/// </summary>
	/**
	* 中介担保应答类
	* ============================================================================
	* api说明：
	* getKey()/setKey(),获取/设置密钥
	* getParameter()/setParameter(),获取/设置参数值
	* getAllParameters(),获取所有参数
	* isTenpaySign(),是否财付通签名,true:是 false:否
	* doShow(),显示处理结果
	* getDebugInfo(),获取debug信息
	* 
	* ============================================================================
	*
	*/	
	public class MediPayResponse:ResponseHandler
	{
		public MediPayResponse(HttpContext httpContext) : base(httpContext)
		{
			//
			// TODO: 在此处添加构造函数逻辑
			//
		}

		/**
			* 是否财付通签名
			* @Override
			* @return boolean
		*/
		
		public override Boolean isTenpaySign() 
		{
		
			

			StringBuilder sb = new StringBuilder();

			ArrayList akeys=new ArrayList(); 
			akeys.Add("attach");
			akeys.Add("buyer_id");
			akeys.Add("cft_tid");
			akeys.Add("chnid");
			akeys.Add("cmdno");
			akeys.Add("mch_vno");
			akeys.Add("retcode");
			akeys.Add("seller");
			akeys.Add("status");
			akeys.Add("total_fee");
			akeys.Add("trade_price");
			akeys.Add("transport_fee");
			akeys.Add("version");
			akeys.Sort();

			foreach(string k in akeys)
			{
				string v = (string)parameters[k];
				if(null != v && "".CompareTo(v) != 0
					&& "sign".CompareTo(k) != 0 && "key".CompareTo(k) != 0) 
				{
					sb.Append(k + "=" + v + "&");
				}
			}

			sb.Append("key=" + this.getKey());
			string sign = MD5Util.GetMD5(sb.ToString(),getCharset());
			
			//debug信息
			this.setDebugInfo(sb.ToString() + " => sign:" + sign);
			return getParameter("sign").Equals(sign); 
			
		} 
		

		public void doShow()
		{
			string strHtml = "<html><head>\r\n" +
				"<meta name=\"TENCENT_ONLINE_PAYMENT\" content=\"China TENCENT\">\r\n" +
				"</head><body></body></html>";

			this.httpContext.Response.Write(strHtml);

			this.httpContext.Response.End();			
		}
	}
}
