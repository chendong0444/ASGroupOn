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
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (Request.QueryString["Id"] != null)
        {
            setContent(int.Parse(Request["Id"].ToString()));
        }
    }
    private void setContent(int id)
    {
        IUser user = AS.GroupOn.App.Store.CreateUser();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            user = session.Users.GetByID(id);
        }
        user_Id.Value = user.Id.ToString();
        user_email.InnerText = user.Email;
        user_username.InnerText = user.Username;
        user_realname.InnerText = user.Realname;
        user_mobile.InnerText = user.Mobile;
        user_zipcode.InnerText = user.Zipcode;
        user_address.InnerText = user.Address;
        user_ip.InnerText = user.IP;
        user_money.InnerText = user.Money.ToString();
        user_score.InnerText = user.userscore.ToString();
    }
    </script>
<form id="Form1" runat="server">
    <div id="order-pay-dialog" class="order-pay-dialog-c" style="width:380px;">
	<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>用户信息及充值</h3>
	<div style="overflow-x:hidden;padding:10px;">
	<table width="96%" class="coupons-table-xq">
		<tr><td width="80"><b>Email：</b></td><td><label id="user_email" runat="server"></label></td></tr>
		<tr><td><b>用户名：</b></td><td><label id="user_username" runat="server"></label></td></tr>
		<tr><td><b>真实姓名：</b></td><td><label id="user_realname" runat="server"></label></td></tr>
		<tr><td class="style1"><b>手机号码：</b></td><td class="style1"><label id="user_mobile" runat="server"></label></td></tr>
		<tr><td><b>邮政编码：</b></td><td><label id="user_zipcode" runat="server"></label></td></tr>
		<tr><td><b>派送地址：</b></td><td><label id="user_address" runat="server"></label></td></tr>
		<tr><td><b>注册IP：</b></td><td><label id="user_ip" runat="server"></label></td></tr>
		<tr><td colspan="2"><hr /></td></tr>
		<tr><td><b>账户余额：</b></td><td><b><label id="user_money" runat="server"></label></b> 元</td></tr>
		<tr><td><b>积分余额：</b></td><td><b><label id="user_score" runat="server"></label></b> 分</td></tr>
		<tr><td><b>消费统计：</b></td><td>共消费 <b><label id="user_constcount" runat="server"></label></b> 次，累计 <b><label id="user_cost" runat="server"></label></b> 元</td></tr>
        <input id="user_Id" type="hidden" runat="server" />
        <tr><td colspan="2"><hr /></td></tr>
		<tr><td><b>账户充值：</b></td><td><input type="text" name="inputmoeny" id="user_input_money" value="0" size="6" maxLength="6"  require="true"  group="user"  />
        
        </td></tr>

        <tr><td><b>积分充值：</b></td><td><input type="text" name="score" id="score" value="0" size="6" maxLength="6"  require="true"  group="user"  />
        
        </td></tr>


         <tr><td>
        <input type="submit" name="button" id="button" value="确定" ask="确定给该用户充值吗？" group="user"  class="formbutton validator" />
        </td>
        </tr>
	</table>
	</div>
</div>
</form>
<script>
    window.x_init_hook_validator();
</script>

