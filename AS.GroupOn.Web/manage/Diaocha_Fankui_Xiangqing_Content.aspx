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
    protected IPagers<IVote_Feedback_Input> pager = null;
    protected string pagerHtml = String.Empty;
    protected IVote_Question voq = Store.CreateVote_Question();
    protected IVote_Options vop = Store.CreateVote_Options();
    protected int Id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Feedback_InformationContent))
        {
            SetError("你不具有查看反馈详情内容的权限！");
            Response.Redirect("DiaoCha_Fankui.aspx");
            Response.End();
            return;

        }
        getValue();
        getTitle();
        setDiaochaContent();
    }
    private void getValue()
    {
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            voq = session.Vote_Question.GetByID(Helper.GetInt(Request.QueryString["xiangqing"], 0));
            vop = session.Vote_Options.GetByID(Helper.GetInt(Request.QueryString["content"], 0));
        }
        if (voq != null)
        {

            sb1.Append("<h2>”" + voq.Title + "“</h2>");
        }
        if (vop != null)
        {
            sb2.Append("<h3>" + vop.name + "</h3>");
        }
        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();

    }
    private void getTitle()
    {
        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<tr>");
        sb1.Append("<th style='width:20%;'>ID</th>");
        sb1.Append("<th style='width:30%px;'>用户名</th>");
        sb1.Append("<th style='width:50%px;'>提交的内容</th>");
        sb1.Append("</tr>");
        Literal3.Text = sb1.ToString();
    }
    private void setDiaochaContent()
    {
        Vote_Feedback_InputFilters vofi = new Vote_Feedback_InputFilters();
        IList<IVote_Feedback_Input> ilistvofi = null;
        vofi.Wheresql = "feedback_id in (select feedback_id from vote_feedback_question where options_id=" + vop.id + " and question_id=" + voq.id + ")";
        vofi.PageSize = 30;
        vofi.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        vofi.AddSortOrder(Vote_Feedback_InputFilters.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Vote_Feedback_Input.GetPager(vofi);
        }
        ilistvofi = pager.Objects;
        if (ilistvofi != null && ilistvofi.Count > 0)
        {
            StringBuilder sb1 = new StringBuilder();
            int i = 0;
            foreach (IVote_Feedback_Input vof in ilistvofi)
            {

                if (i % 2 != 0)
                {
                    sb1.Append("<tr>");
                }
                else
                {
                    sb1.Append("<tr class='alt'>");
                }

                sb1.Append("<td>" + vof.id + "</td>");
                IUser usermodel = Store.CreateUser();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    usermodel = session.Users.GetByID(vof.feedback_id);
                }
                if (usermodel != null)
                    sb1.Append("<td><div style='word-wrap: break-word;overflow: hidden;'>" + usermodel.Username + "</div></td>");
                else
                    sb1.Append("<td>&nbsp;</td>");
                sb1.Append("<td>" + vof.value + "</td>");
                sb1.Append("</tr>");
                i++;
            }
            Literal4.Text = sb1.ToString();
            pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, "DiaoCha_Fankui_Xiangqing_Content.aspx?&page={0}");
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
                                    <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                    <ul class="filter">
                                        <li><a href="DiaoCha_Fankui.aspx">调查中的问题列表</a></li>
                                        <li><a href="DiaoCha_SumPage.aspx">全部问题列表</a></li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <div class="wholetip clear">
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal></div>
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal3" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal4" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="3" style="height: 66px">
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
