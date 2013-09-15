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
    protected IList<ITeam> otherteams = null;
    protected string Currency;
    NameValueCollection _system = new NameValueCollection();
    protected int i = 1;
    protected bool display;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        celanTitle();
        getCurrency();
    }

    public void UpdateView(int teamid)
    {

        TeamFilter tf = new TeamFilter();
        int top = 0;
        if (ASSystem != null)
        {
            tf.Top = ASSystem.sideteam;
            if (top != 0)
            {
                if (CurrentCity != null)
                {
                    tf.Cityblockothers = CurrentCity.Id;
                }
                else
                {
                    tf.DA_City_id = 0;
                }
                tf.teamcata = 0;
                tf.Team_type = "point";
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
<%if (otherteams != null && otherteams.Count > 0)
  { %>
<div class="sbox side-business">

    <div class="sbox-content">
        <div class="r-top"></div>
        <h3>正在兑换...</h3>
        <div class="tip">
            <%foreach (ITeam team in otherteams)
              { %>
            <% if (display)
               { %>
            <a style="display: block; color: Black;" href="<%=GetUrl("积分详情","pointsshop_index.aspx?id="+team.Id )%>"><b><%=i%>、<%=team.Title%></b></a>
            <% }
               else
               {%>
            <a style="display: none; color: Black;" href="<%=GetUrl("积分详情","pointsshop_index.aspx?id="+team.Id )%>"><b><%=i%>、<%=team.Title%></b></a>
            <%}%>
            <%if (team.Image != String.Empty)
              { %><p><a href="<%=GetUrl("积分详情","pointsshop_index.aspx?id="+team.Id )%>">
                <img src="<%=team.Image %>" width="195" border="0" /></a></p>
            <%} %>
            <div class="price_nr">
                <a href="<%=GetUrl("积分详情","pointsshop_index.aspx?id="+team.Id )%>">

                    <p class="xianjia">积分:<%=team.teamscore %></p>
                    <p style="float: left; width: 90px; color: #000; text-decoration: line-through;">原价：<%=ASSystem.currency %><%=team.Market_price %> </p>
                </a>
            </div>
            <div class="yigoumai">
                <p class="xyigm"><%=team.Now_number %> <span style="color: #666">人已兑换</span></p>
                <p><a href="<%=GetUrl("积分详情","pointsshop_index.aspx?id="+team.Id )%>">
                    <image src="<%=ImagePath() %>qg_bt.png"></image>
                </a></p>
            </div>

            <% i++;
              } %>
        </div>
        <div class="r-bottom"></div>
    </div>

</div>
<%} %>