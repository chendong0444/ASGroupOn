<%@ Page Language="C#" AutoEventWireup="true" Debug="true" Inherits="AS.GroupOn.Controls.FBasePage" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        int orderid = Helper.GetInt(Request["id"], 0);
        string cityname = Helper.GetString(Request["city"], String.Empty);
        int expressid = Helper.GetInt(Request["expressid"], 0);
        string type = Helper.GetString(Request["type"], String.Empty);
        int num = Helper.GetInt(Request["num"], 0);

        decimal fare = 0;
        if (type == "team")
        {
            fare = ActionHelper.System_GetFare(orderid, num, PageValue.CurrentSystemConfig, cityname, expressid);
        }
        else
        {
            fare = ActionHelper.System_GetFare(orderid, PageValue.CurrentSystemConfig, cityname, expressid);
        }
        Response.Write(fare);
        Response.End();
    }
</script>

