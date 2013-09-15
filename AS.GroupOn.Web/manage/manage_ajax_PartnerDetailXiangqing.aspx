<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace=" AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    protected int pdid = 0;
    protected IPartner_Detail Ipardetail = new AS.GroupOn.Domain.Spi.Partner_Detail();
    protected IPartner_Detail pardetail = new AS.GroupOn.Domain.Spi.Partner_Detail();
    protected IUser user = new AS.GroupOn.Domain.Spi.User();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Partnet_JiesuanDetail)) 
        {
            SetError("没有查看结算详情的权限");
            Response.Redirect("JieSuan_ShenHe.aspx");
            Response.End();
            return;
        }
        if (!IsPostBack)
        {
            pdid = AS.Common.Utils.Helper.GetInt(Request["Id"], 0);
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
        {
            Ipardetail = session.Partner_Detail.GetByID(pdid);
        }
        if (Ipardetail != null)
        {
           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
           {
               user = session.Users.GetByID(Ipardetail.adminid);
           }
           pmoneyremark.InnerHtml =AS.Common.Utils.Helper.GetString(Ipardetail.remark,String.Empty);
        }

        if (Request["button"] == "确定") 
        {
            int id = AS.Common.Utils.Helper.GetInt(Request["pdid"], 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                Ipardetail = session.Partner_Detail.GetByID(id);
            }
            pardetail.settlementremark = Ipardetail.settlementremark;
            pardetail.settlementstate = AS.Common.Utils.Helper.GetInt(Request["Settlementstate"], 1);
            pardetail.partnerid = Ipardetail.partnerid;
            pardetail.adminid = Ipardetail.adminid;
            pardetail.money = Ipardetail.money;
            pardetail.remark = AS.Common.Utils.Helper.GetString( Request["pmoneyremark"].Length > 1500 ? Request["pmoneyremark"].Substring(0, 1500) : Request["pmoneyremark"], String.Empty);
            pardetail.team_id = Ipardetail.team_id;
            pardetail.num = Ipardetail.num;
            pardetail.createtime = Ipardetail.createtime;
            pardetail.id = AS.Common.Utils.Helper.GetInt(Request["pdid"], 0);
            int count = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
            {
                count = session.Partner_Detail.Update(pardetail);
            }
            if (count > 0)
            {
                SetSuccess("结算备注保存成功！");
            }
            else 
            {
                SetError("结算备注保存失败！");
            }
            Response.Redirect("JieSuan_ShenHe.aspx?Id="+pardetail.partnerid+"");
            Response.End();
            return;
        }


    }
</script>

    <form id="form1" action="manage_ajax_PartnerDetailXiangqing.aspx">
       <div id="order-pay-dialog" class="order-pay-dialog-c" style="width:600px;">
       <h3>
          <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>结算单详情
       </h3>
	    <div id="Div1" style="overflow-x:hidden;padding:10px;">
	    <table class="coupons-table-xq">
		     <tr>
             <input type="hidden" value="<%=pdid %>" name="pdid" />
                <td><b>结算时间：</b></td>
                <td><label id="pmoney_time"><%= Ipardetail.createtime.ToString("yyyy-MM-dd HH:ss:mm") %></label></td>
            </tr>
		    <tr>
                <td><b>管理员：</b></td>
                <td><label id="pmoneyadminName" name="adminName">
                <% if (user != null)
                   { %>
                <%=user.Username%>
                <%} %></label></td>
            </tr>
		    <tr>
                <td class="style2"><b>结算状态：</b></td>
                <td class="style1"><label id="pmoneystate">
                 <% if (Ipardetail.settlementstate == 1)
                    { %>
                    待审核
                 <%}
                    else if (Ipardetail.settlementstate == 2)
                    { %>
                    被拒绝
                 <%}
                    else if (Ipardetail.settlementstate == 4)
                    { %>
                    正在结算
                 <%}else if(Ipardetail.settlementstate==8) {%>
                
                    已结算
                 <%} %>
                </label>
                <input type="hidden" value="<%= Ipardetail.settlementstate%>" name="Settlementstate" />
                </td>
            </tr>
            <tr>
                <td class="style2"><b>备注：</b></td>
                <td class="style1"><textarea name="pmoneyremark" id="pmoneyremark" 
                        style="width:414px; height:300px; margin-left: 4px;" runat="server"></textarea></td>
            </tr>
            <tr>
                <td class="style2">&nbsp;</td>
            </tr>
            <tr>
                <td></td>
                <td  align ="left" class="style2">
                <input type="submit" value="确定" name ="button" id="button" class="formbutton validator"  />
                <input type="hidden" id="hidpmonetid"name="hidpmonetid"/>
               </td>
            </tr>
	    </table>
	    </div>
    </div>
    </form>
<script type="text/javascript">
    $('textarea').xheditor({ tools: 'mfull', upImgUrl: webroot + 'upload.aspx?immediate=1', urlType: 'abs' });
</script>
