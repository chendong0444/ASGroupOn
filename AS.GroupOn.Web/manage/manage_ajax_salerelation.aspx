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
<%@ Import Namespace="System" %>
<script runat="server">
    protected ISales sales = Store.CreateSales();
    protected string teamids = "";
    protected int saleid =0; 
    protected int scuesscount = 0;
    protected string fail = "";
    protected ITeam teammodel = Store.CreateTeam();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Sale_BindTeam))
        {
            SetError("你不具有绑定项目的权限！");
            Response.Redirect("User_Sale.aspx");
            Response.End();
            return;

        }
       teamids = teamid.Value.ToString().Trim();
      saleid= Helper.GetInt(Request.QueryString["saleid"], 0);
    }
   
    
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 680px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>导入相关项目</h3>
    <div id="Div1" style="overflow-x: hidden; padding: 10px; padding-top: 0px; text-align: center;"
        runat="server">
        <form id="form1" method="post">
        <table width="96%" class="coupons-table-xq">
            <tr>
                <td>
                    <div style="text-align: left; padding-left: 10px;">
                        <label>
                            请输入项目ID:<asp:literal id="ltmessage" runat="server"></asp:literal></div>
                    <textarea id="teamid" name="teamid" class="f-input" runat="server" style="width: 90%;
                        height: 100px;" datatype="require" require="true"></textarea>
                  <input type="hidden" name="saleid" value="<%=saleid%>" />
                    <div class="hint" style="text-align: left; padding: 0 56px;">
                        注：1、输入规则：请输入与该销售人员相关联的项目ID，多个项目间用半角逗号(英文半角）分隔
                        <p style="padding-left: 23px;">
                            2、绑定失败可能原因：项目ID不存在，输入数字和逗号之外的字符等</p>
                        <p style="padding-left: 23px;">
                            3、绑定项目ID后，如果该项目下有商户，系统会自动将销售人员和商户做关联</p>
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <input type="hidden" name="action" value="bindteam" />
                    <input type="submit" name="commit" id="submit" runat="server" group="goto" class="validator formbutton" value="绑定"/>
                </td>
            </tr>
        </table>
        </form>
    </div>
</div>
<script type="text/javascript">
    $(function () {
        $("#teamid").blur(function (event) {
            var p = $("#teamid").val();
            if (p == "") {
                $("#teamid").attr("class", "f-input errorInput");
            }
            else {
                $("#teamid").attr("class", "f-input");
            }
        });
    });
</script>
