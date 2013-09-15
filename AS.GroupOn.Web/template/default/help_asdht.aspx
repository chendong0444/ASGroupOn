<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace=" AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    protected string strValue = String.Empty;
    protected string strWebName = String.Empty;
    protected AS.GroupOn.Domain.IPage page = null;
    protected AS.GroupOn.Domain.ISystem system = null;
    protected SystemFilter filter = new SystemFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (ASSystem.title == String.Empty)
        {
            AS.GroupOn.Controls.PageValue.Title = "团购达人";
        }
        if (!IsPostBack)
        {
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                page = session.Page.GetByID("help_asdht");
            }
            if (page != null)
            {
                strValue = page.Value.ToString();
            }
            filter.AddSortOrder(" id desc ");
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                system = session.System.Get(filter);
            }
            if (system != null)
            {
                if (system.abbreviation != null && system.abbreviation != String.Empty)
                {
                    strWebName = system.abbreviation.ToString();
                }
                else
                {
                    strWebName = "艾尚团购";
                }
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
                            <h2><%=strWebName %>是什么</h2>
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


