<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server" >
    protected int partner_id = 0;
    protected System.Collections.Generic.IList<AS.GroupOn.Domain.ITeam> teamList = null;
    protected TeamFilter filter = new TeamFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Partner_Jiesuan)) 
        {
            SetError("你没有商户结算权限");
            Response.Redirect("JieSuan_ShenHe.aspx");
            Response.End();
            return;
        }
        if (!IsPostBack)
        {
            partner_id = AS.Common.Utils.Helper.GetInt(Request["par_Id"], 0);
            if (partner_id > 0)
            {
                filter.Partner_id = partner_id;
                using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teamList = session.Teams.GetList(filter);
                }
            }
        }
    }
</script>
<script type="text/javascript">
    var ok=false; //如果ok为true 则可以提交表单
    var yingjienumber = 0; //应结算份数
    var yijienumber = 0; //已结算份数
    var sellnumber=0;//实际卖出数量
    var yijiemoney=0;//已结算金额
    var costprice=0;//成本
    var jiesuantype="按实际卖出数量";//结算方式 
    var partnerid=<%=partner_id%>;
    function getteam() {//得到项目 
        X.get(webroot+"manage/ajax_partner.aspx?action=getteam&pid="+partnerid+"&tid="+$("#teamid").val()+"&end_date="+$("#end_date").val());
    }



     var JsNumber = 0;//结算数量
     var chenben = 0; //成本
     var states = false; //如果ok为true 则可以提交表单
     function JieSuan() {

         var teamid = $("#teamid").val();
         var pid = $("#pid").val();
         var shht = "1";
         var showmsg = "";
         var end_data = $("#end_date").val();
         $.ajax({
             type: "POST",
             url: "/manage/ajaxpage/ajax_partnerDetail.aspx",
             dataType: "JSON",
             data: { "pid": pid, "teamid": teamid, "shht": shht, "end_data": end_data },
             success: function (msg) {
                 var result = msg.split(',');
                 if (teamid != 0) {
                     if(result[0] == "express") {
                         showmsg = "应结算数量" + result[1] + "份,已结算数量" + result[2] + "份,已结算金额" + result[3] + "元,实际卖出数量" + result[4] + "份,成本" + result[5] + "元;<br/>结算方式" + result[6] + "结算";
                     }else {
                         showmsg = "应结算数量" + result[1] + "份,已结算数量" + result[2] + "份,已结算金额" + result[3] + "元成本" + result[5] + "元;<br/>结算方式" + result[6] + "结算";
                     }
                 }else{
                     showmsg = "";
                 }
                 JsNumber = result[1] - result[2];
                 chenben = result[5];
                 $("#jiesuantxt").html(showmsg);
             }, error: function () {
                 alert("参数错误");
             }
         });
     }

     function checkNumber() {
         if (isNaN($("#number").val())) {
             alert("请输入正确的数字");
             ok = false;
             return false;
         }
         var num = parseInt($("#number").val());
         if (num <= 0 || num > yingjienumber-yijienumber) {
             alert("输入的数量不能大于应结算分数或为0");
             ok = false;
             return false;
         }
         $("#pmoneys").val((costprice * num).toFixed(2));
     }
   </script>
<form method="post" class="validator"  action="">
<input type="hidden" name="action" value="JieSuan" />
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 700px;">
    <h3>
       <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>商户结算
    </h3>
    <div style="overflow-x: hidden; padding: 10px;">
        <input type="hidden" value="<%=partner_id %>" name="pid" id="pid" />
        <table width="96%" class="coupons-table-xq">
        <tr>
            <td width="80" nowrap="" >
                <b> 截至日期：</b>
            </td>
                <td nowrap="" > 
                   <b><input type="text" style="border:0px;" name="end_date" id="end_date" readonly="readonly" value="<%=DateTime.Now.ToString("yyyy-MM-dd") %>" /> </b> 
                </td>
            </tr>
            <tr>
                <td width="80" nowrap="">
                   <b> 选择项目：</b>
                </td>
                <td nowrap="" > 
                <select name="teamid" id="teamid" onchange="getteam()" sytle="width:500px">
                    <option value="0">请选择项目</option>
                <%foreach (AS.GroupOn.Domain.ITeam team in teamList)
                  { %>
                  <option value="<%=team.Id%>">ID:<%=team.Id %>&nbsp;&nbsp;名称:<%=team.Title.ToString().Length > 31 ? team.Title.ToString().Substring(1,31) + "....." : team.Title%></option>
                <%} %>
                </select>
                <br />
                    <span id="jiesuantxt"></span>
                </td>
            </tr>
            <tr>
                <td width="80" nowrap>
                    <b>结算份数：</b>  
                </td>
                <td>
                    <input id="number" type="text" name="number" style="width:70px;"  group="a" require="true" value ="" onkeyup="checkNumber()" datatype="number" />
                    <span id="yanzheng" name="yanzheng" style="color:gray">*项目成本价</span>
                </td>
            </tr>
            <tr>
                <td width="80" nowrap>
                    <b>结算金额：</b>
                </td>
                <td>
                    <input id="pmoneys" type="text"  style="width:70px;" readonly="readonly" name="pmoneys"  value="" group="a" require="true" 
                        datatype="money" />
                </td>
            </tr>
            <tr>
                <td>
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td width="80" nowrap>
                    <b>备注：</b>
                </td>
                <td>
                    <textarea name="remark" id="remark" style="width: 500px; height: 300px;"  runat="server"></textarea>
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td>
                    <input id="commit" type="submit" name="commit" group="a" class="formbutton validator"value="结算" />
                </td>
            </tr>
        </table>
    </div>
</div>
</form>
<script type="text/javascript">
    $('textarea').xheditor({ tools: 'mfull', upImgUrl: webroot + 'upload.aspx?immediate=1', urlType: 'abs' });
</script>