<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>

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
    public string pid = "0";
    protected IList<ITeam> ilistpar_teams = null;
    protected TeamFilter teamfilter = new TeamFilter();
    protected IPartner_Detail pdmodel = Store.CreatePartner_Detail();
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        teamfilter.Partner_id =Helper.GetInt(CookieUtils.GetCookieValue("partner",key),0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistpar_teams = session.Teams.GetList(teamfilter);
        }
        if (Request["Id"] != null)
        {
            hid.Value = Request["Id"].ToString();
            pid = hid.Value;
        }
        if (Request["commit"] == "结算")
        {
            Insert_Pd();
        }

}
    #region 添加结算信息
    public void Insert_Pd()
    {


        pdmodel.createtime = DateTime.Now;
        pdmodel.settlementstate = 1;
        string teamid = hidId.Value;
        pdmodel.team_id = Helper.GetInt(teamid, 0);
        pdmodel.partnerid = Helper.GetInt(CookieUtils.GetCookieValue("partner",key), 0);//商户编号
        pdmodel.num = Helper.GetInt(Request.Form["number"], 0);
        //根据项目ID找到成本
      
        ITeam teamrow = Store.CreateTeam();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teamrow = session.Teams.GetByID(pdmodel.team_id);
        }
        if (teamrow != null)
        {
            pdmodel.money = Helper.GetDecimal(teamrow.cost_price, 0) * pdmodel.num;
        }

       
        pdmodel.remark = Request.Form["remark"];
        int i = 0;
        using (IDataSession sesssion = AS.GroupOn.App.Store.OpenSession(false))
        {
        i = sesssion.Partner_Detail.Insert(pdmodel);
        }
        if (i > 0)
        {
            SetSuccess("添加申请结算成功");
            Response.Redirect(WebRoot + "biz/Pmoney.aspx");
            Response.End();
        }
        else
        {
            SetError("添加申请结算失败");
            Response.Redirect(WebRoot + "biz/Pmoney.aspx");
            Response.End();
        }
    }
        #endregion
</script>
<%LoadUserControl("../_header.ascx", null); %>
<script type="text/javascript">
    var ok = false; //如果ok为true 则可以提交表单
    var yingjienumber = 0; //应结算份数
    var yijienumber = 0; //已结算份数
    var sellnumber = 0; //实际卖出数量
    var yijiemoney = 0; //已结算金额
    var costprice = 0; //成本
    var jiesuantype = "按实际卖出数量"; //结算方式 
    function getteam() {//得到项目
        $("#hidId").val($("#teamid").val());
        X.get("<%=PageValue.WebRoot %>manage/ajax_partner.aspx?action=getteam&tid=" + $("#teamid").val()+"&pid="+<%=CookieUtils.GetCookieValue("partner",key)%>);
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
<form id="form1" runat="server">
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
            <td width="80"nowrap="" >
                   <b> 选择项目：</b>
                </td>
                <td nowrap="" > 
                <select name="teamid" id="teamid" onchange="getteam()" sytle="width:100px">
                    <option value="0">请选择项目</option>
                <% foreach(ITeam row in ilistpar_teams)
                  { %>
                  <option value="<%=row.Id %>">ID:<%=row.Id %>名称<%=row.Product %></option>
                <%} %>
                </select>
                <input type="hidden" id="hidId" runat="server" />
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
                                         
                     <textarea id="remark" name="remark"  style="width:500px; height:300px;" class="f-textarea xheditor {upImgUrl:'/upload.aspx?immediate=1',urlType:'abs',height:400}"></textarea></td>
            </tr>
            <tr>
                <td>
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td>
                    <input type="submit" name="commit" group="a" class="formbutton validator" action="<%=PageValue.WebRoot%>manage/ajaxpage/ajax_shmoney.aspx?Id=<%=pid %>"
                        value="结算" />
                </td>
            </tr>
        </table>
    </div>
</div>
</form>
<%LoadUserControl("../_footer.ascx", null); %>

