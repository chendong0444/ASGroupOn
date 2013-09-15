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
    protected IPagers<IInvite> pager = null;
    protected IList<IInvite> iListInvite = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected InviteFilter filter = new InviteFilter();
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Rebate_ListView))
        {
            SetError("你不具有查看返利日志列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        if (Request["saiXuan"] == "筛选")
        {
            SelectWhere();
        }
        fanLiRecord();
    }
    /// <summary>
    /// 返利记录
    /// </summary>
    private void fanLiRecord()
    {
        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<tr >");
        sb1.Append("<th width='48%'>项目</th>");
        sb1.Append("<th width='15%'>主动用户</th>");
        sb1.Append("<th width='15%'>被邀用户</th>");
        sb1.Append("<th width='12%'>邀买时间</th>");
        sb1.Append("<th width='10%'>操作员</th>");
        sb1.Append("</tr>");

        /*---------------获取返利记录---------begin-----------------------------------------*/
        url = url + "&page={0}";
        url = "Index-FanliRecord.aspx?" + url.Substring(1);
        filter.FromCredit = 0;//返利记录
        filter.PageSize = 30;
        filter.AddSortOrder(InviteFilter.Buy_time_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Invite.GetPager(filter);
        }
        iListInvite = pager.Objects;
        /*---------------获取返利记录--------end------------------------------------------*/
        
        int i = 0;
        StringBuilder sb2 = new StringBuilder();
        foreach (IInvite inviteInfo in iListInvite)
        {
            if (i % 2 != 0)
            {
                sb2.Append("<tr>");
            }
            else
            {
                sb2.Append("<tr class='alt'>");
            }
            i++;
            //项目
            if (inviteInfo.Team != null)
            {
                sb2.Append("<td><a class='deal-title' href='" + getTeamPageUrl(inviteInfo.Team.Id) + "' target='_blank'><b>项目ID:" + inviteInfo.Team.Id + "</b>  " + inviteInfo.Team.Title + "</td>");
            }
            else
            {
                sb2.Append("<td>");
                int num = 0;
                foreach (IOrderDetail orderdetailInfo in inviteInfo.OrderDetails)
                {
                    num++;
                    sb2.Append("(<a class='deal-title' href='" + getTeamPageUrl(orderdetailInfo.Teamid) + "' target='_blank'>" + num + ":");
                    sb2.Append(orderdetailInfo.Team == null ? "" : orderdetailInfo.Team.Title + "<font style='color:red'>(" + orderdetailInfo.Num + "件)</font>");
                    sb2.Append("</a>)<br>");
                }
                sb2.Append("</td>");
            }
            //主动用户
            if (inviteInfo.Users != null && inviteInfo.Users.Count > 0)
            {
                foreach (IUser userInfo in inviteInfo.Users)
                {
                    sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 150px;'>");
                    sb2.Append("<font style='color:red'>" + userInfo.Email + "</font><br>");
                    sb2.Append("<a class='ajaxlink' href='ajax_manage.aspx?action=userview&Id=" + userInfo.Id + "'>" + userInfo.Username + "</a><br>");
                    sb2.Append(userInfo.IP + "<br>");
                    sb2.Append("<font style='color:red'>" + userInfo.Mobile + "</font>");
                    sb2.Append("</div></td>");
                }
            }
            else
            {
                sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 150px;'>&nbsp;</div></td>");
            }
            //被邀用户|邀买时间|操作员
            if (inviteInfo.Other_user_id != 0 && inviteInfo.OtherUser != null)
            {
                sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 150px;'>");
                sb2.Append("<font style='color:red'>" + inviteInfo.OtherUser.Email + "</font><br>");
                sb2.Append("<a class='ajaxlink' href='ajax_manage.aspx?action=userview&Id=" + inviteInfo.OtherUser.Id + "'>" + inviteInfo.OtherUser.Username + "</a><br>");
                sb2.Append(inviteInfo.OtherUser.IP + "<br>");
                sb2.Append("<font style='color:red'>" + inviteInfo.OtherUser.Mobile + "</font>");
                sb2.Append("</div></td>");
                sb2.Append("<td>" + inviteInfo.Create_time + "</td>");

                IList<IUser> iListUser = null;
                UserFilter userfilter = new UserFilter();
                userfilter.ID = inviteInfo.Admin_id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iListUser = session.Users.GetList(userfilter);
                }
                if (iListUser != null)
                {
                    foreach (IUser iuserInfo in iListUser)
                    {
                        sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 150px;'>" + iuserInfo.Username + "</div></td>");
                    }
                }
                else
                {
                    sb2.Append("<td>&nbsp;</td>");
                }

            }
            else
            {
                sb2.Append("<td>&nbsp;</td>");
                sb2.Append("<td>&nbsp;</td>");
                sb2.Append("<td>&nbsp;</td>");
            }

            sb2.Append("</tr>");
        }
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();
    }

    ///// <summary>
    ///// 筛选条件
    ///// </summary>
    public void SelectWhere()
    {
        if (!string.IsNullOrEmpty(Request["startTime"]))
        {
            url = url + "&startTime=" + Request["startTime"];
            filter.FromCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request["startTime"]).ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now);
        }
        if (!string.IsNullOrEmpty(Request["endTime"]))
        {
            url = url + "&endTime=" + Request["endTime"];
            filter.ToCreate_time = Helper.GetDateTime(Convert.ToDateTime(Request["endTime"]).ToString("yyyy-MM-dd HH:mm:ss"), DateTime.Now);
        }

        if (!string.IsNullOrEmpty(Request["ddlState"]))
        {
            url = url + "&ddlState=" + Request["ddlState"];
            string ddlState = Request["ddlState"];

            if (ddlState == "1")//项目ID
            {
                filter.Team_id = Helper.GetInt(Request["txtcontent"], 0);
            }
            if (ddlState == "2")//邀请人用户名
            {
                IUser iuser = null;
                UserFilter userfilter = new UserFilter();
                userfilter.Username = Helper.GetString(Request["txtcontent"], String.Empty);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iuser = session.Users.GetByName(userfilter);
                }
                filter.User_id = iuser.Id;
            }
            if (ddlState == "3")//被邀请人用户名
            {
                IUser iuser = null;
                UserFilter userfilter = new UserFilter();
                userfilter.LoginName = Helper.GetString(Request["txtcontent"], String.Empty);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    iuser = session.Users.Get(userfilter);
                }
                filter.Other_user_id = iuser.Id;
            }
            url = url + "&txtcontent=" + Request["txtcontent"];
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
                    
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>返利记录</h2>
                                    <div class="search">
                                    时&nbsp;间：
                                            <input type="text"  name="startTime" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});" class="date" style="width: 110px" 
                                            <%if(!string.IsNullOrEmpty(Request.QueryString["startTime"])){ %>value="<%=Request.QueryString["startTime"] %>" <%} %> />到&nbsp;&nbsp;&nbsp;
                                            <input type="text" name="endTime" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});" class="date" style="width: 110px" 
                                            <%if(!string.IsNullOrEmpty(Request.QueryString["endTime"])){ %>value="<%=Request.QueryString["endTime"] %>" <%} %> />
                                             <select name="ddlState">
                                                <option value="0">请选择</option>
                                                <option value="1" <%if(Request.QueryString["ddlState"] == "1"){ %>selected="selected" <%} %>>项目ID</option>
                                                <option value="2" <%if(Request.QueryString["ddlState"] == "2"){ %>selected="selected" <%} %>>邀请人用户名</option>
                                                <option value="3" <%if(Request.QueryString["ddlState"] == "3"){ %>selected="selected" <%} %>>被邀请人用户名</option>
                                            </select>&nbsp;&nbsp;
                                            <input type="text" name="txtcontent" class="h-input"
                                            <%if(!string.IsNullOrEmpty(Request.QueryString["txtcontent"])){ %>value="<%=Request.QueryString["txtcontent"] %>" <%} %>  />&nbsp;
                                            <input type="submit" value="筛选" class="formbutton" name="saiXuan" style="padding: 1px 6px;" />
                                    <ul class="filter">
                                     
                                    </ul></div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="8">
                                                <%=pagerHtml%>
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
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
