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
    protected IPagers<IMailserver> pager = null;
    protected IList<IMailserver> iListMailserver = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Email_SentManyService_List))
        {
            SetError("你不具有查看群发邮件服务设置列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        if (Request["delId"] != null && Request["delId"].ToString() != "")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Email_SentManyService_Delete))
            {
                SetError("你不具有删除群发邮件服务设置的权限！");
                Response.Redirect("MailServerList.aspx");
                Response.End();
                return;

            }
            else
            {
                Del();
            }
        }
        //发送测试
        if (Request["sendid"] != null)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Email_SentManyService_TestSend))
            {
                SetError("你不具有群发邮件发送测试的权限！");
                Response.Redirect("MailServerList.aspx");
                Response.End();
                return;

            }
            else
            {
                SendMail(Helper.GetInt(Request["sendid"], 0));
            }
        }
        InitData();
    }

    /// <summary>
    /// 绑定友群发邮件设置列表
    /// </summary>
    protected void InitData()
    {
        url = url + "&page={0}";
        url = "MailServerList.aspx?" + url.Substring(1);
        MailserverFilter filter = new MailserverFilter();
        filter.PageSize = 30;
        filter.AddSortOrder(MailserverFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Mailserver.GetPager(filter);
        }
        iListMailserver = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }
    /// <summary>
    /// 删除
    /// </summary>
    protected void Del()
    {
        int strid = Helper.GetInt(Request["delId"], 0);
        if (strid > 0)
        {
            int del_id = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                del_id = session.Mailserver.Delete(strid);
            }
            if (del_id > 0)
            {
                SetSuccess("删除成功");
            }
            Response.Redirect("MailServerList.aspx");
            Response.End();
            return;
        }
    }
    /// <summary>
    /// 测试发送邮件
    /// </summary>
    /// <param name="senid"></param>
    public void SendMail(int senid)
    {
        IMailserver imailserver = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            imailserver = session.Mailserver.GetByID(senid);
            List<string> address = new List<string>();
            address.Add(imailserver.receivemail);
            if (EmailMethod.sendMail("test标题", "test", imailserver.sendmail, imailserver.sendmail, address, imailserver.smtphost, imailserver.mailuser, imailserver.mailpass))
            {
                SetSuccess("友情提示：测试邮件发送成功");
            }
            else
            {
                SetError("友情提示：测试邮件发送失败");
            }
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
                                        群发邮件设置</h2>
                                    
                                </div><ul class="filter">
                                        <li>
                                             <a href="AddMailServer.aspx">新建群发邮件服务</a>
                                        </li>
                                    </ul>
                                <div class="sect">
                                   
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='10%'>
                                                ID
                                            </th>
                                            <th width='15%'>
                                                SMTP主机
                                            </th>
                                            <th width='15%'>
                                                SMTP端口
                                            </th>
                                            <th width='15%'>
                                                发信地址
                                            </th>
                                            <th width='15%'>
                                                回信地址
                                            </th>
                                            <th width='15%'>
                                                最多发送数量
                                            </th>
                                            <th width='15%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListMailserver != null && iListMailserver.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (IMailserver mailserverInfo in iListMailserver)
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
                                                    <%=mailserverInfo.id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=mailserverInfo.smtphost%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=mailserverInfo.smtpport%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=mailserverInfo.sendmail%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=mailserverInfo.receivemail%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=mailserverInfo.sendcount%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <a href="AddMailServer.aspx?updateId=<%=mailserverInfo.id%>" >编辑</a> |
                                                    <a ask="确定删除此邮件服务吗？" href="MailServerList.aspx?delId=<%=mailserverInfo.id%>" >删除</a> |
                                                    <a  href="MailServerList.aspx?sendid=<%=mailserverInfo.id%>" >发送测试</a>
                                                </div>
                                            </td>
                                        </tr>
                                        <%       
                                            }
                                          } %>
                                        <tr>
                                            <td colspan="7">
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