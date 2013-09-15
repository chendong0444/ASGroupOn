<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    
    protected System.Collections.Generic.IList<IRefunds> refunds = null;
    protected IRefunds refund = null;
    protected int partnerid = 0;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        partnerid = Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0);
        RefundsFilter filter = new RefundsFilter();
        filter.State = 1;
        filter.PartnerID = partnerid;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            refunds = session.Refunds.GetList(filter);
        }

    }

</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1" runat="server" method="get">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        退款审核</h2>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width="17%">
                                                订单ID
                                            </th>
                                            <th width="25%">
                                                退款项目
                                            </th>
                                            <th width="13%">
                                                退款金额
                                            </th>
                                            <th width="25%">
                                                退款原因
                                            </th>
                                            <th width="20%">
                                                操作
                                            </th>
                                        </tr>
                                        <%
                                            int i = 0;
                                            foreach (IRefunds refund in refunds)
                                            {
                                                if (i % 2 == 0)
                                                {%>
                                        <tr>
                                            <td width="200">
                                                订单ID:
                                                <%=refund.Order_ID%>
                                            </td>
                                            <td width="140">
                                                <table>
                                                    <%
                                                    System.Collections.Generic.IList<IRefunds_detail> refunddetaillist = null;
                                                    Refunds_detailFilter filter = new Refunds_detailFilter();
                                                    filter.refunds_id = refund.Id;
                                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                    {
                                                        refunddetaillist = session.Refunds_detail.GetList(filter);
                                                    }
                                                    %>
                                                    <tr>
                                                        <td>
                                                            项目ID
                                                        </td>
                                                        <td>
                                                            退货数量
                                                        </td>
                                                    </tr>
                                                    <%for (int j = 0; j < refunddetaillist.Count; j++)
                                                      { %>
                                                    <tr>
                                                        <td>
                                                            <a target="_blank" href="<%=PageValue.WebRoot%>team.aspx?id=<%=refunddetaillist[j].teamid %>">
                                                                <%=refunddetaillist[j].teamid%></a>
                                                        </td>
                                                        <td>
                                                            <%=refunddetaillist[j].teamnum%>
                                                        </td>
                                                    </tr>
                                                    <%} %>
                                                </table>
                                            </td>
                                            <td width="100">
                                                <%=refund.Money%>
                                            </td>
                                            <td width="100">
                                                <%=refund.Reason%>
                                            </td>
                                            <td width="100">
                                                <input type="button" rd="<%=refund.Id  %>" value="同意" class="formbutton validator"
                                                    style="padding: 1px 6px;" />
                                            </td>
                                        </tr>
                                        <% }
                                                else
                                                {
                                        %>
                                        <tr class="alt">
                                            <td width="200">
                                                订单ID:
                                                <%=refund.Order_ID%>
                                            </td>
                                            <td width="140">
                                                <table>
                                                    <%
                                                    System.Collections.Generic.IList<IRefunds_detail> refunddetaillist = null;
                                                    Refunds_detailFilter filter = new Refunds_detailFilter();
                                                    filter.refunds_id = refund.Id;
                                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                    {
                                                        refunddetaillist = session.Refunds_detail.GetList(filter);
                                                    }
                                                    %>
                                                    <tr>
                                                        <td>
                                                            项目ID
                                                        </td>
                                                        <td>
                                                            退货数量
                                                        </td>
                                                    </tr>
                                                    <%for (int j = 0; j < refunddetaillist.Count; j++)
                                                      { %>
                                                    <tr>
                                                        <td>
                                                            <a target="_blank" href="<%=PageValue.WebRoot%>team.aspx?id=<%=refunddetaillist[j].teamid %>">
                                                                <%=refunddetaillist[j].teamid%></a>
                                                        </td>
                                                        <td>
                                                            <%=refunddetaillist[j].teamnum%>
                                                        </td>
                                                    </tr>
                                                    <%} %>
                                                </table>
                                            </td>
                                            <td width="100">
                                                <%=refund.Money%>
                                            </td>
                                            <td width="100">
                                                <%=refund.Reason%>
                                            </td>
                                            <td width="100">
                                                <input type="button" rd="<%=refund.Id  %>" value="同意" class="formbutton validator"
                                                    style="padding: 1px 6px;" />
                                            </td>
                                        </tr>
                                        <%}
                                                i++;
                                            }%>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
<script type="text/javascript">
    $("input[rd]").click(function () {
        var url = "<%=PageValue.WebRoot%>manage/ajax_partner.aspx?action=conform&id=" + $(this).attr("rd");
        X.get(url);
    });
</script>
