using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Controls
{
    public class PartnerPage : BasePage
    {
       protected override void OnLoad(EventArgs e)
       {
           base.OnLoad(e);
           if (!IsPartnerAdmin)
           {
               Response.Write("<script>alert('商家后台帐号已失效，请重新登录！');document.location.href='" + GetUrl("后台管理", "Login.aspx") + "';</script>");
               Response.End();
           }
       }
       /// <summary>
       /// 判断当前商户管理员是否登录
       /// </summary>
       public static bool IsPartnerAdmin
       {
           get
           {
               if (AS.Common.Utils.WebUtils.GetPartnerAdminID() > 0)
               {
                   return true;
               }
               else
               {
                   return false;
               }

           }
       }

    }
}
