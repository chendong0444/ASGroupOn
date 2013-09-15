<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    protected string str = "";
    string key = "";
    protected string str2 = "";
    //ucenter返回的对象
    protected AS.ucenter.RetrunClass retrunclass = null;
    protected IUser userinfomodel = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Form.Action = GetUrl("UC用户绑定", "account_resetlogin.aspx");
        NameValueCollection _system = new NameValueCollection();
        _system = PageValue.CurrentSystemConfig;
        if (Request.QueryString["backurl"] != null && Request.QueryString["backurl"] != "")
        {
            SetRefer(Request.QueryString["backurl"]);
        }
        else
        {
            SetRefer(GetRefer());
        }
        if (CookieUtils.GetCookieValue("userid") != String.Empty)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                userinfomodel = session.Users.GetByID(Helper.GetInt(DESEncrypt.Decrypt(CookieUtils.GetCookieValue("userid"), FileUtils.GetKey()), 0));
            }
        }
        str = CookieUtils.GetCookieValue("fromdomain");
        string yizhantong = CookieUtils.GetCookieValue("yizhantong");
        string str1 = CookieUtils.GetCookieValue("ucenter");
        str2 = CookieUtils.GetCookieValue("ucError");
        if ((yizhantong != null && yizhantong.Trim() == "yizhantong") || str1.Trim() == "ucenter")
        {
            getLogin();
        }
        else
        {
            Response.Redirect(WebRoot + "index.aspx");
        }

    }
    /// <summary>
    /// 登录判断
    /// </summary>
    private void getLogin()
    {
        key = String.Empty;//一站通key值
        if (CookieUtils.GetCookieValue("key").Length > 0)
        {
            key = DESEncrypt.Decrypt(CookieUtils.GetCookieValue("key"), FileUtils.GetKey());
        }
        if (Request.HttpMethod == "POST")
        {
            //获得真实姓名
            string realname = Helper.GetString(CookieUtils.GetCookieValue("realname"), String.Empty);
            //获得邮箱
            string email = Helper.GetString(Request.Form["email"], String.Empty);
            //获得用户名
            string username = Helper.GetString(Request.Form["username"], String.Empty);
            //获得密码
            string pwd = Request.Form["pwd"];
            //获得确认密码
            string pwdVer = Request.Form["pwdVer"];
            //更新用户操作
            updateLogin(username, pwd, pwdVer, email, key, realname);
            //然后跳转到返回页面地址
            Response.Redirect(GetRefer(), true);
        }

    }
    /// <summary>
    /// 更新用户的操作
    /// </summary>
    /// <param name="username">用户名</param>
    /// <param name="pwd">密码</param>
    /// <param name="pwdVer">重复密码</param>
    /// <param name="email">邮箱</param>
    /// <param name="yizhantong">一站通标识key,如果是不是一站通的用户这个参数为空，否则是一站通的key值</param>
    /// <param name="ucenter">传入配置信息的是否启用一站通的状态：UC_Islogin为1的情况下是启用的状态，0或者null的情况下是没有启用一站通</param>
    /// <param name="realname">真实姓名,接收支付宝大快捷一站通的真实姓名</param>
    /// <param name="uid">ucenter启用的情况下login.html或LoginAndReg.html页面传过来的用户ID，这个是加密过来的，需要解密</param>
    private void updateLogin(string username, string pwd, string pwdVer, string email, string yizhantongKey, string realname)
    {
        int userid = 0;//需要重新绑定信息的用户ID
        IUser usermodel = null;
        if (CookieUtils.GetCookieValue("userid") != String.Empty)
        {
            userid = Helper.GetInt(DESEncrypt.Decrypt(CookieUtils.GetCookieValue("userid"), FileUtils.GetKey()), 0);
        }
        if (userid == 0)//不存在的用户无需绑定，直接返回首页
        {
            Response.Redirect(WebRoot + "index.aspx");
            return;
        }
        //查找当前用户的数据库信息
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            usermodel = session.Users.GetByID(userid);
        }
        if (usermodel == null)
        {
            SetError("不存在此用户");
            Response.Redirect(GetUrl("UC用户绑定", "account_resetlogin.aspx"));
            Response.End();
            return;
        }
        //1.1检查邮箱是否为空
        if (email == null || email == "")
        {
            SetError("邮箱不能为空，请输入邮箱地址");
            Response.Redirect(GetUrl("UC用户绑定", "account_resetlogin.aspx"));
            Response.End();
            return;
        }
        else
        {
            //1.2.1判断邮箱的格式
            if (!Helper.ValidateString(email, "email"))
            {
                SetError("电子邮件输入的格式不正确");
                Response.Redirect(GetUrl("UC用户绑定", "account_resetlogin.aspx"));
                Response.End();
                return;
            }
            //判断用户名长度是否合法
            int nameLenth = System.Text.Encoding.Default.GetByteCount(Helper.GetString(username, username));
            if (nameLenth < 4 || nameLenth > 16)
            {
                SetError("用户名长度为4-16个字符，一个汉字为两个字符！");
                Response.Redirect(GetUrl("UC用户绑定", "account_resetlogin.aspx"));
                Response.End();
                return;
            }
            //3.密码验证
            if (pwd == null || pwd == "" || pwdVer == null || pwdVer == "")
            {
                SetError("密码不能为空，请输入密码");
                Response.Redirect(GetUrl("UC用户绑定", "account_resetlogin.aspx"));
                Response.End();
                return;
            }
            if (pwd.Trim() != pwdVer.Trim())
            {
                SetError("两次输入的密码不一致，请重新输入密码");
                Response.Redirect(GetUrl("UC用户绑定", "account_resetlogin.aspx"));
                Response.End();
                return;
            }


            //1.2.2判断邮箱,用户名是否存在
            List<Hashtable> hs = null;
            if (userid > 0)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    hs = session.Custom.Query("select * from [user] where Id!=" + userid + " and (email='" + email + "' or username='" + email + "' or email='" + username + "' or username='" + username + "')");
                }
            }
            //邮箱存在
            if (hs != null && hs.Count > 0)
            {
                SetError("当前邮箱或用户名已存在，请重新填写");
                Response.Redirect(GetUrl("UC用户绑定", "account_resetlogin.aspx"));
                Response.End();
                return;
            }

        }

        //4.ucenter开启的情况下进行用户名，邮箱验证,并注册到ucenter
        //声明ucenter用户名，邮箱验证的变量
        string value = "";
        if (WebUtils.config["UC_Islogin"] == "1")
        {
            //4.1.ucenter邮箱验证
            value = AS.Ucenter.getValue.getEmail(AS.Ucenter.getValue.getEmail(email));
            if (value != "")
            {
                SetError(value);
                Response.Redirect(GetUrl("UC用户绑定", "account_resetlogin.aspx"));
                Response.End();
                return;
            }
            //4.2.ucenter用户名验证
            value = AS.Ucenter.getValue.getUsername(AS.Ucenter.getValue.getUsername(username));
            if (value != "")
            {
                SetError(value);
                Response.Redirect(GetUrl("UC用户绑定", "account_resetlogin.aspx"));
                Response.End();
                return;
            }
            //4.3注册ucenter
            int ucentervalue = AS.Ucenter.setValue.setRegester(username, pwd, email, false);
            if (ucentervalue == -10)
            {
                FileUtils.SetConfig("UC_Islogin", "0");
                SetError("ucenter配置不正确,已自动关闭ucenter，请重新登录。");
                Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                Response.End();
            }
            if (ucentervalue < 0)
            {
                SetError(AS.Ucenter.setValue.getRegester(ucentervalue));
                Response.Redirect(GetUrl("UC用户绑定", "account_resetlogin.aspx"));
                Response.End();
                return;
            }
        }
        int updateValue = 0;
        IUser upuser = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            upuser = session.Users.GetByID(userid);
        }
        if (upuser != null)
        {
            upuser.Username = username;
            upuser.Email = email;
            upuser.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Helper.GetString(pwd.Trim(), pwd) + PassWordKey, "md5");
            if (WebUtils.config["UC_Islogin"] == "1") //开启了ucenter,把ucenter同步标识加上
            {
                upuser.ucsyc = "yessyc";
            }
            if (!String.IsNullOrEmpty(realname)) //有真实姓名
            {
                upuser.Realname = realname;
            }
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                updateValue = session.Users.Update(upuser);
            }
        }
        if (updateValue > 0)
        {
            if (yizhantongKey.Length > 0)//不存在此一站通标识则写入
            {
                IYizhantong yizhantongmodel = null;
                IYizhantong insertyizhantong = AS.GroupOn.App.Store.CreateYizhantong();
                YizhantongFilters yizhantong = new YizhantongFilters();
                yizhantong.Name = yizhantongKey;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    yizhantongmodel = session.Yizhantong.Get(yizhantong);
                }
                if (yizhantongmodel == null)
                {
                    insertyizhantong.name = key;
                    insertyizhantong.userid = userid;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        session.Yizhantong.Insert(insertyizhantong);
                    }
                }
            }
        }
        if (updateValue > 0)
        {
            SetSuccess("修改成功!");
            //保存在cookie里面，设置为已登陆状态
            CookieUtils.SetCookie("userid", updateValue.ToString(), Key, null);
            WebUtils.SetLoginUserCookie(username, true);
            LoginOK(userid);
            CookieUtils.ClearCookie("ucenter");
            CookieUtils.ClearCookie("yizhantong");
            CookieUtils.ClearCookie("key");
            Response.Redirect(WebRoot + "index.aspx");
            Response.End();
            return;
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="form" runat="server">
    <div class="bdw" id="bdw">
        <div class="cf" id="bd">
            <div id="login">
                <div id="content" class="login-box">
                    <div class="box">
                        <div class="box-content">
                            <div class="sect">
                                <div class="field">
                                    <%if (str2 != null && str2 != "")
                                      { %>
                                    <span class="bt">
                                        <%=str2 %></span><br />
                                    <%}
                                      else
                                      { %>
                                    <span class="bt">您好，您已经用<%=str %>账户成功登录<%=ASSystem.abbreviation %>请修改相关的个人信息。</span><br />
                                    <%} %>
                                    <span id="Span1"></span>
                                </div>
                                <div class="field email">
                                    <label for="login-email-address">
                                        Email</label>
                                    <input type="text" size="30" name="email" require="true" datatype="email|ajax" url="<%=WebRoot%>ajax/ucenterUpdate.aspx"
                                        vname="signupemail" group="a" msg="邮箱格式不正确|" id="login-email-address" class="f-input"
                                        value="<%=userinfomodel.Email %>" /><span class="hint">用于登录及找回密码，不会公开，请放心填写</span><br />
                                    <span id="emailerr"></span>
                                </div>
                                <div class="field email">
                                    <label for="login-email-address">
                                        用户名</label>
                                    <input type="text" size="30" id="username" name="username" require="true" datatype="require|ajax"
                                        url="<%=WebRoot%>ajax/ucenterUpdate.aspx" vname="signupusername" msg="用户名不能为空或格式不正确|" group="a"
                                        id="Text1" class="f-input" value="<%=userinfomodel.Username %>" /><span class="hint">填写4-16个字符，一个汉字为两个字符</span><span
                                            id="usernameerr"></span>
                                </div>
                                <div class="field password">
                                    <label for="login-password">
                                        密码</label>
                                    <input type="password" size="30" name="pwd" require="true" datatype="require" group="a"
                                        id="pwd" class="f-input" />
                                </div>
                                <div class="field password">
                                    <label for="login-password">
                                        确认密码</label>
                                    <input type="password" size="30" name="pwdVer" require="true" datatype="compare"
                                        compare="pwd" msg="两次输入的密码不一致" group="a" id="pwdVer" class="f-input" />
                                </div>
                                <div class="act">
                                    <asp:button id="commit" runat="server" group="a" text="绑定" class="formbutton validator" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- bd end -->
    </div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>