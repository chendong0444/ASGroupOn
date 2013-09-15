using System;
using System.Collections.Generic;
using System.Text;

namespace ASDHTSMS
{
   public class SMS:Module.ISMS
    {
        #region ISMS 成员

        public bool SendSMS(string username, string password, string mobiles, string content)
        {
            bool result = false;
            try
            {
                ASDHTSMSService.parametersOperate sms = new ASDHTSMSService.parametersOperate();
               result=sms.SendSMS(username, password, content, mobiles);
            }
            catch(Exception ex) {
                System.IO.File.WriteAllText(AppDomain.CurrentDomain.BaseDirectory + "sms.log", ex.Message);
            }
            return result;
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

        #endregion
    }
}
