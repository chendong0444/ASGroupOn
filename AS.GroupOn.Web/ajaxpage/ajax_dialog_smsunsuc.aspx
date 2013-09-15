<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script runat="server">

    public string strMobile = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        strMobile = Request["mobile"];
        if (Request["action"] != null && Request["action"].ToString() != "")
        {
            //取消订阅
            if (Request["mobile"] != null && Request["mobile"].ToString() != "")
            {
                SmssubscribeFilter sf=new SmssubscribeFilter();
                sf.Mobile=strMobile;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    seion.Smssubscribe.deleteBymobile(sf);
                }
            }
        }
    }
    
    </script>


<div id="order-pay-dialog" class="order-pay-dialog-c" style="width:380px;">
<h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>取消短信订阅</h3>
      <input type="hidden" value="<%=strMobile %>" id="go_to_subscribe"/>
	<p class="info" id="smssub-dialog-display-id">该手机已经绑定过，如果现在绑定将清除以前的订阅？继续么？</p>
    <p class="act" style="margin:auto;text-align:center; padding-bottom:5px;">
    <input id="submit"  class="formbutton"  value="确定" name="submit" type="submit" />&nbsp;&nbsp;&nbsp;
    <input id="coupon_dialog_back"  name="coupon_dialog_back" class="formbutton" value="取消" type="button" onclick="return X.boxClose();" /></p>
</div>
<script type="text/javascript">

    $(document).ready(function () {

        $("#submit").click(function () {
            var mobile = $('#go_to_subscribe').val();
            X.get(webroot + 'AjaxPage/ajax_dialog_smsunsub.aspx?action=qx&mobile=' + mobile);
            X.boxClose();
            alert("取消订阅成功！");
        });
    });


</script> 