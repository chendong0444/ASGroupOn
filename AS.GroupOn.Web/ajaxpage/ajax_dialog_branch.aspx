<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerBranchPage" %>
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
    protected NameValueCollection orderarr = new NameValueCollection();

    public string wuliu = "";
    public string ename = "";
    public string kuaino = "";
    protected OrderFilter orfilter = new OrderFilter();
    protected IOrder order = Store.CreateOrder();
    protected CategoryFilter catefilter = new CategoryFilter();
    protected IList<ICategory> ilistcate = null;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (CookieUtils.GetCookieValue("pbranch",key) != String.Empty)
        {
            int id = Helper.GetInt(Request["id"], 0);
            string update = Request["btnOK"];
            int branch_id = Helper.GetInt(CookieUtils.GetCookieValue("pbranch",key),0);
            int i = 0;
            orfilter.Wheresql1 = "[Order].Id=orderdetail.Order_id and [Order].Id=" + id + " and orderdetail.Teamid in(select Id from Team where Team.branch_id=" + branch_id + ") ";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.Orders.SelCountBranch(orfilter);
            }
            if (i>0)
            {
                if (!Page.IsPostBack)
                {
                    GetContent(id);
                    hid.Value = Request["id"].ToString();
                }
                
            }
            else
            {
                Response.Redirect(GetUrl("后台管理", "Login.aspx"));
            }
            if (update == "发货")
            {
                UpdateOrder(id);
            }
        }
    }

    #region 修改订单的快递单号
    public void UpdateOrder(int id)
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            order = session.Orders.GetByID(id);
        }
        string expressId = Request["express_id"];//快递方式id
        string expressNo = Request["express_no"];//快递单号
        if (Request["express_id"] == "0")
        {
            
            Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
            SetError("请选择快递");
            Response.End();
            //JsonUtils.GetJson("请选择快递!", "alert");
            
        }
        else
        {
            if (expressNo == null || expressNo == "")
            {
                expressNo = Request["express_no"];
            }
            order.Express_id = int.Parse(expressId);
            order.Express_no = expressNo;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int rusult = session.Orders.Update(order);
            }
            
            Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
            SetSuccess("修改快递信息成功");
            Response.End();
            //JsonUtils.GetJson("alert('修改快递信息成功!');window.location.reload();", "eval");
            //Response.End();
        }
    }
    #endregion

    #region 显示数据
    private void GetContent(int id)
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            order = session.Orders.GetByID(id);
        }
        orderarr = Helper.GetObjectProtery(order);

        catefilter.Zone = "express";
        catefilter.Id = order.Express_id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistcate = session.Category.GetList(catefilter);
        }
        if (ilistcate.Count > 0)
        {
            foreach (ICategory cate in ilistcate)
            {
                ename = cate.Ename;
            }
            kuaino = order.Express_no;


        }
        if (order.Express_no != "")
        {
            wuliu = "<img src='" + PageValue.WebRoot + "upfile/css/i/loading.gif'/>";
        }

        IUser userinfo = Store.CreateUser();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            userinfo = session.Users.GetByID(order.User_id);
        }
        username.InnerText = userinfo.Username;
        quantity.InnerText = order.Quantity.ToString();
        state.InnerText = WebUtils.GetPayText(order.State, order.Service);
        pay_id.InnerText = order.Pay_id;
        payTime.InnerText = order.Pay_time.ToString();
        Zipcode.InnerText = order.Zipcode;
        realName.InnerText = order.Realname;
        mobile.InnerText = order.Mobile;
        address.InnerText = order.Address;
        credit.InnerText = "余额付款：" + order.Credit;
        if (order.Service == "cashondelivery")
        {
            money.InnerText = order.cashondelivery.ToString();
        }
        else
        {
            money.InnerText = order.Money.ToString();
        }
        card.InnerText = order.Card.ToString();
        remark.InnerText = order.Remark;
        if (order.Service == "yeepay")
        {

            service.InnerText = "易宝支付 ";
        }
        else if (order.Service == "tenpay")
        {
            service.InnerText = "财付通支付 ";
        }
        else if (order.Service == "chinabank")
        {
            service.InnerText = "网银在线支付 ";
        }
        else if (order.Service == "credit")
        {
            service.InnerText = "余额付款支付 ";
            money.InnerText = order.Credit.ToString();
        }
        else if (order.Service == "alipay")
        {
            service.InnerText = "支付宝支付 ";
        }
        else if (order.Service == "chinamobilepay")
        {
            service.InnerText = "中国移动支付 ";
        }
        else if (order.Service == "cashondelivery")
        {
            service.InnerText = "货到付款 ";
        }
        if (order.Service == "refund")
        {
            service.InnerText = "其他方式退款:";
        }
        express_no.Value = order.Express_no;

        //订单详情
        IList<IOrderDetail> ilistordetail = null;
        IOrderDetail ordetail = Store.CreateOrderDetail();
        OrderDetailFilter ordefilter = new OrderDetailFilter();
        ordefilter.Order_ID = id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistordetail = session.OrderDetail.GetList(ordefilter);
        }
        if (ilistordetail.Count > 0)
        {
            int j = 0;
            foreach (IOrderDetail ordeinfo in ilistordetail)
            {
                title.InnerHtml += j + 1 + ":";
               
                ITeam team = Store.CreateTeam();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    team = session.Teams.GetByID(Helper.GetInt(ordeinfo.Teamid, 0));
                }


                title.InnerHtml += team.Title;
                if (ordeinfo.result.ToString() == "")
                {
                    title.InnerHtml += "</br>";
                }
                else
                {
                    title.InnerHtml += AS.GroupOn.Domain.Spi.Order.Getbulletin(ordeinfo.result.ToString(), 0);
                }

            }
        }
        CategoryFilter cafilter = new CategoryFilter();
        IList<ICategory> ilistca = null;
        cafilter.Zone = "express";
        cafilter.AddSortOrder(CategoryFilter.Sort_Order_DESC);
        cafilter.AddSortOrder(CategoryFilter.ID_ASC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistca = session.Category.GetList(cafilter);
        }
        if (order != null)
        {
            express.InnerHtml = "<select id='express_id' name='express_id'>";
            express.InnerHtml += "<option value='0'>请选择快递</option>";
            foreach (ICategory cate in ilistca)
            {
                if (order.Express_id.ToString() == cate.Id.ToString())
                {
                    express.InnerHtml += "<option value='" + cate.Id.ToString() + "' selected='selected'>" + cate.Name.ToString() + "</option>";
                }
                else
                {
                    express.InnerHtml += "<option value='" + cate.Id.ToString() + "'>" + cate.Name.ToString() + "</option>";
                }

            }
            express.InnerHtml += "</select>";
        }

    }
        #endregion
</script>
<%--<form id="Form1" runat="server">--%>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 510px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span></h3>
    <div style="overflow-x: hidden; padding: 10px;" id="dialog-order-id">
        <table width="96%" align="center" class="coupons-table-xq">
            <tr>
                <td width="100">
                    <b>用户名：</b>
                </td>
                <td>
                    <span id="username" runat="server"></span>
                </td>
            </tr>
            <tr>
                <td>
                    <b>项目名称：</b>
                </td>
                <td>
                    <span id="title" runat="server"></span>
                </td>
            </tr>
            <tr>
                <td class="style1">
                    <b>总共购买数量：</b>
                </td>
                <td class="style1">
                    <span id="quantity" runat="server"></span>
                </td>
            </tr>
            <tr>
                <td>
                    <b>付款状态：</b>
                </td>
                <td>
                    <span id="state" runat="server"></span>
                </td>
            </tr>
            <tr>
                <td>
                    <b>交易单号：</b>
                </td>
                <td>
                    <span id="pay_id" runat="server"></span>
                </td>
            </tr>
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
                    <b>付款时间：</b>
                </td>
                <td>
                    <span id="payTime" runat="server"></span>
                    <input id="hid" type="hidden" runat="server" />
                </td>
            </tr>
            <tr>
                <td>
                    <b>邮编：</b>
                </td>
                <td>
                    <span id="Zipcode" runat="server"></span>
                </td>
            </tr>
            <tr>
                <td width="80">
                    <b>买家留言：</b>
                </td>
                <td>
                    <span id="remark" runat="server"></span>
                </td>
            </tr>
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
                    <span id="realName" runat="server"></span>
                </td>
            </tr>
            <tr>
                <td>
                    <b>手机号码：</b>
                </td>
                <td>
                    <span id="mobile" runat="server"></span>
                </td>
            </tr>
            <tr>
                <td>
                    <b>收件地址：</b>
                </td>
                <td>
                    <span id="address" runat="server"></span>
                </td>
            </tr>
            <tr id="tr3" runat="server">
                <td colspan="2">
                    <hr />
                </td>
            </tr>
            <tr id="tr4" runat="server">
                <td>
                    <b>快递单号：</b>
                </td>
                <td>
                    <input type="text" id="express_no" name="express_no" value="" style="width: 150px;
                        margin-bottom: 0px;" maxlength="32" runat="server" group="a" />&nbsp;&nbsp;
                    <label id="express" runat="server">
                    </label>
                </td>
            </tr>
            <tr>
                <td>
                </td>
                <td class="style1">
                <input type="hidden" name="action" value="uporder" />
                    <input id="btnOK" name="btnOK" type="submit" runat="server" value="发货" class="validator formbutton"
                        group="a" />&nbsp&nbsp&nbsp&nbsp;
                    <%if (orderarr["Express_id"] != "0")
                      { %>
                    <input type="button" onclick="print()" class="validator formbutton" value="打印快递" />
                    <%} %>
                </td>
            </tr>
            <tr><td colspan="2"><hr/></td></tr>
    <tr>
    <td colspan="2" align="left"><p>物流信息：</p></td>
    </tr>
    <tr>
    <td style="color:Red" id="wu" colspan="2" align="left"><%=wuliu %></td>
    </tr>
        </table>
    </div>
</div>
<%--</form>--%>
<script type="text/javascript">
    function print()
    {
     X.get("<%=PageValue.WebRoot %>manage/ajax_print.aspx?action=print&id=<%=order.Id %>");

    }

    jQuery(document).ready(function () {

        <%if(kuaino!=""){ %>
    X.get("<%=PageValue.WebRoot %>manage/ajax_wuliu.aspx?id=<%=ename %>&&kuai=<%=kuaino %>");
    <% }%>

    });
</script>
