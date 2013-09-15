<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<script runat="server">
    public string strEmail = "";
    public string strLink = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NameValueCollection _system = new NameValueCollection();
        _system = WebUtils.GetSystem();
        strEmail = Session["useremail"].ToString();
        strLink = EmailMethod.GetEMailLoginUrl(strEmail);

    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
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
                                <div class="head success">
                                    <h2>恭喜您，注册成功！</h2>
                                </div>
                                <div class="sect">
                                    <h3 class="notice-title">下一步，请验证您的Email</h3>
                                    <div class="notice-content">
                                        <p>
                                            我们发送了一封验证邮件到 <strong>
                                                <%=strEmail %></strong>，请到您的邮箱收信，并点击其中的链接验证您的邮箱。
                                        </p>
                                        <p class="signup-gotoverify">
                                            <a href="<%=strLink %>" target="_blank">
                                                <img src="<%=PageValue.WebRoot%>upfile/css/i/signup-email-link.gif"></a>
                                        </p>
                                    </div>
                                    <div class="help-tip">
                                        <h3 class="help-title">收不到邮件？</h3>
                                        <ul class="help-list">
                                            <li>有可能被误判为垃圾邮件了，请到垃圾邮件文件夹找找。</li>
                                            <li><a href="<%=GetUrl("验证邮件","account_verify.aspx?email="+strEmail)%>">点击这里</a>重发验证邮件到你的邮箱：</li>
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
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>