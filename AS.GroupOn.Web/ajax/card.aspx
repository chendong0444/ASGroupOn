<%@ Page Language="C#" AutoEventWireup="true" Debug="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Import Namespace="System.Data" %>
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

        //根据商家查询项目
        string partnerId = Helper.GetString(Request["partnerId"], String.Empty);
        if (action == "pt")
        {
            NeedLogin();
            Response.Write(JsonUtils.GetJson(WebUtils.LoadPageString(PageValue.WebRoot + "ajaxpage/ajax_dialog_carditem.aspx?action=pt&partnerId=" + partnerId + ""), "dialog"));
        }
    }
    </script>
