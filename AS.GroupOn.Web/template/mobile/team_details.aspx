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
<script runat="server">
    protected ITeam teammodel = null;
    protected int teamid = 0;
    protected bool over = false;
    protected AS.Enum.TeamState state = AS.Enum.TeamState.none;
    protected DateTime overtime = DateTime.Now;  //团购结束时间
    protected long difftimefix = 0;
    protected long curtimefix = 0;
    private string fonts = string.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        teamid = Helper.GetInt(Request["id"], 0);
        PageValue.Title = "项目详情";
        using (IDataSession session = Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(teamid);
        }
        if (teammodel.bulletin.Replace("{", "").Replace("}", "").Replace("[", "").Replace("]", "").Replace("|", "/") != "")
        {
            fonts = teammodel.bulletin.Replace("{", "").Replace("}", "").Replace("[", "").Replace("]", "").Replace("|", "/");
            string ends = fonts.Substring(fonts.Length - 1, 1);
            if (ends == ",")
            {
                fonts = fonts.Substring(0, fonts.Length - 1);
            }
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<style>
    /* deal详情页菜单 */
    #deal-menu
    {
        width: 100%;
        font-size: 12px;
        color: #666;
        border-collapse: collapse;
        border-spacing: 0;
    }

        #deal-menu .name
        {
            width: auto;
            text-align: left;
        }

        #deal-menu .price
        {
            width: 18%;
        }

        #deal-menu .amount
        {
            width: 23%;
        }

        #deal-menu .subtotal
        {
            width: 18%;
            text-align: right;
        }

        #deal-menu caption, #deal-menu th, #deal-menu td
        {
            padding: 4px;
            border: 1px solid #C0DCF3;
        }

        #deal-menu .title
        {
            font-weight: bold;
            color: #5C5C5C;
        }

        #deal-menu caption
        {
            background: #D2E8F9;
            border-bottom: none;
        }

            #deal-menu caption .title
            {
                color: #4A4A4A;
            }

        #deal-menu th
        {
            background: #EDF6FD;
            text-align: left;
        }

        #deal-menu .subline
        {
            background: #F2F2F2;
        }

        #deal-menu tfoot td
        {
            border-color: #FFF;
        }

        #deal-menu tfoot .ft td
        {
            border-top: 1px solid #C0DCF3;
        }
</style>
<style>
    .standard-table
    {
        background-color: #c0dcf3;
        width: 100%;
        border: 0;
        border-collapse: separate;
        border-spacing: 1px;
        table-layout: fixed;
        margin-top: 5px;
    }

        .standard-table .center
        {
            text-align: center;
        }

        .standard-table .right
        {
            text-align: right;
        }

        .standard-table th
        {
            padding: 3px 5px;
            background-color: #d2e8f9;
            color: #333;
        }

        .standard-table td
        {
            padding: 3px 5px;
            word-break: break-all;
            word-wrap: break-word;
        }

        .standard-table tr.comment
        {
            background-color: #edf6fd;
            color: #666;
            font-weight: bold;
        }

        .standard-table tr.normal
        {
            background-color: #fff;
            color: #666;
        }
</style>
<style>
    .standard-center
    {
        text-align: center;
    }

    .standard-bar
    {
        padding: 3px 6px;
        color: #fff;
        border-radius: 3px;
        font-weight: bold;
    }

    .standard-list-title
    {
        margin: 5px 0;
    }

    .standard-image
    {
        display: block;
        margin: 10px 0;
    }

    .standard-image-wrap
    {
        display: block;
        width: 100%;
    }
</style>
<body id="deal-detail">
    <header>
        <div class="left-box">
            <a class="go-back" href="javascript:history.back()"><span>团购详情</span></a>
        </div>
        <h1><%=PageValue.Title%></h1>
    </header>
    <div id="details">
        <details>
            <summary>项目详情</summary>
            <%if (teammodel != null)
              { %>
            <table class="standard-table">
                <thead>
                    <th width="41%">内容
                    </th>
                    <th width="18%">单价
                    </th>
                    <th width="23%">数量/规格
                    </th>
                    <th width="18%">小计
                    </th>
                </thead>
                <tbody>
                    <tr class="normal">
                        <td>
                            <%=teammodel.Title%>
                        </td>
                        <td class="center">
                            <%=ASSystemArr["Currency"]%><%=GetMoney(teammodel.Market_price)%>
                        </td>
                        <td class="center">1张
                        </td>
                        <td class="right">
                            <%=ASSystemArr["Currency"]%><%=GetMoney(teammodel.Market_price)%>
                        </td>
                    </tr>
                    <tr class="comment">
                        <%if (fonts != "")
                          {%>
                        <td colspan="4" class="center">
                            <%=fonts %>
                        </td>
                        <%} %>
                    </tr>
                </tbody>
                <tfoot>
                    <tr>
                        <td></td>
                        <td></td>
                        <td>价值
                        </td>
                        <td class="right">
                            <%=ASSystemArr["Currency"] %><%=GetMoney(teammodel.Market_price )%>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td></td>
                        <td>
                            <%=PageValue.CurrentSystem.sitename%>价
                        </td>
                        <td class="right">
                            <%=teammodel.Team_price %>
                        </td>
                    </tr>
                </tfoot>
            </table>
            <div id="mobileapp">
                <%=ashelper.GetHtmlWapImageUrlList(teammodel.Detail.ToString())%>
            </div>
            <%}%>
            <div style="margin: 0 8px;">
                <p class="c-submit">
                    <%if (teammodel.Begin_time <= DateTime.Now && DateTime.Now < teammodel.End_time)
                      {
                          if (teammodel.Max_number != 0 && teammodel.Now_number > teammodel.Max_number)
                          {%>
                    <a href="#">超出最大购买量</a>
                    <%}
                  else
                  {%>
                    <% if (teammodel.Delivery == "draw")
                       {%>
                    <a href="<%=GetUrl("手机版订单购买", "team_buy.aspx")%><%=teammodel.Id %>">立即参与</a>
                    <%}
                       else
                       {%>
                    <a href="<%=GetUrl("手机版订单购买", "team_buy.aspx")%><%=teammodel.Id %>">立即购买</a>
                    <% }%>
                    <%}
                      }
                      else
                      {%>
                    <a href="#">该项目已结束</a>
                    <%} %>
                </p>
            </div>
        </details>
    </div>
</body>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>