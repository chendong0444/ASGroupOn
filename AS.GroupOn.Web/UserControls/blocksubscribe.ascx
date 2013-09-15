<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
    }
</script>
<div class="deal-subscribe">
    <div class="top">
    </div>
    <div class="body" id="deal-subscribe-body">
        <script language="javascript" type="text/javascript">
            function checkLeftEmail() {
                var str = document.getElementById("left_email").value;
                if (!str.match(/^([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/)) {
                    document.getElementById("left_email").value = "请输入您的Email...";
                    return false;
                }
                else {
                    window.location.href = '<%=GetUrl("邮件订阅", "help_Email_Subscribe.aspx")%>' + '?email=' + str;
                }
            }
        </script>
        <table class="address">
            <tr>
                <td>
                    <input type="text" id="left_email" name="left_email" class="f-text" group="d3" xtip="请输入您的Email..."
                        value="" />
                </td>
                <td>
                    <a href="javascript:void(0)">
                        <image src="<%=ImagePath() %>button-subscribe-b.gif" onclick="checkLeftEmail()"></image>
                    </a>
                </td>
            </tr>
        </table>
        <p class="text">
            邮件订阅第一时间通知<br />
            明天再来看又有新惊喜<br />
            <span class="required">*</span> 此服务可以随时取消</p>
    </div>
    <div class="bottom">
    </div>
</div>
