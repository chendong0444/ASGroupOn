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
    protected IPagers<ICoupon> pager = null;
    protected IList<ICoupon> list_coupon = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected string date_type = "";
    protected string where_type = "";
    protected CouponFilter filter = new CouponFilter();
    protected override void OnLoad(EventArgs e)
    {
        
        base.OnLoad(e);
       
        if (!string.IsNullOrEmpty(Request.QueryString["date_type"]))
        {
            url = url + "&date_type=" + Request.QueryString["date_type"];
            date_type = Request.QueryString["date_type"];
            if (date_type == "1")
            {
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
            }
            else if (date_type == "2")
            {
                if (!string.IsNullOrEmpty(Request.QueryString["begintime"]))
                {
                    url = url + "&begintime=" + Request.QueryString["begintime"];
                    filter.FromStart_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["begintime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
                }
                if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
                {
                    url = url + "&endtime=" + Request["endtime"];
                    filter.ToStart_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
                }
            }
            else if (date_type == "4")
            {
                if (!string.IsNullOrEmpty(Request.QueryString["begintime"]))
                {
                    url = url + "&begintime=" + Request.QueryString["begintime"];
                    filter.FromExpire_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["begintime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
                }
                if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
                {
                    url = url + "&endtime=" + Request["endtime"];
                    filter.ToExpire_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
                }
            }
            else if (date_type == "8")
            {
                if (!string.IsNullOrEmpty(Request.QueryString["begintime"]))
                {
                    url = url + "&begintime=" + Request.QueryString["begintime"];
                    filter.FromConsume_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["begintime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
                }
                if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
                {
                    url = url + "&endtime=" + Request["endtime"];
                    filter.ToConsume_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
                }
            }
        }
        if (!string.IsNullOrEmpty(Request.QueryString["where_type"]))
        {
            IUser uses = null;
            UserFilter u_filter = new UserFilter();
            url = url + "&where_type=" + Request.QueryString["where_type"];
            where_type = Request.QueryString["where_type"];
            if (where_type == "1")
            {
                filter.Team_id = Helper.GetInt(Request.QueryString["type_name"], 0);
            }
            else if (where_type == "2" || where_type == "4" || where_type == "32")
            {
                if (where_type == "2")
                {
                    u_filter.Username = Helper.GetString(Request.QueryString["type_name"], String.Empty);
                }
                else if (where_type == "4")
                {
                    u_filter.Email = Helper.GetString(Request.QueryString["type_name"], String.Empty);
                }
                else
                {
                    u_filter.Mobile = Helper.GetString(Request.QueryString["type_name"], String.Empty);
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    uses = session.Users.Get(u_filter);
                }
                if (uses != null)
                    filter.User_id = uses.Id;
            }
            else if (where_type == "8")
            {
                filter.Partner_id = Helper.GetInt(Request.QueryString["type_name"], 0);
            }
            else if (where_type == "16")
            {
                filter.Id = Helper.GetString(Request.QueryString["type_name"], String.Empty);
            }
            url = url + "&type_name=" + Request.QueryString["type_name"];
        }
        InitData();
    }
    private void InitData()
    {
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        sb1.Append("<tr >");
        sb1.Append("<th width='10%'>编号</th>");
        sb1.Append("<th width='30%'>项目</th>");
        sb1.Append("<th width='10%'>用户</th>");
        sb1.Append("<th width='10%'>开启时间  |  过期时间</th>");
        sb1.Append("<th width='10%' >消费时间</th>");
        sb1.Append("<th width='10%' >短信</th>");
        sb1.Append("<th width='20%'>操作</th>");
        sb1.Append("</tr>");
        url = url + "&page={0}";
        url = "Youhui_YiXiaofei.aspx?" + url.Substring(1);
        filter.Consume = "Y";
        filter.PageSize = 30;
        filter.AddSortOrder(CouponFilter.Create_time_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        filter.inOrder_id = AsAdmin.City_id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Coupon.GetPager(filter);
        }
        list_coupon = pager.Objects;
        IUser user = Store.CreateUser();
        ITeam team = Store.CreateTeam();
        int i = 0;
        foreach (ICoupon coupon in list_coupon)
        {
            user = coupon.User;
            team = coupon.Team;
            if (i % 2 != 0)
            {
                sb2.Append("<tr>");
            }
            else
            {
                sb2.Append("<tr class='alt'>");
            }
            i++;
            sb2.Append("<td>" + coupon.Id + "</td>");
            sb2.Append("<td>" + team.Id + "&nbsp;(<a class='deal-title' href='" + getTeamPageUrl(coupon.Team_id) + "' target='_blank'>" + team.Title + "</a>)</td>");
            sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 180px;'>" + user.Email + "<br/>" + user.Username + "</div></td>");
            sb2.Append("<td nowrap>" + ((coupon.start_time.HasValue) ? coupon.start_time.Value.ToString("yyyy-MM-dd HH:mm:ss") : String.Empty) + "</br>" + coupon.Expire_time.ToString("yyyy-MM-dd HH:mm:ss") + "</td>");
            if (coupon.Consume_time != null)
            {
                sb2.Append("<td nowrap>" + coupon.Consume_time + "</td>");
            }
            else if (coupon.Consume == "N" && coupon.Expire_time >= DateTime.Now)
            {
                sb2.Append("<td nowrap>未消费</td>");
            }
            else if (coupon.Consume == "N" && coupon.Expire_time < DateTime.Now)
            {
                sb2.Append("<td nowrap>已过期</td>");
            }
            sb2.Append("<td>" + coupon.Sms + "</td>");
            if (coupon.Consume == "N" && coupon.Expire_time >= DateTime.Now)
            {
                sb2.Append("<td class='op'><a href='ajax_coupon.aspx?action=sms&&csecret=" + coupon.Secret + "&id=" + coupon.Id + "' class='ajaxlink'>短信</a> | ");
                sb2.Append("<a  href='ajax_manage.aspx?action=secret&couponsecret=" + coupon.Secret + "&cid=" + coupon.Id + "' class='ajaxlink'>详情</a> | ");
                sb2.Append("<a href='Youhui_YiXiaofei.aspx?couponsecret=" + coupon.Secret + "&couponid=" + coupon.Id + "' class='' ask='确认消费吗？'>消费</a></td>");
            }
            else
            {
                sb2.Append("<td class='op'><a  href='ajax_manage.aspx?action=secret&couponsecret=" + coupon.Secret + "&cid=" + coupon.Id + "' class='ajaxlink'>详情</a></td>");
            }
            sb2.Append("</tr>");
        }
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();
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
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        已消费优惠卷</h2><form id="Form" runat="server" method="get">
                                <div class="search">
                                    时间：
                                    <select name="date_type" class="h-input">
                                        <option value="">全部</option>
                                        <option value="1" <%if(Request.QueryString["date_type"] == "1"){ %>selected="selected"
                                            <%} %>>生成时间</option>
                                        <option value="2" <%if(Request.QueryString["date_type"] == "2"){ %>selected="selected"
                                            <%} %>>开始时间</option>
                                        <option value="4" <%if(Request.QueryString["date_type"] == "4"){ %>selected="selected"
                                            <%} %>>结束时间</option>
                                        <option value="8" <%if(Request.QueryString["date_type"] == "8"){ %>selected="selected"
                                            <%} %>>使用时间</option>
                                    </select>
                                    &nbsp;日期:
                                    <input type="text" class="h-input" datatype="date" style="margin-right:0px;" name="begintime" <%if(!string.IsNullOrEmpty(Request.QueryString["begintime"])){ %>value="<%=Request.QueryString["begintime"] %>"
                                        <%} %> />--<input type="text" class="h-input" datatype="date" name="endtime" <%if(!string.IsNullOrEmpty(Request.QueryString["endtime"])){ %>value="<%=Request.QueryString["endtime"] %>"
                                            <%} %> />&nbsp;&nbsp;&nbsp;&nbsp; 筛选条件：<select name="where_type" class="h-input">
                                                <option value="">全部</option>
                                                <option value="1" <%if(Request.QueryString["where_type"] == "1"){ %>selected="selected"
                                                    <%} %>>项目ID</option>
                                                <option value="2" <%if(Request.QueryString["where_type"] == "2"){ %>selected="selected"
                                                    <%} %>>用户名</option>
                                                <option value="4" <%if(Request.QueryString["where_type"] == "4"){ %>selected="selected"
                                                    <%} %>>Email</option>
                                                <option value="8" <%if(Request.QueryString["where_type"] == "8"){ %>selected="selected"
                                                    <%} %>>商户ID</option>
                                                <option value="16" <%if(Request.QueryString["where_type"] == "16"){ %>selected="selected"
                                                    <%} %>>券编号</option>
                                                <option value="32" <%if(Request.QueryString["where_type"] == "32"){ %>selected="selected"
                                                    <%} %>>手机号</option>
                                            </select>&nbsp;&nbsp; 内容：<input type="text" style="width: 120px;" name="type_name"
                                                class="h-input" <%if(!string.IsNullOrEmpty(Request.QueryString["type_name"])){ %>value="<%=Request.QueryString["type_name"] %>"
                                                <%} %> />&nbsp;&nbsp;
                                    <input type="submit" value="筛选" class="formbutton" style="padding: 1px 6px; width: 60px;" />
                                </div>
                                </form>
                                </div>
                                
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="8">
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
