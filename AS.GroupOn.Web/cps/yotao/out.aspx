<%@ Page Language="C#" AutoEventWireup="true"  Inherits="ASdhtWeb.BasePage" %>
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

        DateTime starttime = DateTime.Now.Date;
        DateTime endtime = DateTime.Now.Date.AddDays(1);
        if (Request["date"] != null && Request["date"] != String.Empty)
        {

            starttime = Helper.GetDateTime(Request["date"], DateTime.Now.Date);
            endtime = Helper.GetDateTime(Request["date"], DateTime.Now.Date).AddDays(1);
        }
        else
        {
            starttime = Helper.GetDateTime(Request["begin_date"], DateTime.Now.Date);
            endtime = Helper.GetDateTime(Request["end_date"], DateTime.Now.Date).AddDays(1);
        }
        string id = Helper.GetString(Request["unionid"], "yotao");
        string sql = "(select value1,create_time,u_id,channelid,t.order_id,(team_id+isnull(teamid,0))as teamid,isnull(num,quantity) as number,isnull(teamprice,price) as teamprice,state from (select channelid,u_id,cps.order_id,state,create_time,team_id,quantity,Origin,fare,price,value1 from cps inner join [order] on (cps.order_id=[order].id))t left join orderdetail on([t].order_id=orderdetail.order_id) where create_time>='" + starttime.ToString("yyyy-MM-dd 00:00:00") + "' and create_time<'" + endtime.ToString("yyyy-MM-dd 00:00:00") + "' and channelid='" + id + "' ) tt";
        List<Hashtable> hs = null;
        using (IDataSession session = Store.OpenSession(false))
        {
            hs = session.Custom.Query(sql);
        }
        System.Text.StringBuilder sb = new System.Text.StringBuilder();
        if (hs != null && hs.Count > 0)
        {
            for (int i = 0; i < hs.Count; i++)
            {
                string state = "未付款";
                switch (hs[i]["state"].ToString())
                {
                    case "pay":
                        state = "已付款";
                        break;
                    case "refund":
                        state = "已退款";
                        break;
                    case "cancel":
                        state = "已取消";
                        break;
                }
                System.Collections.Specialized.NameValueCollection namevalues = HttpUtility.ParseQueryString(hs[i]["value1"].ToString());
                sb.Append("2\t 订单时间：" + Convert.ToDateTime(hs[i]["create_time"]).ToString("HHmmss") + "\t sid=" + namevalues["sid"] + "\t uid=" + namevalues["uid"] + " \t aid=" + namevalues["aid"] + " \t yid=" + namevalues["yid"] + " \t 订单ID:" + hs[i]["order_id"] + "\t 订单金额:" + (Helper.GetDecimal(hs[i]["Origin"], 0) - Helper.GetDecimal(hs[i]["fare"], 0)) + " \t 订单状态：" + state + "\n");
            }
        }
        Response.Clear();
        Response.Write(sb.ToString());
        Response.End();
    }
</script>
