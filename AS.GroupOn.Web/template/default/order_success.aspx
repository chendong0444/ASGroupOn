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
    protected NameValueCollection configs = new NameValueCollection();
    public string teamid;//项目编号
    protected int type = 0;// 0付款失败 1 付款成功  2充值成功 3贝宝支付待审核状态
    public IOrder ordermodel = null;
    public IUser usermodel = null;
    public string splitorderid = String.Empty;
    public System.Data.DataTable dt = new System.Data.DataTable();
    public System.Data.DataSet ds = new System.Data.DataSet();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        NeedLogin();
        configs = PageValue.CurrentSystemConfig;
        string payid = Helper.GetString(Request["id"], String.Empty);
        string item_num = Helper.GetString(Request["paypalid"], String.Empty);
        string st = Helper.GetString(Request["st"], String.Empty);
        if (item_num != "")
        {
            payid = item_num;
        }
        if (payid != String.Empty)
        {
            IPay paymodel = null;
            using (IDataSession session = Store.OpenSession(false))
            {
                paymodel = session.Pay.GetByID(payid);
            }
            if (paymodel != null)
            {
                if (paymodel.Order_id > 0)
                {
                    hidorderid.Value = paymodel.Order_id.ToString();
                    //传递订单号
                    Getorder(paymodel.Id.ToString());
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        ordermodel = session.Orders.GetByID(Helper.GetInt(paymodel.Order_id, 0));
                    }
                    if (ordermodel != null)
                    {
                        usermodel = ordermodel.User;
                        SplitOrder(ordermodel.Id, ordermodel.CashParent_orderid);
                    }
                    type = 1;
                    if (ordermodel.State == "scorepay" && !string.IsNullOrEmpty(CookieUtils.GetCookieValue("invitor")) && string.IsNullOrEmpty(CookieUtils.GetCookieValue("invitorNum")))
                    {
                        int uid = Helper.GetInt(CookieUtils.GetCookieValue("invitor"), 0);
                        if (usermodel != null)
                        {
                            int invitescore = Helper.GetInt(configs["invitescore"], 0);
                            OrderMethod.UpdateScore(usermodel.Id, usermodel.userscore, invitescore);
                            //设置只能一次返积分，再次购买则不会返积分。
                            CookieUtils.SetCookie("invitorNum", "1");
                        }
                    }
                    CookieCar.ClearCar();
                }
                else
                {
                    type = 2;
                    string pid = paymodel.Id;
                    string userid = string.Empty;
                    if (Regex.IsMatch(pid, @"0as(\d+)as.+"))
                    {
                        userid = Regex.Match(pid, @"0as(\d+)as.+").Groups[1].Value;
                    }
                    int uid = Helper.GetInt(userid, 0);
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        usermodel = session.Users.GetByID(uid);
                    }
                    if (usermodel != null && string.IsNullOrEmpty(CookieUtils.GetCookieValue("chargescore")))
                    {
                        int chargescore = Helper.GetInt(configs["chargescore"], 0);
                        OrderMethod.UpdateScore(usermodel.Id, usermodel.userscore, chargescore);
                        //设置只能一次返积分，再次购买则不会返积分。
                        CookieUtils.SetCookie("chargescore", "1");
                    }
                }
            }
            else
            {
                OrderFilter of = new OrderFilter();
                of.Pay_id = payid;
                IList<IOrder> list = null;
                using (IDataSession session = Store.OpenSession(false))
                {
                    list = session.Orders.GetList(of);
                }
                if (list != null && list.Count > 0)
                {
                    if (list[0].Service == "cashondelivery" && list[0].State == "nocod")
                    {
                        int orderid = Helper.GetInt(list[0].Id, 0);
                        int cashorderid = Helper.GetInt(list[0].CashParent_orderid, 0);
                        SplitOrder(orderid, cashorderid);
                        Getorder(payid);
                        type = 3;
                    }
                }
            }
        }
        if (type == 0)
        {
            PageValue.Meta = "<META HTTP-EQUIV=\"Refresh\" content=\"20\">";
        }
        else
        {
            PageValue.Meta = String.Empty;
        }
    }
    public void SplitOrder(int orderid, int cashorderid)
    {
        IOrder ordermodel = null;
        OrderFilter of = new OrderFilter();
        IList<IOrder> list = null;
        using (IDataSession sesion = Store.OpenSession(false))
        {
            ordermodel = sesion.Orders.GetByID(orderid);
        }
        if (ordermodel != null)
        {
            if (ordermodel.CashParent_orderid != 0)
            {
                of.State = "unpay";
                of.Id = cashorderid;
                using (IDataSession session = Store.OpenSession(false))
                {
                    list = session.Orders.GetList(of);
                }
            }
            else
            {
                of.CashParent_orderid = orderid;
                of.State = "unpay";
                using (IDataSession session = Store.OpenSession(false))
                {
                    list = session.Orders.GetList(of);
                }
            }
            if (list != null && list.Count > 0)
            {
                splitorderid = list[0].Id.ToString();
            }
        }
    }
    //获取订单编号
    public void Getorder(string orderid)
    {
        using (IDataSession session = Store.OpenSession(false))
        {
            usermodel = session.Users.GetbyUName(UserName);
        }
        OrderFilter of = new OrderFilter();
        IList<IOrder> list = null;
        of.Pay_id = orderid;
        using (IDataSession session = Store.OpenSession(false))
        {
            list = session.Orders.GetList(of);
        }
        ds = Helper.ToDataSet(list.ToList());
        dt.Columns.Add("TeamId");
        dt.Columns.Add("Id");
        for (int j = 0; j < ds.Tables[0].Rows.Count; j++)
        {
            using (IDataSession session = Store.OpenSession(false))
            {
                ordermodel = session.Orders.GetByID(Helper.GetInt(ds.Tables[0].Rows[j]["Id"], 0));
            }
            CPS(ordermodel);
            //添加TeamId和Id到dt中
            System.Data.DataRow dr = dt.NewRow();
            dr["TeamId"] = ordermodel.teamid.ToString();
            dr["Id"] = ordermodel.Id;
            dt.Rows.Add(dr);
        }
    }
    public virtual void CPS(IOrder ordermodel)
    {
        string cookieorderid = CookieUtils.GetCookieValue("returnorderid");
       
        //如果启用2345并且是2345一站通用户(可通过cookie是否存在2345_qid判断)则回传订单信息
        if (configs["is2345login"] == "1" && CookieUtils.GetCookieValue("2345_qid").Length > 0 && cookieorderid.IndexOf(ordermodel.Id.ToString()) < 0)
        {
            try
            {
                System.Net.WebClient wc = new System.Net.WebClient();
                NameValueCollection updata = new NameValueCollection();
                updata.Add("key", configs["login2345key"]);
                updata.Add("qid", CookieUtils.GetCookieValue("2345_qid"));
                updata.Add("order_id", ordermodel.Id.ToString());
                updata.Add("order_time", Helper.GetTimeFix(DateTime.Now).ToString());
                updata.Add("website", ASSystemArr["abbreviation"]);
                updata.Add("total_price", ordermodel.Origin.ToString());
                string goods_url = WWWprefix.Substring(0, WWWprefix.LastIndexOf("/")) + GetUrl("订单详情", "order_view.aspx?userid=" + AsUser.Id + "&id=" + ordermodel.Id);
                updata.Add("goods_url", goods_url);
                string title = String.Format("您在{0}的订单号{1}", ASSystem.abbreviation, ordermodel.Id);
                string desc = String.Format("您在{0}的订单号{1}", ASSystem.abbreviation, ordermodel.Id);
                List<Hashtable> hs = null;
                using (IDataSession session = Store.OpenSession(false))
                {
                    hs = session.Custom.Query("select top 1 num,end_time,Delivery,team_price,market_price,id,title,image,Expire_time from team inner join (select (isnull(teamid,0)+team_id) as teamid,isnull(num,quantity) as num from [order]  left join [orderdetail] on([order].id=[orderdetail].order_id) where [order].id=" + ordermodel.Id + ")t on(team.id=t.teamid)");
                }
                if (hs != null&&hs.Count>0)
                {
                    for (int i = 0; i < hs.Count; i++)
                    {
                        
                        title = title + "," + StringUtils.SubString(hs[i]["title"].ToString(), 30) + "......";
                        desc = desc + "," + StringUtils.SubString(hs[i]["title"].ToString(), 30) + "......";
                        updata.Add("proimg", WWWprefix.Substring(0, WWWprefix.Length - 1) + hs[i]["image"]);
                        if (hs[i]["Delivery"] == "coupon" && hs[i]["Expire_time"] != null)
                            updata.Add("spend_close_time", Helper.GetTimeFix(Helper.GetDateTime(hs[i]["Expire_time"].ToString(), DateTime.Now)).ToString());
                        else
                            updata.Add("spend_close_time", Helper.GetTimeFix(Helper.GetDateTime(hs[i]["end_time"].ToString(), DateTime.Now)).ToString());
                        updata.Add("pid", hs[i]["id"].ToString());
                        updata.Add("price", hs[i]["market_price"].ToString());
                        updata.Add("tprice", hs[i]["team_price"].ToString());
                        updata.Add("number", hs[i]["num"].ToString());
                        if (Helper.GetDecimal(hs[i]["market_price"], 0) == 0 || Helper.GetDecimal(hs[i]["team_price"], 0) == 0)
                        {
                            updata.Add("rebate", "0.000");
                        }
                        else
                        {
                            updata.Add("rebate", ((Helper.GetDecimal(hs[i]["team_price"], 0) / Helper.GetDecimal(hs[i]["market_price"], 0))).ToString("0.000"));
                        }
                    }
                }
                title = Server.UrlEncode(title);
                desc = Server.UrlEncode(desc);
                updata.Add("title", title);
                updata.Add("desc", desc);
                string temp_sign = Helper.MD5(String.Format("{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}|{9}|{10}|{11}|{12}|{13}|{14}|{15}", new object[] { updata["qid"], updata["order_id"], updata["order_time"], updata["pid"], updata["price"], updata["tprice"], updata["rebate"], updata["proimg"], updata["website"], updata["number"], updata["total_price"], goods_url, title, updata["spend_close_time"], configs["login2345key"], configs["login2345secret"] }));
                updata.Add("sign", temp_sign);
                byte[] temp_result = wc.UploadValues("http://api.tuan.2345.com/api/deal.php", "POST", updata);
                string temp_result_string = System.Text.Encoding.UTF8.GetString(temp_result);
            }
            catch (Exception ex){}
        }
        try
        {
            if (CookieUtils.GetCookieValue("returnorderid").IndexOf(ordermodel.Id.ToString()) < 0)
                CookieUtils.GetCookieValue("returnorderid", CookieUtils.GetCookieValue("returnorderid") + "," + ordermodel.Id);
        }
        catch { };
       
        //如果启用360并且是360一站通用户(可通过cookie是否存在360_uid判断)则回传订单信息
        if (configs["is360login"] == "1" && CookieUtils.GetCookieValue("360_qid").Length > 0 && cookieorderid.IndexOf(ordermodel.Id.ToString()) < 0)
        {
            try
            {
                System.Net.WebClient wc = new System.Net.WebClient();
                NameValueCollection updata = new NameValueCollection();
                updata.Add("key", configs["login360key"]);
                updata.Add("qid", CookieUtils.GetCookieValue("360_qid"));
                updata.Add("order_id", ordermodel.Id.ToString());
                updata.Add("order_time", ordermodel.Create_time.ToString("yyyyMMddHHmmss"));
                updata.Add("total_price", ordermodel.Origin.ToString());
                List<Hashtable> hs = null;
                using (IDataSession session = Store.OpenSession(false))
                {
                    hs = session.Custom.Query("select title,teamid,num,teamprice,Delivery,Expire_time from team inner join (select (isnull(teamid,team_id)) as teamid,isnull(teamprice,price) as teamprice,isnull(num,quantity) as num from [order]  left join [orderdetail] on([order].id=[orderdetail].order_id) where [order].id=" + ordermodel.Id + ")t on(team.id=t.teamid)");
                }
                string goods_url = String.Empty;
                string temptitle = String.Empty;
                string merchant_addr = Server.UrlEncode(ASSystem.abbreviation);
                updata.Add("merchant_addr", merchant_addr);
                if (hs != null&&hs.Count>0)
                {
                    for (int i = 0; i < hs.Count; i++)
                    {
                        temptitle = Server.UrlEncode(StringUtils.SubString(hs[i]["title"].ToString(), 60, true));
                        goods_url = Server.UrlEncode(getTeamPageUrl(Helper.GetInt(hs[i]["teamid"].ToString().ToString(), 0)));
                        updata["pid"] = hs[i]["teamid"].ToString();
                        updata["number"] = hs[i]["num"].ToString();
                        updata["price"] = hs[i]["teamprice"].ToString();
                        updata["goods_url"] = goods_url;
                        if (hs[i]["Delivery"] == "coupon" && hs[i]["Expire_time"] != null)
                            updata["spend_close_time"] = Helper.GetDateTime(hs[i]["Expire_time"],DateTime.Now).ToString("yyyyMMddHHmmss");
                        else
                            updata["spend_close_time"] = String.Empty;
                        updata["title"] = temptitle;
                        updata["desc"] = temptitle;
                        string temp_sign = Helper.MD5(String.Format("{0}|{1}|{2}|{3}|{4}|{5}|{6}|{7}|{8}|{9}|{10}|{11}|{12}|{13}", new object[] { updata["key"], updata["qid"], updata["order_id"], updata["order_time"], updata["pid"], updata["price"], updata["number"], updata["total_price"], goods_url, temptitle, temptitle, updata["spend_close_time"], merchant_addr, configs["login360secret"] }));
                        updata["sign"] = temp_sign;
                        byte[] temp_result = wc.UploadValues("http://tuan.360.cn/api/deal.php", "POST", updata);
                        string temp_result_string = System.Text.Encoding.UTF8.GetString(temp_result);

                    }
                }
            }
            catch (Exception ex){ }
        }
        //百度回传订单信息
        try
        {
            //给hao123回传订单信息
            if (ordermodel != null)
            {
                if (((ordermodel.fromdomain == "来自百度一站通") || Request.Cookies["baidu"] != null) && configs["isbaidulogin"] == "1" && ordermodel.fromdomain != "百度cps")
                {
                    string version = "2.0";
                    if (version == "2.0")
                    {
                        string url = "https://openapi.baidu.com/rest/2.0/hao123/saveOrder";
                        List<Hashtable> hs = null;
                        using (IDataSession session = Store.OpenSession(false))
                        {
                            hs = session.Custom.Query("select  orderprice,num,end_time,Delivery,team_price,market_price,id,Product,image,Expire_time from team inner join (select (isnull(teamid,0)+team_id) as teamid,isnull(num,quantity) as num,(Origin-fare)as orderprice from [order]  left join [orderdetail] on([order].id=[orderdetail].order_id) where [order].id=" + ordermodel.Id + ")t on(team.id=t.teamid)");
                        }

                        string title = "订单-" + ordermodel.Id + "," + hs[0]["product"] + "等";
                        string logo = WebUtils.GetRealTeamImageUrl(hs[0]["image"].ToString());
                        string prourl = WWWprefix + getTeamPageUrl(Helper.GetInt(hs[0]["id"].ToString(), 0));
                        string orderprice = (Helper.GetDecimal(hs[0]["orderprice"], 0) * 100).ToString("0");
                        if (hs[0]["Delivery"] == "express")
                        {
                            title = "订单-" + ordermodel.Id + "," + hs[0]["product"];
                        }
                        ArrayList list = new ArrayList();
                        NameValueCollection values = new NameValueCollection();
                        if (CookieUtils.GetCookieValue("oauth_token").Length > 0)
                        {
                            list.Add("access_token=" + CookieUtils.GetCookieValue("oauth_token"));
                            System.Net.WebClient client = new System.Net.WebClient();
                            string result = client.DownloadString("https://openapi.baidu.com/rest/2.0/passport/users/getInfo?access_token=" + CookieUtils.GetCookieValue("oauth_token"));
                            System.Collections.Generic.Dictionary<string, object> jsondata =
                            JsonUtils.JsonToObject(result);
                            list.Add("uid=" + jsondata["userid"].ToString());
                            values.Add("uid", jsondata["userid"].ToString());
                            url = url + "?access_token=" + CookieUtils.GetCookieValue("oauth_token");
                        }
                        else
                        {
                            HttpCookie cookie = Request.Cookies["baidu"];
                            if (cookie != null)
                            {
                                System.Net.WebClient gettoken = new System.Net.WebClient();
                                string result = gettoken.DownloadString("https://openapi.baidu.com/oauth/2.0/token?grant_type=client_credentials&client_id=" + configs["baidukey"] + "&client_secret=" + configs["baidusecret"]);
                                System.Collections.Generic.Dictionary<string, object> jsondata = JsonUtils.JsonToObject(result);
                                url = url + "?access_token=" + jsondata["access_token"].ToString();
                                list.Add("access_token=" + jsondata["access_token"].ToString());
                                list.Add("baiduid=" + cookie.Values["baiduid"]);
                                values.Add("baiduid", cookie.Values["baiduid"]);
                                list.Add("tn=" + cookie.Values["tn"]);
                                values.Add("tn", cookie.Values["tn"]);
                            }
                        }
                        values.Add("order_id", ordermodel.Id.ToString());
                        list.Add("order_id=" + ordermodel.Id);
                        values.Add("title", title);
                        list.Add("title=" + title);
                        values.Add("logo", logo);
                        list.Add("logo=" + logo);
                        values.Add("url", prourl);
                        list.Add("url=" + prourl);
                        values.Add("price", orderprice);
                        list.Add("price=" + orderprice);
                        values.Add("goods_num", "1");
                        list.Add("goods_num=1");
                        values.Add("sum_price", orderprice);
                        list.Add("sum_price=" + orderprice);
                        values.Add("summary", "订单" + ordermodel.Id);
                        list.Add("summary=订单" + ordermodel.Id);
                        values.Add("expire", "0");
                        list.Add("expire=0");
                        values.Add("addr", "");
                        list.Add("addr=");
                        values.Add("bonus", "0");
                        list.Add("bonus=0");
                        list.Sort();
                        string sign = String.Empty;
                        for (int i = 0; i < list.Count; i++)
                        {
                            sign = sign + list[i];
                        }
                        sign = sign + configs["baidusecret"];
                        sign = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(sign, "md5").ToLower();
                        values.Add("bd_sig", sign);
                        System.Net.WebClient wc = new System.Net.WebClient();
                        byte[] data = wc.UploadValues(url, "POST", values);
                        string dataval = Encoding.UTF8.GetString(data);
                        if (dataval.IndexOf("success") < 0)
                            WebUtils.LogWrite("百度回传订单信息", dataval);
                        else
                        {
                            ordermodel.fromdomain = "百度cps";
                            using (IDataSession session = Store.OpenSession(false))
                            {
                                session.Orders.Update(ordermodel);
                            }
                        }
                    }
                }
            }
        }
        catch (Exception ex) { WebUtils.LogWrite("百度回传订单信息1", ex.Message); }
    }
    public string GetTeam(string id, int orderid)
    {
        string str = "";
        ITeam teamodel = null;
        IOrder ordermodel = null;
        IList<IOrderDetail> detaillist = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            teamodel = session.Teams.GetByID(Helper.GetInt(id, 0));
            ordermodel = session.Orders.GetByID(Helper.GetInt(orderid, 0));
        }
        if (teamodel != null)
        {
            str = "<a href='" + getTeamPageUrl(Helper.GetInt(teamodel.Id.ToString(), 0)) + "'>" + teamodel.Title + "</a>";
        }
        else
        {
            if (ordermodel != null)
            {
                detaillist = ordermodel.OrderDetail;
            }
            if (detaillist != null)
            {
                int num = 0;
                foreach (var model in detaillist)
                {
                    ITeam detailteam = null;
                    num++;
                    str += "<a href='" + getTeamPageUrl(Helper.GetInt(model.Teamid.ToString(), 0)) + "'>" + num + ":";
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        detailteam = session.Teams.GetByID(model.Teamid);
                    }
                    str += detailteam == null ? "" : detailteam.Title;
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
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta name="keywords" content="<%=PageValue.KeyWord %>"/>
<meta name="description" content="<%=PageValue.Description %>" />
<%=PageValue.Meta %>
<script type='text/javascript' src="<%=PageValue.WebRoot %>upfile/js/index.js"></script>
<script type="text/javascript" src="<%=PageValue.WebRoot %>upfile/js/srolltop.js"></script>
<%if (IsTotw)
  {%>
<script>totw = true;</script>
<script type='text/javascript' src="<%=PageValue.WebRoot %>upfile/js/zhtotw.js"></script>
<%}
  else
  {%>
<script>    totw = false;</script>
  <%} %>
<script type='text/javascript'>    webroot = '<%=PageValue.WebRoot %>'; LOGINUID = '<%=AsUser.Id %>';</script>
<link rel="stylesheet" href="<%=PageValue.CssPath %>/css/index.css" type="text/css" media="screen" charset="utf-8" />
<title><%=PageValue.Title%></title>
</head>
<body class="newbie">
<div id="pagemasker"></div>
<div id="dialog"></div>
<div id="doc">
<%LoadUserControl("_header.ascx", null); %>
<form id="form1" runat="server">
    <asp:hiddenfield id="hidorderid" runat="server" />
    <div id="bdw" class="bdw">
        <div id="bd" class="cf">
            <div id="content">
                <div id="order-pay-return" class="box">
                    <div class="box-content">
                        <%if (type == 0)
                          {
                        %>
                        <div class="error">
                            付款失败！失败原因可能如下：<br />
                            1.如果您在网银已支付成功，等待20秒钟。页面将自动刷新。<br />
                            2.如果刷新后仍未提示支付成功，请联系客服人员<br />
                        </div>
                        <%
                          }
                          else if (type == 1 || type == 3)
                          { 
                        %>
                        <div class="success">
                            <h2>
                                <%if (type == 1)
                                  { %>
                                您的订单，支付成功了！
                                <p class="just-pay">
                                    <%if (splitorderid != null && splitorderid != "")
                                      {%>
                                    <span style="color: red;">您还有一个订单未支付(订单号:<%=splitorderid %>),<a href="<%=GetUrl("购物车订单", "shopcart_confirmation.aspx?orderid="+splitorderid)%>"><img src="<%=ImagePath()%>pay-go-now.gif" /></a></span>
                                    <%} %>
                                </p>
                                <%} %>
                                <%if (type == 3)
                                  { %>
                                您的订单，确认成功了！
                                <p class="just-pay">
                                    <%if (splitorderid != null && splitorderid != "")
                                      {%>
                                    <span style="color: red;">您还有一个订单未支付(订单号:<%=splitorderid %>),<a href="<%=GetUrl("购物车订单", "shopcart_confirmation.aspx?orderid="+splitorderid)%>"><img src="<%=ImagePath()%>pay-order.gif" /></a></span>
                                    <%} %>
                                </p>
                                <%} %>
                            </h2>
                        </div>
                        <div class="sect">
                            <%if (ds.Tables[0].Rows.Count > 1)
                              { %>
                            <div class="head">
                                <h2>您购买的项目属于不同商家，您的订单已被拆分为</h2>
                            </div>
                            <%for (int i = 0; i < dt.Rows.Count; i++)
                              {
                                  if ((i + 1) % 2 == 0)
                                  { %>
                            <div class="order-success" id="order-success-bg">
                                <p style="font-size: 14px;">
                                    <strong><a href="<%=GetUrl("订单详情","order_view.aspx?id="+int.Parse(dt.Rows[i]["Id"].ToString())) %>">订单ID：<%=int.Parse(dt.Rows[i]["Id"].ToString()) %></a></strong>
                                </p>
                                <%=GetTeam(dt.Rows[i]["TeamId"].ToString(), int.Parse(dt.Rows[i]["Id"].ToString()))%>&nbsp;&nbsp;
                            </div>
                            <% }
                                  else
                                  { %>
                            <div class="order-success">
                                <p style="font-size: 14px;">
                                    <strong><a href="<%=GetUrl("订单详情","order_view.aspx?id="+int.Parse(dt.Rows[i]["Id"].ToString())) %>">订单ID：<%=int.Parse(dt.Rows[i]["Id"].ToString()) %></a></strong>
                                </p>
                                <%=GetTeam(dt.Rows[i]["TeamId"].ToString(), int.Parse(dt.Rows[i]["Id"].ToString()))%>&nbsp;&nbsp;
                            </div>
                            <% }
                              }
                            %>
                            <%}
                              else
                              { %>
                            <div class="head">
                                <h2>查看所购项目</h2>
                            </div>
                            <%for (int i = 0; i < dt.Rows.Count; i++)
                              {%>
                            <div class="order-success">
                                <p style="font-size: 14px;">
                                    <strong><a href="<%=GetUrl("订单详情","order_view.aspx?id="+int.Parse(dt.Rows[i]["Id"].ToString())) %>">订单详情</a></strong>
                                </p>
                                <%=GetTeam(dt.Rows[i]["TeamId"].ToString(), int.Parse(dt.Rows[i]["Id"].ToString()))%>&nbsp;&nbsp;
                            </div>
                            <%
                              }
                              }
                            %>
                        </div>
                        <% }
                          else if (type == 2)
                          { %>
                        <div class="success">
                            <h2>充值成功</h2>
                        </div>
                        <% }%>
                    </div>
                </div>
            </div>
            <div id="side">
            </div>
        </div>
        <!-- bd end -->
    </div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
