<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    protected IPage page = null;
    protected ISystem system = null;
    SystemFilter filter = new SystemFilter();
    protected string strWebName = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (ASSystem.title == String.Empty)
        {
            AS.GroupOn.Controls.PageValue.Title = "团购达人";
        }
        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            page = session.Page.GetByID("help_tour");
        }
        filter.AddSortOrder(" id desc");
        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.Get(filter);
        }
        if (system != null)
        {
            if (system.abbreviation == null || system.abbreviation.ToString() == "")
            {
                strWebName = "艾尚团购";
            }
            else
            {
                strWebName = system.abbreviation.ToString();
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
                            <h2>玩转<%=strWebName%></h2>
                            <span class="head_eg"><em>|</em>Fun</span></div>
                        <div class="sect"><%=page.Value %></div>
                    </div>

                </div>
            </div>
            <div class="clear"></div>
        </div>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>

