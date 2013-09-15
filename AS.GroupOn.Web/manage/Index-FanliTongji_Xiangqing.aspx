<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Data" %>

<script runat="server">
    protected IPagers<IInvite> pager = null;
    protected IList<IInvite> iListInvite = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected InviteFilter filter = new InviteFilter();

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Invite_TongjiDetail))
        {
            SetError("你不具有查看邀请统计详情的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        if (Request["btnselect"] == "筛选")
        {
            SelectWhere();
        }
        getTitle();
        getContent();
    }
    protected void getTitle()
    {
        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<tr >");
        sb1.Append("<th width='70%'>项目</th>");
        sb1.Append("<th width='15%'>被邀用户</th>");
        sb1.Append("<th width='15%'>邀买时间</th>");
        sb1.Append("</tr>");
        Literal1.Text = sb1.ToString();
    }
    protected void getContent()
    {
        int id = Helper.GetInt(HttpContext.Current.Request["Id"], 0);

        url = url + "&page={0}";
        url = "Index-FanliTongji_Xiangqing.aspx?" + url.Substring(1);
        url = url + "&Id=" + id;
        filter.PageSize = 30;
        filter.AddSortOrder(InviteFilter.Buy_time_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        filter.User_id = id;
        filter.TeamidNotZero = 1;

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Invite.GetPager(filter);
        }
        iListInvite = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);

        StringBuilder sb2 = new StringBuilder();
        int p = 0;
        foreach (IInvite iinviteInfo in iListInvite)
        {
            if (p % 2 == 0)
            {
                sb2.Append("<tr class='alt' >");
            }
            else
            {
                sb2.Append("<tr>");
            }

            sb2.Append("<td><a class='deal-title' href='" + getTeamPageUrl(iinviteInfo.Team_id) + "' target='_blank'><b>项目ID:" + iinviteInfo.Team_id + "</b> " + iinviteInfo.Team.Title + "</td>");
            sb2.Append("<td style=' color:red; text-align:left'>&nbsp;" + iinviteInfo.OtherUser.Username + "</td>");
            sb2.Append("<td>" + iinviteInfo.Buy_time.ToString() + "</td>");
            sb2.Append("</tr>");
            p++;
        }
        Literal2.Text = sb2.ToString();
    }

    /// <summary>
    /// 筛选条件
    /// </summary>
    public void SelectWhere()
    {
        if (!string.IsNullOrEmpty(Request["startTime"]) && !string.IsNullOrEmpty(Request["endTime"]))
        {
            filter.FromBuy_time = Helper.GetDateTime(Request["startTime"], DateTime.Now);
            filter.ToBuy_time = Helper.GetDateTime(Request["endTime"], DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request["memail"]))
        {
            string selTxt = Request["memail"];
            if (!string.IsNullOrEmpty(Request["ddlState"]))
            {
                string selItem = Request["ddlState"];
                if (selItem == "1")  //被邀用户名
                {
                    IUser user = null;
                    UserFilter userfilter = new UserFilter();
                    if (Regex.IsMatch(selTxt.Trim(), @"^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$", RegexOptions.IgnoreCase))
                    {
                        userfilter.Email = selTxt.Trim();
                    }
                    else
                    {
                        userfilter.Username = selTxt.Trim();
                    }
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        user = session.Users.Get(userfilter);
                    }
                    if (user != null)
                    {
                        filter.Other_user_id = user.Id;
                    }
                    else
                    {
                        SetError("没有找到 此用户的被邀信息 !");
                    }
                }
                else if (selItem == "2") //项目ID
                {
                    if (NumberUtils.IsNum(selTxt))
                    {
                        filter.Team_id = Convert.ToInt32(selTxt.Trim());
                    }
                    else
                    {
                        SetError("项目ID 必须为数字！");
                    }
                }
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
                <div id="coupons">
                    <div class="dashboard" id="dashboard">
                      
                    </div>
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>邀请统计详情</h2>
                                    <div class="search">
                                         时&nbsp;间：
                                            <input type="text" readonly="readonly" value='<%=Request["startTime"] %>' name="startTime"
                                                onfocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});" class="date" style="width: 110px" />到&nbsp;&nbsp;&nbsp;<input
                                                    type="text" readonly="readonly" name="endTime" value='<%=Request["endTime"] %>'
                                                    onfocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});"  class="date" style="width: 110px" />
                                            <select name="ddlState">
                                                <option value="0">请选择</option>
                                                <option value="1">用户名</option>
                                                <option value="2">项目ID</option>
                                            </select>
                                            &nbsp;
                                            <input type="text" name="memail" value='<%=Request["memail"] %>' class="h-input" />&nbsp;<input
                                                type="submit" value="筛选" class="formbutton" name="btnselect" style="padding: 1px 6px;" />
                                        <ul class="filter"></ul>
                                    </div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="7">
                                                <ul class="paginator">
                                                    <li class="current">
                                                        <%=pagerHtml%>
                                                    </li>
                                                </ul>
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
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
