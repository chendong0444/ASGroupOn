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
    
    protected bool mailssl = false;
    protected NameValueCollection configs = new NameValueCollection();
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Email_General))
        {
            SetError("你不具有普通邮件设置的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (Request.HttpMethod == "POST")
        {
            setEmail();
        }
    }
    private void setEmail()
    {
        NameValueCollection values = new NameValueCollection();
        values.Add("mailname", Request.Form["mail_username"]);
        values.Add("time", Request.Form["time"]);
        values.Add("fucount", Request.Form["fucount"]);
        values.Add("maxcount", Request.Form["maxcount"]);
        for (int i = 0; i < values.Count; i++)
        {
            string strKey = values.Keys[i];
            string strValue = values[strKey];
            FileUtils.SetConfig(strKey, strValue);
        }

        ISystem isystem = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            isystem = session.System.GetByID(1);

            isystem.mailhost = Request["mail_host"];
            isystem.mailport = Request["mail_port"];
            if (Request["mailssl"] == "1")
            {
                isystem.mailssl = 1;
            }
            else
            {
                isystem.mailssl = 0;
            }
            isystem.mailuser = Request["mail_user"];
            isystem.mailpass = Request["mail_pass"];
            isystem.mailfrom = Request["mail_form"];
            isystem.mailinterval = Convert.ToInt32(Request["mail_interval"]);
            isystem.subscribehelpphone = Request["subscribe_helpphone"];
            isystem.subscribehelpemail = Request["subscribe_helpemail"];
            isystem.mailreply = Request["mail_reply"];
            int r = session.System.Update(isystem);
            if (r > 0)
            {
                SetSuccess("保存成功");
            }
            else
            {
                SetError("保存失败");
            }
            
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
                    
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>邮件设置</h2>
                                    <%--<ul class="filter">
                                        <li> <a href="SheZhi_Youjian.aspx" >普通邮件设置</a></li>
                                        <li> <a href="MailServerList.aspx" >群发邮件设置</a></li>
                                    </ul>--%>
                                </div>
                                <div class="sect">
						            <div class="wholetip clear"><h3>1、发信配置</h3></div>
						
						            <div id="mail-zone-smtp" style="display:block;">
                                    <div class="field">
                                        <label>SMTP主机</label>
                                        <input type="text" size="30" id="mail_host" name="mail_host" class="f-input" value="<%=PageValue.CurrentSystem.mailhost %>"/>
                                    </div>
                                    <div class="field">
                                        <label>SMTP端口</label>
                                        <input type="text" size="30" id="mail_port" name="mail_port" class="number" value="<%=PageValue.CurrentSystem.mailport %>" />
                                    </div>
                                    <div class="field">
                                        <label>SSL方式</label>
                                        <input type="checkbox" size="10"  value="1" name="mailssl" <%if(PageValue.CurrentSystem.mailssl==1){ %>checked<%} %> />
                                        <span style="color:Gray" >请按邮局要的要求，选择是否选用“SSL”。勾选代表“选择SSL”，不勾选则“不选择SSL”</span>
                                    </div>
                                    <div class="field">
                                        <label>验证用户名</label>
                                        <input type="text" size="30" id="mail_user" name="mail_user" class="f-input" value="<%=PageValue.CurrentSystem.mailuser %>" />
                                    </div>
                                    <div class="field">
                                        <label>用户别名</label>
                                        <input type="text" size="30" id="mail_username" name="mail_username" class="f-input" value="<%=PageValue.CurrentSystemConfig["mailname"] %>" />
                                        <span class="hint" >用户邮件中的发件人的昵称</span>
                                    </div>
                                    <div class="field">
                                        <label>验证密码</label>
                                        <input type="password" size="30" id="mail_pass" name="mail_pass" class="f-input"  value='<%=PageValue.CurrentSystem.mailpass %>'/>
                                    </div>
						            </div>
                                    <div class="field">
                                        <label>发信地址</label>
                                        <input type="text" size="30" id="mail_form" name="mail_form" class="f-input" value="<%=PageValue.CurrentSystem.mailfrom %>" />
                                        <span class="hint">发信邮件地址</span>
                                    </div>
                                    <div class="field">
                                        <label>回信地址</label>
                                        <input type="text" size="30" id="mail_reply" name="mail_reply" class="f-input" value="<%=PageValue.CurrentSystem.mailreply %>" />
                                        <span class="hint">回信邮件地址</span>
                                    </div>
                                    <div class="field">
                                        <label>发信频率</label>
                                        <input type="text" size="30" id="mail_interval" name="mail_interval" class="number" require="true" datatype="integer" value="<%=PageValue.CurrentSystem.mailinterval.ToString() %>" />
                                        <span class="inputtip">请按邮局要求的频率，设置每封邮件的发送时间间隔，单位：秒，建议设置：2-5 之间</span>
                                    </div>

						            <div class="wholetip clear"><h3>2、订阅设置（发送邮件订阅时邮件内容中的联系方式）</h3></div>
                                    <div class="field">
                                        <label>联系电话</label>
                                        <input type="text" size="30" id="subscribe_helpphone" name="subscribe_helpphone" class="f-input" value="<%=PageValue.CurrentSystem.subscribehelpphone %>" />
                                    </div>
                                    <div class="field">
                                        <label>联系邮件</label>
                                        <input type="text" size="30" id="subscribe_helpemail" name="subscribe_helpemail" class="f-input" value="<%=PageValue.CurrentSystem.subscribehelpemail %>" />
                                    </div>
                        	        <div class="wholetip clear"><h3>3、邮件群发设置</h3></div>
                                    <div class="field">
                                        <label>间隔时间</label>
                                        <input type="text" size="5" id="time" name="time" class="number" value="<%= PageValue.CurrentSystemConfig["time"] %>" /><span class="inputtip">以秒为单位</span>
                                    </div>
                                    <div class="field">
                                        <label>群发数量</label>
                                        <input type="text" size="5" id="fucount" name="fucount" class="number" value="<%= PageValue.CurrentSystemConfig["fucount"] %>" />
                                    </div>
                                    <div class="field">
                                        <label>最多发送数量</label>
                                        <input type="text" size="5" id="maxcount" name="maxcount" class="number" value="<%= PageValue.CurrentSystemConfig["maxcount"] %>" />
                                    </div>
                                    <div class="act">
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