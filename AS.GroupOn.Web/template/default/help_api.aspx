<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<script runat="server">
    protected string strValue = String.Empty;
    protected AS.GroupOn.Domain.IPage page = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (ASSystem.title == String.Empty)
        {
            AS.GroupOn.Controls.PageValue.Title = "团购达人";
        }
        if (!Page.IsPostBack)
        {
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                page = session.Page.GetByID("help_api");
            }
            if (page != null)
            {
                strValue = page.Value.ToString();
            }
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="learn">
            <div class="dashboard1" id="dashboard">
                <%LoadUserControl(WebRoot + "UserControls/helpmenu.ascx", null); %>
            </div>
            <div id="content" class="about">
                <div class="box">
                    <div class="box-content">
                        <div class="head">
                            <h2>开发接口</h2>
                        </div>
                        <div class="sect"><%=strValue %></div>
                    </div>
                </div>
            </div>
            <div class="clear"></div>
        </div>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>


