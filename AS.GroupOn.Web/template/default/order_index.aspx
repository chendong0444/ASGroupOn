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
    public bool result = false;//是否过期
    string strpage = string.Empty;//内容部分
    string pay = string.Empty;//全部，未付款，已付款
    string url = string.Empty;//url
    protected int Userid = 0;//登录ID
    public string pagenum = "1";
    public int teamId = 0;
    IPagers<IOrder> pager = null;
    protected OrderFilter ordermodel = new OrderFilter();
    UserFilter usermodel = new UserFilter();
    protected IList<IOrder> orderpage = null;
    IUser userpage = null;
    IList<IOrderDetail> detaillist = null;
    protected NameValueCollection _system = new NameValueCollection();
    ITeam teammodel = null;
    protected override void OnLoad(EventArgs e)
    {
        _system = PageValue.CurrentSystemConfig;// 得到系统配置表信息
        OrderFilter filter = new OrderFilter();
        Userid = Convert.ToInt32(AsUser.Id);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            userpage = session.Users.GetByID(Userid);
        }
        usermodel.ID = Userid;
        base.OnLoad(e);
        Ordertype = "order";
        NeedLogin();
        if (Request["pagenum"] != null)
        {
            if (AS.Common.Utils.NumberUtils.IsNum(Request["pagenum"].ToString()))
            {
                pagenum = Request["pagenum"].ToString();
            }
            else
            {
                SetError("您输入的参数非法");
            }
        }

        if (Request["teamid"] != null && Request["orderid"] != null)
        {
            Delete(Convert.ToInt32(Request["teamid"]), Convert.ToInt32(Request["orderid"]));
        }
        GetOrder();
    }
    //样式
    public string GetStyle(string s, string style)
    {
        string str = "";
        if (s == style)
        {
            str = "class='current'";
        }
        return str;
    }
    //删除未支付的订单，同时修改代金券的状态
    public void Delete(int teamid, int orderid)
    {

        IOrder orderimode = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            orderimode = session.Orders.GetByID(orderid);
        }
        if (orderimode != null && (orderimode.State == "unpay" || orderimode.State == "scoreunpay") || orderimode.State == "refund")
        {
            if (orderimode.User_id == AsUser.Id)
            {
                ActionHelper.User_CancelOrder(orderimode, teamid);
                SetSuccess("友情提示：删除成功");
            }
            else
            {
                SetError("友情提示：不可以删除其他人的订单");
            }
        }
        else
        {
            if (orderimode != null && orderimode.Service == "cashondelivery" && orderimode.State == "nocod")
            {
                if (orderimode.Express_id == 0 || orderimode.Express_no == null)//等待发货，可以删除(即用户取消的订单)
                {
                    if (orderimode.User_id == AsUser.Id)
                    {

                        ActionHelper.User_CancelOrder(orderimode, teamid);
                        SetSuccess("友情提示：删除成功");
                    }
                    else
                    {
                        SetError("友情提示：不可以删除其他人的订单");
                    }
                }
                if (orderimode.Express_id > 0 && orderimode.Express_no != null && orderimode.State == "nocod")//已发货
                {
                    SetError("当前项目订单已发货，无法删除");
                }
            }
            else
            {
                SetError("当前项目订单已付款或者不存在，无法删除");
            }
        }
    }
    //如果项目的团购日期已经过了，并且订单没有支付，那么这个订单是过期的订单
    public bool Gettuan(int orderid, int Id, string pay)
    {
        bool falg = false;
        if (Id != 0)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                teammodel = session.Teams.GetByID(Convert.ToInt32(Id));
            }
            if (teammodel != null)
            {
                if (teammodel.teamcata == 0)
                {
                    if ((teammodel.End_time < DateTime.Now && pay == "unpay") || (teammodel.Max_number != 0 && teammodel.Now_number >= teammodel.Max_number))
                    {
                        falg = true;
                    }
                }
                else if (teammodel.teamcata == 1)
                {
                    if (pay == "unpay")
                    {
                        falg = false;
                    }
                }
            }
        }
        else
        {
            OrderDetailFilter orderdatefile = new OrderDetailFilter();
            orderdatefile.Order_ID = Convert.ToInt32(orderid);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                detaillist = session.OrderDetail.GetList(orderdatefile);
            }
            foreach (IOrderDetail model in detaillist)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    teammodel = session.Teams.GetByID(Convert.ToInt32(model.Teamid));
                }
                if (teammodel != null)
                {
                    if (teammodel.teamcata == 0)
                    {
                        if ((teammodel.End_time < DateTime.Now && pay == "unpay") || (teammodel.Max_number != 0 && teammodel.Now_number >= teammodel.Max_number))
                        {
                            falg = true;
                        }
                    }
                    else if (teammodel.teamcata == 1)
                    {
                        if (pay == "unpay")
                        {
                            falg = false;
                        }
                    }
                }
            }
        }
        return falg;
    }
    //根据项目编号，查询项目内容
    public string GetTeam(string orderid, string state)
    {
        //sumResult = true;
        int userid = userpage.Id;
        string str = "";
        IOrder orders = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            orders = session.Orders.GetByID(Helper.GetInt(orderid, 0));
        }

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(Convert.ToInt32(orders.Team_id));
        }
        IUserReview userreviewmodel = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            userreviewmodel = session.UserReview.GetByID(1);
        }
        if (teammodel != null)
        {
            teamId = teammodel.Id;
            if (state == "pay" || state == "unpay" || state == "nocod" || state == "refund" || state == "cancel")
            {
                str = "<a class='deal-title'  href='" + getTeamPageUrl(teammodel.Id) + "' target='_blank' title='" + teammodel.Title + "' >" + Helper.GetSubString(teammodel.Title.ToString(), 65) + "</a>";
            }
            else
            {
                str = "<a class='deal-title' href='" + GetUrl("积分详情", "pointsshop_index.aspx?id=" + teammodel.Id) + "' target='_blank' title='" + teammodel.Title + "' >" + Helper.GetSubString(teammodel.Title.ToString(), 65) + "</a>";
            }

        }
        else
        {
            OrderDetailFilter orderdatefile = new OrderDetailFilter();
            orderdatefile.Order_ID = Convert.ToInt32(orderid);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                detaillist = session.OrderDetail.GetList(orderdatefile);
            }
            if (detaillist != null)
            {
                int num = 0;
                foreach (IOrderDetail model in detaillist)
                {
                    num++;
                    if (state == "pay" || state == "unpay" || state == "nocod" || state == "refund" || state == "cancel")
                    {
                        str += "<a class='deal-title' href='" + getTeamPageUrl(model.Teamid) + "' target='_blank'>";
                    }
                    else
                    {
                        str += "<a class='deal-title' href='" + GetUrl("积分详情", "pointsshop_index.aspx?id=" + model.Teamid) + "' target='_blank'>";
                    }
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        teammodel = session.Teams.GetByID(Convert.ToInt32(model.Teamid));
                    }
                    //string title = teammodel.Title;
                    str += teammodel == null ? "该项目不存在" : Helper.GetSubString(teammodel.Title, 65);
                    str += "</a><br>";
                }

            }
            else
            {
                str = "";

            }
        }
        return str;
    }
    //显示我的订单
    public void GetOrder()
    {
        UserFilter usermodel = new UserFilter();
        ordermodel.PageSize = 10;
        ordermodel.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["pagenum"], 1);
        ordermodel.UnState = "cancel";
        ordermodel.User_id = Userid;
        ordermodel.AddSortOrder(OrderFilter.ID_DESC);
        if (Request["pay"] != null && Request["pay"] != "")  //根据订单的状态查询订单
        {
            pay = Request["pay"].ToString().Replace("'", "");

            if (pay == "unpay")
            {
                ordermodel.Wheresql1 = " (State='unpay' or State='nocod')";
            }
            else
            {

                ordermodel.State = pay;
            }

        }
        url = GetUrl("我的订单", "order_index.aspx?pay=" + pay + "&pagenum={0}");
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Orders.GetPager(ordermodel);

        }
        orderpage = pager.Objects;
        if (orderpage.Count == 0)
        {
            strpage = "对不起，没有相关数据";
        }
        else
        {
            if (pager.TotalRecords >= 10)
            {
                strpage = AS.Common.Utils.WebUtils.GetPagerHtml(10, pager.TotalRecords, Convert.ToInt32(pagenum), url);
            }
        }
    }
    public string getisrefundState(string str)
    {
        switch (str)
        {
            case "S":
                return "1";
            case "G":
                return "2";
            case "Y":
                return "4";
            case "N":
                return "0";
        }
        return "0";
    }
    public string GetPayUrl(string userid,string orderid)
    {
        string strNewUrl = String.Empty;
        _system = WebUtils.GetSystem();
        IOrder order = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            order = session.Orders.GetByID(int.Parse(orderid));
        }
        if (_system != null && _system["MallTemplate"] != null && _system["MallTemplate"].ToString() == "1")
        {
            if (order != null && order.OrderDetail != null && order.OrderDetail.Count > 0)
            {
                if (order.OrderDetail[0].Team.teamcata != null && order.OrderDetail[0].Team.teamcata == 0)
                {
                    if (order.OrderDetail[0].Team.invent_result != null)
                    {
                        if (order.OrderDetail[0].Team.invent_result.Contains("价格"))
                            strNewUrl = GetUrl("不同价格订单", "shopcart_notpriceation.aspx?orderid=" + orderid);
                        else
                            strNewUrl = GetUrl("购物车订单", "shopcart_confirmation.aspx?userid=" + userid + "&orderid=" + orderid);
                    }
                    else
                    {
                        strNewUrl = GetUrl("购物车订单", "shopcart_confirmation.aspx?userid=" + userid + "&orderid=" + orderid);
                    }
                }
                else
                {
                    strNewUrl = GetUrl("京东选择银行", "shop_jdservice.aspx?orderid=" + orderid);
                }
            }
        }
        else
        {
            if (order.Team_id != 0)
            {
                strNewUrl = GetUrl("优惠卷确认", "order_check.aspx?orderid=" + orderid);
            }
            else
            {
                if (order != null && order.OrderDetail != null && order.OrderDetail.Count>0)
                {
                    if (order.OrderDetail[0].Team.teamcata!=null&&order.OrderDetail[0].Team.teamcata == 0)
                    {
                        if (order.OrderDetail[0].Team.invent_result != null)
                        {
                            if (order.OrderDetail[0].Team.invent_result.Contains("价格"))
                                strNewUrl = GetUrl("不同价格订单", "shopcart_notpriceation.aspx?orderid=" + orderid);
                            else
                                strNewUrl = GetUrl("购物车订单", "shopcart_confirmation.aspx?userid=" + userid + "&orderid=" + orderid);
                        }
                        else
                        {
                            strNewUrl = GetUrl("购物车订单", "shopcart_confirmation.aspx?userid=" + userid + "&orderid=" + orderid);
                        }
                    }
                    else
                    {
                        strNewUrl = GetUrl("购物车订单", "shopcart_confirmation.aspx?userid=" + userid + "&orderid=" + orderid);
                    }
                }
                else
                {
                    strNewUrl = GetUrl("购物车订单", "shopcart_confirmation.aspx?userid=" + userid + "&orderid=" + orderid);
                }
            }
        }
        return strNewUrl;
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    function fnOver(thisId) {
        var thisClass = thisId.className;
        var overCssF = thisClass;
        if (thisClass.length > 0) { thisClass = thisClass + " " };
        thisId.className = thisClass + overCssF + "hover";
    }
    function fnOut(thisId) {
        var thisClass = thisId.className;
        var thisNon = (thisId.className.length - 5) / 2;
        thisId.className = thisClass.substring(0, thisNon);
    }
</script>
<form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div class="menu_tab" id="dashboard">
                        <%LoadUserControl("_MyWebside.ascx", Ordertype); %>
                    </div>
                    <div id="tabsContent" class="coupons-box">
                        <div class="box-content1 tab">
                            <div class="head">
                                <h2>我的订单</h2>
                                <%LoadUserControl(WebRoot + "UserControls/blockaboutorder.ascx", null); %>
                                <ul class="filter">
                                    <li class="label">分类: </li>
                                    <li><a href="<%=GetUrl("我的订单", "order_index.aspx")%>">全部</a> </li>
                                    <li><a href="<%=GetUrl("我的订单", "order_index.aspx?pay=unpay")%>">未付款</a> </li>
                                    <li><a href="<%=GetUrl("我的订单", "order_index.aspx?pay=pay")%>">已付款</a> </li>
                                </ul>
                            </div>
                            <div class="sect">
                                <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                    <tr>
                                        <th width="80">订单编号
                                        </th>
                                        <th width="200">项目名称
                                        </th>
                                        <th width="35">数量
                                        </th>
                                        <th width="50">总价
                                        </th>
                                        <th width="40">积分
                                        </th>
                                        <th width="60">状态
                                        </th>
                                        <th width="100">操作
                                        </th>
                                    </tr>
                                    <%int i = 0; %>
                                    <%foreach (IOrder ordermod in orderpage)
                                      {
                                          result = false;
                                          string value = "";
                                          if (ordermod.Service == "cashondelivery" && (ordermod.State == "nocod" || ordermod.State == "pay"))
                                          {
                                              if (ordermod.Express_id == 0 || ordermod.Express_no == null || ordermod.Express_no == "")
                                              {
                                                  value = "等待发货";
                                              }
                                              else if (ordermod.Express_id > 0 && ordermod.Express_no.Length > 0 && ordermod.State == "nocod")
                                              {
                                                  value = "已发货";
                                              }
                                              else if (ordermod.State == "pay")
                                              {
                                                  value = "已收货";
                                              }
                                          }
                                          else if (ordermod.State == "pay" || ordermod.State == "scorepay")
                                          {
                                              value = "已付款";
                                          }
                                          else if (Gettuan(ordermod.Id, Convert.ToInt32(ordermod.Team_id.ToString()), ordermod.State))
                                          {
                                              result = true;
                                              value = "已过期";
                                          }
                                          else if (ordermod.State == "refund")
                                          {
                                              value = "已退款";
                                          }
                                          else if (ordermod.State == "refunding")
                                          {
                                              value = "正在退款";
                                          }
                                          else
                                          {
                                              result = true;
                                              value = "未付款";
                                          }
                                    %>
                                    <tr <%if (i % 2 != 0)
                                          {%>
                                        class='alt' <%} %>>
                                        <td>
                                            <%=ordermod.Id %>
                                        </td>
                                        <td style="text-align: left;">
                                            <%= GetTeam(ordermod.Id.ToString(), ordermod.State)%>
                                        </td>
                                        <td>
                                            <%=ordermod.Quantity %>
                                        </td>
                                        <td>
                                            <span class="money"></span>
                                            <%=ASSystem.currency%>
                                            <%=ordermod.Origin %>
                                        </td>
                                        <td>
                                            <span class="money"></span>
                                            <%=ordermod.orderscore %>
                                        </td>
                                        <td>
                                            <%=value %>
                                        </td>
                                        <td>
                                            <%if (value == "已退款" || value == "正在退款")
                                              {%>
                                            <%}
                                              else
                                              {
                                            %>
                                            <%if (ordermod.State == "pay" || ordermod.State == "scorepay")
                                              {
                                            %>
                                            <a href="<%=GetUrl("订单详情","order_view.aspx?userid="+ordermod.User_id+"&id="+ordermod.Id)%>">详情</a>
                                            <% if (ordermod.Team_id != 0 && ordermod.Team_id != null)
                                               {
                                                   if (ordermod.rviewstate == 0)
                                                   {
                                                       using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                       {
                                                           teammodel = session.Teams.GetByID(ordermod.Team_id);
                                                       }

                                                       DateTime days = Helper.GetDateTime(ordermod.Pay_time, DateTime.Now).AddDays(7);
                                                       if (teammodel != null)
                                                       {
                                                           if (teammodel.Delivery == "coupon" && days > DateTime.Now)
                                                           {
                                                               if (teammodel.isrefund == "S" || teammodel.isrefund == "Y")
                                                               {%>
                                        | <a class="ajaxlink" href="<%=PageValue.WebRoot%>ajax/Refund_like_manage.aspx?action=Refundreview&userid=<%=ordermod.User_id %>&id=<%=ordermod.Id %>&pagenum=<%=pagenum%>">退款申请</a>
                                            <% }
                                            %>
                                            <%  }
                                                       else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "G")
                                                       {%>
                                        | <a class="ajaxlink" href="<%=PageValue.WebRoot%>ajax/Refund_like_manage.aspx?action=Refundreview&userid=<%=ordermod.User_id %>&id=<%=ordermod.Id %>&pagenum=<%=pagenum%>">退款申请</a>
                                            <% }
                                                       else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "Y")
                                                       {%>
                                        | <a class="ajaxlink" href="<%=PageValue.WebRoot%>ajax/Refund_like_manage.aspx?action=Refundreview&userid=<%=ordermod.User_id %>&id=<%=ordermod.Id %>&pagenum=<%=pagenum%>">退款申请</a>
                                            <%}
                                                   }
                                               }
                                               else
                                               {
                                                   DateTime days = Helper.GetDateTime(ordermod.Pay_time, DateTime.Now).AddDays(7);
                                                   if (teammodel != null)
                                                   {
                                                       if (teammodel.Delivery == "coupon")
                                                       {
                                                           if (teammodel.isrefund == "S" || teammodel.isrefund == "Y" || teammodel.isrefund == "G")
                                                           {
                                                               if (ordermod.rviewstate == 1)
                                                               {
                                                                   states.InnerText = "| 退款待审核";
                                                               }
                                                               else if (ordermod.rviewstate == 2)
                                                               {
                                                                   states.InnerText = "| 退款被拒绝";
                                                               }
                                                               else if (ordermod.rviewstate == 4)
                                                               {
                                                                   states.InnerText = "| 退款审核中";
                                                               }
                                                               else if (ordermod.rviewstate == 8)
                                                               {
                                                                   states.InnerText = "";
                                                               }
                                                           }

                                                       }
                                                   }
                                            %>
                                            <label id="states" runat="server">
                                            </label>
                                            <%
                                               }
                                           }
                                          }
                                              else if (value == "已过期")
                                              { %>
                                            <% 
                                              if (ordermod.State == "pay")
                                              {%>
                                            <a href="<%=GetUrl("订单详情","order_view.aspx?userid="+ordermod.User_id+"&id="+ordermod.Id)%>">详情</a>
                                            <% if (ordermod.Team_id != 0 && ordermod.Team_id != null)
                                               {
                                                   if (ordermod.rviewstate == 0)
                                                   {
                                                       DateTime days = Helper.GetDateTime(ordermod.Pay_time, DateTime.Now).AddDays(7);
                                                       if (teammodel != null)
                                                       {
                                                           if (teammodel.Delivery == "coupon" && days > DateTime.Now)
                                                           {

                                                               if (teammodel.isrefund == "Y" || teammodel.isrefund == "S")
                                                               {%>
                                        | <a class="ajaxlink" href="<%=PageValue.WebRoot%>ajax/Refund_like_manage.aspx?action=Refundreview&userid=<%=ordermod.User_id %>&id=<%=ordermod.Id %>&pagenum=<%=pagenum%>">退款申请</a>
                                            <%}
                                                                    
                                            %>
                                            <%  }
                                                       else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "G")
                                                       {%>
                                        | <a class="ajaxlink" href="<%=PageValue.WebRoot%>ajax/Refund_like_manage.aspx?action=Refundreview&userid=<%=ordermod.User_id %>&id=<%=ordermod.Id %>&pagenum=<%=pagenum%>">退款申请</a>
                                            <%}
                                                   }
                                               }
                                               else
                                               {
                                                   DateTime days = Helper.GetDateTime(ordermod.Pay_time, DateTime.Now).AddDays(7);
                                                   if (teammodel != null)
                                                   {
                                                       if (teammodel.Delivery == "coupon")
                                                       {
                                                           if (teammodel.isrefund == "Y" || teammodel.isrefund == "S" || teammodel.isrefund == "G")
                                                           {
                                                               if (ordermod.rviewstate == 1)
                                                               {

                                                                   states.InnerText = "| 退款待审核";
                                                               }
                                                               else if (ordermod.rviewstate == 2)
                                                               {
                                                                   states.InnerText = "| 退款被拒绝";
                                                               }
                                                               else if (ordermod.rviewstate == 4)
                                                               {
                                                                   states.InnerText = "| 退款审核中";
                                                               }
                                                               else if (ordermod.rviewstate == 8)
                                                               {
                                                                   states.InnerText = "";
                                                               }
                                                           }
                                                       }
                                                   }
                                            %>
                                            <label id="Label2" runat="server">
                                            </label>
                                            <%
                                               }
                                           }%>
                                            <% } %>
                                            <%}
                                              else
                                              { %>
                                            <%if (ordermod.Team_id == 0 || ordermod.Team == null)
                                              { %>
                                            <%if (ordermod.State == "scoreunpay")
                                              { %>
                                            <a href="<%=GetUrl("积分支付","PointsShop_Pconfir.aspx?userid="+ordermod.User_id +"&orderid="+ordermod.Id)%>">付款</a> |<a href="<%=GetUrl("我的订单", "order_index.aspx?pay="+pay +"&teamid="+ordermod.teamid +"&orderid="+ordermod.Id) %>"
                                                ask="是否删除此订单?">删除</a>
                                            <% }
                                              else
                                              {%>
                                            <%if (ordermod.Service != "cashondelivery")
                                              { %>
                                            <a href="<%=GetPayUrl(ordermod.User_id.ToString(),ordermod.Id.ToString())%>">付款</a> |
                                        <%}
                                              else if (ordermod.Service == "cashondelivery" && ordermod.State == "unpay")
                                              { 
                                        %><a href="<%=GetPayUrl(ordermod.User_id.ToString(),ordermod.Id.ToString())%>">
                                            付款</a> |
                                        <% }
                                        %><a href="<%=GetUrl("我的订单", "order_index.aspx?pay="+pay +"&teamid="+ordermod.teamid +"&orderid="+ordermod.Id) %>"
                                            ask="是否删除此订单?">删除</a>
                                            <% }
                                          }
                                              else
                                              {%>
                                            <a href="<%=GetUrl("优惠卷确认","order_check.aspx?userid="+ordermod.User_id +"&orderid="+ordermod.Id) %>">付款</a> |<a href="<%=GetUrl("我的订单", "order_index.aspx?pay="+pay +"&teamid="+ordermod.teamid +"&orderid="+ordermod.Id) %>"
                                                ask="是否删除此订单?">删除</a>
                                            <% }%>
                                            <%}%>
                                            <%} %>
                                        </td>
                                    </tr>
                                    <% 
                                              i++;
                                  }%>
                                    <tr>
                                        <td colspan="7">
                                            <%=strpage%>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
</form>
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %>
