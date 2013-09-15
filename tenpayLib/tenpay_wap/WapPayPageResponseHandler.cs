using System;
using System.Collections;
using System.Text;
using System.Web;

namespace Asdht.Wap.tenpay
{
	/// <summary>
	/// WapPayPageResponseHandler ��ժҪ˵����
	/// </summary>
	/**
	* wap֧��ҳ��Ӧ����
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
	public class WapPayPageResponseHandler:ResponseHandler
	{
		public WapPayPageResponseHandler(HttpContext httpContext) : base(httpContext)
		{
			//
			// TODO: �ڴ˴���ӹ��캯���߼�
			//
		}

		public override Boolean isTenpaySign() 
		{
			ArrayList akeys=new ArrayList(); 
			akeys.Add("attach");
			akeys.Add("bargainor_id");
			akeys.Add("charset");
			akeys.Add("fee_type"); 
			akeys.Add("pay_result"); 
			akeys.Add("sp_billno");
			akeys.Add("time_end");
			akeys.Add("total_fee");
			akeys.Add("transaction_id");
			akeys.Add("ver");

			akeys.Sort();

			return base._isTenpaySign(akeys);

		} 

	}
}
