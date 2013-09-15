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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected string strsite = "";
    protected StringBuilder sbhtmlcode = new StringBuilder();
    protected string strOrderId = "";
    protected string strMoney = "";
    protected string strState = "";
    protected string strRefund = "";
    protected string strTitle = "";
    protected StringBuilder strhtml = new StringBuilder();
    protected IList<ICoupon> list_coupon = null;
    protected IList<IPcoupon> list_pcoupon = null;
    protected IOrder ordermodel = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "订单详情";
        MobileNeedLogin();
        strsite = ASSystem.sitename;
        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            InitData(Helper.GetInt(Request["id"], 0));
        }
    }
    //详情信息(已退款/已支付)
    public void InitData(int strId)
    {
        strOrderId = strId.ToString();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ordermodel = session.Orders.GetByID(strId);
        }
        if (ordermodel != null)
        {
            
            if (ordermodel.Team_id == 0)
            {
                IOrderDetail orderdetailmodel=null;
                OrderDetailFilter ordetailfilter = new OrderDetailFilter();
                ordetailfilter.Order_ID = strId;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    orderdetailmodel = session.OrderDetail.Get(ordetailfilter);
                }
                if (orderdetailmodel.Team.Delivery == "coupon")
                {
                    if (orderdetailmodel.Team.isrefund == "Y")
                    {
                        strRefund = "<span>支持7天退款</span><span>支持过期退款</span>";
                    }
                    else if (orderdetailmodel.Team.isrefund == "S")
                    {
                        strRefund = "<span>仅支持7天退款</span>";
                    }
                    else if (orderdetailmodel.Team.isrefund == "G")
                    {
                        strRefund = "<span>仅支持过期退款</span>";
                    }
                    else
                    {
                        strRefund = "<span>不支持7天退款以及过期退款</span>";
                    }
                }
                strTitle = "<h2><a href='" + GetMobilePageUrl(orderdetailmodel.Team.Id) + "'>" + orderdetailmodel.Team.Product + "</a></h2>";
            }
            else
            {
                if (ordermodel.Team.Delivery == "coupon")
                {
                    if (ordermodel.Team.isrefund == "Y")
                    {
                        strRefund = "<span>支持7天退款</span><span>支持过期退款</span>";
                    }
                    else if (ordermodel.Team.isrefund == "S")
                    {
                        strRefund = "<span>仅支持7天退款</span>";
                    }
                    else if (ordermodel.Team.isrefund == "G")
                    {
                        strRefund = "<span>仅支持过期退款</span>";
                    }
                    else
                    {
                        strRefund = "<span>不支持7天退款以及过期退款</span>";
                    }
                }
                strTitle = "<h2><a href='" + GetMobilePageUrl(ordermodel.Team.Id) + "'>" + ordermodel.Team.Product + "</a></h2>";
            }
            strMoney = ordermodel.Origin.ToString();
            if (ordermodel.State == "pay")
            {
                strState = "已付款";
            }
            else if (ordermodel.State == "refund")
            {
                strState = "已退款";
            }

            if (ordermodel.Express == "Y")//快递项目
            {
                string strkudistate="";
                string strkuaidiname = "";
                string strkuaiducode = "";
                if (ordermodel.Express_id > 0)
                {
                    strkudistate = "<font style='color:#98B13F'>已发货</font>";
                    CategoryFilter Categoryfil = new CategoryFilter();
                    IList<ICategory> CategoryList = null;
                    Categoryfil.Id = ordermodel.Express_id;
                    Categoryfil.Zone = "express";
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        CategoryList = session.Category.GetList(Categoryfil);
                    }

                    if (CategoryList.Count > 0)
                    {
                        if (CategoryList[0].Name != null && CategoryList[0].Name.ToString() != "")
                        {
                            strkuaidiname = CategoryList[0].Name.ToString();
                            strkuaiducode = ordermodel.Express_no;
                        }
                    }
                }
                else
                {
                    strkudistate = "未发货";
                }
                strhtml.Append("<h3 class='common-title'>快递信息：</h3>");
                strhtml.Append("<section class='common-items'>");
                strhtml.Append("<div class='common-item'><span class='item-label'>发货状态：</span><span class='item-content'>" + strkudistate + "</span></div>");
                strhtml.Append("<div class='common-item'><span class='item-label'>快递公司：</span><span class='item-content'>" + strkuaidiname + "</span></div>");
                strhtml.Append("<div class='common-item'><span class='item-label'>快递单号：</span><span class='item-content'>" + strkuaiducode + "</span></div>");
                strhtml.Append("</section>");
            
            }
            else if (ordermodel.Express == "N") //优惠劵
            {
                CouponFilter couponfilter = new CouponFilter();
                couponfilter.Order_id = ordermodel.Id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    list_coupon = session.Coupon.GetList(couponfilter);
                }
                if (list_coupon != null && list_coupon.Count>0)
                {
                    for (int i = 0; i < list_coupon.Count; i++)
                    {
                        sbhtmlcode.Append("<div class='common-item'><span class='item-label'>优惠劵：</span><span class='item-content'>" + list_coupon[i].Id + " - " + list_coupon[i].Secret + "</span></div>");
                    }
                    if (isTime(list_coupon[0].Expire_time) == false)
                    {
                        strState = "已过期";
                    }
                    else
                    {
                    }
                }
                else
                {
                    sbhtmlcode.Append("&nbsp;&nbsp;&nbsp;&nbsp;劵号密码已注销");
                }
                strhtml.Append("<h3 class='common-title'>" + strsite + "劵：</h3>");
                strhtml.Append("<section class='common-items'>");
                strhtml.Append(sbhtmlcode);
                strhtml.Append("</section>");
            }
            else if(ordermodel.Express=="P") //站外劵
            {
                PcouponFilter pcouponfilter = new PcouponFilter();
                pcouponfilter.orderid = ordermodel.Id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    list_pcoupon = session.Pcoupon.GetList(pcouponfilter);
                }
                if (list_pcoupon != null && list_pcoupon.Count>0)
                {
                    for (int i = 0; i < list_pcoupon.Count; i++)
                    {
                        sbhtmlcode.Append("<div class='common-item'><span class='item-label'>优惠劵：</span><span class='item-content'>" + list_pcoupon[i].number + "</span></div>");
                    }
                    if (isTime(list_pcoupon[0].expire_time) == false)
                    {
                        strState = "已过期";
                    }
                    else
                    {
                        
                    }
                }
                else
                {
                    sbhtmlcode.Append("&nbsp;&nbsp;&nbsp;&nbsp;劵号密码已注销");
                }
                strhtml.Append("<h3 class='common-title'>" + strsite + "劵：</h3>");
                strhtml.Append("<section class='common-items'>");
                strhtml.Append(sbhtmlcode);
                strhtml.Append("</section>");
            }
        
        }
        strhtml.Append("<h3 class='common-title'>订单信息：</h3>");
        strhtml.Append("<section class='common-items'>");
        strhtml.Append("<div class='common-item'><span class='item-label'>订单编号：</span><span class='item-content'>" + strOrderId + "</span></div>");
        strhtml.Append("<div class='common-item'><span class='item-label'>总价：</span><span class='item-content'>" + ASSystem.currency + strMoney + "</span></div>");
        strhtml.Append("<div class='common-item'><span class='item-label'>订单状态：</span><span class='item-content'>" + strState + "</span></div>");
        strhtml.Append("</section>");
    }
    //判断优惠券的到期日期是否大于当前日期，如果大于，返回true
    public bool isTime(DateTime Consume_time)
    {
        if (Convert.ToDateTime(Consume_time.ToString("yyyy-MM-dd 23:59:59")) > DateTime.Now)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<body>
    <header>
        <div class="left-box">
            <a class="go-back" href="javascript:history.back()"><span>返回</span></a>
        </div>
        <h1>订单详情</h1>
    </header>
    <article class="body" id="orderView">
        <div class="deal-title">
            <%=strTitle %>
            <p class="protect">
                <%=strRefund %>
            </p>

        </div>
        <%=strhtml %>
    </article>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>