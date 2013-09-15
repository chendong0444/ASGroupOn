<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>

<script runat="server">
    protected bool isOpera = false;
    protected bool isrefund = false;
    protected int isid = 0;
    protected int pid = 0;
    protected override void OnLoad(EventArgs e)
    {
        if (AS.Common.Utils.Helper.GetString(Request["opera"], String.Empty) == "1")
        {
            isOpera = true;
        }
        if (AS.Common.Utils.Helper.GetString(Request["id"], String.Empty) != null)
        {
            isid = AS.Common.Utils.Helper.GetInt(Request["id"], 0);
        }
        if (AS.Common.Utils.Helper.GetString(Request["id"], String.Empty) != null)
        {
            pid = AS.Common.Utils.Helper.GetInt(Request["id"], 0);
        }
        if (AS.Common.Utils.Helper.GetString(Request["refund"], String.Empty) == "1")
        {
            isrefund = true;
        }
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog" style="display: block; background-color: rgb(255, 255, 255); left: 524px;
        top: 81.6px; z-index: 9999;">
        <div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
            <h3>
                <%--<span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>--%>宗正大优惠券验证</h3>
            <p class="info" id="coupon-dialog-display-bizid">
                请您输入宗正大优惠券编号和密码<br>
                进行操作（查询免输密码）</p>
            <p class="notice" vname="bizcouponid">
                宗正大优惠券编号：<input id="coupon-dialog-input-bizid" type="text" name="id" class="f-input"
                    style="text-transform: uppercase;" maxlength="14" onkeyup="X.coupon.dialoginputkeyup(this);"></p>
            <p class="notice" id="bizcouponbranch" style="display: none;">
                分店名称：<select id="selectid" name="selectpart"></select>
            </p>
            <p class="notice" vname="bizcouponpwd" style="display: none;">
                宗正大优惠券密码：<input id="coupon-dialog-input-bizsecret" type="text" name="secret" style="text-transform: uppercase;"
                    class="f-input" maxlength="8" onkeyup="X.coupon.dialoginputkeyup(this);"></p>
            <p class="notice" vname="bizshanghupwd" style="display: none;">
                商家密码 ：<input id="coupon-dialog-input-shangjiasecret" type="text" name="shangjiasecret"
                    style="text-transform: uppercase;" class="f-input" maxlength="8" onkeyup="X.coupon.dialoginputkeyup(this);"></p>
            <p class="act" style="margin-left: auto;  width: 200px;"><%--margin-right: auto;--%>
                <input id="coupon-dialog-bizquery" class="formbutton" value="查询" name="query" type="submit"
                    onclick="X.coupon.bizdialogquery();return false;" onmouseup="return couponlength();"/>
                    
                <%--&nbsp;&nbsp;&nbsp;<input
                        id="coupon-dialog-bizconsume" name="consume" class="formbutton" value="消费（需密码）"
                        type="submit" onclick="X.coupon.bizdialogconsume();return false;" asks="每张宗正大优惠券只能消费一次，确定消费吗？"
                        style="display: none;"/>&nbsp;&nbsp;&nbsp;<input id="coupon_dialog_bizback" name="coupon_dialog_bizback" class="formbutton"
                    value="返回" type="button">--%>
            </p>
        </div>
    </div>
    <%--<div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="help">
                    <!--<div class="dashboard" id="dashboard"></div>-->
	
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        首页</h2>
                                </div>
                                <div class="sect">
                                    <div style="margin-left: 20px; margin-top: 20px;">
                                        <%
      
                                            Response.Write("服务器操作系统:" + Environment.OSVersion + "<br>");
                                            Response.Write("服务器CPU处理器数量：" + Environment.ProcessorCount + "<br>");
                                            Response.Write(".NET 运行版本:" + Environment.Version + "<br>");
                            
                                        %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>--%>
    </form>
    <%if (isOpera)
      { %>
    <script type="text/javascript">
        jQuery(document).ready(function () {
            X.get('/ajax/coupon.aspx?action=bizdialog&a=' + Math.random());
        });
    </script>
    <%} %>
    <%if (isrefund)
      { %>
    <script type="text/javascript">
        jQuery(document).ready(function () {
            X.get('/manage/ajax_partner.aspx?action=refundview&a=' + Math.random());
        });
    </script>
    <%} %>
    <%if (isid > 0)
      { %>
    <script type="text/javascript">
        jQuery(document).ready(function () {
            X.get('/biz/PartnerlInfo.aspx?id=<%=isid %>');
        });
    </script>
    <%} %>
    <%if (pid > 0)
      { %>
    <script type="text/javascript">
        jQuery(document).ready(function () {
            X.get('/biz/ChangePWD.aspx?id=<%=pid %>');
        });
    </script>
    <%} %>
</body>
<%LoadUserControl("_footer.ascx", null); %>
