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
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Problem_List))
        {
            SetError("你不具有查看问题列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;


        }
        if (Request.QueryString["del"] != null)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Delete_Problem))
            {
                SetError("你不具有删除问题列表的权限！");
                Response.Redirect("DiaoCha_Wenti.aspx");
                Response.End();
                return;


            }
            delWenti(int.Parse(Request.QueryString["del"].ToString()));
        }

        if (Request.QueryString["change_show"] != null)
        {
            setShow(int.Parse(Request.QueryString["change_show"].ToString()), int.Parse(Request.QueryString["show"].ToString()));
        }
        wenTi();
    }
    private void setShow(int id, int id1)
    {
        IVote_Question vq = Store.CreateVote_Question();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            vq = session.Vote_Question.GetByID(id1);
        }
        
        vq.is_show = id;
        
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int result = session.Vote_Question.Update(vq);
        }
        //SetSuccess("更新成功！");
    }


    private void wenTi()
    {
        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<tr>");
        sb1.Append("<th width='15%'>ID</th>");
        sb1.Append("<th width='30%'>标题</th>");
        sb1.Append("<th width='15%'>状态</th>");
        sb1.Append("<th width='15%'>排序</th>");
        sb1.Append("<th width='25%'>操作</th>");
        sb1.Append("</tr>");
        StringBuilder sb2 = new StringBuilder();
       Vote_QuestionFilters voqf = new Vote_QuestionFilters();
        IList<IVote_Question> ilistvoqt = null;
        voqf.PageSize = 30;
        voqf.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        voqf.AddSortOrder(Vote_QuestionFilters.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Vote_Question.GetPager(voqf);
        }
        ilistvoqt = pager.Objects;
        if (ilistvoqt != null && ilistvoqt.Count > 0)
        {
            int i = 0;
            foreach(IVote_Question voq in ilistvoqt)
            {
                if (i % 2 != 0)
                {
                    sb2.Append("<tr>");
                }
                else
                {
                    sb2.Append("<tr class='alt'>");
                }
                sb2.Append("<td>" + voq.id + "</td>");
                sb2.Append("<td>" + voq.Title + "</td>");
                if (Convert.ToInt32(voq.is_show.ToString()) == 1)
                {
                    sb2.Append("<td>显示</td>");
                }
                else
                {
                    sb2.Append("<td>隐藏</td>");
                }
                sb2.Append("<td>" + voq.order + "</td>");
                sb2.Append("<td class='op'>");
                if (Convert.ToInt32(voq.is_show.ToString()) == 1)
                {
                    sb2.Append("<a href='DiaoCha_Wenti.aspx?change_show=0&show=" + voq.id + "'>隐藏</a>	｜");
                }
                else
                {
                    sb2.Append("<a href='DiaoCha_Wenti.aspx?change_show=1&show=" + voq.id + "'>显示</a>｜");
                }
                sb2.Append("<a href='DiaoCha_Wenti_Xuanxiang.aspx?ids=" + voq.id + "'>选项</a>｜");
                sb2.Append("<a href='DiaoCha_Wenti_Bianji.aspx?edits=" + voq.id + "'>编辑</a>｜");
                sb2.Append("<a ask='确定要删除吗?' class=\"remove-record\" href='DiaoCha_Wenti.aspx?del=" + voq.id + "'>删除</a>");
                sb2.Append("</td>");
                sb2.Append("</tr>");
                i++;
            }
        }

        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, "DiaoCha_Wenti.aspx?&page={0}");
    }
    private void updateWenti(int id)
    {
        IVote_Question vq = Store.CreateVote_Question();
       IVote_Question voqu = Store.CreateVote_Question();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            voqu = session.Vote_Question.GetByID(id);
        }
        if(voqu!=null)
        {
            
            vq.id = voqu.id;
            vq.is_show = int.Parse(Request.QueryString["change_show"].ToString());
            vq.order = voqu.order;
            vq.Title = voqu.Title;
            vq.Type = voqu.Type;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int upresult = session.Vote_Question.Update(vq);
        }
        SetSuccess("更新成功！");
    }
    private void delWenti(int id)
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int delid = session.Vote_Question.Delete(id);
        }
        SetSuccess("删除成功!");
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
                                    <h2>
                                        正在调查问题列表
                                    </h2>
                                    <ul class="filter">
                                        <li><a href="DiaoCha_NewPage.aspx?action=add">添加新问题</a> </li>
                                        <li><a href="DiaoCha_Wenti.aspx">全部问题列表</a> </li>
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
