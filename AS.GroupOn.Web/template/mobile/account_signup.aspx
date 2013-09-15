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
    protected string strtel = string.Empty;
    protected string strpwd = string.Empty;
    protected string strcheckCode = string.Empty;
    protected IList<IUser> listuser = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "注册账号";
        PageValue.WapBodyID = "signupverify";
        string strMobile = string.Empty;
        if (Request.HttpMethod == "POST")
        {
            if (Request.Form["mobile-number"] != null)
            {
                strtel = Helper.GetString(Request.Form["mobile-number"].ToString().Trim(), String.Empty);
                strMobile = Request["mobile-number"].ToString().Trim();
                Session["s_mobile"] = strtel;
            }
            UserFilter uf = new UserFilter();
            uf.Mobile = strMobile.Trim();
            using (IDataSession seion = Store.OpenSession(false))
            {
                listuser = seion.Users.GetList(uf);
            }
            if (listuser != null && listuser.Count > 0)
            {
                SetError("此手机号已经被注册！");
                Response.Redirect(GetUrl("手机版注册", "account_signup.aspx"));
                Response.End();
                return;
            }
            SendMobilecode(strMobile);
        }
    }
    /// <summary>
    /// 发送短信验证码
    /// </summary>
    /// <param name="mobile"></param>
    public void SendMobilecode(string mobile)
    {
        if (Helper.ValidateString(mobile, "mobile"))
        {
            List<string> mobile_sub = new List<string>();
            mobile_sub.Add(mobile);
            string randnummobile = Helper.GetRandomString(6);
            NameValueCollection values = new NameValueCollection();
            values.Add("手机号码", mobile);
            values.Add("网站简称", ASSystem.abbreviation);
            values.Add("认证码", randnummobile);
            string message = ReplaceStr("mobilecode", values);
            int mobilecodecount = 0;
            if (CookieUtils.GetCookieValue("mobilecodecount") != null && CookieUtils.GetCookieValue("mobilecodecount").ToString() != "")
            {
                mobilecodecount = int.Parse(CookieUtils.GetCookieValue("mobilecodecount").ToString());
            }
            DateTime now = DateTime.Now;
            string strtime = now.ToShortDateString();
            if (mobilecodecount <= 5 && (DateTime.Parse(now.ToShortDateString() + " 00:00:00") <= now && DateTime.Parse(now.ToShortDateString() + " 23:59:59") >= now))
            {

                if (EmailMethod.SendSMS(mobile_sub, message))
                {

                    Session["mobilecode"] = randnummobile;
                    mobilecodecount = mobilecodecount + 1;
                    CookieUtils.SetCookie("mobilecodecount", mobilecodecount.ToString(), DateTime.Now.AddDays(1));
                    SetSuccess("短信已发送至:" + mobile);
                    Response.Redirect(GetUrl("手机版注册短信验证", "account_signupcheck.aspx"));
                    Response.End();
                }
            }
            if (mobilecodecount > 5)
            {
                SetError("该手机已发送最高次数5次，请明天再来!");
                Response.Redirect(GetUrl("手机版注册", "account_signup.aspx"));
                Response.End();
            }
            else
            {
                SetError("短信已发送失败！");
                Response.Redirect(GetUrl("手机版注册", "account_signup.aspx"));
                Response.End();
            }
        }
        else
        {
            SetError("手机格式不正确!");
            Response.Redirect(GetUrl("手机版注册", "account_signup.aspx"));
            Response.End();
        }

    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<ul class="common-flow">
    <li class="active">
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
        <input pattern="[0-9]*" id="mobile-number" class="common-text" placeholder="请输入您的手机号"
            name="mobile-number" autocomplete="off" type="text" required="required"></p>
    <p class="c-submit c-disabled">
        <input value="获取验证码" disabled="disabled" type="submit">
    </p>
    </form>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<script type="text/javascript">
    $(function () {
        var $cSubmit = $('.c-submit'),
        $submitBtn = $cSubmit.find('input'),
        CHECKED = 'checked',
        DISABLED = 'disabled',
        C_DISABLED = 'c-' + DISABLED;
      
        $('#mobile-number').on('keyup', function () {
            var val = this.value;
            if (/^\d{11}$/.test(val)) {
                $cSubmit.removeClass(C_DISABLED);
                $submitBtn.prop(DISABLED, '');
            }
        });

        $('#term').on('change', function () {
            if (!$(this).prop(CHECKED)) {
                $cSubmit.addClass(C_DISABLED);
                $submitBtn.prop(DISABLED, DISABLED);
            } else if (/^\d{11}$/.test($('#mobile-number').val())) {
                $cSubmit.removeClass(C_DISABLED);
                $submitBtn.prop(DISABLED, '');
            }
        });
    });
</script>
<%LoadUserControl("_htmlfooter.ascx", null); %>