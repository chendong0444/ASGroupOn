using System;
using System.Web;
using System.Text;
using System.Text.RegularExpressions;
using AS.GroupOn.Controls;
using System.Collections.Generic;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain.Spi;
using AS.GroupOn.Domain;

namespace AS.GroupOn.Controls
{
    public class ChinaNetSMSWraper
    {

        public static bool SendSMS(List<string> phone, string content)
        {
            bool ok = EmailMethod.SendSMS(phone, content);

            try
            {
                //保存电信通道的短信
                ISystem system = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    system = session.System.GetByID(1);
                }

                if (ok && system.smsuser == "jiukuan") //smsuser=jiukuan说明是电信通道的短信
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        ISmsLog smsLog = new SmsLog();
                        smsLog.Content = content;
                        smsLog.Mobiles = string.Join(",", phone.ToArray());
                        smsLog.SendTime = DateTime.Now;

                        session.SmsLog.Insert(smsLog);
                    }
                }
            }
            catch (Exception ex)
            {
                System.IO.File.WriteAllText(AppDomain.CurrentDomain.BaseDirectory + "sms.log", ex.Message);
            }

            return ok;

        }


    }
}
