<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace=" System.Data" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        string action = Helper.GetString(Request["action"], String.Empty);
        if ("Refundreview" == action)
        {
            string html = WebUtils.LoadPageString(PageValue.TemplatePath + "order_refundview.aspx?id=" + Helper.GetInt(Request["id"], 0) + "&pagenum=" + Request["pagenum"]);
            Response.Write(JsonUtils.GetJson(html, "dialog"));
        }
    }
</script>
