using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Controls
{
   public class FrontUserPage:FrontPage
    {
       protected override void OnLoad(EventArgs e)
       {
           base.OnLoad(e);
           if (PageValue.CurrentUser == null)
           {
               //SetReffer();
               Response.Redirect(UrlMapper.GetUrl("登录","account_login.aspx?returnUrl="+Server.UrlEncode(PageValue.Url)));
           }
       }
    }
}
