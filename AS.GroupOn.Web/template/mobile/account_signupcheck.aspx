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
    protected string strmobile = string.Empty;
    protected string topmobile = string.Empty;
    protected string lastmobile = string.Empty;
    protected string strmobiecode = string.Empty;
    public string Key = FileUtils.GetKey();//cookie加密密钥
    protected NameValueCollection configs = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = PageValue.CurrentSystem.sitename;
        PageValue.WapBodyID = "account";
        if (Request.HttpMethod == "POST")
        {
            if (Session["mobilecode"] != null && Request.Form["verifycode"] != null && Session["mobilecode"].ToString() == Request.Form["verifycode"].ToString())
            {
                SetSuccess("提交验证码成功");
                Response.Redirect(GetUrl("手机版注册设置密码", "account_signupset.aspx"));
            }
            else
            {
                SetError("验证码错误");
                Response.Redirect(GetUrl("手机版注册短信验证", "account_signupcheck.aspx"));
            }
            Response.End();
            return;
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
    <li class="active">
        <div class="content">
            <p class="step">
                <span>2</span></p>
            <p>
                输入验证码</p>
        </div>
        <div class="arrow">
        </div>
    </li>
    <li>
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
        <input id="verifycode" name="verifycode" class="common-text" type="text" placeholder="请输入短信中的验证码"
            name="verifycode" required="required" /></p>
    <p class="c-submit ">
        <input type="submit" value="提交验证码" />
    </p>
    <p class="sub-action">
        <a href="<%=GetUrl("手机版注册", "account_signup.aspx")%>">注册</a> <a href="<%=GetUrl("手机版找回密码", "account_repass.aspx")%>">
            找回密码</a></p>
    </form>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>