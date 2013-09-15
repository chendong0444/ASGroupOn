<%@ Page AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage"
    Language="C#" %>

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
    
    protected NameValueCollection mail = new NameValueCollection();
    protected NameValueCollection city = new NameValueCollection();
    protected NameValueCollection team = new NameValueCollection();
    protected NameValueCollection partner = new NameValueCollection();
    protected string today = DateTime.Now.ToString("yyyy-MM-dd");
    protected override void OnLoad(EventArgs e)
    {


        base.OnLoad(e);
        int mailid = Helper.GetInt(Request["mailid"], 0);
        int teamid = Helper.GetInt(Request["teamid"], 0);
        if (mailid > 0)
        {
            IMailer mailerr = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                mailerr = session.Mailers.GetByID(mailid);
            }
            mail = Helper.GetObjectProtery(mailerr);
            if (mailerr.City_id > 0)
            {
                ICategory mcity = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mcity = session.Category.GetByID(mailerr.City_id);
                }
                city = Helper.GetObjectProtery(mcity);
            }
        }
        if (teamid > 0)
        {
            ITeam teamm = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teamm = session.Teams.GetByID(teamid);
            }
            team = Helper.GetObjectProtery(teamm);
            if (teamm.Partner_id > 0)
            {
                IPartner partnerm = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    partnerm = session.Partners.GetByID(teamm.Partner_id);   
                }                
                partner = Helper.GetObjectProtery(partnerm);

            }
        }
    }
    
    
     </script>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Strict//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="robots" content="noindex, nofollow">
</head>
<body bgcolor="#ffffff" style='padding:10px; width:720px; margin:0 auto;'>
<style type='text/css'>
body {font-family:Helvetica, Arial, sans-serif; color:#000;}
table{ table-layout:fixed;}
table td{ table-layout:fixed; float:left;}
a { color: #399; text-decoration:none;}
a:hover { color: #399; text-decoration:none; }
p { line-height: 1.5em; }
</style>

<table cellpadding='0' cellspacing='0' width='670px'>
    <tr>
        <td>
            <p style='margin:0; padding:0; font-size:14px; color:#000; font-family: Helvetica, Arial, sans-serif;text-align:center; font-size:12px; color:#929292;'>如不想继续收<%=ASSystemArr["abbreviation"]%>每日推荐邮件，您可随时<a href="<%=WWWprefix %>unsubscribe.aspx?code=<%=mail["secret"] %>" style="" title="取消订阅">取消订阅</a>。</p>
            <p style='margin:0; padding:0; font-size:14px; color:#000; font-family: Helvetica, Arial, sans-serif;text-align:center;font-size:12px; color:#929292; '>请把 <a href="mailto:<%=ASSystemArr["mailfrom"] %>" style="" title=""><%=ASSystemArr["mailfrom"] %></a> 加到您的邮箱联系人中，以确保能正确接收此邮件。</p>
        </td>
    </tr>
</table>

<!-- content -->
<div style='width:670px; margin:5px 0; padding: 20px 20px 20px 20px; background-color:#993300;background-image: url(<%=WWWprefix%><%=ImagePath() %>bg-deal.jpg);background-repeat: no-repeat;background-position: center top; border-width:5px; border-style: solid; border-color:#deedcc;-moz-border-radius:10px;-webkit-border-radius:10px; position:relative; overflow:hidden;'>

<table cellpadding='0' cellspacing='0' style='background-color:#fff; -moz-border-radius-topright:8px; -moz-border-radius-topleft:8px; -webkit-border-top-right-radius:8px; -webkit-border-top-left-radius:8px; overflow:hidden; _display:inline;' width='630px'>
<!--内容 header-->
<tr style=" width:630px;">
    <td colspan='2'>
        <div id='mail-header' style='height:104px; margin: 0; -moz-border-radius-topright:8px; -moz-border-radius-topleft:8px; -webkit-border-top-right-radius:8px; -webkit-border-top-left-radius:8px; border-bottom:4px solid #338888; width:670px;'>
            <table cellpadding='0' cellspacing='0' height='104px' width='620px'>
          <tr>
                    <td width="110px" style='height:30px; padding:25px 0 0 20px;' valign='top'><a href="<%=WWWprefix%>index.aspx" title="<%=ASSystemArr["sitename"] %>"><img alt="<%=ASSystemArr["sitename"] %>" src="<%= WWWprefix %><%=ASSystemArr["Emaillogo"].ToString().Substring(1)%>" style="border: 0px; margin:0 auto; float:left;"  /></a></td>
              <td width="250px" style='padding-left:15px;padding-top:38px;_padding-top:8px; text-align:center;color:#FFF;font-weight:bold;' valign='top'><%=city["name"] %></td>
                    <td width="220px" align='left' style='padding-right:20px; padding-top:43px;_padding-top:3px;' valign='top'>
                        <table cellpadding='0' cellspacing='0' width='225px;'>
                            <tr>
                                <td align='left' style='margin:0; color:#fff; font-size:12px; font-family: Helvetica, Arial, sans-serif;'><%=today %></td> </tr>
                            <tr>
                                <td align='left' style='padding-top:15px;'></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>
    </td>
</tr>
<!--内容 header end-->
<!--内容 content-->
<tr>
<td style='padding:20px 0 25px 0; border-top:10px solid #44ABAF; width:630px;' valign='top'>
<table cellpadding='0' cellspacing='0' width='600px'>
    <!-- TR 1 -->
    <tr>
        <td colspan='2' style="padding: 0 20px 20px 20px; width:600px">
            <h1 style='margin:0; padding:0; line-height:1.2; width:600px; '><a href="<%=WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot+getTeamPageUrl(Helper.GetInt(team["id"],0))%>&c=maillist" style="text-decoration:none; font-size:30px; font-weight:700; font-family:'黑体',Helvetica, Arial, sans-serif; margin:0;" title="<%=team["title"] %>"><%=team["title"] %></a></h1>
        </td>
    </tr>
    <!-- TR 2 -->
    <tr>
        <td style='padding:0 15px 0 4px; width:233px;' valign='top'>
            <table background='<%=WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot %><%=ImagePath().ToString().Substring(1) %>mail-tpl-tag.gif' bgcolor='#4BC1DD' cellpadding='0' cellspacing='0' height='60px' width='233px'>
                <tr>
                    <td style='padding-left:30px; font-size:28px; color:#fff; font-weight:700; font-family: Helvetica, Arial, sans-serif;'>&#165;<%=team["team_price"] %></td>
                    <td style='padding-left:0px; padding-top:2px;'><a href="<%=WWWprefix.Substring(0, WWWprefix.LastIndexOf("/"))+getTeamPageUrl(Helper.GetInt(team["id"],0)) %>" title="<%=team["title"] %>"><img alt="<%=team["title"] %>" src="<%=WWWprefix %><%=ImagePath().ToString().Substring(1) %>mail-tpl-view.gif" style="border:none;" /></a></td>
                </tr>
            </table>
                        <div style='padding-left:10px;'>
                <table cellpadding='0' cellspacing='0' width='216px'>
                    <tr style='background-color:#d0eef6;'>
                        <td width='72px' align='center' style='margin:0; padding:0; font-size:14px; color:#000; font-family: Helvetica, Arial, sans-serif;border-left:1px solid #4bc1dd; font-size:12px; padding:10px 0 5px 0;'>原价</td>
                        <td width='72px' align='center' style='margin:0; padding:0; font-size:14px; color:#000; font-family: Helvetica, Arial, sans-serif;font-size:12px; padding:10px 0 5px 0;'>折扣</td>
                        <td width='72' align='center' style='margin:0; padding:0; font-size:14px; color:#000; font-family: Helvetica, Arial, sans-serif;border-right:1px solid #4bc1dd; font-size:12px; padding:10px 0 5px 0;'>节省</td>
                    </tr>
                    <tr style='background-color:#d0eef6;'>
                        <td width='72' align='center' style='border-left:1px solid #4bc1dd; border-bottom:1px solid #4bc1dd; font-size:14px; font-weight:700; color:#000; font-family: Helvetica, Arial, sans-serif;; margin:0; padding:0 0 5px 0;'>&#165;<%=team["market_price"] %></td>
                        <td width='72' align='center' style='border-bottom:1px solid #4bc1dd; font-size:14px; font-weight:700; color:#000; font-family: Helvetica, Arial, sans-serif;; margin:0; padding:0 0 5px 0;'><%if(team["team_price"]!=String.Empty&&team["market_price"]!=String.Empty){ %><%=WebUtils.GetDiscount(Convert.ToDecimal(team["market_price"]),Convert.ToDecimal(team["team_price"])) %>>折<%} %></td>
                        <td width='72px' align='center' style='border-right:1px solid #4bc1dd; border-bottom:1px solid #4bc1dd; font-size:14px; font-weight:700; color:#000; font-family: Helvetica, Arial, sans-serif;; margin:0; padding:0 0 5px 0;'>&#165;<%=(Convert.ToDecimal(team["market_price"])-Convert.ToDecimal(team["team_price"])) %></td>
                    </tr>
                </table>
            </div>
                                    <div style='padding:8px 0 0 17px; table-layout:fixed;'>
                <table cellpadding='0' cellspacing='0' width='216px'>
                    <tr>
                        <td style='border:1px solid #e8e8e8; width:217px; height:116px; padding:0 5px 10px 15px;'>
                            <table cellpadding='0' cellspacing='0'>
                                <tr><td style='margin:0; padding:0; font-size:14px; color:#000; font-family: Helvetica, Arial, sans-serif;padding:10px 0 7px 0; font-size:16px; font-weight:bold; '><%=partner["title"] %></td></tr>
                                <tr>
                                    <td style='margin:0; padding:0; font-size:14px; color:#000; font-family: Helvetica, Arial, sans-serif;vetical-align:top; font-size:12px; '>
                                        <div style="margin:0; padding:0; font-size:14px; color:#000; font-family: Helvetica, Arial, sans-serif;; font-size:12px; "><%=partner["location"] %></div>
                                    </td>
                                </tr>
                                <tr>
                                    <td style='font-size:12px; color:#000; font-family: Helvetica, Arial, sans-serif; margin:0; padding:0;'></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </div>
                    </td>
        <td valign='top'>
            <a href="<%=WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot %>team.aspx?id=<%=team["id"] %>" title="<%=team["title"] %>"><img alt="<%=team["title"]%>" src="<%if(team["image"].ToString()!=""){ %><%=WWWprefix %><%=team["image"].ToString().Substring(1) %><% } %>" style="border:none;" title="<%=team["title"] %>" width="398" /></a>        </td>
    </tr>
    <!-- TR 3 -->
    <tr>
        <td colspan='2'>
            <table cellpadding='0' cellspacing='0' width='630px'>
                <tr>
                                        <td valign="top" style="margin:0; padding:20px 0 0 20px; line-height: 21px; font-size: 14px; color:#000; font-family: Helvetica,Arial,sans-serif;">
                        <table cellpadding='0' cellspacing='0' width='368px' style="margin:0; padding:0;">
                            <tr><td style="padding-bottom:5px; "><h3 style='font-size:16px; color:#000; font-family: Helvetica, Arial, sans-serif; margin:0;'>本单详情</h3></td></tr>
                            <tr>
                                <td>
                                    <div style="margin:0; padding:0; font-size:14px; color:#000; font-family: Helvetica, Arial, sans-serif; width:630px;" >
									<%=team["detail"] %>
									</div>
                                </td>
                            <tr><td style="padding-top:20px; padding-bottom:5px; "><h3 style='font-size:16px; color:#000; font-family: Helvetica, Arial, sans-serif; margin:0;'><%=ASSystemArr["abbreviation"] %>说</h3></td></tr>
                            <tr>
                                <td>
                                                                        <div style="margin:0; padding:0; font-size:14px; color:#000; font-family: Helvetica, Arial, sans-serif;"><%=team["summary"] %></div>
                                </td>
                            </tr>
                            <tr>
                                <td align="center" style="padding:5px 0; width:630px; ">
                                <a href="<%=WWWprefix.Substring(0, WWWprefix.LastIndexOf("/"))+getTeamPageUrl(Helper.GetInt(team["id"],0))%>" alt="查看更多"><img style="border:none;" src="<%=WWWprefix %><%=ASSystemArr["emaillogo"].ToString().Substring(1) %>" alt="Learn More"/></a></td>
                            </tr>
                        </table>
                    </td>
<%--                        <td style='padding:0;' valign='top'>
                        <div class='side_deal_content' style='border:1px solid #D3D3D3; -moz-border-radius-topleft:8px; -moz-border-radius:8px; -webkit-border-radius:8px;position:absolute; right:10px; width:100px; background:#FFF;'>
                            <table cellpadding='0' cellspacing='0' width='100' style="table-layout:inherit;">
                                <tr>
                                    <td style='height:45px; text-align:center;' valign='middle'>
                                        <div style="background:#f1f1f1 url('<%=WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + WebRoot %><%=ImagePath().ToString().Substring(1) %>mail-tpl-grey.jpg') repeat-x; padding:0 0 1px 0; height: 36px; overflow:hidden; border-bottom: 1px solid #dfdfdf; margin-top: 5px; ">
                                            <h2 style='font-family:Helvetica, Arial, sans-serif; font-weight:bold; font-size:14px; margin:3px; color:#303030; padding-top: 5px;'>邀请有奖</h2>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div style='margin:0; padding:0; font-size:14px; color:#000; font-family: Helvetica, Arial, sans-serif;padding:10px 15px 10px 15px;'>
                                            <p style="margin:0; padding:0;">每邀请一位好友首次购买，您将获 <span style="color:#cc3333;">&#165;<%=ASSystemArr["invitecredit"] %></span> 元返利<br/><a href="<%=WWWprefix %>account/invite.aspx" style="font-size:12px; font-weight:bold; ">&raquo; 点击获取您的专用邀请链接</a></p>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>--%>
                                    </tr>
            </table>
        </td>
    </tr>
</table>
</td>
</tr>
<!--内容 content end-->
</table>

<table style='background-color:#deedcc; margin-top:2px; -moz-border-radius-bottomleft:8px; -moz-border-radius-bottomright:8px; -webkit-border-bottom-left-radius:8px; -webkit-border-bottom-right-radius:8px;' width='100%'>
    <tr>
        <td style='font-family: Helvetica, Arial, sans-serif; color:#545454; font-size:12px; text-align:center; line-height:16px; padding:10px;'>电子邮箱:<a href="mailto:<%=ASSystemArr["subscribehelpemail"] %>" style="" title=""><%=ASSystemArr["subscribehelpemail"] %></a>&nbsp;&nbsp;&nbsp; 客服电话: <%=ASSystemArr["subscribehelpphone"] %>&nbsp;&nbsp;<span style='font-weight:normal; font-size:12px;'><%=ASSystemArr["Jobtime"]%></span></td>
    </tr>
</table>

</div>

<table cellpadding='0' cellspacing='0' width='720px'>
    <tr>
        <td align='center'>
            <p style='font-size:12px; font-family: Helvetica, Arial, sans-serif; color:#929292; margin:3px; padding-bottom:5px;'>您收到此邮件是因为您订阅了<%=ASSystemArr["sitename"] %>每日推荐更新。如果您不想继续接收此类邮件，可随时<a href="<%=WWWprefix %>unsubscribe.aspx?code=<%=mail["secret"] %>" style="" title="">取消订阅</a>。</p>
        </td>
    </tr>
</table>

</body>
</html>

