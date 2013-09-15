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
        Regex regex = new Regex(@"(\d{4})(\d{2})(\d{2})");
        if (Request["yyyymmdd"] != null && Request["yyyymmdd"] != String.Empty && regex.IsMatch(Request["yyyymmdd"]))
        {

            string date = regex.Replace(Request["yyyymmdd"], "$1-$2-$3");
            starttime = AS.Common.Utils.Helper.GetDateTime(date, DateTime.Now.Date);
            endtime = AS.Common.Utils.Helper.GetDateTime(date, DateTime.Now.Date).AddDays(1);
        }
        else
        {
            string date1 = regex.Replace(Request["begin_date"], "$1-$2-$3");
            string date2 = regex.Replace(Request["end_date"], "$1-$2-$3");
            starttime = AS.Common.Utils.Helper.GetDateTime(date1, DateTime.Now.Date);
            endtime = AS.Common.Utils.Helper.GetDateTime(date2, DateTime.Now.Date).AddDays(1);
        }
        string id = AS.Common.Utils.Helper.GetString(Request["unionid"], "linktech");
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
                string state = "100";
                switch (hs[i]["state"].ToString())
                {
                    case "pay":
                        state = "200";
                        break;
                    case "refund":
                        state = "300";
                        break;
                    case "cancel":
                        state = "300";
                        break;

                }
                sb.Append("2\t" + Convert.ToDateTime(hs[i]["create_time"]).ToString("HHmmss") + "\t" + hs[i]["value1"].ToString() + "\t" + hs[i]["order_id"] + "\t" + hs[i]["teamid"] + "\t" + "0\t" + hs[i]["number"] + "\t" + hs[i]["teamprice"] + "\t" + "0\t" + state + "\n");
            }
        }
        Response.Clear();
        Response.Write(sb.ToString());
        Response.End();
    }
</script>
