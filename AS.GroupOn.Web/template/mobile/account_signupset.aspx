<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script runat="server">
    protected int ucenterValue = 0;
    protected bool ucenterResult = false;
    public string Key = FileUtils.GetKey();//cookie加密密钥
    //ucenter返回的对象
    protected AS.ucenter.RetrunClass retrunclass = null;
    protected string strmobile = string.Empty;
    protected string mobilecode = string.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "设置密码";
        strmobile = Session["s_mobile"].ToString();
        mobilecode = Session["mobilecode"].ToString();

        if (Request.HttpMethod == "POST")
        {
            btnRist_Click();
        }
    }
    protected void btnRist_Click()
    {
        if (Request.Form["password"] != null && Request.Form["password"].Trim() != "" && Request.Form["repassword"] != null && Request.Form["repassword"].Trim() != "")
        {
            IUser m_user = Store.CreateUser();
            string strEmail = strmobile + "@wap.com";
            string strUserName = strmobile;
            string strPwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Request.Form["password"].ToString() + PassWordKey, "md5");
            string strMobile = strmobile;
            int strCity = CurrentCity.Id;
            m_user.Username = strUserName;
            m_user.Password = strPwd;
            m_user.Email = strEmail;
            m_user.ucsyc = "nosyc";
            m_user.Mobile = Server.HtmlEncode(strMobile);
            m_user.City_id = strCity;
            m_user.Gender = "M";
            m_user.Create_time = DateTime.Now;
            m_user.IP = WebUtils.GetClientIP;
            m_user.Newbie = "N";
            m_user.Avatar = PageValue.WebRoot + "upfile/css/i/man.jpg";
            UserFilter userf = new UserFilter();
            int count = 0;
            using (IDataSession seion = Store.OpenSession(false))
            {
                count = seion.Users.GetCountByCityId(userf);
            }
            m_user.Manager = "N";
            m_user.IP_Address = CookieUtils.GetCookieValue("gourl");
            m_user.fromdomain = CookieUtils.GetCookieValue("fromdomain");
            m_user.Enable = "Y";
            m_user.userscore = 0;
            m_user.totalamount = 0;
            m_user.Score = 0;
            m_user.Money = 0;
            m_user.Login_time = DateTime.Now;
            m_user.Create_time = DateTime.Now;
            int i = 0;
            using (IDataSession seion = Store.OpenSession(false))
            {
                i = seion.Users.Insert(m_user);
            }
            if (i == 0)
            {
                SetError("您输入的信息有误");
                Response.Redirect(GetUrl("手机版注册设置密码", "account_signupset.aspx"));
                return;
            }
            if (i > 0)
            {
                UserFilter usf = new UserFilter();
                int iID = 0;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    iID = seion.Users.GetMaxId(usf);
                }
                #region 判断Session是否保存了邀请信息，有则写入邀请信息中
                if (CookieUtils.GetCookieValue("invitor") != String.Empty)
                {

                    IInvite mInvite = Store.CreateInvite();
                    mInvite.Create_time = DateTime.Now;
                    mInvite.User_id = int.Parse(CookieUtils.GetCookieValue("invitor"));
                    mInvite.Other_user_id = iID;
                    mInvite.Other_user_ip = WebUtils.GetClientIP;
                    mInvite.Pay = "N";
                    using (IDataSession seion = Store.OpenSession(false))
                    {
                        seion.Invite.Insert(mInvite);
                    }
                }
                #endregion
                CreateUserOK(i);
                CookieUtils.SetCookie("userid", i.ToString(), Key, null);
                CookieUtils.SetCookie("username", strUserName, Key, null);
                SetSuccess("注册成功");
                Response.Redirect(GetUrl("手机版首页", "index.aspx"));
            }
        }
        else
        {
            SetError("密码设置有错误！");
            Response.Redirect(GetUrl("手机版注册设置密码", "account_signupset.aspx"));
            return;
        }
    }
    public virtual void CreateUserOK(int userid)
    {
        //注册成功执行的方法
        //注册返积分
        IUser uimodel = Store.CreateUser();
        using (IDataSession seion = Store.OpenSession(false))
        {
            uimodel = seion.Users.GetByID(userid);
        }
        if (uimodel != null)
        {
            if (WebUtils.config["regscore"] != null && WebUtils.config["regscore"].ToString() != "" && WebUtils.config["regscore"].ToString() != "0")
            {
                UpdateScore(userid, uimodel.Score, int.Parse(WebUtils.config["regscore"].ToString()));
            }
        }
    }
    /// <summary>
    /// 修改用户余额
    /// </summary>
    /// <param name="userid">ID</param>
    /// <param name="summoeny">积分</param>
    /// <param name="yumongy">+ -积分</param>
    public void UpdateScore(int userid, int userscore, int score)
    {
        int result = userscore + score;
        if (result < 0)
        {
            result = 0;
        }
        IUser user = Store.CreateUser();
        user.userscore = result;
        user.Id = userid;
        using (IDataSession seion = Store.OpenSession(false))
        {
            seion.Users.UpdateUserScore(user);
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<ul class="common-flow">
    <li>
        <div class="content">
            <p class="step">
                <span>1</span></p>
            <p>
                输入手机号</p>
        </div>
        <div class="arrow">
        </div>
    </li>
    <li>
        <div class="content">
            <p class="step">
                <span>2</span></p>
            <p>
                输入验证码</p>
        </div>
        <div class="arrow">
        </div>
    </li>
    <li class="active">
        <div class="content">
            <p class="step">
                <span>3</span></p>
            <p>
                设置密码</p>
        </div>
        <div class="arrow">
        </div>
    </li>
</ul>
<div id="login" class="body account">
    <form id="login-form" method="post">
    <p>
        <input type="hidden" name="mobile" value="<%=Session["s_mobile"] %>" /></p>
    <p>
        <input type="hidden" name="verifycode" value="<%=Session["mobilecode"] %>" /></p>
    <p>
        <input class="common-text" type="password" placeholder="请输入您的密码" name="password"
            required="required" /></p>
    <p>
        <input class="common-text" type="password" placeholder="请重复您输入的密码" name="repassword"
            required="required" /></p>
    <p class="c-submit ">
        <input type="submit" value="设置密码" />
    </p>
    <p class="sub-action">
        <a href="<%=GetUrl("手机版注册", "account_signup.aspx")%>">注册</a> <a href="<%=GetUrl("手机版找回密码", "account_repass.aspx")%>">
            找回密码</a></p>
    </form>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<script>
    $(function () {
        $('#login-form').submit(function () {
            var val = this.password.value,
            reVal = this.repassword.value,
            len = val.length;
            if (val !== reVal) {
                alert('两次输入的密码不一致。');
                return false;
            }
            if (len < 6 || len > 32) {
                alert('密码为6-32个字符，可以使用字母、数字及符号的任意组合。');
                return false;
            }
        });
    });
</script>
<%LoadUserControl("_htmlfooter.ascx", null); %>