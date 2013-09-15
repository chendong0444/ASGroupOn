using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using AS.GroupOn;
using AS.GroupOn.Controls;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess.Accessor;
using AS.Common.Utils;
namespace AS.UserEvent
{
    public class Event
    {
        /// <summary>
        /// 后台管理登录页面
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="password">用户密码</param>
        /// <param name="checkcode">用户验证码</param>
        /// <returns></returns>
        public static JavaScriptResult LoginAdminUser(string username, string password, string checkcode, string type)
        {
            JavaScriptResult result = null;
            if (PageValue.CurrentSystemConfig["ischeckcode"] == null || PageValue.CurrentSystemConfig["ischeckcode"].ToString() != "0")
            {
                if (checkcode.ToLower() != WebUtils.GetCheckCode().ToLower())
                {
                    result = new JavaScriptResult("alert('请输入正确的验证码！');history.back();", true);
                    return result;
                }
            }
            switch (type)
            {
                case "admin":
                    result = adminLogin(username, password);
                    break;
                case "merchant":
                    result = merchantLogin(username, password);
                    break;
                case "sale":
                    result = saleLogin(username, password);
                    break;
                case "pbranch":
                    result = pbranchLogin(username, password);
                    break;
                default:
                    result = adminLogin(username, password);
                    break;
            }

            return result;
        }

        /// <summary>
        /// 管理员登录
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="pwd">密码</param>
        private static JavaScriptResult adminLogin(string username, string pwd)
        {
            JavaScriptResult jsr = null;
            UserFilter uf = new UserFilter();
            uf.Username = username;
            uf.Manager = "Y";
            IList<IUser> users = null;
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                users = session.Users.GetList(uf);
            }
            if (users != null)
            {
                if (users.Count > 0)
                {
                    if (users[0].Password == AS.Common.Utils.WebUtils.GetPasswordByMD5(pwd))
                    {
                        CookieUtils.SetCookie("userid", users[0].Id.ToString(), FileUtils.GetKey(), null);
                        CookieUtils.SetCookie("username", users[0].Username.ToString(), FileUtils.GetKey(), null);
                        WebUtils.SetLoginAdminUserCookie(users[0].Id, true);
                        if (users[0].IsManBranch == "Y")
                        {
                            CookieUtils.SetCookie("ManBranchAdminid", users[0].Id.ToString(), FileUtils.GetKey(), null);
                            jsr = new JavaScriptResult("alert('管理员分站登录成功！');document.location.href='" + PageValue.WebRoot + "ManBranch/index.aspx';", true);
                            return jsr;
                        }
                        else
                        {
                            jsr = new JavaScriptResult("alert('管理员登录成功！');document.location.href='" + PageValue.WebRoot + "manage/index.aspx';", true);
                            return jsr;
                        }
                    }
                    else
                    {
                        jsr = new JavaScriptResult("alert('您输入的密码错误,请您重新输入！');history.back();", true);
                        return jsr;
                    }
                }
                else
                {
                    jsr = new JavaScriptResult("alert('管理员不存在！');history.back();", true);
                    return jsr;
                }
            }
            else
            {
                jsr = new JavaScriptResult("alert('管理员不存在！');history.back();", true);
                return jsr;
            }
        }

        /// <summary>
        /// 商家登录
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="pwd">密码</param>
        private static JavaScriptResult merchantLogin(string username, string pwd)
        {
            JavaScriptResult jsr = null;
            PartnerFilter pf = new PartnerFilter();
            pf.Username = username;
            IList<IPartner> partners = null;
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                partners = session.Partners.GetList(pf);
            }
            if (partners != null)
            {
                if (partners.Count > 0)
                {
                    if (partners[0].Password == AS.Common.Utils.WebUtils.GetPasswordByMD5(pwd))
                    {
                        CookieUtils.SetCookie("partner", partners[0].Id.ToString(), FileUtils.GetKey(), null);
                        jsr = new JavaScriptResult("alert('商家登录成功！');document.location.href='" + PageValue.WebRoot + "biz/index.aspx';", true);
                        return jsr;
                    }
                    else
                    {
                        jsr = new JavaScriptResult("alert('您输入的密码错误,请您重新输入！');history.back();", true);
                        return jsr;
                    }
                }
                else
                {
                    jsr = new JavaScriptResult("alert('该商家不存在！');history.back();", true);
                    return jsr;
                }
            }
            else
            {
                jsr = new JavaScriptResult("alert('该商家不存在！');history.back();", true);
                return jsr;
            }

        }
        /// <summary>
        /// 商家分站登录
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="pwd">密码</param>
        private static JavaScriptResult pbranchLogin(string username, string pwd)
        {
            JavaScriptResult jsr = null;
            BranchFilter branch = new BranchFilter();
            branch.username = username;
            branch.userpwd = AS.Common.Utils.WebUtils.GetPasswordByMD5(pwd);
            IList<IBranch> branchs = null;
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                branchs = session.Branch.GetList(branch);
            }
            if (branchs != null)
            {
                if (branchs.Count > 0)
                {
                    if (branchs[0].userpwd == AS.Common.Utils.WebUtils.GetPasswordByMD5(pwd))
                    {
                        CookieUtils.SetCookie("pbranch", branchs[0].id.ToString(), FileUtils.GetKey(), null);
                        jsr = new JavaScriptResult("alert('商家分站登录成功！');document.location.href='" + PageValue.WebRoot + "partnerbranch/index.aspx';", true);
                        return jsr;
                    }
                    else
                    {
                        jsr = new JavaScriptResult("alert('您输入的密码错误,请您重新输入！');history.back();", true);
                        return jsr;
                    }
                }
                else
                {
                    jsr = new JavaScriptResult("alert('该用户不存在！');history.back();", true);
                    return jsr;
                }
            }
            else
            {
                jsr = new JavaScriptResult("alert('该用户不存在！');history.back();", true);
                return jsr;
            }
        }
        /// <summary>
        /// 销售后台登录
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="pwd">密码</param>
        private static JavaScriptResult saleLogin(string username, string pwd)
        {
            JavaScriptResult jsr = null;
            SalesFilter sale = new SalesFilter();
            sale.username = username;
            sale.password = pwd;
            IList<ISales> sales = null;
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                sales = session.Sales.GetList(sale);
            }
            if (sales != null)
            {
                if (sales.Count > 0)
                {
                    if (sales[0].password == pwd)
                    {
                        CookieUtils.SetCookie("sale", sales[0].id.ToString(), FileUtils.GetKey(), null);
                        jsr = new JavaScriptResult("alert('销售后台登录成功！');document.location.href='" + PageValue.WebRoot + "sale/index.aspx';", true);
                        return jsr;
                    }
                    else
                    {
                        jsr = new JavaScriptResult("alert('您输入的密码错误,请您重新输入！');history.back();", true);
                        return jsr;
                    }
                }
                else
                {
                    jsr = new JavaScriptResult("alert('该用户不存在！');history.back();", true);
                    return jsr;
                }
            }
            else
            {
                jsr = new JavaScriptResult("alert('该用户不存在！！');history.back();", true);
                return jsr;
            }
        }


    }
}
