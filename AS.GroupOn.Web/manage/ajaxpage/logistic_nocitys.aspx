<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

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
    protected int expressid = 0;
    
    protected FarecitysFilter filter = new FarecitysFilter();
    protected IList<IFarecitys> ilistfarecitys = null;
    protected IList<Hashtable> table = null;
    protected string expressids = String.Empty; //不能送到的城市ID 1,2,3,4,5 格式
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        pid = Helper.GetInt(Request["pid"], 0);
        expressid = Helper.GetInt(Request["expressid"], 0);
        filter.pid = pid;
        
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            table = session.Farecitys.GetByPid(filter);
        }
       
        ExpressnocitysFilter exfilter = new ExpressnocitysFilter();
        IList<IExpressnocitys> ilistexpre = null;
        exfilter.expressid = expressid;
        exfilter.AddSortOrder(ExpressnocitysFilter.ID_ASC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistexpre = session.Expressnocitys.GetList(exfilter);
        }
        if (ilistexpre != null)
        {
            foreach(IExpressnocitys expre in ilistexpre)
            {
                expressids = expre.nocitys.ToString();
                expressids = "," + expressids + ",";
            }
        
        }
        
        
        
    } 


</script>

<script src="../../upfile/js/jquery.contextmenu.r2-min.js" type="text/javascript"></script>
<script src="../../upfile/js/jquery.simple.tree.js" type="text/javascript"></script>
<%if (table != null)
  {
      foreach (Hashtable dt in table)
      {%>
     <li id='cityid_<%=dt["id"] %>' pid="<%=dt["pid"] %>" ><span><%=dt["name"] %></span><input type="checkbox" name="check_<%=dt["id"] %>" id="check_<%=dt["id"] %>" <%if(expressids.IndexOf(","+dt["id"].ToString()+",")>=0){ %>checked="checked"<%} %> onchange="nocitychange('<%=dt["id"] %>','<%=expressid %>')" /><label id='lab_<%=dt["id"] %>'></label>
			  <%if (Convert.ToInt32(dt["cid"]) > 0)
       { %>
					    <ul class="ajax">
							<li id='4'>{url:<%=PageValue.WebRoot%>manage/ajaxpage/logistic_nocitys.aspx?pid=<%=dt["id"]%>&expressid=<%=expressid %>}</li>
						</ul>
           <% }%>             
</li>
      <%}
  } %>
  <script type="text/javascript">
      function nocitychange(id, expressid) {
          if ($("#check_" + id).attr("checked")) {
              X.get("<%=PageValue.WebRoot %>manage/ajax_manage.aspx?action=nocitysedit&act=no&id=" + expressid + "&cityid=" + id);
          }
          else { 
              X.get("<%=PageValue.WebRoot %>manage/ajax_manage.aspx?action=nocitysedit&act=yes&id=" + expressid + "&cityid=" + id);
          }
      }
</script>