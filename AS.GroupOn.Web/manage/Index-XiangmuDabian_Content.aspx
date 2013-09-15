<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    protected IAsk _ask = null;
    protected IList<IAsk> iListAsk = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected string comment = string.Empty;
    protected int id = 0;
    protected string commit = string.Empty;
    protected override void OnLoad(EventArgs e)
    {  
        base.OnLoad(e);
        //判断管理员是否有此操作
        
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TeamAsk_Edit))
        {
            SetError("你不具有编辑项目咨询列表权限！");
            Response.Redirect("Index-XiangmuDabian.aspx");
            Response.End();
            return;
        }

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
             id = Convert.ToInt32(Request.QueryString["id"]);
            _ask = session.Ask.GetByID(id);
        }
        comment = Request["comment"];
        id = Convert.ToInt32(Request["id"]);
        commit = Request["commit"];
        if (commit=="编辑")
        {
            IAsk _ask = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {

                _ask = session.Ask.GetByID(Convert.ToInt32(id));
            }
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {

                _ask.Content = comment;
                i = session.Ask.Update(_ask);

            }
            if (i > 0)
            {
                SetSuccess("编辑成功");
                Response.Redirect("Index-XiangmuDabian.aspx");
            }
            else
            {
                SetError("编辑失败");
                Response.Redirect("Index-XiangmuDabian.aspx");
            };
        }
    } 
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form action="Index-XiangmuDabian_Content.aspx" method="post" class="validator">
    <!--<input type="hidden" name="action" value="xmdb_update" />-->
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div class="dashboard" id="dashboard">
                    </div>
                    <div id="content" class="box-content mainwide">
                        <div class="dashboard" id="Div1">
                        </div>
                        <div id="Div2" class="clear ">
                            <div class="clear box">
                                <div class="box-content">
                                    <div class="head">
                                        <h2>
                                            编缉</h2>
                                        <br />
                                        <span class="headtip">
                                            <input type="text" style="display: none;" name="id" value="<%=_ask.Id %>" /><%=_ask.User.Realname %>&nbsp;关于(<a><%=_ask.team.Title %></a>)的咨询</span></div>
                                    <div class="sect">
                                        <div class="field">
                                            <label>
                                                编缉内容</label>
                                            <textarea cols="45" rows="5" name="comment" id="team-ask-comment" class="f-textarea"><%=_ask.Content %></textarea>
                                        </div>
                                        <div class="act">
                                            <input type="submit" value="编辑" id="misc-submit" name="commit" class="formbutton" />
                                            &nbsp;&nbsp;
                                            <input type="button" class="formbutton" onClick="javascript:history.go(-1);" value="返回" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>