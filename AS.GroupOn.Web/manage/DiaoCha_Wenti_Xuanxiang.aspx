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
    protected Vote_OptionsFilters voof = new Vote_OptionsFilters();
    protected IList<IVote_Options> ilistvoo = null;
    int Id = 0;
    //{
    //    get { return int.Parse(ViewState["_Id"].ToString()); }
    //    set { ViewState["_Id"] = value; }
    //}
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if(Request.QueryString["id"] != null)
        {
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_ProblemOption_List))
        {
            SetError("你不具有查看问题选项的权限！");
            Response.Redirect("DiaoCha_SumPage.aspx");
            Response.End();
            return;


        }
        }
        if (Request.QueryString["ids"] != null)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_ProblemOption_List))
        {
            SetError("你不具有查看问题选项的权限！");
            Response.Redirect("DiaoCha_Wenti.aspx");
            Response.End();
            return;

        }
        }
        if (Request.QueryString["id"] != null)
        {
            Id = Convert.ToInt32(Request.QueryString["id"]);
        }
        if (Request.QueryString["ids"] != null)
        {
            Id = Convert.ToInt32(Request.QueryString["ids"]);
        }
        if (Request.QueryString["del"] != null)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Delete_Option))
            {
                SetError("你不具有删除问题选项的权限！");
                Response.Redirect("DiaoCha_Wenti_Xuanxiang.aspx?id="+Id);
                Response.End();
                return;


            }
            int del_id = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                del_id = session.Vote_Options.Delete(Helper.GetInt(Request.QueryString["del"].ToString(), 0));
            }
            if (del_id > 0)
            {

                Response.Redirect("DiaoCha_Wenti_Xuanxiang.aspx?id=" + Id);
                SetSuccess("删除成功！");
            }
            else
            {
                SetError("删除失败！");
            }
        }

        //修改信息
        if (Request["action"] != null)
        {
            Upoption(Convert.ToInt32(Request["action"]));
        }
        if (Request.QueryString["id"] != null)
        {
            Id = Helper.GetInt(Request.QueryString["id"], 0);
            getQuationTitleAndNewTitle(Id);
            voof.Question_ID = Helper.GetInt(Request.QueryString["id"].ToString(), 0);
            getQuationContent();

        }
        if (Request.QueryString["ids"] != null)
        {
            Id = Helper.GetInt(Request.QueryString["ids"], 0);
            getQuationTitleAndNewTitle(Id);
            voof.Question_ID = Helper.GetInt(Request.QueryString["ids"].ToString(), 0);
            getQuationContent();

        }
        if (Request.QueryString["add"] != null)
        {
            Id = Helper.GetInt(Request.QueryString["add"], 0);
            getQuationTitleAndNewTitle(Id);
            voof.Question_ID = Helper.GetInt(Request.QueryString["add"].ToString(), 0);
            getQuationContent();

        }
    }

    public void Upoption(int ishow)
    {
        IVote_Options vo = Store.CreateVote_Options();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            vo = session.Vote_Options.GetByID(Helper.GetInt(Request["opid"], 0));
        }
        vo.is_show = ishow;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int upresult = session.Vote_Options.Update(vo);
        }
    }
    private void getQuationTitleAndNewTitle(int id)
    {
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        IVote_Question voq = Store.CreateVote_Question();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            voq = session.Vote_Question.GetByID(id);
        }
        if (voq != null)
        {
            sb1.Append("<h2>'" + voq.Title + "'选项列表</h2>");
            sb2.Append("<a href='DiaoCha_Wenti_Xuanxiang_Tianjia.aspx?add=" + id + "'>添加新选项</a>");
        }
        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();
    }
    private void getQuationContent()
    {
        StringBuilder sb3 = new StringBuilder();
        sb3.Append("<tr >");
        sb3.Append("<th width='15%'>ID</th>");
        sb3.Append("<th width='33%'>名称</th>");
        sb3.Append("<th width='15%'>状态</th>");
        sb3.Append("<th width='10%'>排序</th>");
        sb3.Append("<th width='25%'>操作</th>");
        sb3.Append("</tr>");
        StringBuilder sb4 = new StringBuilder();

        voof.PageSize = 30;
        voof.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        voof.AddSortOrder(Vote_OptionsFilters.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Vote_Options.GetPager(voof);
        }
        ilistvoo = pager.Objects;
        if (ilistvoo != null && ilistvoo.Count > 0)
        {
            int i = 0;
            foreach (IVote_Options voop in ilistvoo)
            {

                if (i % 2 != 0)
                {
                    sb4.Append("<tr>");
                }
                else
                {
                    sb4.Append("<tr class='alt'>");
                }
                sb4.Append("<td >" + voop.id + "</td>");
                sb4.Append("<td >" + voop.name + "</td>");
                if (Convert.ToInt32(voop.is_show.ToString()) == 1)
                {
                    sb4.Append("<td >显示</td>");
                }
                else
                {
                    sb4.Append("<td >隐藏</td>");
                }
                sb4.Append("<td >" + voop.order + "</td>");
                sb4.Append("<td class='op'>");
                if (Convert.ToInt32(voop.is_show.ToString()) == 0)
                {
                    sb4.Append("<a href='DiaoCha_Wenti_Xuanxiang.aspx?action=1&opid=" + voop.id + "&id=" + Request.QueryString["id"] + "'>显示</a>｜");

                }
                else
                {
                    sb4.Append("<a href='DiaoCha_Wenti_Xuanxiang.aspx?action=0&opid=" + voop.id + "&id=" + Request.QueryString["id"] + "'>隐藏</a>｜");

                }
                sb4.Append("<a href='DiaoCha_Wenti_Xuanxiang_Bianji.aspx?question_id=" + Id + "&id=" + voop.id + "'>编辑</a>｜");
                sb4.Append("<a class=\"remove-record\" href=\"DiaoCha_Wenti_Xuanxiang.aspx?id=" + Id + "&del=" + voop.id + "\">删除</a>");
                sb4.Append("</td>");
                sb4.Append("</tr>");
                i++;
            }
        }
        Literal3.Text = sb3.ToString();
        Literal4.Text = sb4.ToString();
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
                                <div class="head" style="height: 35px;">
                                    <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                    <ul class="filter">
                                        <li>
                                            <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        </li>
                                        <li><a href="DiaoCha_Wenti.aspx">问题列表</a> </li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal3" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal4" runat="server"></asp:Literal>
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
