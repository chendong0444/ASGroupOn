<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    public ISales_promotion salmodel = null;
    public int pid;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        pid = Helper.GetInt(Request["id"], 0);

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            salmodel = session.Sales_promotion.GetByID(pid);
        }

    }
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 500px;">
  
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>促销活动详情<span
            id="bian" runat="server"></span><span id="xin" runat="server"></span><span id="mingcheng"
                runat="server"></span></h3>
    <div style="overflow-x: hidden; padding: 10px;">
        <p>
        </p>
        <input id="hid" type="hidden" />
        <% if (salmodel != null)
           { %>
        <table width="96%" class="coupons-table-xq">
            <tr>
                <td width="120" nowrap="">
                    <b>促销活动名称：</b>
                </td>
                <td nowrap="">
                    <label id="lblName">
                        <%=salmodel.name %></label>
                </td>
            </tr>
            <tr>
                <td width="90" nowrap="">
                    <b>是否发布：</b>
                </td>
                <td>
                    <label id="lblenable">
                        <%if (salmodel.enable == 1)
                          {
                        %>
                        是
                        <%
                            }
                          else
                          {
                        %>
                        否
                        <%
                            }%>
                    </label>
                </td>
            </tr>
            <tr>
                <td width="90" nowrap>
                    <b>开始时间：</b>
                </td>
                <td>
                    <label id="lblstartime" name="lblstartime">
                        <%=salmodel.start_time.ToShortDateString()%></label>
                </td>
            </tr>
            <tr>
                <td width="90" nowrap>
                    <b>结束时间：</b>
                </td>
                <td>
                    <label id="lblendtime" name="lblendtime">
                        <%=salmodel.end_time.ToShortDateString() %></label>
                </td>
            </tr>
            <tr>
                <td width="90">
                    <b>排序：</b>
                </td>
                <td nowrap="">
                    <label id="lblsort" name="lblsort">
                        <%=salmodel.sort %></label>
                </td>
            </tr>
            <tr id="freight">
                <td width="120">
                    <b>促销活动描述：</b>
                </td>
                <td nowrap="">
                    <label id="lblruledescription" name="lblruledescription">
                        <%=salmodel.description %></label>
                </td>
            </tr>
        </table>
        <%
            }
           else
           { %>
        <table width="96%" class="coupons-table-xq">
            <tr>
                <td width="120" nowrap="">
                    <b>促销活动名称：</b>
                </td>
                <td nowrap="">
                    <label id="Label1">
                    </label>
                </td>
            </tr>
            <tr>
                <td width="90" nowrap="">
                    <b>是否发布：</b>
                </td>
                <td>
                    <label id="Label2">
                    </label>
                </td>
            </tr>
            <tr>
                <td width="90" nowrap>
                    <b>开始时间：</b>
                </td>
                <td>
                    <label id="Label3" name="lblstartime">
                    </label>
                </td>
            </tr>
            <tr>
                <td width="90" nowrap>
                    <b>结束时间：</b>
                </td>
                <td>
                    <label id="Label4" name="lblendtime">
                    </label>
                </td>
            </tr>
            <tr>
                <td width="90">
                    <b>排序：</b>
                </td>
                <td nowrap="">
                    <label id="Label5" name="lblsort">
                    </label>
                </td>
            </tr>
            <tr id="Tr1">
                <td width="120">
                    <b>促销活动描述：</b>
                </td>
                <td nowrap="">
                    <label id="Label6" name="lblruledescription">
                    </label>
                </td>
            </tr>
        </table>
        <%
            } %>
    </div>
</div>
