<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>

<script runat="server">

    protected TeamFilter teamfilter = new TeamFilter();
    protected IList<ITeam> iListTeam = null;
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!String.IsNullOrEmpty(Request["cityid"]))
        {
            if (!Helper.isEmpity(Request["cityid"]))
            {
                teamfilter.City_ids = Helper.GetString(Request["cityid"], String.Empty);
            }
        }
        if (Request["nostartteam"] != "1")
        {
            teamfilter.State = TeamState.Nowing;
            teamfilter.Team_type = "normal";
        }
        else
        {
            teamfilter.FromEndTime = DateTime.Now;
            teamfilter.Team_type = "normal";
        }
        teamfilter.AddSortOrder(TeamFilter.City_id_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListTeam = session.Teams.GetList(teamfilter);
        }
    }

    public string GetMoney(object price)
    {

        string money = String.Empty;
        if (price != null)
        {
            Regex regex = new Regex(@"^(\d+)$|^(\d+.[1-9])0$|^(\d+).00$");
            Match match = regex.Match(price.ToString());
            if (match.Success)
            {
                money = regex.Replace(match.Value, "$1$2$3");
            }
            else
                money = price.ToString();
        }
        return money;
    }
    
</script>
<script language="javascript">
    function correctPNG() {
        for (var i = 0; i < document.images.length; i++) {
            var img = document.images[i]
            var imgName = img.src.toUpperCase()
            if (imgName.substring(imgName.length - 3, imgName.length) == "PNG") {
                var imgID = (img.id) ? "id='" + img.id + "' " : ""
                var imgClass = (img.className) ? "class='" + img.className + "' " : ""
                var imgTitle = (img.title) ? "title='" + img.title + "' " : "title='" + img.alt + "' "
                var imgStyle = "display:inline-block;" + img.style.cssText
                if (img.align == "left") imgStyle = "float:left;" + imgStyle
                if (img.align == "right") imgStyle = "float:right;" + imgStyle
                if (img.parentElement.href) imgStyle = "cursor:hand;" + imgStyle
                var strNewHTML = "<span " + imgID + imgClass + imgTitle
   + " style=\"" + "width:" + img.width + "px; height:" + img.height + "px;" + imgStyle + ";"
+ "filter:progid:DXImageTransform.Microsoft.AlphaImageLoader"
   + "(src=\'" + img.src + "\', sizingMethod='scale');\"></span>"
                img.outerHTML = strNewHTML
                i = i - 1
            }
        }
    }
    window.attachEvent("onload", correctPNG); 
</script>
<style type="text/css">
<!--
body {
	font-size: 12px;
	margin: 0px;
	padding: 0px;
	font-family: "微软雅黑，宋体,arial";
}
.content {
	padding: 15px 20px;
        width: 720px;
	    margin-right: auto;
	    margin-left: auto;
	    border: 5px solid #30afc0;
	    overflow: hidden;
	    height: 554px;
    }
.cp_content {
	float: left;
	width: 675px;
	border: 1px solid #30afc0;
	padding: 10px;
	background-color: #FFF;
	margin-bottom: 10px;
}
.content tr td .cp_content tr td p strong a {
	color: #000;
	text-decoration:none
}
.content tr td .cp_content tr td table tr td table tr td strong a {
	color: #FFF;
	text-decoration: none;
}
.content tr td .cp_content tr td table tr td table tr td a {
	color: #0066cc;
}
-->
</style>
<table cellspacing="0" cellpadding="5" border="0" align="center" width="675" bgcolor="#a3dcef" class="content">
  <tr>
    <td bgcolor="#007b9c" width="240"><a target="_blank" href=""><img src="..<%= PageValue.CurrentSystem.headlogo %>" width="264" height="58"  border="0"/></a></td>
    <td bgcolor="#007b9c" width="300" style="color:#FFF; font-size:18px;"></td>
    <td align="center" valign="middle" bgcolor="#007b9c" style="color:#FFF"><%=DateTime.Now.ToString("yyyy-MM-dd") %></td>
  </tr>
  <tr><td></td></tr>
  

  <tr>
       <td colspan="3">
       
       
         <!--循环开始-->
         <%foreach (ITeam iteamInfo in iListTeam)
           {
                %>
            <table cellspacing="0" cellpadding="0" border="0" bgcolor="#30afc0" class="cp_content">
  <tr>
    <td colspan="3" bgcolor="#FFFFFF"><p style="font-size:26px; margin:0; padding:0; line-height:35px;"><strong>
    
    <%if (iteamInfo.TeamCategoryInfo != null)
      { %>

      【<%=iteamInfo.TeamCategoryInfo.Name%>】
    <% }%>
    <a href="<%= PageValue.WWWprefix.Substring(0, PageValue.WWWprefix.LastIndexOf("/"))  %><%=getTeamPageUrl(iteamInfo.Id)%>" target="_blank"><%=iteamInfo.Title %></a></strong></p></td>
  </tr>
  <tr bgcolor="#FFFFFF">
    <td><table cellspacing="0" cellpadding="0" border="0" width="235">
      <tr>
        <td>
           <table style="background-image:url(<%=PageValue.WWWprefix.Substring(0, PageValue.WWWprefix.LastIndexOf("/"))  %><%=PageValue.WebRoot%>upfile/css/i/mail-tpl-tag.gif); width:236px; height:60px;">
              <tr> 
                  <td width="120" style="color:#FFFFFF; font-size:20px; font-weight:bold;" align="center"><%=PageValue.CurrentSystem.currency %><%=iteamInfo.Team_price%></td>
                  <td>&nbsp;</td>
                  <td><a href="<%= PageValue.WWWprefix.Substring(0, PageValue.WWWprefix.LastIndexOf("/"))  %><%=getTeamPageUrl(iteamInfo.Id)%>" target="_blank"><img src="<%=PageValue.WWWprefix.Substring(0, PageValue.WWWprefix.LastIndexOf("/"))  %><%=PageValue.WebRoot%>upfile/css/i/button-deal-buy.gif" width="86" height="40"  border="0"/></a></td>
              </tr>
           </table>
         </td>
      </tr>
      <tr>
        <td width="230" height="50"><table cellspacing="0" cellpadding="0" border="0" style="font-size:12px; font-weight:bold;">
          <tr>
            <td width="90" height="25" align="center" valign="middle" bgcolor="#d0eef6">原价</td>
            <td width="80" align="center" valign="middle" bgcolor="#d0eef6">降幅</td>
            <td width="70" align="center" valign="middle" bgcolor="#d0eef6">节省</td>
          </tr>
          <tr>
            <td width="50" height="25" align="center" valign="middle" bgcolor="#d0eef6"><%=PageValue.CurrentSystem.currency%><%=GetMoney(iteamInfo.Market_price) %></td> 
            <td width="50" align="center" valign="middle" bgcolor="#d0eef6"><%=WebUtils.GetDiscount(Helper.GetDecimal(iteamInfo.Market_price, 0), Helper.GetDecimal(iteamInfo.Team_price, 0))%></td>
            <td width="50" align="center" valign="middle" bgcolor="#d0eef6"><%=PageValue.CurrentSystem.currency%><%=GetMoney((Helper.GetDecimal(iteamInfo.Market_price, 0) - Helper.GetDecimal(iteamInfo.Team_price, 0)).ToString())%></td>
          </tr>
        </table>


        <%if (iteamInfo.Partner != null)
          { %>
          <table cellspacing="0" cellpadding="0" border="0">
            <tr>
              <td>&nbsp;</td>
            </tr>
            <tr>
              <td style="font-size:14px;"><strong>商家信息：</strong></td>
            </tr>
            <tr>
              <td align="right" valign="middle" width="230" style="line-height:25px; font-size:14px;"><strong><%=iteamInfo.Partner.Title %></strong><br />
                <a href=" <%=iteamInfo.Partner.Homepage %>">访问网站</a><br />
                位置:<br />
                <%=iteamInfo.Partner.Location%> </td>
            </tr>
          </table>
          <% }%>
          </td>
      </tr>
    </table></td>
    <td>
    <table>
      <tr>
      
        <td><a href="<%=PageValue.WWWprefix.Substring(0, PageValue.WWWprefix.LastIndexOf("/"))  %><%=getTeamPageUrl(iteamInfo.Id)%>" target="_blank"><img src="<%=PageValue.WWWprefix.Substring(0, PageValue.WWWprefix.LastIndexOf("/"))%><%=iteamInfo.Image %>" width="405" height="258" border="0"/></a></td>
      </tr>
      <tr>
        <td align="right" valign="middle" width="400" style="line-height:2;"><%=iteamInfo.Summary%></td>
      </tr>
      <tr>
        <td align="right" valign="middle" height="25">
           <table>
                <tr>
                    <td width="120" height="25" align="center" valign="middle" bgcolor="#ff6600" style="color:#FFF"><strong><a href="<%=PageValue.WWWprefix.Substring(0, PageValue.WWWprefix.LastIndexOf("/"))  %><%=getTeamPageUrl(iteamInfo.Id)%>" target="_blank">查看详情《</a></strong></td>
                </tr>
           </table>
        </td>
        
      </tr>
      <!-- <p style="width:130px; height:50px; background-color:#ff6600"></p>-->
    </table></td>
    <td></td>
    </table>
   <% }%>
<!--循环结束-->   

       </td>
  </tr>
    
  </tr>
</table>

