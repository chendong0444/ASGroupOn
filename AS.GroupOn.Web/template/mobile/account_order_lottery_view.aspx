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
    protected ITeam teammodel = null;
    protected IPagers<IDraw> pager = null;
    protected string url = string.Empty;//url
    protected IList<IDraw> list_draw = null;
    protected StringBuilder strhtml = new StringBuilder();
    protected IUser usermodel = null;
    protected string strtitle = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "订单";
        MobileNeedLogin();
        if (Request["teamid"] != null)
        {
            InitData(Helper.GetInt(Request["teamid"], 0));
        }
    }
    //获取抽奖详细信息
    public void InitData(int teamid)
    {
        strhtml.Append("<div class='deal'>");
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(Helper.GetInt(teamid, 0));
        }
        if (teammodel != null)
        {
            strhtml.AppendFormat("<img src='{0}' />", PageValue.CurrentSystem.domain + WebRoot + (teammodel.PhoneImg == null ? String.Empty : teammodel.PhoneImg), teammodel.Title);
            strhtml.Append("<h2>" + teammodel.Product + "</h2>");
            strtitle = teammodel.Product;
        }
        strhtml.Append("</div>");
        strhtml.Append("<table><tbody>");
        strhtml.Append("<tr><th style='width:90px;' class='title'>项目名称</th><th style='width:72px;' class='title'>抽奖号码</th><th style='width:50px;' class='title'>状态</th></tr>");
        DrawFilter drawfil = new DrawFilter();
        drawfil.teamid = teamid;
        drawfil.userid = AsUser.Id;
        drawfil.PageSize = 15;
        drawfil.AddSortOrder(DrawFilter.CREATETIME_DESC);
        drawfil.CurrentPage = Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Draw.GetPager(drawfil);
        }
        list_draw = pager.Objects;
        string strnum = "";
        if (pager != null)
        {
            if (pager.TotalRecords > 0)
            {
                for (int i = 0; i < list_draw.Count; i++)
                {
                    if (list_draw[i].state == "Y")
                    {
                        strhtml.Append("<tr><td>" + strtitle + "</td><td>" + list_draw[i].number + "</td><td><strong>中奖了</strong></td></tr>");
                    }
                    else
                    {
                        strhtml.Append("<tr><td>" + strtitle + "</td><td>" + list_draw[i].number + "</td><td>未中奖</td></tr>");
                    }
                }
                strhtml.Append("</tbody></table>");
                strhtml.Append("<p class='isEmpty'>" + strnum + "</p>");
            }
        }
        else
        {
            strhtml.Append("</tbody></table>");
            strhtml.Append("<p class='empty'>没有相关数据</p>");
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<body id="lottery-result">
    <header>
        <div class="left-box">
            <a class="go-back" href="javascript:history.back()"><span>返回</span></a>
        </div>
        <h1>抽奖结果</h1>
    </header>
    <article class="body">
        <%=strhtml %>
    </article>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>