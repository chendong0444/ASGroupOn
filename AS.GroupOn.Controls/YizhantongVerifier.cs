using System;
using System.Collections.Generic;
using System.Text;
using AS.Common.Utils;
using AS.Enum;
using AS.GroupOn.DataAccess;
using AS.GroupOn.Domain;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.App;
using System.Collections.Specialized;
using AS.GroupOn.Controls;
using System.Web;
using AS.ucenter;

namespace AS.Ucenter
{
    public class YizhantongVerifier
    {
        /// <summary>
        /// 一站通登录方法
        /// </summary>
        /// <param name="key">一站通用户名</param>
        /// <param name="qmail">一站通邮箱</param>
        /// <param name="YizhantongState">来源一站通名称</param>
        /// <param name="realname">真实姓名</param>
        /// <param name="refer">返回地址</param>
        /// <param name="ucenter">ucenter标识</param>
        /// <param name="pages">页面对象</param>
        public static void YizhantongLogin(string key, string username, string qmail, YizhantongState yizhantong, string realname, string ucenter, BasePage pages, string referurl)
        {
            key = Helper.GetString(key, String.Empty);
            if (key == String.Empty)
            {
                pages.Response.Redirect(UrlMapper.GetUrl("首页", "index.aspx"));
                return;
            }
            username = Helper.GetString(username, String.Empty);
            qmail = Helper.GetString(qmail, String.Empty);
            CookieUtils.SetCookie("fromdomain", yizhantong.ToString());
            if (qmail == String.Empty) qmail = key;//如果qmail为空。则把key当成qmail
            if (username == String.Empty) username = key;
            //一站通标识
            CookieUtils.SetCookie("yizhantong", "yizhantong");
            //真实姓名
            CookieUtils.SetCookie("realname", realname);
            //ucenter返回的对象
            RetrunClass retrunclass = null;
            //查出一站通的用户信息
            IUser iuser = null;
            IYizhantong iyizhantong = null;
            YizhantongFilters yztfilter = new YizhantongFilters();
            yztfilter.Name = key;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iyizhantong = session.Yizhantong.Get(yztfilter);
            }
            if (iyizhantong != null)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iuser = session.Users.GetByID(iyizhantong.userid);
                }
            }
            //判断此用户名是否存在,如果存在就是老用户，否则是新用户
            if (iuser != null)
            {

                if (iyizhantong != null)//是通过key验证来的
                {
                    //修改过的用户,进行ucenter的一系列验证
                    if (ucenter != null && ucenter == "1")
                    {
                        //启用了ucenter
                        ucenterVal(iuser, yizhantong.ToString(), retrunclass, key, pages);
                    }
                    else
                    {
                        //修改过的用户
                        CookieUtils.SetCookie("userid", iuser.Id.ToString(), FileUtils.GetKey(), null);
                        WebUtils.SetLoginUserCookie(iuser.Username.ToString(), true);
                        InviteLogin(iuser.Id);//一站通登录邀请返利
                        pages.SetSuccess("登录成功");
                        pages.LoginOK(Helper.GetInt(iuser.Id, 0)); //登陆成功后执行的方法
                        if (iuser.Manager.ToUpper() == "Y" || iuser.Id.ToString() == "1")
                            CookieUtils.SetCookie("admin", iuser.Id.ToString());
                        CookieUtils.SetCookie("fromdomain", yizhantong.ToString());
                        string gourl = "<script>window.location.href='" + ((referurl == String.Empty) ? pages.ResolveUrl(BasePage.GetRefer()) : referurl) + "';</script>";
                        HttpContext.Current.Response.Write(gourl);
                        HttpContext.Current.Response.End();
                    }
                }
                else  //不是通过key来的 并且是老用户
                {
                    if (ucenter != null && ucenter == "1")
                    {
                        //没有修改过的用户
                        //提交到修改个人资料页面
                        pages.SetError("请修改个人资料");
                        CookieUtils.SetCookie("key", DESEncrypt.Encrypt(key, BasePage.GetKey()));
                        CookieUtils.SetCookie("fromdomain", yizhantong.ToString());
                        CookieUtils.SetCookie("gourl", yizhantong.ToString());
                        CookieUtils.SetCookie("userid", DESEncrypt.Encrypt(iuser.Id.ToString(), BasePage.GetKey()));
                        HttpContext.Current.Response.Redirect(UrlMapper.GetUrl("UC用户绑定", "account_resetlogin.aspx"));
                        HttpContext.Current.Response.End();
                        return;
                    }
                    else
                    {
                        //没有修改过的用户
                        if (Helper.ValidateString(iuser.Email, "email") || WebUtils.config["logintongbinduser"] != "1")
                        {
                            //邮箱验证可通过
                            //验证通过则设置为已登录状态，并返回返回地址
                            IYizhantong iyzt = Store.CreateYizhantong();
                            iyzt.name = key;
                            iyzt.userid = iuser.Id;
                            int a = 0;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                a = session.Yizhantong.InsertYZT(iyzt);
                            }
                            if (a > 0)
                            {
                                CookieUtils.SetCookie("userid", iuser.Id.ToString(), FileUtils.GetKey(), null);
                                WebUtils.SetLoginUserCookie(iuser.Username.ToString(), true);
                                pages.LoginOK(Helper.GetInt(iuser.Id, 0)); //登陆成功后执行的方法
                                if (iuser.Manager.ToUpper() == "Y" || iuser.Id.ToString() == "1")
                                    CookieUtils.SetCookie("admin", iuser.Id.ToString());
                                InviteLogin(iuser.Id);//一站通登录邀请返利
                                pages.SetSuccess("登录成功");
                                CookieUtils.SetCookie("fromdomain", yizhantong.ToString());
                                HttpContext.Current.Response.Write("<script>window.location.href='" + ((referurl == String.Empty) ? pages.ResolveUrl(BasePage.GetRefer()) : referurl) + "';</script>");
                                HttpContext.Current.Response.End();
                                return;
                            }
                            else
                            {
                                pages.SetError("登录失败,请重新登录");
                                HttpContext.Current.Response.Redirect(UrlMapper.GetUrl("用户登录", "account_login.aspx"));
                                HttpContext.Current.Response.End();
                                return;
                            }

                        }
                        else //邮箱验证未通过并且开启了强制绑定
                        {
                            //邮箱验证未通过
                            //跳转到修改邮箱页面
                            pages.SetError("请绑定个人资料");
                            CookieUtils.SetCookie("key", DESEncrypt.Encrypt(key, BasePage.GetKey()));
                            CookieUtils.SetCookie("fromdomain", yizhantong.ToString());
                            CookieUtils.SetCookie("gourl", yizhantong.ToString());
                            CookieUtils.SetCookie("userid", DESEncrypt.Encrypt(iuser.Id.ToString(), BasePage.GetKey()));
                            HttpContext.Current.Response.Redirect(UrlMapper.GetUrl("UC用户绑定", "account_resetlogin.aspx"));
                            HttpContext.Current.Response.End();
                            return;
                        }
                    }
                }
            }
            else
            {

                if (WebUtils.config["logintongbinduser"] == "1" || WebUtils.config["UC_Islogin"] == "1")//如果开启强制绑定则
                {
                    //新用户,直接提交到注册的页面
                    CookieUtils.SetCookie("key", DESEncrypt.Encrypt(key, BasePage.GetKey()));
                    CookieUtils.SetCookie("gourl", yizhantong.ToString());
                    //跳转到修改个人资料页面
                    pages.SetError("请绑定个人资料");
                    HttpContext.Current.Response.Redirect(UrlMapper.GetUrl("一站通登录绑定", "account_resetNewlogin.aspx"));
                    HttpContext.Current.Response.End();
                }
                else //没有开启强制绑定则由系统自动注册 并写入key
                {
                    #region 注册用户
                    IUser userinfoModel = Store.CreateUser();
                    userinfoModel.Username = Helper.GetString(username, String.Empty);
                    userinfoModel.Email = Helper.GetString(qmail, String.Empty);
                    if (userinfoModel.Username == String.Empty)
                    {
                        userinfoModel.Username = key;
                    }
                    if (userinfoModel.Email == String.Empty)
                    {
                        userinfoModel.Email = key;
                    }
                    if (realname != null && realname != "")
                        userinfoModel.Realname = realname;

                    userinfoModel.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Helper.GetRandomString(10) + BasePage.PassWordKey, "md5");
                    userinfoModel.fromdomain = yizhantong.ToString();
                    userinfoModel.ucsyc = "nosyc";
                    userinfoModel.Enable = "Y";
                    userinfoModel.Avatar = PageValue.WebRoot + "upfile/img/man.jpg";
                    userinfoModel.IP_Address = CookieUtils.GetCookieValue("gourl");
                    userinfoModel.Create_time = DateTime.Now;
                    userinfoModel.Newbie = "N";
                    userinfoModel.Manager = "N";
                    userinfoModel.IP = WebUtils.GetClientIP;
                    userinfoModel.Login_time = DateTime.Now;
                    userinfoModel.userscore = 0;
                    userinfoModel.totalamount = 0;
                    userinfoModel.City_id = Helper.GetInt(PageValue.CurrentCity.Id, 0);
                    int userid = 0;
                    while (true)
                    {
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            userid = session.Users.Insert(userinfoModel);
                        }
                        if (userid > 0)
                        {
                            IYizhantong iyzt = Store.CreateYizhantong();
                            iyzt.name = key;
                            iyzt.userid = userid;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                session.Yizhantong.InsertYZT(iyzt);
                            }
                            break;
                        }
                        else//没有注册成功 可能有重名的帐号或邮箱。随机一下
                        {
                            userinfoModel.Username = userinfoModel.Username + Helper.GetRandomString(4);
                            userinfoModel.Email = userinfoModel.Email + Helper.GetRandomString(4);
                        }
                    }
                    InviteLogin(userid);//一站通登录邀请返利
                    pages.SetSuccess("登陆成功!");
                    //保存在cookie里面，设置为已登陆状态
                    CookieUtils.SetCookie("userid", userinfoModel.Id.ToString(), FileUtils.GetKey(), null);
                    WebUtils.SetLoginUserCookie(userinfoModel.Username.ToString(), true);
                    pages.LoginOK(userinfoModel.Id); //登陆成功后执行的方法
                    CookieUtils.ClearCookie("ucenter");
                    CookieUtils.ClearCookie("yizhantong");
                    CookieUtils.ClearCookie("key");
                    HttpContext.Current.Response.Write("<script>window.location.href='" + ((referurl == String.Empty) ? pages.ResolveUrl(BasePage.GetRefer()) : referurl) + "';</script>");
                    HttpContext.Current.Response.End();
                    #endregion

                }
            }
        }

        /// <summary>
        /// 同步登录的验证方法,只适用一站通
        /// </summary>
        /// <param name="dt">datatable对象</param>
        /// /// <param name="yizhantong">一站通类型</param>
        /// <param name="returnclass1">retrunclass</param>
        /// <param name="key">key</param>
        /// <param name="refer">返回的页面</param>
        /// <param name="bp">basepage对象</param>
        ///  /// <param name="pages">Page对象</param>
        public static void ucenterVal(IUser iuser, string fromyizhantong, RetrunClass returnclass1, string key, BasePage pages)
        {
            if (iuser.ucsyc.Trim() == "yessyc") //这个用户之前已经同步过ucenter
            {
                //登录ucenter
                if (Ucenter.getValue.getUsername(iuser.Username) == 1) //检测ucenter中是否存在此用户名
                {
                    //登录成功
                    //验证通过则设置为已登录状态，并返回返回地址
                    CookieUtils.SetCookie("userid", iuser.Id.ToString(), FileUtils.GetKey(), null);
                    WebUtils.SetLoginUserCookie(iuser.Username.ToString(), true);
                    pages.LoginOK(Helper.GetInt(iuser.Id, 0)); //登陆成功后执行的方法
                    if (iuser.Manager.ToUpper() == "Y" || iuser.Id.ToString() == "1")
                        CookieUtils.SetCookie("admin", iuser.Id.ToString());
                    InviteLogin(iuser.Id);//一站通登录邀请返利
                    pages.SetSuccess("登录成功");
                    CookieUtils.SetCookie("gourl", fromyizhantong);
                    returnclass1 = Ucenter.getValue.getLogin(iuser.Username, false); //取得用户信息，为了得到ucenter用户ID ,给同步登录做准备
                    if (returnclass1 == null)
                    {
                        NameValueCollection namevalue = new NameValueCollection();
                        namevalue.Add("UC_Islogin", "0");
                        WebUtils sysconfig = new WebUtils();
                        sysconfig.CreateSystemByNameCollection(namevalue);
                        pages.SetError("ucenter配置不正确,已自动关闭ucenter，请重新登录。");
                        HttpContext.Current.Response.Redirect(UrlMapper.GetUrl("用户登录", "account_login.aspx"));
                        HttpContext.Current.Response.End();
                        return;
                    }
                    HttpContext.Current.Response.Write(Ucenter.setValue.getsynlogin(returnclass1.Uid));//得到同步登陆代码
                    HttpContext.Current.Response.Write("<script>window.location.href='" + pages.ResolveUrl(BasePage.GetRefer()) + "'</script>");
                    HttpContext.Current.Response.End();
                }
                else
                {
                    //登录失败
                    //跳转到修改邮箱页面
                    pages.SetError("登录失败,请重新登录");
                    CookieUtils.SetCookie("key", DESEncrypt.Decrypt(key, BasePage.GetKey()));
                    CookieUtils.SetCookie("fromdomain", fromyizhantong);
                    CookieUtils.SetCookie("gourl", fromyizhantong);
                    HttpContext.Current.Response.Redirect(UrlMapper.GetUrl("用户登录", "account_login.aspx"));
                    HttpContext.Current.Response.End();
                }
            }
            else
            {
                //这个用户还没有同步过ucenter,需要重新绑定信息并进行同步
                pages.SetError("请绑定个人资料");
                CookieUtils.SetCookie("key", DESEncrypt.Encrypt(key, BasePage.GetKey()));
                CookieUtils.SetCookie("fromdomain", fromyizhantong);
                CookieUtils.SetCookie("gourl", fromyizhantong);
                CookieUtils.SetCookie("userid", DESEncrypt.Encrypt(iuser.Id.ToString(), BasePage.GetKey()));
                HttpContext.Current.Response.Redirect(UrlMapper.GetUrl("UC用户绑定", "account_resetlogin.aspx"));
                HttpContext.Current.Response.End();
            }

        }
        public static void InviteLogin(int id)
        {
            if (CookieUtils.GetCookieValue("invitor") != String.Empty)
            {
                if (id > 0)
                {
                    IInvite mInvite = Store.CreateInvite();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        mInvite.Create_time = DateTime.Now;
                        mInvite.User_id = int.Parse(CookieUtils.GetCookieValue("invitor"));
                        mInvite.Other_user_id = id;
                        mInvite.Other_user_ip = WebUtils.GetClientIP;
                        mInvite.Pay = "N";
                        session.Invite.Insert(mInvite);
                    }
                }
            }
        }
    }
}
