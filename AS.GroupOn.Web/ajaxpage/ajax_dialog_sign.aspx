<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        if (Request["mobile"] != null && Request["secret"] != null && Request["mobile"].ToString() != "" && Request["secret"].ToString() != "")
        {
            NeedLogin();
            string mobile = Helper.GetString(Request["mobile"], String.Empty);
            string secret = Helper.GetString(Request["secret"], String.Empty);
            if (Session["signsecret"] != null)
            {
                if (Session["signsecret"].ToString() == secret)
                {
                    if (AsUser.Id != 0)
                    {
                        IUser usermodel = AsUser;
                        usermodel.Signmobile = mobile;
                        int i = 0;
                        using (IDataSession session = Store.OpenSession(false))
                        {
                            i = session.Users.Update(usermodel);
                        }
                        if (i > 0)
                            SetSuccess("手机号码已成功绑定！");
                        else
                            SetSuccess("手机号码已绑定失败！");
                        Response.Write(JsonUtils.GetJson("X.boxClose(); window.location.href='" + WebRoot + "index.aspx';", "eval"));
                        Response.End();
                    }
                }
                else
                {
                    SetError("验证码失效！");
                    Response.Write(JsonUtils.GetJson("X.boxClose(); window.location.href='" + WebRoot + "index.aspx';", "eval"));
                    Response.End();
                }
            }
            else
            {
                SetError("验证码失效！");
                Response.Write(JsonUtils.GetJson("X.boxClose(); window.location.href='" + WebRoot + "index.aspx';", "eval"));
                Response.End();
            }
        }
    }
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
    <script type="text/javascript">
        $(document).ready(function () {
            jQuery('#sendsms').click(function () {
                var mobile = $('#coupon-dialog-input-mobile').val();
                if (mobile != "") {
                    X.get(webroot + 'ajax/sms.aspx?action=sign&&mobile=' + mobile);
                }
            });
            $("#coupon-dialog-sign").click(function () {
                var mobile = $('#coupon-dialog-input-mobile').val();
                var secret = $('#coupon-dialog-input-secret').val();
                X.get(webroot + 'AjaxPage/ajax_dialog_sign.aspx?mobile=' + mobile + '&secret=' + secret);
            });
            jQuery('#coupon_dialog_bizback').click(function () {
                X.boxClose();
                X.get(webroot + 'ajax/coupon.aspx?action=sign');
            });
        });
    </script>
    <h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>签到</h3>
    <%if (!IsLogin)
      {%>
    <p class="info" id="P1">请您登录后再签到</p>
    <%}
      else
      {%>
    <p class="info" id="coupon-dialog-display-id">请绑定手机号码</p>

    <p class="notice" vname="mobile">
        手机号码：<input id="coupon-dialog-input-mobile" type="text" name="id" class="f-input" datatype="mobile" style="text-transform: uppercase;" maxlength="11" onkeyup="X.coupon.dialoginputkeyup(this);" />
        <a href="#" id="sendsms">获取验证码</a>
    </p>
    <p class="notice" vname="secret">验证码：<input id="coupon-dialog-input-secret" type="text" name="secret" style="text-transform: uppercase; margin-left: 12px;" class="f-input" maxlength="6" onkeyup="X.coupon.dialoginputkeyup(this);" /></p>
    <%} %>
    <p class="act" style="margin: auto; text-align: center; padding-bottom: 5px;">
        <%if (IsLogin)
          {%>
        <input id="coupon-dialog-sign" class="formbutton" value="绑定" name="query" type="button" />&nbsp;&nbsp;&nbsp;
        <input id="coupon_dialog_bizback" name="coupon_dialog_bizback" class="formbutton" value="返回" type="button" />
        <%} %>
    </p>
</div>
