<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>
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
    public ITeam teammodel = null;
    public IOrder ordermodel = null;
    public ICard cardmodel = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        MobileNeedLogin();
        PageValue.WapBodyID = "verify-card";
        PageValue.Title = "使用代金券";
        if (Request.Form["submit"] == "验证")
        {
            if (Helper.GetString(Request["cardcode"], String.Empty) == String.Empty)
            {
                SetError("您输入的代金券不能为空，请您重新输入");
                Response.Redirect(GetUrl("手机版使用代金券", "order_verifycard.aspx") + Request["id"]);
                Response.End();
                return;
            }
            if (Helper.GetString(Request["id"], String.Empty) != String.Empty && Helper.GetString(Request["cardcode"], String.Empty) != String.Empty)
            {
                using (IDataSession session = Store.OpenSession(false))
                {
                    ordermodel = session.Orders.GetByID(Helper.GetInt(Request["id"], 0));
                    cardmodel = session.Card.GetByID(Helper.GetString(Request["cardcode"], String.Empty));
                }
                if (ordermodel != null && cardmodel != null)
                {
                    if (ordermodel.OrderDetail != null && ordermodel.OrderDetail.Count > 0)//快递项目
                    {
                        if (ordermodel.OrderDetail != null && ordermodel.OrderDetail[0].Team != null)
                        {
                            teammodel = ordermodel.OrderDetail[0].Team;
                        }
                        if (ordermodel.OrderDetail[0].carno != null && ordermodel.OrderDetail[0].Credit > 0)
                        {
                            SetError("您已经使用过代金券了");
                            Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["id"]);
                            Response.End();
                            return;
                        }
                        else
                        {
                            if (cardmodel == null)
                            {
                                SetError("您输入的代金券不存在");
                                Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["id"]);
                                Response.End();
                                return;
                            }
                            if (cardmodel.Partner_id != teammodel.Partner_id && cardmodel.Partner_id > 0)
                            {
                                SetError("您输入的代金券不存在");
                                Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["id"]);
                                Response.End();
                                return;
                            }
                            else
                            {
                                if (cardmodel.Team_id != teammodel.Id && cardmodel.Team_id > 0)
                                {
                                    SetError("您输入的代金券不存在");
                                    Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["id"]);
                                    Response.End();
                                    return;
                                }
                                else
                                {
                                    if (cardmodel.Begin_time > DateTime.Now || cardmodel.End_time < DateTime.Now)
                                    {
                                        SetError("您输入的代金券已过期");
                                        Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["id"]);
                                        Response.End();
                                        return;
                                    }
                                    else
                                    {
                                        if (cardmodel.consume != "Y") //判断是否被使用过
                                        {
                                            // price 可代金额
                                            int price = Math.Min(cardmodel.Credit, teammodel.Card);
                                            price = Math.Min(price, Convert.ToInt32(Math.Floor(ordermodel.OrderDetail[0].Teamprice * ordermodel.OrderDetail[0].Num)));
                                            ordermodel.Card += price;
                                            ordermodel.OrderDetail[0].carno = cardmodel.Id;
                                            ordermodel.OrderDetail[0].Credit = price;
                                            ordermodel.Origin = ordermodel.Origin - price;
                                            if (ordermodel.Origin < 0) ordermodel.Origin = 0;
                                            cardmodel.Team_id = teammodel.Id;
                                            cardmodel.Partner_id = teammodel.Partner_id;
                                            cardmodel.Order_id = ordermodel.Id;
                                            cardmodel.consume = "Y";
                                            using (IDataSession session = Store.OpenSession(false))
                                            {
                                                session.OrderDetail.Update(ordermodel.OrderDetail[0]);
                                                session.Orders.Update(ordermodel);
                                                session.Card.Update(cardmodel);
                                            }
                                            SetSuccess("代金券使用成功");
                                            Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["id"]);
                                            Response.End();
                                            return;
                                        }
                                        else
                                        {
                                            SetError("您输入的代金券已被使用，请输入其他代金券");
                                            Response.Redirect(GetUrl("手机版使用代金券", "order_verifycard.aspx") + Request["id"]);
                                            Response.End();
                                            return;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else//优惠卷项目
                    {
                        teammodel = ordermodel.Team;
                        if (teammodel.Card == 0)
                        {
                            SetError("该项目不可以使用代金券");
                            Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["id"]);
                            Response.End();
                            return;
                        }
                        if (ordermodel.Card_id != null && ordermodel.Card_id.Length > 0 || ordermodel.Card > 0)
                        {
                            SetError("您已经使用过代金券了");
                            Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["id"]);
                            Response.End();
                            return;
                        }
                        else
                        {
                            if (cardmodel == null)
                            {
                                SetError("您输入的代金券不存在");
                                Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["id"]);
                                Response.End();
                                return;
                            }
                            if (cardmodel.Partner_id != null && cardmodel.Partner_id != teammodel.Partner_id && cardmodel.Partner_id > 0)
                            {
                                SetError("您输入的代金券不存在");
                                Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["id"]);
                                Response.End();
                                return;
                            }
                            else
                            {
                                if (cardmodel.Team_id != teammodel.Id && cardmodel.Team_id > 0)
                                {
                                    SetError("您输入的代金券不存在");
                                    Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["id"]);
                                    Response.End();
                                    return;
                                }
                                else
                                {
                                    if (cardmodel.Begin_time > DateTime.Now || cardmodel.End_time < DateTime.Now)
                                    {
                                        SetError("您输入的代金券已过期");
                                        Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["id"]);
                                        Response.End();
                                        return;
                                    }
                                    else
                                    {
                                        if (cardmodel.consume != "Y") //判断是否被使用过
                                        {
                                            int price = Math.Min(cardmodel.Credit, teammodel.Card);
                                            price = Math.Min(price, Convert.ToInt32(Math.Floor(ordermodel.Quantity * ordermodel.Price)));
                                            ordermodel.Card = price;
                                            ordermodel.Card_id = cardmodel.Id;
                                            ordermodel.Origin = ordermodel.Origin - ordermodel.Card;
                                            if (ordermodel.Origin < 0) ordermodel.Origin = 0;
                                            cardmodel.Team_id = teammodel.Id;
                                            cardmodel.Partner_id = teammodel.Partner_id;
                                            cardmodel.Order_id = ordermodel.Id;
                                            cardmodel.consume = "Y";
                                            using (IDataSession session = Store.OpenSession(false))
                                            {
                                                session.Orders.Update(ordermodel);
                                                session.Card.Update(cardmodel);
                                            }
                                            SetSuccess("代金券使用成功");
                                            Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + Request["id"]);
                                            Response.End();
                                            return;
                                        }
                                        else
                                        {
                                            SetError("您输入的代金券已被使用，请输入其他代金券");
                                            Response.Redirect(GetUrl("手机版使用代金券", "order_verifycard.aspx") + Request["id"]);
                                            Response.End();
                                            return;
                                        }
                                    }
                                }
                            }

                        }
                    }
                }
                SetError("您输入的代金券不存在，请您重新输入");
                Response.Redirect(GetUrl("手机版使用代金券", "order_verifycard.aspx") + Request["id"]);
                Response.End();
                return;
            }
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<article class="body">
    <form id="card-verify-form" action="<%=GetUrl("手机版使用代金券","order_verifycard.aspx")+Request["id"] %>" method="POST">
        <div style="width: 100%; position: relative;">
            <input id="code" type="number" placeholder="请输入您的券号" class="textblock" name="cardcode" value="" required/>
            <p class="c-submit ">
                <input type="submit" name="submit" value="验证" />
            </p>
        </div>
    </form>
    <p class="help"><a href="<%=GetUrl("手机版用户代金卷帮助","help_card.aspx") %>">如何获取代金券</a></p>
</article>
<%LoadUserControl("_footer.ascx", null); %>
<script>
    $(function () {
        var $code = $('#card-code'),
            $card = $('.card');

        if ($card.length < 1)
            return false;

        $card.on(MT.util.tapOrClick, function (e) {
            e.preventDefault();

            var code = $(this).find('.code').text();
            $code.val(code);
            $('#card-verify-form').submit();
        });
    });
</script>
<%LoadUserControl("_htmlfooter.ascx", null); %>