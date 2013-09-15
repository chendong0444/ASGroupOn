using System;
using System.Collections.Generic;
using System.Text;
using System.Web;
namespace AS.Common.Utils
{
   public class SessionHelper
    {
       public static object GetSession(string name)
       {
          object obj = null;
          obj= HttpContext.Current.Session[name];
          return obj;
       }

       public static void SetSession(string name, object val)
       {
           HttpContext.Current.Session.Remove(name);
           HttpContext.Current.Session.Add(name, val);
       }
       public static void RemoveSession(string name)
       {
           HttpContext.Current.Session.Remove(name);
       }
    }
}
