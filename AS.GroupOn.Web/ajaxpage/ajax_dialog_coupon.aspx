<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>

<script runat="server">

        public string Couponname = "";
        public ICoupon couponmodel = Store.CreateCoupon();
        public IPartner partnermodel = Store.CreatePartner();
        public IBranch branchmodel = Store.CreateBranch();
        protected override void OnLoad(EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                initPage();

            }
        }
        private void initPage()
        {
            Couponname = ASSystem.couponname;
        }

    </script>

<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:380px;">

<script type="text/javascript">
    $(document).ready(function () {
            $("#coupon-dialog-consume").hide();
            $("[vname='couponpwd']").hide();
            $("[vname='shanghupwd']").hide();
            $("#couponbranch").hide();
            $("#selectid").show();

            jQuery('#coupon_dialog_back').click(function () {
                X.boxClose();
                X.get(webroot + 'ajax/coupon.aspx?action=dialog');
            });
        });
        function couponlength() {
            var num = $("#coupon-dialog-input-id").val();
            if (num == null || num == "") {
                alert("请您输入优惠券号！");
                return false;
            }
             else if(num.length < 5 || num.length > 14) {
                alert("您的优惠券编号应在5—14位之间");
                document.getElementById("coupon-dialog-input-id").value = ""
                return false;         
            }

        }
</script>

<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span><%=Couponname%>验证</h3>
<p class="info" id="coupon-dialog-display-id">请您输入<%=Couponname %>编号和密码<br/>进行操作（查询免输密码）</p>
<p class="notice" vname="couponid"><%=Couponname%>编号：<input id="coupon-dialog-input-id" type="text" name="id" class="f-input" style="text-transform:uppercase;" maxLength="14" onkeyup="X.coupon.dialoginputkeyup(this); " /></p>
<p class="notice" id="couponbranch" >
分店名称：<select id="selectid" name="selectpart"></select>
</p>
<p class="notice" vname="couponpwd"><%=Couponname%>密码：<input id="coupon-dialog-input-secret" type="text" name="secret" style="text-transform:uppercase;" class="f-input" maxLength="8" onkeyup="X.coupon.dialoginputkeyup(this);" /></p>
<p class="notice" vname="shanghupwd">商家密码：<input id="coupon-dialog-input-shangjiasecret" type="text" name="shangjiasecret" style="text-transform:uppercase;" class="f-input" maxLength="8" onkeyup="X.coupon.dialoginputkeyup(this);" onMouseUp="return couponlength();" /></p>
<p class="act" style="margin:auto;text-align:center; padding-bottom:5px;"><input id="coupon-dialog-query"  class="formbutton"  value="查询" name="query" type="submit"  onclick="X.coupon.dialogquery();return false;"/>&nbsp;&nbsp;&nbsp;
<input id="coupon-dialog-consume"  name="consume" class="formbutton" value="消费（需密码,仅供商家使用）" type="submit" onclick="X.coupon.dialogconsume();return false;" ask="每张<%=Couponname %>只能消费一次，确定消费吗？"/>&nbsp;&nbsp;&nbsp;
<input id="coupon_dialog_back"  name="coupon_dialog_back" class="formbutton" value="返回" type="button"  /></p>
</div>
