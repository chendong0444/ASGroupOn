<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

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
    protected int pid = 0;
    protected FarecitysFilter filter = new FarecitysFilter();
    protected IList<IFarecitys> ilistfarecitys = null;
    protected IList<Hashtable> table = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        pid = Helper.GetInt(Request["pid"], 0);
        filter.pid = pid;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            table = session.Farecitys.GetByPid(filter);
        }


    }
</script>
<%if (table != null)
  {
      foreach (Hashtable dt in table)
      {%>
<li id='cityid_<%=dt["id"] %>' pid="<%=dt["pid"] %>"><span>
    <%= dt["name"] %></span>
    <%if (Convert.ToInt32(dt["cid"]) > 0)
      { %>
    <ul class="ajax">
        <li id='4'>{url:<%=PageValue.WebRoot%>ajax/logistic_citys.aspx?action=query&id=<%=dt["id"]%>}</li>
    </ul>
    <% }%>
</li>
<%}
  } %>