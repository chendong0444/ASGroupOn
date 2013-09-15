<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerBranchPage" %>

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
        string action = Helper.GetString(Request["action"], String.Empty);
        int id = Helper.GetInt(Request["id"], 0);

        if (action == "orderview" && id > 0)
        {
            Response.Write(JsonUtils.GetJson(WebUtils.LoadPageString(WebRoot + "ajaxpage/ajax_dialog_branch.aspx?id=" + id), "dialog"));
        }

        if (action == "teamdetail" && id > 0)
        {
            Response.Write(JsonUtils.GetJson(WebUtils.LoadPageString(WebRoot + "manage/manage_ajax_dialog_teamdetail.aspx?id=" + id), "dialog"));
        }

    }
</script>
