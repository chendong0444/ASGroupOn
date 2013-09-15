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
<%@ Import Namespace="System.Data" %>
<script runat="server">
    protected string Currency;
    NameValueCollection _system = new NameValueCollection();
    protected ISystem system = Store.CreateSystem();
    protected IList<ITeam> otherteams = null;
    protected int i = 1;
    protected bool display;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        celanTitle();
        getCurrency();

    }
    public override void UpdateView()
    {
        UpdateView(CurrentTeam.Id);
    }
    
    public void UpdateView(int teamId)
    {
        TeamFilter tf = new TeamFilter();
        tf.Top = 1;// ASSystem.sideteam;
        //if (CurrentCity != null)
        //{
        //    tf.Cityblockothers = CurrentCity.Id;
        //}
        //else
        //{
        //    tf.DA_City_id = 0;
        //}
        tf.teamcata = 0;
        tf.Team_type = "seconds";
        tf.No_Id =teamId;
        tf.ToBegin_time = DateTime.Now;
        tf.FromEndTime = DateTime.Now;
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            otherteams = seion.Teams.GetBlockOthers(tf);
        }

    }

    public void celanTitle()
    {

        _system = WebUtils.GetSystem();
        if (_system != null)
        {

            if (_system["displayTitle"] == "1")
            {
                display = true;
            }
            else
            {
                display = false;
            }
        }
    }
    public void getCurrency()
    {
        using (IDataSession seion = Store.OpenSession(false))
        {
            system = seion.System.GetByID(1);
        }
        if (system != null && system.currency != "")
        {
            Currency = system.currency;
        }
        else
        {
            Currency = "￥";
        }
    }

</script>
<%if (otherteams != null && otherteams.Count > 0)
  { %>
<div class="sbox side-business">
    <div class="sbox-content">
        <div class="r-top">
        </div>
        <h3>
            正在秒杀...</h3>
        <div class="tip">
            <%foreach (ITeam team in otherteams)
              { %>
            <% if (display)
               { %>
            <a style="display: block; color: Black;" href="<%=getTeamPageUrl(team.Id)%>"><b>
                <%=i%>、<%=team.Title%></b></a>
            <% }
               else
               {%>
            <a style="display: none; color: Black;" href="<%=getTeamPageUrl(team.Id)%>"><b>
                <%=i%>、<%=team.Title%></b></a>
            <%}%>
            <%if (team.Image != String.Empty)
              { %><p>
                  <a href="<%=getTeamPageUrl(team.Id)%>">
                      <img src="<%=ImageHelper.getSmallImgUrl(team.Image)%>" width="208" border="0" /></a></p>
            <%} %>
            <div class="yigoumai">
                <p class="xyigm">
                    <%=team.Now_number %>
                    <span style="color: #666">人已购买</span></p>
                <p>
                    <a href="<%=getTeamPageUrl(team.Id)%>">
                        <image src="<%=ImagePath() %>qg_bt.png"></image>
                    </a>
                </p>
            </div>
            <% i++;
              } %>
        </div>
        <div class="r-bottom">
        </div>
    </div>
</div>
<%} %>
