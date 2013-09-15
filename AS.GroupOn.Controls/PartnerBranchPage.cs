using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.Common.Utils;
using AS.GroupOn.Domain.Spi;
using System.Collections.Specialized;

namespace AS.GroupOn.Controls
{
    public class PartnerBranchPage : BasePage
    {
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            if (!IsPartnerBranchAdmin)
            {
                Response.Write("<script>alert('管理员帐号已失效，请重新登录！');document.location.href='" + GetUrl("后台管理", "Login.aspx") + "';</script>");
                Response.End();
            }
        }
        /// <summary>
        /// 判断当前商户管理员是否登录
        /// </summary>
        public static bool IsPartnerBranchAdmin
        {
            get
            {
                if (AS.Common.Utils.WebUtils.GetPartnerBranchAdminID() > 0)
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
