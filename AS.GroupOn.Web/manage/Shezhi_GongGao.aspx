<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_SetTg_Advertisement_AllPosition))
        {
            SetError("你不具有查看系统公告的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (Request.HttpMethod == "POST")
        {
            addSystem();
        }
        setCity();
    }
    ISystem systems = null;
    private void setCity()
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            systems = session.System.GetByID(1);
        }
        if (systems != null)
        {
            bulletin.Value = systems.gobalbulletin;
        }
    }
    private void addSystem()
    {
        ISystem system = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
        }

        system.gobalbulletin = Request.Form["bulletin"].ToString();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            session.System.Update(system);
        }
        SetSuccess("设置成功");

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
                <div id="system">
                    
                    <div id="content" class="clear mainwide">
                        <div class="clear box">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        系统公告</h2>
                                </div>
                                <div class="sect">
                                    <input type="hidden" name="id" value="1" />
                                    <div class="wholetip clear">
                                        <h3>
                                            1、全局公告</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            全局公告</label>
                                        <div style="float: left;">
                                            <textarea cols="45" rows="5" name="bulletin" id="bulletin" class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1',urlType:'abs'}"
                                                runat="server"></textarea></div>
                                    </div>
                                    <div class="act">
                                        <input type="submit" value="保存" name="commit" id="system-submit" class="formbutton" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
    </div>
    <!-- bdw end -->
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>