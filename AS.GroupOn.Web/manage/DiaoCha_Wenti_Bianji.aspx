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
   
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (Request.QueryString["edit"] != null)
        {
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Edit_Problem))
        {
            SetError("你不具有查看编辑问题的权限！");
            Response.Redirect("DiaoCha_SumPage.aspx");
            Response.End();
            return;

        }
        }
        if (Request.QueryString["edits"] != null)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Edit_Problem))
            {
                SetError("你不具有查看编辑问题的权限！");
                Response.Redirect("DiaoCha_Wenti.aspx");
                Response.End();
                return;

            }
        }
        if (Request.HttpMethod == "POST")
        {
            setValue();
        }
        if (!IsPostBack)
        {
            if (Request.QueryString["edit"] != null)
            {
                getValue(int.Parse(Request.QueryString["edit"].ToString()));
            }

            if (Request.QueryString["edits"] != null)
            {
                getValue(int.Parse(Request.QueryString["edits"].ToString()));
            }
        }
    }
    private void getValue(int id)
    {
         StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        IVote_Question voqe = Store.CreateVote_Question();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            voqe = session.Vote_Question.GetByID(id);
        }
        if(voqe!=null)
        {
            title1.Value = voqe.Title;
            if (voqe.Type == "radio")
            {
                sb1.Append("  <input type='radio' name='type' value='radio' checked/>单选");
                sb1.Append(" <input type='radio' name='type' value='checkbox' />多选");
            }
            else if (voqe.Type == "checkbox")
            {
                sb1.Append("  <input type='radio' name='type' value='radio' />单选");
                sb1.Append(" <input type='radio' name='type' value='checkbox' checked />多选");
            }
            if (voqe.is_show == 1)
            {
                sb2.Append("<input type='radio' name='is_show' value='1' checked/>显示 ");
                sb2.Append("<input type='radio' name='is_show' value='0' />隐藏");
            }
            else if (voqe.is_show == 0)
            {
                sb2.Append("<input type='radio' name='is_show' value='1' />显示 ");
                sb2.Append("<input type='radio' name='is_show' value='0' checked/>隐藏");
            }
            order_name.Value = voqe.order.ToString();
            update.Value = voqe.id.ToString();
        }

        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();


    }
    private void setValue()
    {
        IVote_Question vq = Store.CreateVote_Question();
        vq.id = int.Parse(update.Value);
        vq.is_show = int.Parse(Request.Form["is_show"].ToString());
        try
        {
            vq.order = int.Parse(order_name.Value);
        }
        catch (Exception)
        {


        }
        vq.Title = title1.Value;
        vq.Type = Request.Form["type"].ToString();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int upresult = session.Vote_Question.Update(vq);
        }
        SetSuccess("更新成功！");
        Response.Redirect("DiaoCha_Wenti.aspx");
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
                                        编辑问题
                                    </h2>
                                    <ul class="filter">
                                        <li></li>
                                        <li><a href="DiaoCha_Wenti.aspx">调查中的问题列表</a> <a href="DiaoCha_SumPage.aspx">全部问题列表</a>
                                        </li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <div class="field">
                                        <label>
                                            标题</label>
                                        <input id="title1" type="text" size="30" group="a" require="true" datatype="require" name="title" class="f-input" runat="server" />
                                        <span class="inputzifu" style="width:500px;">不超过100个字符</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            类型</label>
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                    </div>
                                    <div class="field">
                                        <label>
                                            是否显示</label>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                    </div>
                                    <div class="field">
                                        <label>
                                            排序</label>
                                        <input type="text" id="order_name" group="a" size="30" name="order" require="true" datatype="number" class="number" runat="server" />
                                    </div>
                                    <div class="act">
                                        <input id="update" type="hidden" name="update" runat="server" />
                                        <input type="submit" value="修改" name="commit" group="a" class="formbutton validator" />
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
