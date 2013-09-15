<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected System.Collections.Generic.IList<IBranch> branches = null;
    protected IPartner partner = null;
    protected string mapInfo = String.Empty;//地图信息
    protected int tid = 0;
    protected ITeam teammodel = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        tid = Helper.GetInt(Request["id"], 0);
        using (IDataSession session = Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(tid);
        }
        if (teammodel != null && teammodel.Partner != null)
        {
            partner = teammodel.Partner;
            if (!String.IsNullOrEmpty(partner.point) && partner.point.IndexOf(",") >= 0)
            {
                string[] points = partner.point.Split(',');
                mapInfo = points[1] + "," + points[0];
            }
            BranchFilter bf = new BranchFilter();
            bf.partnerid = teammodel.Partner.Id;
            using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
            {
                branches = seion.Branch.GetList(bf);
            }
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<script src="http://api.map.baidu.com/api?v=1.2" type="text/javascript"></script>
<body id="deal-detail">
    <header>
        <div class="left-box">
            <a class="go-back" href="javascript:history.back()"><span>返回</span></a>
        </div>
        <h1>地图详情</h1>
    </header>
    <div id="address">
        <%if (partner != null)
          {%>
        <div>
            <h1>
                <%=partner.Title%></h1>
            <%if (partner.Address != null && partner.Address.ToString() != "")
              { %>
            <p>
                <%=partner.Address%>
            </p>
            <%} %>
            <%if (partner.Phone != null && partner.Phone != "")
              { %>
            <a class="phone" href="tel:<%=partner.Phone%>">&#9742;
                <%=partner.Phone%></a>
            <%}%>
        </div>
        <%if (mapInfo != String.Empty)
          {%>
        <div id="map_canvas" style="width: 196px; height: 196px;">
        </div>
        <script type='text/javascript'>
            var map = new BMap.Map("map_canvas");
            var point = new BMap.Point(<%=mapInfo%>);
            map.centerAndZoom(point, 15);
            var marker = new BMap.Marker(point);
            map.addOverlay(marker);
            marker.setAnimation(BMAP_ANIMATION_BOUNCE);
        </script>
        <%}%>
        <%if (branches != null && branches.Count > 0)
          {%>
        <%foreach (var item in branches)
          {%>
        <div>
            <h1>
                <%=item.branchname%></h1>
            <%if (!String.IsNullOrEmpty(item.address))
              { %>
            <p>
                <%=item.address%>
            </p>
            <%} %>
            <%if (!String.IsNullOrEmpty(item.phone))
              { %>
            <a class="phone" href="tel:<%=item.phone%>">&#9742;
                <%=item.phone%></a>
            <%}%>
            <%if (!String.IsNullOrEmpty(item.mobile))
              { %>
            <a class="phone" href="tel:<%=item.mobile%>">&#9742;
                <%=item.mobile%></a>
            <%}%>
        </div>
        <%if (!String.IsNullOrEmpty(item.point))
          { %>
        <%string[] poin = item.point.Split(','); %>
        <div id="<%=item.id %>" style="width: 196px; height: 196px;">
        </div>
        <script type='text/javascript'>
            var map = new BMap.Map("<%=item.id %>");
            var point = new BMap.Point(<%=poin[1] + "," + poin[0]%>);
            map.centerAndZoom(point, 15);
            var marker = new BMap.Marker(point);
            map.addOverlay(marker);
            marker.setAnimation(BMAP_ANIMATION_BOUNCE);
        </script>
        <%}%>
        <%}%>
        <%}%>
        <%}%>
        <aside>
            <h1>消费提示</h1>
            <%if (!String.IsNullOrEmpty(teammodel.Notice))
              {%>
            <%=teammodel.Notice%>
            <%}%>
        </aside>
    </div>
    <%LoadUserControl("_footer.ascx", null); %>
    <%LoadUserControl("_htmlfooter.ascx", null); %>