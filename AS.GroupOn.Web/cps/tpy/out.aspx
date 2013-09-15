<%@ Page Language="C#" AutoEventWireup="true" CodePage="65001"%>
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
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!this.Page.IsPostBack)
        {
            string where = " where 1=1 ";
            string id = WebUtils.config["tpykey"];
            if (Request["st"] != null && Request["st"] != String.Empty)
            {
                string st=Request["st"];
                Regex regex = new Regex(@"(\d{4})(\d{2})(\d{2})");
                st=regex.Replace(st, "$1-$2-$3");
                where = where + " and create_time>='" + Helper.GetDateTime(st, DateTime.Now).ToString("yyyy-MM-dd") + "'";
            }
            if (Request["et"] != null && Request["et"] != String.Empty)
            {
                string et = Request["et"];
                Regex regex = new Regex(@"(\d{4})(\d{2})(\d{2})");
                et = regex.Replace(et, "$1-$2-$3");
                where = where + " and create_time<'" + Helper.GetDateTime(et, DateTime.Now).AddDays(1).ToString("yyyy-MM-dd") + "'"; 
            }
            if (Request["orderid"] != null && Request["orderid"] != String.Empty)
            {
                where = where + " and order_id=" + Helper.GetInt(Request["orderid"], 0); 
            }
            if (Request["userid"] != null && Request["userid"] != String.Empty)
            {
                where = where + " and username='" + Helper.GetString(Request["userid"], "$$$$$") + "'"; 
            }
            if (Request["zhuangtai"] != null && Request["zhuangtai"] != String.Empty)
            {
                switch (Request["zhuangtai"])
                {
                    case "a":
                        where = where + " and state='pay'";
                        break;
                    case "b":
                        where = where + " and state='cancel'";
                        break;
                    case "c":
                        where = where + " and state='unpay'";
                        break; 
                    case "d":
                        where = where + " and state='refund'";
                        break;
                }
            }

            where = where + " and channelid='taipingyangcps'";
            string sql = "(select username,value1,create_time,channelid,t.order_id,Origin,state from (select channelid,u_id,cps.order_id,state,create_time,(Origin-fare) as Origin,price,value1,username from cps inner join [order] on (cps.order_id=[order].id))t "+where+")tt";
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
                    string state = "c";
                    switch (hs[i]["state"].ToString())
                    {
                        case "pay":
                            state = "a";
                            break;
                        case "cancel":
                            state = "b";
                            break;
                        case "refund":
                            state = "d";
                            break;
                        case "unpay":
                            state = "c";
                            break;
                    }
                    sb.Append(hs[i]["order_id"] + "|" + state + "|" + Helper.GetDecimal(hs[i]["origin"], 0) + "|" + Helper.GetDateTime(hs[i]["create_time"], DateTime.Now).ToString("yyyy-MM-dd HH:mm:ss") + "|" + hs[i]["username"] + "\n");
                }
            }
            Response.Clear();
            Response.Write(sb.ToString());
            Response.End();
        }
    }
</script>

