using System;
using System.Collections.Generic;
using System.Text;
using AS.GroupOn.DataAccess;
using AS.GroupOn.DataAccess.Filters;
using AS.GroupOn.Domain;
using System.Web;
using AS.Common.Utils;
using System.Collections.Specialized;
namespace AS.GroupOn.Events
{
   public class UserEvent
    {
       /// <summary>
       /// 用户登录
       /// </summary>
       /// <param name="username">用户名</param>
       /// <param name="password">密码</param>
       /// <param name="autologin">是否自动登录</param>
       /// <returns></returns>
       public static EventResult UserLogin(string username, string password, bool autologin)
       {
           EventResult eResult = new EventResult();
           if (String.IsNullOrEmpty(username))
           {
               eResult.Message = "用户名不能为空";
               eResult.Result = false;
               return eResult;
           }
           if (String.IsNullOrEmpty(password))
           {
               eResult.Message = "密码不能为空";
               eResult.Result = false;
               return eResult;
           }
           UserFilter userFilter=new UserFilter();
           userFilter.AddSortOrder(UserFilter.ID_ASC);
           userFilter.Username=username;
           userFilter.Password=AS.Common.Utils.StringUtils.MD5(password+AS.Common.Utils.WebUtils.PassWordKey());
           IUser user=null;
           using (IDataSession session = App.Store.OpenSession(false))
           {
              user= session.Users.Get(userFilter);
           }
           if (user == null)
           {
               userFilter = new UserFilter();
               userFilter.AddSortOrder(UserFilter.ID_ASC);
               userFilter.Email = username;
               userFilter.Password = AS.Common.Utils.StringUtils.MD5(password + AS.Common.Utils.WebUtils.PassWordKey());
               using (IDataSession session = App.Store.OpenSession(false))
               {
                   user = session.Users.Get(userFilter);
               }
               if (user == null)
               {
                   eResult.Message = "用户名或密码不正确!!!";
                   eResult.Result = false;
               }
               else
               {
                   WebUtils.SetLoginUserCookie(user.Username, false);
                   if (user.Manager.ToUpper() == "Y")
                       WebUtils.SetLoginAdminUserCookie(user.Id, false);
                   if (autologin)
                   {
                       Utils.CookieHelper.SetCookie("user", username,System.DateTime.Now.AddDays(365),true);
                       Utils.CookieHelper.SetCookie("byguserpd", password, System.DateTime.Now.AddDays(365), true);
                   }
                   else
                   {
                       Utils.CookieHelper.ClearCookie("user");
                       Utils.CookieHelper.ClearCookie("byguserpd");
                   }
                   eResult.Object = user;
                   eResult.Message = "登陆成功";
                   eResult.Result = true;
               }
           }
           else
           {
               WebUtils.SetLoginUserCookie(user.Username, false);
               if (user.Manager.ToUpper() == "Y")
                   WebUtils.SetLoginAdminUserCookie(user.Id, false);
               if (autologin)
               {
                   Utils.CookieHelper.SetCookie("user", username, System.DateTime.Now.AddDays(365), true);
                   Utils.CookieHelper.SetCookie("byguserpd", password, System.DateTime.Now.AddDays(365), true);
               }
               else
               {
                   Utils.CookieHelper.ClearCookie("user");
                   Utils.CookieHelper.ClearCookie("byguserpd");
               }
               eResult.Object = user;
               eResult.Message = "登陆成功";
               eResult.Result = true;
           }
           return eResult;

           /////设置cookie
       }

       /// <summary>
       /// 用户注册
       /// </summary>
       /// <param name="email"></param>
       /// <param name="username"></param>
       /// <param name="password"></param>
       /// <param name="repassword"></param>
       /// <param name="mobile"></param>
       /// <param name="cityid"></param>
       /// <param name="subscribe"></param>
       /// <param name="regTime"></param>
       /// <param name="regIP"></param>
       /// <param name="fromDomain"></param>
       /// <param name="IP_Address"></param>
       /// <returns></returns>
       public static EventResult UserRegister(string email, string username, string password, string repassword, string mobile, int cityid, bool subscribe, DateTime regTime, string regIP, string fromDomain, string IP_Address)
       {
           EventResult eResult = new EventResult();
           if (String.IsNullOrEmpty(email))
           {
               eResult.Result = false;
               eResult.Message = "Email不能为空";
               return eResult;
           }
           if (!AS.Common.Utils.StringUtils.ValidateString(email, "email"))
           {
               eResult.Result = false;
               eResult.Message = "Email格式不正确";
               return eResult;
           }
           if (AS.Common.Utils.StringUtils.GetStringByteLength(email) > 128)
           {
               eResult.Result = false;
               eResult.Message = "Email长度不正确,应小于128字节";
               return eResult;
           }
           if (String.IsNullOrEmpty(username))
           {
               eResult.Result = false;
               eResult.Message = "用户名不能为空";
               return eResult;
           }
           if (username.Length < 4 || username.Length > 16)
           {
               eResult.Result = false;
               eResult.Message = "用户名长度请控制在4-16个字符";
               return eResult;
           }
           if (AS.Common.Utils.StringUtils.GetStringByteLength(username) > 128)
           {
               eResult.Result = false;
               eResult.Message = "用户名长度不正确,应小于500字节";
               return eResult;
           }
           if (!AS.Common.Utils.StringUtils.ValidateString(username, "username"))
           {
               eResult.Result = false;
               eResult.Message = "用户名格式不正确,应为数字、英文或中文字符";
               return eResult;
           }
           if (String.IsNullOrEmpty(password))
           {
               eResult.Result = false;
               eResult.Message = "密码不能为空";
               return eResult;
           }
           if (password != repassword)
           {
               eResult.Result = false;
               eResult.Message = "两次输入的密码不一致";
               return eResult;
           }
           if (String.IsNullOrEmpty(mobile))
           {
               eResult.Result = false;
               eResult.Message = "手机号不能为空";
               return eResult;
           }
           if (!AS.Common.Utils.StringUtils.ValidateString(mobile, "mobile"))
           {
               eResult.Result = false;
               eResult.Message = "手机号码格式不正确";
               return eResult;
           }

           UserFilter userFilter = new UserFilter();
           userFilter.LoginName = email;
           IUser user = null;
           using (IDataSession session = App.Store.OpenSession(false))
           {
               user = session.Users.Get(userFilter);
           }
           if (user != null)
           {
               eResult.Result = false;
               eResult.Message = "当前Email已存在，请更换";
               return eResult;
           }
           userFilter.LoginName = username;
           using (IDataSession session = App.Store.OpenSession(false))
           {
               user = session.Users.Get(userFilter);
           }
           if (user != null)
           {
               eResult.Result = false;
               eResult.Message = "当前用户名已存在，请更换";
               return eResult;
           }

           user = App.Store.CreateUser();
           user.City_id = cityid;
           user.Username = username;
           user.Create_time = regTime;
           user.Email = email;
           user.Enable = "N";
           user.fromdomain = fromDomain;
           user.Gender = "男";
           user.IP = regIP;
           user.Avatar = "/upfile/img/man.jpg";
           user.Login_time = regTime;
           user.Manager = "N";
           user.Mobile = mobile;
           user.Password = AS.Common.Utils.StringUtils.MD5(password + AS.Common.Utils.WebUtils.PassWordKey());
           user.ucsyc = "nosyc";
           user.IP_Address = IP_Address;
           int userID = 0;
           using (IDataSession session = App.Store.OpenSession(true))
           {
               if (subscribe)
               {
                   IMailer mailer = null;
                   MailerFilter mailerFilter = new MailerFilter();
                   mailerFilter.AddSortOrder(MailerFilter.ID_ASC);
                   mailerFilter.Email = email;
                   mailer= session.Mailers.Get(mailerFilter);
                   if (mailer == null)
                   {
                       mailer = App.Store.CreateMailer();
                       mailer.Email = email;
                       mailer.City_id = cityid;
                       mailer.Secret = AS.Common.Utils.StringUtils.MD5(AS.Common.Utils.StringUtils.GetRandomString(8));
                       session.Mailers.Insert(mailer);
                   }
               }
               userID= session.Users.Insert(user);
               if(userID==1)
               {
                   user=session.Users.GetByID(userID);
                   user.Manager="Y";
                   user.auth="{team}{help}{order}{market}{admin}{finance}";
                   session.Users.Update(user);
               }
               session.Commit();
           }
           if (userID > 0)
           {
               WebUtils.SetLoginUserCookie(user.Username, false);
               if (user.Manager.ToUpper() == "Y")
                   WebUtils.SetLoginAdminUserCookie(user.Id, false);
               eResult.Object = user;
               eResult.Message = "注册成功";
               eResult.Result = true;
               return eResult;
           }
           else
           {
               eResult.Result = false;
               eResult.Message = "注册失败";
               return eResult;
           }
       }

       /// <summary>
       /// 邮件订阅
       /// </summary>
       /// <param name="email"></param>
       /// <returns></returns>
       public static EventResult MailSubscribe(string email,int cityid)
       {
           EventResult eResult = new EventResult();
           if (String.IsNullOrEmpty(email))
           {
               eResult.Result = false;
               eResult.Message = "Email不能为空";
               return eResult;
           }
           if (!AS.Common.Utils.StringUtils.ValidateString(email, "email"))
           {
               eResult.Result = false;
               eResult.Message = "Email格式不正确";
               return eResult;
           }
           if (AS.Common.Utils.StringUtils.GetStringByteLength(email) > 128)
           {
               eResult.Result = false;
               eResult.Message = "Email长度不正确,应小于128字节";
               return eResult;
           }

           IMailer mailer = null;
           MailerFilter mailerFilter = new MailerFilter();
           mailerFilter.AddSortOrder(MailerFilter.ID_ASC);
           mailerFilter.Email = email;
           using (IDataSession session = App.Store.OpenSession(false))
           {
               mailer = session.Mailers.Get(mailerFilter);
               if (mailer == null)
               {
                   mailer = App.Store.CreateMailer();
                   mailer.Email = email;
                   mailer.City_id = cityid;
                   mailer.Secret = AS.Common.Utils.StringUtils.MD5(AS.Common.Utils.StringUtils.GetRandomString(8));
                   session.Mailers.Insert(mailer);
               }
           }
           eResult.Result = true;
           eResult.Message = "邮件订阅成功";
           return eResult;
       }

       /// <summary>
       /// 找回密码
       /// </summary>
       /// <param name="email">EMAIL地址</param>
       /// <param name="url">当前URL地址</param>
       /// <returns></returns>
       public EventResult FindPassword(string email, string url)
       {
           EventResult result = new EventResult();
           if (String.IsNullOrEmpty(email))
           {
               result.Result = false;
               result.Message = "Email不能为空";
               return result;
           }
           if (!AS.Common.Utils.StringUtils.ValidateString(email, "email"))
           {
               result.Result = false;
               result.Message = "Email格式不正确";
               return result;
           }
           if (AS.Common.Utils.StringUtils.GetStringByteLength(email) > 128)
           {
               result.Result = false;
               result.Message = "Email长度不正确,应小于128字节";
               return result;
           }
           IUser user = null;
           UserFilter filter = new UserFilter();
           filter.Email = email;
           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
           {
               user = session.Users.Get(filter);
           }
           if (user == null)
           {
               result.Message = "对不起，没有找到这个Email，请您检查Email是否输入正确!";
               result.Result = false;
               return result;
           }
           ///////////////////////////////////////////////////////////////////////////////////
           //更新验证码
           string strSecret = Utils.Helper.GetRandomString(32);
           user.Secret = strSecret;
           int updatecount = 0;
           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
           {
               updatecount = session.Users.Update(user);
           }
           if (updatecount > 0)
           {
               string WWWprefix = url;
               WWWprefix = WWWprefix.Substring(7);
               WWWprefix = "http://" + WWWprefix.Substring(0, WWWprefix.IndexOf('/'));

               NameValueCollection values = new NameValueCollection();
               values.Add("username", user.Username);
               values.Add("sitename", AS.GroupOn.Controls.PageValue.CurrentSystem.sitename);
               values.Add("wwwprefix", WWWprefix);
               values.Add("recode", strSecret);
               string message = Utils.WebSiteHelper.LoadTemplate("~/template/newt/mail_repass.html", values);

               string strEmailTitle = AS.GroupOn.Controls.PageValue.CurrentSystem.sitename + "重设密码";
               string strEamilBody = message;
               List<string> listEmial = new List<string>();
               listEmial.Add(email);
               string sendemailerror = String.Empty;
               bool strResult = Utils.MailHelper.sendMail(strEmailTitle, strEamilBody, AS.GroupOn.Controls.PageValue.CurrentSystem.mailfrom, "便宜购", listEmial, AS.GroupOn.Controls.PageValue.CurrentSystem.mailhost, AS.GroupOn.Controls.PageValue.CurrentSystem.mailuser, AS.GroupOn.Controls.PageValue.CurrentSystem.mailpass);
               if (strResult)
               {
                   result.Message = "重设密码邮件已经发送，请您注意查收！";
                   result.Result = true;
                   return result;
               }
               else
               {
                   result.Message = "重设密码邮件发送失败，请您重试！";
                   result.Result = false;
                   return result;
               }
           }
           else
           {
               result.Message = "重设密码失败，请您重试！";
               result.Result = false;
               return result;
           }
       }
       /// <summary>
       /// 添加到服务购物车
       /// </summary>
       /// <param name="teamid">项目ID</param>
       /// <param name="teamnum">项目数量</param>
       /// <param name="guige">规格</param>
       /// <returns></returns>
       public EventResult AddCouponCart(int teamid, int teamnum, string guige,Cart cart)
       {
           EventResult result = new EventResult();
           if (teamid <= 0)
           {
               result.Message = "所选项目不正确";
               result.Result = false;
               return result;
           }
           ITeam team = null;
           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
           {
               team = session.Teams.GetByID(teamid);
           }
           if (team == null)
           {
               result.Message = "所选项目不正确";
               result.Result = false;
               return result;
           }
           bool find = false;
           List<CartTeam> teamlist = cart.TeamList;
           for (int i = 0; i < teamlist.Count; i++)
           {
               CartTeam ct = teamlist[i];
               if (ct.TeamID == teamid)
               {
                   find = true;
                   if (teamnum < 1)
                   {
                       teamlist.Remove(ct);
                   }
                   else
                   {
                       ct.TeamNum = teamnum;
                   }
               }
               else
                   teamlist.Remove(ct);
           }
           if (!find)
           {
               if (teamnum > 0)
               {
                   CartTeam ct = new CartTeam();
                   ct.TeamID = teamid;
                   ct.TeamNum = teamnum;
                   ct.Bllin = guige;
                   teamlist.Add(ct);
                   
               }
           }
           cart.TeamList = teamlist;
           Dictionary<string, object> c = new Dictionary<string, object>();
           c.Add("cart", cart);
           CookieUtils.SetCookie(CookieUtils.couponcart,JsonUtils.GetJsonFromObject(c));
           result.Result = true;
           return result;
       }


       /// <summary>
       /// 添加到邮购购物车
       /// </summary>
       /// <param name="teamid">项目ID</param>
       /// <param name="teamnum">项目数量</param>
       /// <param name="guige">规格</param>
       /// <returns></returns>
       public EventResult AddDeliveryCart(int teamid, int teamnum, string guige, Cart cart)
       {
           EventResult result = new EventResult();
           if (teamid <= 0)
           {
               result.Message = "所选项目不正确";
               result.Result = false;
               return result;
           }
           ITeam team = null;
           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
           {
               team = session.Teams.GetByID(teamid);
           }
           if (team == null)
           {
               result.Message = "所选项目不正确";
               result.Result = false;
               return result;
           }
           bool find = false;
           List<CartTeam> teamlist = cart.TeamList;
           for (int i = 0; i < teamlist.Count; i++)
           {
               CartTeam ct = teamlist[i];
               if (ct.TeamID == teamid)
               {
                   find = true;
                   if (teamnum < 1)
                   {
                       teamlist.Remove(ct);
                   }
                   else
                   {
                       ct.TeamNum = teamnum;
                       ct.Bllin = guige;
                   }
               }
           }
           if (!find)
           {
               if (teamnum > 0)
               {
                   CartTeam ct = new CartTeam();
                   ct.TeamID = teamid;
                   ct.TeamNum = teamnum;
                   ct.Bllin = guige;
                   teamlist.Add(ct);

               }
           }
           cart.TeamList = teamlist;
           Dictionary<string, object> c = new Dictionary<string, object>();
           c.Add("cart", cart);
           CookieUtils.SetCookie(CookieUtils.deliverycart, JsonUtils.GetJsonFromObject(c));
           result.Result = true;
           return result;
       }
       /// <summary>
       /// 保存购物车
       /// </summary>
       /// <param name="cart"></param>
       /// <param name="carttype">购物车名称（是优惠券还是邮购）</param>
       /// <returns></returns>
       public EventResult SaveCart(Cart cart,string carttype)
       {
           Dictionary<string, object> c = new Dictionary<string, object>();
           c.Add("cart", cart);
           CookieUtils.SetCookie(carttype, JsonUtils.GetJsonFromObject(c));
           EventResult result = new EventResult();
           result.Result = true;
           return result;
       }

    }
}
