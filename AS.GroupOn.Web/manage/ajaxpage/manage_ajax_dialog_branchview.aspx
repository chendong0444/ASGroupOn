<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">
    //Maticsoft.BLL.Branch branchbll = new BLL.Branch();
    protected IBranch branch = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            int branchid = Helper.GetInt(Request["id"], 0);
            //DataSet ds = branchbll.GetbranchAll(branchid);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                branch = session.Branch.GetByID(branchid);
            }
            if (branch!=null)
            {
                //for (int i = 0; i < ds.Tables[0].Rows.Count; i++)
                //{
                lb_branchid.Text = branch.id.ToString();
                lb_username.Text = branch.username.ToString();
                lb_userpwd.Text = branch.userpwd.ToString();
                lb_branchname.Text = branch.branchname.ToString();
                lb_contact.Text = branch.contact.ToString();
                lb_phone.Text = branch.phone.ToString();
                lb_address.Text = branch.address;
                    lb_mobile.Text = branch.mobile.ToString();
                    lb_point.Text = branch.point.ToString();
                    lb_secret.Text = branch.secret.ToString();
                    lb_verifymobile.Text = branch.verifymobile.ToString();
                //}
            }



        }



    }

</script>
<head>
    <style type="text/css">
        .coupons-table-xq
        {
            width: 85%;
        }
    </style>
</head>

<div id="order-pay-dialog" class="order-pay-dialog-c" 
    style="width:538px; height: 333px;">
	<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>分站详情</h3>
	<div style="overflow-x:hidden; padding:10px;">
	<table align="center" class="coupons-table-xq">
	<tr><td><b>分站ID：</b></td><td>
        <asp:label runat="server" text="" id="lb_branchid"></asp:label>
    </td></tr>

		<tr><td><b>用户名：</b></td><td>
        <asp:label runat="server" text="" id="lb_username"></asp:label></td></tr>
		<tr><td><b>登录密码：</b></td><td>
        <asp:label runat="server" text="" id="lb_userpwd"></asp:label></td></tr>

        <tr><td><b>分站名称：</b></td><td>
        <asp:label runat="server" text="" id="lb_branchname"></asp:label></td></tr>

        <tr><td><b>联系人：</b></td><td>
        <asp:label runat="server" text="" id="lb_contact"></asp:label></td></tr>
		<tr><td><b>联系电话：</b></td><td>
        <asp:label runat="server" text="" id="lb_phone"></asp:label></td></tr>
		<tr><td><b>联系地址：</b></td><td>
        <asp:label runat="server" text="" id="lb_address"></asp:label></td></tr>
		<tr><td><b>联系人手机:</b></td><td>
        <asp:label runat="server" text="" id="lb_mobile"></asp:label></td></tr>

		<tr><td><b> 经纬度：  </b></td>
        <td><asp:label runat="server" text="" id="lb_point"></asp:label></td></tr>
		<tr><td><b> 消费密码：</b></td><td>
        <asp:label runat="server" text="" id="lb_secret"></asp:label></td></tr>
		<tr><td><b> 验证电话：</b></td><td>
        <asp:label runat="server" text="" id="lb_verifymobile"></asp:label></td></tr>
	</table>
	</div>
</div>

