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
    
    protected IMailserver imailserver = null;
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        
        if (Request["updateId"] != null && Request["updateId"].ToString() != "")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Email_SentManyService_Edit))
            {
                SetError("你不具有编辑群发邮件服务设置的权限！");
                Response.Redirect("MailServerList.aspx");
                Response.End();
                return;
            }
            else
            {
                Update();
            }
        }
        else
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Email_SentManyService_Add))
            {
                SetError("你不具有添加群发邮件服务设置的权限！");
                Response.Redirect("MailServerList.aspx");
                Response.End();
                return;
            }
        }
    }
    /// <summary>
    /// 编辑加载数据
    /// </summary>
    protected void Update()
    {
        int strid = Helper.GetInt(Request["updateId"], 0);
        if (strid > 0)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                imailserver = session.Mailserver.GetByID(strid);
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
                                    <h2>
                                    <%if (imailserver != null)
                                      { %>编辑邮件服务<%}
                                      else
                                      { %>
                                       新增邮件服务
                                       <%} %>
                                    </h2>
                                </div>
                                <div class="sect">
                                    <%if (imailserver != null)
                                      { %>
                                        <div id="mail-zone-smtp" style="display:block;">
                                        <div class="field">
                                            <label>SMTP主机</label>
                                            <input type="text" size="30"  name="mail[host]" class="f-input"   value='<%=imailserver.smtphost %>' />
                                        </div>
                                        <div class="field">
                                            <label>SMTP端口</label>
                                            <input type="text" size="30"  name="mail[port]" class="number"  value='<%=imailserver.smtpport %>'/>
                                        </div>
                                        <div class="field">
                                            <label>SSL方式</label>
                                            <input type="checkbox" size="10"  value="1" name="mailssl"  <%if(imailserver.ssl==1){ %>checked<%} %>  />
                                            <span style="color:Gray" >请按邮局要的要求，选择是否选用“SSL”。勾选代表“选择SSL”，不勾选则“不选择SSL”</span>
                                        </div>
                                        <div class="field">
                                            <label>验证用户名</label>
                                            <input type="text" size="30"  name="mail[user]" class="f-input"  value='<%=imailserver.mailuser %>'/>
                                        </div>
                                         <div class="field">
                                            <label>用户别名</label>
                                            <input type="text" size="30"  name="mail_username" class="f-input"  value='<%=imailserver.realname %>'/>
                                            <span class="hint" >用户邮件中的发件人的昵称</span>
                                        </div>
                                        <div class="field">
                                            <label>验证密码</label>
                                            <input type="text" size="30"  name="mail[pass]" class="f-input"  value='<%=imailserver.mailpass %>'/>
                                        </div>
						                </div>
                                        <div class="field">
                                            <label>发信地址</label>
                                            <input type="text" size="30"  name="mail[from]" class="f-input"  value='<%=imailserver.sendmail %>'/>
                                            <span class="hint">发信邮件地址</span>
                                        </div>
                                        <div class="field">
                                            <label>回信地址</label>
                                            <input type="text" size="30" name="mail[reply]" class="f-input"  value='<%=imailserver.receivemail %>'/>
                                            <span class="hint">回信邮件地址</span>
                                        </div>
                                        <div class="field">
                                            <label>最多发送数量</label>
                                            <input type="text" size="30" name="sendcount" class="number"  value='<%=imailserver.sendcount %>'/>
                                            <span class="hint">邮件最多发送数量</span>
                                        </div>
                                        <input type="hidden" name="id" value="<%=imailserver.id %>" />
                                        <input type='hidden' name='action' value='updatemailserver' />
                                    <%}
                                      else
                                      { %>
                                        <div id="mail-zone-smtp" style="display:block;">
                                        <div class="field">
                                            <label>SMTP主机</label>
                                            <input type="text" size="30" id="mail_host" name="mail[host]" class="f-input"   value='' />
                                        </div>
                                        <div class="field">
                                            <label>SMTP端口</label>
                                            <input type="text" size="30" id="mail_port" name="mail[port]" class="number"  value=''/>
                                        </div>
                                        <div class="field">
                                            <label>SSL方式</label>
                                            <input type="checkbox" size="10"  value="1" name="mailssl"  />
                                            <span style="color:Gray" >请按邮局要的要求，选择是否选用“SSL”。勾选代表“选择SSL”，不勾选则“不选择SSL”</span>
                                        </div>
                                        <div class="field">
                                            <label>验证用户名</label>
                                            <input type="text" size="30" id="mail_user" name="mail[user]" class="f-input"  value=''/>
                                        </div>
                                         <div class="field">
                                            <label>用户别名</label>
                                            <input type="text" size="30" id="mail_username" name="mail_username" class="f-input"  value=''/>
                                            <span class="hint" >用户邮件中的发件人的昵称</span>
                                        </div>
                                        <div class="field">
                                            <label>验证密码</label>
                                            <input type="text" size="30" id="mail_pass" name="mail[pass]" class="f-input"  value=''/>
                                        </div>
						                </div>
                                        <div class="field">
                                            <label>发信地址</label>
                                            <input type="text" size="30" id="mail_form" name="mail[from]" class="f-input"  value=''/>
                                            <span class="hint">发信邮件地址</span>
                                        </div>
                                        <div class="field">
                                            <label>回信地址</label>
                                            <input type="text" size="30" id="mail_reply" name="mail[reply]" class="f-input"  value=''/>
                                            <span class="hint">回信邮件地址</span>
                                        </div>
                                        <div class="field">
                                            <label>最多发送数量</label>
                                            <input type="text" size="30" id="sendcount" name="sendcount" class="number"  value=''/>
                                            <span class="hint">邮件最多发送数量</span>
                                        </div>
                                        <input type='hidden' name='action' value='addmailserver' />
                                    <%} %>
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