using System;
using System.Collections.Generic;
using System.Text;
using System.Net;
using System.IO;
using Module;

namespace SMS
{
    public class ChinaNetSMS : ISMS
    {
        /// <summary>
        /// 短信发送（中国电信短信通道）
        /// </summary>
        public bool SendSMS(string username, string password, string mobiles, string content)
        {
            string result = string.Empty;

            string url = "http://117.135.134.240/msg/HttpBatchSendSM?account={0}&pswd={1}&mobile={2}&msg={3}&needstatus=true";

            HttpWebRequest http = WebRequest.Create(string.Format(url, username, password, mobiles, content)) as HttpWebRequest;
            http.Method = "GET";
            http.ServicePoint.Expect100Continue = false;
            http.UserAgent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)";
            //if (Proxy != null)
            //{
            //    if (Proxy.Credentials != null)
            //    {
            //        http.UseDefaultCredentials = true;
            //    }
            //    http.Proxy = Proxy;
            //}


            try
            {
                using (WebResponse response = http.GetResponse())
                {
                    using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                    {
                        try
                        {
                            result = reader.ReadToEnd();
                            System.IO.File.WriteAllText(AppDomain.CurrentDomain.BaseDirectory + "sms.log", result);

                        }
                        catch (Exception ex)
                        {
                            System.IO.File.WriteAllText(AppDomain.CurrentDomain.BaseDirectory + "sms.log", ex.Message);
                        }
                        finally
                        {
                            reader.Close();
                        }
                    }
                    response.Close();
                }
            }
            catch (Exception ex)
            {
                System.IO.File.WriteAllText(AppDomain.CurrentDomain.BaseDirectory + "sms.log", ex.Message);
            }

            //电信返回的结果格式
            //20110725160412,0          //时间，状态0表示成功
            //1234567890100             //msgId
            if (!string.IsNullOrEmpty(result) && result.Split(',')[1].Substring(0,1)=="0")
            {
                return true;
            }
            return false;  
        }

        public bool ModifyPassword(string username, string oldpassword, string newpassword)
        {
            throw new NotImplementedException();
        }

        public decimal GetCredit(string username, string password)
        {
            throw new NotImplementedException();
        }

        public System.Data.DataTable GetJournal(string username, string password, int page)
        {
            throw new NotImplementedException();
        }

        public decimal GetPrice(string username, string password)
        {
            throw new NotImplementedException();
        }
    }
}
