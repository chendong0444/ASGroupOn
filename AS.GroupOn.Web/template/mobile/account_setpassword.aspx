﻿<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    IUser user = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.WapBodyID = "account";
        PageValue.Title = "设置新密码";
        string code = string.Empty;
        if (Session["mobilecode"] != null)
        {
            code = Session["mobilecode"].ToString();
        }
        if (Request.HttpMethod == "POST")
        {
            if (Request.Form["verifyCode"] != null)
            {
                if (Request.Form["verifyCode"] != code)
                {
                    SetError("验证码错误！");
                    return;
                }
            }
            if (Request.Form["password"] != null && Request.Form["password2"] != null)
            {
                if (Request.Form["password"].ToString().Trim().Length >= 6 && Request.Form["password"].ToString().Trim().Length <= 32 && Request.Form["password2"].ToString().Trim().Length >= 6 && Request.Form["password2"].ToString().Trim().Length <= 32)
                {
                    if (Request.Form["password"] != Request.Form["password2"])
                    {
                        SetError("输入的密码不一致！");
                        return;
                    }
                }
                else
                {
                    SetError("密码设置错误，为保证您的账号安全，请至少设置6个字符");
                    return;
                }
            }
            if (Request.Form["verifyCode"] == code && Request.Form["password"] == Request.Form["password2"])
            {
                IUser user = Store.CreateUser();
                UserFilter usfilter = new UserFilter();
                usfilter.Mobile = Session["s_mobile"].ToString();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    user = session.Users.Get(usfilter);
                }
                IUser userpwd = Store.CreateUser();
                userpwd.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Request.Form["password"] + PassWordKey, "md5");
                userpwd.Id = user.Id;
                int i = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    i = session.Users.UpdatePassword(userpwd);
                }
                if (i > 0)
                {
                    SetSuccess("修改密码成功！");
                    Response.Redirect(GetUrl("手机版登录", "account_login.aspx"));
                }
                else
                {
                    SetError("修改密码失败！");

                }
            }
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div class="body account">
    <div class="errMsg none">
    </div>
    <form id="resetreq-form" autocomplete="off" method="post">
    <p>
        输入短信验证码：</p>
    <p>
        <input placeholder="请输入短信验证码" type="text" name="verifyCode" class="common-text" required="required" /></p>
    <p>
        输入新密码：</p>
    <p>
        <input id="new-password0" class="common-text" type="password" placeholder="输入新密码"
            pattern="^[0-9a-zA-Z]{6,32}$" name="password" required="required" />
    </p>
    <p>
        重复输入新密码：</p>
    <p>
        <input id="new-password1" class="common-text" type="password" placeholder="重复输入新密码"
            pattern="^[0-9a-zA-Z]{6,32}$" name="password2" required="required" />
    </p>
    <p class="tips">
        密码长度在6-32个字符之间</p>
    <p class="c-submit ">
        <input type="submit" value="更改密码" />
    </p>
    </form>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        var elPs0 = document.querySelector('#new-password0'),
            elPs1 = document.querySelector('#new-password1'),
            elSubmit = document.querySelector('.c-submit>input'),
            elErrMsg, isError;

        elPs1.addEventListener('blur', function (e) {
            elErrMsg = document.querySelector('#errMsg');

            if (elPs0.value !== elPs1.value && !elErrMsg) {
                document.querySelector('.account')
                        .insertAdjacentHTML('beforebegin', '<div id="errMsg">两次新密码必须一致!</div>')
                isError = true;
            }

            if (elPs0.value === elPs1.value && elErrMsg) {
                elErrMsg.style = "display:none;";
                isError = false;
            }
        });

        elSubmit.addEventListener('click', function (e) {
            if (isError)
                e.preventDefault();
        });
    });
</script>
<%LoadUserControl("_htmlfooter.ascx", null); %>