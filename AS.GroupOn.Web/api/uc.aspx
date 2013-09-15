<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    string code = "";
    IUser userinfo = null;
    //ucenter返回的对象
    protected AS.ucenter.RetrunClass retrunclass = null;
    /// <summary>
    /// 通信页面
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected NameValueCollection configs = new NameValueCollection();
    protected void Page_Load(object sender, EventArgs e)
    {
        configs = PageValue.CurrentSystemConfig;
        //判断通信名称与网站设置的名称是否一致，如果一致就说明通信成功，否则通信失败。
        code = Request.QueryString["code"];
        if (code != null && code != "")
        {
            string str = AS.Ucenter.UcenterEncodeValue.AuthCode(code, AS.Ucenter.UcenterEncodeValue.AuthCodeMethod.Decode, configs["UC_KEY"]);
            string[] typevalue = str.Split('&');
            //说明不止一个参数
            if (typevalue != null && typevalue.Length > 0)
            {
                //判断是否是同步登录过来的。
                if (typevalue[0] == "action=synlogin")
                {
                    if (configs["UC_Islogin"] == "1")
                    {
                        //如果是同步登录过来的就提取用户名
                        string[] username = typevalue[1].Split('=');
                        //核对参数名
                        if (username[0] == "username")
                        {
                            //就对ucenter的用户名进行验证
                            resultValue(username[1]);
                        }
                    }

                }
                else if (typevalue[0] == "action=test")
                {
                    //说明是刚添加的引用,告诉ucenter通信成功信息
                    Response.Write("1");
                    Response.End();
                }
                else if (typevalue[0] == "action=synlogout")
                {
                    if (configs["UC_Islogin"] == "1")
                    {
                        //同步退出
                        ClearCookie();
                    }
                }
            }
            Response.Write(1);
            Response.End();
        }

    }
    private void log(string result)
    {
        #region 记录通信记录
        try
        {
            string value = System.DateTime.Now.ToString("yyyyMMddhhmmss") + System.DateTime.Now.Millisecond.ToString();
            string drec = Server.MapPath(WebRoot + "api/uclog/" + value + ".log");
            System.IO.File.AppendAllText(drec, result);
        }
        catch { }
        #endregion
    }
    /// <summary>
    /// 对数据进行处理
    /// </summary>
    /// <param name="username">用户名</param>
    private void resultValue(string username)
    {
        UserFilter uf = new UserFilter();
        uf.Username = username;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            userinfo = session.Users.Get(uf);
        }
        //本网站注册的用户名
        if (userinfo != null)
        {
            //存在此用户名
            if (userinfo.ucsyc.ToString() == "yessyc")
            {
                //同步登录的用户名
                //验证通过则设置为已登录状态，并返回返回地址
                CookieUtils.SetCookie("userid", userinfo.Id.ToString(), Key, null);
                CookieUtils.SetCookie("username", username, Key, null);
                Response.Write("1");
                Response.End();
            }
            else
            {
                //不是同步登录的用户名
                retrunclass = AS.Ucenter.getValue.getLogin(username, false);
                if (retrunclass.Email == userinfo.Email)
                {
                    userinfo.ucsyc = "yessyc";
                    int i = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        i = session.Users.Update(userinfo);
                    }
                    //是同一个用户
                    if (i > 0)
                    {
                        //更新成功
                        CookieUtils.SetCookie("userid", userinfo.Id.ToString(), Key, null);
                        CookieUtils.SetCookie("username", username, Key, null);
                        Response.Write("1");
                        Response.End();
                    }
                    else
                    {
                        //没有更新成功，写到日志里
                        log("更新失败：" + System.DateTime.Now.ToString() + username);
                    }

                }
            }
        }
        else
        {
            //不是本网站的用户名
            //不存在此用户名,获取用户的信息
            retrunclass = AS.Ucenter.getValue.getLogin(username, false);
            if (retrunclass == null)
            {
                FileUtils.SetConfig("UC_Islogin", "0");
                Response.End();
                return;
            }
            //判断邮箱是否存在
            uf = new UserFilter();
            uf.Email = retrunclass.Email;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                userinfo = session.Users.Get(uf);
            }
            //创建用户名
            IUser usermodel = AS.GroupOn.App.Store.CreateUser();
            usermodel.Username = retrunclass.UserName;
            usermodel.Email = retrunclass.Email;
            usermodel.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Helper.GetRandomString(6) + PassWordKey, "md5");
            usermodel.Create_time = System.DateTime.Now;
            usermodel.Login_time = System.DateTime.Now;
            usermodel.Manager = "N";
            usermodel.ucsyc = "yessyc";
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.Users.Insert(usermodel);
            }
            if (i > 0)
            {
                CookieUtils.SetCookie("userid", userinfo.Id.ToString(), Key, null);
                CookieUtils.SetCookie("username", username, Key, null);
            }
            Response.Write("1");
            Response.End();
        }
    }
</script>