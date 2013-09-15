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
    /// <summary>
    /// 商户ID
    /// </summary>
    protected IRefunds refunds = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        int refundid = Helper.GetInt(Request.QueryString["id"], 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            refunds = session.Refunds.GetByID(refundid);
        }
    }
</script>
<form id="Form1" runat="server">
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 680px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span><span
            id="bian" runat="server"></span><span id="xin" runat="server"></span><span id="mingcheng"
                runat="server"></span></h3>
    <div id="Div1" style="overflow-x: hidden; padding: 10px;" runat="server">
        <p>
        </p>
        <input id="hid" type="hidden" runat="server" />
        <table width="96%" class="coupons-table-xq">
            <tr>
                <td width="80" nowrap>
                    <b>退款备注：</b>
                </td>
                <td>
                <%if (refunds.State <= 8)
                  { %>
                    <textarea name="remark" id="remark" style="width: 500px; height: 300px;"><%=refunds.Result%></textarea>
                    <%}else{ %>
                    <%=refunds.Result%>
                    <%} %>
                </td>
            </tr>
            <%if (refunds.State <= 8)
              { %>
            <tr>
                <td>
                </td>
                <td>
                    <input type="button" name="commit" onclick="refundover()"  class="formbutton" value="退款" />
                </td>
            </tr>
            <%} %>
        </table>
    </div>
</div>
</form>
<script type="text/javascript">
  window.x_init_hook_validator();
    $('textarea').xheditor({ tools: 'mfull', upImgUrl: '../upload.aspx?immediate=1', urlType: 'abs' });
    
    function refundover() {
        if ($("#remark").val() == "") {
            alert("备注总得写点什么吧");
            return false;
        }
        var rid=<%=refunds.Id %>;
        var url="ajax_manage.aspx?action=refundover";
        X.post(url,{"rid":rid,"remark":$("#remark").val()});
    
    }
</script>