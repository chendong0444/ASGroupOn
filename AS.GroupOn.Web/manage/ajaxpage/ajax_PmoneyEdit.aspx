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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected int pid = 0;//结算信息ID
    protected IList<ITeam> partner_teams = null;
    protected TeamFilter tfilter = new TeamFilter();
    protected IPartner_Detail partner_detail = Store.CreatePartner_Detail();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
       
        tfilter.Partner_id = Helper.GetInt(CookieUtils.GetCookieValue("partner",FileUtils.GetKey()), 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            partner_teams = session.Teams.GetList(tfilter);
        }
        if (Request["button"] == "确定")
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                partner_detail = session.Partner_Detail.GetByID(Helper.GetInt(Request.Form["hidpmonetid"], 0));
            }
            partner_detail.settlementremark = pmoneyremark.Value;
            partner_detail.settlementstate = 1;
            int ires = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ires = session.Partner_Detail.Update(partner_detail);
            }
            if (ires > 0)
            {
                SetSuccess("修改结算信息成功！");
            }
            else
            {
                SetError("修改结算信息失败！");
            }
            Response.Redirect(Request.UrlReferrer.AbsoluteUri);
            Response.End();
            return;
        }

        //显示页面
        if (Request["id"] != null)
        {
            pid = int.Parse(Request["id"].ToString());
            getContent(pid);
        }

    }
    private void getContent(int id)
    {

         using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                partner_detail = session.Partner_Detail.GetByID(Helper.GetInt(id, 0));
            }
        if (partner_detail.settlementstate == 2)
        {
            pmoneystate.InnerText = "拒绝";
        }
        pmoneyremark.Value = partner_detail.remark;

    }
</script>
<script type="text/javascript">
    var ok = false; //如果ok为true 则可以提交表单
    var yingjienumber = 0; //应结算份数
    var yijienumber = 0; //已结算份数
    var sellnumber = 0; //实际卖出数量
    var yijiemoney = 0; //已结算金额
    var costprice = 0; //成本
    var jiesuantype = "按实际卖出数量"; //结算方式 
    function getteam() {//得到项目 
       
        X.get("<%=PageValue.WebRoot %>manage/ajax_partner.aspx?action=getteam&tid=" + $("#teamid").val());
    }
    function checkNumber() {
        if (isNaN($("#number").val())) {
            alert("请输入正确的数字");
            $("#number").val("");
            ok = false;
            return false;
        }
        var num = parseInt($("#number").val());
        if (num <= 0 || num > yingjienumber - yijienumber) {
            alert("输入的数量不能大于剩余份数或为0(剩余份数=应结份数-已结份数)");
            $("#number").val("");
            ok = false;
            return false;
        }
        ok = true;
    }
</script>
<%LoadUserControl("../_header.ascx", null); %>
<form id="form1" runat="server">
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:600px;">
	<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>结算单修改</h3>
	<div id="Div1" style="overflow-x:hidden;padding:10px;" runat="server">
	<table width="96%" class="coupons-table-xq">
	
		<%--<tr><td class="style1"><b>结算时间：</b></td><td class="style1"><label id="pmoney_time" runat="server"></label></td></tr>--%>
		<%--<tr><td><b>管理员：</b></td><td><label id="pmoneyadminName" name="adminName" runat="server"></label></td></tr>--%>
		<tr>
            <td width="80"nowrap="" >
                   <b> 选择项目：</b>
                </td>
                <td nowrap="" > 
                <select name="teamid" id="teamid" onchange="getteam()" sytle="width:100px">
                    <option value="0">请选择项目</option>
                <%foreach (ITeam row in partner_teams)
                  { %>
                  <option value="<%=row.Id %>">ID:<%=row.Id %>名称<%=row.Product %></option>
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
                    <input id="number" type="text" name="number" class="h-input"  group="a"
                        require="true" datatype="money" onblur="checkNumber()" />
                </td>
            </tr>
        <tr><td><b>结算状态：</b></td><td><label id="pmoneystate" runat="server"></label></td></tr>
        <tr><td><b>备注：</b></td><td><textarea name="pmoneyremark" id="pmoneyremark" style="width:450px; height:300px;" class="f-textarea xheditor {upImgUrl:'/upload.aspx?immediate=1',urlType:'abs',height:400}" runat="server"></textarea>        
        </td></tr>
        <tr><td>&nbsp</td>
        <td>
        <input type="submit" value="确定" name ="button" id="button"   action="<%=PageValue.WebRoot%>manage/ajaxpage/ajax_PmoneyEdit.aspx" class="formbutton validator"/>
        <input type="hidden" id="hidpmonetid"name="hidpmonetid" value="<%=pid%>" />
        </td>
        </tr>
	</table>
	</div>
</div>
</form>
<%LoadUserControl("../_footer.ascx", null); %>


