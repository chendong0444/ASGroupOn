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
    protected IList<IVote_Feedback_Question> ilistvofq = null;
    protected Vote_Feedback_QuestionFilters vofqf = new Vote_Feedback_QuestionFilters();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Edit_Option))
        {
            SetError("你不具有查看编辑问题选项的权限！");
            Response.Redirect("DiaoCha_Wenti_Xuanxiang.aspx?id=" + Request.QueryString["question_id"]);
            Response.End();
            return;


        }
        if (!IsPostBack)
        {
            getEdit();

        }
        if (Request.HttpMethod == "POST")
        {
            setEdit();
        }
    }
    private void getEdit()
    {
        StringBuilder sb1 = new System.Text.StringBuilder();
        StringBuilder sb2 = new System.Text.StringBuilder();
        StringBuilder sb3 = new System.Text.StringBuilder();
        StringBuilder sb4 = new System.Text.StringBuilder();
        StringBuilder sb5 = new StringBuilder();


        if (Request.QueryString["question_id"] != null)
        {
            IVote_Question voq = Store.CreateVote_Question();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                voq = session.Vote_Question.GetByID(Helper.GetInt(Request.QueryString["question_id"], 0));
            }
            if (voq != null)
            {
                sb4.Append("   <h2>'" + voq.Title + "</h2>");
            }

            sb5.Append("<input type='hidden' name='question_id' value='" + Request.QueryString["question_id"] + "' />");
        }
        if (Request.QueryString["id"] != null)
        {
            IVote_Options vop = Store.CreateVote_Options();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                vop = session.Vote_Options.GetByID(Helper.GetInt(Request.QueryString["id"], 0));
            }
            if (vop != null)
            {
                name.Value = vop.name;
                if (vop.is_br == 1)
                {
                    sb1.Append("<input type='radio' name='is_br' value='1' checked />换行");
                    sb1.Append("<input type='radio' name='is_br' value='0' />不换行");
                }
                else
                {
                    sb1.Append("<input type='radio' name='is_br' value='1' />换行");
                    sb1.Append("<input type='radio' name='is_br' value='0' checked />不换行");
                }
                if (vop.is_input == 1)
                {
                    sb2.Append("<input type='radio' name='is_input' value='1' checked />有");
                    sb2.Append(" <input type='radio' name='is_input' value='0' />无");
                }
                else
                {
                    sb2.Append("<input type='radio' name='is_input' value='1' />有");
                    sb2.Append(" <input type='radio' name='is_input' value='0' checked/>无");
                }
                if (vop.is_show == 1)
                {
                    sb3.Append(" <input type='radio' name='is_show' value='1' checked/>显示");
                    sb3.Append(" <input type='radio' name='is_show' value='0' />隐藏");
                }
                else
                {
                    sb3.Append(" <input type='radio' name='is_show' value='1' />显示");
                    sb3.Append(" <input type='radio' name='is_show' value='0' checked/>隐藏");
                }

                ordername.Value = vop.order.ToString();

                sb5.Append("<input type='hidden' name='options_id' value='" + Request.QueryString["id"] + "' />");
            }

        }
        bianji.Text = sb4.ToString();
        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();
        Literal3.Text = sb3.ToString();
        Literal4.Text = sb5.ToString();

    }
    private void setEdit()
    {
        IVote_Options vops = Store.CreateVote_Options();
        vops.id = Helper.GetInt(Request.Form["options_id"].ToString(),0);
        vops.question_id = Helper.GetInt(Request.Form["question_id"].ToString(), 0);
        vops.name = name.Value;
        vops.is_br = Helper.GetInt(Request.Form["is_br"].ToString(),0);
        vops.is_input = Helper.GetInt(Request.Form["is_input"].ToString(),0);
        vops.is_show = Helper.GetInt(Request.Form["is_show"].ToString(),0);
        vops.order = Helper.GetInt(ordername.Value,0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int upresult = session.Vote_Options.Update(vops);
        }
        SetSuccess("更新成功");
        Response.Redirect("DiaoCha_Wenti_Xuanxiang.aspx?id=" + Request.Form["question_id"].ToString() + "");

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
                                    <asp:Literal ID="bianji" runat="server"></asp:Literal>
                                    <ul class="filter">
                                        <li><a href="DiaoCha_Wenti_Xuanxiang.aspx?id=<%=Request.QueryString["question_id"] %>">
                                            选项列表</a> </li>
                                        <li><a href="DiaoCha_Wenti.aspx">问题列表</a> </li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <label>
                                            名称</label>
                                        <input id="name" type="text" size="30" name="name" group="a" require="true" datatype="require" class="f-input" value="" runat="server" />
                                        <span class="ttsd" style="width:500px;">不超过60个字符</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否换行</label>
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否有输入框</label>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否显示</label>
                                        <asp:Literal ID="Literal3" runat="server"></asp:Literal>
                                    </div>
                                    <div class="field">
                                        <label>
                                            排序</label>
                                        <input type="text" id="ordername" size="30" group="a" require="true" datatype="number" name="order" class="number" runat="server" />
                                    </div>
                                    <div class="act">
                                        <asp:Literal ID="Literal4" runat="server"></asp:Literal>
                                        <input type="submit" value="编辑" name="commit" group="a" class="formbutton validator" />
                                    </div>
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
