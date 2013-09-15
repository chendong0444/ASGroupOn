<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Response.ContentEncoding=Encoding.GetEncoding("GB2312");
        Response.ContentType = "application/octet-stream";
        HttpBrowserCapabilities bc = Request.Browser;
        if (bc.Type.ToLower().Contains("ie"))
        {
            Response.AddHeader("Content-Disposition", "attachment;filename=" + System.Web.HttpUtility.UrlEncode(ASSystem.sitename, System.Text.Encoding.UTF8) + ".url");
        }
        else
        {
            Response.AddHeader("Content-Disposition", "attachment;filename=" + ASSystem.sitename + ".url");
        }
        StringBuilder sb=new StringBuilder();
        sb.Append("[InternetShortcut]\r\n");
        sb.Append("URL=" + WWWprefix+"index.aspx"+"\r\n");
        sb.Append("Modified=F00F43B3A875");
        Response.Write(sb.ToString());
        Response.End();
    }

</script>