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
    System.Text.StringBuilder sb = new System.Text.StringBuilder();
    System.Collections.Generic.List<IDictionary> order_list = new System.Collections.Generic.List<IDictionary>();
    string bid = String.Empty;
    string orderid = String.Empty;
    string sql = String.Empty;
    string last_order_id = "";
    string orderids = "";
    decimal propor = Helper.GetDecimal(PageValue.CurrentSystemConfig["cps360bili"].ToString(), 1);
    string prostr = GetMoney((Helper.GetDecimal(PageValue.CurrentSystemConfig["cps360bili"].ToString(), 0) * 100).ToString()) + "%";
    protected override void OnLoad(EventArgs e)
    {
        if (PageValue.CurrentSystemConfig["open360"] != null && PageValue.CurrentSystemConfig["open360"] == "1")
        {
            DateTime d = DateTime.Now;
            DateTime ed = DateTime.Now.Date.AddDays(1);
            string cp_key = PageValue.CurrentSystemConfig["cps360appkey"];//密钥
            string _active_time;
            string _bid = Helper.GetString(Request["bid"], String.Empty);
            string _sign = Helper.GetString(Request["sign"], String.Empty);
            string orderids = Request.Form["order_ids"];
            string start_time = Request.Form["start_time"];
            string end_time = Request.Form["end_time"];
            string updstart_time = Request.Form["updstart_time"];
            string updend_time = Request.Form["updend_time"];
            if (_bid != String.Empty && _bid != PageValue.CurrentSystemConfig["cps360appid"])
            {
                Response.Write("bid不可为空");
                return;
            }
            if (Request["last_order_id"] != null && Request["last_order_id"].ToString() != String.Empty)
            {
                last_order_id = Helper.GetString(Request["last_order_id"], String.Empty);
            }
            if (Request["active_time"] != null && Request["active_time"].ToString() != String.Empty)
            {
                _active_time = Request["active_time"].ToString();
            }
            else
            {
                Response.Write("active_time不可为空");
                return;
            }
            string msg = "";
            if (!checkActiveTime(long.Parse(_active_time), out msg))
            {
                Response.Write(msg);
            }
            string sign = Helper.MD5(_bid + "#" + _active_time + "#" + cp_key);
            if (_sign != null && _sign.ToString() != String.Empty)
            {
                if (_sign == sign)
                {
                    if (!String.IsNullOrEmpty(orderids))
                    {
                        string[] temp = orderids.Split(',');
                        orderids = String.Empty;
                        for (int i = 0; i < temp.Length; i++)
                        {
                            orderids = orderids + "," + Helper.GetInt(temp[i], 0);
                        }
                        if (orderids.Length > 0)
                            orderids = orderids.Substring(1);
                        QueryOrder(orderids);
                        Response.Write(sb.ToString());
                        Response.End();
                    }
                    else if (!String.IsNullOrEmpty(start_time) && !String.IsNullOrEmpty(end_time))
                    {
                        DateTime s_time = DateTime.Parse(start_time);
                        DateTime e_time = DateTime.Parse(end_time);
                        SelecteData(s_time, e_time, "now");
                        Response.Write(sb.ToString());
                        Response.End();
                    }
                    else if (!String.IsNullOrEmpty(updstart_time) && !String.IsNullOrEmpty(updend_time))
                    {
                        DateTime s_time = DateTime.Parse(updstart_time);
                        DateTime e_time = DateTime.Parse(updend_time);
                        SelecteData(s_time, e_time, "up");
                        Response.Write(sb.ToString());
                        Response.End();
                    }
                }
                else
                {
                    WebUtils.LogWrite("签名错误", sign + ">>>>>" + _sign);
                }
            }
            else
            {
                Response.Write("sign不可为空");
                return;
            }
        }
    }
    public static string GetMoney(object price)
    {
        string money = String.Empty;
        if (price != null)
        {
            Regex regex = new Regex(@"^(\d+)$|^(\d+.[1-9])0$|^(\d+).00$");
            Match match = regex.Match(price.ToString());
            if (match.Success)
            {
                money = regex.Replace(match.Value, "$1$2$3");
            }
            else
            {
                money = price.ToString();
                if (money.IndexOf(".00") > 0)
                {
                    money = money.Substring(0, money.IndexOf(".00"));
                }
                if (money.IndexOf(".0") > 0)
                {
                    money = money.Substring(0, money.IndexOf(".0"));
                }
            }
        }
        return money;
    }
    /// <summary>
    /// 检查超时
    /// </summary>
    /// <param name="active_time">请求时的UNIX时间戳</param>
    /// <param name="msg">提示信息</param>
    /// <returns>true：不超时，false：超时</returns>
    public static bool checkActiveTime(long active_time, out string msg)
    {
        long currentTime = (DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000;
        long diffTime = Math.Abs(currentTime - active_time);   //时间差（s）

        if ((int)diffTime > 900)
        {
            msg = "检查超时";
            return false;
        }
        msg = "成功";
        return true;
    }
    private StringBuilder QueryOrder(string orderids)
    {
        string sql = "select top 2000 [Order].Id,pay_time,create_time,disamount,cps.value1,cps.username,cps.result,cps.[u_id],[Order].Card,[Order].Express,[order].address,[order].team_id,[Order].Fare,[Order].Origin,[Order].Quantity,[order].price,[order].state,[card] from cps inner join [Order] on(cps.order_id=[Order].Id) where channelid='360' ";
        if (bid.Length > 0)
        {
            sql = sql + " and [u_id]='" + bid + "' ";
        }
        sql = sql + " and order_id in(" + orderids + ")";
        sql = sql + " order by id asc";
        List<Hashtable> ordertable = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            ordertable = session.Custom.Query(sql);
        }
        IOrder ordermodel = Store.CreateOrder();
        Response.ContentType = "text/xml";
        sb.AppendFormat("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
        sb.AppendFormat("<orders>");
        string delivery_address = String.Empty;
        string address = String.Empty;
        for (int i = 0; i < ordertable.Count; i++)
        {
            using (IDataSession session = Store.OpenSession(false))
            {
                ordermodel = session.Orders.GetByID(Helper.GetInt(ordertable[i]["Id"], 0));
            }
            if (ordermodel.Address != null && ordermodel.Address.ToString() != "")
            {
                address = "中国," + ordermodel.Address.Replace('-', ',');
            }
            else
            {
                address = ",,,,,,";
            }
            delivery_address = "delivery_address,0," + ordermodel.Realname + "," + address + "," + ordermodel.Zipcode + "," + ordermodel.Mobile + "|" + "order_link," + Server.UrlEncode(PageValue.CurrentSystem.domain + UrlMapper.GetUrl("订单详情", "order_view.aspx?userid=" + ordermodel.User_id + "&id=" + ordermodel.Id)) + "|";
            sb.AppendFormat("<order>");
            sb.AppendFormat("<bid>" + ordertable[i]["u_id"].ToString() + "</bid>");
            sb.AppendFormat("<qid>" + ordertable[i]["value1"].ToString() + "</qid>");
            sb.AppendFormat("<qihoo_id>" + ordertable[i]["username"].ToString() + "</qihoo_id>");
            sb.AppendFormat("<ext>" + ordertable[i]["result"].ToString().Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;") + "</ext>");
            sb.AppendFormat("<order_id>" + ordertable[i]["Id"].ToString() + "</order_id>");
            sb.AppendFormat("<order_time>" + Convert.ToDateTime(ordertable[i]["create_time"]).ToString("yyyy-MM-dd HH:mm:ss") + "</order_time>");
            if (ordertable[i]["Pay_time"] != null && ordertable[i]["Pay_time"].ToString() != "")
            {
                sb.AppendFormat("<order_updtime>" + Convert.ToDateTime(ordertable[i]["Pay_time"]).ToString("yyyy-MM-dd HH:mm:ss") + "</order_updtime>");
            }
            else
            {
                sb.AppendFormat("<order_updtime>" + Convert.ToDateTime(ordertable[i]["create_time"]).ToString("yyyy-MM-dd HH:mm:ss") + "</order_updtime>");
            }
            sb.AppendFormat("<total_comm>" + get_info(ordertable[i]["Id"].ToString(), "comm") + "</total_comm>");
            sb.AppendFormat("<commission>" + get_info(ordertable[i]["Id"].ToString(), "commission") + "</commission>");
            sb.AppendFormat("<p_info>" + delivery_address + get_info(ordertable[i]["Id"].ToString(), "info") + "</p_info>");
            sb.AppendFormat("<server_price>" + ordertable[i]["Fare"].ToString() + "</server_price>");
            sb.AppendFormat("<total_price>" + get_info(ordertable[i]["Id"].ToString(), "total") + "</total_price>");
            sb.AppendFormat("<coupon>" + ordertable[i]["card"].ToString() + "</coupon>");
            sb.AppendFormat("<status>" + getState(ordertable[i]["state"].ToString()) + "</status>");
            sb.AppendFormat("</order>");
        }
        sb.AppendFormat("</orders>");

        Response.Clear();
        return sb;
    }
    private StringBuilder SelecteData(DateTime d, DateTime end, string type)
    {
        string sql = "select top 2000 [Order].Id,pay_time,create_time,disamount,cps.value1,cps.username,cps.result,cps.[u_id],[Order].Card,[Order].Express,[order].address,[order].team_id,[Order].Fare,[Order].Origin,[Order].Quantity,[order].price,[order].state,[order].[Realname],[order].[Zipcode],[order].[Mobile],[order].[User_id],[card] from cps inner join [Order] on(cps.order_id=[Order].Id) where channelid='360' ";
        if (bid.Length > 0)
        {
            sql = sql + " and [u_id]='" + bid + "' ";
        }
        if (type == "now")
            sql = sql + " and [order].create_time>='" + d.ToString("yyyy-MM-dd HH:mm:ss") + "' and [order].create_time<='" + end.ToString("yyyy-MM-dd HH:mm:ss") + "' ";
        else if (type == "up")
            sql = sql + " and [order].pay_time>='" + d.ToString("yyyy-MM-dd HH:mm:ss") + "' and [order].pay_time<='" + end.ToString("yyyy-MM-dd HH:mm:ss") + "' ";

        if (last_order_id.Length > 0)
            sql = sql + " and order_id>" + last_order_id;
        sql = sql + " order by id asc";
        List<Hashtable> ordertable = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            ordertable = session.Custom.Query(sql);
        }
        IOrder ordermodel = Store.CreateOrder();
        Response.ContentType = "text/xml";
        sb.AppendFormat("<?xml version=\"1.0\" encoding=\"utf-8\"?>");
        sb.AppendFormat("<orders>");
        string delivery_address = String.Empty;
        string address = String.Empty;
        for (int i = 0; i < ordertable.Count; i++)
        {
            using (IDataSession session = Store.OpenSession(false))
            {
                ordermodel = session.Orders.GetByID(Helper.GetInt(ordertable[i]["Id"], 0));
            }
            if (ordermodel.Address != null && ordermodel.Address.ToString() != "")
            {
                address = "中国," + ordermodel.Address.Replace('-', ',');
            }
            else
            {
                address = ",,,,,,";
            }
            delivery_address = "delivery_address,0," + ordermodel.Realname + "," + address + "," + ordermodel.Zipcode + "," + ordermodel.Mobile + "|" + "order_link," + Server.UrlEncode(PageValue.CurrentSystem.domain + UrlMapper.GetUrl("订单详情", "order_view.aspx?userid=" + ordermodel.User_id + "&id=" + ordermodel.Id)) + "|";
            sb.AppendFormat("<order>");
            sb.AppendFormat("<bid>" + ordertable[i]["u_id"].ToString() + "</bid>");
            sb.AppendFormat("<qid>" + ordertable[i]["value1"].ToString() + "</qid>");
            sb.AppendFormat("<qihoo_id>" + ordertable[i]["username"].ToString() + "</qihoo_id>");
            sb.AppendFormat("<ext>" + ordertable[i]["result"].ToString().Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;") + "</ext>");
            sb.AppendFormat("<order_id>" + ordertable[i]["Id"].ToString() + "</order_id>");
            sb.AppendFormat("<order_time>" + Convert.ToDateTime(ordertable[i]["create_time"]).ToString("yyyy-MM-dd HH:mm:ss") + "</order_time>");
            if (ordertable[i]["Pay_time"] != null && ordertable[i]["Pay_time"].ToString() != "")
            {
                sb.AppendFormat("<order_updtime>" + Convert.ToDateTime(ordertable[i]["Pay_time"]).ToString("yyyy-MM-dd HH:mm:ss") + "</order_updtime>");
            }
            else
            {
                sb.AppendFormat("<order_updtime>" + Convert.ToDateTime(ordertable[i]["create_time"]).ToString("yyyy-MM-dd HH:mm:ss") + "</order_updtime>");
            }
            sb.AppendFormat("<total_comm>" + get_info(ordertable[i]["Id"].ToString(), "comm") + "</total_comm>");
            sb.AppendFormat("<commission>" + get_info(ordertable[i]["Id"].ToString(), "commission") + "</commission>");
            sb.AppendFormat("<p_info>" + delivery_address + get_info(ordertable[i]["Id"].ToString(), "info") + "</p_info>");
            sb.AppendFormat("<server_price>" + ordertable[i]["Fare"].ToString() + "</server_price>");
            sb.AppendFormat("<total_price>" + get_info(ordertable[i]["Id"].ToString(), "total") + "</total_price>");
            sb.AppendFormat("<coupon>" + ordertable[i]["card"].ToString() + "</coupon>");
            sb.AppendFormat("<status>" + getState(ordertable[i]["state"].ToString()) + "</status>");
            sb.AppendFormat("</order>");
        }
        sb.AppendFormat("</orders>");
        Response.Clear();
        return sb;
    }
    private string getState(string state)
    {
        switch (state.ToLower())
        {
            case "pay":
                state = "4";
                break;
            case "unpay":
                state = "1";
                break;
            case "cancel":
                state = "6";
                break;
            case "refund":
                state = "6";
                break;
            default:
                state = "1";
                break;
        }
        return state;
    }
    private string get_info(string orderid, string type)
    {
        decimal total_comm = 0.00M;
        decimal youhui = 0.00M;
        decimal total = 0.00M;
        string commission = String.Empty;
        string p_info = String.Empty;
        string name = String.Empty;
        string info = String.Empty;
        IList<IOrderDetail> orderdetailmodellist = null;
        IOrderDetail orderdetailmodel = Store.CreateOrderDetail();
        IOrder order_model = Store.CreateOrder();
        ITeam teammodel = Store.CreateTeam();
        OrderDetailFilter od = new OrderDetailFilter();
        od.Order_ID = Helper.GetInt(orderid, 0);
        using (IDataSession session = Store.OpenSession(false))
        {
            order_model = session.Orders.GetByID(Helper.GetInt(orderid, 0));
            orderdetailmodellist = session.OrderDetail.GetList(od);
        }
        if (type == "comm")
        {
            if (orderdetailmodellist.Count > 0)
            {
                for (int k = 0; k < orderdetailmodellist.Count; k++)
                {
                    orderdetailmodel = orderdetailmodellist[k];
                    total_comm = total_comm + orderdetailmodel.Teamprice * orderdetailmodel.Num * propor - Convert.ToDecimal(orderdetailmodel.Credit) * propor;
                }
            }
            else
            {
                total_comm = order_model.Price * order_model.Quantity * propor - Convert.ToDecimal(order_model.Card) * propor;
            }
            info = total_comm.ToString("0.00");
        }
        else if (type == "commission")
        {
            if (orderdetailmodellist.Count > 0)
            {
                for (int k = 0; k < orderdetailmodellist.Count; k++)
                {
                    orderdetailmodel = orderdetailmodellist[k];
                    commission = commission + orderdetailmodel.Teamid + "," + prostr + "," + Math.Round(propor * orderdetailmodel.Teamprice * orderdetailmodel.Num, 2) + "," + orderdetailmodel.Teamprice + "," + orderdetailmodel.Num + "|";
                    youhui = youhui + Convert.ToDecimal(orderdetailmodel.Credit) * propor;
                }
            }
            else
            {
                commission = commission + order_model.Team.Id + "," + prostr + "," + Math.Round(propor * order_model.Price * order_model.Quantity, 2) + "," + order_model.Price + "," + order_model.Quantity + "|";

                youhui = youhui + Convert.ToDecimal(order_model.Card) * propor;
            }
            info = commission + youhui.ToString("0.00");
        }
        else if (type == "info")
        {
            if (orderdetailmodellist.Count > 0)
            {
                for (int k = 0; k < orderdetailmodellist.Count; k++)
                {
                    orderdetailmodel = orderdetailmodellist[k];
                    teammodel = orderdetailmodel.Team;
                    name = GetCateName(teammodel);
                    p_info = p_info + orderdetailmodel.Teamid + "," + teammodel.Product.Replace(",", "，") + "," + orderdetailmodel.Order_id + "," + orderdetailmodel.Teamprice + "," + orderdetailmodel.Num + "," + name + "," + Server.UrlEncode(PageValue.CurrentSystem.domain + BasePage.getTeamPageUrl(orderdetailmodel.Teamid)) + "|";
                }
                info = p_info.Substring(0, p_info.Length - 1);
            }
            else
            {
                name = GetCateName(order_model.Team);
                p_info = p_info + order_model.Team_id + "," + order_model.Team.Product.Replace(",", "，") + "," + order_model.Id + "," + order_model.Price + "," + order_model.Quantity + "," + name + "," + Server.UrlEncode(PageValue.CurrentSystem.domain + BasePage.getTeamPageUrl(order_model.Team_id));
                info = p_info;
            }
        }
        else if (type == "total")
        {
            if (orderdetailmodellist.Count > 0)
            {
                for (int k = 0; k < orderdetailmodellist.Count; k++)
                {
                    orderdetailmodel = orderdetailmodellist[k];
                    total = total + orderdetailmodel.Teamprice * orderdetailmodel.Num - Convert.ToDecimal(orderdetailmodel.Credit);
                }
            }
            else
            {
                total = order_model.Price * order_model.Quantity - Convert.ToDecimal(order_model.Card);
            }
            info = total.ToString("0.00");
        }
        return info;
    }
    private string GetCateName(ITeam teammodel)
    {
        string catalogname = "";
        ICatalogs catalogmodel = teammodel.TeamCatalogs;
        IList<Hashtable> hs = null;
        using (IDataSession session=Store.OpenSession(false))
        {
            hs = session.Custom.Query("select * from catalogs order by id desc");
        }
        string cataname = "";
        int parent_id = 0;
        bool isbool = false;
        System.Collections.Generic.List<string> list = new System.Collections.Generic.List<string>();
        for (int i = 0; i < hs.Count; i++)
        {
            int _parentid = parent_id;
            while (Convert.ToInt32(hs[i]["id"]) == teammodel.cataid)
            {
                parent_id = Convert.ToInt32(hs[i]["parent_id"]);
                catalogname = hs[i]["catalogname"].ToString();
                list.Add(catalogname);
                isbool = true;
                break;
            }
            if (isbool)
            {
                while (Convert.ToInt32(hs[i]["id"]) == _parentid)
                {
                    parent_id = Convert.ToInt32(hs[i]["parent_id"]);
                    catalogname = hs[i]["catalogname"].ToString();
                    list.Add(catalogname);
                    break;
                }
            }
        }
        if (list.Count == 0)
        {
            list.Add("暂无分类");
        }
        list.Reverse(0, list.Count);
        for (int k = 0; k < list.Count; k++)
        {
            string name = list[k] + "_";
            cataname += name;
        }
        catalogname = cataname.Remove(cataname.Length - 1);
        
        return catalogname;
    }
</script>
