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
   protected IVote_Question que = Store.CreateVote_Question();
    string ID
    {
        get { return ViewState["ID"].ToString(); }
        set { ViewState["ID"] = value; }
    }
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Add_NewOption))
        {
            SetError("你不具有添加问题选项的权限！");
            Response.Redirect("DiaoCha_Wenti_Xuanxiang.aspx?id="+Request.QueryString["add"]);
            Response.End();
            return;


        }
        if (Request.QueryString["add"] != null)
        {

            ID = Request.QueryString["add"].ToString();
            if (ID != null)
            {
                getTitleName(int.Parse(ID));

            }

        }
        if (Request.HttpMethod == "POST")
        {
            setContent();
        }
    }
    private void getTitleName(int id)
    {
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            que = session.Vote_Question.GetByID(id);
        }
        if(que!=null)
        {
            sb1.Append("<h2>'" + que.Title + "'添加选项</h2>");
            sb2.Append("<input type='hidden' id='question_id' name='question_id' value='" + que.id + "'/>");

        }

        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();
    }
    private void setContent()
    {
        IVote_Options op = Store.CreateVote_Options();
        op.question_id = int.Parse(Request.Form["question_id"].ToString());
        op.name = Request.Form["name"].ToString();
        op.is_br = int.Parse(Request.Form["is_br"].ToString());
        op.is_input = int.Parse(Request.Form["is_input"].ToString());
        op.is_show = int.Parse(Request.Form["is_show"].ToString());
        op.order = int.Parse(Request.Form["order"].ToString());
        int addid = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            addid = session.Vote_Options.Insert(op);
        }
        if (addid > 0)
        {
            SetSuccess("添加成功");
            Response.Redirect("DiaoCha_Wenti_Xuanxiang.aspx?id=" + ID + "");
        }
        else
        {
            SetError("添加失败");
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
                                        <li><a href="DiaoCha_Wenti_Xuanxiang.aspx?add=<%=ID %>">选项列表</a> </li>
                                        <li><a href="DiaoCha_Wenti.aspx">问题列表</a> </li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <label>
                                            名称</label>
                                        <input type="text" size="30" name="name" group="a" require="true" datatype="require" class="f-input" value="" />
                                        <span class="inputtip" style="width:500px;">不超过60个字符</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否换行</label>
                                        <input type="radio" name="is_br" value="1" />换行
                                        <input type="radio" name="is_br" value="0" checked />不换行
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否有输入框</label>
                                        <input type="radio" name="is_input" value="1" />有
                                        <input type="radio" name="is_input" value="0" checked />无
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否显示</label>
                                        <input type="radio" name="is_show" value="1" checked />显示
                                        <input type="radio" name="is_show" value="0" />隐藏
                                    </div>
                                    <div class="field">
                                        <label>
                                            排序</label>
                                        <input type="text" size="30" name="order" group="a" require="true" datatype="number" class="number" value="0" />
                                    </div>
                                    <div class="act">
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <input type="submit" value="添加" name="commit" group="a" class="formbutton validator" />
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
