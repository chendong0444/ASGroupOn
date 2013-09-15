<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<script runat="server">
    protected string name = "";
    protected string strValue = "";
    protected AS.GroupOn.Domain.IPage page = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            if (ASSystem != null)
            {
                name = ASSystem.abbreviation;
            }
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                page = session.Page.GetByID("about_contact");
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
        <div id="about">
            <div id="learn">
                <div class="dashboard1" id="dashboard">
                    <%LoadUserControl(WebRoot + "UserControls/helpmenu.ascx", null); %>
                </div>
                <div id="content" class="about">
                    <div class="clear box">

                        <div class="box-content">
                            <div class="head">
                                <h2>联系方式</h2>
                                <span class="head_eg">
                                    <em>|</em>
                                    Contact
                                </span>
                            </div>
                            <div class="sect"><%=strValue %></div>
                        </div>

                    </div>
                </div>
                <div class="clear"></div>
            </div>
        </div>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
