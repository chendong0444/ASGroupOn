<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">
    public string type = "";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            type = "edit";


        }

    }
</script>
<ul>

    <li <%=Utility.GetStyle("ProductList.aspx")%>><a href="ProductList.aspx">产品列表</a><span></span></li>

    <li <%=Utility.GetStyle("ProductAdd.aspx")%>><a href="ProductAdd.aspx"><%if (type == "edit")
                                                                             {%>编辑产品<% }
                                                                             else
                                                                             { %>新建产品<%} %></a><span></span></li>


</ul>
