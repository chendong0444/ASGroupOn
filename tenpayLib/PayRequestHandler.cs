using System;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Collections;

namespace tenpay
{
	/// <summary>
	/// PayRequestHandler ��ժҪ˵����
	/// </summary>
	/**
	* ��ʱ����������
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
			* ��ʼ��������Ĭ�ϸ�һЩ������ֵ����cmdno,date�ȡ�
		*/
		public override void init() 
		{

			//������� 
			this.setParameter("cmdno", "1");
		
			//����
            this.setParameter("time_start", DateTime.Now.ToString("yyyyMMddHHmmss"));
		
			//�̻���
            this.setParameter("partner", "");
		
			//�Ƹ�ͨ���׵���   
			this.setParameter("transaction_id", "");
		
			//�̼Ҷ�����
            this.setParameter("out_trade_no", "");
		
			//��Ʒ�۸��Է�Ϊ��λ
			this.setParameter("total_fee", "");
		
			//�������� 
			this.setParameter("fee_type",  "1");
		
			//����url
			this.setParameter("return_url",  "");
		
			//�Զ������
			this.setParameter("attach",  "");
		
			//�û�ip
            this.setParameter("spbill_create_ip", "");
		
			//��Ʒ����
            this.setParameter("subject", "");
		
			//���б���
			this.setParameter("bank_type",  "0");
		
			//�ַ�������
            this.setParameter("input_charset", "gb2312");
		


			//ժҪ   ? 
			this.setParameter("sign", "");
		}



		/**
	 * @Override
	 * ����ǩ��
	 */
		protected override void createSign() 
		{
		
			//��ȡ����
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
		
			//��֯ǩ��
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
			//���ժҪ
			string sign = MD5Util.GetMD5(sb.ToString(),getCharset()).ToLower();
				
			this.setParameter("sign", sign);
	
			//debug��Ϣ
			setDebugInfo(sb.ToString() + " => sign:"  + sign);
		
		}

	}
}
