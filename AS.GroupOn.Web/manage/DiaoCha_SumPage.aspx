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
    protected IPagers<IVote_Question> pager = null;
    protected string pagerHtml = String.Empty;
    protected IList<IVote_Question> ilistvq = null;
    protected int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_ProblemOptionFeedBack_List))
        {
            SetError("你不具有查看问题选项反馈列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        getSumPage();
        if (Request.QueryString["change_show"] != null)
        {
            setShow(int.Parse(Request.QueryString["change_show"].ToString()), int.Parse(Request.QueryString["show"].ToString()));
        }
        id = Helper.GetInt(Request["del"], 0);
        if (id > 0)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Edit_Problem))
            {
                SetError("你不具有删除问题的权限！");
                Response.Redirect("DiaoCha_SumPage.aspx");
                Response.End();
                return;


            }
            int del_id = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                del_id = session.Vote_Question.Delete(id);
            }
            if (del_id > 0)
            {

                SetSuccess("问题" + id + "删除成功");
            }
            Response.Redirect("DiaoCha_SumPage.aspx");
            Response.End();
            return;
        }
    }
    private void getSumPage()
    {


        Vote_QuestionFilters vq = new Vote_QuestionFilters();
        vq.PageSize = 30;
        vq.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        vq.AddSortOrder(Vote_QuestionFilters.ID_ASC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Vote_Question.GetPager(vq);
        }
        ilistvq = pager.Objects;
        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<tr >");
        sb1.Append("<td width='10%'>ID</td>");
        sb1.Append("<td width='30%'>标题</td>");
        sb1.Append("<td width='10%'>状态</td>");
        sb1.Append("<td width='10%'>排序</td>");
        sb1.Append("<td width='40%'>操作</td>");
        sb1.Append("</tr>");
        StringBuilder sb2 = new StringBuilder();
        if (ilistvq != null)
        {
            int i = 0;
            foreach (IVote_Question var in ilistvq)
            {

                if (i % 2 != 0)
                {
                    sb2.Append("<tr>");
                }
                else
                {
                    sb2.Append("<tr class='alt'>");
                }


                sb2.Append("<td>" + var.id + "</td>");
                sb2.Append("<td>" + var.Title + "</td>");
                if (var.is_show == 1)
                {
                    sb2.Append("<td>显示</td>");
                }
                else if (var.is_show == 0)
                {
                    sb2.Append("<td> 隐藏</td>");
                }

                sb2.Append("<td>" + var.order + "</td>");
                sb2.Append("<td>");
                if (var.is_show == 1)
                {
                    sb2.Append("<a href='DiaoCha_SumPage.aspx?change_show=0&show=" + var.id + "'>隐藏 |</a>	");
                }
                else if (var.is_show == 0)
                {
                    sb2.Append("<a href='DiaoCha_SumPage.aspx?change_show=1&show=" + var.id + "'>显示 |</a>	");
                }
                else
                {
                    sb2.Append("<a href='DiaoCha_SumPage.aspx?change_show=0&show=" + var.id + ">隐藏 |</a>	");
                }

                sb2.Append("<a href='DiaoCha_Wenti_Xuanxiang.aspx?id=" + var.id + "'> 选项 |</a>");
                sb2.Append("<a href='DiaoCha_Wenti_Bianji.aspx?edit=" + var.id + "'> 编辑 |</a>");
                sb2.Append("<a class=\"remove-record\"  href='DiaoCha_SumPage.aspx?del=" + var.id + "'> 删除</a>");
                sb2.Append("</td>");
                sb2.Append("</tr>");
                i++;
            }
        }
        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, "DiaoCha_SumPage.aspx?&page={0}");
    }

    private void setShow(int id, int id1)
    {
        IVote_Question item = Store.CreateVote_Question();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            item = session.Vote_Question.GetByID(id1);
        }
        IVote_Question vq = Store.CreateVote_Question();
        if (item != null)
        {
            vq.id = item.id;
            vq.Title = item.Title;
            vq.Type = item.Type;
            vq.order = item.order;
            vq.is_show = id;

        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int result = session.Vote_Question.Update(vq);

        }
       SetSuccess("更新成功！");
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
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
                                    <h2>
                                        全部问题列表
                                    </h2>
                                    <ul class="filter">
                                        <li><a href="DiaoCha_NewPage.aspx">添加新问题</a> </li>
                                        <li><a href="DiaoCha_Wenti.aspx">正在调查问题列表</a> </li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="8">
                                                <ul class="paginator">
                                                    <%=pagerHtml%>
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
</body>
<%LoadUserControl("_footer.ascx", null); %>
