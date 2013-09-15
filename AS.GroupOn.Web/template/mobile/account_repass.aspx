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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "找回密码";
        PageValue.WapBodyID = "resetreq";
        if (Request.HttpMethod == "POST")
        {
            if (Request.Form["checkcode"] != null && Request.Form["mobile"] != null)
            {
                if (Request.Form["mobile"] == null || Request.Form["mobile"] == "")
                {
                    SetError("请输入手机号！");
                    Response.Redirect(GetUrl("手机版找回密码", "account_repass.aspx"));
                    Response.End();
                    return;
                }
                string strcheckCode = Request.Form["checkcode"].ToString().Trim();
                if (Session["checkcode"] == null || strcheckCode.ToLower() != Session["checkcode"].ToString().ToLower())
                {
                    SetError("请输入正确的验证码！");
                    Response.Redirect(GetUrl("手机版找回密码", "account_repass.aspx"));
                    Response.End();
                    return;
                }


                UserFilter usfilter = new UserFilter();
                IList<IUser> ilistuser = null;

                usfilter.Mobile = Request.Form["mobile"].ToString();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ilistuser = session.Users.GetList(usfilter);
                }

                if (ilistuser != null && ilistuser.Count == 1)
                {
                    Session["s_mobile"] = Request.Form["mobile"];
                    SendMobilecode(Request.Form["mobile"].ToString());
                    Response.Redirect(GetUrl("手机版设置新密码", "account_setpassword.aspx"));
                    Response.End();
                }
                else
                {
                    SetError("您输入的手机号不存在，请用邮箱找回密码！");
                    return;
                }
            }
            else
            {
                SetError("手机号和验证码不能为空！");
                Response.Redirect(GetUrl("手机版找回密码", "account_repass.aspx"));
                Response.End();
                return;
            }
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
            string message = ReplaceStr("repwdcode", values);
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
                    Response.Redirect(GetUrl("手机版设置新密码", "account_setpassword.aspx"));
                    Response.End();
                }

            }
            if (mobilecodecount > 5)
            {
                SetError("该手机已发送最高次数5次，请明天再来!");
                Response.Redirect(GetUrl("手机版找回密码", "account_repass.aspx"));
                Response.End();
            }
            else
            {
                SetError("短信已发送失败！");
                Response.Redirect(GetUrl("手机版找回密码", "account_repass.aspx"));
                Response.End();
            }
        }
        else
        {
            SetError("手机格式不正确!");
            Response.Redirect(GetUrl("手机版找回密码", "account_repass.aspx"));
            Response.End();
        }

    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div class="body account">
    <form id="mresetreq-form" method="post">
        <p>
            请输入手机号码：
        </p>
        <p>
            <input type="text" value="" name="mobile" class="common-text" id="mobile" pattern="[0-9]*"
                placeholder="请输入手机号码" required>
        </p>
        <p>
            请输入右图验证码：
        </p>
        <p id="captcha" class="common-captcha">
            <input type="text" autocomplete="off" id="checkcode" name="checkcode" class="common-text"
                placeholder="请输入验证码" required />
            <img id="chkimg" src="<%=PageValue.WebRoot%>checkcode.aspx">
            <span onclick="cimg()">换一张</span>
            <script>
                function cimg() {
                    var changetime = new Date().getTime();
                    document.getElementById('chkimg').src = '<%=PageValue.WebRoot%>checkcode.aspx?' + changetime;
            }
            </script>
        </p>
        <p class="c-submit ">
            <input type="submit" value="发送短信验证码">
        </p>
    </form>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>