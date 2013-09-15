<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


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
    protected IUser users = null;
    protected int id = 0;
    protected int url = 0;
    protected override void OnLoad(EventArgs e)
    {           
        base.OnLoad(e);
        if (!string.IsNullOrEmpty(Request.QueryString["id"]))
        {
            id = Helper.GetInt(Request.QueryString["id"], 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                users = session.Users.GetByID(id);
            }
        }
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" method="post">
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
                                        修改密码</h2>
                                    <b style="margin-left: 20px; font-size: 16px;">（<%if (users!=null)
                                                                                      {
                                                                                          %><%=users.Email %>/<%=users.Username %><%
                                                                                      } %>）</b></div>
                                <div class="sect">
                                    <input type="hidden" name="id" value="<%=users.Id %>" />
                                    <div class="wholetip clear">
                                        
                                    </div>
                                    <div class="field">
                                        <label>
                                            用户Email</label>
                                        <input type="text" size="30" readonly="readonly" name="email" id="email"  class="f-input" value="<%= users.Email %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            用户名</label>
                                        <input type="text" size="30" name="username" id="username" require="true" datatype="require" class="f-input" value="<%=users.Username %>" />
                                    </div>
                                    <div class="field password">
                                        <label>
                                            登录密码</label>
                                        <input type="password" size="30" name="password" id="password" class="f-input" value="<%=users.Password %>"
                                             />
                                    </div>
                                    <div class="field">
                                        <label>
                                            新密码</label>
                                        <input type="password" size="30" name="newpwd" id="newpwd" class="f-input"/>
                                    </div>
                                    <div class="field">
                                        <label>
                                            确认新密码</label>
                                        <input type="password" size="30" name="confirmpwd" id="confirmpwd" class="number" />
                                    </div>
                                   
                                    <div class="act">
                                    <input type="hidden" name="action" value="updatepwd" />
                                        <input type="submit" value="修改" name="commit" id="submit" class="formbutton validator"
                                            group="user" />
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