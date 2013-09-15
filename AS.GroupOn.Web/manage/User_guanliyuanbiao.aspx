<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    protected IPagers<IUser> pager = null;
    protected IList<IUser> iListUsers = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Admin_List))
        {
            SetError("你不具有查看管理员列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        UserFilter filter = new UserFilter();
        filter.Manager = "Y";
        
        url = url + "&page={0}";
        url = "User_guanliyuanbiao.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(UserFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Users.GetPager(filter);
        }
        iListUsers = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }
    
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" method="post" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    
                    <div id="content" class="box-content clear mainwide"">
                        <div class="box clear>
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        管理员列表</h2>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='10%'>
                                                ID
                                            </th>
                                            <th width='15%'>
                                                Email
                                            </th>
                                            <th width='15%'>
                                                用户名
                                            </th>
                                            <th width='10%'>
                                                姓名
                                            </th>
                                            <th width='10%'>
                                                注册时间
                                            </th>
                                            <th width='8%'>
                                                手机号码
                                            </th>
                                             <th width='8%'>
                                               管理员分站
                                            </th>
                                            <th width='15%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListUsers != null && iListUsers.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (IUser userinfo in iListUsers)
                                              {
                                                  if(userinfo.Username=="shjk" || userinfo.Username=="eric")
                                                    continue;
                                                    
                                                  if (i % 2 == 0)
                                                  {%>
                                                  <tr>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=userinfo.Id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=userinfo.Email%></div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=userinfo.Username%></div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=userinfo.Realname%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=userinfo.Create_time%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=userinfo.Mobile%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                <%if (userinfo.IsManBranch=="Y")
                                                  {
                                                      ICategory cacity = null;
                                                       using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                        {
                                                            cacity = session.Category.GetByID(userinfo.City_id);
                                                        }
                                                       if (cacity!=null)
                                                       {
                                                           %>
                                                           <%=cacity.Name %>
                                                           <%
                                                       }
                                                  } %>
                                                    
                                                </div>
                                            </td>
                                            <td>
                                            
                                                <a class="remove-record" href="User_Bianji.aspx?id=<%=userinfo.Id %>">编辑</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a
                                                  class='ajaxlink'  href="ajax_manage.aspx?action=authorization&authorization=<%=userinfo.Id %>">授权</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a
                                                  class='ajaxlink'  href="ajax_manage.aspx?action=adminfenzhan&adminfenzhan=<%=userinfo.Id %>">管理员分站</a>
                                            </td>
                                        </tr>
                                                  <%}
                                                  else
                                                  {%>
                                                  <tr class="alt">
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=userinfo.Id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=userinfo.Email %></div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=userinfo.Username%></div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=userinfo.Realname %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=userinfo.Create_time %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=userinfo.Mobile %>
                                                </div>
                                            </td>
                                             <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                <%if (userinfo.IsManBranch=="Y")
                                                  {
                                                      ICategory cacity = null;
                                                       using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                        {
                                                            cacity = session.Category.GetByID(userinfo.City_id);
                                                        }
                                                       if (cacity!=null)
                                                       {
                                                           %>
                                                           <%=cacity.Name %>
                                                           <%
                                                       }
                                                  } %>
                                                    
                                                </div>
                                            </td>
                                            <td>
                                            
                                                <a class="remove-record" href="User_Bianji.aspx?id=<%=userinfo.Id %>">编辑</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a
                                                  class='ajaxlink'  href="ajax_manage.aspx?action=authorization&authorization=<%=userinfo.Id %>">授权</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a
                                                  class='ajaxlink'  href="ajax_manage.aspx?action=adminfenzhan&adminfenzhan=<%=userinfo.Id %>">管理员分站</a>
                                            </td>
                                        </tr>
                                                  <%}
                                                  i++;     
                                              }
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
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>