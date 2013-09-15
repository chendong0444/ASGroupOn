<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script runat="server">
    protected string team_id = String.Empty;
    protected int askcount = 0;
    protected IPagers<IAsk> pager = null;
    protected ITeam teammodel = null;
    protected AskFilter filter = new AskFilter();
    protected IList<IAsk> list_ask = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
    }
    
    public void UpdateView(ITeam team, bool show_all)
    {
        if (team != null)
        {
            team_id = team.Id.ToString();
        }
        if (team != null)
        {
            if (ASSystem != null)
            {
                if (ASSystem.teamask == 0 && team_id != String.Empty)
                    filter.Team_ID = Helper.GetInt(team_id, 0);
            }
        }
        filter.IsComment = true;
        filter.PageSize = 5;
        filter.AddSortOrder(AskFilter.ID_DESC);
        filter.CurrentPage = 1;
        using (IDataSession session = Store.OpenSession(false))
        {
            pager = session.Ask.GetPager(filter);
        }
        teammodel = team;
        askcount = pager.TotalRecords;
        list_ask = pager.Objects;
    }
    public override void UpdateView()
    {
        ITeam team = Params as ITeam;
        if (team != null)
        {
            UpdateView(team, true);
        }
    }
</script>
<div class="deal-consult sbox">
    <div class="sbox-bubble">
    </div>
    <div class="sbox-content">
        <div class="r-top">
        </div>
        <h3>本单答疑</h3>
        <div class="deal-consult-tip">
            <p class="nav">
                <a href="<%=GetUrl("本单答疑","team_ask.aspx?id="+team_id)%>">查看全部(<%=askcount%>)</a> | <a
                    href="<%=GetUrl("本单答疑","team_ask.aspx?id="+team_id)%>">我要提问</a>
            </p>
            <ul class="list">
                <%if (list_ask != null && list_ask.Count > 0)
                  {%>
                <%foreach (IAsk ask in list_ask)
                  { %>
                <li><a href="<%=GetUrl("本单答疑","team_ask.aspx?id="+ask.Team_id)%>#ask-entry-<%=ask.Id %>"
                    target="_blank">
                    <%=StringUtils.SubString(ask.Content,30) %>...</a></li>
                <%} %>
                <% } %>
            </ul>
        </div>
        <div class="r-bottom">
        </div>
    </div>
</div>
