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
        partnerid = Helper.GetInt(CookieUtils.GetCookieValue("partner",key), 0);
        RefundsFilter filter = new RefundsFilter();
        filter.State = 1;
        filter.PartnerID = partnerid;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            refunds = session.Refunds.GetList(filter);
        }
      
    }

</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 700px; height: 500px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>商户确认退款</h3>
    <table width="700px">
        <tr>
            <th width="200">
                订单ID
            </th>
            <th width="140">
                退款项目
            </th>
            <th width="100">
                退款金额
            </th>
            <th width="100">
                退款原因
            </th>
            <th width="100">
                操作
            </th>
        </tr>
       
        <%foreach (IRefunds refund in refunds)
          {
        %>
        <tr>
            <td  width="200">
                    订单ID<%=refund.Order_ID %>
            </td>
            <td  width="140">
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
                            <a target="_blank" href="<%=getTeamPageUrl(refunddetaillist[j].teamid) %>">
                                <%=refunddetaillist[j].teamid %></a>
                        </td>
                        <td>
                            <%=refunddetaillist[j].teamnum %>
                        </td>
                    </tr>
                    <%} %>
                </table>
            </td>
            <td  width="100">
                <%=refund.Money %>
            </td>
            <td  width="100">
                <%=refund.Reason %>
            </td>
            <td  width="100">
                <input type="button" rd="<%=refund.Id  %>" value="同意" class="formbutton validator" style="padding: 1px 6px;"  />
            </td>
        </tr>
       
        <%} %>
    </table>
    <script type="text/javascript">
        $("input[rd]").click(function () {
            var url = "<%=PageValue.WebRoot%>manage/ajax_partner.aspx?action=conform&id=" + $(this).attr("rd");
            X.get(url);
        });
    </script>
</div>
