using System;
using System.Collections.Generic;
using System.Text;

namespace AS.GroupOn.Controls
{
    public class SalePage : BasePage
    {
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            if (!IsSaleAdmin)
            {
                Response.Write("<script>alert('销售后台帐号已失效，请重新登录！');document.location.href='" + GetUrl("后台管理", "Login.aspx?type=sale") + "';</script>");
                Response.End();
            }
        }
        /// <summary>
        /// 判断当前商户管理员是否登录
        /// </summary>
        public static bool IsSaleAdmin
        {
            get
            {
                if (AS.Common.Utils.WebUtils.GetSaleAdminID() > 0)
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
