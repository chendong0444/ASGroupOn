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
    protected IPagers<IOrder> pager = null;
    protected IList<IOrder> list_order = null;
    protected OrderFilter filter = new OrderFilter();
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected string type = "";
    protected string strkey = "";
    protected int key;
    protected int id = 0;
    protected string type_name = "";
    protected DateTime dateTime = DateTime.Now;
    protected int cnt = 0;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        key = Helper.GetInt(Request["key"], 3);
        //1.已发货 2.未发货  3.已完成
        if (key == 1)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Order_Express_DeliveryYes_Detail))
            {
                SetError("你不具有查看已发货记录的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
        }
        else if (key == 2)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Order_Express_DeliveryNo_ListView))
            {
                SetError("你不具有查看未发货记录的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
        }
        else if (key == 3)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Order_Express_OCD_FinishOrderList))
            {
                SetError("你不具有查看已完成记录的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
        }
        else
        {
            SetError("参数不对！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        
       
        id = Helper.GetInt(Request["delete"], 0);
        if (id > 0)
        {
            int del_id = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                del_id = session.Orders.Delete(id);
            }
            if (del_id > 0)
            {
                WebUtils.LogWrite("管理员删除订单", "订单ID:" + id);
                SetSuccess("订单ID" + id + "删除成功");
            }
            if (Session["Key"] != null)
            {
                Response.Redirect("DingDan_CashState.aspx&key=" + Session["Key"]);
                Response.End();
            }
            else
            {
                Response.Redirect("DingDan_CashState.aspx");
                Response.End();
            }
            return;
        }
        
        int orderid = Helper.GetInt(Request["orderid"], 0);

        string action = Helper.GetString(Request["action"], String.Empty);
        if (action == "cashondelivery")
        {
            Check(orderid);
        }

       

        strkey = key.ToString();

        type = Helper.GetString(Request["type"], String.Empty);
        if (!string.IsNullOrEmpty(Request.QueryString["state"]))
        {
            url = url + "&state=" + Request.QueryString["state"];
            if (Request["state"] == "1")
            {
                filter.State = "unpay";
            }
            else if (Request["state"] == "2")
            {
                filter.State = "pay";
            }
        }
        if (!string.IsNullOrEmpty(Request.QueryString["begintime"]))
        {
            url = url + "&begintime=" + Request.QueryString["begintime"];
            filter.FromCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["begintime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
        {
            url = url + "&endtime=" + Request["endtime"];
            filter.ToCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["fromfinishtime"]))
        {
            url = url + "&fromfinishtime=" + Request["fromfinishtime"];
            filter.FromPay_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["fromfinishtime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["endfinishtime"]))
        {
            url = url + "&endfinishtime=" + Request.QueryString["endfinishtime"];
            filter.ToPay_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endfinishtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["select_type"]))
        {
            IUser uses = null;
            UserFilter u_filter = new UserFilter();
            url = url + "&select_type=" + Request.QueryString["select_type"];
            type_name = Request.QueryString["type_name"];
            if (Request.QueryString["select_type"] == "1" || Request.QueryString["select_type"] == "2")
            {
                if (Request.QueryString["select_type"] == "1")
                {
                    u_filter.Username = type_name;
                }
                else
                {
                    u_filter.Email = type_name;
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    uses = session.Users.Get(u_filter);
                }
                if (uses != null)
                    filter.User_id = uses.Id;
            }
            else if (Request.QueryString["select_type"] == "4")
            {
                filter.Id = Helper.GetInt(type_name, 0);
            }
            else if (Request.QueryString["select_type"] == "8")
            {
                filter.Team_In = Helper.GetInt(type_name, 0);
            }
            else if (Request.QueryString["select_type"] == "16")
            {
                filter.Pay_id = Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "32")
            {
                filter.Express_no = Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "64")
            {
                filter.Mobile = Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "128")
            {
                filter.Realname = Helper.GetString(type_name, String.Empty);
            }
            else if (Request.QueryString["select_type"] == "256")
            {
                filter.Address = Helper.GetString(type_name, String.Empty);
            }

            url = url + "&type_name=" + Request.QueryString["type_name"];
        }

        url = url + "&key=" + key;
        url = url + "&page={0}";
        url = "DingDan_CashState.aspx?" + url.Substring(1);


        //1.已发货 2.未发货  3.已完成
        if (key == 1)
        {
            Session["Key"] = 1;
            filter.Service = "cashondelivery";
            filter.State = "nocod";
            filter.Express = "Y";
            filter.No_Express_id = 0;
            filter.LenDa_Express_no = 0;
        }
        else if (key == 2)
        {
            Session["Key"] = 2;
            filter.StateOr = "nocod";
            filter.Express = "Y";
        }
        else
        {
            Session["Key"] = 3;
            filter.Service = "cashondelivery";
            filter.State = "pay";
            filter.Express = "Y";
            filter.No_Express_id = 0;
            filter.LenDa_Express_no = 0;
        }

        filter.PageSize = 30;
        filter.AddSortOrder(OrderFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Orders.GetPager(filter);
        }
        list_order = pager.Objects;

        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);

    }
    //用户付款记录
    public static void AddPay(string orderid, string payid, string bank, decimal money, string Currency, string service, DateTime? pay_time)
    {

        int oid = Helper.GetInt(orderid, 0);
        IPay pay = Store.CreatePay();
        IPay pays = Store.CreatePay();
        
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pay = session.Pay.GetByID(payid);
        }

        if (oid > 0 && pay == null || oid == 0)
        {
            pays.Id = payid;//网银交易单号
            pays.Order_id = oid;//订单号
            pays.Bank = bank;
            pays.Currency = Currency;
            pays.Service = service;
            if (pay_time.HasValue) pays.Create_time = pay_time.Value;
            else
                pays.Create_time = DateTime.Now;
            pays.Money = money;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                session.Pay.Insert(pays);
            }
        }

    }
    //积分消费记录表
    public static string Insert_scorelog(int score, string action, string orderid, int adminid, int userid)
    {
        string result = string.Empty;
        int cnt = 0;
        IScorelog scorelog = Store.CreateScorelog();
        scorelog.score = score;
        scorelog.action = action;
        scorelog.create_time = DateTime.Now;
        scorelog.adminid = adminid;
        scorelog.user_id = userid;
        scorelog.key = orderid;

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            cnt = session.Scorelog.Insert(scorelog);
        }

        if (cnt > 0)
        {
            result = "success";
        }
        else
        {
            result = "error";
        }
        return result;
    }


    // 用户消费记录
    public static void AddFlow(int userid, int orderid, string Direction, decimal money, string action, int adminid, DateTime? pay_time, string payid, string service)
    {

        IFlow flow = Store.CreateFlow();
        ITeam team = Store.CreateTeam();
        IInvite invite = Store.CreateInvite();
        IInvite newinvite = Store.CreateInvite();
        ISystem system = Store.CreateSystem();
        IOrder order = Store.CreateOrder();
        IUser user = Store.CreateUser();
        IUser newuser = Store.CreateUser();
        UserFilter userf=new UserFilter();
        IOrderDetail OrderDetail = Store.CreateOrderDetail();
        int teamid=0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            order = session.Orders.GetByID(orderid);
        }
      
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            user = session.Users.GetByID(userid);
        }
        
        flow.User_id = userid;

        if (order!= null)
        {
            if (orderid != 0)
            {
                flow.Detail_id = order.Pay_id;
            }
            else
            {
                flow.Detail_id = "0";
            }
        }

        flow.Direction = Direction;
        flow.Money = money;
        flow.Action = action;  //动作为buy购买
        if (pay_time.HasValue) flow.Create_time = pay_time.Value;
        else
            flow.Create_time = DateTime.Now;
        flow.Admin_id = adminid;//管理员

        if (orderid != 0) //判断此订单号是不是充值的订单号，如果是那么不执行下面的操作
        {
            if (user != null)
            {
                if (user.Newbie != "C")
                { 
                    newuser.Id = userid;
                    newuser.Newbie = "Y";
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        session.Users.UpdateNewBie(newuser);
                    }
                }
            }
            if (Getinvite(userid))//此用户是否邀请了别人  :查询此用户是否被邀请
            {
                invite = GetByfrom(userid);  //根据Other_user_id查询出邀【主动邀请人】在邀请表【invite】中的信息

                //同时修改邀请表中的信息，Other_user_id ，被邀请人下订单购买成功，那么邀请表中【invite】中字段Pay 修改为'N'
                //邀请表中的Pay  ‘Y’已返利，‘N’未返利，‘C’违规记录

                //查询已购买，条件，Pay='N' and Buy_time != '

                IUser users = Store.CreateUser();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    users = session.Users.GetByID(userid);
                }
                if(users !=null)
                {
                if (users.Newbie == "Y")//判断被邀请人是否第一次购买项目
                {
                    newinvite.Pay = "Y";
                    if (order != null)
                    {
                        if (invite != null)
                        {
                            if (invite.Team_id == 0)
                            {
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    teamid = session.OrderDetail.GetByOrderid_team(order.Id);
                                }

                                newinvite.Team_id = teamid;

                            }
                            else
                            {
                                newinvite.Team_id = order.Team_id;
                            }
                        }
                    }

                    newinvite.Buy_time = DateTime.Now; //被邀请人下订单的时间

                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        session.Invite.UpdatePayTime(newinvite);
                    }

                    NameValueCollection configs = new NameValueCollection();
                    configs = WebUtils.GetSystem();
                    if (configs["invitescore"] != null && configs["invitescore"].ToString() != "" && configs["invitescore"].ToString() != "0")
                    {
                        
                        IUser b_user = Store.CreateUser();
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            b_user = session.Users.GetByID(int.Parse(CookieUtils.GetCookieValue("invitor")));
                        }

                        if (b_user != null)
                        {
                            UpdateScore(b_user.Id, b_user.userscore, int.Parse(configs["invitescore"].ToString()));

                            IScorelog scorelogs = Store.CreateScorelog();

                            scorelogs.action = "邀请好友";
                            scorelogs.score = int.Parse(WebUtils.config["invitescore"].ToString());
                            scorelogs.user_id = b_user.Id;
                            scorelogs.adminid = 0;
                            scorelogs.create_time = DateTime.Now;
                            scorelogs.key = "0";

                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                session.Scorelog.Insert(scorelogs);
                            }
                        }
                    }
                    CookieUtils.ClearCookie("invitor");

                }
            }


            }
        }

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            session.Flow.Insert(flow);
        }
    }
    //修改用户的积分
    /// <summary>
    /// 修改用户余额
    /// </summary>
    /// <param name="userid">ID</param>
    /// <param name="summoeny">积分</param>
    /// <param name="yumongy">+ -积分</param>
    public static void UpdateScore(int userid, int userscore, int score)
    {
        int result = userscore + score;
        if (result < 0)
        {
            result = 0;
        }
        IUser s_user = Store.CreateUser();
        
        s_user.userscore = result;
        s_user.Id = userid;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            session.Users.UpdateUserScore(s_user);
        }

    }


    //  查询此用户是否被邀请
    public static bool Getinvite(int userid)
    {
        bool falg = false;
        IInvite invite = Store.CreateInvite();

        invite = GetByfrom(userid);

        if (invite != null)
        {
            falg = true;
        }
        else
        {
            falg = false;
        }
        return falg;
    }

    /// <summary>
    /// 得到一个对象实体
    /// </summary>
    public static IInvite GetByfrom(int Other_user_id)
    {
        IInvite invite = Store.CreateInvite();

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            invite = session.Invite.GetByOther_Userid(Other_user_id);
        }

        if (invite != null)
        {

            return invite;
        }
        else
        {
            return null;
        }
    }

    public void Check(int orderid)
    {

        int oid = Helper.GetInt(Request["orderid"], 0);

        IOrder order = Store.CreateOrder();
        IUser user = Store.CreateUser();
        IPay pay = Store.CreatePay();
        UserFilter uf = new UserFilter();

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            order = session.Orders.GetByID(oid);
        }
        if (order != null)
        {
            if (order.State == "nocod")
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    user = session.Users.GetByID(order.User_id);
                }
                if (user != null)
                {
                    //促销活动返给用户金额，需记录
                    if (order.Parent_orderid == 0 && order.Returnmoney != 0)
                    {
                        user.Money += order.Returnmoney;
                    
                        AddFlow(user.Id, oid, "income", order.Returnmoney, "Feeding_amount", 0, dateTime, order.Pay_id, "");
                    }
                    //项目赠送积分
                    if (order.orderscore != 0)
                    {
                        user.userscore += order.orderscore;

                        Insert_scorelog(order.orderscore, "下单", oid.ToString(), 0, order.User_id);
                    }
                    //用户累计消费金额

                    user.totalamount += order.Origin - order.Fare;

                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        cnt = session.Users.UpdateMoney(user);
                    }
                    AddFlow(order.User_id, order.Id, "expense", decimal.Parse(order.Origin.ToString()), "buy", 0, dateTime, order.Pay_id, "cashondelivery");//记录用户消费记录

                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        pay = session.Pay.GetByID(order.Pay_id);
                    }

                    if (pay != null)
                    {
                        pay.Money += order.cashondelivery;
                        pay.Id = order.Pay_id;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                             session.Pay.Update(pay);
                        }
                    }
                    else
                    {
                        AddPay(orderid.ToString(), order.Pay_id, WebUtils.GetPayCnName(WebUtils.GetPayType(order.Service)), order.cashondelivery, "CNY", order.Service, DateTime.Now);//记录用户付款记录
                    }

                }
            }

        }

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            order.State = "pay";
            order.Pay_time = dateTime;
            order.Id = oid;
            if (order.Service == "cashondelivery")
            {
                user.Money = user.Money - order.Credit;
            }
            session.Users.Update(user);
            cnt = session.Orders.UpdatePayTime(order);
        }
        if (cnt > 0)
        {
            SetSuccess("确认成功");
        }
        else
        {
            SetError("确认失败");
        }

        string gourl = Request.Url.AbsoluteUri;
        if (Request.UrlReferrer != null)
            gourl = Request.UrlReferrer.AbsoluteUri;
        Response.Redirect(gourl);
        Response.End();
        return;
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <%if (strkey == "1")
                                      {%>
                                    <h2>
                                        已发货</h2>
                                    <%}
                                      else if (strkey == "2")
                                      { %>
                                    <h2>
                                        未发货</h2>
                                    <%}
                                      else if (strkey == "3")
                                      { %>
                                    <h2>
                                        已完成</h2>
                                    <%} %><form id="Form1" runat="server" method="get">
                                <div class="search">
                                    生成订单时间：<input type="text" style=" margin-right:0px;" class="h-input" datatype="date" name="begintime"
                                        <%if(!string.IsNullOrEmpty(Request.QueryString["begintime"])){ %>value="<%=Request.QueryString["begintime"] %>"
                                        <%} %> />--<input type="text" class="h-input" datatype="date" name="endtime" <%if(!string.IsNullOrEmpty(Request.QueryString["endtime"])){ %>value="<%=Request.QueryString["endtime"] %>"
                                            <%} %> />&nbsp;&nbsp; 完成订单时间：<input type="text" style=" margin-right:0px;" class="h-input" datatype="date" name="fromfinishtime"
                                                <%if(!string.IsNullOrEmpty(Request.QueryString["fromfinishtime"])){ %>value="<%=Request.QueryString["fromfinishtime"] %>"
                                                <%} %> />--<input type="text" class="h-input" datatype="date" name="endfinishtime"
                                                    <%if(!string.IsNullOrEmpty(Request.QueryString["endfinishtime"])){ %>value="<%=Request.QueryString["endfinishtime"] %>"
                                                    <%} %> />&nbsp;&nbsp; 筛选条件：<select name="select_type">
                                                        <option value="">全部</option>
                                                        <option value="1" <%if(Request.QueryString["select_type"] == "1"){ %>selected="selected"
                                                            <%} %>>用户名</option>
                                                        <option value="2" <%if(Request.QueryString["select_type"] == "2"){ %>selected="selected"
                                                            <%} %>>Email</option>
                                                        <option value="4" <%if(Request.QueryString["select_type"] == "4"){ %>selected="selected"
                                                            <%} %>>订单编号</option>
                                                        <option value="8" <%if(Request.QueryString["select_type"] == "8"){ %>selected="selected"
                                                            <%} %>>项目ID</option>
                                                        <option value="16" <%if(Request.QueryString["select_type"] == "16"){ %>selected="selected"
                                                            <%} %>>交易单号</option>
                                                        <option value="32" <%if(Request.QueryString["select_type"] == "32"){ %>selected="selected"
                                                            <%} %>>快递单号</option>
                                                        <option value="64" <%if(Request.QueryString["select_type"] == "64"){ %>selected="selected"
                                                            <%} %>>手机号</option>
                                                        <option value="128" <%if(Request.QueryString["select_type"] == "128"){ %>selected="selected"
                                                            <%} %>>收货人</option>
                                                        <option value="256" <%if(Request.QueryString["select_type"] == "256"){ %>selected="selected"
                                                            <%} %>>派送地址</option>
                                                    </select>&nbsp;&nbsp; 内容：<input type="text" style="width: 120px;" name="type_name" class="h-input"
                                                        <%if(!string.IsNullOrEmpty(Request.QueryString["type_name"])){ %>value="<%=Request.QueryString["type_name"] %>"
                                                        <%} %> />&nbsp;&nbsp;
                                    <input type="submit" value="查询" class="formbutton" /></div>
                                </form>
                                </div>
                                
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='10%'>
                                                ID
                                            </th>
                                            <th width='17%'>
                                                项目
                                            </th>
                                            <th width='8%'>
                                                用户
                                            </th>
                                            <th width='5%'>
                                                数量
                                            </th>
                                            <th width='10%'>
                                                总款
                                            </th>
                                            <th width='10%'>
                                                余付
                                            </th>
                                            <th width='10%'>
                                                货到付款
                                            </th>
                                            <th width='10%'>
                                                付款状态
                                            </th>
                                            <th width='10%'>
                                                递送方式
                                            </th>
                                            <th width='10%'>
                                                操作
                                            </th>
                                        </tr>
                                        <% 
                                            IUser user = Store.CreateUser();
                                            ITeam team = Store.CreateTeam();
                                            IList<ITeam> teamlist = null;
                                            IList<IOrderDetail> orderlist = null;
                                            int i = 0;

                                            if (list_order != null && list_order.Count > 0)
                                            {
                                                foreach (IOrder order in list_order)
                                                {
                                                    user = order.User;
                                                    team = order.Team;
                                                    if (i % 2 != 0)
                                                    {%>
                                        <tr>
                                            <% }
                                                    else
                                                    { %>
                                        <tr class='alt'>
                                            <% 
}
                                                    i++;
                                            %>
                                            <td>
                                                <%=order.Id%>
                                            </td>
                                            <td>
                                                <% 
                                                    if (order.Team_id == 0)
                                                    {
                                                        teamlist = order.Teams;
                                                        orderlist = order.OrderDetail;
                                                        foreach (IOrderDetail teams in order.OrderDetail)
                                                        {%>
                                                项目ID:<%=teams.Teamid%>
                                                (<a class="deal-title" href='<%=getTeamPageUrl(teams.Teamid)%>' target="_blank"><%=StringUtils.SubString(teams.Team.Title, 70) + "..."%>
                                                </a>)<%=StringUtils.SubString(AS.Common.Utils.WebUtils.Getbulletin(teams.result), 0, "<br>")%>
                                                <%
                                                    }
                                                    }
                                                    else
                                                    { %>
                                                项目ID:<%=order.Team_id%>
                                                <%if (team != null)
                                                  { %>
                                                (<a class="deal-title" href='<%=getTeamPageUrl(order.Team_id)%>' target="_blank"><%=StringUtils.SubString(team.Title, 70) + "..."%>
                                                </a>)
                                                <% 
}
}
                                                    if (order.result != null)
                                                        StringUtils.SubString(AS.Common.Utils.WebUtils.Getbulletin(order.result), 0, "<br>");
                                                    if (order.Parent_orderid != null && order.Parent_orderid != 0)
                                                    {%>
                                                <br>
                                                <font style="color: #0D6D00; font-weight: bold;">该订单父ID:<% =order.Parent_orderid%></font>
                                                <%} %>
                                            </td>
                                            <%if (user != null) %>
                                            <td>
                                                <a class="ajaxlink" href='ajax_manage.aspx?action=userview&Id=<%=order.User_id %>'>
                                                    <%=user.Email%>
                                                    <br>
                                                    <%=user.Username%></a>&nbsp;»&nbsp;<a class="ajaxlink" href='ajax_manage.aspx?action=sms&v=<%=user.Mobile %>'>短信</a>
                                            </td>
                                            <td>
                                                <%=order.Quantity%>
                                            </td>
                                            <td>
                                                <%=order.Origin%>
                                            </td>
                                            <td>
                                                <%=order.Credit%>
                                            </td>
                                            <td>
                                                <%=order.cashondelivery %>
                                            </td>
                                            <td>
                                                货到付款
                                            </td>
                                            <td>
                                                <%=GetOrderExpress(order) %>
                                            </td>

                                            
                                           
                                            <% 
                                                if (order.State == "pay" || order.State == "nocod")
                                                {%>
                                            <td class="op">

                                                <a class="ajaxlink" href='ajax_manage.aspx?action=orderview&orderview=<%=order.Id%>'>
                                                    详情</a>
                                                     <%if (strkey == "1")
                                              { 
                                            %>
                                            | <a href="DingDan_CashState.aspx?action=cashondelivery&orderid=<%=order.Id %>">确认</a>
                                            <%} %>

                                            </td>
                                            <% 
                                                }
                                                else if (order.State == "cancel")
                                                {%>
                                            <td class="op">
                                                <a class="deal-title" href='DingDan_CashState.aspx?delete=<%=order.Id  %>' ask="确定删除本单吗？">
                                                    删除</a>｜<a class="ajaxlink" href='ajax_manage.aspx?action=orderview&orderview=<%= order.Id %>'>详情</a>
                                            </td>
                                            <%  }
                                                else if (order.State == "unpay")
                                                {%>
                                            <td class="op">
                                                <a class="deal-title" href='Dingdan_DangqiDingdan.aspx?id=<%=order.Id %>' ask="确定本单为现金付款?">
                                                    现金</a>｜<a class="deal-title" href='DingDan_CashState.aspx?delete=<%=order.Id %>'
                                                        ask="确定删除本单吗？">删除</a>｜<a class="ajaxlink" href='ajax_manage.aspx?action=orderview&orderview=<%=order.Id %>'>详情</a>
                                            </td>
                                            <%   }
                                                else if (order.State == "refund")
                                                {%>
                                            <td class="op">
                                                <a class="ajaxlink" href='ajax_manage.aspx?action=orderview&type=refunding&orderview=<%= order.Id %>'>
                                                    详情</a>
                                            </td>
                                            <%  }%>
                                        </tr>
                                        <% }
                                            }
                                        %>
                                        <tr>
                                            <td colspan="10">
                                                <%=pagerHtml%>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
<%LoadUserControl("_footer.ascx", null); %>
