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
    protected IUser usermodel = null;
    protected NameValueCollection configs = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        configs = PageValue.CurrentSystemConfig;
        form.Action= GetUrl("一站通登录绑定", "account_resetNewlogin.aspx");
        if (Request.QueryString["backurl"] != null && Request.QueryString["backurl"] != "")
        {
            SetRefer(Request.QueryString["backurl"]);
        }
        str = CookieUtils.GetCookieValue("fromdomain");
        string yizhantong = CookieUtils.GetCookieValue("yizhantong");
        if (yizhantong != null && yizhantong != "")
        {
            if (Request.HttpMethod == "POST")
            {
                //邮箱
                string email = Helper.GetString(Request.Form["email"], String.Empty);
                //密码
                string pwd = Request.Form["pwd"];
                //用户绑定
                setLogin(email, pwd);
            }
        }
        else
        {
            Response.Redirect(GetRefer());
            Response.End();
            return;
        }

    }
    /// <summary>
    /// 用户绑定
    /// </summary>
    ///<param name="email">用户名或邮箱</param>
    /// <param name="pwd">密码</param>
    /// <param name="ucenter">是否启用了ucenter</param>
    /// <param name="yizhantong">一站通标识</param>
    private void setLogin(string email, string pwd)
    {
        //获取一站通页面过来的真实姓名
        string realname = CookieUtils.GetCookieValue("realname");
        //邮箱验证
        if (email == null || email == "")
        {
            SetError("用户名或邮箱不能为空，请输入用户名或邮箱");
            Response.Redirect(GetUrl("一站通登录绑定", "account_resetNewlogin.aspx"));

            Response.End();
            return;
        }
        //密码验证
        if (pwd == null || pwd == "")
        {
            SetError("密码不能为空，请输入密码");
            Response.Redirect(GetUrl("一站通登录绑定", "account_resetNewlogin.aspx"));
            Response.End();
            return;
        }
        //查找数据数据库是否存在此用户
        UserFilter uf = new UserFilter();
        uf.LoginName = email;
        uf.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(pwd.Trim() + PassWordKey, "md5");
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            usermodel = session.Users.Get(uf);
        }
        if (usermodel != null)
        {
            AS.ucenter.RetrunClass returnclass = null;
            if (configs["UC_Islogin"] == "1")//如果ucenter开启
            {
                //提取用户名和密码进行ucenter登录验证
                returnclass = AS.Ucenter.setValue.setLogin(usermodel.Username, pwd, false, false);
                if (returnclass == null)//如果ucenter返回信息异常，则自动关闭ucenter
                {
                    //连接服务器错误，或者参数不正确
                    FileUtils.SetConfig("UC_Islogin", "0");
                    SetError("ucenter配置不正确,已自动关闭ucenter，请重新登录。");
                    Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                    Response.End();
                }
                if (returnclass.Uid <= 0)
                {
                    //登录失败，返回错误信息
                    SetError(AS.Ucenter.setValue.getLogin(returnclass.Uid));
                    Response.Redirect(GetUrl("一站通登录绑定", "account_resetNewlogin.aspx"));
                    Response.End();
                    return;
                }

            }
            int updateValue = 0;//声明更新的变量
            string key = CookieUtils.GetCookieValue("key");
            if (key.Length > 0)
                key = DESEncrypt.Decrypt(CookieUtils.GetCookieValue("key"), FileUtils.GetKey());
            //都验证通过了，可进行key值写入,设置uc同步，更新真实姓名

            if (configs["UC_Islogin"] == "1") //开启了ucenter,把ucenter同步标识加上
            {
                usermodel.ucsyc = "yessyc";
            }
            if (!String.IsNullOrEmpty(realname)) //有真实姓名
            {
                usermodel.Realname = realname;
            }
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                updateValue = session.Users.Update(usermodel);
            }
            if (updateValue > 0)
            {
                if (key.Length > 0)//不存在此一站通标识则写入
                {
                    IYizhantong yizhantongmodel = null;
                    IYizhantong insertyizhantong = AS.GroupOn.App.Store.CreateYizhantong();
                    YizhantongFilters yizhantong = new YizhantongFilters();
                    yizhantong.Name = key;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        yizhantongmodel = session.Yizhantong.Get(yizhantong);
                    }
                    if (yizhantongmodel == null)
                    {
                        insertyizhantong.name = key;
                        insertyizhantong.userid = updateValue;
                        insertyizhantong.safekey = CookieUtils.GetCookieValue("safekey");
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            session.Yizhantong.Insert(insertyizhantong);
                        }
                    }
                }
            }
            //更新成功
            SetSuccess("绑定成功!");
            CookieUtils.SetCookie("userid", updateValue.ToString(), Key, null);
            WebUtils.SetLoginUserCookie(usermodel.Username, true);
            LoginOK(updateValue); //登陆成功后执行的方法
            //设置ucenter同步登录
            if (configs["UC_Islogin"] == "1" && returnclass.Uid > 0)
            {
                Response.Write(AS.Ucenter.setValue.getsynlogin(returnclass.Uid));
            }
            CookieUtils.ClearCookie("ucenter");
            CookieUtils.ClearCookie("yizhantong");
            CookieUtils.ClearCookie("key");
            Response.Write("<script>window.location.href='" + Page.ResolveUrl(GetRefer()) + "'<" + "/script>");
            Response.End();
            return;

        }
        else
        {
            SetError("您的邮箱或者密码错误，无法绑定，请重新输入");
            Response.Redirect(GetUrl("一站通登录绑定", "account_resetNewlogin.aspx"));
            Response.End();
            return;
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="form" runat="server">
    <div id="bdw" class="bdw">
        <div id="bd" class="cf">
            <div id="login">
                <div id="content" class="login-box">
                    <div class="box">
                        <div class="box-content">
                            <div class="sect">
                                <div class="field">
                                    <span class="bt">您好，您已经用<%=str %>帐户成功登录<%=ASSystem.abbreviation %></span>
                                </div>
                                <div class="field">
                                    <span class="bt"><a href="<%=GetUrl("一站通注册绑定","account_resetNoLogin.aspx") %>">还未注册过<%=ASSystem.abbreviation %>&gt;&gt;点击这里创建新帐户</a></span>
                                </div>
                                <div class="field">
                                    <span class="bt">已是<%=ASSystem.abbreviation %>会员请直接使用<%=ASSystem.abbreviation %>账户绑定下列个人信息。</span>
                                </div>
                                <div class="field email">
                                    <label for="login-email-address">
                                        用户名/Email</label>
                                    <input type="text" size="30" name="email" group="a" require="true" id="login-email-address"
                                        class="f-input" value="" /><span class="hint">用于登录及找回密码，不会公开，请放心填写</span><br />
                                    <span id="emailerr"></span>
                                </div>
                                <div class="field password">
                                    <label for="login-password">
                                        密码</label>
                                    <input type="password" size="30" name="pwd" require="true" group="a" id="pwd" class="f-input" />
                                </div>
                                <div class="act">
                                    <asp:button id="commit" runat="server" group="a" text="绑定" class="formbutton" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div id="sidebar">
                    <div class="sbox">
                        <div class="sbox-content">
                            <div class="r-top">
                            </div>
                            <div class="side-tip">
                                <h2>什么是创建新账户？</h2>
                                <p>
                                    使用<%=str %>链接创建新账户，会为您在<%=ASSystem.abbreviation %>创建一个新的账号，并直接和您的<%=str %>账号绑定。
                                </p>
                                <h2>什么是绑定已有账户？</h2>
                                <p>
                                    使用<%=str %>绑定已有账户，会将您在<%=ASSystem.abbreviation %>已有的账号和您的<%=str %>账号绑定。
                                </p>
                                <h2>以后我要怎么样登录？</h2>
                                <p>
                                    无论是使用<%=str %>链接创建的新账户还是绑定已有账户，以后您直接通过<%=str %>用户绑定链接就可以直接登录了。
                                </p>
                            </div>
                            <div class="r-bottom">
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