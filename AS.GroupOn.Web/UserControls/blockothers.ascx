<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
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
    protected bool display;
    protected int teamdetailnum = 0;
    protected int top = 0;
    protected IList<ITeam> otherteams = null;
    public NameValueCollection _system = new NameValueCollection();
    public Dictionary<string, object> values = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Init();
    }

    public override void UpdateView()
    {
        values = Params as Dictionary<string, object>;
        //teamid,strOtherTeamid,strview
        Init();
        if (values != null)
            UpdateView(Convert.ToInt32(values["teamid"]), values["strOtherTeamid"].ToString(), values["strview"].ToString());
    }

    public override string CacheKey
    {
        get
        {
            if (values != null && values["teamid"] != null)
                return "cacheusercontrol-otherteam-" + values["teamid"].ToString();
            return String.Empty;
        }
    }
    public override bool CanCache
    {
        get
        {
            return true;
        }
    }

    protected void Init()
    {
        _system = WebUtils.GetSystem();
        celanTitle();
        getCurrency();
    }

    public void UpdateView(int teamid, string strOtherTeamid, string strview)
    {

        TeamFilter tf = new TeamFilter();
        strOtherTeamid = Helper.DelSideChar(strOtherTeamid, ',');
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ASSystem = session.System.GetByID(1);
        }
        if (ASSystem != null)
        {
            tf.Top = ASSystem.sideteam;

            if (tf.Top != 0)
            {

                if (strview == "teamview")
                {
                    if (strOtherTeamid != "")
                    {
                        tf.IdnotIn = strOtherTeamid;
                    }
                }
                if (CurrentCity != null)
                {
                    tf.Cityblockothers = CurrentCity.Id;
                }
                else
                {
                    tf.DA_City_id = 0;
                }
                tf.teamcata = 0;
                tf.Team_type = "normal";
                tf.No_Id = teamid;
                tf.ToBegin_time = DateTime.Now;
                tf.FromEndTime = DateTime.Now;
                using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    otherteams = seion.Teams.GetBlockOthers(tf);
                }

            }
        }
    }

    public void celanTitle()
    {

        if (WebUtils.config["displayTitle"] == "1")
        {
            display = true;
        }
        else
        {
            display = false;
        }

        if (WebUtils.config["teamdetailnum"] != null && WebUtils.config["teamdetailnum"].ToString() != "")
        {
            teamdetailnum = Helper.GetInt(WebUtils.config["teamdetailnum"], 0);
        }
    }
    public void getCurrency()
    {
        if (ASSystem != null && ASSystem.currency != "")
        {
            Currency = ASSystem.currency;
        }
        else
        {
            Currency = "￥";
        }
    }
</script>
<%
    if (otherteams != null && otherteams.Count > 0)
    { %>
<div class="sbox side-business">
    <div class="sbox-content">
        <div class="r-top">
        </div>
        <h3>
            正在团购...</h3>
        <div class="tip">
            <%
                foreach (ITeam team in otherteams)
                {
                    
            %>
            <div class="buy-other">
               
                    <% if (display)
                       { %>
                     <h4>
                    <a href='<%=getTeamPageUrl(team.Id)  %>'><%=team.Title%></a>
                    </h4>

                    <% }
                     %>
                
                <%if (team.Image != String.Empty)
                  { %><p>
         <a href='<%=getTeamPageUrl(team.Id)  %>'>
             <img src='<%=ImageHelper.getSmallImgUrl( team.Image) %>' width="208" border="0" /></a></p>
                <%} %>
                <div class="buy-info">
                    <div class="yigoumai">
                        <p class="xyigm">
                            <%=team.Now_number%>
                            <span>人已购买</span></p>
                        <p>
                            <a href='<%=getTeamPageUrl(team.Id)  %>'>
                            <image src="<%=ImagePath()%>qg_bt.png"></image>
                            </a>
                        </p>
                    </div>
                </div>
            </div>
            <%
        } %>
        </div>
        <div class="r-bottom">
        </div>
    </div>
</div>
<%}
%>