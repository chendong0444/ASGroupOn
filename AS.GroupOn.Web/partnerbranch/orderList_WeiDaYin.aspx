<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerBranchPage" %>

<%@ Register Src="~/UserControls/BranchOrder_PartnerSearch.ascx" TagName="BranchOrder_PartnerSearch"
    TagPrefix="uc3" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">
    public string sql;
    public string url;
    public string sqll;
    public string where = String.Empty;
    public int page = 1;
    protected string pagerhtml = String.Empty;
    protected OrderFilter orderfilter = new OrderFilter();
    protected IPagers<IOrder> pager = null;
    protected IList<IOrder> ilistorder = null;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        BranchOrder_PartnerSearch1.SearchExpress = true;

        if (Request.HttpMethod == "GET")
        {
            page = Helper.GetInt(Request.QueryString["page"], 1);
        }

        if (CookieUtils.GetCookieValue("pbranch", key) == null || CookieUtils.GetCookieValue("pbranch", key) == "")
        {
            Response.Redirect(WebRoot + "login.aspx?action=pbranch");
        }
        InitPage();
    }

    private void InitPage()
    {

        if (CookieUtils.GetCookieValue("pbranch", key) == null || CookieUtils.GetCookieValue("pbranch", key) == "")
        {
            Response.Redirect(WebRoot + "login.aspx?action=pbranch");
        }
        StringBuilder stTitle = new StringBuilder();
        stTitle.Append("<tr>");
        stTitle.Append("<th width='10%'>ID</th>");
        stTitle.Append("<th class='xiangmu' width='25%'>项目</th>");
        stTitle.Append("<th width='15%'>用户</th>");
        stTitle.Append("<th width='25%'>派送地址</th>");
        stTitle.Append("<th width='10%'>快递公司</th>");
        stTitle.Append("<th width='15%'>操作</th>");
        stTitle.Append("</tr>");
        ltOrderTitle.Text = stTitle.ToString();

        sql = BranchOrder_PartnerSearch1.GetWhereString();
        url = BranchOrder_PartnerSearch1.GetUrl();
        sql = "where service!='cashondelivery' and State='pay' and Express='Y' and Express_id>0 and isnull(express_xx,'')<>'已打印' " + sql;

        where = Convert.ToBase64String(HttpUtility.UrlEncodeToBytes(sql, Encoding.UTF8));
        StringBuilder stContent = new StringBuilder();
        orderfilter.table = "(SELECT distinct Id,User_id,State,Service,Credit,cashondelivery,[Money],Address,Express,Express_id,Express_no,Express_xx,"
        +"Quantity,Origin,Pay_time from (select t.*,Category.name as Category_name from (select [Order].Id, orderdetail.Teamid ,[Order].result,"
        +"[order].Address ,[order].remark as order_remark,User_id,Email,Username,Quantity,Origin,Service,[Order].Credit,[order].Money,cashondelivery,"
        +"Express,[Order].Create_time as order_create_time,[order].Parent_orderid as order_parent_orderid,[order].Partner_id as order_Partner_id,"
        +"Pay_time,[user].mobile,state,team_id,pay_id,Express_no,[order].mobile as order_mobile,Express_id,express_xx from [Order] inner join "
        +"[User] on([Order].User_id=[User].Id)left join orderdetail on([Order].Id=orderdetail.Order_id ))t  left join [Category]  "
        +"on(Category.id=express_id) where t.Teamid in(select Id from Team where Team.branch_id =" + Helper.GetInt(CookieUtils.GetCookieValue("pbranch", key), 0) + "))t " + sql+")s";
        orderfilter.PageSize = 30;
        orderfilter.CurrentPage = page;
        orderfilter.AddSortOrder(OrderFilter.Pay_time_DESC);

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Orders.GetBranchPage(orderfilter);
        }
        ilistorder = pager.Objects;
        if (ilistorder.Count > 0)
        {
            int i = 0;
            foreach (IOrder orderinfo in ilistorder)
            {
                if ((i + 1) % 2 == 0)
                {
                    stContent.Append("<tr>");
                }
                else
                {
                    stContent.Append("<tr class='alt'>");
                }
                //ID
                stContent.Append("<td>" + orderinfo.Id + "</td>");

                //项目

                //订单详情
                IList<IOrderDetail> ilistordetail = null;
                OrderDetailFilter ordetailfilter = new OrderDetailFilter();
                ordetailfilter.Order_ID = orderinfo.Id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ilistordetail = session.OrderDetail.GetList(ordetailfilter);
                }
                //项目
                if (ilistordetail.Count > 0)
                {
                    stContent.Append("<td>");
                    foreach (IOrderDetail ordetail in ilistordetail)
                    {
                        ITeam team = Store.CreateTeam();
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            team = session.Teams.GetByID(ordetail.Teamid);
                        }
                        stContent.Append("<b>项目ID" + ordetail.Teamid + "</b>" + "(总共:" + ordetail.Num + "件)");
                        stContent.Append("</br>");
                        if (team == null)
                        {
                            stContent.Append("<a>项目已不存在</a>");
                        }
                        if (team != null)
                        {
                            stContent.Append("<a target='_blank' href='" + getTeamPageUrl(Helper.GetInt(ordetail.Teamid.ToString(), 0)) + "'>" + team.Title + "</a>");
                        }
                        if (ordetail.result.ToString() == "")
                        {
                            stContent.Append("</br>");
                        }
                        else
                        {
                            stContent.Append(AS.GroupOn.Domain.Spi.Order.Getbulletin((ordetail.result).ToString(), 0));
                        }

                    }
                    stContent.Append("</td>");
                }
                else
                {
                    stContent.Append("<td>");
                    ITeam team = Store.CreateTeam();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        team = session.Teams.GetByID(orderinfo.Team_id);
                    }
                    stContent.Append("<b>项目ID" + orderinfo.Team_id + "</b>" + "(总共:" + orderinfo.Quantity + "件)");
                    stContent.Append("</br>");
                    if (team == null)
                    {
                        stContent.Append("<a>项目已不存在</a>");
                    }
                    if (team != null)
                    {
                        stContent.Append("<a target='_blank' href='" + getTeamPageUrl( Helper.GetInt(orderinfo.Team_id.ToString(), 0)) + "'>" + team.Title + "</a>");
                    }
                    if (orderinfo.result.ToString() == "")
                    {
                        stContent.Append("</br>");
                    }
                    else
                    {
                        stContent.Append(AS.GroupOn.Domain.Spi.Order.Getbulletin((orderinfo.result).ToString(), 0));
                    }
                    stContent.Append("</td>");
                }

                //用户
                IUser userInfo = Store.CreateUser();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    userInfo = session.Users.GetByID(orderinfo.User_id);
                }
                stContent.Append("<td>" + userInfo.Username + "</br>" + userInfo.Email + "</td>");
                //派送地址
                stContent.Append("<td>" + orderinfo.Address + "</td>");
                //快递公司
                ICategory category = Store.CreateCategory();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    category = session.Category.GetByID(orderinfo.Express_id);
                }
                stContent.Append("<td>" + category.Name + "<br />" + orderinfo.Express_no + "</td>");
                //操作
                stContent.Append("<td class='op' nowrap>");
                stContent.Append("<a class='ajaxlink' href='" + PageValue.WebRoot + "manage/ajax_print.aspx?action=print&id=" + orderinfo.Id + "'>打印快递</a>｜ ");
                stContent.Append("<a class='ajaxlink' href='" + PageValue.WebRoot + "ajax/branch.aspx?action=orderview&id=" + orderinfo.Id + "'>详情</a>");
                stContent.Append("</tr>");
                i++;
            }
           
        }
        else
        {
            stContent.Append("<tr><td colspan='6'>暂无数据！</td></tr>");
            ltOrderContent.Text = stContent.ToString();
        }
        pagerhtml = WebUtils.GetPagerHtml(30, pager.TotalRecords, page, url);

        ltOrderContent.Text = stContent.ToString();
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
    <input type="hidden" id="hiId" runat="server" />
    <input type="hidden" id="hiExpressId" runat="server" />
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
                                    <h2>
                                        未打印</h2>
                                    <ul class="contact-filter" style="top: 48px">
                                        <li></li>
                                        <uc3:BranchOrder_PartnerSearch ID="BranchOrder_PartnerSearch1" runat="server" />
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="ltOrderTitle" runat="server"></asp:Literal>
                                        <asp:Literal ID="ltOrderContent" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="6">
                                                <ul class="paginator">
                                                    <li class="current">
                                                        <%= pagerhtml %>
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
        <!-- bdw end -->
    </div>
    </form>
</body>
<script type="text/javascript">
    jQuery(function () {
        $('input').keyup(function (event) {

            if (event.keyCode == "13") {
                document.getElementById("btnselect").click();   //服务器控件loginsubmit点击事件被触发
                return false;
            }

        });

    });
   
</script>
<%LoadUserControl("_footer.ascx", null); %>

