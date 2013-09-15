<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

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
    protected IPagers<IVote_Options> pager = null;
    protected string pagerHtml = String.Empty;
    int xiangqing = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Feedback_Information))
        {
            SetError("你不具有查看反馈详情的权限！");
            Response.Redirect("DiaoCha_Fankui.aspx");
            Response.End();
            return;

        }
        if (Request.QueryString["xiangqing"] != null)
        {
            xiangqing = Convert.ToInt32(Request.QueryString["xiangqing"].ToString());
            getXiangqing(xiangqing);
            Literal3.Text = "<h2>'" + Request.QueryString["title"] + "'反馈详情</h2>";
        }
    }
    private void getXiangqing(int id)
    {
        //调查问题选项表
        //调查问卷人员回答的问题
       Vote_OptionsFilters vopt = new Vote_OptionsFilters();
        vopt.Question_ID = id;
        IList<IVote_Options> ilistvopt = null;
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        sb1.Append("<tr >");
        sb1.Append("<th width='40'>ID</th>");
        sb1.Append("<th width='300'>名称</th>");
        sb1.Append("<th width='100'>反馈(人次)</th>");
        sb1.Append("<th width='100'>状态</th>");
        sb1.Append("<th width='100'>排序</th>");
        sb1.Append("<th width='50'>操作</th>");
        sb1.Append("</tr>");
        vopt.PageSize = 30;
        vopt.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        vopt.AddSortOrder(Vote_OptionsFilters.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Vote_Options.GetPager(vopt);
        }
        ilistvopt = pager.Objects;
       if(ilistvopt.Count==0)
        {
            sb2.Append("<tr><td colspan=5 align='center'>无选项</td></tr>");
        }
        else
        {
            if (ilistvopt != null && ilistvopt.Count > 0)
            {
                int i = 0;
                foreach(IVote_Options vo in ilistvopt)
                {
                    if (i % 2 != 0)
                    {
                        sb2.Append("<tr>");
                    }
                    else
                    {
                        sb2.Append("<tr class='alt'>");
                    }
                    sb2.Append("<td width='40'>" + vo.id + "</td>");
                    sb2.Append("<td width='300'>" + vo.name + "</td>");
                    Vote_Feedback_QuestionFilters vfoq = new Vote_Feedback_QuestionFilters();
                    IList<IVote_Feedback_Question> ilistvfoq = null;
                    vfoq.Options_ID = vo.id;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        ilistvfoq = session.Vote_Feedback_Question.GetList(vfoq);
                    }
                    if (ilistvfoq.Count >= 0)
                    {
                        sb2.Append("<td width='100'>" + ilistvfoq.Count + "(人次)</td>");
                    }
                    else
                    {
                        sb2.Append("<td width='100'>0(人次)</td>");
                    }
                    sb2.Append("<td width='100'>" + vo.is_show + "</td>");
                    sb2.Append("<td width='100'>" + vo.order + "</td>");
                    sb2.Append("<td width='50'><a href='Diaocha_Fankui_Xiangqing_Content.aspx?content=" + vo.id + "&xiangqing=" + Request.QueryString["xiangqing"].ToString() + "'>查看</a></td>");
                    sb2.Append("</tr>");
                    i++;
                }
            }
            Literal1.Text = sb1.ToString();
            Literal2.Text = sb2.ToString();
            pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, "DiaoCha_Fankui_Xiangqing.aspx?&page={0}");

        }
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head" style="height:35px;">
                                    <asp:Literal ID="Literal3" runat="server"></asp:Literal>
                                    <ul class="filter">
                                        <li><a href="DiaoCha_Fankui.aspx?action=question_list">调查中的问题列表</a></li>
                                        <li><a href="DiaoCha_SumPage.aspx?action=question_list&show_all=1">全部问题列表</a></li>
                                        <%--<li><a href="Diaocha_Fankui_Xiangqing.aspx?action=list">详细反馈列表</a></li>--%>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="8">
                                                <ul class="paginator">
                                                    <li class="current">
                                                        <%=pagerHtml %>
                                                    </li>
                                                </ul>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
