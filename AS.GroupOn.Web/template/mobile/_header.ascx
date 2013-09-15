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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public override void UpdateView()
    {
        ShowMessage();
    }
</script>
<body id="<%=PageValue.WapBodyID %>">
<%if (PageValue.WapBodyID == "index")
  { %>
  <header>
        <h1 id="logo">
            <a  href="<%=GetUrl("手机版首页","index.aspx") %>"><span><%=PageValue.CurrentSystem.sitename%></span></a>
        </h1>
        <a class="city" href="<%=GetUrl("手机版城市","city.aspx") %>"><%=PageValue.CurrentCity.Name%></a>
        <div id="nav">
            <a class="account"  href="<%=GetUrl("手机版个人中心","account_index.aspx") %>">我的<%=PageValue.CurrentSystem.sitename%></a>
            <a class="category"  href="<%=GetUrl("手机版分类","category.aspx") %>">分类</a>
            <a class="search"  href="<%=GetUrl("手机版搜索","search.aspx") %>">搜索</a>
        </div>
    </header>
  <%}
  else
  {%>

     <header>
            <div class="left-box">
                <a class="go-back" href="javascript:history.back()"><span>返回</span></a>
            </div>
        <h1><%=PageValue.Title%></h1>
    </header><%} %>
    <%if (suctext != String.Empty)
      { %>
    <div id="okMsg" style="opacity: 1;"><%=suctext %></div>
    <%} %>
    <%if (errtext != String.Empty)
      { %>
    <div id="errMsg" style="opacity: 1;"><%=errtext %></div>
    <%}%>
