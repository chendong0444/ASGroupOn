<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="AS.Common.Utils" %>

<script runat="server">
    protected IPagers<IMailtasks> pager = null;
    protected IList<IMailtasks> iListMailtasks = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_EmailMany_List))
        {
            SetError("你不具有查看群发邮件列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        if (Request["delId"] != null && Request["delId"].ToString() != "")
        {
            Del();
        }
        if (Request["sid"] != null)
        {
            StartMail(Helper.GetInt(Convert.ToInt32(Request["sid"]),0));
        }
        if (Request["deid"] != null)
        {
            ZanTingMail(Helper.GetInt(Convert.ToInt32(Request["deid"]), 0));
        }
        InitData();
    }

    /// <summary>
    /// 邮件群发列表
    /// </summary>
    protected void InitData()
    {
        url = url + "&page={0}";
        url = "MailtasksList.aspx?" + url.Substring(1);

        MailtasksFilter filter = new MailtasksFilter();
        filter.PageSize = 30;
        filter.AddSortOrder(MailtasksFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Mailtasks.GetPager(filter);
        }
        iListMailtasks = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }
    /// <summary>
    /// 删除
    /// </summary>
    protected void Del()
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_EmailMany_Delete))
        {
            SetError("你不具有删除群发邮件的权限！");
            Response.Redirect("MailtasksList.aspx");
            Response.End();
            return;

        }
        else
        {
            int strid = Helper.GetInt(Request["delId"], 0);
            if (strid > 0)
            {
                int delm = 0;
                int delmsp = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    delm = session.Mailtasks.Delete(strid);
                    delmsp = session.Mailserviceprovider.DeleteWhere(strid);
                }
                if (delm > 0 && delmsp > 0)
                {
                    SetSuccess("删除成功");
                }
                Response.Redirect("MailtasksList.aspx");
                Response.End();
                return;
            }
        }
    }

    /// <summary>
    /// 发送
    /// </summary>
    /// <param name="id"></param>
    protected void StartMail(int id)
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_YX_EmailMany_Send))
        {
            SetError("你不具有群发邮件发送的权限！");
            Response.Redirect("MailtasksList.aspx");
            Response.End();
            return;

        }
        else
        {
            IList<IMailserver> imailserverlist = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                imailserverlist = session.Mailserver.GetList(null);
            }
            if (imailserverlist == null || imailserverlist.Count == 0)
            {
                SetError("请您设置邮件群发服务");
                Response.Redirect("MailServerList.aspx");
                Response.End();
                return;
            }
            IMailtasks imailtasks = null;
            IList<IMailtasks> iListMailtasks = null;
            MailtasksFilter mailtasksfilter = new MailtasksFilter();
            mailtasksfilter.state = 1;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iListMailtasks = session.Mailtasks.GetList(mailtasksfilter);
            }
            if (iListMailtasks != null && iListMailtasks.Count > 0)//邮件任务中有正在发送的邮件，那么其他的邮件无法进行发送
            {
                SetError("友情提示：邮件正在发送中，当前邮件无法进行发送，请稍后．．．．");
            }
            else
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    imailtasks = session.Mailtasks.GetByID(id);
                    imailtasks.state = 1;
                    session.Mailtasks.Update(imailtasks);
                    SetSuccess("友情提示：邮件正在发送中，请稍后．．．．");
                }
            }
        }
    }

    /// <summary>
    /// 暂停
    /// </summary>
    /// <param name="id"></param>
    protected void ZanTingMail(int id)
    {
        IMailtasks imailtasks = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            imailtasks = session.Mailtasks.GetByID(id);
            imailtasks.state = 3;
            session.Mailtasks.Update(imailtasks);
            SetSuccess("友情提示：邮件正在发送中，请稍后．．．．");
        }
    }
    
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons" >
             
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head" style="height:35px;">
                                    <h2>
                                        邮件群发</h2>
                                    
                                </div><ul class="filter">
                                        <li>
                                            <a href="Addmailtasks.aspx">新增群发邮件</a>
                                        </li>
                                    </ul>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='10%'>
                                                ID
                                            </th>
                                            <th width='15%'>
                                                标题
                                            </th>
                                            <th width='10%'>
                                                预览邮件内容
                                            </th>
                                            <th width='10%'>
                                                已发送数量
                                            </th>
                                            <th width='10%'>
                                                发送总数量
                                            </th>
                                            <th width='10%'>
                                                已阅读的数量
                                            </th>
                                            <th width='10%'>
                                                邮件状态
                                            </th>
                                            <th width='10%'>
                                                城市
                                            </th>
                                            <th width='15%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListMailtasks != null && iListMailtasks.Count > 0)
                                          {
                                              
                                               int i = 0;
                                               foreach (IMailtasks mailtasksInfo in iListMailtasks)
                                              {
                                                  if (i % 2 != 0)
                                                  {
                                        %>
                                        <tr>
                                        <%
                                                  }
                                                  else
                                                  {
                                        %>
                                        <tr class='alt'>
                                        <%
                                                  }
                                            i++;
                                        %>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=mailtasksInfo.id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=mailtasksInfo.subject%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <a href="SeePage.aspx?id=<%=mailtasksInfo.id %>" target="_blank">预览内容</a>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=mailtasksInfo.sendcount%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=mailtasksInfo.totalcount%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=mailtasksInfo.readcount%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%if (mailtasksInfo.state == 0)
                                                    { %>
                                                未发送
                                                <% }
                                                      else if (mailtasksInfo.state == 1)
                                                    {%>
                                                    正在发送
                                                <% }
                                                      else if (mailtasksInfo.state == 2)
                                                    {%>
                                                    发送完毕
                                                <% }
                                                      else if (mailtasksInfo.state == 3)
                                                    {%>
                                                    已暂停
                                                <% }
                                                      else if (mailtasksInfo.state == 4)
                                                    {%>
                                                    已取消
                                                <% }%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=mailtasksInfo.City %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <a href="Addmailtasks.aspx?updateId=<%=mailtasksInfo.id%>" >编辑</a> | 
                                                    <a ask="确定删除此邮件吗？" href="MailtasksList.aspx?delId=<%=mailtasksInfo.id%>" >删除</a> 
                                                    <%if (mailtasksInfo.state == 0)
                                                      { %>|
                                                    <a href="MailtasksList.aspx?sid=<%=mailtasksInfo.id%>">发送</a> 
                                                    <% }
                                                      else if (mailtasksInfo.state == 1)
                                                      {%>|
                                                      <a href="MailtasksList.aspx?deid=<%=mailtasksInfo.id%>">暂停</a>
                                                    <% }%>
                                                </div>
                                            </td>
                                        </tr>
                                        <%       
                                            }
                                          } %>
                                        <tr>
                                            <td colspan="9">
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