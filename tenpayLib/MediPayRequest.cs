using System;
using System.Text;
using System.Web;
using System.Web.UI;

namespace tenpay
{
	/// <summary>
	/// MediPayRequest ��ժҪ˵����
	/// </summary>
	/// 	
	/**
	* �н鵣��������
	* ============================================================================
	* api˵����
	* init(),��ʼ��������Ĭ�ϸ�һЩ������ֵ����cmdno,date�ȡ�
	* getGateURL()/setGateURL(),��ȡ/������ڵ�ַ,����������ֵ
	* getKey()/setKey(),��ȡ/������Կ
	* getParameter()/setParameter(),��ȡ/���ò���ֵ
	* getAllParameters(),��ȡ���в���
	* getRequestURL(),��ȡ������������URL
	* doSend(),�ض��򵽲Ƹ�֧ͨ��
	* getDebugInfo(),��ȡdebug��Ϣ
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
			* ��ʼ��������Ĭ�ϸ�һЩ������ֵ����cmdno,date�ȡ�
		*/
		public override void init() 
		{

			//�汾��
			this.setParameter("version", "2");
		
			//�������
			this.setParameter("cmdno","12");
		
			//��������
			this.setParameter("encode_type", "1");
		
			//ƽ̨�ṩ�ߵĲƸ�ͨ�˺�
			this.setParameter("chnid", "");
		
			//�տ�Ƹ�ͨ�ʺ�
			this.setParameter("seller", "");
		
			//��Ʒ����
			this.setParameter("mch_name", "");
		
			//��Ʒ�ܼ�
			this.setParameter("mch_price",  "1");
		
			//����˵��
			this.setParameter("transport_desc",  "");
		
			//��������
			this.setParameter("transport_fee",  "");
		
			//����˵��
			this.setParameter("mch_desc",  "");
		
			//�Ƿ���Ҫ�ڲƸ�ͨ��ʾ������Ϣ
			this.setParameter("need_buyerinfo",  "");
		
			//��������
			this.setParameter("mch_type",  "");
		
			//�̻�������
			this.setParameter("mch_vno","");

			//����url
			this.setParameter("mch_returl","");

			//֧�������ʾҳ��
			this.setParameter("show_url","");

			//�Զ������
			this.setParameter("attach","");
		
			//ժҪ
			this.setParameter("sign", "");
		}


		

	}
}
