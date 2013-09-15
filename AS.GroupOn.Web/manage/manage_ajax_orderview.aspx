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
    protected IOrder order = Store.CreateOrder();
    protected IUser user = Store.CreateUser();
    protected IPartner partner = Store.CreatePartner();
    protected IList<ITeam> teamlist = null;
    protected string team_titel = String.Empty;
    protected string wuliu = String.Empty;
    protected int orderid = 0;
    protected string kuaino = "";
    public string ename = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        orderid = Helper.GetInt(Request["orderview"], 0);
        if (Request["type"] == "update")//更新快递单号
        {
            updateorder();
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            order = session.Orders.GetByID(orderid);
        }
        if (order != null)
        {
            if (order.User != null)
                user = order.User;
            if (order.Partner != null)
                partner = order.Partner;
            if (order.Team_id == 0)
            {
                teamlist = order.Teams;
                foreach (IOrderDetail detail in order.OrderDetail)
                {
                    string headhtml = "<br>项目ID";
                    if (detail.result != "") 
                    {
                        headhtml = "项目ID";
                    }
                    team_titel = team_titel + headhtml + detail.Teamid + "  数量:" + Helper.GetInt(detail.Num, 0) + "  " + detail.Team.Title + StringUtils.SubString(AS.Common.Utils.WebUtils.Getbulletin(detail.result), 0, "<br>");
                }
            }
            else
            {

                if (order.Team != null)
                {
                    team_titel = "项目ID:" + order.Team.Id+"  " + order.Team.Title;
                }
                else if (order.Teams != null && order.Teams.Count>0)
                {
                    foreach (var detail in order.OrderDetail)
                    {
                        team_titel = team_titel + "项目ID:" + detail.Teamid +"  "+ detail.Team.Title + StringUtils.SubString(AS.Common.Utils.WebUtils.Getbulletin(detail.result), 0, "<br>");
                    } 
                }
                else
                {
                    team_titel = "项目已不存在!"; 
                }
            }
            if (order.Express == "Y")
            {
                IList<ICategory> list_cate = null;
                CategoryFilter filter = new CategoryFilter();
                filter.Zone = "express";
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    list_cate = session.Category.GetList(filter);
                }
                express.InnerHtml = "<select id='express_id' name='express_id'>";
                express.InnerHtml += "<option value='0'>请选择快递</option>";
                for (int i = 0; i < list_cate.Count; i++)
                {
                    if (order.Express_id.ToString() == list_cate[i].Id.ToString())
                    {
                        express.InnerHtml += "<option value='" + list_cate[i].Id.ToString() + "' selected='selected'>" + list_cate[i].Name + "</option>";
                        ename = list_cate[i].Ename.ToString();
                    }
                    else
                    {
                        express.InnerHtml += "<option value='" + list_cate[i].Id.ToString() + "'>" + list_cate[i].Name + "</option>";
                    }
                }
                express.InnerHtml += "</select>";
                express_no.Value = order.Express_no;
            }
            if (order.Express_no != null && order.Express_no.ToString() != "")
            {
                wuliu = "<img src='" + PageValue.WebRoot + "upfile/css/i/loading.gif'/>";
                kuaino = order.Express_no;
            }
            if (order.State == "refund")
            {
                IRefunds refundmodel = null;
                RefundsFilter filter = new RefundsFilter();
                if (order.Parent_orderid != 0)
                {
                    filter.Order_Id = order.Parent_orderid;
                }
                else
                {
                    filter.Order_Id = order.Id;
                }
                using (IDataSession session = Store.OpenSession(false))
                {
                    refundmodel = session.Refunds.Get(filter);
                }
                if (refundmodel != null)
                {
                    if (refundmodel.RefundMeans == 1)
                    {
                        credit.InnerText = "退到账户余额:" + refundmodel.Money;
                        service.InnerText = "人工退款:0.00";
                    }
                    else
                    {
                        if (order.Parent_orderid != 0)
                        {
                            credit.InnerText = "退到账户余额:0.00";
                            service.InnerText = "人工退款:" + order.Credit;
                        }
                        else
                        {
                            credit.InnerText = "退到账户余额:" + order.Credit;
                            service.InnerText = "人工退款:" + order.Money;
                        }
                    }
                }
            }
            else
            {
                credit.InnerText = "余额付款:" + order.Credit.ToString();
                if (order.Service == "cashondelivery")
                {
                    money.InnerText = order.cashondelivery.ToString();
                }
                else
                {
                    money.InnerText = order.Money.ToString();
                }
                if (order.Service == "yeepay")
                    service.InnerText = "易宝支付 ";
                else if (order.Service == "tenpay")
                    service.InnerText = "财付通支付 ";
                else if (order.Service == "chinabank")
                    service.InnerText = "网银在线支付 ";
                else if (order.Service == "credit")
                    service.InnerText = "在线支付 ";
                else if (order.Service == "alipay")
                    service.InnerText = "支付宝支付 ";
                else if (order.Service == "chinamobilepay")
                    service.InnerText = "中国移动支付 ";
                else if (order.Service == "cashondelivery")
                    service.InnerText = "货到付款";
                else if (order.Service == "cash")
                    service.InnerText = "线下支付";
                else if (order.Service == "alipaywap")
                    service.InnerText = "支付宝手机支付";
                else if (order.Service == "tenpaywap")
                    service.InnerText = "财付通手机支付";
                money.InnerText = order.Money.ToString();
            }
            card.InnerText = order.Card.ToString();
        }
        optionfund.InnerHtml = "<select name='refund' id='option_refund' onchange='stateType()'>";
        optionfund.InnerHtml += "<option value='0'>请选择退款方式</option>";
        optionfund.InnerHtml += "<option value='1'>退款到账户余额</option>";
        optionfund.InnerHtml += "<option value='2'>其他途径已退款</option>";
        optionfund.InnerHtml += "</select>";

    }
    public void updateorder()
    {
        string expressid = Request["express_id"];//快递编号
        string express_no = Request["express_no"];//快递单号
        string orderid = Request["id"];
        if (Request["express_id"] == "0")
        {
            Response.Write(JsonUtils.GetJson("请选择快递!", "alert"));
        }
        else
        {
            if (express_no == null || express_no == "")
            {
                express_no = Request["express_no"];
            }
            IOrder orders = Store.CreateOrder();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                orders = session.Orders.GetByID(int.Parse(orderid));
            }
            orders.Express_id = Convert.ToInt32(expressid);
            orders.Express_no = express_no;
            orders.Express = "Y";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                session.Orders.Update(orders);
            }
            Response.Write(JsonUtils.GetJson("alert('修改快递信息成功!');window.location.reload();", "eval"));
            Response.End();
        }
    }
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 510px;">
    <h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span></h3>
    <div style="overflow-x:hidden; padding: 10px;" id="dialog-order-id">
        <table width="96%" align="center" class="coupons-table-xq">
            <tr>
                <td width="100">
                    <b>用户名：</b>
                </td>
                <td>
                    <%=user.Username %>
                </td>
            </tr>
            <tr>
                <td>
                    <b>Email：</b>
                </td>
                <td>
                    <%=user.Email %>
                </td>
            </tr>
            <tr>
                <td>
                    <b>项目名称：</b>
                </td>
                <td>
                    <%=team_titel%>
                </td>
            </tr>
            <%if (partner != null && partner.Title!=null)
              {%>
            <tr>
                <td>
                    <b>商户名称：</b>
                </td>
                <td>
                    <%=partner.Title %>
                </td>
            </tr>
            <%} %>
            <tr>
                <td class="style1">
                    <b>总共购买数量：</b>
                </td>
                <td class="style1">
                    <%=order.Quantity %>
                </td>
            </tr>
            <tr>
                <td>
                    <b>付款状态：</b>
                </td>
                <td>
                    <%=WebUtils.GetPayText(order.State, order.Service) %>
                </td>
            </tr>
            <%if (order.Pay_id != null && order.Pay_id.ToString() != "")
              {%>
            <tr>
                <td>
                    <b>交易单号：</b>
                </td>
                <td>
                    <%=order.Pay_id %>
                </td>
            </tr>
            <%} %>
            <tr>
                <td>
                    <b>付款明细：</b>
                </td>
                <td>
                    <span id="credit" runat="server"></span>元&nbsp;<span id="service" runat="server"></span><span
                        id="money" runat="server"></span> 元&nbsp;代金券：<span id="card" runat="server"></span>
                    元
                </td>
            </tr>
            <tr>
                <td>
                    <b>下单时间：</b>
                </td>
                <td>
                    <%=order.Create_time.ToString("yyyy-MM-dd HH:mm:ss")%>
                </td>
            </tr>
            <%if (order.State == "pay" || order.State == "scorepay")
              { %>
            <tr>
                <td>
                    <b>付款时间：</b>
                </td>
                <td>
                    <%=order.Pay_time.Value.ToString("yyyy-MM-dd HH:mm:ss")%>
                </td>
            </tr>
            <% }%>
            <%if ((order.State == "refund" || order.State == "scorrefund") && order.refundTime != null)
              { %>
            <tr>
                <td>
                    <b>退款时间：</b>
                </td>
                <td>
                    <%=order.refundTime.Value.ToString("yyyy-MM-dd HH:mm:ss")%>
                </td>
            </tr>
            <% }%>
            <%if (user.Mobile != String.Empty)
              { %>
            <tr>
                <td>
                    <b>联系手机：</b>
                </td>
                <td>
                    <%=user.Mobile %>
                </td>
            </tr>
            <%} %>
             <%if (order.Zipcode != null && order.Zipcode.Length>0)
              { %>
            <tr>
                <td>
                    <b>邮编：</b>
                </td>
                <td>
                    <%=order.Zipcode %>
                </td>
            </tr>
            <%} %>
            <%if (user.Qq != String.Empty)
              { %>
            <tr>
                <td>
                    <b>QQ：</b>
                </td>
                <td>
                    <%=user.Qq %>
                </td>
            </tr>
            <%} %>
            <%if (user.msn != String.Empty)
              { %>
            <tr>
                <td>
                    <b>MSN：</b>
                </td>
                <td>
                    <%=user.msn %>
                </td>
            </tr>
            <%} %>
            <%if (order.Remark != String.Empty)
              { %>
            <tr>
                <td width="80">
                    <b>买家留言：</b>
                </td>
                <td>
                    <%=order.Remark %>
                </td>
            </tr>
            <%} %>
            <%if (order.State == "refunding")
              {%>
            <%if (!string.IsNullOrEmpty(order.rviewremarke))
              { %>
            <tr>
                <td>
                    <b>审核备注：</b>
                </td>
                <td>
                    <%=order.rviewremarke %>
                </td>
            </tr>
            <%} %>
            <%if (!string.IsNullOrEmpty(order.userremarke))
              { %>
            <tr>
                <td>
                    <b>用户申请备注：</b>
                </td>
                <td>
                    <%=order.userremarke %>
                </td>
            </tr>
            <%} %>
            <%if (order.refundTime.ToString() != String.Empty)
              { %>
            <tr>
                <td>
                    <b>退款审核时间：</b>
                </td>
                <td>
                    <%=order.refundTime %>
                </td>
            </tr>
            <%} %>
            <% } %>
            <%if (order.Express == "Y")
              {%>
            <tr>
                <td colspan="2">
                    <hr />
                </td>
            </tr>
            <tr>
                <td width="80" class="style1">
                    <b>收件人：</b>
                </td>
                <td class="style1">
                    <%=order.Realname %>
                </td>
            </tr>
            <tr>
                <td>
                    <b>手机号码：</b>
                </td>
                <td>
                    <%=order.Mobile %>
                </td>
            </tr>
            <tr>
                <td>
                    <b>收件地址：</b>
                </td>
                <td>
                    <%=order.Address %>
                </td>
            </tr>
            <%if (order.State == "pay" || order.State == "scorepay" || order.State == "nocod")
              { %>
            <tr id="tr3">
                <td colspan="2">
                    <hr />
                </td>
            </tr>
            <tr id="tr4" runat="server">
                <td>
                    <b>快递信息：</b>
                </td>
                <td>
                    <label id="express" runat="server"  >
                    </label>
                    <input type="text" id="express_no" name="express_no" value="" style="width: 150px;
                        margin-bottom: 0px;" maxlength="32" runat="server" group="a" />
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td align="left">
                    <input type="submit" onclick="submit()" value="发货" class="validator" group="a" />&nbsp&nbsp&nbsp&nbsp;
                    <%if (order.Express_id != 0&&order.Express_no!=null)
                      { %>
                    <input id="button" type="button" value="打印快递" onclick="print()" />
                    <%} %>
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <hr />
                </td>
            </tr>
            <%if (kuaino != "")
              {%>
               <tr>
                <td colspan="2" align="left">
                    <p>
                        物流跟踪：以下跟踪信息由<a href="http://www.kuaidi100.com/?refer=hishop" target="_blank">快递100</a>提供,如有疑问请到物流公司官网查询</p>
                </td>
            </tr>
              <%} %>
            <tr>
                <td style="color: Red" id="wu" colspan="2" align="left">
                    <%=wuliu%>
                </td>
            </tr>
            <%} %>
            <%}%>
            <%if (order.Express == "Y" || order.Express == "N")
              { %>
            <%if (order.State == "pay" || order.State == "scorepay")
              { %>
            <tr>
                <td>
                    <b>退款处理：</b>
                </td>
                <td>
                    <label id="optionfund" runat="server">
                    </label>
                </td>
            </tr>
            <tr id="tr_5" style="display: none">
                <td>
                    <b>订单信息：</b>
                </td>
                <td>
                    <% if (order.OrderDetail.Count > 0)
                       {
                           for (int i = 0; i < order.OrderDetail.Count; i++)
                           {
                               IOrderDetail t = order.OrderDetail[i];
                               Response.Write("项目ID:[" + t.Teamid + "]数量:[" + t.Num + "]" + "</br>");
                           }
                       }
                       else
                       {
                           Response.Write("项目ID:[" + order.teamid + "],项目数量:[" + order.Quantity + "]" + "</br>");
                       }                             
                    %>
                </td>
            </tr>
            <tr id="tr_1" style="display: none">
                <td>
                    <b>退款金额：</b>
                </td>
                <td>
                    <input width="50px" name="refundmoney" id="refundmoney" value="" />
                </td>
            </tr>
            <tr id="tr_2" style="display: none">
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
            <tr id="tr_3" style="display: none">
                <td>
                    <b>退款原因:</b>
                </td>
                <td>
                    <textarea name="refundremark" id="refundremark" heigth="70px"></textarea>
                </td>
            </tr>
            <tr id="tr_4" style="display: none">
                <td>
                    <b>退款确认:</b>
                </td>
                <td>
                    <input type="button" value="确定退款" onclick="orderrefund()" /><%if (order.Express == "N")
                                                                                  { %><font color="red">已消费了<%=CouponMethod.GetUseCouponCount(order.Id) %>张优惠券</font><%} %>
                </td>
            </tr>
            <%}
              }
              else
              {%>
            <%if (order.Express == "D")
              { %>
            <tr>
                <td>
                    <b>抽奖号码：</b>
                </td>
                <td>
                    <%=DrawMethod.GetDrawCode(order.Id)%>
                </td>
            </tr>
            <% }
              }%>
            <tr>
                <td colspan="2">
                    <hr />
                </td>
            </tr>
            <tr>
                <td colspan="2" align="center">
                    <div id="adminremark">
                    </div>
                    <textarea id="admin_remark" cols="75" rows="5"></textarea>
                    <br />
                    <input name="admin_remark_button" onclick="admin_remark_submit()" type="button" value="提交备注" />
                </td>
            </tr>
        </table>
    </div>
</div>
<script type="text/javascript">
    jQuery(document).ready(function(){
      <%if(kuaino!=""){ %>
    X.get("ajax_wuliu.aspx?id=<%=ename %>&&kuai=<%=kuaino %>&&type=1");
        <% }%>
        getadminremark();
    });
    function stateType() {
        var state = $("#option_refund").val();
        if (state.toString() == "1" || state.toString() == "2") {
            $("#tr_1").show();
            $("#tr_2").show();
            $("#tr_3").show();
            $("#tr_4").show();
            $("#tr_5").show();
            $("#tr_6").show();
            $("#tr_7").show();
        }
        else {
            $("#tr_1").hide();
            $("#tr_2").hide();
            $("#tr_3").hide();
            $("#tr_4").hide();
            $("#tr_5").hide();
            $("#tr_6").hide();
            $("#tr_7").show();
        }
    }
      function print()
  {
    X.get("ajax_print.aspx?action=print&id=<%=order.Id %>");
}
function submit() {
    var id = $("#express_id").val();
    var no = $("#express_no").val();
    var orderid=<%=orderid %>;
    if (id=="0") {
    alert("请选择快递");
      return false;
}
if (no=="") {
    alert("请输入快递单号");
      return false;
}
    X.get("manage_ajax_orderview.aspx?type=update&express_id=" + id + "&express_no=" + no+"&id="+orderid);
}
    function getadminremark()
    {
  
        X.get("ajax_manage.aspx?action=adminremark&id=<%=orderid %>");

  }
    function admin_remark_submit()
    {
        if($("#admin_remark").val()=="")
        {
            alert("不能提交空信息");
            return ;
        }
        else
        {
            if(window.confirm("确认提交备注信息吗？"))
            {
                $.post("ajax_manage.aspx?action=submitadminremark&id=<%=orderid %>",{"content":$("#admin_remark").val()},function(msg){
                    if (msg=="OK") {
                        alert("提交成功");
                    }
                    else{alert(msg);}
                    getadminremark();
                    $("#admin_remark").val("");
                });
            };
        }
    }
    function orderrefund()
    {
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
        if($("#refundremark").val()=="")
        {
            alert("请选择退款原因");
            return false;
        }
        if($("#option_refund").val()=="0")
        {
            alert("请选择退款方式");
            return false;
        }

        X.post(
 "ajax_partner.aspx?action=refund1",
 {"refundmoney":$("#refundmoney").val(),
     "refundteams":$("#refundteams").val(),"type":1,
     "reason":$("#refundremark").val(),"refundtype":$("#option_refund").val(),
     "orderid":<%=orderid %>});
}
</script>
