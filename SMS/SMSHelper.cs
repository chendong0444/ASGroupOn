using System;
using System.Collections.Generic;
using System.Text;
using Module;
namespace SMS
{
   public class SMS:ISMS
    {


        #region ISMS 成员

        public bool SendSMS(string username, string password, string mobiles, string content)
        {
            bool ok = false;
            if (mobiles.Length > 0 && username.Length > 0 && password.Length > 0 && content.Length > 0)
            {
                string[] mobile_array = mobiles.Split(',');
                SMSHelper.SDKService sdk = new SMSHelper.SDKService();
                int result=sdk.sendSMS(username, password, String.Empty, mobile_array, content, String.Empty, "GBK", 5);
                if (result == 0)
                {
                    ok = true;
                }
            }
 
         return ok;
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
