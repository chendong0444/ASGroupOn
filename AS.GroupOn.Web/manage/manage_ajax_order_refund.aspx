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
    protected int orderid = 0;
    protected int pagenum = 1;
    protected IOrder ordermodel = null;
    public IList<IOrderDetail> detaillist = null;
    protected override void OnLoad(EventArgs e)
    {
        NeedLogin();
        NameValueCollection _system = new NameValueCollection();
        _system = PageValue.CurrentSystemConfig;
        orderid = Helper.GetInt(Request["orderview"], 0);
        optionfund.InnerHtml = "<select name='refund' id='option_refund'>";
        optionfund.InnerHtml += "<option value='0'>请选择退款方式</option>";
        optionfund.InnerHtml += "<option value='1'>退款到账户余额</option>";
        optionfund.InnerHtml += "<option value='2'>其他途径已退款</option>";
        using (IDataSession session=Store.OpenSession(false))
        {
            ordermodel = session.Orders.GetByID(orderid);
        }
        if (ordermodel != null)
        {
            if (ordermodel.OrderDetail!=null)
            {
               detaillist= ordermodel.OrderDetail;
            }
        }
    }
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>退款审核</h3>
    <div style="overflow-x: hidden; padding: 10px;">
        <table class="coupons-table-xq">
            <tr>
                <td>
                    <b>退款原因：</b>
                </td>
                <td>
                    <%=ordermodel.userremarke.ToString().Trim().Replace("\r\n", "<br>")%>
                </td>
            </tr>
            <tr>
                <td>
                    <b>退款状态：</b>
                </td>
                <td>
                     <select name="state" id="state" sytle="width:110px" onchange="stateType()">
                        <%if (ordermodel != null)
                          {%>
                        <option value="2" <% if (ordermodel.rviewstate == 2){ %>selected="selected"<%} %>>退款拒绝</option>
                        <option value="4"<% if (ordermodel.rviewstate == 4){ %>selected="selected"<%} %>>退款审核中</option>
                        <option value="8"<% if (ordermodel.rviewstate == 8){ %>selected="selected"<%} %>>退款通过</option>
                        <%} %>
                    </select>
                </td>
            </tr>
            <tr id="tr_1" style="display: none">
                <td>
                    <b>
                        <label id="lblname">
                            退款方式：</label></b>
                </td>
                <td>
                    <label id="optionfund" runat="server" sytle="width:110px">
                    </label>
                </td>
            </tr>
            <tr id="tr_2" style="display: none">
                <td colspan="2">
                    <hr />
                </td>
            </tr>
            <tr id="tr_3" style="display: none">
                <td>
                    <b>订单信息：</b>
                </td>
                <td>
                    <%      
                        if (detaillist.Count > 0)
                        {
                            for (int i = 0; i < detaillist.Count; i++)
                            {

                                Response.Write("订单ID:[" + ordermodel.Id + "],总款:[" + ordermodel.Origin + "]" + "</br>" + "项目ID:[" + detaillist[i].Teamid + "]数量:[" + detaillist[i].Num + "]");

                            }
                        }
                        else
                        {
                            Response.Write("订单ID:[" + ordermodel.Id + "],总款:[" + ordermodel.Origin + "]" + "</br>" + "项目ID:[" + ordermodel.Team_id + "],项目数量:[" + ordermodel.Quantity + "]" + "</br>");

                        }                                                                                                                                                                       
                    %>
                </td>
            </tr>
            <tr id="tr_4" style="display: none">
                <td>
                    <b>退款金额：</b>
                </td>
                <td>
                    <input width="50px" name="refundmoney" id="refundmoney" value="" />
                </td>
            </tr>
            <tr id="tr_5" style="display: none">
                <td>
                    <b>退款规则：</b>
                </td>
                <td>
                    <textarea name="refundteams" id="refundteams" heigth="70px"></textarea><font color="red"><br />
                        例如：7346-2
                        <br />
                        代表项目ID为7346退货2个.<br />
                        如果有多个项目用回车</font>
                </td>
            </tr>
            <tr id="tr_6" style="display: none">
                <td colspan="2">
                    <hr />
                </td>
            </tr>
            <tr>
                <td>
                    <b>审核备注：</b>
                </td>
                <td>
                    <textarea id="remark" cols="40" rows="5" name="remark"><%=ordermodel.rviewremarke %></textarea>
                </td>
            </tr>
            <tr>
                <td colspan="2" height="10">
                    &nbsp;
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td>
                    <input type="button" value="确 定" id="btnsubmit" onclick="orderrefund()" class="formbutton validator" /><%if (ordermodel.Express == "N")
                                                                                                              { %><font color="red">已消费了<%=CouponMethod.GetUseCouponCount(orderid) %>张优惠券</font><%} %>
                </td>
            </tr>
        </table>
    </div>
</div>

<script type="text/javascript">
    $(function () { window.x_init_hook_validator(); });
    $("#state option[value='<%=ordermodel.rviewstate %>']").attr("selected", "selected");
    function stateType() {
        var state = $("#state").val();
        if (state.toString() == "8") {
            $("#tr_1").show();
            $("#tr_2").show();
            $("#tr_3").show();
            $("#tr_4").show();
            $("#tr_5").show();
            $("#tr_6").show();
        }
        else {
            $("#tr_1").hide();
            $("#tr_2").hide();
            $("#tr_4").hide();
            $("#tr_3").hide();
            $("#tr_4").hide();
            $("#tr_5").hide();
            $("#tr_6").hide();
        }
    }
    function orderrefund(){
        var state = $("#state").val();
        if (state.toString() == "8") {
            if($("#option_refund").val()=="0")
            {
                alert("请选择退款方式");
                return false;
            }
            if($("#refundmoney").val()=="")
            {
                alert("请填写退款金额");
                return false;
            }
            if($("#refundteams").val()=="")
            {
                alert("请填写项目ID和数量");
                return false;
            }
            if($("#remark").val()=="")
            {
                alert("请填写审核备注");
                return false;
            }
        }
        else
        {
            if($("#remark").val()=="")
            {
                alert("请填写审核备注");
                return false;
            }
        }
        $("#btnsubmit").attr("disabled","disabled");//防止连续点击
        X.post("ajax_partner.aspx?action=refund1",
{"refundmoney":$("#refundmoney").val(),"type":2,
    "refundteams":$("#refundteams").val(), "remark":$("#remark").val(), "state":$("#state").val(),
    "reason":"<%=ordermodel.userremarke.Trim().ToString().Replace("\r\n", "<br>")%>","refundtype":$("#option_refund").val(),
    "orderid":<%=ordermodel.Id %>})
    }
</script>

