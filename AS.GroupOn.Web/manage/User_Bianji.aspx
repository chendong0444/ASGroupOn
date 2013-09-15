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
<script runat="server">
    protected IUser users = null;
    protected int id = 0;
    protected int url = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Admin_Edit))
        {
            SetError("你不具有编辑管理员列表的权限！");
            Response.Redirect("User.aspx");
            Response.End();
            return;

        }
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
                                <div class="head" style="height:35px;">
                                    <h2>
                                        编辑用户</h2>
                                    <b style="margin-left: 20px; font-size: 16px;">（<%=users.Email %>/<%=users.Username %>）</b></div>
                                <div class="sect">
                                    <input type="hidden" name="id" value="<%=users.Id %>" />
                                    <div class="wholetip clear">
                                        <h3>
                                            1、身份信息</h3>
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
                                    <div class="field">
                                        <label>
                                            真实姓名</label>
                                        <input type="text" size="30" name="realname" id="realname" class="f-input" value="<%=users.Realname %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            QQ号码</label>
                                        <input type="text" size="30" name="qq" id="qq" class="number" value="<%=users.Qq %>" />
                                    </div>
                                    <div class="field password">
                                        <label>
                                            登录密码</label>
                                        <input type="text" size="30" name="password" id="password" class="f-input"
                                             />
                                        <span class="hint">如果不想修改密码，请保持空白</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            2、基本信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            邮政编码</label>
                                        <input type="text" size="30" name="zipcode" id="zipcode" class="f-input" value="<%=users.Zipcode %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            配送地址</label>
                                        <input type="text" size="30" name="address" id="address" class="f-input" value="<%=users.Address %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            手机号码</label>
                                        <input type="text" size="30" name="mobile" id="mobile" class="number" value="<%=users.Mobile %>"
                                            maxlength="11" />
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            3、激活状态</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            用户激活</label>
                                        <%if (users.Enable == "Y")
                                          {%>
                                        <input type="text" size="30" value="Y" name="enablevalue" group="user" datatype="english" class="number" maxlength="1"
                                            style="text-transform: uppercase;" />
                                        <% }
                                          else if (users.Enable == "N")
                                          {%>
                                        <input type="text" size="30" value="N" name="enablevalue" class="number" datatype="english" group="user" maxlength="1"
                                              style="text-transform: uppercase;" />
                                        <%}
                                            else
                                            {%>
                                        <input type="text" size="30" value="N" name="enablevalue" class="number" datatype="english" group="user" maxlength="1"
                                              style="text-transform: uppercase;" />
                                           <% } %>
                                        <span class="inputtip" id="SPAN2">Y:是 N:否</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            4、附加信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            邮件验证</label>
                                        <input type="text" size="30" name="secret" id="secret" class="f-input" />
                                        <span class="hint">通过验证，请清空该字段</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            管理员</label>
                                        <%if (users.Manager == "Y")
                                          {%>
                                        <input type="text" size="30" value="Y" name="manager" class="number" group="user" datatype="english" maxlength="1"
                                            style="text-transform: uppercase;"
                                             />
                                        <% }
                                          else if (users.Manager == "N")
                                          {%>
                                        <input type="text" size="30" value="N" name="manager" class="number" group="user" datatype="english" maxlength="1"
                                             style="text-transform: uppercase;" />
                                        <%}
                                            else
                                            {%>
                                        <input type="text" size="30" value="N" name="manager" class="number" group="user" datatype="english" maxlength="1"
                                            style="text-transform: uppercase;" />
                                           <% } %>
                                        <span class="inputtip" id="SPAN1">Y:是 N:否</span>
                                    </div>
                                    <div class="act">
                                    <input type="hidden" name="action" value="updateuser" />
                                        <input type="submit" value="编辑" name="commit" id="submit" class="formbutton validator"
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