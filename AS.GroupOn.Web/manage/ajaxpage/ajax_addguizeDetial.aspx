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
    public IPromotion_rules rulemodel = null;
    public int pid;
    public int typeid;
    protected string strGuize = "";
    protected string strEnable = "";
    protected string strDeduction = "";
    protected string strFeeding_amount = "";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        pid = Helper.GetInt(Request["id"], 0);
        typeid = Helper.GetInt(Request["typeid"], 0);

        ICategory icategory = null;
        CategoryFilter categoryfilter = new CategoryFilter();
        categoryfilter.Zone = "activity";
        categoryfilter.Id = typeid;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            rulemodel = session.Promotion_rules.GetByID(pid);
            icategory = session.Category.Get(categoryfilter);
        }
        if (icategory != null)
        {
            strGuize = icategory.content;
        }

        if (rulemodel.deduction == 0 && rulemodel.feeding_amount == 0)
        {
            if (rulemodel.free_shipping == 1)
            {
                strEnable = "是";
            }
            else
            {
                strEnable = "否";
            }
        }
        else if (rulemodel.deduction != 0)
        {
            strDeduction = rulemodel.deduction.ToString();
        }
        else if (rulemodel.feeding_amount != 0)
        {
            strFeeding_amount = rulemodel.feeding_amount.ToString();
        }
    }
       
</script>
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 680px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>促销规则详情<span
            id="bian" runat="server"></span><span id="xin" runat="server"></span><span id="mingcheng"
                runat="server"></span></h3>
    <div style="overflow-x: hidden; padding: 10px;">
        <p>
        </p>
        <input id="hid" type="hidden" />
        <% if (rulemodel != null)
           { %>
        <table width="96%" class="coupons-table-xq">
            <tr>
                <td width="120" nowrap="">
                    <b>促销规则选择：</b>
                </td>
                <td nowrap="">
                    <label id="lblGuiZe">
                        <%=strGuize %></label>
                </td>
            </tr>
            <tr>
                <td width="120" nowrap="">
                    <b>订单优惠条件：</b>
                </td>
                <td>
                    <label id="lbljine">
                        订单金额满<%=rulemodel.full_money%>元</label>
                </td>
            </tr>
            <tr>
                <td width="120" nowrap>
                    <b>活动规则开始时间：</b>
                </td>
                <td>
                    <label id="lblstartime" name="lblstartime">
                        <%=rulemodel.start_time.ToShortDateString() %></label>
                </td>
            </tr>
            <tr>
                <td width="120" nowrap>
                    <b>活动规则结束时间：</b>
                </td>
                <td>
                    <label id="lblendtime" name="lblendtime">
                        <%=rulemodel.end_time.ToShortDateString() %></label>
                </td>
            </tr>
            <tr>
                <td width="90">
                    <b>排序：</b>
                </td>
                <td nowrap="">
                    <label id="lblsort" name="lblsort">
                        <%=rulemodel.sort %></label>
                </td>
            </tr>
            <%if (rulemodel.deduction != 0 || rulemodel.feeding_amount != 0)
              {
              }
              else
              {%>
            <tr id="freight">
                <td width="90">
                    <b>是否免运费：</b>
                </td>
                <td nowrap="">
                    <label id="lblenable" name="lblenable">
                        <%=strEnable %>
                    </label>
                </td>
            </tr>
            <% 
                }%>
            <tr>
                <td width="90">
                    <b>是否启用：</b>
                </td>
                <td nowrap="">
                    <label id="lblisenable" name="lblisenable" runat="server">
                        <%if (rulemodel.enable == 1)
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
            <%if (rulemodel.deduction == 0)
              {
              }
              else
              {
            %>
            <tr id="reduces">
                <td width="90">
                    <b>减少的金额：</b>
                </td>
                <td nowrap="">
                    <label id="lbldeduction" name="lbldeduction">
                        <%=strDeduction %></label>
                </td>
            </tr>
            <%
                }
            %>
            <%if (rulemodel.feeding_amount == 0)
              {
              }
              else
              {
            %>
            <tr id="back">
                <td width="120">
                    <b>返回余额的金额：</b>
                </td>
                <td nowrap="">
                    <label id="lblfeeding_amount" name="lblfeeding_amount">
                        <%=strFeeding_amount %></label>
                </td>
            </tr>
            <%
                }%>
            <tr>
                <td width="90" nowrap>
                    <b>规则描述：</b>
                </td>
                <td>
                    <label name="lbldescription" id="lbldescription">
                        <%=rulemodel.rule_description %></label>
                </td>
            </tr>
        </table>
        <%}
           else
           { %>
        <table width="96%" class="coupons-table-xq">
            <tr>
                <td width="120" nowrap="">
                    <b>促销规则选择：</b>
                </td>
                <td nowrap="">
                    <label id="Label1">
                    </label>
                </td>
            </tr>
            <tr>
                <td width="120" nowrap="">
                    <b>订单优惠条件：</b>
                </td>
                <td>
                    <label id="Label2">
                        订单金额满 元</label>
                </td>
            </tr>
            <tr>
                <td width="120" nowrap>
                    <b>活动规则开始时间：</b>
                </td>
                <td>
                    <label id="Label3" name="lblstartime">
                    </label>
                </td>
            </tr>
            <tr>
                <td width="120" nowrap>
                    <b>活动规则结束时间：</b>
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
                <td width="90">
                    <b>是否免运费：</b>
                </td>
                <td nowrap="">
                    <label id="Label6" name="lblenable">
                    </label>
                </td>
            </tr>
            <tr>
                <td width="90">
                    <b>是否启用：</b>
                </td>
                <td nowrap="">
                    <label id="Label7" name="lblisenable" runat="server">
                    </label>
                </td>
            </tr>
            <tr id="Tr2">
                <td width="90">
                    <b>减少的金额：</b>
                </td>
                <td nowrap="">
                    <label id="Label8" name="lbldeduction">
                    </label>
                </td>
            </tr>
            <tr id="Tr3">
                <td width="120">
                    <b>返回余额的金额：</b>
                </td>
                <td nowrap="">
                    <label id="Label9" name="lblfeeding_amount">
                    </label>
                </td>
            </tr>
            <tr>
                <td width="90" nowrap>
                    <b>规则描述：</b>
                </td>
                <td>
                    <label name="lbldescription" id="Label10">
                    </label>
                </td>
            </tr>
        </table>
        <%
            } %>
    </div>
</div>
