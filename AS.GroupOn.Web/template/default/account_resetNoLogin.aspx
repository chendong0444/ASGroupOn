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
    protected NameValueCollection configs = new NameValueCollection();
    string key = "";
    protected string str = "";
    string realname = "";
    string email = "";
    string username = "";
    string pwd = "";
    string pwdrefer = "";
    //ucenter返回的对象
    protected AS.ucenter.RetrunClass retrunclass = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        form.Action = GetUrl("一站通注册绑定", "account_resetNoLogin.aspx");
        if (Request.QueryString["backurl"] != null && Request.QueryString["backurl"] != "")
        {
            SetRefer(Request.QueryString["backurl"]);
        }
        else
        {
            SetRefer(GetRefer());
        }
        configs = PageValue.CurrentSystemConfig;
        str = CookieUtils.GetCookieValue("fromdomain");
        string yizhantong = CookieUtils.GetCookieValue("yizhantong");
        string str1 = CookieUtils.GetCookieValue("ucenter");
        if ((yizhantong != null && yizhantong.Trim() == "yizhantong") || (str1 != null && str1.Trim() == "ucenter"))
        {

            getLogin();
        }
        else
        {
            Response.Redirect(WebRoot + "Index.aspx");
        }
    }
    /// <summary>
    /// 登录判断
    /// </summary>
    private void getLogin()
    {
        if (Request.HttpMethod == "POST")
        {
            email = Server.HtmlEncode(Request.Form["email"]);
            username = Server.HtmlEncode(Request.Form["username"]);
            pwd = Server.HtmlEncode(Request.Form["pwd"]);
            pwdrefer = Server.HtmlEncode(Request.Form["pwdrefer"]);
            string realname = CookieUtils.GetCookieValue("realname");
            //获取一站通用户名
            key = CookieUtils.GetCookieValue("key");
            realname = CookieUtils.GetCookieValue("realname");
            //ucenter配置信息
            string uc_islogin = configs["UC_Islogin"];
            //注册用户
            regesterLogin(username, pwd, pwdrefer, key, uc_islogin, realname);
        }
    }
    /// <summary>
    /// 注册用户
    /// </summary>
    /// <param name="username"></param>
    /// <param name="pwd"></param>
    /// <param name="pwdrefer"></param>
    /// <param name="key"></param>
    /// <param name="ucenter"></param>
    /// <param name="realname"></param>
    private void regesterLogin(string username, string pwd, string pwdrefer, string key, string ucenter, string realname)
    {
        //注册验证
        regesterYanzheng(username, pwd, pwdrefer, ucenter);
        //如果用户名和邮箱都不存在就注册到ucenter
        if (key != null && key != "")
        {
            //注册成功,注册到本网站
            key = DESEncrypt.Decrypt(key, FileUtils.GetKey());

            IUser userinfoModel = AS.GroupOn.App.Store.CreateUser();
            userinfoModel.Username = Helper.GetString(username, username);
            if (realname != null && realname != "")
                userinfoModel.Realname = realname;
            userinfoModel.Email = Helper.GetString(email, email);
            userinfoModel.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(pwd + PassWordKey, "md5");
            userinfoModel.fromdomain = CookieUtils.GetCookieValue("fromdomain");
            userinfoModel.Enable = "Y";
            if (ucenter != null && ucenter == "1")
            {
                userinfoModel.ucsyc = "yessyc";
            }
            userinfoModel.IP_Address = CookieUtils.GetCookieValue("gourl");
            int userid = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                userid = session.Users.Insert(userinfoModel);
            }
            if (userid > 0)
            {
                IYizhantong yizhantong = AS.GroupOn.App.Store.CreateYizhantong();
                yizhantong.name = key;
                yizhantong.userid = userid;
                yizhantong.safekey = CookieUtils.GetCookieValue("safekey");
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Yizhantong.Insert(yizhantong);
                }
            }
            SetSuccess("绑定成功!");
            //保存在cookie里面，设置为已登陆状态
            CookieUtils.SetCookie("userid", userid.ToString(), Key, null);
            WebUtils.SetLoginUserCookie(userinfoModel.Username, true);
            LoginOK(userinfoModel.Id); //登陆成功后执行的方法
            CookieUtils.ClearCookie("ucenter");
            CookieUtils.ClearCookie("yizhantong");
            CookieUtils.ClearCookie("key");
            //打印并跳转
            if (ucenter != null && ucenter == "1")
            {
                retrunclass = AS.Ucenter.getValue.getLogin(Helper.GetString(username, username), false);
                Response.Write(AS.Ucenter.setValue.getsynlogin(retrunclass.Uid));
            }
            else
            {
                SetSuccess("更新成功!");
            }
           
            Response.Write("<script>window.location.href='" + Page.ResolveUrl(GetRefer()) + "'<" + "/script>");
            Response.End();
        }

    }
    /// <summary>
    /// 注册验证
    /// </summary>
    /// <param name="username">用户名</param>
    /// <param name="pwd">密码</param>
    /// <param name="pwdrefer">确认密码</param>
    /// <param name="ucenter">是否启用了ucenter</param>
    private void regesterYanzheng(string username, string pwd, string pwdrefer, string ucenter)
    {
        List<Hashtable> hs = new List<Hashtable>();
        if (email != null && email != "")
        {
            if (!Helper.ValidateString(Helper.GetString(email, email), "email"))
            {
                SetError("电子邮件输入的格式不正确");
                Response.Redirect(GetUrl("一站通注册绑定", "account_resetNoLogin.aspx"));
                Response.End();
                return;
            }
            else
            {
                //格式正确的情况下判断邮箱地址是否重复，如果重复就重写
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    hs = session.Custom.Query("select top 1 Id from [user] where " + " Email='" + Helper.GetString(email, String.Empty) + "' or username='" + Helper.GetString(email, String.Empty) + "' or email='" + Helper.GetString(username, String.Empty) + "' or username='" + Helper.GetString(username, String.Empty) + "'");
                }
                if (hs.Count > 0)
                {
                    SetError("帐号或邮箱地址已存在，请重新填写!");
                    Response.Redirect(GetUrl("一站通注册绑定", "account_resetNoLogin.aspx"));
                    Response.End();
                    return;
                }
            }

        }
        else
        {
            SetError("邮箱地址不能为空，请填写邮箱地址");
            Response.Redirect(GetUrl("一站通注册绑定", "account_resetNoLogin.aspx"));
            Response.End();
            return;
        }
        if (username != null && username != "")
        {
            int lenth = System.Text.Encoding.Default.GetByteCount(Helper.GetString(username, username));

            if (lenth > 16 || lenth < 4)
            {
                SetError("用户名长度为4-16个字符，一个汉字为两个字符！");
                Response.Redirect(GetUrl("一站通注册绑定", "account_resetNoLogin.aspx"));
                Response.End();
                return;
            }
            else
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    hs = session.Custom.Query("select top 1 Id from [user] where " + "username='" + Helper.GetString(username, username) + "'");
                }
                //用户名是否存在
                if (hs.Count > 0)
                {
                    SetError("用户名已存在，请输入其他用户名!");
                    Response.Redirect(GetUrl("一站通注册绑定", "account_resetNoLogin.aspx"));
                    Response.End();
                    return;
                }
            }
        }
        else
        {
            SetError("用户名不能为空，请填写用户名");
            Response.Redirect(GetUrl("一站通注册绑定", "account_resetNoLogin.aspx"));
            Response.End();
            return;

        }
        if (pwd == null || pwd == "")
        {
            SetError("密码不能为空，请填写密码");
            Response.Redirect(GetUrl("一站通注册绑定", "account_resetNoLogin.aspx"));
            Response.End();
            return;
        }
        if (pwdrefer == null || pwdrefer == "")
        {
            SetError("确认密码不能为空，请填写确认密码");
            Response.Redirect(GetUrl("一站通注册绑定", "account_resetNoLogin.aspx"));
            Response.End();
            return;
        }
        if (pwd != pwdrefer)
        {
            SetError("输入的两次密码不正确，请重新填写密码");
            Response.Redirect(GetUrl("一站通注册绑定", "account_resetNoLogin.aspx"));
            Response.End();
            return;
        }
        //启用了ucenter
        if (ucenter != null && ucenter == "1")
        {
            //使用了ucenter,需要判断ucenter是否有用户名和密码
            if (AS.Ucenter.getValue.getEmail(AS.Ucenter.getValue.getEmail(Helper.GetString(email, email))) != "")
            {
                //有此邮箱
                SetError("邮箱地址已存在，请输入其他邮件");
                Response.Redirect(GetUrl("一站通注册绑定", "account_resetNoLogin.aspx"));
                Response.End();
                return;
            }
            if (AS.Ucenter.getValue.getUsername(AS.Ucenter.getValue.getUsername(Helper.GetString(username, username))) != "")
            {
                //有此用户名
                SetError("用户名已存在，请输入其他用户名");
                Response.Redirect(GetUrl("一站通注册绑定", "account_resetNoLogin.aspx"));
                Response.End();
                return;
            }
            string pwdvalue = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Helper.GetString(pwd, pwd), "md5");
            int aa = AS.Ucenter.setValue.setRegester(Helper.GetString(username, username), pwd, Helper.GetString(email, email), false);
            if (aa == -10)
            {
                //说明ucenter配置不正确
                FileUtils.SetConfig("UC_Islogin", "0");
                SetError("ucenter配置不正确,已自动关闭ucenter，请重新登录。");
                Response.Redirect(GetUrl("一站通注册绑定", "account_resetNoLogin.aspx"));

            }
            string a = AS.Ucenter.setValue.getRegester(aa);
            if (a != "")
            {
                //注册失败
                SetError(a);
                Response.Redirect(GetUrl("一站通注册绑定", "account_resetNoLogin.aspx"));
                Response.End();
                return;
            }
        }
    }                
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    jQuery("username").click(function (event) {
        var k = this.length;
        alert(k);
        var t = this.val();
        for (var i = 0; i < k; i++) {
            if (0 < t.charCodeAt(i) > 255) {
                alert("中文符号");
            }
        }
    });
</script>
<form id="form" runat="server">
    <div id="bdw" class="bdw">
        <div id="bd" class="cf">
            <div id="login">
                <div id="content" class="login-box">
                    <div class="box">
                        <div class="box-content">
                            <div class="sect">
                                <div class="field">
                                    <span class="bt">您好，您已经用<%=str %>帐户成功登录<%=ASSystem.abbreviation %>,请设置相关的个人信息,进行绑定。</span><br />
                                    <span id="Span1"></span>
                                </div>
                                <div class="field email">
                                    <label for="login-email-address">
                                        Email</label>
                                    <input type="text" size="30" name="email" require="true" datatype="email|ajax" url="/ajax/user.aspx"
                                        vname="signupemail" group="a" msg="邮箱格式不正确|" id="login-email-address" class="f-input"
                                        value="" /><span class="hint">用于登录及找回密码，不会公开，请放心填写</span><br />
                                    <span id="emailerr"></span>
                                </div>
                                <div class="field email">
                                    <label for="login-email-address">
                                        用户名</label>
                                    <input type="text" size="30" id="username" name="username" require="true" datatype="require|ajax"
                                        url="/ajax/user.aspx" vname="signupusername" msg="用户名不能为空或格式不正确|" group="a" id="Text1"
                                        class="f-input" value="" /><span class="hint">填写4-16个字符，一个汉字为两个字符</span><span id="usernameerr"></span>
                                </div>
                                <div class="field password">
                                    <label for="login-password">
                                        密码</label>
                                    <input type="password" size="30" name="pwd" require="true" group="a" id="pwd" class="f-input" />
                                </div>
                                <div class="field password">
                                    <label for="login-password">
                                        确认密码</label>
                                    <input type="password" size="30" name="pwdrefer" require="true" group="a" id="pwdrefer"
                                        class="f-input" />
                                </div>
                                <div class="act">
                                    <asp:button id="commit" runat="server" group="a" text="绑定" class="formbutton" />
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