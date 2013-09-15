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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public string pcouname = "";
    protected IPcoupon pcoupon = Store.CreatePcoupon();
    public int id = 0;
    public int pid = 0;
    protected override void OnLoad(EventArgs e)
    {
        if (Request["id"] != null)
        {
            id = Helper.GetInt(Request["id"], 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pcoupon = session.Pcoupon.GetByID(id);
            }
            if (pcoupon != null)
                pcouname = pcoupon.number;
        }
        if (Request.Form["button"] == "提交")//
        {
            pid = Helper.GetInt(Request["pid"], 0);
            IPcoupon p = null;
            if (pid > 0)
            {
                using (IDataSession session = Store.OpenSession(false))
                {
                    p = session.Pcoupon.GetByID(pid);
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
                SetError("友情提示：修改失败");
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
    <p id="coupon-dialog-display-id1" style="color: Red;">
        商户优惠券号：</p>
    <input id="couponsh" name="coupon" type="text" require="true" datatype="require"
        value='<%=pcouname %>' />
    <p class="act">
        <input type="submit" value="提交" class="formbutton validator" group="g" name="button"
            action="manage_ajax_dialog_editpcoupon.aspx?pid=<%=Request["id"]  %>" />
    </p>
</div>
</form>
