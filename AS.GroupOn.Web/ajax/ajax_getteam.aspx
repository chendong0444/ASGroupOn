<%@ Page Language="C#" AutoEventWireup="true" Debug="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace=" System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected void Page_Load(object sender, EventArgs e)
    {
        StringBuilder sb = new StringBuilder();
        string type = Helper.GetString(Request["type"], String.Empty);
        int id = Helper.GetInt(Request["id"], -1);
        if (id != -1)
        {
            IList<ITeam> list = getMallTeamByCataid(id);
            sb = GetStr(list);
        }
        else if (type != String.Empty)
        {
            IList<ITeam> list = getMallTeamByCataid(type);
            sb = GetStr(list);
        }
        Response.Write(sb.ToString());
    }
    protected StringBuilder GetStr(IList<ITeam> list)
    {
        StringBuilder sb = new StringBuilder();
        int i = 0;
        if (list != null && list.Count > 0)
        {
            sb.Append(" <ul class=\"lh style3\">");
            foreach (var team in list)
            {
                i++;
                sb.Append("<li class=\"fore" + i + "\">");
                sb.Append("<div class=\"p-img ld\">");
                sb.Append("<a target=\"_blank\" href=" + getTeamPageUrl(team.Id) + " title=" + team.Product + "><img height=\"100\" alt=" + team.Product + " data-img=\"1\" src=\"" + team.Image.ToString() + "\"" + "></a></div>");
                sb.Append("<div class=\"p-name\">");
                sb.Append("<a target=\"_blank\" href=" + getTeamPageUrl(team.Id) + " title=" + team.Product + ">" + team.Product + "</a>");
                sb.Append("</div>");
                sb.Append("<div class=\"p-price\">");
                sb.Append("<span>" + ASSystemArr["Currency"] + "</span>" + "<span>" + GetMoney(team.Team_price) + "</span>");
                sb.Append("</div> ");
                sb.Append("</li>");
            }
            sb.Append("</ul>");
        }
        return sb;
    }
    protected IList<ITeam> getMallTeamByCataid(string type)
    {
        IList<ITeam> iListTeam = null;
        TeamFilter teamfilter = new TeamFilter();
        if (type == "grab")
        {
            string sql = "select top 5 * from team where teamcata=0 and (Team_type='normal' or Team_type='draw')  and Begin_time<='" + DateTime.Now.ToString() + "' and end_time>='" + DateTime.Now.ToString() + "' order by  sort_order desc,Begin_time desc,id desc ";
            using (IDataSession session = Store.OpenSession(false))
            {
                iListTeam = session.Teams.GetList(sql);
            }
            return iListTeam;
        }
        else
        {
            if (type == "mhot")
                teamfilter.teamhost = 2;
            else if (type == "mtui")
                teamfilter.teamhost = 3;
            else if (type == "msale")
                teamfilter.teamhost = 4;
            else
                return iListTeam;
        }
        teamfilter.teamcata = 1;
        teamfilter.mallstatus = 1;
        teamfilter.Top = 5;
        teamfilter.AddSortOrder(TeamFilter.MoreSort);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListTeam = session.Teams.GetList(teamfilter);
        }
        return iListTeam;
    }
    protected IList<ITeam> getMallTeamByCataid(int cataid)
    {
        IList<ITeam> iListTeam = null;
        TeamFilter teamfilter = new TeamFilter();
        teamfilter.teamcata = 1;
        teamfilter.mallstatus = 1;
        teamfilter.Top = 10;
        teamfilter.AddSortOrder(TeamFilter.MoreSort);
        if (cataid != 0)
        {
            teamfilter.CataID = cataid;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListTeam = session.Teams.GetList(teamfilter);
        }
        return iListTeam;
    }
</script>
