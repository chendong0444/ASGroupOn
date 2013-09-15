<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    protected NameValueCollection system = new NameValueCollection();
    protected NameValueCollection team = new NameValueCollection();
    protected NameValueCollection order = new NameValueCollection();
    public ITeam teammodel = null;
    public IOrder morder = null;
    public IOrderDetail detailmodel = null;
    public ICard cardmodel = null;
    protected string ty = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        NeedLogin();
        system = Helper.GetObjectProtery(ASSystem);
        int orderid = Helper.GetInt(Request["order_id"], 0);
        string cardcode = Helper.GetString(Request.Form["cardcode"], String.Empty);
        using (IDataSession session = Store.OpenSession(false))
        {
            morder = session.Orders.GetByID(orderid);
            cardmodel = session.Card.GetByID(cardcode);
        }
        ty = Helper.GetString(Request["ty"], String.Empty);
        form.Action = WebRoot + "ajaxpage/ajax_dialog_shopcard.aspx?detailid=" + Request["detailid"] + "&order_id=" + Request["order_id"] + "&ty=" + Request["ty"];
        if (Helper.GetInt(Request["detailid"], 0) > 0)//购物车项目
        {
            using (IDataSession session = Store.OpenSession(false))
            {
                detailmodel = session.OrderDetail.GetByID(Helper.GetInt(Request["detailid"], 0));
            }
            if (detailmodel != null && detailmodel.Team != null)
            {
                teammodel = detailmodel.Team;
            }
            team = Helper.GetObjectProtery(teammodel);
            if (Request["submit"] == "确认使用" && Request["order_id"] != null && Request["cardcode"] != null)
            {
                decimal cardprice = Helper.GetDecimal(system["card"], 0);

                if (teammodel.Card == 0)
                {
                    if (ty == "jd")
                    {
                        AS.Common.Utils.JsHelper.Alert("该项目不可以使用代金券");
                        AS.Common.Utils.JsHelper.BackHistory(-1);
                    }
                    else
                    {
                        SetError("该项目不可以使用代金券");
                        Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
                    }
                    Response.End();
                    return;
                }
                if (morder != null)
                {
                    if (detailmodel.carno != String.Empty && detailmodel.Credit > 0)
                    {
                        if (ty == "jd")
                        {
                            AS.Common.Utils.JsHelper.AlertAndGoHistory("您已经使用过代金券了", -1);
                        }
                        else
                        {
                            SetError("您已经使用过代金券了");
                            Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
                        }
                        Response.End();
                        return;
                    }
                    else
                    {
                        if (cardmodel == null)
                        {
                            if (ty == "jd")
                            {
                                AS.Common.Utils.JsHelper.AlertAndGoHistory("您输入的代金券不存在", -1);
                            }
                            else
                            {
                                SetError("您输入的代金券不存在");
                                Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
                            }
                            Response.End();
                            return;
                        }
                        if (cardmodel.Partner_id != teammodel.Partner_id && cardmodel.Partner_id > 0)
                        {
                            if (ty == "jd")
                            {
                                AS.Common.Utils.JsHelper.AlertAndGoHistory("您输入的代金券不存在", -1);
                            }
                            else
                            {
                                SetError("您输入的代金券不存在");
                                Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
                            }
                            Response.End();
                            return;
                        }
                        else
                        {
                            if (cardmodel.Team_id != teammodel.Id && cardmodel.Team_id > 0)
                            {
                                if (ty == "jd")
                                {
                                    AS.Common.Utils.JsHelper.AlertAndGoHistory("您输入的代金券不存在", -1);
                                }
                                else
                                {
                                    SetError("您输入的代金券不存在");
                                    Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
                                }
                                Response.End();
                                return;
                            }
                            else
                            {
                                if (cardmodel.Begin_time > DateTime.Now || cardmodel.End_time < DateTime.Now)
                                {
                                    if (ty == "jd")
                                    {
                                        AS.Common.Utils.JsHelper.AlertAndGoHistory("您输入的代金券已过期", -1);
                                    }
                                    else
                                    {
                                        SetError("您输入的代金券已过期");
                                        Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
                                    }
                                    Response.End();
                                    return;
                                }
                                else
                                {
                                    if (cardmodel.consume != "Y") //判断是否被使用过
                                    {
                                        // price 可代金额
                                        int price = Math.Min(cardmodel.Credit, teammodel.Card);
                                        price = Math.Min(price, Convert.ToInt32(Math.Floor(detailmodel.Teamprice * detailmodel.Num)));
                                        morder.Card += price;
                                        detailmodel.carno = cardmodel.Id;
                                        detailmodel.Credit = price;
                                        morder.Origin = morder.Origin - price;
                                        if (morder.Origin < 0) morder.Origin = 0;
                                        cardmodel.Team_id = teammodel.Id;
                                        cardmodel.Partner_id = teammodel.Partner_id;
                                        cardmodel.Order_id = morder.Id;
                                        cardmodel.consume = "Y";
                                        using (IDataSession session = Store.OpenSession(false))
                                        {
                                            session.OrderDetail.Update(detailmodel);
                                            session.Orders.Update(morder);
                                            session.Card.Update(cardmodel);
                                        }
                                        if (ty == "jd")
                                        {
                                            AS.Common.Utils.JsHelper.Alert("代金券使用成功");
                                        }
                                        else
                                        {
                                            SetSuccess("代金券使用成功");
                                        }
                                        Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
                                        Response.End();
                                        return;
                                    }
                                    else
                                    {
                                        if (ty == "jd")
                                        {
                                            AS.Common.Utils.JsHelper.AlertAndGoHistory("您输入的代金券已被使用，请输入其他代金券", -1);
                                        }
                                        else
                                        {
                                            SetError("您输入的代金券已被使用，请输入其他代金券");
                                            Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
                                        }
                                        Response.End();
                                        return;
                                    }
                                }
                            }
                        }

                    }
                }
            }
        }
        else //优惠券项目
        {
            if (morder != null && morder.Team != null)
            {
                teammodel = morder.Team;
            }
            team = Helper.GetObjectProtery(teammodel);
            if (Request["submit"] == "确认使用" && Request["order_id"] != null && Request["cardcode"] != null)
            {

                decimal cardprice = Helper.GetDecimal(system["card"], 0);
                if (teammodel.Card == 0)
                {
                    SetError("该项目不可以使用代金券");
                    Response.Redirect(GetUrl("优惠卷确认","order_check.aspx?orderid=" + orderid));
                    Response.End();
                    return;
                }
                if (morder != null)
                {
                    if (morder.Card_id != null && morder.Card_id.Length > 0 || morder.Card > 0)
                    {
                        SetError("您已经使用过代金券了");
                        Response.Redirect(GetUrl("优惠卷确认","order_check.aspx?orderid=" + orderid));
                        Response.End();
                        return;
                    }
                    else
                    {
                        if (cardmodel == null)
                        {
                            SetError("您输入的代金券不存在");
                            Response.Redirect(GetUrl("优惠卷确认","order_check.aspx?orderid=" + orderid));
                            Response.End();
                            return;
                        }
                        if (cardmodel.Partner_id != null && cardmodel.Partner_id != teammodel.Partner_id && cardmodel.Partner_id > 0)
                        {
                            SetError("您输入的代金券不存在");
                            Response.Redirect(GetUrl("优惠卷确认","order_check.aspx?orderid=" + orderid));
                            Response.End();
                            return;
                        }
                        else
                        {
                            if (cardmodel.Team_id != teammodel.Id && cardmodel.Team_id > 0)
                            {
                                SetError("您输入的代金券不存在");
                                Response.Redirect(GetUrl("优惠卷确认","order_check.aspx?orderid=" + orderid));
                                Response.End();
                                return;
                            }
                            else
                            {
                                if (cardmodel.Begin_time > DateTime.Now || cardmodel.End_time < DateTime.Now)
                                {
                                    SetError("您输入的代金券已过期");
                                    Response.Redirect(GetUrl("优惠卷确认","order_check.aspx?orderid=" + orderid));
                                    Response.End();
                                    return;
                                }
                                else
                                {
                                    if (cardmodel.consume != "Y") //判断是否被使用过
                                    {
                                        int price = Math.Min(cardmodel.Credit, teammodel.Card);
                                        price = Math.Min(price, Convert.ToInt32(Math.Floor(morder.Quantity * morder.Price)));
                                        morder.Card = price;
                                        morder.Card_id = cardmodel.Id;
                                        morder.Origin = morder.Origin - morder.Card;
                                        if (morder.Origin < 0) morder.Origin = 0;
                                        cardmodel.Team_id = teammodel.Id;
                                        cardmodel.Partner_id = teammodel.Partner_id;
                                        cardmodel.Order_id = morder.Id;
                                        cardmodel.consume = "Y";
                                        using (IDataSession session = Store.OpenSession(false))
                                        {
                                            session.Orders.Update(morder);
                                            session.Card.Update(cardmodel);
                                        }
                                        SetSuccess("代金券使用成功");
                                        Response.Redirect(GetUrl("优惠卷确认","order_check.aspx?orderid=" + orderid));
                                        Response.End();
                                        return;
                                    }
                                    else
                                    {
                                        SetError("您输入的代金券已被使用，请输入其他代金券");
                                        Response.Redirect(GetUrl("优惠卷确认","order_check.aspx?orderid=" + orderid));
                                        Response.End();
                                        return;
                                    }
                                }
                            }
                        }

                    }
                }
            }
        }
    }
</script>
<form id="form" runat="server">
    <div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
        <h3><span id="Span1" class="close" onclick="return X.boxClose();">关闭</span>请输入代金券</h3>
        <p class="info" id="coupon-dialog-display-id">
            您有代金券吗？<br>
            可代现金最多为：<span class="current"><%=system["Currency"] %></span><%=team["card"]%><br />
            使用代金券不找零，不退余额
        </p>
        <p class="notice">
            <input class="f-input" type="text" group="quan" require="true" datatype="require" name="cardcode" maxlength="16" style="text-transform: uppercase;" />
            <input type="hidden" name="order_id" value="<%=order["id"] %>" />
        </p>
        <p class="act">
            <input type="submit" name="submit" group="quan" class="formbutton validator" value="确认使用" />
        </p>
    </div>
</form>
