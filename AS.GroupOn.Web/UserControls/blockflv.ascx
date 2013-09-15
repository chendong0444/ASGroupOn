<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script runat="server">
    protected ITeam team = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

    }
    public void UpdateView(ITeam _team)
    {
        team = _team;

    }
    public override void UpdateView()
    {
        ITeam _team = Params as ITeam;
        if (_team != null)
            UpdateView(_team);
    }

</script>
<%if(team!=null&&team.Flv!=String.Empty){ %>

<div class="sbox">
	<div id="team_<%=team.Id %>_player" style="height:210px;width:230px;"><img src="/upfile/team/<%=team.Image %>" height="210" width="230" /></div>
</div>
<script>
    window.x_init_hook_player = function () {

        var fo = new SWFObject("<%=WebRoot %>upfile/img/player.swf", "flv_player", "100%", "100%", 7, "#FFFFFF");
        fo.addParam("flashvars", "file=<%=team.Flv %>&amp;stretching=fill&amp;image=/upfile/team/<%=team.Image %>");
        fo.addParam("wmode", "transparent");
        fo.addParam("allowscriptaccess", "always");
        fo.addParam("allowfullscreen", "true");
        fo.addParam("quality", "high");
        fo.write("team_<%=team.Id %>_player");
    }
</script>
<%} %>