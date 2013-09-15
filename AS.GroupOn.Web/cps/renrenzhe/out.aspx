<%@ Page Language="C#" AutoEventWireup="true" Inherits="ASdhtWeb.BasePage" %>
<%@ Import Namespace="System.Data" %>
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
    protected override void OnLoad(EventArgs e)
    {
        DateTime starttime = DateTime.Now;
        DateTime endtime = DateTime.Now.Date.AddDays(1);
        string from = String.Empty;
        string time = String.Empty;
        string code = String.Empty;
        if (Request["begin_date"] != null && Request["begin_date"].ToString() != String.Empty)
        {
            if (Request["end_date"] != null && Request["end_date"].ToString() != String.Empty)
            {
                starttime = Helper.GetDateTime(Request["begin_date"], DateTime.Now.Date);
                endtime = Helper.GetDateTime(Request["end_date"], DateTime.Now.Date).AddDays(1);
            }
        }
        else
        {
            Response.Write("-1");
            return;
        }
        if (Request["unionid"] != null && Request["unionid"].ToString() != String.Empty)
        {
            from = Helper.GetString(Request["unionid"], String.Empty);
        }
        else
        {
            Response.Write("-3");
            return;
        }
        if (Request["time"] != null && Request["time"].ToString() != String.Empty)
        {
            time = Helper.GetString(Request["time"], String.Empty);
        }
        else
        {
            Response.Write("-4");
            return;
        }
        string WWWprefix = "";
        WWWprefix = Request.Url.AbsoluteUri;
        string ss = WebUtils.config["rrzsecret"];
        string url = WWWprefix.Substring(0, WWWprefix.Length - 38);
        if (Request["code"] != null && Request["code"].ToString() != string.Empty)
        {
            code = Helper.GetString(Request["code"], String.Empty);
            if (code == Helper.MD5(url + ss))
            {
                string sql = "select [Order].Id,value1,[Order].Origin,[Order].Fare,[Order].State,u_id,Create_time from cps inner join [Order] on(cps.order_id=[Order].Id) where Create_time>='" + starttime.ToString("yyyy-MM-dd 0:0:0") + "' and Create_time<='" + endtime.ToString("yyyy-MM-dd 23:59:59") + "' and channelId='renrenzhe' order by Create_time";
                List<Hashtable> hs = null;
                using (IDataSession session = Store.OpenSession(false))
                {
                    hs = session.Custom.Query(sql);
                }
                StringBuilder sb = new StringBuilder();
                if (hs != null && hs.Count > 0)
                {
                    for (int i = 0; i < hs.Count; i++)
                    {
                        IOrder order = null;
                        IList<IOrderDetail> orderlist = null;
                        using (IDataSession session = Store.OpenSession(false))
                        {
                            order = session.Orders.GetByID(Helper.GetInt(hs[i]["Id"], 0));
                        }
                        if (order != null)
                        {
                            if (order.OrderDetail != null && order.OrderDetail.Count > 0)
                            {
                                string o_cd = String.Empty;             //定单号
                                string u_id = hs[i]["u_id"].ToString();             //用户标示
                                string p_cd = String.Empty;             //商品编号，商品在团购网站中的唯一标识
                                string c_cd = String.Empty;             //分类编号
                                string it_cnt = String.Empty;           //商品数量
                                string price = String.Empty;            //商品单价
                                string state = String.Empty;            //订单状态0: 未付款1: 已付款2: 已取消
                                string title = String.Empty;
                                long o_time = 0;
                                foreach (IOrderDetail detail in order.OrderDetail)
                                {
                                    o_cd = o_cd + detail.Order_id;
                                    p_cd = p_cd + detail.Teamid;
                                    if (detail.Team.TeamCatalogs.catalogname != null)
                                        c_cd = c_cd + detail.Team.TeamCatalogs.catalogname + "|";
                                    else
                                        c_cd = c_cd + "|";
                                    title = title + detail.Team.Product + "|";
                                    it_cnt = it_cnt + detail.Num + "|";
                                    price = price + (detail.Teamprice * 100).ToString("0") + "|";
                                    o_time = Helper.GetTimeFix(detail.Order.Create_time);
                                    state = GetPayState(detail.Order.State);
                                    state = state + "|_|";
                                    sb.Append(o_time + "|" + o_cd + "|" + u_id + "|" + p_cd + "|" + c_cd + it_cnt + price + state + "\n");
                                }
                            }
                            else
                            {
                                string o_cd = String.Empty;
                                string u_id = hs[i]["u_id"].ToString();
                                string p_cd = String.Empty;
                                string c_cd = String.Empty;
                                string it_cnt = String.Empty;
                                string price = String.Empty;
                                string state = String.Empty;
                                string title = String.Empty;
                                long o_time = 0;
                                o_cd = order.Id.ToString();
                                p_cd = order.Team_id.ToString();
                                it_cnt = order.Quantity.ToString();
                                price = order.Price.ToString();
                                state = GetPayState(order.State);
                                o_time = Helper.GetTimeFix(order.Create_time);
                                string catalogname = "无";
                                if (order.Team.TeamCatalogs.catalogname != null)
                                    c_cd = order.Team.TeamCatalogs.catalogname;
                                else
                                    c_cd = catalogname;
                                sb.Append(o_time + "|" + o_cd + "|" + u_id + "|" + p_cd + "|" + c_cd + "|" + it_cnt + "|" + price + "|" + state + "|_|\n");
                            }
                        }
                    }
                }
                Response.Write(sb.ToString());
                Response.End();
            }
            else
            {
                Response.Write("-2");
                Response.End();
            }
        }
        else
        {
            Response.Write("-2");
            Response.End();
        }
    }
    private string GetPayState(string state)
    {
        switch (state)
        {
            case "pay":
                return "1";
            case "cancel":
                return "2";
        }
        return "0";
    }
</script>
