<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<script runat ="server">
    protected IPartner_Detail pardetail = new AS.GroupOn.Domain.Spi.Partner_Detail();
    protected IPartner_Detail parList = new AS.GroupOn.Domain.Spi.Partner_Detail();
    protected int Id = 0;
    protected int partnerid = 0;
    protected int adminid = 0;
    protected decimal money = 0;
    protected string Remark = String.Empty;
    protected int Team_id=0;
    protected int num = 0;
    protected int sta = 0;
    protected int pid = 0;
    protected int jiesuannum = 0;
    protected override void  OnLoad(EventArgs e)
    {
 	    base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Partner_Jiesuan_Examine)) 
        {
            SetError("你没有审核结算信息的权限");
            Response.Redirect("JieSuan_ShenHe.aspx");
            Response.End();
            return;
        }
        
        if (Request.QueryString["State"] != "true")
        {
            //审核结算时所申请的结算数量
            jiesuannum = AS.Common.Utils.Helper.GetInt(Request["num"], 0);
            Team_id = AS.Common.Utils.Helper.GetInt(Request["teamid"], 0);
            sta = AS.Common.Utils.Helper.GetInt(Request["sta"], 1); //结算状态--8代表已结算。1代表待审核. 2代表被拒绝 ,4代表正在结算
            pid = AS.Common.Utils.Helper.GetInt(Request["pid"], 0);
            Id = AS.Common.Utils.Helper.GetInt(Request["id"], 0);
        }
        else
        {
            
            Id = AS.Common.Utils.Helper.GetInt(Request.QueryString["id"], 0);
            int yjs = AS.Common.Utils.Helper.GetInt(Request.QueryString["yinjie"], 0);         //项目因结算数量
            int yijie = AS.Common.Utils.Helper.GetInt(Request.QueryString["yijie"], 0);        //项目已结算数量
            int sqjiesuan = AS.Common.Utils.Helper.GetInt(Request.QueryString["sqjiesuan"], 0);//申请结算的数量
            pid = AS.Common.Utils.Helper.GetInt(Request.QueryString["pid"],0);
            //当因结算数量等于已结算数量  该项目还是有其他未审核的结算信息 
          
            if ((yijie+sqjiesuan) - yjs > 0 && AS.Common.Utils.Helper.GetInt(Request.QueryString["stta"],0)==8)
            {
                SetError("已超过因结算数量 不能继续结算");
                Response.Redirect("JieSuan_ShenHe.aspx?Id=" + pid );
            }
            else
            {
                if (Id > 0)
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        parList = session.Partner_Detail.GetByID(Id);
                    }
                }
                else
                {
                    SetError("参数ID错误");
                }
                if (parList != null)
                {
                    partnerid = parList.partnerid;
                    money = parList.money;
                    Remark = parList.remark;
                    Team_id = parList.team_id;
                    num = parList.num;
                    pardetail.settlementremark = AS.Common.Utils.Helper.GetString(Request.QueryString["remark"], String.Empty);
                    pardetail.settlementstate = Request.QueryString["stta"] == "" ? sta : AS.Common.Utils.Helper.GetInt(Request.QueryString["stta"], 0);
                    pardetail.partnerid = partnerid;
                    pardetail.adminid = AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", AS.Common.Utils.FileUtils.GetKey()), 0);
                    pardetail.money = money;
                    pardetail.remark = Remark;
                    pardetail.team_id = Team_id;
                    pardetail.num = num;
                    pardetail.createtime = DateTime.Now;
                    pardetail.id = Id;
                    int count = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        count = session.Partner_Detail.Update(pardetail);
                    }
                    if (count > 0)
                    {
                        if (pardetail.settlementstate == 8)
                        {
                            SetSuccess("结算成功!");
                        }
                        else if (pardetail.settlementstate == 4)
                        {
                            SetSuccess("正在结算中");
                        }
                        else if (pardetail.settlementstate == 2)
                        {
                            SetSuccess("结算被拒绝");
                        }
                        else if (pardetail.settlementstate == 1)
                        {
                            SetSuccess("结算待审核中");
                        }
                    }
                    else
                    {
                        SetError("结算失败");
                    }
                    Response.Redirect("JieSuan_ShenHe.aspx?Id=" + partnerid + "");
                    Response.End();
                    return;
                }
            }
        }
    }
 </script>
 <script type="text/javascript">
     function JieSuan() {
         var teamid = $("#teamid").val();
         var parid = $("#pid").val();
         var shht = "1";
         var end_data = $("#end_date").val();
         var sta = $("#states").val();
         var remark = $("#remark").val();
         var sqjiesuan = $("#jiesuannum").val();
         $.ajax({
             type: "POST",
             url: "/manage/ajaxpage/ajax_partnerDetail.aspx",
             dataType: "JSON",
             data: { "pid": parid, "teamid": teamid, "shht": shht, "end_data": end_data },
             success: function (msg) {
                 var result = msg.split(',');
                 window.location = "/manage/manage_ajax_PartnerDetailReview.aspx?State=true&id=" + $("#id").val() + "&yinjie=" + result[1] + "&yijie=" + result[2] + "&pid=" + parid + "&stta=" + sta + "&remark=" + remark + "&sqjiesuan=" + sqjiesuan;
             }, error: function () {
                 alert("参数错误");
             }
         });
      }   
 </script>
 <form method="post" action="manage_ajax_PartnerDetailReview.aspx">
    <div id="order-pay-dialog" class="order-pay-dialog-c" style="width:380px;">
	<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>结算审核</h3>
	<div style="overflow-x:hidden;padding:10px;">
    <input type="hidden" name="id" id="id" value="<%=Id %>" />
    <input type="hidden" name="pid" id="pid" value="<%=pid %>" />
    <input type="hidden" name="end_date" id="end_date" value="<%=DateTime.Now.ToString("yyyy-MM-dd") %>" />
    <input type="hidden" name="teamid" id="teamid" value="<%=Team_id %>" />
    <input type="hidden" name="jiesuannum" id="jiesuannum" value="<%=jiesuannum %>" />
	<table  class="coupons-table-xq">
		<tr><td><b>状态：</b></td>
            <td> 
            <select name="states" id="states">
                <option value="1" <%if(sta==1){%> selected="selected" <% } %> >待审核</option>
                <option value="2" <%if(sta==2){%> selected="selected" <% } %> >拒绝</option>
                <option value="4" <%if(sta==4){%> selected="selected" <% } %> >正在结算</option>
                <option value="8" <%if(sta==8){%> selected="selected" <% } %> >已结算</option>
            </select>
            </td>
        </tr>
		<tr>
            <td><b>备注：</b></td>
            <td><textarea  id="remark" cols="40" rows="5" name="remark"></textarea></td>
        </tr>
		<tr>
            <td colspan="2" height="10">
           &nbsp; </td>
        </tr>
		<tr><td>&nbsp;</td><td>
             <input name="but" group="a" style="width:30px;" class="formbutton"  value="确定" onclick="JieSuan()" />
            </td></tr>
	</table>
    </div>
        </div>
          </form>
