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
    protected string str_Fare = "0";
    public string strOrigin = "";
    public string strDelivery = "";
    public string strExpress = "N";
    public string strPrice = "";
    public string strTitle = "";
    public string strQuantity = "1";
    public string strPer_number = "";
    public string strToTal = "";
    public string strMoney = "";
    protected int Farefree = 0;
    public string strFarefree = "";
    public IList<IOrder> orderlist = null;
    public ITeam teammodel = Store.CreateTeam();
    public NameValueCollection _system = new NameValueCollection();
    public IUser usermodel = null;
    protected bool payselectexpress = false;
    public string teamid = "";
    public string stradress = "";
    protected decimal totalprice = 0;//应付总额
    protected bool receiveVisble = false;
    protected bool orderemailvalidVisble = false;
    public int userid;
    protected string orderaddress = String.Empty;
    protected string result = "";
    protected decimal fare = 0;//应付运费
    protected string Quantity = "1";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        MobileNeedLogin();
        PageValue.WapBodyID = "buy";
        PageValue.Title = "下单";
        form.Action = GetUrl("手机版订单购买", "team_buy.aspx") + Request["id"];
        if (!Page.IsPostBack)
        {
            if (Request["id"] != null)
            {
                if (!NumberUtils.IsNum(Request["id"].ToString()))
                {
                    SetError("参数错误！");
                    Response.Redirect(GetUrl("手机版首页", "index.aspx"));
                    Response.End();
                    return;
                }
                using (IDataSession session = Store.OpenSession(false))
                {
                    teammodel = session.Teams.GetByID(Helper.GetInt(Request["id"], 0));
                }
                if (AsUser.Id != 0)
                {
                    Judge(Helper.GetInt((Request["id"].ToString()), 0));
                }
                initPage();
            }
        }
    }
    //判断如果项目之可以购买一次，并且，用户在项目下过成功订单，那么用户不可以购买此项目，
    public void Judge(int teamid)
    {
        OrderFilter of = new OrderFilter();
        of.User_id = AsUser.Id;
        of.Team_id = teamid;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            orderlist = session.Orders.GetList(of);
        }
        using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(teamid);
        }
        if (teammodel == null)
        {
            SetError("没有该项目");
            Response.Redirect(GetUrl("手机版首页", "index.aspx"));
            Response.End();
            return;
        }
        int buycount = 0;
        int orderid = 0;
        if (orderlist != null && orderlist.Count > 0)
        {
            for (int i = 0; i < orderlist.Count; i++)
            {
                if (orderlist[i].State == "unpay")
                {
                    orderid = orderlist[i].Id;
                    break;
                }
                else
                {
                    if (orderlist[i].State != "cancel")
                    {
                        buycount = buycount + 1;
                    }
                }
            }
        }
        if (teammodel.Buyonce == "Y")
        {
            if (buycount > 0)
            {
                SetError("您已经购买过此项目，当前项目只允许购买一次");
                Response.Redirect(GetUrl("手机版首页", "index.aspx"));
                Response.End();
                return;
            }
        }
    }
    //显示项目的信息
    private void initPage()
    {
        if (Request["id"] == null || Request["id"].ToString() == "")
        {
            SetError("参数错误！");
            Response.Redirect(GetUrl("手机版首页", "index.aspx"));
            Response.End();
            return;
        }
        else
        {
            teamid = Request["id"].ToString();
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(Helper.GetInt(teamid, 0));
        }
        if (teammodel == null)
        {
            SetError("没有该项目信息");
            Response.Redirect(GetUrl("手机版首页", "index.aspx"));
            Response.End();
            return;
        }
        AS.Enum.TeamState ts = GetState(teammodel);
        if (ts != AS.Enum.TeamState.begin && ts != AS.Enum.TeamState.successbuy)
        {
            SetError("该项目不能购买");
            Response.Redirect(GetUrl("手机版首页", "index.aspx"));
            Response.End();
            return;
        }
        strFarefree = teammodel.Farefree.ToString();
        Farefree = teammodel.Farefree;
        strDelivery = teammodel.Delivery;
        strPrice = teammodel.Team_price.ToString();
        if (teammodel.Delivery == "express")
        {
            fare = ActionHelper.System_GetFare(int.Parse(teamid), int.Parse(strQuantity), PageValue.CurrentSystemConfig, String.Empty, 0);
            totalprice = decimal.Parse(strQuantity) * decimal.Parse(strPrice.ToString());
            totalprice = fare + totalprice;
            Farefree = teammodel.Farefree;
        }
    }
    //提交按钮
    protected void submit_ServerClick(object sender, EventArgs e)
    {
        MobileNeedLogin();
        if (Helper.GetString(Request["id"], String.Empty) == String.Empty)
        {
            SetError("参数错误！");
            Response.Redirect(GetUrl("手机版首页", "index.aspx"));
            Response.End();
            return;
        }
        else
        {
            teamid = Request["id"].ToString();
        }
        string oldmobile = Helper.GetString(Request["oldmobile"], String.Empty);
        if (oldmobile != String.Empty && oldmobile.Trim() != AsUser.Mobile)
        {
            SetError("已绑定手机号输入错误，请重新输入");
            Response.Redirect(GetUrl("手机版订单购买", "team_buy.aspx") + Request["id"]);
            Response.End();
            return;
        }
        string newmobile = Helper.GetString(Request["newmobile"], String.Empty);
        if (newmobile != String.Empty && !StringUtils.ValidateString(newmobile, "mobile"))
        {
            SetError("手机号格式错误，请重新输入");
            Response.Redirect(GetUrl("手机版订单购买", "team_buy.aspx") + Request["id"]);
            Response.End();
            return;
        }
        //根据项目编号，查询项目的信息
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(int.Parse(teamid));
        }
        if (teammodel == null)
        {
            SetError("没有该项目信息！");
            Response.Redirect(GetUrl("手机版首页", "index.aspx"));
            Response.End();
            return;
        }
        else
        {
            strFarefree = teammodel.Farefree.ToString(); //项目表中的免单数量
            strDelivery = teammodel.Delivery;            //项目表中的快递方式
            strPrice = teammodel.Team_price.ToString();  //项目表中的团购价格
            str_Fare = teammodel.Fare.ToString();          //项目表中的快递费
            if (teammodel.Max_number != 0)
            {
                if (teammodel.Max_number - teammodel.Now_number < Convert.ToInt32(Request["num"]))
                {
                    SetError("您购买的数量已超过该项目的最高数量,您还能购买此项目" + (teammodel.Max_number - teammodel.Now_number).ToString() + "个！");
                    Response.Redirect(GetUrl("手机版订单购买", "team_buy.aspx") + Request["id"]);
                    Response.End();
                    return;
                }
            }
            if (teammodel.Delivery == "coupon")//优惠卷项目
            {
                if (Convert.ToInt32(Request["quantity"]) < 0)
                {
                    SetError("友情提示：请输入正确的数字");
                    Response.Redirect(GetUrl("手机版订单购买", "team_buy.aspx") + Request["id"]);
                    Response.End();
                    return;
                }
                Quantity = Request["quantity"].ToString();
                strExpress = "N";
                float iPTotal = int.Parse(Request["quantity"].ToString()) * float.Parse(teammodel.Team_price.ToString());
                strOrigin = iPTotal.ToString();
            }
            else if (teammodel.Delivery == "pcoupon")//商户优惠卷项目
            {
                if (Convert.ToInt32(Request["quantity"]) < 0)
                {
                    SetError("友情提示：请输入正确的数字");
                    Response.Redirect(GetUrl("手机版订单购买", "team_buy.aspx") + Request["id"]);
                    Response.End();
                    return;
                }
                Quantity = Request["quantity"].ToString();
                strExpress = "P";
                float iPTotal = int.Parse(Request["quantity"].ToString()) * float.Parse(teammodel.Team_price.ToString());
                strOrigin = iPTotal.ToString();
            }
            else if (teammodel.Delivery == "express")//快递项目
            {
                if (Helper.GetString(Request["county"], String.Empty) == String.Empty)
                {
                    SetError("友情提示：请选择城市");
                    Response.Redirect(GetUrl("手机版订单购买", "team_buy.aspx") + Request["id"]);
                    Response.End();
                    return;
                }
                if (Helper.GetString(Request["realname"],String.Empty) == String.Empty)
                {
                    SetError("友情提示：请填写收货人姓名");
                    Response.Redirect(GetUrl("手机版订单购买", "team_buy.aspx") + Request["id"]);
                    Response.End();
                    return;
                }
                if (Helper.GetString(Request["zipcode"], String.Empty) == String.Empty)
                {
                    SetError("友情提示：请填写邮政编码");
                    Response.Redirect(GetUrl("手机版订单购买", "team_buy.aspx") + Request["id"]);
                    Response.End();
                    return;
                }
                if (Helper.GetString(Request["address"], String.Empty) == String.Empty)
                {
                    SetError("友情提示：请填写地址");
                    Response.Redirect(GetUrl("手机版订单购买", "team_buy.aspx") + Request["id"]);
                    Response.End();
                    return;
                }
                string rulemoney = "0";
                float iPTotal = 0;
                //如果没有选择规格，
                if (teammodel.bulletin != null && Helper.GetString(Utility.Getbulletin(teammodel.bulletin), "") != "")
                {
                    string message = Checkbulletin(teammodel, Request["bulletin"]);
                    if (message != String.Empty)
                    {
                        SetError(message);
                        Response.Redirect(GetUrl("手机版订单购买", "team_buy.aspx") + Request["id"]);
                        Response.End();
                        return;
                    }
                    result = Server.UrlDecode(Request["bulletin"]).Replace(".", ",").Replace("-", "|");//写入规格
                    Quantity = Utility.Getnum(Server.UrlDecode(Request["bulletin"]).Replace(".", ",").Replace("-", "|")).ToString();
                    if (teammodel.invent_result != null && teammodel.invent_result.Contains("价格"))//存在多种价格
                    {
                        Quantity = "0";
                        int newnum = 0;
                        int sumnum = 0;
                        string price = "0";
                        string[] newrulemo = result.Replace("{", "").Replace("}", "").Replace(".", ",").Replace("-", "|").Split('|');
                        for (int j = 0; j < newrulemo.Length; j++)
                        {
                            //不同规格的数量
                            newnum = Convert.ToInt32(newrulemo[j].Substring(newrulemo[j].LastIndexOf(','), newrulemo[j].Length - newrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));
                            sumnum = sumnum + newnum;
                            //不同规格单价
                            price = Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, Server.UrlDecode(newrulemo[j]).Replace("-", "|").Replace(".", ","));
                            //总价
                            iPTotal = iPTotal + newnum * float.Parse(price);
                        }
                        Quantity = sumnum.ToString();
                    }
                    else
                    {
                        rulemoney = teammodel.Team_price.ToString();
                        iPTotal = int.Parse(Quantity) * float.Parse(rulemoney);
                    }
                }
                else
                {
                    Quantity = Request["quantity"].ToString();
                    iPTotal = int.Parse(Quantity) * float.Parse(teammodel.Team_price.ToString());
                }
                if (teammodel.freighttype > 0)//启用了运费模版
                {
                    string province = Helper.GetString(Request["province"], String.Empty);
                    string[] str = province.Split(',');
                    fare = ActionHelper.System_GetFare(int.Parse(teamid), int.Parse(Quantity), _system, Helper.GetString(str[1], String.Empty), Helper.GetInt(Request["express"], 0));//快递费
                }
                else
                {
                    fare = teammodel.Fare;
                }
                //计算项目表中的免单数量
                if (int.Parse(Quantity) < int.Parse(strFarefree)) //如果选取数量<免单数量，那么订单总额需要加上快递费
                {
                    strOrigin = (iPTotal + int.Parse(fare.ToString())).ToString("0.00");
                }
                else//如果选取数量>免单数量，那么订单总额就不需要加上快递费                                               
                {
                    if (Quantity == "1" && strFarefree != "1") //做这个判断是因为，页面初始化时，数量文本框默认为1，如果免单数量为0，根据判断，选取项目数量(1)>免单数量(0),那么订单总额就不需要加上快递费 ，逻辑有问题，在此判断一下
                    {
                        strOrigin = (iPTotal + int.Parse(fare.ToString())).ToString();
                    }
                    else
                    {
                        if (strFarefree == "0")
                        {
                            strOrigin = (iPTotal + int.Parse(fare.ToString())).ToString();
                        }
                        else
                        {
                            fare = 0;
                            strOrigin = iPTotal.ToString();
                        }
                    }
                }
                orderaddress = Helper.GetSubString(Request["county"] + "-" + Request["address"], 128);
                strExpress = "Y";
            }
            else if (teammodel.Delivery == "draw")//抽奖项目
            {
                if (Convert.ToInt32(Request["quantity"]) < 0)
                {
                    SetError("友情提示：请输入正确的数字");
                    Response.Redirect(GetUrl("手机版订单购买", "team_buy.aspx") + Request["id"]);
                    Response.End();
                    return;
                }
                Quantity = Request["quantity"].ToString();
                strExpress = "D";
                float iPTotal = int.Parse(Request["quantity"].ToString()) * float.Parse(teammodel.Team_price.ToString());
                strOrigin = iPTotal.ToString();
            }
            else
            {
                SetError("项目类型出现错误！");
                Response.Redirect(GetUrl("手机版首页", "index.aspx"));
                Response.End();
                return;
            }
            int orderid = Checkbuy(teammodel.Id);
            if (orderid != 0)
            {
                IOrder oldorder = null;
                using (IDataSession session = Store.OpenSession(false))
                {
                    oldorder = session.Orders.GetByID(orderid);
                }
                if (oldorder != null)
                {
                    if (newmobile != String.Empty)
                    {
                        oldorder.Mobile = newmobile;
                    }
                    else
                    {
                        oldorder.Mobile = AsUser.Mobile;
                    }
                    oldorder.Address = orderaddress;
                    oldorder.Express = strExpress;
                    oldorder.Price = decimal.Parse(strPrice);
                    oldorder.Origin = decimal.Parse(strOrigin);
                    oldorder.Fare = fare;
                    oldorder.Realname = Helper.GetString(Request["realname"], AsUser.Realname);
                    oldorder.Remark = Helper.GetString(Request["deliveryComment"], String.Empty);
                    oldorder.Zipcode = Helper.GetString(Request["zipcode"], AsUser.Zipcode);
                    oldorder.Partner_id = Helper.GetInt(teammodel.Partner_id, 0);
                    oldorder.Quantity = int.Parse(Quantity);
                    if (strExpress == "Y")
                    {
                        AsUser.Realname = Helper.GetString(Request["realname"], AsUser.Realname);
                        if (Helper.GetString(Request["address"], String.Empty) != String.Empty)
                        {
                            AsUser.Address = Request["address"];
                        }
                        if (Helper.GetString(Request["zipcode"], String.Empty) != String.Empty)
                        {
                            AsUser.Zipcode = Request["zipcode"];
                        }
                    }
                    AsUser.Mobile = oldorder.Mobile;
                    using (IDataSession session = Store.OpenSession(false))
                    {
                        session.Users.Update(AsUser);
                        session.Orders.Update(oldorder);
                    }
                    if (teammodel.Per_number != 0)
                    {
                        if (int.Parse(teammodel.Per_number.ToString()) < oldorder.Quantity)
                        {
                            SetError("每人限购数量" + teammodel.Per_number.ToString());
                            Response.Redirect(GetUrl("手机版订单购买", "team_buy.aspx") + Request["id"]);
                            Response.End();
                            return;
                        }
                    }
                    if (oldorder.OrderDetail != null && oldorder.OrderDetail.Count > 0)
                    {
                        IOrderDetail orderdemodel = null;
                        if (oldorder.OrderDetail.Count == 1)
                        {
                            orderdemodel = oldorder.OrderDetail[0];
                            if (orderdemodel != null)
                            {
                                orderdemodel.Teamprice = teammodel.Team_price;
                                orderdemodel.Num = int.Parse(Quantity);
                                orderdemodel.Teamid = teammodel.Id;
                                orderdemodel.Order_id = orderid;
                                orderdemodel.discount = 0;
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    session.OrderDetail.Update(orderdemodel);
                                }
                            }
                        }
                        else
                        {
                            foreach (var item in oldorder.OrderDetail)
                            {
                                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                {
                                    session.OrderDetail.Delete(item.id);
                                }
                            }
                            if (result != null && result != "")
                            {
                                orderdemodel = Store.CreateOrderDetail();
                                int newnum = 0;
                                string price = "0";
                                if (teammodel.invent_result != null && teammodel.invent_result.Contains("价格"))//存在多种价格
                                {
                                    string[] newrulemo = result.Replace("{", "").Replace("}", "").Replace(".", ",").Replace("-", "|").Split('|');
                                    for (int j = 0; j < newrulemo.Length; j++)
                                    {
                                        //不同规格单价
                                        price = Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, Server.UrlDecode(newrulemo[j]).Replace("-", "|").Replace(".", ","));
                                        orderdemodel.Teamprice = Convert.ToDecimal(price);
                                        //规格的数量
                                        newnum = Convert.ToInt32(newrulemo[j].Substring(newrulemo[j].LastIndexOf(','), newrulemo[j].Length - newrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));

                                        orderdemodel.Num = newnum;
                                        orderdemodel.result = newrulemo[j].ToString();
                                        orderdemodel.Teamid = teammodel.Id;
                                        orderdemodel.Order_id = orderid;
                                        orderdemodel.discount = 0;
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            session.OrderDetail.Insert(orderdemodel);
                                        }
                                    }
                                }
                                else
                                {
                                    orderdemodel.Teamprice = teammodel.Team_price;
                                    orderdemodel.Num = int.Parse(Quantity);
                                    orderdemodel.result = result;
                                    orderdemodel.Teamid = teammodel.Id;
                                    orderdemodel.Order_id = orderid;
                                    orderdemodel.discount = 0;
                                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                    {
                                        session.OrderDetail.Insert(orderdemodel);
                                    }
                                }
                            }
                        }
                    }
                    CreateOrderOK(orderid);
                    Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + orderid);
                    Response.End();
                    return;
                }
            }

            IOrder ordermodel = Store.CreateOrder();
            if (newmobile != String.Empty)
            {
                ordermodel.Mobile = newmobile;
            }
            else
            {
                ordermodel.Mobile = AsUser.Mobile;
            }
            ordermodel.Fare = fare;
            ordermodel.Quantity = int.Parse(Quantity);
            ordermodel.Create_time = DateTime.Now;
            ordermodel.Express = strExpress;
            ordermodel.Price = decimal.Parse(strPrice);
            ordermodel.Express_id = Helper.GetInt(Request.Form["express"], 0);
            ordermodel.Origin = decimal.Parse(strOrigin);
            ordermodel.Realname = Helper.GetString(Request["realname"], AsUser.Realname);
            ordermodel.Remark = Helper.GetString(Request["deliveryComment"], String.Empty);
            ordermodel.Zipcode = Helper.GetString(Request["zipcode"], AsUser.Zipcode);
            ordermodel.State = "unpay";
            ordermodel.Address = orderaddress;
            ordermodel.Team_id = int.Parse(teamid);
            ordermodel.Partner_id = Helper.GetInt(teammodel.Partner_id, 0);
            AddOrder(ordermodel);
        }
    }
    //判断是否之前购买过此项目,如果购买过返回订单ID
    public int Checkbuy(int teamid)
    {
        string sql = string.Format("select * from (select [Order].id, isnull(teamid,team_id) as teamid from [Order] left join [orderdetail] on([Order].Id=[orderdetail].Order_id) where [Order].state ='unpay' and [Order].user_id={0})t where t.teamid={1}", AsUser.Id, teamid);
        List<Hashtable> ht = new List<Hashtable>();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ht = session.Custom.Query(sql);
        }
        int orderid = 0;
        if (ht.Count > 0 && Helper.GetInt(ht[0]["id"].ToString(), 0) > 0)
        {
            orderid = Helper.GetInt(ht[0]["id"].ToString(), 0);
        }
        return orderid;
    }
    //写入order表中
    public virtual void AddOrder(IOrder model)
    {
        //创建订单
        IOrder ordermodel = Store.CreateOrder();
        if (model.Express == "Y")
        {
            ordermodel.Team_id = 0;
        }
        else
        {
            ordermodel.Team_id = model.Team_id;
        }
        ordermodel.Partner_id = model.Partner_id;
        ordermodel.Quantity = model.Quantity;
        ordermodel.Price = model.Price;
        ordermodel.Realname = model.Realname;
        ordermodel.Remark = model.Remark;
        ordermodel.User_id = AsUser.Id;
        ordermodel.Zipcode = model.Zipcode;
        ordermodel.Address = model.Address;
        ordermodel.State = "unpay";
        ordermodel.result = model.result;
        ordermodel.Express = model.Express;
        ordermodel.Express_id = model.Express_id;
        ordermodel.Create_time = DateTime.Now;
        ordermodel.Fare = model.Fare;
        if (CurrentCity != null && CurrentCity.Name != null)
            ordermodel.City_id = CurrentCity.Id;
        else
        {
            ordermodel.City_id = 0;
        }
        ordermodel.Mobile = model.Mobile;
        ordermodel.Origin = model.Origin;
        ordermodel.IP_Address = Helper.GetString(CookieUtils.GetCookieValue("gourl"), "手机端");
        ordermodel.fromdomain = CookieUtils.GetCookieValue("fromdomain");
        //用户信息更新
        if (model.Express == "Y")
        {
            AsUser.Realname = model.Realname;
            if (Helper.GetString(Request["address"],String.Empty)!=String.Empty)
            {
                AsUser.Address = Request["address"];
            }
            if (Helper.GetString(Request["zipcode"], String.Empty) != String.Empty)
            {
                AsUser.Zipcode = Request["zipcode"];
            }
        }
        AsUser.Mobile = model.Mobile;
        int orderid = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            session.Users.Update(AsUser);
            orderid = session.Orders.Insert(ordermodel);
        }
        if (orderid > 0)
        {
            if (model.Express == "Y")
            {
                IOrderDetail orderdemodel = Store.CreateOrderDetail();
                if (result != null && result != "")
                {
                    int newnum = 0;
                    string price = "0";
                    if (teammodel.invent_result != null && teammodel.invent_result.Contains("价格"))//存在多种价格
                    {
                        string[] newrulemo = result.Replace("{", "").Replace("}", "").Replace(".", ",").Replace("-", "|").Split('|');
                        for (int j = 0; j < newrulemo.Length; j++)
                        {
                            //不同规格单价
                            price = Utility.Getrulemoney(teammodel.Team_price.ToString(), teammodel.invent_result, Server.UrlDecode(newrulemo[j]).Replace("-", "|").Replace(".", ","));
                            orderdemodel.Teamprice = Convert.ToDecimal(price);
                            //规格的数量
                            newnum = Convert.ToInt32(newrulemo[j].Substring(newrulemo[j].LastIndexOf(','), newrulemo[j].Length - newrulemo[j].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", ""));

                            orderdemodel.Num = newnum;
                            orderdemodel.result = newrulemo[j].ToString();
                            orderdemodel.Teamid = teammodel.Id;
                            orderdemodel.Order_id = orderid;
                            orderdemodel.discount = 0;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                session.OrderDetail.Insert(orderdemodel);
                            }
                        }
                    }
                    else
                    {
                        orderdemodel.Teamprice = teammodel.Team_price;
                        orderdemodel.Num = ordermodel.Quantity;
                        orderdemodel.result = result;
                        orderdemodel.Teamid = teammodel.Id;
                        orderdemodel.Order_id = orderid;
                        orderdemodel.discount = 0;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            session.OrderDetail.Insert(orderdemodel);
                        }
                    }
                }
                else
                {
                    orderdemodel.Teamprice = teammodel.Team_price;
                    orderdemodel.Num = model.Quantity;
                    orderdemodel.Teamid = teammodel.Id;
                    orderdemodel.Order_id = orderid;
                    orderdemodel.discount = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        session.OrderDetail.Insert(orderdemodel);
                    }
                }
            }
            IOrder ordernew = null;
            using (IDataSession session = Store.OpenSession(false))
            {
                ordernew = session.Orders.GetByID(orderid);
            }
            if (ordernew != null)
            {
                ordernew.Pay_id = OrderMethod.Getorder(AsUser.Id, teammodel.Id, orderid);
            }
            using (IDataSession session = Store.OpenSession(false))
            {
                session.Orders.Update(ordernew);
            }
            CreateOrderOK(orderid);
            Response.Redirect(GetUrl("手机版订单确认", "order_check.aspx") + orderid);
            Response.End();
            return;
        }
    }
    /// <summary>
    /// 下单成功后执行的操作
    /// </summary>
    /// <param name="orderid"></param>
    public virtual void CreateOrderOK(int orderid)
    {

    }
    public static string Checkbulletin(ITeam teammodel, string result)
    {
        string message = String.Empty;
        bool invent = false;
        if (teammodel != null && teammodel.Delivery == "express")
        {
            bool isExistrule = false;
            if (teammodel.open_invent == 1)//开启库存
            {
                invent = Utility.isinvent(Helper.GetString(result, ""), Helper.GetString(teammodel.invent_result, ""));
                isExistrule = Utility.GetNewOld(result, teammodel.invent_result);
            }
            if (Utility.Getnum(result) <= 0)
            {
                message = "您的购买数量不能小于1";
            }
            else if (Utility.Getrule(result))
            {
                message = "您不可以选择一样的规格，请重新选择";
            }
            else if (isExistrule)
            {
                message = "您选择了此项目所没有的规格，请重新选择";
            }
            else if (invent)
            {
                message = "您购买的数量超过了库存数量，请减少一些";
            }
            else if (teammodel.teamcata == 0 && Utility.Getnum(result) > teammodel.Per_number && teammodel.Per_number > 0)
            {
                message = "您最多可以购买" + teammodel.Per_number + "个";
            }
            else if (Utility.Getnum(result) < teammodel.Per_minnumber && teammodel.Per_minnumber > 0)
            {
                message = "您最低必须购买" + teammodel.Per_minnumber + "个";
            }
        }
        else
        {
            message = "项目不存在";
        }
        return message;
    }
    public static string Getfont(int num, int teamid, int count, string oldresult)
    {
        string str = "";
        string bulletin = "";

        ITeam teammodel = Store.CreateTeam();
        string sum = "0";
        using (AS.GroupOn.DataAccess.IDataSession seion = Store.OpenSession(false))
        {
            teammodel = seion.Teams.GetByID(teamid);
        }
        if (teammodel != null)
        {
            bulletin = teammodel.bulletin;
            if (Utilys.Getbulletin(bulletin) != "")
            {
                string[] bulletinteam = bulletin.Replace("{", "").Replace("}", "").Split(',');
                string[] oldteam = oldresult.Replace("{", "").Replace("}", "").Split('|');

                int rows = 0; //规格行数初始数量
                if (oldresult == "")
                {
                    str += "<table id='tb" + num + "'>";
                    str += "<tr>";
                    str += " <td colspan='7' class='deal-buy-desc' id='rule" + num + "'>";

                    for (int i = 0; i < bulletinteam.Length; i++)
                    {
                        if (bulletinteam[i].Replace("[", "").Replace("]", "").Replace(":", "") != "")
                        {
                            str += "" + bulletinteam[i].Split(':')[0] + ":";
                            string[] bull = bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "").Split('|');
                            str += "<select name='rule" + num + "' rows='" + rows + "' onchange='checkintory(this)'>";
                            for (int j = 0; j < bull.Length; j++)
                            {
                                str += "<option value='" + bulletinteam[i].Split(':')[0] + ":" + bull[j] + "'>" + bull[j] + "</option>";
                            }
                            str += "</select>";
                        }
                    }
                    str += "数量:<input id='textfield' num_tid='" + teamid + "' rows='" + rows + "' name='num" + num + "' type='text'  value='" + count + "' pattern='[0-9]*' style='width: 28px;' />";
                    if (teammodel.invent_result != null && !teammodel.invent_result.Contains("价格"))
                    {
                        str += "<input type='button' name='button' id='button' rows='" + rows + "' value='其他规格' onclick=\"additem(this,'tb" + num + "','rule" + num + "','" + count + "',document.getElementById('textfield').value," + teamid + ")\" />";
                        str += "<input type='button' value='删除' onclick=\"deleteitem(this,'tb" + num + "'," + teamid + ",'" + count + "')\"/>";
                    }
                    str += "</td>";
                    str += "</tr>";
                    StringBuilder sb = new StringBuilder();
                    sb.Append("</table><script>var rows=" + rows + ";</");
                    sb.Append("script>");
                    str += sb.ToString();
                }
                else
                {
                    str += "<table id='tb" + num + "'>";
                    for (int i = 0; i < oldteam.Length; i++)
                    {
                        rows = rows + 1;
                        str += "<tr>";
                        str += " <td colspan='7' class='deal-buy-desc' id='rule" + num + "'>";
                        sum = oldteam[i].Substring(oldteam[i].LastIndexOf(','), oldteam[i].Length - oldteam[i].LastIndexOf(',')).Replace(",", "").Replace("数量", "").Replace(":", "").Replace("[", "").Replace("]", "");
                        for (int k = 0; k < bulletinteam.Length; k++)
                        {
                            str += "" + bulletinteam[k].Split(':')[0] + ":";
                            if (bulletinteam[k].Replace("[", "").Replace("]", "").Replace(":", "") != "")
                            {
                                string[] bull = bulletinteam[k].Split(':')[1].Replace("[", "").Replace("]", "").Split('|');
                                str += "<select name='rule" + num + "' onchange='checkintory(this)' rows='" + rows + "'>";
                                for (int h = 0; h < bull.Length; h++)
                                {
                                    string txt6 = oldteam[i];
                                    if (oldteam[i].Contains(bull[h]))
                                    {
                                        str += "<option value='" + bulletinteam[k].Split(':')[0] + ":" + bull[h] + "' selected='selected'>" + bull[h] + "</option>";
                                    }
                                    else
                                    {

                                        str += "<option value='" + bulletinteam[k].Split(':')[0] + ":" + bull[h] + "'>" + bull[h] + "</option>";
                                    }
                                }
                                str += "</select>";
                            }
                        }
                        str += "数量:<input id='textfield' num_tid='" + teamid + "' name='num" + num + "' rows='" + rows + "' type='text'  value='" + sum + "' pattern='[0-9]*' style='width: 28px;'/>";
                        if (teammodel.invent_result != null && !teammodel.invent_result.Contains("价格"))
                        {
                            str += "<input type='button' name='button' id='button1' value='其他规格' rows='" + rows + "' onclick=\"additem(this,'tb" + num + "','rule" + num + "','" + sum + "',document.getElementById('textfield').value," + teamid + ")\" /> ";
                            str += "<input type='button' value='删除' onclick=\"deleteitem(this,'tb" + num + "'," + teamid + ",'" + sum + "')\"/>";
                        }
                        str += "</td>";
                        StringBuilder sb = new StringBuilder();
                        sb.Append("</tr><script>var rows=" + rows + ";</");
                        sb.Append("script>");

                        str += sb.ToString();
                    }
                }
            }
        }
        return str;
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<%if (teammodel != null)
  {%>
<div class="body">
    <div class="errMsg" style="display: none;"></div>
    <form id="form" runat="server" autocomplete="off">
        <input type="hidden" name="county" id="county">
        <input type="hidden" name="bulletin" id="bulletin">
        <section class="common-items">
            <div class="common-item">
                <span class="item-label">项目：</span>
                <div class="item-content"><a href="<%=GetMobilePageUrl(teammodel.Id) %>"><%=teammodel.Product %></a></div>
            </div>
            <div class="common-item">
                <span class="item-label">单价：</span>
                <div class="item-content"><%=ASSystemArr["currency"] %> <%=GetMoney(teammodel.Team_price) %></div>
            </div>
            <% if (strDelivery == "express" && Farefree > 0)
               { %>
            <div class="common-item">
                <span class="item-label">运费：</span>
                <div class="item-content">
                    <%=ASSystemArr["currency"] %><%=fare %><%if (teammodel.Farefree > 0)
                                                             {%>（满<%=teammodel.Farefree%>件免运费）<%}%>
                </div>
            </div>
            <%} %>


            <%if (String.IsNullOrEmpty(teammodel.bulletin) || Utilys.Getbulletin(teammodel.bulletin) == "")
              {%>
            <div class="common-item">
                <span class="item-label">数量：</span>
                <div class="item-content quantity-box">
                    <div class="minus active">
                        <span>Ι</span>
                    </div>
                    <input type="text" min="<%=teammodel.Per_minnumber %>" <%if (teammodel.Per_number > 0)
                                                                             {%>
                        max="<%=teammodel.Per_number %>" <%}%> name="quantity" value="1" pattern="[0-9]*">
                    <div class="plus active">
                        <span>✚</span>
                    </div>
                </div>
            </div>
            <%}
              else
              { %>
            <div class="common-item">
                <span class="item-label">类型数量：</span>
            </div>
            <%=Getfont(0, teammodel.Id, 1,"") %>
            <%} %>
        </section>

        <%if (strDelivery == "express")
          {%>
        <div class="common-title">
            <h3>配送地址</h3>
        </div>
        <div class="common-items">
            <input type="hidden" name="addressid" value="">
            <div class="common-item">
                <span class="item-label">收货人：</span>
                <div class="item-content">
                    <input type="text" required="required" name="realname" class="" placeholder="收货人姓名" value="<%=AsUser.Realname%>">
                </div>
            </div>
            <div class="common-item">
                <span class="item-label">手机：</span>
                <div class="item-content">
                    <input type="phone" required="required" name="phone" class="" placeholder="收货人手机号码" pattern=".{7,}" value="<%=AsUser.Mobile%>">
                </div>
            </div>
            <div class="common-item">
                <span class="item-label">省市区：</span>
                <div class="item-content">
                    <div id="citylist">
                    </div>
                </div>
            </div>
            <div class="common-item">
                <span class="item-label">地址：</span>
                <div class="item-content">
                    <input type="text" required="required" name="address" class="" placeholder="详细地址" value="<%=AsUser.Address%>">
                </div>
            </div>
            <div class="common-item">
                <span class="item-label">邮政编码：</span>
                <div class="item-content">
                    <input type="text" required="required" name="zipcode" class="" placeholder="邮政编码" pattern="[0-9]*" maxlength="6" value="<%=AsUser.Zipcode%>">
                </div>
            </div>
            <div class="common-item">
                <span class="item-label">订单附言：</span>
                <div class="item-content">
                    <input type="text" name="deliveryComment" value="">
                </div>
            </div>
        </div>
        <% }
          else
          { %>


        <div class="common-title" id="mobile-title">
            <h3>当前手机号码</h3>
        </div>
        <div class="common-items" id="mobile-show">
            <div class="common-item">
                <span class="item-label">手机号码：</span>
                <div class="item-content">
                    <%if (AsUser.Mobile != null && AsUser.Mobile.Length > 0)
                      {%>
                    <%=AsUser.Mobile.Substring(0,3)+"****"+AsUser.Mobile.Remove(0,7)%>
                    <a id="change-mobile" href="javascript:void(0)">修改</a>
                </div>
                <%}
                      else
                      {%>
                <input type="number" placeholder="请输入您的手机号码" required="required" disabled="disabled" name="newmobile" value="" />
                <%}%>
            </div>
            <div class="common-item">
                <span class="item-label">订单附言：</span>
                <div class="item-content">
                    <input type="text" name="deliveryComment" value="">
                </div>
            </div>
        </div>
        <div class="common-items" id="mobile-modify" style="display: none;">
            <div class="common-item">
                <span class="item-label">旧手机号：</span>
                <div class="item-content">
                    <input type="number" placeholder="请输入已绑定的手机号码" required="required" disabled="disabled" name="oldmobile" value="" />
                </div>
            </div>
            <div class="common-item">
                <span class="item-label">新手机号：</span>
                <div class="item-content">
                    <input type="number" placeholder="请输入新手机号" required="required" disabled="disabled" name="newmobile" value="" />
                </div>
            </div>
        </div>
        <%} %>
        <div class="submit-box">
            <p class="c-submit ">
                <input id="Submit1" type="submit" gaevent="imt/buy/submit" runat="server" onserverclick="submit_ServerClick" value="提交订单" />
            </p>
        </div>
    </form>
</div>
<%}%>
<%LoadUserControl("_footer.ascx", null); %>
<script>
    $(function () {
        MT.touch.initQuantityBox();
        // 是否需要清除缓存
        var needClearCache = Boolean("");
        var $title = $('#mobile-title'),
            $modify = $('#mobile-modify'),
            isQuickBuy = false,
            $errMsg = ($('#errMsg').length > 0) ? $('#errMsg') : $('#buy .errMsg'),
            isShowModified = false, timeId;

        var errMsgFadeIn = MT.util.errMsgFadeIn;

        var tapOrClick = MT.util.tapOrClick;

        // 清空数据
        if (needClearCache) {
            localStorage.removeItem('isAddressOrMobileChanged');
            localStorage.removeItem('formData');
        }
        $('#buy-form').validator(function (msg) {
            errMsgFadeIn.call($errMsg, 'text', msg);
        });

        // 当用户修改手机号码：1. #add-mobile有值 2.点击了”修改“(change-mobile)按钮
        $('#add-mobile').on('change', function (e) {
            localStorage.isAddressOrMobileChanged = 'true';

        });
        $('#change-mobile').on(tapOrClick, function (e) {
            e.preventDefault();

            localStorage.isAddressOrMobileChanged = 'true';

            if (!isShowModified) {
                isShowModified = true;
                $modify.show();
                $modify.find('input').removeAttr('disabled');
                $title.html('更换手机号');
                $(this).text('取消修改')
            } else {
                isShowModified = false;
                $modify.hide();
                $modify.find('input').attr('disabled', 'disabled');
                $title.html('当前手机号码');
                $(this).text('修改');
            }
        });

        // 当用户修改收货地址：1.点击了”使用其它地址“(change-address)按钮 2.点击”添加收货人地址“（add-address)按钮
        $('#change-address').on(tapOrClick, function (e) {
            e.preventDefault();

            localStorage.isAddressOrMobileChanged = 'true';
        });
        $('#add-address').on(tapOrClick, function (e) {
            e.preventDefault();

            localStorage.isAddressOrMobileChanged = 'true';
        });

        $('#sms-captcha').on('keyup', function (e) {
            var isValideMobile = $('#smsCode').attr('class').indexOf('active') > -1,
                $submitBtn = $('.c-submit');

            if (isValideMobile && $(this).val()) {
                $smsCode.removeClass('c-disabled').find('input').prop('disabled', '');
            } else {
                $smsCode.addClass('c-disabled');
            }
        })


        $('#login-mobile').on('keyup', function (e) {
            if (/^\d{11}$/.test($("#login-mobile").val())) {
                $("#smsCode").addClass('active');
            }
            else {
                $("#smsCode").removeClass('active');
            }
        })


        function resetSMSBtn($btn, immediately) {
            $btn.addClass('wait-a-minute');
            var MINUTE = 60;

            if (immediately && timeId) {
                clearInterval(timeId);
                $btn.removeClass('wait-a-minute').text('发送验证码');
                return false;
            }

            timeId = setInterval(function () {
                if (MINUTE) {
                    $btn.text((MINUTE > 10 ? MINUTE : (' ' + MINUTE)) + '秒后重发');
                    MINUTE--;
                } else {
                    clearInterval(timeId);
                    $btn.removeClass('wait-a-minute').text('发送验证码');
                }
            }, 1000);
        }

        // 当用户点击了修改号码，校验新旧手机号码
        $('#form').on('submit', function (e) {
            var str = selectInput();
            $("#bulletin").val(str);
            // 快捷购买增加手机号
            if (isQuickBuy) {
                if (!$('input[name=quickBuyCode]').val()) {
                    errMsgFadeIn.call($errMsg, 'text', '请输入验证码')
                    return false;
                }
            } else {
                if (isShowModified) {
                    var newMobile = $('input[name=newmobile]').val(),
                        oldMobile = $('input[name=oldmobile]').val();

                    if (!newMobile || !oldMobile ||
                            !/^\d{11}$/.test(newMobile) || !/^\d{11}$/.test(oldMobile)) {

                        if (newMobile === oldMobile) {
                            errMsgFadeIn.call($errMsg, 'text', '请输入不同的新旧手机号码');
                        } else {
                            errMsgFadeIn.call($errMsg, 'text', '请输入正确的手机号码');
                        }

                        e.preventDefault();
                    }
                }
            }
        });
    });
    $("#citylist").load("<%=PageValue.WebRoot%>ajax/citylist.aspx?pid=0&type=mobile", null, function (data) { });

</script>

<script type="text/javascript" language="javascript">
    var num = 0;
    var txt;
    var sum = 0;
    function additem(obj, id, rule, obj, txt, teamid) {
        rows = rows + 1;
        var texts = $("input[num_tid='" + teamid + "'][type='text']");
        var td = $("td[tid='" + teamid + "']");
        var nownumber = 0;
        var totalnumber = 0;
        totalnumber = parseInt($(td).html());

        for (var i = 0; i < $(texts).length; i++) {
            if (parseInt($(texts).eq(i).val()) <= 0) {
                alert("数量应大于0");
                return false;
            }
            nownumber = nownumber + parseInt($(texts).eq(i).val());
        }
        var row, cell, str;
        row = document.getElementById(id).insertRow(-1);
        if (row != null) {
            cell = row.insertCell(-1);
            cell.innerHTML = document.getElementById(rule).innerHTML.replace(/rows="(\d+)"/g, "rows=\"" + rows.toString() + "\"");
            cell.className = "deal-buy-desc";
            cell.setAttribute("colspan", 6)
            cell.id = "rule";
        }
        num++
        document.getElementsByName("totalNumber")[0].value = num;
    }
    function deleteitem(obj, id, teamid, totalnumber) {
        var texts = $("input[num_tid='" + teamid + "'][type='text']");
        var rowNum, curRow, ce;
        curRow = obj.parentNode.parentNode;
        rowNum = document.getElementById(id).rows.length - 1;
        ce = document.getElementById(id).rows[rowNum].getElementsByTagName("input")[0].value;
        if (rowNum >= 1) {

            document.getElementById(id).deleteRow(curRow.rowIndex);
        }

    }
    function isNum() {
        if (event.keyCode < 48 || event.keyCode > 57) {
            event.keyCode = 0;
        }
    }
    function clearNoNum(obj) {
        if ((obj.value != "") && (isNaN(obj.value) || parseInt(obj.value) <= 0)) {
            obj.value = "1";
        }

    }
    function selectInput() {
        var falg = "";
        var str = "";
        var j = 0;
        var bull = $("select[name=rule0]");  // 这里也可以写成var obj = document.getElementByName("n1");
        var num = document.getElementsByName("num0");
        var arrText = new Array();
        str += "";
        str += "{";
        falg = "";
        for (var i = 0; i < bull.length; i++) {
            if (falg == bull[i].value.split(":")[0]) {

                str += "数量:[" + num[j].value + "]";
                str += "}|";
                j++;
                str += "{";
                str += bull[i].value.split(":")[0] + ":";
                str += "[";
                str += bull[i].value.split(":")[1] + "],";
            }
            else {
                str += bull[i].value.split(":")[0] + ":";
                str += "[";
                str += bull[i].value.split(":")[1] + "],";
                if (falg == "") {
                    falg = bull[i].value.split(":")[0];
                }
            }
        }
        str += "数量:[" + num[j].value + "]";
        str += "}";
        return str;
    }
</script>
<script>
    var webroot = '<%=PageValue.WebRoot%>';
    function changecity(pid) {
        var sels = $("#citylist").find("select");
        var str = "";
        var candel = false;
        var obj = null;
        var citynames = "";
        var cityids = "";
        var cityid = "";
        for (var i = 0; i < sels.length; i++) {
            if (!candel) {
                cityid = sels.eq(i).val();
                var strs = new Array();
                strs = cityid.split(",");
                str = str + "-" + strs[1];
                citynames = citynames + "," + sels.eq(i).val();
            }
            else
                sels.eq(i).remove();

            if (sels.eq(i).attr("pid") == pid) {

                candel = true;
                obj = sels.eq(i);
            }
        }
        if (str.length > 0)
            str = str.substr(1);
        if (citynames.length > 0) {
            citynames = citynames.substr(1);
            cityids = cityids.substr(1);
        }
        $("#county").val(str);
        if (obj != null) {
            var oid = strs[0];
            if (oid != null) {
                var u = "ajax/citylist.aspx?pid=" + oid;
                $.ajax({
                    type: "POST",
                    url: webroot + "ajax/citylist.aspx",
                    data: { "pid": oid, "type": "mobile" },
                    success: function (msg) {
                        if (msg != "") {
                            $("#citylist").append(msg);
                        }
                    }
                });
            }
        }
    }
</script>
<%LoadUserControl("_htmlfooter.ascx", null); %>