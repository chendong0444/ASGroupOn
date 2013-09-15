<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

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
    protected IPagers<IRefunds> pager = null;
    protected System.Collections.Generic.IList<IRefunds> list_refund = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected string type = "";
    protected int id = 0;
    protected string type_name = "";
    protected string state = "";
    protected string tid = "";
    protected string pid = "";
    protected string oid = "";
    RefundsFilter filter = new RefundsFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Order_Refund_Processing_ListView))
        {
            SetError("你不具有查看处理退款订单列表的权限！");
            Response.Redirect("index_index.aspx");
            return;
        }
        if (!string.IsNullOrEmpty(Request.QueryString["state"]))
        {
            url = url + "&state=" + Request.QueryString["state"];
            state = Request.QueryString["state"];
            if (state == "1")
                filter.State = 1;
            else if (state == "4")
                filter.State = 4;
            else if (state == "8")
                filter.State = 8;
            else if (state == "16")
                filter.State = 16;
        }
        if (!string.IsNullOrEmpty(Request.QueryString["begintime"]))
        {
            url = url + "&begintime=" + Request.QueryString["begintime"];
            filter.FromCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["begintime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
        {
            url = url + "&endtime=" + Request.QueryString["endtime"];
            filter.ToCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["tid"]))
        {
            url = url + "&tid=" + Request.QueryString["tid"];
        }
        if (!string.IsNullOrEmpty(Request.QueryString["oid"]))
        {
            url = url + "&oid=" + Request.QueryString["oid"];
            filter.Order_Id = Helper.GetInt(Request.QueryString["oid"], 0);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["pid"]))
        {
            url = url + "&pid=" + Request.QueryString["pid"];
            filter.PartnerID = Helper.GetInt(Request.QueryString["pid"], 0);
        }
        InitData();
    }
    private void InitData()
    {
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        IRefunds refunds = Store.CreateRefunds();
        System.Collections.Generic.IList<IRefunds_detail> detail = null;
        IOrder order = Store.CreateOrder();
        IPartner partner = Store.CreatePartner();

        url = url + "&page={0}";
        url = "Dingdan_Chulituikuan.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(RefundsFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Refunds.GetPager(filter);
        }
        list_refund = pager.Objects;
        int i = 0;
        if (list_refund != null && list_refund.Count > 0)
        {
            foreach (AS.GroupOn.Domain.Spi.Refunds refund in list_refund)
            {
                order = refund.Order;
                partner = refund.Partner;
                detail = refund.Refunds_details;
                if (i % 2 != 0)
                    sb2.Append("<tr>");
                else
                    sb2.Append("<tr class='alt'>");
                i++;
                sb2.Append("<td>" + refund.Id + "</td>");
                sb2.Append("<td>");
                sb2.Append("<a class='deal-title' style='color: #FF0000;' href='javascript:tiaozhuan2(\"orders\",\"Dingdan_DangqiDingdan.aspx?select_type=4&type_name=" + refund.Order_ID + "\",\"3\")'>订单ID:" + refund.Order_ID + "</a><br />");
                if (order != null)
                {
                    sb2.Append("交易单号:" + order.Pay_id + "<br />");
                    sb2.Append("付款方式:" + WebUtils.GetPayCnName(WebUtils.GetPayType(order.Service)) + "<br />");
                    if (refund.State == 4 || refund.State == 7 || refund.State == 8)
                    {
                        if (order.Express == "N")
                        {
                            sb2.Append(" <font color=\"red\">该订单共" + CouponMethod.GetCouponCount(order.Id) + "张优惠卷</font><br /><font color=\"red\">已消费" + CouponMethod.GetUseCouponCount(order.Id) + "张，未消费" + CouponMethod.GetUnPayCouponCount(order.Id) + "张</font>");
                        }
                    }
                }
                else
                {
                    sb2.Append("交易单号:<br />付款方式:<br /");
                }
                sb2.Append("</td>");
                sb2.Append("<td id='teamtitle'><table>");
                if (detail != null && detail.Count > 0)
                {
                    sb2.Append("<tr><td>项目ID</td><td>退货数量</td></tr>");
                    for (int j = 0; j < detail.Count; j++)
                    {
                        sb2.Append("<tr><td>" + detail[j].teamid + "</td><td>" + detail[j].teamnum + "</td></tr>");
                    }
                }
                sb2.Append("</table></td>");
                if (partner != null)
                    sb2.Append("<td>商户ID" + partner.Id + "<br />商户名称:" + partner.Title + "</td>");
                else
                    sb2.Append("<td>暂无商户</td>");
                sb2.Append("<td>" + refund.Money + "</td>");
                sb2.Append("<td>" + refund.StateName + "</td>");
                sb2.Append("<td>" + refund.RefundMeansName + "</td>");
                sb2.Append("<td>" + refund.Reason + "</td>");
                sb2.Append("<td>");
                if ((refund.State | 7) == 7)
                {
                    sb2.Append("<a class='ajaxlink' ask='确认接受吗？' href='ajax_manage.aspx?action=refund8&rid=" + refund.Id + "'>接受</a> |");
                }
                else if (refund.State == 8)
                {
                    sb2.Append(" <a class='ajaxlink' ask='确认处理吗？' href='ajax_manage.aspx?action=refund16&rid=" + refund.Id + "'>处理</a>");
                }
                else if (refund.State == 16)
                {
                    sb2.Append("<a class='ajaxlink' href='ajax_manage.aspx?action=refund16&rid=" + refund.Id + "'>详情</a>");
                }
                if ((refund.State | 7) == 7)
                {
                    sb2.Append(" <a class='ajaxlink' ask='确认删除吗？' href='ajax_manage.aspx?action=refunddel&rid=" + refund.Id + "'>删除</a>");
                }
                sb2.Append("</td>");
                sb2.Append("</tr>");
            }
            if (pager.TotalRecords >= 30)
            {
                pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
            }
        }
        Literal2.Text = sb2.ToString();
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        处理退款订单</h2><form id="Form" runat="server" method="get">
                                <div class="search">
                                  订单状态：
                                    <select id="state" name="state" class="h-input" style="width:120px">
                                        <option value="0">请选择退款状态</option>
                                        <option value="1" <%if(Request.QueryString["state"] == "1"){%>selected="selected"
                                            <%}%>>等待商户确认</option>
                                        <option value="4" <%if(Request.QueryString["state"] == "4"){%>selected="selected"
                                            <%}%>>等待财务接受</option>
                                        <option value="8" <%if(Request.QueryString["state"] == "8"){%>selected="selected"
                                            <%}%>>财务正在处理</option>
                                        <option value="16" <%if(Request.QueryString["state"] == "16"){%>selected="selected"
                                            <%}%>>处理完毕</option>
                                    </select>&nbsp;&nbsp; &nbsp;项目ID:
                                    <input name="tid" id="tid" <%if(!string.IsNullOrEmpty(Request.QueryString["tid"])){ %>value="<%=Request.QueryString["tid"] %>"
                                        <%} %> class="h-input" style="width: 70px;" type="text">
                                    &nbsp;商户ID
                                    <input name="pid" id="pid" <%if(!string.IsNullOrEmpty(Request.QueryString["pid"])){ %>value="<%=Request.QueryString["pid"] %>"
                                        <%} %> class="h-input" style="width: 70px;" type="text">
                                    &nbsp;订单ID
                                    <input name="oid" id="oid" <%if(!string.IsNullOrEmpty(Request.QueryString["oid"])){ %>value="<%=Request.QueryString["oid"] %>"
                                        <%} %> class="h-input" style="width: 70px;" type="text">&nbsp;&nbsp; 退款时间
                                    <input name="begintime" id="begintime" datatype="date" <%if(!string.IsNullOrEmpty(Request.QueryString["begintime"])){ %>value="<%=Request.QueryString["begintime"] %>"
                                        <%} %> class="h-input" style="width: 70px;" type="text">--<input name="endtime" id="endtime"
                                            datatype="date" <%if(!string.IsNullOrEmpty(Request.QueryString["endtime"])){ %>value="<%=Request.QueryString["endtime"] %>"
                                            <%} %> class="h-input" style="width: 70px;" type="text">
                                    <input type="submit" name="search" value="筛选" class="formbutton" style="padding: 1px 6px;
                                        width: 60px;" />&nbsp;&nbsp;
                                </div>
                                </form>
                                </div>
                                
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr >
                                        <th width='5%'>ID</th>
                                        <th width='15%'>订单ID</th>
                                        <th width='10%'>退款项目</th>
                                        <th width='15%'>商户名称</th>
                                        <th width='10%'>退款金额</th>
                                        <th width='10%' >状态</th>
                                        <th width='10%' >退款方式</th>
                                        <th width='15%' >退款原因</th>
                                        <th width='10%' >操作</th>
                                        </tr>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="10">
                                                <%=pagerHtml%>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
<script type="text/javascript">
    function tiaozhuan2(name, url, num) {
        parent.frames[1].location.href = "frameleft.aspx?type=" + name;
        parent.frames[3].location.href = url;
        for (var i = 1; i <= 11; i++) {
            if (num == i) {
                $("#dh" + i).attr('class', 'dangqian');
            } else {
                $("#dh" + i).attr('class', '');
            }
        }
    }
</script>
<%LoadUserControl("_footer.ascx", null); %>
