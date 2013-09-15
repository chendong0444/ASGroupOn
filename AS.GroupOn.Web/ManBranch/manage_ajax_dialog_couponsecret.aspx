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
    protected string consume = "没有使用";
    protected IUser user = Store.CreateUser();
    protected ITeam team = Store.CreateTeam();
    protected IOrder order = Store.CreateOrder();
    protected ICoupon coupon = null;
    protected IPcoupon pcoupon = null;
    protected string branchname = "";
    protected string start_time = "";
    protected string Expire_time = "";
    protected string type = "";

    protected string couponId = "";

    protected string Secret = "";
    protected string couponid = "";
    protected string couponsecret = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        couponid = Helper.GetString(Request["id"], String.Empty);
        type = Helper.GetString(Request["type"], String.Empty);
        couponsecret = Helper.GetString(Request["couponsecret"], String.Empty);
        if (!Page.IsPostBack)
        {
            initPage();
        }
        if (Request.Form["button"] == "提交")
        {
            if (type == "pcoupon")
            {
                if (couponid != "")
                {
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        pcoupon = session.Pcoupon.GetByID(Helper.GetInt(couponid, 0));
                    }
                    if (pcoupon != null)
                    {
                        if (Request["coupon_starttime"] != null && Request["coupon_starttime"].ToString() != "")
                        {
                            string ss = Request["coupon_starttime"].ToString();
                            pcoupon.start_time = DateTime.Parse(Request["coupon_starttime"].ToString());
                        }
                        if (Request["coupon_endtime"] != null && Request["coupon_endtime"].ToString() != "")
                        {
                            pcoupon.expire_time = DateTime.Parse(Request["coupon_endtime"].ToString());
                        }
                        int i = 0;
                        using (IDataSession session = Store.OpenSession(false))
                        {
                            session.Pcoupon.Update(pcoupon);
                        }
                        if (i > 0)
                            SetSuccess("友情提示：修改成功");
                        Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                        Response.End();
                        return;
                    }
                }
            }
            else
            {
                if (couponid != "")
                {
                    CouponFilter filter = new CouponFilter();
                    filter.Id = couponid;
                    filter.Secret = couponsecret;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        coupon = session.Coupon.Get(filter);
                    }
                    if (coupon != null)
                    {
                        if (Request["coupon_starttime"] != null && Request["coupon_starttime"].ToString() != "")
                        {
                            coupon.start_time = DateTime.Parse(Request["coupon_starttime"].ToString());
                        }
                        if (Request["coupon_endtime"] != null && Request["coupon_endtime"].ToString() != "")
                        {
                            coupon.Expire_time = DateTime.Parse(Request["coupon_endtime"].ToString());
                        }
                        int i = 0;
                        using (IDataSession session = Store.OpenSession(false))
                        {
                            i = session.Coupon.Update(coupon);
                        }
                        if (i > 0)
                            SetSuccess("友情提示：修改成功");
                        Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                        Response.End();
                        return;
                    }
                }
            }
        }
    }
    private void initPage()
    {
        string id = Request["id"];
        string secret = Request["couponsecret"];
        type = Request["type"];
        if (type == "pcoupon")
        {
            PcouponFilter filter = new PcouponFilter();
            filter.id = int.Parse(id);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pcoupon = session.Pcoupon.Get(filter);
            }
            if (pcoupon.User != null)
                user = pcoupon.User;
            if (pcoupon.Team != null)
                team = pcoupon.Team;
            if (pcoupon.Order != null)
                order = pcoupon.Order;
            couponId = pcoupon.number;
            Secret = "";
            start_time = pcoupon.start_time.Value.ToString("yyyy-MM-dd HH:mm:ss");
            Expire_time = pcoupon.expire_time.ToString("yyyy-MM-dd HH:mm:ss");
        }
        else
        {
            CouponFilter filter = new CouponFilter();
            filter.Id = id;
            filter.Secret = secret;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                coupon = session.Coupon.Get(filter);
            }
            if (coupon != null)
            {
                if (coupon.User != null)
                    user = coupon.User;
                if (coupon.Team != null)
                    team = coupon.Team;
                if (coupon.Order != null)
                    order = coupon.Order;
                if (coupon.Consume == "Y")
                    consume = "已使用";
                if (coupon.start_time.HasValue)
                    start_time = coupon.start_time.Value.ToString("yyyy-MM-dd HH:mm:ss");
                else if (team.start_time.HasValue)
                {
                    start_time = team.start_time.Value.ToString("yyyy-MM-dd HH:mm:ss");
                }
                else
                    start_time = team.Begin_time.ToString("yyyy-MM-dd HH:mm:ss");
                Expire_time = coupon.Expire_time.ToString("yyyy-MM-dd HH:mm:ss");
                couponId = coupon.Id;
                Secret = coupon.Secret;
                if (coupon.shoptypes > 0)//说明在分店消费
                {
                    IBranch branch = null;
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        branch = session.Branch.GetByID(coupon.shoptypes);
                    }
                    if (branch != null)//找到分店
                    {
                        branchname = "此券在分店消费，分店名称:" + branch.branchname + ",分店ID号" + branch.id;
                    }
                    else//没有找到，分店已被删除
                    {
                        branchname = "此券在分店消费，但分店已被删除";
                    }
                }
            }
        }
    }
</script>
<form id="Form1" runat="server">
<div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
    <h3>
        <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>优惠券详情</h3>
    <div style="overflow-x: hidden; padding: 10px;">
        <table width="96%" align="center" class="coupons-table-xq">
            <tr>
                <td width="100">
                    <b>用户名：</b>
                </td>
                <td>
                    <%=user.Username%>
                </td>
            </tr>
            <tr>
                <td>
                    <b>Email：</b>
                </td>
                <td>
                    <%=user.Email %>
                </td>
            </tr>
            <tr>
                <td>
                    <b>联系手机：</b>
                </td>
                <td>
                    <%=user.Mobile%>
                </td>
            </tr>
            <tr>
                <td>
                    <b>项目名称：</b>
                </td>
                <td>
                    <%=team.Title%>
                </td>
            </tr>
            <tr>
                <td>
                    <b>下单时间：</b>
                </td>
                <td>
                    <%=order.Create_time.ToString("yyyy-MM-dd HH:mm:ss")%>
                </td>
            </tr>
            <tr>
                <th colspan="2">
                    <hr />
                </th>
            </tr>
            <tr>
                <td>
                    <b>手机号码：</b>
                </td>
                <td>
                    <%=order.Mobile%>
                </td>
            </tr>
            <tr>
                <td>
                    <b>优惠券编号：</b>
                </td>
                <td>
                    <%=couponId%>
                </td>
            </tr>
            <tr>
                <td>
                    <b>优惠券密码：</b>
                </td>
                <td>
                    <b>
                        <%=couponsecret%></b>
                </td>
            </tr>
            <tr>
                <td>
                    <b>使用状态：</b>
                </td>
                <td>
                    <b>
                        <%=consume%></b>
                </td>
            </tr>
            <%if (branchname.Length > 0)
              { %>
            <tr>
                <td>
                    <b>消费地址：</b>
                </td>
                <td>
                    <b>
                        <%=branchname%></b>
                </td>
            </tr>
            <%} %>
            <%if (true)
              { %>
            <tr>
                <td>
                    <b>优惠券开始时间：</b>
                </td>
                <td>
                    <input id="coupon_starttime" type="text" name="coupon_starttime" group="g" require="true"
                        datatype="datetime" class="date" value="<%=start_time%>" />
                </td>
            </tr>
            <tr>
                <td>
                    <b>优惠券结束时间：</b>
                </td>
                <td>
                    <input id="coupon_endtime" type="text" name="coupon_endtime" group="g" require="true"
                        datatype="datetime" class="date" value="<%=Expire_time%>" />
                </td>
            </tr>
            <tr>
                <td>
                    <input type="submit" value="提交" class="formbutton validator" group="g" name="button"
                        action="manage_ajax_dialog_couponsecret.aspx?type=<%=type %>&id=<%=couponid %>&couponsecret=<%=couponsecret %>" />
                </td>
            </tr>
            <%  }
              else
              {%>
            <tr>
                <td>
                    <b>优惠券开始时间：</b>
                </td>
                <td>
                    <%=start_time%>
                </td>
            </tr>
            <tr>
                <td>
                    <b>优惠券结束时间：</b>
                </td>
                <td>
                    <%=Expire_time%>
                </td>
            </tr>
            <%} %>
        </table>
    </div>
</div>
</form>
