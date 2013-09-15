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
        if (Request.QueryString["action"] != null)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Add_NewProblem))
            {
                SetError("你不具有查看添加新问题的权限！");
                Response.Redirect("DiaoCha_Wenti.aspx");
                Response.End();
                return;

            }
        }
        else
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Add_NewProblem))
            {
                SetError("你不具有查看添加新问题的权限！");
                 Response.Redirect("DiaoCha_SumPage.aspx");
                Response.End();
                return;

            }
        }
        if (Request.HttpMethod == "POST")
        {
            getQuestion();
        }
    }
    private void getQuestion()
    {

        IVote_Question mmvq = Store.CreateVote_Question();
        mmvq.Title = Request.Form["title"].ToString();
        mmvq.Type = Request.Form["type"].ToString();
        mmvq.is_show = Convert.ToInt32(Request.Form["is_show"].ToString());
        mmvq.order = Convert.ToInt32(Request.Form["order"].ToString());
        mmvq.Addtime = DateTime.Now;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int add = session.Vote_Question.Insert(mmvq);
        }
        SetSuccess("添加成功！");
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
                                        添加问题
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
                                        <input type="text" size="30" group="a" require="true" datatype="require" name="title" class="f-input" value="" maxlength="51" />
                                        <span class="inputtip" style="width:500px;">不超过100个字符</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            类型</label>
                                        <input type="radio" name="type" value="radio" checked />单选
                                        <input type="radio" name="type" value="checkbox" />多选
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
                                        <input type="text" size="30" group="a" name="order" require="true" datatype="number" class="number" value="0" />
                                    </div>
                                    <div class="act">
                                        <input id="addname" type="hidden" name="id" />
                                        <input id="Submit1" type="submit" value="添加" name="commit" group="a" class="formbutton validator" runat="server" />
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
