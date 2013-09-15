<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>
<script runat="server">
    public string Couponname = "";
    protected override void OnLoad(EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            initPage();

        }

    }
    private void initPage()
    {
        AS.GroupOn.Domain.ISystem system = null;
        using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
        }
        Couponname = system.couponname;
    }
</script>

<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:380px;">
<script type="text/javascript">
    $(document).ready(function () {


        $("#coupon-dialog-bizconsume").hide();
        $("[vname='bizcouponpwd']").hide();
        $("[vname='bizshanghupwd']").hide();
        $("#bizcouponbranch").hide();
        $("#selectid").show();

        jQuery('#coupon_dialog_bizback').click(function () {
            X.boxClose();
            X.get(webroot + 'ajax/coupon.aspx?action=bizdialog');
        });
    });

    function couponlength() {
        var num = $("#coupon-dialog-input-bizid").val();
        if (num == null || num == "") {
            alert("请您输入优惠券号！");
            return false;
        }
        else if (num.length < 5 || num.length > 14) {
            alert("您的优惠券编号应在5—14位之间");
            document.getElementById("coupon-dialog-input-bizid").value = ""
            return false;
        }

    }
</script>
<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span><%=Couponname%>验证</h3>
<p class="info" id="coupon-dialog-display-bizid">请您输入<%=Couponname%>编号和密码<br/>进行操作（查询免输密码）</p>
<p class="notice" vname="bizcouponid"><%=Couponname%>编号：<input id="coupon-dialog-input-bizid" type="text" name="id" class="f-input" style="text-transform:uppercase;" maxLength="14" onkeyup="X.coupon.dialoginputkeyup(this);" /></p>
<p class="notice" id="bizcouponbranch" >
分店名称：<select id="selectid" name="selectpart"></select>
</p>
<p class="notice" vname="bizcouponpwd"><%=Couponname%>密码：<input id="coupon-dialog-input-bizsecret" type="text" name="secret" style="text-transform:uppercase;" class="f-input" maxLength="8" onkeyup="X.coupon.dialoginputkeyup(this);" /></p>
<p class="notice" vname="bizshanghupwd">商家密码  ：<input id="coupon-dialog-input-shangjiasecret" type="text" name="shangjiasecret" style="text-transform:uppercase;" class="f-input" maxLength="8" onkeyup="X.coupon.dialoginputkeyup(this);" /></p>
<p class="act" style="margin-left: auto; margin-right: auto; width: 200px;" ><input id="coupon-dialog-bizquery"  class="formbutton"  value="查询" name="query" type="submit" onclick="X.coupon.bizdialogquery();return false;" onMouseUp="return couponlength();"/>&nbsp;&nbsp;&nbsp;<input id="coupon-dialog-bizconsume"  name="consume" class="formbutton" value="消费（需密码）" type="submit" onclick="X.coupon.bizdialogconsume();return false;" asks="每张<%=Couponname %>只能消费一次，确定消费吗？"/>
&nbsp;&nbsp;&nbsp;
<input id="coupon_dialog_bizback"  name="coupon_dialog_bizback" class="formbutton" value="返回" type="button"  />
</p>
</div>
