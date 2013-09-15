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
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script runat="server">
    //Maticsoft.BLL.Partner_Detail partner_details = new Maticsoft.BLL.Partner_Detail();
    //Maticsoft.Model.Partner_Detail partner_detail = new Maticsoft.Model.Partner_Detail();
    //Maticsoft.Model.UserInfo usermodel = new Maticsoft.Model.UserInfo();
    //Maticsoft.BLL.UserInfo userbll = new Maticsoft.BLL.UserInfo();
    protected int pid = 0;
    protected IPartner_Detail partner_detailmodel = Store.CreatePartner_Detail();
    //protected Maticsoft.Model.Partner_Detail partner_detailmodel;
    protected IUser usermodel = Store.CreateUser();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (Request["id"] != null)
        {
            pid = int.Parse(Request["Id"].ToString());
            getContent(pid);

        }
        if (Request["buttontype"] == "确定")
        {
            string aa = pid.ToString();
            int ss = int.Parse(Request.Form["hidpmonetid"]);
            //partner_detailmodel = partner_details.GetModel(ss);
            int ires = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                partner_detailmodel = session.Partner_Detail.GetByID(ss);
                ires = session.Partner_Detail.Update(partner_detailmodel);
            }
            //partner_detailmodel.Remark = pmoneyremark.InnerText;
           
            //int ires = partner_details.Update(partner_detailmodel);
            if (ires > 0)
            {

                SetSuccess("结算备注保存成功！");
            }
            else
            {
                SetError("结算备注保存失败！");
            }
            Response.Redirect(Request.UrlReferrer.AbsoluteUri);
            Response.End();
            return;
        }



    }

    private void getContent(int id)
    {
        //partner_detailmodel = partner_details.GetModel(id);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            partner_detailmodel = session.Partner_Detail.GetByID(id);
            usermodel = session.Users.GetByID(partner_detailmodel.adminid);
        }
        //usermodel = userbll.GetModel(partner_detailmodel.Adminid);
        
        if (usermodel != null && partner_detailmodel.adminid != 0)
        {
            pmoneyadminName.InnerText = usermodel.Username;
        }
        if (partner_detailmodel.settlementstate == 1)
        {
            pmoneystate.InnerText = "待审核";
        }
        else if (partner_detailmodel.settlementstate == 2)
        {
            pmoneystate.InnerText = "拒绝";
        }
        else if (partner_detailmodel.settlementstate == 4)
        {
            pmoneystate.InnerText = "正在结算";
        }
        else if (partner_detailmodel.settlementstate == 8)
        {
            pmoneystate.InnerText = "已结算";
        }
        //pmoneyremark.InnerText  = partner_detailmodel.Remark;
    }
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:500px;">
	<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>结算单详情</h3>
	<div id="Div1" style="overflow-x:hidden;padding:10px;" runat="server">
	<table width="96%" class="coupons-table-xq">
		
   
       <tr><td class="style1"><b>结算时间：</b></td><td class="style1"><label id="pmoney_time" runat="server"><%=partner_detailmodel.createtime%></label></td></tr>
		<tr><td><b>管理员：</b></td><td><label id="pmoneyadminName" name="adminName" runat="server"></label></td></tr>
		<tr><td><b>结算状态：</b></td><td><label id="pmoneystate" runat="server"></label></td></tr>
         <tr><td><b>备注：</b></td><td> 
          <%=partner_detailmodel.remark%>     
        </td></tr>
        <tr><td>&nbsp</td></tr>
         <tr>
        
        <td  align ="left">
         
        <input type="hidden" id="hidpmonetid"name="hidpmonetid" value="<%=pid%>" />
       </td>

        </tr>
	</table>
	</div>
</div>
<script type ="text/javascript" >
    window.x_init_hook_validator();
    $('textarea').xheditor({ tools: 'mfull', upImgUrl: webroot + 'upload.aspx?immediate=1', urlType: 'abs' });
</script>