<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">
    
    
    protected NameValueCollection configs = new NameValueCollection();
    protected IList<ICategory> listcate = null;
    protected IList<IUser> listuser = null;
    protected bool show360login = false;
    protected bool show2345login = false;
    protected bool showqqlogin = false;

    protected bool show163login = false;

    protected bool showSinaLogin = false;
    protected bool showAlipayLogin = false;
    protected string strSUser = "";
    protected string strSEmail = "";
    protected bool show800Login = false;
    protected string strsmobile = "";
    protected int ucenterValue = 0;
    protected bool ucenterResult = false;
    protected bool showtaobaoLogin = false;
    public string mobilecode = String.Empty;

    public string Key = FileUtils.GetKey();//cookie加密密钥
    //protected bool showrenrenlogin = false;
    //ucenter返回的对象
    protected AS.ucenter.RetrunClass retrunclass = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Form.Action = GetUrl("用户注册", "account_loginandreg.aspx");
        configs = PageValue.CurrentSystemConfig;

        if (configs["is360login"] == "1") show360login = true;
        if (configs["is2345login"] == "1") show2345login = true;
        if (configs["isqqlogin"] == "1") showqqlogin = true;

        if (configs["is163login"] == "1") show163login = true;

        if (configs["isSinalogin"] == "1") showSinaLogin = true;
        if (configs["istuan800login"] == "1") show800Login = true;
        if (configs["Isalipaylogin"] == "1") showAlipayLogin = true;
        if (configs["Istaobaologin"] == "1") showtaobaoLogin = true;
        //if (configs["isrenrenlogin"] == "1") showrenrenlogin = true;
        if (!Page.IsPostBack)
        {
            mobilecode = PageValue.CurrentSystemConfig["mobileverify"];
            initPage();
        }


        if (Request["logincommit"] != null && Request["logincommit"].ToString() == "登录")
        {
            commit_Click();
        }

        if (Request["regsubmit"] != null && Request["regsubmit"].ToString() == "注册")
        {
            btnRist_Click();
        }
    }


    private void initPage()
    {

        if (Session["s_email"] != null && Session["s_email"].ToString() != "")
        {
            strSEmail = Session["s_email"].ToString();
        }

        if (Session["s_user"] != null && Session["s_user"].ToString() != "")
        {
            strSUser = Session["s_user"].ToString();
        }
        if (Session["s_mobile"] != null && Session["s_mobile"].ToString() != "")
        {
            strsmobile = Session["s_mobile"].ToString();
        }
        if (Request["backurl"] != null && Request["backurl"].ToString() != "")
        {
            Session.Add("backurl", Request["backurl"].ToString());
            SetRefer(Request["backurl"].ToString());
        }

        city.Items.Add(new ListItem("全部城市", "0"));
        CategoryFilter cf = new CategoryFilter();
        cf.Zone = WebUtils.GetCatalogName(CatalogType.city);
        using (IDataSession seion = Store.OpenSession(false))
        {
            listcate = seion.Category.GetList(cf);
        }

        if (listcate != null && listcate.Count > 0)
        {
            foreach (ICategory category in listcate)
            {

                city.Items.Add(new ListItem(category.Name.ToString(), category.Id.ToString()));

                if (Session["s_city"] != null && Session["s_city"].ToString() != "")
                {
                    city.Value = Session["s_city"].ToString();
                }

            }
        }
    }



    protected void commit_Click()
    {
        string strUser = "";
        string strPwd = "";
        if (Request["user_idLogin"] != null && Request["passwordLogin"] != null)
        {
            strUser = Helper.GetString(Request["user_idLogin"].ToString().Trim(), String.Empty);
            strPwd = Request["passwordLogin"].ToString().Trim();
        }
        if (strUser == "")
        {
            SetError("请输入用户名或者用户邮箱！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
        }
        if (strPwd == "")
        {
            SetError("请输入用户密码！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));

        }

        if (configs["ischeckcode"] == null || configs["ischeckcode"].ToString() != "0")
        {
            string url = "";
            string strcheckCode = Request["checkcodeLogin"];
            if (Session["checkcode"] == null || strcheckCode.ToLower() != Session["checkcode"].ToString().ToLower())
            {
                if (Session["backurl"] != null && Session["backurl"].ToString() != "")
                {
                    url = "?backurl=" + Session["backurl"].ToString();
                }
                SetError("请输入正确的验证码！");
                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx" + url));
                Response.End();
                return;
            }
        }
        string strSqlWhere = "";
        strSqlWhere = string.Format(" username='{0}' or Email='{1}'", Helper.GetString(strUser, String.Empty), Helper.GetString(strUser, String.Empty));
        //是否启用ucenter
        Login(strUser, strPwd);
    }



    protected void btnRist_Click()
    {

        string strEmail = Helper.GetString(Request["emailReg"], String.Empty);
        string strUserName = Helper.GetString(Request["user_idReg"], String.Empty).Trim();
        string strPwd = Request["passwordReg"].ToString().Trim();
        string strPwdConfirm = Request["passwordconfirmReg"].ToString().Trim();
        string strMobile = Request["mobile"].ToString().Trim();
        int strCity = Helper.GetInt(Request["city"], 0);
        string str = Helper.GetString(Request["user_idReg"], "login");
        if (Request["mobile"] != null && Request["mobile"].ToString() != "0" && configs["mobileverify"] == "1")
        {
            string strcheckMobile = Request["confirm_code"];
            if (Session["mobilecode"] == null || strcheckMobile.ToLower() != Session["mobilecode"].ToString().ToLower())
            {
                Session["s_email"] = strEmail;
                Session["s_user"] = strUserName;
                Session["s_mobile"] = strMobile;
                Session["s_city"] = strCity;
                SetError("请输入正确的手机验证码！");
                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                Response.End();
                return;
            }
            else
            {
                Session["s_email"] = null;
                Session["s_user"] = null;
                Session["s_mobile"] = null;
                Session["s_city"] = null;
            }
        }
        if (configs["ischeckcode"] == null || configs["ischeckcode"].ToString() != "0")
        {
            string strcheckCode = Request["checkcodeReg"];
            if (Session["checkcodereg"] == null || strcheckCode.ToLower() != Session["checkcodereg"].ToString().ToLower())
            {
                Session["s_email"] = strEmail;
                Session["s_user"] = strUserName;
                Session["s_mobile"] = strMobile;
                Session["s_city"] = strCity;
                SetError("请输入正确的验证码！");
                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                Response.End();
                return;
            }

            else
            {
                Session["s_email"] = null;
                Session["s_user"] = null;
                Session["s_mobile"] = null;
                Session["s_city"] = null;
            }
        }
        if (str == "login")
        {
            SetError("您输入的用户名不符合规范！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
        }

        if (!strPwd.Equals(strPwdConfirm))
        {
            SetError("密码不一致！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
            return;
        }

        if (strUserName == "")
        {
            SetError("用户名不能为空！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
            return;
        }

        int lenth = System.Text.Encoding.Default.GetByteCount(strUserName);

        if (lenth > 16 || lenth < 4)
        {
            SetError("用户名长度为4-16个字符，一个汉字为两个字符！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
            return;
        }
        else
        {

            UserFilter uf = new UserFilter();
            uf.LoginName = strUserName.Trim();
            using (IDataSession seion = Store.OpenSession(false))
            {
                listuser = seion.Users.GetList(uf);

            }
            if (listuser != null && listuser.Count > 0)
            {
                SetError("用户名已经被注册！");
                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                Response.End();
                return;
            }

        }
        if (strPwd == "")
        {
            SetError("密码不能为空！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
            return;
        }

        int pwdlenth = System.Text.Encoding.Default.GetByteCount(strPwd);
        if (pwdlenth < 6)
        {
            SetError("密码长度不能小于6个字符！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
            return;
        }

        if (ASSystem.needmobile != 0 && !Helper.ValidateString(Server.HtmlEncode(strMobile), "mobile"))
        {
            SetError("手机号码输入的格式不正确");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
            return;
        }
        else if (ASSystem.needmobile != 0)
        {
            UserFilter uf = new UserFilter();
            uf.Mobile = strMobile.Trim();
            using (IDataSession seion = Store.OpenSession(false))
            {
                listuser = seion.Users.GetList(uf);

            }
            if (listuser != null && listuser.Count > 0)
            {
                SetError("此手机号已经被注册！");
                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                Response.End();
                return;
            }
        }

        if (!Helper.ValidateString(strEmail, "email"))
        {
            SetError("电子邮件输入的格式不正确");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
            return;
        }
        else
        {

            UserFilter uf = new UserFilter();
            uf.LoginName = strEmail;
            using (IDataSession seion = Store.OpenSession(false))
            {
                listuser = seion.Users.GetList(uf);

            }

            //说明此邮箱存在
            if (listuser != null && listuser.Count > 0)
            {
                SetError("email已经被注册");
                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                Response.End();
                return;
            }
        }
        IUser m_user = Store.CreateUser();
        //是否启用ucneter
        if (configs["UC_Islogin"] == "1")
        {
            ucenterResult = true;
            m_user = ucenterIsRegester(strUserName, strPwd, strEmail, m_user);
        }
        else
        {
            m_user = ucenterNoRegester(strUserName, strPwd, strEmail, m_user);
        }

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

        if (count == 0)
        {
            m_user.Manager = "Y";
            m_user.auth = "{team}{help}{order}{market}{admin}";

        }
        else
        {
            m_user.Manager = "N";
        }

        bool res = true;
        string Recode = "";


        m_user.IP_Address = CookieUtils.GetCookieValue("gourl");
        m_user.fromdomain = CookieUtils.GetCookieValue("fromdomain");


        if (ASSystem != null)
        {
            if (ASSystem.emailverify == 1)
            {
                Recode = Helper.GetRandomString(32);
                m_user.Enable = "N";
                m_user.Recode = Recode;
                res = false;
                SetSuccess("注册成功,请到邮箱激活");
            }
            else
            {
                m_user.Enable = "Y";
                res = true;
                SetSuccess("注册成功");

            }
        }
        else
        {
            m_user.Enable = "Y";
        }


        int i = 0;

        m_user.userscore = 0;
        m_user.totalamount = 0;
        m_user.Score = 0;
        m_user.Money = 0;
        m_user.Login_time = DateTime.Now;
        m_user.Create_time = DateTime.Now;
        using (IDataSession seion = Store.OpenSession(false))
        {
            i = seion.Users.Insert(m_user);
        }

        if (i == 0)
        {
            SetError("您输入的帐号或邮箱已被注册,请更换");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            return;
        }

        int dingyue = Helper.GetInt(Request["subscribe"], 0);
        if (dingyue == 1)
        {
            IList<IMailer> listmailer = null;
            MailerFilter mf = new MailerFilter();
            mf.Email = Helper.GetString(strEmail, String.Empty);
            mf.City_id = strCity;
            using (IDataSession seion = Store.OpenSession(false))
            {
                listmailer = seion.Mailers.GetList(mf);
            }

            if (listmailer.Count == 0)
            {
                IMailer mailermod = Store.CreateMailer();
                mailermod.City_id = strCity;
                mailermod.Email = strEmail;
                mailermod.Secret = Helper.GetRandomString(32);

                using (IDataSession seion = Store.OpenSession(false))
                {
                    seion.Mailers.Insert(mailermod);
                }
            }
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
            if (ucenterResult)
            {
                if (res)
                {
                    CookieUtils.SetCookie("userid", i.ToString(), Key, null);
                    CookieUtils.SetCookie("username", strUserName, Key, null);
                    //打印并跳转
                    retrunclass = AS.Ucenter.getValue.getLogin(strUserName, false);
                    if (retrunclass != null)
                    {
                        Response.Write(AS.Ucenter.setValue.getsynlogin(retrunclass.Uid));
                    }
                    else
                    {
                        NameValueCollection values = new NameValueCollection();
                        values.Add("UC_Islogin", "0");

                        WebUtils.CreateSystemByNameCollection1(values);
                        SetError("ucenter配置不正确,已自动关闭ucenter，请重新登录。");
                        Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                    }
                    SetSuccess("注册成功");
                    Response.Redirect(Page.ResolveUrl(GetRefer()));
                }
                else
                {
                    Session["useremail"] = strEmail;
                    //发邮件提示用户
                    sentEmail(strEmail, strUserName, Recode);
                    SetSuccess("注册成功");
                    Response.Redirect(Page.ResolveUrl(GetRefer()));
                }
                Response.End();
            }
            else
            {
                if (res)
                {
                    CookieUtils.SetCookie("userid", i.ToString(), Key, null);
                    CookieUtils.SetCookie("username", strUserName, Key, null);
                    SetSuccess("注册成功");
                    Response.Redirect(Page.ResolveUrl(GetRefer()));
                }
                else
                {
                    Session["useremail"] = strEmail;
                    //发邮件提示用户
                    sentEmail(strEmail, strUserName, Recode);
                }
            }
        }
    }


    protected void commit_Click(object sender, EventArgs e)
    {
        string strUser = "";
        string strPwd = "";
        if (Request.Form["user_idLogin"] != null && Request.Form["passwordLogin"] != null)
        {
            strUser = Helper.GetString(Request.Form["user_idLogin"].ToString().Trim(), String.Empty);
            strPwd = Request.Form["passwordLogin"].ToString().Trim();
        }
        if (strUser == "")
        {
            SetError("请输入用户名或者用户邮箱！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
        }
        if (strPwd == "")
        {
            SetError("请输入用户密码！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));

        }


        if (configs["ischeckcode"] == null || configs["ischeckcode"].ToString() != "0")
        {
            string url = "";
            string strcheckCode = Request.Form["checkcodeLogin"];
            if (Session["checkcode"] == null || strcheckCode.ToLower() != Session["checkcode"].ToString().ToLower())
            {
                if (Session["backurl"] != null && Session["backurl"].ToString() != "")
                {
                    url = "?backurl=" + Session["backurl"].ToString();
                }
                SetError("请输入正确的验证码！");
                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx" + url));
                Response.End();
                return;
            }
        }
        string strSqlWhere = "";
        strSqlWhere = string.Format(" username='{0}' or Email='{1}'", Helper.GetString(strUser, String.Empty), Helper.GetString(strUser, String.Empty));
        //是否启用ucenter
        Login(strUser, strPwd);
    }


    protected void btnRist_Click(object sender, EventArgs e)
    {

        string strEmail = Helper.GetString(Request.Form["emailReg"], String.Empty);
        string strUserName = Helper.GetString(Request.Form["user_idReg"], String.Empty).Trim();
        string strPwd = Request.Form["passwordReg"].ToString().Trim();
        string strPwdConfirm = Request.Form["passwordconfirmReg"].ToString().Trim();
        string strMobile = Request.Form["mobile"].ToString().Trim();
        int strCity = Helper.GetInt(Request.Form["city"], 0);
        string str = Helper.GetString(Request.Form["user_idReg"], "login");
        if (Request["mobile"] != null || Request["mobile"].ToString() != "0")
        {
            string strcheckMobile = Request.Form["confirm_code"];
            if (Session["mobilecode"] == null || strcheckMobile.ToLower() != Session["mobilecode"].ToString().ToLower())
            {
                Session["s_email"] = strEmail;
                Session["s_user"] = strUserName;
                Session["s_mobile"] = strMobile;
                Session["s_city"] = strCity;
                SetError("请输入正确的手机验证码！");
                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                Response.End();
                return;
            }
            else
            {
                Session["s_email"] = null;
                Session["s_user"] = null;
                Session["s_mobile"] = null;
                Session["s_city"] = null;
            }
        }
        if (configs["ischeckcode"] == null || configs["ischeckcode"].ToString() != "0")
        {
            string strcheckCode = Request.Form["checkcodeReg"];
            if (Session["checkcodereg"] == null || strcheckCode.ToLower() != Session["checkcodereg"].ToString().ToLower())
            {
                Session["s_email"] = strEmail;
                Session["s_user"] = strUserName;
                Session["s_mobile"] = strMobile;
                Session["s_city"] = strCity;
                SetError("请输入正确的验证码！");
                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                Response.End();
                return;
            }

            else
            {
                Session["s_email"] = null;
                Session["s_user"] = null;
                Session["s_mobile"] = null;
                Session["s_city"] = null;
            }
        }
        if (str == "login")
        {
            SetError("您输入的用户名不符合规范！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
        }

        if (!strPwd.Equals(strPwdConfirm))
        {
            SetError("密码不一致！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
            return;
        }

        if (strUserName == "")
        {
            SetError("用户名不能为空！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
            return;
        }

        int lenth = System.Text.Encoding.Default.GetByteCount(strUserName);

        if (lenth > 16 || lenth < 4)
        {
            SetError("用户名长度为4-16个字符，一个汉字为两个字符！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
            return;
        }
        else
        {
            UserFilter uf = new UserFilter();
            uf.LoginName = strUserName.Trim();
            using (IDataSession seion = Store.OpenSession(false))
            {
                listuser = seion.Users.GetList(uf);

            }
            if (listuser != null && listuser.Count > 0)
            {
                SetError("用户名已经被注册！");
                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                Response.End();
                return;
            }
        }
        if (strPwd == "")
        {
            SetError("密码不能为空！");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
            return;
        }

        if (ASSystem.needmobile != 0 && !Helper.ValidateString(Server.HtmlEncode(strMobile), "mobile"))
        {
            SetError("手机号码输入的格式不正确");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
            return;
        }
        else if(ASSystem.needmobile != 0)
        {
            UserFilter uf = new UserFilter();
            uf.Mobile = strMobile.Trim();
            using (IDataSession seion = Store.OpenSession(false))
            {
                listuser = seion.Users.GetList(uf);

            }
            if (listuser != null && listuser.Count > 0)
            {
                SetError("此手机号已经被注册！");
                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                Response.End();
                return;
            }
        }


        if (!Helper.ValidateString(strEmail, "email"))
        {
            SetError("电子邮件输入的格式不正确");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
            return;
        }
        else
        {
            UserFilter uf = new UserFilter();
            uf.LoginName = strEmail;
            using (IDataSession seion = Store.OpenSession(false))
            {
                listuser = seion.Users.GetList(uf);
            }
            //说明此邮箱存在
            if (listuser != null && listuser.Count > 0)
            {
                SetError("email已经被注册");
                Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                Response.End();
                return;
            }
        }


        IUser m_user = Store.CreateUser();
        //是否启用ucneter
        if (configs["UC_Islogin"] == "1")
        {
            ucenterResult = true;
            m_user = ucenterIsRegester(strUserName, strPwd, strEmail, m_user);
        }
        else
        {
            m_user = ucenterNoRegester(strUserName, strPwd, strEmail, m_user);
        }

        m_user.Mobile = Server.HtmlEncode(strMobile);
        m_user.City_id = strCity;
        m_user.Gender = "M";
        m_user.Create_time = DateTime.Now;
        m_user.IP = WebUtils.GetClientIP;
        m_user.Newbie = "N";
        m_user.Avatar = WebRoot + "upfile/css/i/man.jpg";

        UserFilter usef = new UserFilter();
        IList<IUser> ds_count = null;
        using (IDataSession seion = Store.OpenSession(false))
        {
            ds_count = seion.Users.GetList(usef);
        }

        UserFilter userf = new UserFilter();
        int count = 0;
        using (IDataSession seion = Store.OpenSession(false))
        {
            count = seion.Users.GetCountByCityId(userf);
        }
        if (count == 0)
        {
            m_user.Manager = "Y";
        }
        else
        {
            m_user.Manager = "N";
        }

        bool res = true;
        string Recode = "";


        m_user.IP_Address = CookieUtils.GetCookieValue("gourl");
        m_user.fromdomain = CookieUtils.GetCookieValue("fromdomain");

        if (ASSystem != null)
        {
            if (ASSystem.emailverify == 1)
            {
                Recode = Helper.GetRandomString(32);
                m_user.Enable = "N";
                m_user.Recode = Recode;
                res = false;
                SetSuccess("注册成功,请到邮箱激活");
            }
            else
            {
                m_user.Enable = "Y";
                res = true;
                SetSuccess("注册成功");

            }
        }
        else
        {
            m_user.Enable = "Y";
        }




        int i = 0;

        m_user.userscore = 0;
        m_user.totalamount = 0;
        m_user.Score = 0;
        m_user.Money = 0;
        m_user.Login_time = DateTime.Now;
        m_user.Create_time = DateTime.Now;
        using (IDataSession seion = Store.OpenSession(false))
        {
            i = seion.Users.Insert(m_user);
        }
        if (i == 0)
        {
            SetError("您输入的帐号或邮箱已被注册,请更换");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            return;
        }

        int dingyue = Helper.GetInt(Request["subscribe"], 0);
        if (dingyue == 1)
        {
            IList<IMailer> listmailer = null;
            MailerFilter mf = new MailerFilter();
            mf.Email = Helper.GetString(strEmail, String.Empty);
            mf.City_id = strCity;
            using (IDataSession seion = Store.OpenSession(false))
            {
                listmailer = seion.Mailers.GetList(mf);
            }

            if (listmailer.Count == 0)
            {
                IMailer mailermod = Store.CreateMailer();
                mailermod.City_id = strCity;
                mailermod.Email = strEmail;
                mailermod.Secret = Helper.GetRandomString(32);

                using (IDataSession seion = Store.OpenSession(false))
                {
                    seion.Mailers.Insert(mailermod);
                }


            }
        }


        if (i > 0)
        {
            int iID = i;

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
                CookieUtils.ClearCookie("invitor");

            }



            #endregion

            CreateUserOK(i);
            if (ucenterResult)
            {
                if (res)
                {
                    CookieUtils.SetCookie("userid", i.ToString(), Key, null);
                    CookieUtils.SetCookie("username", strUserName, Key, null);
                    //打印并跳转
                    retrunclass = AS.Ucenter.getValue.getLogin(strUserName, false);
                    if (retrunclass != null)
                    {
                        Response.Write(AS.Ucenter.setValue.getsynlogin(retrunclass.Uid));
                    }
                    else
                    {
                        NameValueCollection values = new NameValueCollection();
                        values.Add("UC_Islogin", "0");
                        WebUtils.CreateSystemByNameCollection1(values);
                        SetError("ucenter配置不正确,已自动关闭ucenter，请重新登录。");
                        Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
                    }
                    SetSuccess("注册成功");
                    Response.Redirect(Page.ResolveUrl(GetRefer()));
                }
                else
                {
                    Session["useremail"] = strEmail;
                    //发邮件提示用户
                    sentEmail(strEmail, strUserName, Recode);
                    Response.Redirect(Page.ResolveUrl(GetUrl("用户注册", "account_loginandreg.aspx")));
                }
                Response.End();
            }
            else
            {
                if (res)
                {
                    CookieUtils.SetCookie("userid", i.ToString(), Key, null);
                    CookieUtils.SetCookie("username", strUserName, Key, null);
                    SetSuccess("注册成功");
                    Response.Redirect(Page.ResolveUrl(GetRefer()));
                }
                else
                {
                    Session["useremail"] = strEmail;
                    //发邮件提示用户
                    sentEmail(strEmail, strUserName, Recode);
                }
            }
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
    /// 启用ucenter的注册方法
    /// </summary>
    /// <param name="username">用户名</param>
    /// <param name="pwd">密码</param>
    /// <param name="email">邮箱</param>
    /// <param name="m_user">model对象</param>
    /// <returns></returns>
    private IUser ucenterIsRegester(string username, string pwd, string email, IUser m_user)
    {
        //用户名验证
        ucenterValue = AS.Ucenter.getValue.getUsername(username);
        if (ucenterValue > 0)
        {
            SetError(AS.Ucenter.getValue.getUsername(ucenterValue));
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
        }
        //邮箱验证
        ucenterValue = AS.Ucenter.getValue.getEmail(email);
        if (ucenterValue > 0)
        {
            SetError(AS.Ucenter.getValue.getEmail(ucenterValue));
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
        }
        //去到ucenter注册
        int ucentervalue = AS.Ucenter.setValue.setRegester(username, pwd, email, false);
        if (ucentervalue == -10)
        {
            NameValueCollection values = new NameValueCollection();
            values.Add("UC_Islogin", "0");
            WebUtils.CreateSystemByNameCollection1(values);
            SetError("ucenter配置不正确,已自动关闭ucenter，请重新登录。");
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
        }
        string a = AS.Ucenter.setValue.getRegester(ucentervalue);
        if (a == "")
        {
            m_user.Username = username;
            m_user.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(pwd + PassWordKey, "md5");
            m_user.Email = email;
            m_user.ucsyc = "yessyc";
        }
        else
        {
            SetError(a);
            Response.Redirect(GetUrl("用户注册", "account_loginandreg.aspx"));
            Response.End();
        }
        return m_user;

    }
    /// <summary>
    /// 不启用ucenter的注册方法
    /// </summary>
    /// <param name="username">用户名</param>
    /// <param name="pwd">密码</param>
    /// <param name="email">邮箱</param>
    /// <param name="m_user">model对象</param>
    /// <returns></returns>
    private IUser ucenterNoRegester(string username, string pwd, string email, IUser m_user)
    {
        m_user.Username = username;
        m_user.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(pwd + PassWordKey, "md5");
        m_user.Email = email;
        m_user.ucsyc = "nosyc";
        return m_user;
    }

    private void sentEmail(string strEmail, string strUserName, string Recode)
    {
        string strSiteName = ASSystemArr["sitename"];
        string WWWprefix = "";


        //获取网站地址
        WWWprefix = Request.Url.AbsoluteUri;
        WWWprefix = WWWprefix.Substring(7);
        WWWprefix = "http://" + WWWprefix.Substring(0, WWWprefix.IndexOf('/'));
        NameValueCollection values = new NameValueCollection();
        values.Add("username", strUserName);
        values.Add("sitename", strSiteName);
        values.Add("wwwprefix", WWWprefix);
        values.Add("recode", Recode);
        string message = WebUtils.LoadTemplate(PageValue.TemplatePath + "mail_verify.html", values);

        //==============发送邮件开始==============
        string strEmailTitle = "感谢注册" + ASSystem.sitename + "，请验证Email以获取更多服务";
        string strEamilBody = message;
        List<string> listEmial = new List<string>();
        listEmial.Add(strEmail);
        string sendemailerror = String.Empty;
        bool strResult = EmailMethod.SendMail(listEmial, strEmailTitle, strEamilBody, out sendemailerror);// Utils.MailHelper.sendMail(strEmailTitle, strEamilBody, strMailfrom, listEmial, strMailhost, strUser, strPwd);
        if (strResult)
        {
            SetSuccess("邮件发送成功！");
            Response.Redirect(GetUrl("注册邮件","account_signuped.aspx"));
        
        }
        else
        {
            SetError("邮件发送失败！");
            Response.Redirect(GetUrl("注册邮件","account_signuped.aspx"));
        }
     
        //==============发送邮件结束==============
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
<body>
<form id="displaySec" class="validator" name="displaySec" runat="server">
    <script type="text/javascript">

        $(document).ready(function () {
            $("input[eve='login']").keypress(function (event) {
                if (event.keyCode == 13) {
                    $("#logincommit").click();
                    return false;
                }

            });
            $("input[eve='reg']").keypress(function (event) {
                if (event.keyCode == 13) {
                    $("#regsubmit").click();
                    return false;
                }

            });

            $("#get_confirm_code").click(function () {
                //countSecond();
                var mobile = $("#mobile").val();
                //alert(mobile);
                if (mobile != "") {
                    //发送短信；
                    $.ajax({
                        type: "POST",
                        url: webroot + "ajax/sms.aspx?action=mobilecode",
                        data: { "mobile": mobile },
                        success: function (msg) {
                            //alert(msg);
                            if (msg == "1") {
                                alert("短信已发送至:" + mobile);
                                countSecond();
                            } else if (msg == "0") {
                                alert("短信已发送失败！");
                            }
                            else if (msg == "2") {
                                alert("该手机已发送最高次数5次，请明天再来!");
                            }
                            else if (msg == "3") {
                                alert("手机格式不正确!");
                            }

                        }
                    });
                }
                else {
                    alert("请输入手机号码");
                }
            });
        });
    </script>
    <script type="text/javascript">
        function pwd() {
            var pwd = document.getElementById("passwordReg").value;
            var repwd = document.getElementById("passwordconfirmReg").value;
            if (pwd != repwd) {
                document.getElementById("pwd").innerHTML = "输入的密码不一致";
            } else {
                document.getElementById("pwd").innerHTML = "";
            }
        }

        var x = 60;
        function countSecond() {
            if (x > 1) {
                x = x - 1;
                $("#mobile").attr("readonly", "readonly");
                $("#get_confirm_code").attr("disabled", "disabled");
                document.displaySec.get_confirm_code.value = x + "秒后重新发送";
                setTimeout("countSecond()", 1000);
            }
            else {
                x = 60;
                document.displaySec.get_confirm_code.value = "获取验证码";
                $("#mobile").attr("readonly", "");
                $("#get_confirm_code").attr("disabled", "");
            }
        }
    </script>

    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="bdw" class="bdw">
        <div id="bd" class="cf">
            <div class="logins_main">
                <div class="gbt_line">
                    请注册或登录&nbsp;<span style="font-size: 14px; font-weight: normal">快速注册，只需30秒</span>
                </div>
                <div class="login_box">
                    <div class="xxzc">
                        <input type="hidden" id="ismobile" value="<%=mobilecode %>" />
                        <table width="100%" cellspacing="5" cellpadding="0" border="0" class="ybcis">
                            <tr>
                                <td valign="top" height="55" align="right" style="font-size: 14px; padding-top: 2px">邮箱&nbsp;&nbsp;
                                </td>
                                <td valign="top" class="hzis">
                                    <input type="text" eve="reg" size="100" group="a" require="true" datatype="email|ajax"
                                        url="<%=PageValue.WebRoot%>ajax/user.aspx" vname="signupemail" msg="邮箱格式不正确|"
                                        msgid="emailerr" class="dlgiwoe" id="emailReg" name="emailReg" value="<%=strSEmail %>" /><br>
                                    登录及找回密码用
                                </td>
                            </tr>
                            <tr>
                                <td valign="top" height="55" align="right" style="font-size: 14px; padding-top: 2px">用户名&nbsp;&nbsp;
                                </td>
                                <td valign="top" class="hzis">
                                    <input type="text" eve="reg" size="100" class="dlgiwoe" group="a" require="true"
                                        id="username" datatype="require|ajax" url="<%=PageValue.WebRoot%>ajax/user.aspx"
                                        vname="signupusername" msg="用户名不能为空或格式不正确|" msgid="usernameerr" id="user_idReg"
                                        name="user_idReg" value="<%=strSUser %>" /><br>
                                    4-16个字符，一个汉字为两个字符
                                </td>
                            </tr>
                            <tr>
                                <td valign="top" height="55" align="right" style="font-size: 14px; padding-top: 2px">用户密码&nbsp;&nbsp;
                                </td>
                                <td valign="top" class="hzis">
                                    <input type="password" eve="reg" class="dlgiwoe" id="passwordReg" size="28" name="passwordReg"><br>
                                    最少6个字符
                                </td>
                            </tr>
                            <tr>
                                <td valign="top" height="55" align="right" style="font-size: 14px; padding-top: 2px">确认密码&nbsp;&nbsp;
                                </td>
                                <td valign="top" class="hzis">
                                    <input type="password" eve="reg" class="dlgiwoe" id="passwordconfirmReg" onblur="pwd();"
                                        size="28" name="passwordconfirmReg"><span id="pwd" style="color: Red"></span>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top" height="35" align="right" style="font-size: 14px; padding-top: 2px">手机号码&nbsp;&nbsp;
                                </td>
                                <%if (ASSystem.needmobile == 0)
                                  { %>
                                <td valign="top" class="hzis">
                                    <input type="text" size="20" eve="reg" class="dlgiwoe" name="mobile" group="a" id="mobile"
                                        datatype="mobile|ajax" class="number" value="<%=strsmobile %>" 
                                        url="<%=PageValue.WebRoot%>ajax/user.aspx" vname="signupmobile" msg="" />
                                </td>
                                <% }
                                  else
                                  {%>
                                <td valign="top" class="hzis">
                                    <input type="text" size="20" eve="reg" class="dlgiwoe" name="mobile" group="a" require="true"
                                        datatype="mobile|ajax" id="mobile" class="number" value="<%=strsmobile %>" 
                                        url="<%=PageValue.WebRoot%>ajax/user.aspx" vname="signupmobile" msg="手机号码不能为空|" />
                                </td>
                                <% }%>
                            </tr>
                            <%if (mobilecode == "1")
                              { %>
                            <tr id="huoqu" style="display: block-inline;">
                                <td valign="top" height="55" align="right" style="font-size: 14px; padding-top: 2px">&nbsp;
                                </td>
                                <td valign="top" class="hzis">
                                    <input type="button" class="formbutton" value="获取验证码" id="get_confirm_code" name="get_confirm_code"
                                        style="_margin-top: 0" />
                                </td>
                            </tr>
                            <tr id="hidemobilecode" style="display: block-inline;">
                                <td valign="top" height="55" align="right" style="font-size: 14px; padding-top: 2px">手机验证码 &nbsp;&nbsp;
                                </td>
                                <td valign="top" class="hzis">
                                    <input type="text" size="20" eve="reg" class="dlgiwoe" id="confirm_code" name="confirm_code"
                                        style="width: 50px;" />
                                </td>
                            </tr>
                            <%}
                              else
                              {%>
                            <tr id="Tr1" style="display: none;">
                                <td valign="top" height="55" align="right" style="font-size: 14px; padding-top: 2px">&nbsp;
                                </td>
                                <td valign="top" class="hzis">
                                    <input type="button" class="formbutton" value="获取验证码" id="Button1" name="get_confirm_code"
                                        style="_margin-top: 0" />
                                </td>
                            </tr>
                            <tr id="Tr2" style="display: none;">
                                <td valign="top" height="55" align="right" style="font-size: 14px; padding-top: 2px">手机验证码 &nbsp;&nbsp;
                                </td>
                                <td valign="top" class="hzis">
                                    <input type="text" size="20" eve="reg" class="dlgiwoe" id="Text1" name="confirm_code"
                                        style="width: 50px;" />
                                </td>
                            </tr>
                            <%} %>
                            <tr>
                                <td valign="top" height="45" align="right" style="font-size: 14px; padding-top: 2px">所在城市&nbsp;&nbsp;
                                </td>
                                <td valign="top" class="hzis">
                                    <select name="city" class="f-city" runat="server" id="city">
                                    </select>
                                </td>
                            </tr>
                            <%if (configs["ischeckcode"] == null || configs["ischeckcode"].ToString() != "0")
                              {%>
                            <tr>
                                <td valign="top" height="45" align="right" style="font-size: 14px; padding-top: 2px">验证码&nbsp;&nbsp;
                                </td>
                                <td valign="top" class="hzis">
                                    <input type="text" size="20" name="checkcodeReg" eve="reg" id="checkcodeReg" class="dlgiwoe"
                                        style="width: 50px;" />
                                    <img height="20px" align="absmiddle" width="65px" id="chkimg" name="chkimg" src="<%=PageValue.WebRoot%>checkcodereg.aspx">
                                    <span style="cursor: pointer;" onclick="cimg()">看不清，换一张</span>
                                    <script>
                                        function cimg() {
                                            var changetime = new Date().getTime();
                                            document.getElementById('chkimg').src = webroot + 'checkcodereg.aspx?' + changetime;
                                        }
                                    </script>
                                    <input runat="server" type="hidden" id="hidcode" />
                                </td>
                            </tr>
                            <%} %>
                            <tr>
                                <td valign="top" height="35" align="right" style="font-size: 14px; padding-top: 2px"></td>
                                <td valign="top" class="hzis">
                                    <input tabindex="3" type="checkbox" value="1" name="subscribe" id="subscribe" class="f-check"
                                        checked="checked" />
                                    <label for="subscribe">
                                        订阅每日最新团购信息</label>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top">&nbsp;
                                </td>
                                <td>
                                    <input type="submit" value="注册" name="regcommit" group="a" id="regsubmit" class="fwewe validator"
                                        runat="server" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="xxyc">
                        <div class="titoe">
                            已有<%if (ASSystem != null)
                                { %>
                            <%= ASSystem.sitename %>
                            <%} %>账号？
                        </div>
                        <table width="95%" cellspacing="0" cellpadding="0" border="0" align="center">
                            <tbody>
                                <tr>
                                    <td height="40" align="right" style="font-size: 14px;">账号&nbsp;&nbsp;
                                    </td>
                                    <td>
                                        <input type="text" size="100" class="dlgse" eve="login" id="user_idLogin" name="user_idLogin">
                                    </td>
                                </tr>
                                <tr>
                                    <td height="40" align="right" style="font-size: 14px;">密码&nbsp;&nbsp;
                                    </td>
                                    <td>
                                        <input type="password" size="28" class="dlgse" eve="login" id="passwordLogin" name="passwordLogin">
                                    </td>
                                </tr>
                                <%if (configs["ischeckcode"] == null || configs["ischeckcode"].ToString() != "0")
                                  {%>
                                <tr>
                                    <td valign="top" height="65" align="right" style="line-height: 50px; width: 100px; font-size: 14px;">验证码&nbsp;&nbsp;
                                    </td>
                                    <td>
                                        <div class="l">
                                            <input type="text" eve="login" size="20" style="width: 50px;" name="checkcodeLogin"
                                                id="checkcodeLogin" class="dlgse" />
                                        </div>
                                        <div style="padding-left: 10px;" class="l">
                                            <img height="20px" width="65px" id="chkimgLogin" name="chkimgLogin" src="<%=WebRoot%>checkcode.aspx">
                                            <br>
                                            <span style="cursor: pointer; font-size: 12px;" onclick="cimglogin()">看不清，换一张</span>
                                        </div>
                                        <script>
                                            function cimglogin() {

                                                var changetime = new Date().getTime();
                                                document.getElementById('chkimgLogin').src = webroot + 'checkcode.aspx?' + changetime;

                                            }
                                            cimg();
                                        </script>
                                    </td>
                                </tr>
                                <%} %>
                                <tr>
                                    <td>&nbsp;
                                    </td>
                                    <td>
                                        <input type="submit" value="登录" name="logincommit" group="b" id="logincommit" class="fwewe"
                                            runat="server" />
                                    </td>
                                </tr>
                        </table>
                        <div class="dl_way">
                            您也可以用合作网站账号登录<%if (ASSystem != null)
                                           { %><%=ASSystem.sitename %><%} %>(
                            <%if (show360login)
                              {%>360.cn&nbsp;<%} %>
                            <%if (showqqlogin)
                              {%>QQ&nbsp;<%} %><%if (showSinaLogin)
                                                 {%>新浪&nbsp;<%} %>
                            <%if (show2345login)
                              {%>2345&nbsp;<%} %>
                            <%if (show163login)
                              {%>网易&nbsp;<%} %>
                            <%if (show800Login)
                              {%>tuan800&nbsp;<%}%>
                            <%if (showAlipayLogin)
                              {%>支付宝&nbsp;<%}%>
                            <%if (showtaobaoLogin)
                              {%>淘宝&nbsp;<%}%>
                            <%if (WebUtils.config["isbaidulogin"] == "1")
                              {%>
                            百度&nbsp;
                            <%} %>
                            <%if (WebUtils.config["iskaixin001login"] == "1")
                              {%>
                            开心网&nbsp;
                            <%} %>
                            <%if (WebUtils.config["isrenrenlogin"] == "1")
                              {%>
                            人人网&nbsp;<%} %>
                            )
                        </div>
                        <ul class="login_way">
                            <%if (show163login)
                              {%>
                            <li><a href="<%=WebRoot%>oauth/163/Login.aspx" title="网易登录" target="_blank">
                                <img src="<%=WebRoot%>upfile/css/i/163_deng.gif" style="width: 64px; height: 24px;" /></a></li>
                            <%} %>
                            <%if (show360login)
                              {%><li><a href="<%=WebRoot%>oauth/360/Login.aspx" title="360登录" target="_blank">
                                  <img src="<%=WebRoot%>upfile/css/i/cn360.gif" style="width: 64px; height: 24px;" /></a></li>
                            <%} %>
                            <%if (showSinaLogin)
                              {%>
                            <li><a href="<%=WebRoot%>oauth/sina/Login.aspx" title="新浪登录" target="_blank">
                                <img src="<%=WebRoot%>upfile/css/i/sl-deng.png" style="width: 64px; height: 24px;" /></a></li>
                            <%} %>
                            <%if (show800Login)
                              {%><li><a href="<%=WebRoot%>oauth/800/Login.aspx" title="tuan800登录" target="_blank">
                                  <img src="<%=WebRoot%>upfile/css/i/800_login.gif" style="width: 64px; height: 24px;" /></a></li>
                            <%} %>
                            <%if (showqqlogin)
                              {%><li><a href="<%=WebRoot%>oauth/qq/loginqq.aspx" target="_blank" title="QQ登录">
                                  <img src="<%=WebRoot%>upfile/css/i/qq-deng.png" style="width: 64px; height: 24px;" /></a></li>
                            <%} %>
                            <%if (show2345login)
                              {%><li><a href="<%=WebRoot%>oauth/2345/Login.aspx" title="2345登录" target="_blank">
                                  <img src="<%=WebRoot%>upfile/css/i/2345_big_login.gif" style="width: 64px; height: 24px;" /></a></li>
                            <%} %>
                             <%if (WebUtils.config["isbaidulogin"] == "1")
                              {%>
                                <li><a target="_blank" href="<%=WebRoot%>oauth/baidu/Login.aspx" title="百度登录">
                                <img src="<%=WebRoot%>upfile/css/i/login-short.png" /></a></li>
                            <%} %>
                            <%if (WebUtils.config["iskaixin001login"] == "1")
                              {%>
                                <li><a target="_blank" href="<%=WebRoot%>oauth/kaixin001/Login.aspx" title="开心登录">
                                <img src="<%=WebRoot%>upfile/css/i/kaixin-deng.gif" style="width: 65px; height: 24px;" /></a></li>
                            <%} %>
                            <%if (WebUtils.config["isrenrenlogin"] == "1")
                              {%>
                                <li><a target="_blank" href="<%=WebRoot%>oauth/renren/Login.aspx" title="人人网登录">
                                <img src="<%=WebRoot%>upfile/css/i/renren-deng.gif" style="width: 65px; height: 24px;" /></a></li>
                            <%}%>
                            <%if (showAlipayLogin)
                              {%><li><a href="<%=WebRoot%>oauth/alipay/Login.aspx" title="支付宝登录" target="_blank">
                                  <img src="<%=WebRoot%>upfile/css/i/alipay_login.gif" /></a></li>
                            <%} %>
                            <%if (showtaobaoLogin)
                              {%>
                            <li><a href="<%=WebRoot%>oauth/taobao/Login.aspx" title="淘宝登录" target="_blank">
                                <img src="<%=WebRoot%>upfile/css/i/taobao_login.gif" alt="淘宝登录" /></a></li>
                            <%} %>
                        </ul>
                    </div>
                </div>
            </div>
        </div>

    </div>
</form>

</body>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>