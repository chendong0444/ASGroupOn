<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        string action = Helper.GetString(Request["action"], String.Empty);
        if (action == "user")
        {
            //需要管理员权限
            if (CookieUtils.GetCookieValue("admin") == String.Empty)
            {
                Response.Write(JsonUtils.GetJson("您还没有登录或登录超时，请重新登录！", "alert"));
                return;
            }
            Response.Write(JsonUtils.GetJson(WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajax_card.aspx?action=user"), "dialog"));
        }
    }

</script>