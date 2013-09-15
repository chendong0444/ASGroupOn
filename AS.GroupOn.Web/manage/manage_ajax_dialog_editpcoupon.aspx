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
    public string pcouname = "";
    protected IPcoupon pcoupon = Store.CreatePcoupon();
    public int id = 0;
    protected override void OnLoad(EventArgs e)
    {
        id = Helper.GetInt(Request["id"], 0);
        if (Request["id"] != null)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pcoupon = session.Pcoupon.GetByID(id);
            }
            if (pcoupon != null)
                pcouname = pcoupon.number;
        }
        if (Request.Form["button"] == "提交")//
        {
            IPcoupon p = null;
            if (id > 0)
            {
                using (IDataSession session = Store.OpenSession(false))
                {
                    p = session.Pcoupon.GetByID(id);
                }
                if (p != null)
                {
                    p.number = Helper.GetString(Request["coupon"], String.Empty);
                    int i = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        i = session.Pcoupon.Update(p);
                    }
                    if (i > 0)
                        SetSuccess("友情提示：修改成功");
                    Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
                    Response.End();
                }
            }
            else
            {
                SetSuccess("友情提示：修改失败");
                Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
                Response.End();
            }
        }
    }
</script>
<form id="Form" runat="server">
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 500px;">
    <input type="hidden" name="totalNumber" value="" />
    <h3>
        <span id="Span1" class="close" onclick="return X.boxClose();">关闭</span>请修改券号<font
            style="color: red"></font></h3>
    <p class="act">
  商户优惠券号：
    <input id="couponsh" name="coupon" type="text" require="true" datatype="require"
        value='<%=pcouname %>' style="width: 201px;"/>
        <input type="submit" value="提交" class="formbutton validator" onclick="return checkvalue();" group="g" name="button"
             />
        </p>
</div>
<script type="text/javascript">
    function checkvalue() {
        if ($("#couponsh").val() == "") {
            alert("请输入您要修改的券号");
          return false
        }
    }
 </script>
</form>
