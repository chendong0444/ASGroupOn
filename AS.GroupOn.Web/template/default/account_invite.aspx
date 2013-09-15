<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    public int strCount = 0;
    public string strCurrency = "";
    public string strWebName = "";
    public string strInvitecredit = "";
    public string strTeamTitle = "";
    public string strTeamImg = "";
    public string strTeamID = "";
    public string strMoney = "";
    public string strUserID = "";
    public string strWebSite = "";
    public string strRealName = "";
    public ITeam teammodel = null;
    public NameValueCollection _system = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        Form.Action = GetUrl("邀请有奖", "account_invite.aspx");

        _system = WebUtils.GetSystem();

        if (!Page.IsPostBack)
        {
            //判断用户失效！
            if (CookieUtils.GetCookieValue("username", Key) == String.Empty)
            {

                string url = GetUrl("用户登录", "account_login.aspx?backurl=" + this.Page.Server.UrlEncode(this.Page.Request.Url.ToString()));
                Response.Redirect(url);

            }

            GetSystemInfo();
            GetTeamNow();

            //获取网站地址
            strWebSite = Request.Url.AbsoluteUri;
            strWebSite = strWebSite.Substring(7);
            strWebSite = "http://" + strWebSite.Substring(0, strWebSite.IndexOf('/'));
        }

        if (Request.HttpMethod == "POST")
        {
            sentEmail();
        }
    }


    private void GetSystemInfo()
    {

        string strCurrency = "";
        ISystem system = null;
        using (IDataSession seion = Store.OpenSession(false))
        {
            system = seion.System.GetByID(1);
        }


        if (system != null)
        {
            strCurrency = system.currency.ToString();

            if (system.abbreviation == null || system.abbreviation == "")
            {
                strWebName = "艾尚团购";
            }
            else
            {
                strWebName = system.abbreviation.ToString();
            }
            if (Request.QueryString["id"] != null && Request.QueryString["id"].ToString() != "")
            {

                using (IDataSession seion = Store.OpenSession(false))
                {
                    teammodel = seion.Teams.GetByID(Convert.ToInt32(Request.QueryString["id"].ToString()));

                }

                if (teammodel != null)
                {
                    strInvitecredit = teammodel.Bonus.ToString();
                }
                else
                {
                    if (CurrentTeam != null)
                    {
                        strInvitecredit = CurrentTeam.Bonus.ToString();
                    }
                    else
                    {
                        strInvitecredit = system.invitecredit.ToString();
                    }

                }
            }
            else
            {
                if (CurrentTeam != null)
                {
                    strInvitecredit = CurrentTeam.Bonus.ToString();
                }
                else
                {
                    strInvitecredit = system.invitecredit.ToString();
                }
            }
        }


        string strUserName = CookieUtils.GetCookieValue("username", Key);

        IUser user = null;
        UserFilter uf = new UserFilter();
        uf.Username = strUserName;
        using (IDataSession seion = Store.OpenSession(false))
        {
            user = seion.Users.GetByName(uf);
        }
        if (user != null)
        {
            strUserID = user.Id.ToString();
            strRealName = user.Realname;
        }

        InviteFilter inf = new InviteFilter();
        inf.User_id = int.Parse(strUserID);

        using (IDataSession seion = Store.OpenSession(false))
        {
            strCount = seion.Invite.GetCount(inf);
        }

        strMoney = (strCount * int.Parse(float.Parse(strInvitecredit).ToString())).ToString();
    }


    private void GetTeamNow()
    {
        if (Session["teamid"] != null)
        {
            using (IDataSession seion = Store.OpenSession(false))
            {
                teammodel = seion.Teams.GetByID(Convert.ToInt32(Session["teamid"].ToString()));

            }
            if (teammodel != null)
            {
                strTeamID = teammodel.Id.ToString();
                strTeamImg = teammodel.Image;
                strTeamTitle = teammodel.Title;
            }
        }
        else
        {
            if (CurrentTeam != null)
            {

                strTeamID = CurrentTeam.Id.ToString();
                strTeamImg = CurrentTeam.Image.ToString();
                strTeamTitle = CurrentTeam.Title.ToString();
            }
            else
            {
                pimg.Visible = false;
            }
        }

    }

    private void sentEmail()
    {
        string strSiteName = "";
        string WWWprefix = "";

        //发送邮件
        string strUserName = CookieUtils.GetCookieValue("username", Key);


        IUser user = null;
        UserFilter uf = new UserFilter();
        uf.Username = strUserName;
        using (IDataSession seion = Store.OpenSession(false))
        {
            user = seion.Users.GetByName(uf);
        }
        if (user != null)
        {

            strUserID = user.Id.ToString();
            strRealName = user.Realname;
        }


        //获取网站地址
        WWWprefix = Request.Url.AbsoluteUri;
        WWWprefix = WWWprefix.Substring(7);
        WWWprefix = "http://" + WWWprefix.Substring(0, WWWprefix.IndexOf('/'));


        NameValueCollection values = new NameValueCollection();
        values.Add("name", strRealName);
        values.Add("sitename", strSiteName);
        values.Add("wwwprefix", WWWprefix);
        values.Add("content", Request.Form["invitation_content"].ToString());
        values.Add("user_id", strUserID);
        string message = WebUtils.LoadTemplate(PageValue.TemplatePath + "mail_invite.HTML", values);

        //==============发送邮件开始==============
        string strEmailTitle = "您的好友[" + strUserName + "]邀请您注册" + ASSystemArr["abbreviation"];
        string strEamilBody = message;

        string[] recipients = Request.Form["recipients"].ToString().Replace("\r\n", "|").Split('|');


        List<string> listEmial = new List<string>();
        for (int i = 0; i < recipients.Length; i++)
        {

            listEmial.Add(recipients[i]);
        }
        string sendemailerror = String.Empty;
        bool strResult = EmailMethod.SendMail(listEmial, strEmailTitle, strEamilBody, out sendemailerror);

        if (strResult)
        {

            SetSuccess("邮件发送成功！");
            Response.Redirect(GetUrl("邀请有奖", "account_invite.aspx"));
        }
        else
        {
            SetError("邮件发送失败！");
            Response.Redirect(GetUrl("邀请有奖", "account_invite.aspx"));
        }

        //==============发送邮件结束==============
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
            <script src="http://widgets.manyou.com/misc/scripts/ab.js" type="text/javascript"></script>
            <div id="bdw" class="bdw">
                <div id="bd" class="cf">
                    <div id="referrals">
                        <div id="content" class="refers">
                            <div class="box clear">
                                <div class="box-content">
                                    <div class="head">
                                        <h2>邀请有奖</h2>
                                    </div>
                                    <div class="sect">
                                        <p class="notice-total">
                                            您已成功邀请 <strong>
                                                <%=strCount %></strong> 人，累计获得 <strong><span class="money">
                                                    <%=strCurrency%></span><%=strMoney %></strong> 返利，<a href="<%=GetUrl("我的邀请","account_refer.aspx")%>">查看邀请成功列表</a>。
                                        </p>
                                        <p class="intro">
                                            当好友接受您的邀请，在<%=strWebName %>上首次成功购买，管理员在审核以后会返还
                                        <%=strInvitecredit%>
                                        元到您的<%=strWebName%>电子账户，下次团购时可直接用于支付。没有数量限制，邀请越多，返利越多。
                                        </p>
                                        <div class="share-list">
                                            <div class="blk im">
                                                <div class="logo">
                                                    <img src="<%=ImagePath() %>logo_qq.gif" />
                                                </div>
                                                <div class="info">
                                                    <h4>这是您的专用邀请链接，请通过 MSN 或 QQ 发送给好友：</h4>
                                                    <input id="share-copy-text" type="text" value="<%=strWebSite %>/?r=<%=strUserID %>"
                                                        size="35" class="f-input" onfocus="this.select()" tip="复制成功，可以通过 MSN 或 QQ 发送给好友了" />
                                                    <input id="share-copy-button" type="button" value="复制" class="formbutton" />
                                                </div>
                                            </div>
                                            <div class="blk">
                                                <div class="logo">
                                                    <img src="<%=ImagePath()%>logo_msn.png" />
                                                </div>
                                                <div class="info finder-form">
                                                    <h4>您可以直接邀请邮箱或MSN好友&nbsp;(<span><a href="javascript:;" onclick="MYABC.showChooser('recipients', '<%=WebRoot%>account/invitemaillist.html', null, false, false, null);return false">点击邀请</a></span>)</h4>
                                                    <div id="email_invitation" style="display: none;">
                                                        <p>
                                                            <label for="recipients">
                                                                邀请列表</label>
                                                            <textarea name="recipients" id="recipients" class="f-input" rows="5" cols="50" require="true"
                                                                datatype="require"></textarea>
                                                        </p>
                                                        <p>
                                                            <label for="invitation_content">
                                                                邀请内容</label>
                                                            <textarea name="invitation_content" id="invitation_content" class="f-input" cols="50"
                                                                rows="5" require="true" datatype="require">Hi，我最近发现了<%=strWebName%>，每天都有超级划算的产品进行团购活动，快来看看吧～</textarea>
                                                        </p>
                                                        <p>
                                                            <label for="real_name">
                                                                您的姓名</label>
                                                            <input id="real_name" type="text" value="<%=strRealName %>" name="real_name" size="12"
                                                                class="f-input" require="true" datatype="require" />
                                                        </p>
                                                        <p class="commit">
                                                            <input type="submit" class="formbutton" value="继续" />
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>
                                            <asp:Panel ID="pimg" runat="server" Visible="true">
                                                <div class="blk last">
                                                    <div class="logo">
                                                        <img src="<%=ImagePath() %>logo_share.gif" />
                                                    </div>
                                                    <div class="info">
                                                        <h4>分享今日团购给好友，也可获<%=strInvitecredit%>元返利！</h4>
                                                        <div class="deal-info">
                                                            <p class="pic">
                                                                <a href="<%=getTeamPageUrl(int.Parse(strTeamID))  %>" target="_blank">
                                                                    <img src="<%=strTeamImg %>" width="150" height="90" /></a>
                                                            </p>
                                                            <p class="deal-title">
                                                                <%=strTeamTitle %>
                                                            </p>
                                                        </div>
                                                        <%LoadUserControl(WebRoot + "UserControls/blockshare.ascx", CurrentTeam); %>
                                                    </div>
                                                </div>
                                            </asp:Panel>
                                        </div>
                                        <div class="clear">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="sidebar">
                        <%LoadUserControl(WebRoot + "UserControls/blockinvitetip.ascx", null); %>
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>