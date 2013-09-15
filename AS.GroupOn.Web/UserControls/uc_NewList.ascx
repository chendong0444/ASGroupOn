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
<script runat="server">
    public IList<INews> newlist = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        Getlist();
    }
    public void Getlist()
    {
        NewsFilter filter = new NewsFilter();
        filter.Top = 5;
        filter.AddSortOrder(NewsFilter.ID_DESC);
        using (IDataSession session = Store.OpenSession(false))
        {
            newlist = session.News.GetList(filter);
        }
    }
    public override void UpdateView()
    {
        Getlist();
    }
</script>
<div class="deal-consult sbox">
    <div class="sbox-bubble">
    </div>
    <div class="sbox-content">
        <div class="r-top">
        </div>
        <h3>新闻公告
        </h3>
        <div class="deal-consult-tip">
             <ul class="list">
                <% if (newlist != null)
                   {
                       foreach (INews item in newlist)
                       {
                           if (item.link != null && item.link != "")
                           { %>
                       <li><a href="<%=item.link %>" target="_blank" style="color:#000;font-size:14px"><%=item.title%></a></li>
                  <%}
                           else
                           {%>
                         <li><a href="<%=GetUrl("新闻", "usercontrols_newlist.aspx?id=" + item.id ) %>" target="_blank"><%=item.title%></a></li>
                  <%}%>
                  <%}%>
                  <%}%>
             </div>
              <div class="ck_more">
             <a href="<%=GetUrl("新闻公告","usercontrols_Morenewlist.aspx")%>" target="_blank">去看看更多新闻</a>
             </div>
        </div>
       
        <div class="r-bottom">
        </div>
</div>
