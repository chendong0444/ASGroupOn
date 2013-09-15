<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
  
    public string strEmail = "";
    public string strLink = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        Form.Action = GetUrl("验证邮件", "account_verify.aspx");

        NameValueCollection _system = new NameValueCollection();
        _system = WebUtils.GetSystem();

        if (!Page.IsPostBack)
        {
            IUser user = Store.CreateUser();
            //激活用户，用户成功登录
            if (Request["code"] != null && Request["code"].ToString() != "")
            {
                initRecod(user);
            }

            //重发邮件
            if (Request["email"] != null && Request["email"].ToString() != "")
            {

                Session["useremail"] = Request["email"].ToString();
                strEmail = Session["useremail"].ToString();
                strLink = EmailMethod.GetEMailLoginUrl(strEmail);
                initSendEmail(user);

            }
            if (Session["useremail"] != null)
            {
                strEmail = Session["useremail"].ToString();
                strLink = EmailMethod.GetEMailLoginUrl(strEmail);
            }


        }
    }

    private void initSendEmail(IUser user)
    {

        IList<IUser> listuser = null;
        string strSiteName = "";
        string WWWprefix = "";
        string strMailfrom = "";
        string strMailhost = "";
        string strEamil = Request["email"].ToString();
        UserFilter uf = new UserFilter();
        uf.Email = Helper.GetString(strEamil, String.Empty);
        using (IDataSession seion = Store.OpenSession(false))
        {
            listuser = seion.Users.GetList(uf);
        }

        if (listuser != null && listuser.Count > 0)
        {

            string str_User = listuser[0].Username;
            string str_Pwd = listuser[0].Password;
            string userid = listuser[0].Id.ToString();
            string recode = listuser[0].Recode;

            if (ASSystem != null)
            {
                strSiteName = ASSystem.sitename;
                strMailfrom = ASSystem.mailfrom;
                strMailhost = ASSystem.mailhost;

            }

            //获取网站地址
            WWWprefix = Request.Url.AbsoluteUri;
            WWWprefix = WWWprefix.Substring(7);
            WWWprefix = "http://" + WWWprefix.Substring(0, WWWprefix.IndexOf('/'));


            NameValueCollection values = new NameValueCollection();
            values.Add("username", str_User);
            values.Add("sitename", strSiteName);
            values.Add("wwwprefix", WWWprefix);
            values.Add("recode", recode);
            string message = WebUtils.LoadTemplate(PageValue.TemplatePath + "mail_verify.html", values);

            //==============发送邮件开始==============
            string strEmailTitle = "感谢注册" + ASSystem.sitename + "，请验证Email以获取更多服务";
            string strEamilBody = message;
            List<string> listEmial = new List<string>();
            listEmial.Add(strEamil);
            string sendemailerror = String.Empty;
            bool strResult = EmailMethod.SendMail(listEmial, strEmailTitle, strEamilBody, out sendemailerror);// Utils.MailHelper.sendMail(strEmailTitle, strEamilBody, strMailfrom, listEmial, strMailhost, strUser, strPwd);

            if (strResult)
            {
                SetSuccess("邮件发送成功！");
                Response.Redirect(GetUrl("验证邮件", "account_verify.aspx"));
            }
            else
            {
                SetError("邮件发送失败！请检查SMTP设置");
                Response.Redirect(GetUrl("验证邮件", "account_verify.aspx"));
            }

            //==============发送邮件结束==============

        }

    }

    private void initRecod(IUser user)
    {
        string recode = Request["code"].ToString();
        IList<IUser> listuser = null;
        UserFilter uf = new UserFilter();
        uf.Recode = recode;
        using (IDataSession seion = Store.OpenSession(false))
        {
            listuser = seion.Users.GetList(uf);
        }

        if (listuser != null && listuser.Count > 0)
        {

            string str_User = listuser[0].Username;
            string str_Pwd = listuser[0].Password;
            string userid = listuser[0].Id.ToString();
            string Manager = listuser[0].Manager;


            //激活用户
            IUser usermodel = Store.CreateUser();
            usermodel.Id = int.Parse(userid);
            usermodel.Enable = "Y";
            using (IDataSession seion = Store.OpenSession(false))
            {
                seion.Users.UpdateEnable(usermodel);
            }

            //创建保存的数据对象

            CookieUtils.SetCookie("username", str_User, Key, null);

            CookieUtils.SetCookie("userid", userid, Key, null);


            //修改登录时间和IP

            usermodel.Login_time = DateTime.Now;
            usermodel.IP = WebUtils.GetClientIP;
            using (IDataSession seion = Store.OpenSession(false))
            {
                seion.Users.UpdateIpTime(usermodel);
            }

            if (Manager.ToUpper() == "Y")
            {
                Session["admin"] = userid;
            }

            SetSuccess("您的帐号激活成功！");

            Response.Redirect(WebRoot + "index.aspx");

        }
    }

</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="signuped">
                    <div id="content">
                        <div class="box">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        请验证邮箱</h2>
                                </div>
                                <div class="sect">
                                    <h3 class="notice-title">
                                        请验证您的Email</h3>
                                    <div class="notice-content">
                                        <p>
                                            我们已经发送了一封验证邮件到 <strong>
                                                <%=strEmail %></strong>，请到您的邮箱收信，并点击其中的链接验证您的邮箱。
                                        </p>
                                        <p class="signup-gotoverify">
                                            <a href="<%=strLink %>" target="_blank">
                                                <img src="<%=PageValue.WebRoot%>upfile/css/i/signup-email-link.gif"></a>
                                        </p>
                                    </div>
                                    <div class="help-tip">
                                        <h3 class="help-title">
                                            收不到邮件？</h3>
                                        <ul class="help-list">
                                            <li>有可能被误判为垃圾邮件了，请到垃圾邮件文件夹找找。</li>
                                            <li><a href="<%=GetUrl("验证邮件", "account_verify.aspx?email="+strEmail)%>">点击这里</a>重发验证邮件到你的邮箱：<%=strEmail %></li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="sidebar">
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
