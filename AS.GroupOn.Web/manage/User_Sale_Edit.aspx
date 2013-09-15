<%@ Page Language="C#" Inherits="AS.GroupOn.Controls.AdminPage" %>
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
    protected ISales sales = null;
    public string saleState = "";
    protected int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (Request.QueryString["state"] == "addsale")
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Sale_Add))
            {
                SetError("你不具有添加销售人员的权限！");
                Response.Redirect("User_Sale.aspx");
                Response.End();
                return;

            }
        }
        if (Request.QueryString["state"] == "updatesale")
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Sale_Edit))
            {
                SetError("你不具有编辑销售人员的权限！");
                Response.Redirect("User_Sale.aspx");
                Response.End();
                return;

            }
        }

        if (!string.IsNullOrEmpty(Request.QueryString["id"]))
        {
            id = Helper.GetInt(Request.QueryString["id"], 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                sales = session.Sales.GetByID(id);
            }
        }

        if (!object.Equals(Request.QueryString["state"], null))
        {
            saleState = Request.QueryString["state"].ToString();
        }


    }
   
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server" method="post">
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
                                        添加销售人员</h2>
                                </div>
                                <div id="Div1">
                                   
                                        
                                            <div class="head">
                                                <h2>
                                                    <asp:Literal ID="ltEditState" runat="server"></asp:Literal></h2>
                                            </div>
                                            <div class="sect">
                                                <div class="field">
                                                    <%if (id > 0)
                                                      {%>
                                                    <input type="hidden" name="action" value="changesales" />
                                                    <input type="hidden" name="id" value="<%=sales.id %>" />
                                                    <label>
                                                        用户名</label>
                                                    <input type="text" name="username" size="30" require="true" datatype="require" maxlength="500"
                                                        id="username" class="f-input" value="<%=sales.username %>" />
                                                </div>
                                                <div class="field">
                                                    <label>
                                                        真实姓名</label>
                                                    <input type="text" name="realname" size="30" id="realname" class="f-input" value="<%=sales.realname %>" />
                                                </div>
                                                <div class="field password">
                                                    <label>
                                                        登录密码</label>
                                                    <input type="text" name="password" size="30" id="password" class="f-input" value="" />
                                                    <% ltEditState.Text = "编辑用户(销售人员)"; ltMessage.Text = "如果不想修改密码，请保持空白";%>
                                                    <div class="hint">
                                                        <asp:Literal ID="ltMessage" runat="server"></asp:Literal></div>
                                                </div>
                                                <div class="field">
                                                    <label>
                                                        联系电话</label>
                                                    <input type="text" name="contact" size="30" id="telphone" class="f-input" style="width: 150px;"
                                                        value="<%=sales.contact %>" />
                                                </div>
                                                <div class="act">
                                                    <input type="submit" value="编辑" name="commit" id="submit" class="formbutton validator"
                                                        group="a" />
                                                    <%}
                                                      else
                                                      {%>
                                                    <input type="hidden" name="action" value="addsales" />
                                                    <label>
                                                        用户名</label>
                                                    <input type="text" name="username" size="30" require="true" datatype="require" maxlength="500"
                                                        id="Text2" class="f-input" />
                                                </div>
                                                <div class="field">
                                                    <label>
                                                        真实姓名</label>
                                                    <input type="text" name="realname" size="30" require="true" maxlength="500" id="Text4"
                                                        class="f-input" />
                                                </div>
                                                <div class="field password">
                                                    <label>
                                                        登录密码</label>
                                                    <input type="text" name="password" size="30" group="a" require="true" datatype="require"
                                                        id="Text6" class="f-input" />
                                                    <%ltEditState.Text = "添加用户(销售人员)"; ltMessage.Text = ""; %>
                                                    <div class="hint">
                                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal></div>
                                                </div>
                                                <div class="field">
                                                    <label>
                                                        联系电话</label>
                                                    <input type="text" name="contact" size="30" require="true" maxlength="500" id="Text8"
                                                        class="f-input" />
                                                </div>
                                                <div class="act">
                                                    <input type="submit" value="提交" name="commit" id="submit3" class="formbutton validator"
                                                        group="a" />
                                                    <% }
                                                    %>
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