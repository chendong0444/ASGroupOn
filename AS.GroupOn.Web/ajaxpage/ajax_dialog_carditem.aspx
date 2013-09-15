<%@ Page Language="C#" AutoEventWireup="true" Debug="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<head>
    <style type="text/css">
        .formbutton
        {
            width: 118px;
        }
        #consult_content
        {
            height: 118px;
            width: 299px;
        }
    </style>
</head>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 620px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span></h3>
    </div>
    <asp:literal id="Literal1" runat="server"></asp:literal>
    <asp:literal id="Literal2" runat="server"></asp:literal>
</div>

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        //需要登录
        NeedLogin();
        if (Request["partnerId"] != null && Request["partnerId"].ToString() != "")
        {
            int partnerId = int.Parse(Request["partnerId"].ToString());
            //Maticsoft.BLL.Team bllTeam = new Maticsoft.BLL.Team();
            //Maticsoft.Model.Team team = new Maticsoft.Model.Team();
            
            
            //DataSet ds = bllTeam.GetList(" Partner_Id= " + partnerId);
            IList<ITeam> teamlist = null;
            TeamFilter teamfil = new TeamFilter();
            teamfil.Partner_id = partnerId;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teamlist = session.Teams.GetList(teamfil);
            }
            
            StringBuilder stB1 = new StringBuilder();
            StringBuilder stB2 = new StringBuilder();
            stB1.Append("<div><h4>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;商品名称</h4></div>");
            stB2.Append("<table class='coupons-table' id='orders-list' width='600px'>");
            for (int i = 0; i < teamlist.Count; i++)
            {
                if ((i + 1) % 2 == 0)
                {
                    stB2.Append("<tr><td>");
                }
                else
                {
                    stB2.Append("<tr class='alt'><td>");
                }
                stB2.Append((i + 1) + "." + teamlist[i].Title);
                stB1.Append("<td></tr>");
            }
            stB2.Append("</table>");
            Literal1.Text = stB1.ToString();
            Literal2.Text = stB2.ToString();
        }
    }
    </script>