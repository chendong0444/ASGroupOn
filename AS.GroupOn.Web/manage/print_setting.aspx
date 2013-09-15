<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    protected IPagers<ITemplate_print> pager = null;
    protected IList<ITemplate_print> iListTeamplate = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
         //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_PrintTemplate))
        {

            SetError("你不具有打印模版列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
  
       Template_printFilter filter=new Template_printFilter();
        
        url = url + "&page={0}";
        url = "print_setting.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(Template_printFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Template_print.GetPager(filter);
        }
        
        iListTeamplate = pager.Objects;
      

        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);

    }
        
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head" style="height:35px;">
                                    <h2>
                                       打印模板
                                       </h2>
<div class="search">
                                
                                 
                                </div>
                                </div>
                                <ul class="filter" >
                                <li>
                                     <a href='<%=PageValue.WebRoot%>manage/ajax_print.aspx?action=add' class="ajaxlink">新建打印模板</a>     
                               </li>
                                    </ul>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                      <tr >
                                              <th width="30%">ID</th>
                                              <th width="35%">打印模版名称</th>
                                              <th width="35%">操作</th>
                                       </tr>

                            <%
                            int i = 0;
                            if (iListTeamplate != null && iListTeamplate.Count > 0)
                            {
                                foreach (ITemplate_print Template_print in iListTeamplate)
                                {
                                    if (i % 2 != 0)
                                    { %>     

                               <tr>
                               <%
}
                                    else
                                    { %>
                             <tr class='alt'>
                          <% 
}
                                    i++;
                                
                           %>
           
                            <td width="20%"><%=Template_print.id%></td>

                            <%if (Template_print.template_name != null)
                              { %>
                            <td width="50%"><%=Template_print.template_name%></td>
                            <%}
                              else
                              { %>
                            <td width="50%"></td>
                            <%} %>
                            <td width="30%"><a class="ajaxlink" href='<%=PageValue.WebRoot%>manage/ajax_print.aspx?action=edit&id=<%=Template_print.id %>'>详情</a>&nbsp;|&nbsp;<a
                         class="ajaxlink" ask="您确认删除此模板吗？" href='<%=PageValue.WebRoot%>manage/ajax_print.aspx?action=delete&id=<%=Template_print.id %>'>删除</a></td>
            </tr>
                                        
                           <%}
                            } %>
                                      
                                        <tr>
                                            <td colspan="8">
                                                <%=pagerHtml %>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
<% LoadUserControl("_footer.ascx", null); %>