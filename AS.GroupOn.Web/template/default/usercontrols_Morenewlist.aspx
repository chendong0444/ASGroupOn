<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    protected IPagers<INews> page = null;
    protected NewsFilter filter = new NewsFilter();
    protected string type = "0";
    protected IList<INews> newsList = null;
    protected string PageHtml = String.Empty;
    protected string pagepar = String.Empty;
    public string cityid = "0";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        
        if (CurrentCity != null)
        {
            cityid = CurrentCity.Id.ToString();
        }
        AS.GroupOn.Controls.PageValue.Title = "新闻公告";

        if (Request["type"] != null && Request["type"].ToString() != "")
        {
            type = Request["type"].ToString();
        }
        pagepar = "&page={0}" + pagepar;
        pagepar = GetUrl("新闻公告", "usercontrols_Morenewlist.aspx?" + pagepar);
        filter.PageSize = 30;
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request["page"], 1);
        filter.type = AS.Common.Utils.Helper.GetInt(type, 0);
        filter.AddSortOrder("create_time desc, id desc");
        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            page = session.News.GetPager(filter);
        }
        if (page != null)
        {
            newsList = page.Objects;
        }
        PageHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, page.TotalRecords, page.CurrentPage, pagepar);

    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div id="bdw">
    <div class="cf" id="bd">
        <div class="news_content">
            <div class="news_head">
                <h2>新闻公告</h2>
            </div>
            <div class="news">
                <ul class="news_list">
                    <%foreach (INews model in newsList)
                      { %>
                    <li>
                        <%if (model.link != "")
                          { %>
                        <a href="<%=model.link %>" target="_blank">·<%=model.title%></a>
                        <% }
                          else
                          {%>
                        <a href="<%=GetUrl("新闻", "usercontrols_newlist.aspx?id=" + model.id ) %>" target="_blank">·<%=model.title%></a>
                        <% }%>
                        <span class="pub_time">
                            <%=model.create_time.ToString("yyyy-MM-dd") %></span> </li>
                    <% }%>
                </ul>
            </div>
            <div class="clear">
            </div>
            <div>
                <ul class="paginator">
                    <li>
                        <%=PageHtml %>
                    </li>
                </ul>
            </div>
        </div>
        <div id="sidebar">
            <%LoadUserControl(WebRoot + "UserControls/adleft.ascx", null); %>
            <%LoadUserControl(WebRoot + "UserControls/blockothers.ascx", null); %>
            <%LoadUserControl(WebRoot + "UserControls/blockbulletin.ascx", null); %>
            <%LoadUserControl(WebRoot + "UserControls/blockflv.ascx", null); %>
            <%LoadUserControl(WebRoot + "UserControls/blockbusiness.ascx", null); %>
            <%LoadUserControl(WebRoot + "UserControls/blocksubscribe.ascx", null); %>
        </div>
        </div>
     </div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>