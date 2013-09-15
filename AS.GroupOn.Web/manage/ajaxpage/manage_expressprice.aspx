<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation= "false " Inherits="AS.GroupOn.Controls.AdminPage" %>

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
    protected int id = 0;
    protected decimal oneprice = 0;
    protected decimal twoprice = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        id = Helper.GetInt(Request["id"], 0);
        IExpressprice expressprice = Store.CreateExpresspric();
       id = Helper.GetInt(Request["id"], 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            expressprice = session.Expressprice.GetByExpressID(id);
        }
        
        if (expressprice != null)
        {
                oneprice = expressprice.oneprice;
                twoprice = expressprice.twoprice;
        }
    }
</script>

<form id="form1" method="post" action="<%=PageValue.WebRoot%>manage/ajax_manage.aspx?action=freightedit">
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:380px;">
	<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span></h3>
	<div style="overflow-x:hidden;padding:10px;">

	<table width="96%" class="coupons-table-xq">
		<tr><td width="80" valign="top" nowrap><b>首件运费价格变化：</b></td><td><input group="city" value="<%=oneprice %>" type="text" name="oneprice" id="oneprice"  require="true" datatype="double" class="f-input"/><p style="clear: left; color: rgb(152, 152, 152); float: left; font-size: 12px; margin-left: 0px; width: 220px;">指快递模板设置价格上下浮动价格。增加写正数，减少写负数。</p></td></tr>
		<tr><td valign="top"><b>次件运费价格变化：</b></td><td><input type="text" group="city" value="<%=twoprice %>" name="twoprice" id="twoprice" require="true" datatype="double" class="f-input" /></td></tr>
		<tr><td colspan="2" height="10">
            <input id="id" type="hidden" name="id" value="<%=id%>" />
        </td></tr>
       
		<tr><td></td><td><input type="submit" name="button" group="city" class="validator" value="确定"  /></td></tr>
	</table>
	</div>
</div>

<script>
    window.x_init_hook_validator();
</script>
</form>