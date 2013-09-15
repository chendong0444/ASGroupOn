using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.DataAccess.Filters
{
   public  class MailserviceproviderFilter:FilterBase
    {
       public const string ID_ASC = "id asc";
       public const string ID_DESC = "id desc";

       public int? id { get; set; }
       public int? mailtasks_id { get; set; }
    }
}
