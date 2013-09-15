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
    string strUrl = "";
    protected NameValueCollection configs = new NameValueCollection();
    protected CookieParameter cookics = new CookieParameter();
    protected bool show360login = false;
    protected bool show2345login = false;
    protected bool showqqlogin = false;
    protected bool show163login = false;
    protected bool showSinaLogin = false;
    protected bool show800Login = false;
    protected bool showAlipayLogin = false;
    protected bool showtaobaoLogin = false;
    string strUser = "";
    string strPwd = "";
    //protected bool showrenrenlogin = false;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Form.Action = GetUrl("用户登录", "account_login.aspx");
        configs = WebUtils.GetSystem();
        if (configs["is360login"] == "1") show360login = true;
        if (configs["is2345login"] == "1") show2345login = true;
        if (configs["isqqlogin"] == "1") showqqlogin = true;
        if (configs["is163login"] == "1") show163login = true;
        if (configs["isSinalogin"] == "1") showSinaLogin = true;
        if (configs["istuan800login"] == "1") show800Login = true;
        if (configs["Isalipaylogin"] == "1") showAlipayLogin = true;
        if (configs["Istaobaologin"] == "1") showtaobaoLogin = true;
        if (Request.HttpMethod == "POST")
        {
            if (Request.Form["username"] != null && Request.Form["password"] != null)
            {
                strUser = Helper.GetString(Request.Form["username"].ToString().Trim(), String.Empty);
                strPwd = Request.Form["password"].ToString().Trim();
            }
            if (strUser == "")
            {
                SetError("请输入用户名或者用户邮箱！");
                Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
            }
            if (strPwd == "")
            {
                SetError("请输入用户密码！");
                Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
            }
            if (configs["ischeckcode"] == null || configs["ischeckcode"].ToString() != "0")
            {
                string strcheckCode = Request.Form["checkcode"].ToString().Trim();
                if (Session["checkcode"] == null || strcheckCode.ToLower() != Session["checkcode"].ToString().ToLower())
                {
                    SetError("请输入正确的验证码！");
                    Response.Redirect(GetUrl("用户登录", "account_login.aspx"));
                    Response.End();
                    return;
                }
            }
            Login(strUser, strPwd);
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="form" runat="server">
<div class="bdw" id="bdw">
    <div class="cf" id="bd">
        <div id="login">
            <div class="login-box" id="content">
                <div class="box">
                    <div class="box-content">
                        <div class="head">
                            <h2>
                                登录</h2>
                            <span>&nbsp;或者 <a href="<%=GetUrl("用户注册","account_loginandreg.aspx") %>">注册</a></span></div>
                        <div class="sect">
                             <div class="field email">
                                        <label for="login-email-address">
                                            Email／用户名</label>
                                        <input type="text" size="30" name="username" id="login-email-address" class="f-input"
                                            value="" />
                                    </div>
                                                <div class="field password">
                                        <label for="login-password">
                                            密码</label>
                                        <input type="password" size="30" name="password" id="password1" class="f-input" />
                                         <span class="lostpassword"><a href="<%=GetUrl("用户忘记密码","account_repass.aspx") %>">忘记密码？</a></span>
                                    </div>
   
                            <%if (PageValue.CurrentSystemConfig["ischeckcode"] == null || PageValue.CurrentSystemConfig["ischeckcode"].ToString() != "0")
                              {%>
                            <div class="field">
                                <label for="signup-username">
                                    验证码</label>
                                          <input type="text" size="20" name="checkcode" group="a" require="true" id="checkcode"
                                    datatype="require" class="number" />
                                <img height="20px" src="<%=PageValue.WebRoot%>checkcode.aspx" width="65px" id="chkimgs"
                                    name="chkimg" />
                                <span style="cursor: pointer;" onclick="cimgs()">看不清，换一张</span>
                                <script>
                                    function cimgs() {
                                        var changetime = new Date().getTime();
                                        document.getElementById('chkimgs').src = '<%=PageValue.WebRoot%>checkcode.aspx?' + changetime;
                                    }
                                    cimgs();
                                </script>
                            </div>
                            <%}%>
                            <div class="field autologin">
                                <input type="checkbox" class="f-check" id="autologin" name="auto-login" value="1" />
                                <label for="autologin">
                                    下次自动登录</label>
                            </div>
                            <div class="act">
                                <input type="submit" class="formbutton" id="commit" value="登录" name="commit">
                            </div>
                            <div class="act">
                                <div style="color: #333; margin-top: 10px; border-top: 1px solid #CCCCCC; height: 30px;
                                    padding-top: 15px;">
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
                                    <%
                                        if (PageValue.CurrentSystemConfig["isbaidulogin"] == "1")
                                        {%>
                                    百度&nbsp;
                                    <%} %>
                                    <%
                                        if (PageValue.CurrentSystemConfig["iskaixin001login"] == "1")
                                        {%>
                                    开心网&nbsp;<%} %>
                                    <%if (PageValue.CurrentSystemConfig["isrenrenlogin"] == "1")
                                      {%>
                                    人人网&nbsp;<%} %>
                                    )
                                </div>
                            </div>
                            <br />
                            <div class="act">
                                <%if (show360login)
                                  {%><a href="<%=PageValue.WebRoot%>oauth/360/login.aspx" title="360登录" target="_blank"><img src="<%=PageValue.WebRoot%>upfile/css/i/cn360.gif"
                                      alt="360登录" /></a><%} %>
                                <%if (show2345login)
                                  {%>&nbsp;&nbsp;<a href="<%=PageValue.WebRoot%>oauth/2345/login.aspx" title="2345登录" target="_blank"><img
                                      src="<%=PageValue.WebRoot%>upfile/css/i/2345_big_login.gif" alt="2345登录" /></a><%} %>
                                <%if (showqqlogin)
                                  {%>&nbsp;&nbsp;<a href="<%=PageValue.WebRoot%>oauth/qq/loginqq.aspx" title="QQ登录" target="_blank"><img
                                      src="<%=PageValue.WebRoot%>upfile/css/i/qq-deng.png" alt="qq登录" /></a><%} %>
                                <%if (showSinaLogin)
                                  {%>
                                &nbsp;&nbsp;<a href="<%=PageValue.WebRoot%>oauth/sina/login.aspx" title="新浪登录" target="_blank"><img src="<%=PageValue.WebRoot%>upfile/css/i/sl-deng.png"
                                    alt="新浪登录" /></a><%} %>
                                <%if (show163login)
                                  {%>
                                &nbsp;&nbsp;<a href="<%=PageValue.WebRoot%>oauth/163/login.aspx" title="网易登录" target="_blank"><img src="<%=PageValue.WebRoot%>upfile/css/i/163_deng.gif"
                                    alt="网易登录" /></a><%} %>
                                <%if (show800Login)
                                  {%>
                                &nbsp;&nbsp;<a href="<%=PageValue.WebRoot%>oauth/800/login.aspx" title="tuan800登录" target="_blank"><img
                                    src="<%=PageValue.WebRoot%>upfile/css/i/800_login.gif" alt="tuan800登录" /></a><%} %>
                                <%if (showAlipayLogin)
                                  {%>
                                &nbsp;&nbsp;<a href="<%=PageValue.WebRoot%>oauth/alipay/Login.aspx" title="支付宝登录" target="_blank"><img
                                    src="<%=PageValue.WebRoot%>upfile/css/i/alipay_login.gif" alt="支付宝登录" /></a><%} %>

                                <%if (PageValue.CurrentSystemConfig["isbaidulogin"] == "1")
                                  {%>
                                &nbsp;&nbsp;<a target="_blank" href="<%=PageValue.WebRoot%>oauth/baidu/login.aspx" title="百度账号登录"><img
                                    src="<%=PageValue.WebRoot%>upfile/css/i/login-short.png" alt="baidu登录" /></a>
                                <%} %>
                                <%if (PageValue.CurrentSystemConfig["iskaixin001login"] == "1")
                                  {%>
                                &nbsp;&nbsp;<a target="_blank" href="<%=PageValue.WebRoot%>oauth/kaixin001/login.aspx" title="开心网登录"><img
                                    src="<%=PageValue.WebRoot%>upfile/css/i/kaixin-deng.gif" alt="开心网登录" /></a>
                                <%} %>
                                <%if (PageValue.CurrentSystemConfig["isrenrenlogin"] == "1")
                                  {%>
                                &nbsp;&nbsp;<a target="_blank" href="<%=PageValue.WebRoot%>oauth/renren/login.aspx" title="人人网登录"><img
                                    src="<%=PageValue.WebRoot%>upfile/css/i/renren-deng.gif" alt="人人网登录" /></a>
                                <%} %>
                                <%if (showtaobaoLogin)
                                  {%>
                                <a href="<%=PageValue.WebRoot%>oauth/taobao/Login.aspx" title="淘宝登录" target="_blank">
                                    <img src="<%=PageValue.WebRoot%>upfile/css/i/taobao_login.gif" alt="淘宝登录" /></a><%} %>
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
                            <h2>还没有<%=ASSystemArr["abbreviation"]%>账户？</h2>
                            <p>
                                立即<a href="<%=GetUrl("用户注册","account_loginandreg.aspx") %>">注册</a>，仅需30秒！</p>
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