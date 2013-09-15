using System;
using System.Collections;
using System.Text;
using System.Web;

namespace tenpay
{
	/// <summary>
	/// MediPayResponse ��ժҪ˵����
	/// </summary>
	/**
	* �н鵣��Ӧ����
	* ============================================================================
	* api˵����
	* getKey()/setKey(),��ȡ/������Կ
	* getParameter()/setParameter(),��ȡ/���ò���ֵ
	* getAllParameters(),��ȡ���в���
	* isTenpaySign(),�Ƿ�Ƹ�ͨǩ��,true:�� false:��
	* doShow(),��ʾ������
	* getDebugInfo(),��ȡdebug��Ϣ
	* 
	* ============================================================================
	*
	*/	
	public class MediPayResponse:ResponseHandler
	{
		public MediPayResponse(HttpContext httpContext) : base(httpContext)
		{
			//
			// TODO: �ڴ˴���ӹ��캯���߼�
			//
		}

		/**
			* �Ƿ�Ƹ�ͨǩ��
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
			
			//debug��Ϣ
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
