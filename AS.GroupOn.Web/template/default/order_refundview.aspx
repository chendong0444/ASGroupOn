<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected int orderid = 0;
    protected int pagenum = 1;
    protected int id = 0;
    protected NameValueCollection userarr = new NameValueCollection();
    protected NameValueCollection teamarr = new NameValueCollection();
    protected NameValueCollection orderarr = new NameValueCollection();
    IOrder ordermodel = null;
    ITeam teamodel = null;
    OrderDetailFilter orderdetafil = new OrderDetailFilter();
    IList<IOrderDetail> detailist = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NeedLogin();
        orderid = Helper.GetInt(Request["id"], 0);
        id = Helper.GetInt(Request["id"], 0);
        pagenum = Helper.GetInt(Request["pagenum"], 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ordermodel = session.Orders.GetByID(orderid);
        }
    }
    #region 修改订单的状态
    public void btn_clik(object sender, EventArgs e)
    {
        string userremarke = Helper.GetString(Request["remark"], String.Empty);
        if (userremarke.Trim() == "" || userremarke.Trim() == String.Empty)
        {
            SetError("请您填写退款原因");
            Response.Redirect(Request.UrlReferrer.AbsoluteUri);
            Response.End();
            return;
        }
        ordermodel.rviewstate = 1;
        ordermodel.userremarke = Helper.GetString(Request["remark"], String.Empty);
        int ires = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ires = session.Orders.Update(ordermodel);
        }
        if (ires > 0)
        {
            SetSuccess("退款申请成功，待审核中！");
        }
        Response.Redirect(Request.UrlReferrer.AbsoluteUri);
        Response.End();
        return;

    }
    public void updatestate()
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teamodel = session.Teams.GetByID(ordermodel.Team_id);
        }

        ActionHelper.RefundType refundtype = (ActionHelper.RefundType)Helper.GetInt(Request["refund"], 0);
        string message;
        string error = ActionHelper.Mananger_RefundMent(Helper.GetInt(orderid, 0), AsUser.Id, refundtype, out message);
        if (error == String.Empty)
        {
            #region
            if (ordermodel.Team_id == 0 || ordermodel.Team_id.ToString() == "")
            {
                orderdetafil.Order_ID = ordermodel.Id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    detailist = session.OrderDetail.GetList(orderdetafil);
                }

                foreach (IOrderDetail model in detailist)
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        teamodel = session.Teams.GetByID(model.Teamid);
                    }
                    DateTime days = Helper.GetDateTime(ordermodel.Pay_time, DateTime.Now).AddDays(7);
                    if (teamodel.Delivery == "express" && days <= DateTime.Now)
                    {
                        if (Helper.GetInt(teamodel.open_invent, 0) == 1)//开启库存功能
                        {
                            // 修改过规格数量
                            if (model.result != "")
                            {
                                Utility.GetNewOld(model.result, teamodel.invent_result);
                                teamodel.invent_result = Utility.GetOrderrule(model.result, teamodel.invent_result, 1);
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    int i = 0;
                                    i = session.Teams.Update(teamodel);
                                }

                            }
                            teamodel.inventory = teamodel.inventory + model.Num;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int i = 0;
                                i = session.Teams.Update(teamodel);
                            }
                            //  退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                            AdminPage.intoorder(ordermodel.Id, model.Num, 4, model.Teamid, AsUser.Id, model.result, 0);
                            // 处理产品库存
                            IProduct promodel = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                promodel = session.Product.GetByID(teamodel.productid);
                            }
                            if (promodel != null)
                            {
                                if (model.result != "")
                                {
                                    promodel.invent_result = Utility.GetOrderrule(model.result, promodel.invent_result, 1);
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        int i = 0;
                                        i = session.Product.Update(promodel);
                                    }
                                }

                                promodel.inventory = promodel.inventory + model.Num;
                                if (promodel.inventory > 0)
                                {
                                    promodel.status = 1;
                                }
                                else
                                {
                                    promodel.status = 0;
                                }
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    int i = 0;
                                    i = session.Product.Update(promodel);
                                }

                                //退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                                AdminPage.intoorder(ordermodel.Id, model.Num, 4, promodel.id, AsUser.Id, model.result, 1);
                            }
                        }
                    }
                    else if (teamodel.Delivery == "coupon")
                    {
                        if (Helper.GetInt(teamodel.open_invent, 0) == 1)//开启库存功能
                        {
                            // 修改过规格数量
                            if (model.result != "")
                            {
                                Utility.GetNewOld(model.result, teamodel.invent_result);
                                teamodel.invent_result = Utility.GetOrderrule(model.result, teamodel.invent_result, 1);
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    int i = 0;
                                    i = session.Teams.Update(teamodel);
                                }
                            }
                            teamodel.inventory = teamodel.inventory + model.Num;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int i = 0;
                                i = session.Teams.Update(teamodel);
                            }
                            //  退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                            AdminPage.intoorder(ordermodel.Id, model.Num, 4, model.Teamid, AsUser.Id, model.result, 0);
                            // 处理产品库存
                            IProduct promodel = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                promodel = session.Product.GetByID(teamodel.productid);
                            }
                            if (promodel != null)
                            {
                                if (model.result != "")
                                {
                                    promodel.invent_result = Utility.GetOrderrule(model.result, promodel.invent_result, 1);
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        int i = 0;
                                        i = session.Product.Update(promodel);
                                    }
                                }
                                promodel.inventory = promodel.inventory + model.Num;
                                if (promodel.inventory > 0)
                                {
                                    promodel.status = 1;
                                }
                                else
                                {
                                    promodel.status = 0;
                                }
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    int i = 0;
                                    i = session.Product.Update(promodel);
                                }

                                //退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                                AdminPage.intoorder(ordermodel.Id, model.Num, 4, promodel.id, AsUser.Id, model.result, 1);
                            }
                            IList<ICoupon> couponlist = null;
                            CouponFilter coufil = new CouponFilter();
                            coufil.Order_id = orderid;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                couponlist = session.Coupon.GetList(coufil);
                            }
                            for (int i = 1; i <= couponlist.Count; i++)
                            {
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    int ii = 0;
                                    ii = session.Coupon.Delete(couponlist[i].Id);
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                if (Helper.GetInt(teamodel.open_invent, 0) == 1)//开启库存功能
                {
                    // 修改下项目的库存的数量
                    if (teamodel != null)
                    {
                        DateTime days = Helper.GetDateTime(ordermodel.Pay_time, DateTime.Now).AddDays(7);
                        if (teamodel.Delivery == "express" && days <= DateTime.Now)
                        {
                            if (Helper.GetString(ordermodel.result, "") != "")
                            {
                                // Utils.Utility.Getrule(model.result, teamodel.invent_result, 0,1);
                                teamodel.invent_result = Utility.GetOrderrule(ordermodel.result, teamodel.invent_result, 1);
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    int i = 0;
                                    i = session.Teams.Update(teamodel);
                                }
                            }
                            teamodel.inventory = teamodel.inventory + ordermodel.Quantity;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int i = 0;
                                i = session.Teams.Update(teamodel);
                            }
                            //退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                            AdminPage.intoorder(ordermodel.Id, ordermodel.Quantity, 4, ordermodel.Team_id, AsUser.Id, ordermodel.result, 0);

                            // 处理产品库存
                            IProduct promodel = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                promodel = session.Product.GetByID(teamodel.productid);
                            }
                            if (promodel != null)
                            {
                                if (ordermodel.result != "")
                                {
                                    promodel.invent_result = Utility.GetOrderrule(ordermodel.result, promodel.invent_result, 1);
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        int i = 0;
                                        i = session.Product.Update(promodel);
                                    }
                                }
                                promodel.inventory = promodel.inventory + ordermodel.Quantity;
                                if (promodel.inventory > 0)
                                {
                                    promodel.status = 1;
                                }
                                else
                                {
                                    promodel.status = 0;
                                }
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    int i = 0;
                                    i = session.Product.Update(promodel);
                                }

                                //  退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                                AdminPage.intoorder(ordermodel.Id, ordermodel.Quantity, 4, promodel.id, AsUser.Id, ordermodel.result, 1);
                            }
                        }
                        else if (teamodel.Delivery == "coupon")
                        {
                            if (Helper.GetString(ordermodel.result, "") != "")
                            {
                                teamodel.invent_result = Utility.GetOrderrule(ordermodel.result, teamodel.invent_result, 1);
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    int i = 0;
                                    i = session.Teams.Update(teamodel);
                                }
                            }
                            teamodel.inventory = teamodel.inventory + ordermodel.Quantity;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int i = 0;
                                i = session.Teams.Update(teamodel);
                            }
                            //退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                            AdminPage.intoorder(ordermodel.Id, ordermodel.Quantity, 4, ordermodel.Team_id, AsUser.Id, ordermodel.result, 0);
                            // 处理产品库存
                            IProduct promodel = null;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                promodel = session.Product.GetByID(teamodel.productid);
                            }
                            if (promodel != null)
                            {
                                if (ordermodel.result != "")
                                {
                                    promodel.invent_result = Utility.GetOrderrule(ordermodel.result, promodel.invent_result, 1);
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        int i = 0;
                                        i = session.Product.Update(promodel);
                                    }
                                }
                                promodel.inventory = promodel.inventory + ordermodel.Quantity;
                                if (promodel.inventory > 0)
                                {
                                    promodel.status = 1;
                                }
                                else
                                {
                                    promodel.status = 0;
                                }
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    int i = 0;
                                    i = session.Product.Update(promodel);
                                }

                                //  退单入库  1管理员入库 2管理员出库 3下单出库 4下单入库
                                AdminPage.intoorder(ordermodel.Id, ordermodel.Quantity, 4, promodel.id, AsUser.Id, ordermodel.result, 1);
                            }
                            IList<ICoupon> couponlist = null;
                            CouponFilter coufil = new CouponFilter();
                            coufil.Order_id = orderid;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                couponlist = session.Coupon.GetList(coufil);
                            }
                            for (int i = 1; i <= couponlist.Count; i++)
                            {
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    int ii = 0;
                                    ii = session.Coupon.Delete(couponlist[i].Id);
                                }
                            }
                        }
                    }

                }
            }
            #endregion
            SetSuccess(message);
        }
        else
            SetError(error);
        Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
        Response.End();
    }
    #endregion
</script>
<body>
    <form id="form1" runat="server">
        <div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
            <h3><span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span>退款申请</h3>
            <div style="overflow-x: hidden; padding: 10px;">
                <table class="coupons-table-xq">
                    <tr>
                        <td><b>退款原因：</b></td>
                        <td>
                            <textarea id="remark" cols="40" rows="5" name="remark"></textarea></td>
                    </tr>
                    <tr>
                        <td colspan="2" height="10">&nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td>&nbsp;</td>
                        <td>
                            <input type="submit" name="save" id="button" group="abc" runat="server" onserverclick="btn_clik" class="formbutton validator" value="提交" />
                        </td>
                    </tr>
                </table>

            </div>
        </div>
    </form>
</body>
