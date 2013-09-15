<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<script runat="server">
    protected string output = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NameValueCollection _system = new NameValueCollection();
        _system = WebUtils.GetSystem();
        int teamid = Helper.GetInt(Request["Id"], 0);
        if (teamid > 0)
        {
            ITeam team = Store.CreateTeam();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                team = session.Teams.GetByID(teamid);
            }
            if (team != null)
            {
                if (team.City_id > 0) CookieUtils.SetCookie("cityid", team.City_id.ToString(), DateTime.Now.AddYears(1));
                if (team.teamscore > 0)
                {
                    Response.Redirect(GetUrl("积分详情", "pointsshop_index.aspx?id=" + team.Id));
                    Response.End();
                    return;
                }
                if (team.Team_type == "normal")
                {
                    output = WebUtils.LoadPageString(PageValue.TemplatePath + "team_view.aspx?id=" + team.Id);
                }
                else if (team.Team_type == "seconds")
                {
                    output = WebUtils.LoadPageString(PageValue.TemplatePath + "team_view_seconds.aspx?id=" + team.Id);
                }
                else
                {
                    output = WebUtils.LoadPageString(PageValue.TemplatePath + "team_view_goods.aspx?id=" + team.Id);
                }
            }
            else
            {
                Response.Write("不存在此项目");
            }
        }
    }
</script>
<%=output %>
