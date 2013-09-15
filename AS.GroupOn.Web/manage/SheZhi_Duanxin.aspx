<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>



<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="ASDHTSMS.ASDHTSMSService" %>
<%@ Import Namespace="AS.GroupOn.App" %>

<script runat="server">
    protected ISystem system = Store.CreateSystem();
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Sms_Account))
        {
            SetError("你不具有查看短信设置的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        getSms();

    }
    private void getSms()
    {  
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
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
                    <div id="content" class="box-content">
                        <div class="box clear mainwide ">
                            <div class="box-content">
                <div class="head"><h2>短信配置（请填写用户名和密码）</h2>
                <input type="hidden" id="id" name="id" value="<%=system.id %>" />
                </div>
                <div class="sect">
              
						<div class="wholetip clear"><h3>1、基本信息</h3></div>
                        <div class="field">
                            <label>短信用户</label>
                            <input type="text" size="30" id="sms_user" name="user" class="f-input" value="<%=system.smsuser %>"/>
                        </div>
                        <div class="field">
                            <label>短信密码</label>
                            <input type="password" size="30" id="sms_pass" name="pass" class="f-input"  value="<%=system.smspass %>"/>
                         
                        </div>
                        <div class="field">
                            <label>点发频率</label>
                            <input type="text" size="30" id="sms_interval" name="interval" class="number" value="<%=system.smsinterval %>"/>
                            <span class="inputtip">用户联系点击短信发送的，时间间隔限制，管理员点发不受此限制，建议：60-300s</span>
                        </div>

                        <div class="act">
                        <input type="hidden" name="action" value="updatesms" />
                            <input type="submit" value="保存" name="commit" class="formbutton"/>
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