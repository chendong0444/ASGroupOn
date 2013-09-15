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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected IPagers<IPcoupon> pager = null;
    protected IList<IPcoupon> list_pcoupon = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected string date_type = "";
    protected string ddlstate = "";
    protected string where_type = "";
    protected PcouponFilter filter = new PcouponFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_CouponP_Listview))
        {
            SetError("你不具有查看站外券列表的权限！");
            Response.Redirect("index_index.aspx");
            return;
        }
        if (!string.IsNullOrEmpty(Request.QueryString["ddlstate"]))
        {
            ddlstate = Request.QueryString["ddlstate"];
            if (ddlstate == "1")
            {
                filter.state = "buy";
            }
            else if (ddlstate == "2")
            {
                filter.state = "nobuy";
            }
            url = url + "&ddlstate=" + Request.QueryString["ddlstate"];
        }
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
                    filter.FromBuy_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["begintime"]).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
                }
                if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
                {
                    url = url + "&endtime=" + Request["endtime"];
                    filter.ToBuy_time = Helper.GetDateTime(Convert.ToDateTime(Request.QueryString["endtime"]).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
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
                filter.teamid = Helper.GetInt(Request.QueryString["type_name"], 0);
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
                    filter.userid = uses.Id;
                else
                {
                    return;
                }
            }
            else if (where_type == "8")
            {
                filter.partnerid = Helper.GetInt(Request.QueryString["type_name"], 0);
            }
            else if (where_type == "16")
            {
                filter.number = Helper.GetString(Request.QueryString["type_name"], String.Empty);
            }
            url = url + "&type_name=" + Request.QueryString["type_name"];
        }
        if (Request["cid"] != null)
        {
            delete(Helper.GetInt(Request["cid"], 0));
        }
        InitData();
    }
    private void InitData()
    {
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        IUser user = Store.CreateUser();
        sb1.Append("<tr >");
        sb1.Append("<th width='10%'>编号</th>");
        sb1.Append("<th width='20%'>券号</th>");
        sb1.Append("<th width='30%'>项目</th>");
        sb1.Append("<th width='20%'>用户</th>");
        sb1.Append("<th width='10%'>状态</th>");
        sb1.Append("<th width='10%' nowrap>操作</th>");
        sb1.Append("</tr>");
        url = url + "&page={0}";
        url = "Youhui_pcoupon.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(PcouponFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Pcoupon.GetPager(filter);
        }
        list_pcoupon = pager.Objects;
        int i = 0;
        if (list_pcoupon != null && list_pcoupon.Count > 0)
        {
            foreach (IPcoupon pcoupon in list_pcoupon)
            {
                user = pcoupon.User;
                if (i % 2 != 0)
                {
                    sb2.Append("<tr>");
                }
                else
                {
                    sb2.Append("<tr class='alt'>");
                }
                i++;
                sb2.Append("<td>" + pcoupon.id + "</td>");
                sb2.Append("<td>" + pcoupon.number + "</td>");
                if (pcoupon.Team != null && pcoupon.Team.Title != null)
                {
                    sb2.Append("<td>" + "ID:" + pcoupon.Team.Id + "(<a class='deal-title' href='" + getTeamPageUrl(pcoupon.Team.Id) + "' target='_blank'>" + pcoupon.Team.Title + "</a>)</td>");
                }
                else
                {
                    sb2.Append("<td nowrap></td>");  
                }
               
                if (user != null)
                {
                    sb2.Append("<td><div style='word-wrap: break-word;overflow: hidden; width: 140px;'>" + user.Email + "<br/>" + user.Username + "</div></td>");
                }
                else
                {
                    sb2.Append("<td nowrap></td>");
                }
                if (pcoupon.state == "buy")
                {
                    sb2.Append("<td nowrap>已被购买</td>");
                }
                else
                {
                    sb2.Append("<td nowrap>未被购买</td>");
                }
                sb2.Append("<td class='op'>");
                if (pcoupon.userid != 0)
                {
                    sb2.Append("<a href='ajax_coupon.aspx?action=psms&id=" + pcoupon.id + "' class='ajaxlink'>短信</a> | ");
                }
                sb2.Append("<a  href='ajax_manage.aspx?action=secret&type=pcoupon&cid=" + pcoupon.id + "' class='ajaxlink'>详情</a>");
                if (pcoupon.state == "nobuy")
                {
                    sb2.Append(" | <a  href='ajax_manage.aspx?action=pcoupon&cid=" + pcoupon.id + "' class='ajaxlink'>编辑</a> | ");
                    sb2.Append("<a  href='Youhui_pcoupon.aspx?cid=" + pcoupon.id + "' ask='是否删除此券？'>删除</a>");
                }
                sb2.Append("</tr>");
            }
            if (pager.TotalRecords >= 30)
            {
                pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
            }
        }
        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();
    }
    public void delete(int id)
    {
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_CouponP_Delete))
        {
            SetError("你不具有删除站外券的权限！");
            Response.Redirect("Youhui_pcoupon.aspx");
            return;
        }
        IPcoupon pcoupon = null;
        ITeam team = null;
        IProduct product = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pcoupon = session.Pcoupon.GetByID(id);
        }
        if (pcoupon != null)
        {
            team = pcoupon.Team;
            product = team.Products;
            if (team != null)
            {
                if (AsAdmin.Id == 0)
                {
                    SetError("友情提示：当前管理员不存在,删除失败");
                    Response.Redirect("Youhui_pcoupon.aspx");
                    Response.End();
                }
                team.inventory = team.inventory - 1;
                intoorder(0, -1, 4, team.Id, AsAdmin.Id, "", 0);
                if (product != null)
                {
                    product.inventory = product.inventory - 1;
                    if (product.inventory > 0)
                        product.status = 1;
                    else
                        product.status = 0;
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Teams.Update(team);
                }
                if (product != null)
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        session.Product.Update(product);
                    }
                    intoorder(0, -1, 4, product.id, AsAdmin.Id, "", 1);
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Pcoupon.Delete(id);
                }
                SetSuccess("友情提示：删除成功");
                string key = AS.Common.Utils.FileUtils.GetKey();
                AS.AdminEvent.ConfigEvent.AddOprationLog(AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", key), 0), "删除站外券", "删除站外券 ID:" + Request.QueryString["cid"].ToString(), DateTime.Now);
                if (Request.UrlReferrer != null)
                    Response.Redirect("Youhui_pcoupon.aspx");
            }
        }
        else
        {
            SetError("友情提示：删除失败");
            Response.Redirect("Youhui_pcoupon.aspx");
            Response.End();
        }
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
                                        站外券</h2>
                                    <form id="Form" runat="server" method="get">
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
                                                <%} %>>购买时间</option>
                                        </select>
                                        &nbsp;日期:
                                        <input type="text" class="h-input" datatype="date" style="margin-right: 0px;" name="begintime"
                                            <%if(!string.IsNullOrEmpty(Request.QueryString["begintime"])){ %>value="<%=Request.QueryString["begintime"] %>"
                                            <%} %> />--<input type="text" class="h-input" datatype="date" name="endtime" <%if(!string.IsNullOrEmpty(Request.QueryString["endtime"])){ %>value="<%=Request.QueryString["endtime"] %>"
                                                <%} %> />&nbsp;&nbsp;&nbsp;&nbsp; 筛选条件：<select id="select_type" name="where_type"
                                                    class="h-input">
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
                                                    id="type_name" class="h-input" <%if(!string.IsNullOrEmpty(Request.QueryString["type_name"])){ %>value="<%=Request.QueryString["type_name"] %>"
                                                    <%} %> />&nbsp;&nbsp; 状态:<select id="ddlstate" name="ddlstate" class="h-input">
                                                        <option value="">全部</option>
                                                        <option value="1" <%if(Request.QueryString["ddlstate"] == "1"){ %>selected="selected"
                                                            <%} %>>已被购买</option>
                                                        <option value="2" <%if(Request.QueryString["ddlstate"] == "2"){ %>selected="selected"
                                                            <%} %>>未被购买</option>
                                                    </select>
                                        <input type="submit" value="筛选" class="formbutton" onclick="return checkvale();"
                                            style="padding: 1px 6px; width: 60px;" />
                                    </div>
                                    </form>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
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
<script type="text/javascript">
    function checkvale() {
        if ($("#select_type").val() != "") {
            if ($("#type_name").val() == "") {
                var selectIndex = document.getElementById("select_type").selectedIndex;
                var selectText = document.getElementById("select_type").options[selectIndex].text
                alert("请输入您要进行筛选的" + selectText);
                return false;
            }
        }
        else {
            $("#type_name").val("");
        }
    }
</script>
<%LoadUserControl("_footer.ascx", null); %>
