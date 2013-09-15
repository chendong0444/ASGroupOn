using System;
using System.Collections;
using System.Text;
using System.Web;

namespace tenpay
{
	/// <summary>
	/// PayResponseHandler ��ժҪ˵����
	/// </summary>
	/**
	* ��ʱ����Ӧ����
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
	public class PayResponseHandler:ResponseHandler
	{
		public PayResponseHandler(HttpContext httpContext) : base(httpContext)
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
		
			//��ȡ����
			string cmdno = getParameter("cmdno");
			string pay_result = getParameter("pay_result");
			string date = getParameter("date");
			string transaction_id = getParameter("transaction_id");
			string sp_billno = getParameter("sp_billno");
			string total_fee = getParameter("total_fee");		
			string fee_type = getParameter("fee_type");
			string attach = getParameter("attach");
			string tenpaySign = getParameter("sign").ToUpper();
			string key = this.getKey();
			
			//��֯ǩ����
			StringBuilder sb = new StringBuilder();
			sb.Append("cmdno=" + cmdno + "&");
			sb.Append("pay_result=" + pay_result + "&");
			sb.Append("date=" + date + "&");
			sb.Append("transaction_id=" + transaction_id + "&");
			sb.Append("sp_billno=" + sp_billno + "&");
			sb.Append("total_fee=" + total_fee + "&");
			sb.Append("fee_type=" + fee_type + "&");
			sb.Append("attach=" + attach + "&");
			sb.Append("key=" + key);
		
			//���ժҪ
			string sign = MD5Util.GetMD5(sb.ToString(),getCharset());	

			//debug��Ϣ
			setDebugInfo(sb.ToString() + " => sign:" + sign +
				" tenpaySign:" + tenpaySign);
		
			 return sign.Equals(tenpaySign);
		} 
	
	
	}
}
