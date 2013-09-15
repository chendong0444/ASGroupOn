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
    protected ProductFilter productft = new ProductFilter();
    protected int id = 0;
    protected IProduct productmodel;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        id = Helper.GetInt(Request["id"], 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            productmodel = session.Product.GetByID(id);
        }
    }
</script>
<form id="form1" runat="server">
    <div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
        <h3>
            <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>产品审核</h3>
        <div style="overflow-x: hidden; padding: 10px;">
            <input type="hidden" name="id" value="<%=id %>" />
            <table class="coupons-table-xq">
                <tr>
                    <td>
                        <b>状态：</b>
                    </td>
                    <td>
                        <select id="ddlproductstatus" name="ddlproductstatus">
                            <%if (productmodel != null)
                              { %>
                            <option value="1" <%if (productmodel.status == 1)
                                                {%>selected <% } %>>上架</option>
                            <%if (productmodel.status != 1 && productmodel.status != 8)
                              { %>
                            <option value="2" <%if (productmodel.status == 2)
                                                {%>selected <% } %>>拒绝</option>
                            <%} %>
                            <option value="8" <%if (productmodel.status == 8)
                                                {%>selected <% } %>>下架</option>
                            <%} %>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td>
                        <b>备注：</b>
                    </td>
                    <td>
                        <textarea id="remark" cols="40" rows="5" name="remark"></textarea>
                    </td>
                </tr>
                <tr>
                    <td colspan="2" height="10">&nbsp;
                    </td>
                </tr>
                <tr>
                    <td>&nbsp;
                    </td>
                    <td>
                        <input type="hidden" name="action" value="check" />
                        <input id="Submit1" type="submit" value="提交" name="commit" class="validator formbutton"
                            group="g" />
                    </td>
                </tr>
            </table>
        </div>
    </div>
</form>
