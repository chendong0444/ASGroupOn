<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        form.Action = GetUrl("用户忘记密码", "account_repass.aspx");
        NameValueCollection _system = new NameValueCollection();
        _system = WebUtils.GetSystem();
    }

    protected void submit_ServerClick(object sender, EventArgs e)
    {
        string strEmail = resetemail.Value;

        if (strEmail == "")
        {
            SetError("邮箱不能为空！");
            Response.Redirect(GetUrl("用户忘记密码", "account_repass.aspx"));
        }
        string strSiteName = "";
        string WWWprefix = "";
        string strMailfrom = "";
        string strMailhost = "";
        string strUser = "";
        string strPwd = "";

        if (ASSystem != null)
        {
            strSiteName = ASSystem.sitename;
            strMailfrom = ASSystem.mailfrom;
            strMailhost = ASSystem.mailhost;
            strUser = ASSystem.mailuser;
            strPwd = ASSystem.mailpass;
        }

        //获取网站地址
        WWWprefix = Request.Url.AbsoluteUri;
        WWWprefix = WWWprefix.Substring(7);
        WWWprefix = "http://" + WWWprefix.Substring(0, WWWprefix.IndexOf('/'));

        string strSecret = "";
        string strUserName = "";
        string strUID = "";
        IUser user = Store.CreateUser();
        UserFilter uf = new UserFilter();
        uf.Email = Helper.GetString(strEmail, String.Empty);
        using (IDataSession seion = Store.OpenSession(false))
        {
            user = seion.Users.GetByEmail(uf);
        }

        if (user != null)
        {

            strUserName = user.Username.ToString();
            strUID = user.Id.ToString();
            strSecret = Helper.GetRandomString(32);
            //修改用户验证码信息
            IUser usermodel = Store.CreateUser();
            usermodel.Id = user.Id;
            usermodel.Secret = strSecret;
            using (IDataSession seion = Store.OpenSession(false))
            {
                seion.Users.UpdateSecret(usermodel);
            }

            NameValueCollection values = new NameValueCollection();
            values.Add("username", strUserName);
            values.Add("sitename", strSiteName);
            values.Add("wwwprefix", WWWprefix);
            values.Add("recode", strSecret);
            string message = WebUtils.LoadTemplate(PageValue.TemplatePath + "mail_repass.html", values);

            //==============发送邮件开始==============
            string strEmailTitle = ASSystem.sitename + "重设密码";
            string strEamilBody = message;
            List<string> listEmial = new List<string>();
            listEmial.Add(strEmail);
            string sendemailerror = String.Empty;
            bool strResult = EmailMethod.SendMail(listEmial, strEmailTitle, strEamilBody, out sendemailerror);

            if (strResult)
            {
                SetSuccess("邮件发送成功！");
                Response.Redirect(GetUrl("用户忘记密码", "account_repass.aspx"));
            }
            else
            {
                SetError("邮件发送失败!");
                Response.Redirect(GetUrl("用户忘记密码", "account_repass.aspx"));
            }
            //==============发送邮件结束==============
        }
        else
        {
            SetError("友情提示：此用户不存在");
        }

    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form" runat="server" class="validator">
        <div id="pagemasker">
        </div>
        <div id="dialog">
        </div>
        <div id="doc">

            <div id="bdw" class="bdw">
                <div id="bd" class="cf">
                    <div id="reset">
                        <div id="content">
                            <div class="box">
                                <div class="box-content">
                                    <div class="head">
                                        <h2>重设密码</h2>
                                    </div>
                                    <div class="sect">
                                        <div class="field email">
                                            <label class="f-label" for="reset-email">
                                                Email</label>
                                            <input type="text" size="30" name="email" group="a" id="resetemail" require="true"
                                                datatype="email|ajax" value="" class="f-input" runat="server" />
                                            <span class="hint">您用来登录的 Email 地址</span>
                                        </div>
                                        <div class="act">
                                            <input type="submit" value="重设密码" name="commit" group="a" id="submit" class="formbutton validator"
                                                runat="server" onserverclick="submit_ServerClick" />
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
        <script>
            jQuery(function () { jQuery(document).pngFix(); });
        </script>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
