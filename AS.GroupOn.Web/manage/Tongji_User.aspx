<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

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
    protected string url = "";
    protected UserFilter filter = new UserFilter();
    protected string pagerHtml = String.Empty;
    protected IPagers<IUser> pager = null;
    protected IList<IUser> list_user = null;
    protected StringBuilder sb1 = new StringBuilder();
    protected StringBuilder sb2 = new StringBuilder();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TJ_User_Reg_Source))
        {
            SetError("你不具有查看用户注册来源统计的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (!string.IsNullOrEmpty(Request.QueryString["begintime"]))
        {
            url = url + "&begintime=" + Request.QueryString["begintime"];
            filter.FromCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["begintime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
        {
            url = url + "&endtime=" + Request["endtime"];
            filter.ToCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
        }
        sb1.Append("<tr >");
        sb1.Append("<th width='10%'>ID</th>");
        sb1.Append("<th width='20%'>Email/用户名</th>");
        sb1.Append("<th width='20%' nowrap>姓名/城市</th>");
        sb1.Append("<th width='10%'>注册时间</th>");
        sb1.Append("<th width='20%'>来源地址</th>");
        sb1.Append("<th width='10%'>联系电话</th>");
        sb1.Append("<th width='10%'>操作</th>");
        sb1.Append("</tr>");
        url = url + "&page={0}";
        url = "Tongji_User.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(UserFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Users.GetPager(filter);
        }
        list_user = pager.Objects;
        ICategory c = Store.CreateCategory();
        int i = 0;
        if (list_user != null)
        {
            foreach (var item in list_user)
            {
                c = item.Category;
                if (i % 2 != 0)
                    sb2.Append("<tr>");
                else
                    sb2.Append("<tr class='alt'>");
                i++;
                sb2.Append("<td>" + item.Id + "</td>");
                sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 200px;'>");
                if (item.Email != "")
                    sb2.Append(item.Email + "/");
                else
                    sb2.Append("&nbsp;/");
                sb2.Append("" + item.Username);
                sb2.Append("</div></td>");
                if (item.Realname != "" && c != null)
                {
                    sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 100px;'>" + item.Realname + "/" + c.Name + "</div></td>");
                }
                else if (item.Realname == "" && c != null)
                {
                    sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 100px;'>" + c.Name + "</div></td>");
                }
                else if (item.Realname != "" && c == null)
                {
                    sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 100px;'>" + item.Realname + "</div></td>");
                }
                else
                {
                    sb2.Append("<td>&nbsp;</td>");
                }
                sb2.Append("<td>" + item.Create_time + "</td>");
                if (!string.IsNullOrEmpty(item.IP_Address))
                {
                    if (item.IP_Address.Trim() == "直接输入网址")
                        sb2.Append("<td style='color:red;'>直接输入网址</td>");
                    else
                        sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 140px;'><a target='_blank' href='" + item.IP_Address + "' alt='" + item.IP_Address + "'>" + item.IP_Address + "</a></td>");
                }
                else
                {
                    sb2.Append("<td>&nbsp;</td>");
                }
                if (item.Mobile != "")
                    sb2.Append("<td>" + item.Mobile + "</td>");
                else
                    sb2.Append("<td>&nbsp;</td>");
                sb2.Append("<td>");
                sb2.Append("<a class='ajaxlink' href='ajax_manage.aspx?action=userview&Id=" + item.Id + "'>详情</a>");
                sb2.Append("</td>");
            }
        }
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        Literal2.Text = sb2.ToString();
        Literal1.Text = sb1.ToString();
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <div>
    </div>
    <div>
    </div>
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div class="dashboard" id="dashboard">
                    </div>
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        用户注册来源统计</h2>
                                    <form runat="server" method="get">
                                    <div class="lie_fl">
                                        筛选条件：注册日期：<input type="text" class="h-input" datatype="date" name="begintime" style="margin-right: 0px;"
                                            <%if(!string.IsNullOrEmpty(Request.QueryString["begintime"])){ %>value="<%=Request.QueryString["begintime"] %>"
                                            <%} %> />--<input type="text" class="h-input" datatype="date" name="endtime" <%if(!string.IsNullOrEmpty(Request.QueryString["endtime"])){ %>value="<%=Request.QueryString["endtime"] %>"
                                                <%} %> />&nbsp;<input type="submit" name="search" value="统计" class="formbutton" group="go"
                                                    style="padding: 1px 6px; width: 60px;" />
                                    </div>
                                    </form>
                                    <div class="lie_fl">
                                    </div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table"
                                      >
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="10">
                                                <%=pagerHtml%>
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
<%LoadUserControl("_footer.ascx", null); %>