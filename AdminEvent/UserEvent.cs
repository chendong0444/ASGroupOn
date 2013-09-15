using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.Controls;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.DataAccess.Accessor;
using AS.Common.Utils;
using System.Web;
using AS.GroupOn.Domain.Spi;
using AS.GroupOn.DataAccess;
using AS.GroupOn.App;
using AS.Common;
namespace AS.AdminEvent
{

    /// <summary>
    /// 用户后台事件
    /// </summary>
    public class UserEvent
    {
        private static RedirctResult result = null;
        int i = 0;
        public JavaScriptResult DeleteUser(string formname, int id)
        {
            JavaScriptResult result = null;
            ////判断管理员是否有此操作
            //if(AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_User_Delete))
            //{
            //     result = new JavaScriptResult("alert('您不具备删除用户的权限!');",true);
            //    return result;

            //}

            return result;
        }
        #region  编辑用户信息
        /// <summary>
        /// 编辑用户信息
        /// </summary>
        /// <param name="user_id">ID号</param>
        /// <param name="Email">邮箱</param>
        /// <param name="Username">用户名</param>
        /// <param name="Realname">真实姓名</param>
        /// <param name="Qq">QQ</param>
        /// <param name="Password">密码</param>
        /// <param name="Zipcode">邮编</param>
        /// <param name="Address">地址</param>
        /// <param name="Mobile">手机</param>
        /// <param name="Enable">激活状态</param>
        /// <param name="Secret">邮件验证码</param>
        /// <param name="Manager">管理状态</param>
        /// <returns></returns>
        public RedirctResult Update_UserInfo(string Email, string Username, string Realname, string Qq, string Password, string Zipcode, string Address, string Mobile, string Enable, string Secret, string Manager, int user_id)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_User_Edit))
            {
                PageValue.SetMessage(new ShowMessageResult("你没有修改用户信息的权限", false, false));
                result = new RedirctResult("index_index.aspx", true);
                return result;
            }
            else
            {
                IUser user = new User();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    user = session.Users.GetByID(user_id);
                }
                user.Id = user_id;
                user.Email = Email;
                user.Username = Username;
                //判断修改之后的用户名是否已存在
                IList<IUser> UserList = null;
                UserFilter userfilter = new UserFilter();
                userfilter.AddSortOrder(UserFilter.ID_DESC);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    UserList = session.Users.GetList(userfilter);
                }
                if (UserList != null)
                {
                    foreach (IUser item in UserList)
                    {
                        if (item.Id != user_id && item.Username == Username)
                        {
                            PageValue.SetMessage(new ShowMessageResult("用户名已存在", false, false));
                            result = new RedirctResult("User.aspx", true);
                            return result;
                        }
                    }
                }
                user.Realname = Realname;
                user.Qq = Qq;
                if (!string.IsNullOrEmpty(Password))
                {
                    //user.Password =WebUtils.GetPasswordByMD5(Password);
                    user.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Password + BasePage.PassWordKey, "md5");
                }
                user.Zipcode = Zipcode;
                user.Address = Address;
                user.Mobile = Mobile;
                user.Enable = Enable.ToUpper();
                user.Secret = Secret;
                user.Manager = Manager.ToUpper();

                int count = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    count = session.Users.UpdateUser(user);
                }
                if (count > 0)
                    PageValue.SetMessage(new ShowMessageResult("修改成功", true, true));
                else
                    PageValue.SetMessage(new ShowMessageResult("修改失败", false, false));
                result = new RedirctResult("User.aspx", true);
            }
            return result;
        }
        #endregion

        public RedirctResult InsertUser(string leveName, decimal maxmoney, decimal minmoney, double discount, int sort_order)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_UserLeve_Add))
            {
                PageValue.SetMessage(new ShowMessageResult("你没有新建用户等级的权限", false, false));
                result = new RedirctResult("index_index.aspx", true);
                return result;
            }
            else
            {
                ICategory cgory = null;
                CategoryFilter cfilter = new CategoryFilter();
                cfilter.Name = leveName;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    cgory = session.Category.Get(cfilter);
                }
                if (cgory != null)
                {
                    if (leveName == cgory.Name)
                    {
                        result = new RedirctResult("Type_YonghuDengji.aspx?dengji=true", true);
                        return result;
                    }
                }
                ICategory category = new Category();
                category.Name = leveName;
                category.Zone = "grade";
                category.Display = "Y";
                category.Sort_order = sort_order;
                int leveid = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    leveid = session.Category.Insert(category);
                }
                if (leveid > 0)
                {
                    IUserlevelrules userlevelrules = new Userlevelrules();
                    userlevelrules.levelid = AS.Common.Utils.Helper.GetInt(leveid, 0);
                    userlevelrules.maxmoney = AS.Common.Utils.Helper.GetDecimal(maxmoney, 0);
                    userlevelrules.minmoney = AS.Common.Utils.Helper.GetDecimal(minmoney, 0);
                    userlevelrules.discount = AS.Common.Utils.Helper.GetDouble(discount, 0);

                    int userleveid = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        userleveid = session.Userlevelrelus.Insert(userlevelrules);
                    }
                    if (userleveid > 0)
                        PageValue.SetMessage(new ShowMessageResult("添加成功", true, true));
                    else
                        PageValue.SetMessage(new ShowMessageResult("添加失败", false, false));
                    result = new RedirctResult("Type_YonghuDengji.aspx", true);
                }

            }
            return result;
        }
        public RedirctResult UpdateUserlevelrules(string leveName, decimal maxmoney, decimal minmoney, double discount, int sort_order, int userleveid, int leveid)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_UserLeve_Edit))
            {
                PageValue.SetMessage(new ShowMessageResult("你没有编辑用户等级的权限", false, false));
                result = new RedirctResult("index_index.aspx", true);
                return result;
            }
            else
            {
                IUserlevelrules userlevelrule = new Userlevelrules();
                userlevelrule.maxmoney = AS.Common.Utils.Helper.GetDecimal(maxmoney, 0);
                userlevelrule.minmoney = AS.Common.Utils.Helper.GetDecimal(minmoney, 0);
                userlevelrule.discount = AS.Common.Utils.Helper.GetDouble(discount, 0);
                userlevelrule.id = AS.Common.Utils.Helper.GetInt(userleveid, 0);
                userlevelrule.levelid = AS.Common.Utils.Helper.GetInt(leveid, 0);
                int ids = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ids = session.Userlevelrelus.Update(userlevelrule);
                }
                if (ids > 0)
                {
                    ICategory cfilters = new Category();
                    cfilters.Id = leveid;
                    cfilters.Name = leveName;
                    cfilters.Sort_order = sort_order;
                    cfilters.Zone = "grade";
                    cfilters.Display = "Y";
                    int counts = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        counts = session.Category.Update(cfilters);
                    }
                    if (counts > 0)
                        PageValue.SetMessage(new ShowMessageResult("修改成功", true, true));
                    else
                        PageValue.SetMessage(new ShowMessageResult("修改失败", false, false));
                    result = new RedirctResult("Type_YonghuDengji.aspx", true);
                }
            }
            return result;

        }




        #region 添加角色
        /// <summary>
        /// 添加角色
        /// </summary>
        /// <param name="rolename">角色名称</param>
        /// <param name="code">简称</param>
        /// <returns></returns>
        public RedirctResult AddRole(string rolename, string code)
        {
            IRole role = Store.CreateRole();
            role.rolename = rolename;
            role.code = code;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.Role.Insert(role);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("添加成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("添加失败", false, false));
            result = new RedirctResult("User_Roles.aspx", true);
            return result;
        }
        /// <summary>
        /// 编辑角色信息
        /// </summary>
        /// <param name="rolename"></param>
        /// <param name="code"></param>
        /// <param name="id"></param>
        /// <returns></returns>
        public RedirctResult UpdateRole(string rolename, string code, int id)
        {
            IRole role = Store.CreateRole();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                role.rolename = rolename;
                role.code = code;
                role.Id = id;
                i = session.Role.Update(role);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("更新成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("更新失败", false, false));
            result = new RedirctResult("User_Roles.aspx", true);
            return result;
        }
        /// <summary>
        /// 编辑管理员信息
        /// </summary>
        /// <param name="email">邮箱</param>
        /// <param name="username">用户名</param>
        /// <param name="realname">真实姓名</param>
        /// <param name="qq">QQ</param>
        /// <param name="password">密码</param>
        /// <param name="zipcode">邮编</param>
        /// <param name="address">地址</param>
        /// <param name="mobile">手机</param>
        /// <param name="enablevalue">是否激活</param>
        /// <param name="secret">邮件验证码</param>
        /// <param name="manager">是否有管理权限</param>
        /// <param name="id">ID</param>
        /// <returns></returns>
        public RedirctResult UpdateUser(string email, string username, string realname, string qq, string password, string zipcode, string address, string mobile, string enablevalue, string secret, string manager, int id)
        {
            IUser users = Store.CreateUser();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                users = session.Users.GetByID(id);

                if (!string.IsNullOrEmpty(password))
                {
                    users.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(password + BasePage.PassWordKey, "md5");
                }
                users.Email = email;
                users.Username = username;
                users.Realname = realname;
                users.Qq = qq;
                users.Zipcode = zipcode;
                users.Address = address;
                users.Mobile = mobile;
                users.Enable = enablevalue.ToUpper();
                users.Secret = secret;
                users.Manager = manager.ToUpper();
                users.Id = id;
                i = session.Users.UpdateUserInfo(users);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("更新成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("更新失败", false, false));
            result = new RedirctResult("User_guanliyuanbiao.aspx", true);
            return result;
        }

        /// <summary>
        /// 编辑销售人员信息
        /// </summary>
        /// <param name="username">用户名</param>
        /// <param name="realname">真实姓名</param>
        /// <param name="password">密码</param>
        /// <param name="contact">联系电话</param>
        /// <param name="id">ID</param>
        /// <returns></returns>

        public RedirctResult ChangeSales(string username, string realname, string password, string contact, int id)
        {
            ISales sales = Store.CreateSales();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                if (string.IsNullOrEmpty(password))
                {
                    sales = session.Sales.GetByID(id);
                    password = sales.password;
                }
                else
                {
                    sales.password = password;
                }
                sales.username = username;
                sales.realname = realname;
                sales.contact = contact;
                sales.id = id;
                i = session.Sales.Update(sales);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("更新成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("更新失败", false, false));
            result = new RedirctResult("User_Sale.aspx", true);
            return result;
        }
        /// <summary>
        /// 新建销售人员信息
        /// </summary>
        ///<param name="username">用户名</param>
        /// <param name="realname">真实姓名</param>
        /// <param name="password">密码</param>
        /// <param name="contact">联系电话</param>
        /// <returns></returns>
        public RedirctResult AddSales(string username, string realname, string password, string contact)
        {
            ISales sales = Store.CreateSales();
            sales.username = username;
            sales.realname = realname;
            sales.contact = contact;
            sales.password = password;

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.Sales.Insert(sales);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("添加成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("添加失败", false, false));
            result = new RedirctResult("User_Sale.aspx", true);
            return result;

        }
        /// <summary>
        /// 添加商城导航栏目
        /// </summary>
        /// <param name="title">栏目标题</param>
        /// <param name="url">栏目链接地址</param>
        /// <param name="guidsort">栏目排序</param>
        /// <param name="openguid">显示状态</param>
        /// <param name="openparent">新窗口打开</param>
        /// <returns></returns>
        public RedirctResult AddGuid(string title, string url, int guidsort, int openguid, int openparent, int teamormall)
        {
            teamormall = 1;
            IGuid guid = Store.CreateGuid();
            guid.guidtitle = title;
            guid.guidlink = url;
            guid.guidsort = guidsort;
            guid.guidopen = openguid;
            guid.guidparent = openparent;
            guid.teamormall = teamormall;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.Guid.Insert(guid);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("添加成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("添加失败", false, false));
            result = new RedirctResult("Shezhi_GuidList_mall.aspx", true);
            return result;
        }
        /// <summary>
        /// 编辑商城导航栏目
        /// </summary>
        /// <param name="title">栏目标题</param>
        /// <param name="url">栏目链接地址</param>
        /// <param name="guidsort">栏目排序</param>
        /// <param name="openguid">显示状态</param>
        /// <param name="openparent">新窗口打开</param>
        /// <param name="id">ID</param>
        /// <returns></returns>
        public RedirctResult UpdateGuid(string title, string url, int guidsort, int openguid, int openparent, int id)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_MallGuid_Edit))
            {
                PageValue.SetMessage(new ShowMessageResult("您不具备编辑商城导航栏目的权限", false, false));
                result = new RedirctResult("index_index.aspx", true);
                return result;
            }

            IGuid guid = Store.CreateGuid();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                guid = session.Guid.GetByID(id);
                guid.guidtitle = title;
                guid.guidlink = url;
                guid.guidsort = guidsort;
                guid.guidopen = openguid;
                guid.guidparent = openparent;
                guid.id = id;
                i = session.Guid.Update(guid);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("更新成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("更新失败", false, false));
            result = new RedirctResult("Shezhi_GuidList_mall.aspx", true);
            return result;
        }
        /// <summary>
        /// 添加团购导航栏目
        /// </summary>
        /// <param name="title">栏目标题</param>
        /// <param name="url">栏目链接地址</param>
        /// <param name="guidsort">栏目排序</param>
        /// <param name="openguid">显示状态</param>
        /// <param name="openparent">新窗口打开</param>
        /// <returns></returns>
        public RedirctResult AddTgGuid(string title, string url, int guidsort, int openguid, int openparent, int teamormall)
        {

            IGuid guid = Store.CreateGuid();
            guid.guidtitle = title;
            guid.guidlink = url;
            guid.guidsort = guidsort;
            guid.guidopen = openguid;
            guid.guidparent = openparent;
            guid.teamormall = teamormall;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.Guid.Insert(guid);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("添加成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("添加失败", false, false));
            result = new RedirctResult("Shezhi_GuidList.aspx", true);
            return result;
        }
        /// <summary>
        /// 编辑团购导航栏目
        /// </summary>
        /// <param name="title">栏目标题</param>
        /// <param name="url">栏目链接地址</param>
        /// <param name="guidsort">栏目排序</param>
        /// <param name="openguid">显示状态</param>
        /// <param name="openparent">新窗口打开</param>
        /// <param name="id">ID</param>
        /// <returns></returns>
        public RedirctResult UpdateTgGuid(string title, string url, int guidsort, int openguid, int openparent, int id)
        {
            IGuid guid = Store.CreateGuid();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                guid = session.Guid.GetByID(id);
                guid.guidtitle = title;
                guid.guidlink = url;
                guid.guidsort = guidsort;
                guid.guidopen = openguid;
                guid.guidparent = openparent;
                guid.id = id;
                i = session.Guid.Update(guid);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("更新成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("更新失败", false, false));
            result = new RedirctResult("Shezhi_GuidList.aspx", true);
            return result;
        }
        /// <summary>
        /// 管理员授权
        /// </summary>
        /// <param name="auth"></param>
        /// <param name="id"></param>
        /// <returns></returns>
        public RedirctResult UpdatePower(string auth, int id)
        {
            IUser user = Store.CreateUser();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                user = session.Users.GetByID(id);
            }
            if (auth != String.Empty)
            {
                IRole role = Store.CreateRole();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    role = session.Role.SelectCode(Convert.ToInt32(auth));
                }
                auth = "{" + role.code + "}";
            }
            user.auth = auth;
            user.Id = id;
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.Users.UpdateAuth(user);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("设置成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("设置失败", false, false));
            result = new RedirctResult("User_guanliyuanbiao.aspx", true);
            return result;
        }

        /// <summary>
        /// 管理员分站 管理员授权
        /// </summary>
        /// <param name="city">管理城市ID</param>
        /// <param name="userid">用户ID</param>
        /// <returns></returns>
        public RedirctResult qdadminfz(int city, int userid)
        {
            if (city == 0)
            {
                PageValue.SetMessage(new ShowMessageResult("未进行操作保持原来状态", false, false));
                result = new RedirctResult("User_guanliyuanbiao.aspx", true);
            }
            else
            {
                IUser user = Store.CreateUser();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    user = session.Users.GetByID(userid);
                }
                user.City_id = city;
                user.IsManBranch = "Y";
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    i = session.Users.Update(user);
                }
                if (i > 0)
                    PageValue.SetMessage(new ShowMessageResult("设置成功", true, true));
                else
                    PageValue.SetMessage(new ShowMessageResult("设置失败", false, false));
                result = new RedirctResult("User_guanliyuanbiao.aspx", true);
            }
            return result;
        }
        /// <summary>
        /// 管理员分站 取消管理员授权
        /// </summary>
        /// <param name="city">管理城市ID</param>
        /// <param name="userid">用户ID</param>
        /// <returns></returns>
        public RedirctResult qxadminfz(int city, int userid)
        {
            IUser user = Store.CreateUser();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                user = session.Users.GetByID(userid);
            }
            user.IsManBranch = "N";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.Users.Update(user);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("取消成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("取消失败", false, false));
            result = new RedirctResult("User_guanliyuanbiao.aspx", true);
            return result;
        }
        /// <summary>
        /// 编辑管理员信息
        /// </summary>
        /// <param name="email">邮箱</param>
        /// <param name="username">用户名</param>
        /// <param name="realname">真实姓名</param>
        /// <param name="qq">QQ</param>
        /// <param name="zipcode">邮编</param>
        /// <param name="address">地址</param>
        /// <param name="mobile">手机</param>
        /// <param name="id">ID</param>
        /// <returns></returns>
        public RedirctResult UpdateUser1(string email, string username, string realname, string qq, string zipcode, string address, string mobile, int id)
        {
            IUser users = Store.CreateUser();

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                users = session.Users.GetByID(id);

                users.Email = email;
                users.Username = username;
                users.Realname = realname;
                users.Qq = qq;
                users.Zipcode = zipcode;
                users.Address = address;
                users.Mobile = mobile;
                users.Id = id;
                i = session.Users.UpdateUserInfo(users);
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("修改成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("修改失败", false, false));
            result = new RedirctResult("PersonalInfo.aspx?id="+id, true);
            return result;
        }

        /// <summary>
        /// 修改密码
        /// </summary>
        /// <param name="email">邮箱</param>
        /// <param name="username">用户名</param>
        /// <param name="password">登录密码</param>
        /// <param name="newpwd">新密码</param>
        /// <param name="confirmpwd">确认新密码</param>
        /// <param name="id">ID</param>
        /// <returns></returns>
        public RedirctResult UpdatePwd(string email, string username, string password, string newpwd, string confirmpwd, int id)
        {
            IUser users = Store.CreateUser();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                if (newpwd != String.Empty && confirmpwd != String.Empty)
                {
                    if (newpwd != confirmpwd)
                    {
                        PageValue.SetMessage(new ShowMessageResult("两次密码不一致", false, false));
                        result = new RedirctResult("ChangePWD.aspx?id=" + id, true);
                    }
                    else
                    {

                        users = session.Users.GetByID(id);
                        users.Email = email;
                        users.Username = username;
                        users.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(newpwd + BasePage.PassWordKey, "md5");
                        i = session.Users.UpdateUserInfo(users);
                    }
                }
                else if (newpwd != String.Empty || confirmpwd != String.Empty)
                {
                    PageValue.SetMessage(new ShowMessageResult("两次密码不一致", false, false));
                    result = new RedirctResult("ChangePWD.aspx?id=" + id, true);
                }
                else
                {
                    users.Password = password;
                    i = session.Users.UpdateUserInfo(users);
                }
            }
            if (i > 0)
                PageValue.SetMessage(new ShowMessageResult("修改成功", true, true));
            else
                PageValue.SetMessage(new ShowMessageResult("修改失败", false, false));
            result = new RedirctResult("ChangePWD.aspx?id="+id, true);
            return result;

        }
        #endregion

        public RedirctResult BindTeam(string teamid, int saleid)
        {
            //ISales sales = Store.CreateSales();
            //string teamids = "";
            int scuesscount = 0;
            string fail = "";
            ITeam teammodel = Store.CreateTeam();

            if (teamid != null && teamid != "")
            {
                string[] ids = teamid.Split(',');
                for (int i = 0; i < ids.Length; i++)
                {
                    int tid = Helper.GetInt(ids[i].ToString().Trim(), 0);
                    //teammodel = team.GetModel(tid);
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        teammodel = session.Teams.GetByID(tid);
                    }


                    if (ids[i].ToString().Trim() != "" && tid > 0 && teammodel != null)
                    {
                        //根据teamid将sale_id更新到team表中

                        teammodel.Id = tid;
                        teammodel.sale_id = saleid;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int a = session.Teams.UpdateSaleid(teammodel);
                        }
                        //根据项目id找到商户id；如果该项目有商户，将销售id更新到商户表中
                        if (teammodel.Partner_id != 0)
                        {
                            IPartner partner = Store.CreatePartner();
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                partner = session.Partners.GetByID(teammodel.Partner_id);
                            }
                            if (partner != null)
                            {
                                if (!string.IsNullOrEmpty(partner.saleid))
                                {
                                    int aa = 0;
                                    if (partner.saleid.ToString().Contains("," + saleid.ToString()) || partner.saleid.ToString().Contains(saleid.ToString() + ",") || partner.saleid.ToString().Contains(saleid.ToString()))
                                    {
                                        aa = 1;
                                    }
                                    if (aa == 0)
                                    {
                                        partner.saleid = partner.saleid + "," + saleid.ToString();
                                    }

                                }
                                else
                                {
                                    partner.saleid = saleid.ToString();
                                }
                            }
                            partner.Id = teammodel.Partner_id;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                session.Partners.UpdateSaleid(partner);
                            }
                        }

                        scuesscount++;
                    }
                    else
                    {
                        fail = ids[i].ToString();
                    }
                }
                PageValue.SetMessage(new ShowMessageResult("绑定完毕！共绑定" + scuesscount + "个项目id,失败" + (ids.Length - scuesscount) + "个", true, true));
                result = new RedirctResult("User_Sale.aspx", true);
            }
            else
            {
                PageValue.SetMessage(new ShowMessageResult("请输入项目id，多个用逗号分隔！", true, true));
                result = new RedirctResult("User_Sale.aspx", true);
            }
            return result;
        }
    }

}
