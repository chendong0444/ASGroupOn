<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    
    protected NameValueCollection configs = new NameValueCollection();

    protected string strImgavatar = "";
    protected StringBuilder stBCity = new StringBuilder();
    bool fileok = false;
    string email = "";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Ordertype = "settings";
        configs = WebUtils.GetSystem();
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="settings">
            <div class="menu_tab" id="dashboard">
                <%LoadUserControl("_MyWebside.ascx", Ordertype); %>
            </div>
            <div id="tabsContent" class="coupons-box">
                <div class="account_set tab">
                    <div class="sect">
                        <iframe name="fapiao" src="http://fapiao.youshang.com/app/app.html" width="510" height="465" marginwidth="0" marginheight="0" hspace="0" vspace="0" frameborder="0" scrolling="no"></iframe>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %>
