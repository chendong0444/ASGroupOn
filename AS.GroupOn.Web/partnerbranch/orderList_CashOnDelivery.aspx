<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerBranchPage" %>

<%@ Register Src="~/UserControls/BranchOrder_PartnerCashOnDelivery.ascx" TagName="BranchOrder_PartnerCashOnDelivery"
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
    public int page = 1;
    protected string pagerhtml = String.Empty;
    protected OrderFilter orderfilter = new OrderFilter();
    protected IPagers<IOrder> pager = null;
    protected IList<IOrder> ilistorder = null;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (CookieUtils.GetCookieValue("pbranch", key) == null || CookieUtils.GetCookieValue("pbranch", key) == "")
        {
            Response.Redirect(WebRoot + "login.aspx?action=pbranch");
        }

        if (Request.HttpMethod == "GET")
        {
            page = Helper.GetInt(Request.QueryString["page"], 1);
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
        stTitle.Append("<th width='15%'>ID</th>");
        stTitle.Append("<th class='xiangmu'  width='25%'>项目</th>");
        stTitle.Append("<th width='15%'>用户</th>");
        stTitle.Append("<th width='20%'>派送地址</th>");
        stTitle.Append("<th width='13%'>快递公司</th>");
        stTitle.Append("<th width='12%'>操作</th>");
        stTitle.Append("</tr>");
        ltOrderTitle.Text = stTitle.ToString();

        sql = BranchOrder_PartnerCashOnDelivery1.GetWhereString();
        url = BranchOrder_PartnerCashOnDelivery1.GetUrl();

        sql = sql + " and State='nocod' and Express='Y' and Express_id=0 ";

        StringBuilder stContent = new StringBuilder();
        orderfilter.table = "(SELECT distinct Id,User_id,State,Service,Credit,cashondelivery,[Money],Address,Express,Express_id,Express_no,Express_xx,"
        + "Quantity,Origin,Pay_time from(select t.*,Category.name as Category_name from (select [Order].Id, orderdetail.Teamid,[Order].result,"
        +"[order].Address,[order].remark as order_remark,User_id,Email,Username,Quantity,Origin,Service,[Order].Credit,[order].Money,"
        +"cashondelivery,Express,[Order].Create_time as order_create_time,[order].Parent_orderid as order_parent_orderid,"
        +"[order].Partner_id as order_Partner_id,Pay_time,[user].mobile,state,team_id,pay_id,Express_no,[order].mobile as order_mobile,"
        +"Express_id,express_xx from [Order] inner join [User] on([Order].User_id=[User].Id)left join orderdetail "
        +"on([Order].Id=orderdetail.Order_id ))t  left join [Category]  on(Category.id=express_id) where t.Teamid "
        +"in(select Id from Team where Team.branch_id =" + Helper.GetInt(CookieUtils.GetCookieValue("pbranch", key), 0) + "))t where 1=1 " + sql+")s";
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

                //订单详情

                IList<IOrderDetail> ilistdetail = null;
                OrderDetailFilter detailfilter = new OrderDetailFilter();
                detailfilter.Order_ID = orderinfo.Id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ilistdetail = session.OrderDetail.GetList(detailfilter);
                }

                //项目
                if (ilistdetail.Count > 0)
                {
                    stContent.Append("<td>");
                    foreach (IOrderDetail detailinfo in ilistdetail)
                    {
                        ITeam team = Store.CreateTeam();
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            team = session.Teams.GetByID(detailinfo.Teamid);
                        }
                        stContent.Append("<b>项目ID" + detailinfo.Teamid + "</b>" + "(总共:" + detailinfo.Num + "件)");
                        stContent.Append("</br>");
                        if (team == null)
                        {
                            stContent.Append("<a>项目已不存在</a>");
                        }
                        if (team != null)
                        {
                            stContent.Append("<a target='_blank' href='" + getTeamPageUrl(Helper.GetInt(detailinfo.Teamid.ToString(), 0)) + "'>" + team.Title + "</a>");
                        }
                        if (detailinfo.result.ToString() == "")
                        {
                            stContent.Append("</br>");
                        }
                        else
                        {
                            stContent.Append(AS.GroupOn.Domain.Spi.Order.Getbulletin((detailinfo.result).ToString(), 0));
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
                        stContent.Append("<a target='_blank' href='" + getTeamPageUrl(Helper.GetInt(orderinfo.Team_id.ToString(), 0)) + "'>" + team.Title + "</a>");
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
                IList<ICategory> ilistcate = null;
                CategoryFilter catefilter = new CategoryFilter();
                catefilter.Zone = "express";
                catefilter.AddSortOrder(CategoryFilter.Sort_Order_DESC);
                catefilter.AddSortOrder(CategoryFilter.ID_ASC);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ilistcate = session.Category.GetList(catefilter);
                }
                stContent.Append("<td><select id='sl" + orderinfo.Id + "' runat='server' >");
                stContent.Append("<option value='0'>请选择快递</option>");
                foreach (ICategory cate in ilistcate)
                {
                    stContent.Append("<option value='");
                    stContent.Append(cate.Id.ToString());
                    stContent.Append("'>");
                    stContent.Append(cate.Name.ToString());
                    stContent.Append("</option>");
                }
                stContent.Append("</td>");
                //操作
                stContent.Append("<td>");
                stContent.Append("<input id='btnSave' onclick='Save(" + orderinfo.Id + ")' type='button' value='保存'/></td>");
                stContent.Append("</tr>");
                stContent.Append("");
                i++;
            }

            pagerhtml = WebUtils.GetPagerHtml(30, pager.TotalRecords, page, url);

            ltOrderContent.Text = stContent.ToString();
        }
        else
        {
            stContent.Append("<tr><td colspan='6'>暂无数据！</font></td></tr>");
            ltOrderContent.Text = stContent.ToString();
        }
    }

    protected void Update(object sender, EventArgs e)
    {
        IOrder order = Store.CreateOrder();
        int id = Helper.GetInt(hiId.Value, 0);
        int s = Helper.GetInt(express_id.Value, 0);
        order.Id = id;
        order.Express_id = s;

        int branch_id = Helper.GetInt(CookieUtils.GetCookieValue("pbranch", key), 0);
        //bool bl = bllOrder.branchExists(id, branch_id);
        int existresult = 0;
        orderfilter.table = "[Order],orderdetail where [Order].Id=orderdetail.Order_id and [Order].Id=" + order.Id + " and orderdetail.Teamid in(select Id from Team where Team.branch_id=" + Helper.GetInt(CookieUtils.GetCookieValue("pbranch", key), 0) + ")";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            existresult = session.Orders.GetBranchCount(orderfilter);
        }
        if (existresult > 0)
        {
            if (order.Express_id == 0)
            {
                SetSuccess("请选择快递");
                Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
                Response.End();
            }
            else
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    order = session.Orders.GetByID(order.Id);
                }
                order.Express_id = s;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int result = session.Orders.Update(order);
                }

                SetSuccess("修改快递信息成功");
                Response.Redirect(Page.Request.UrlReferrer.AbsoluteUri);
                Response.End();
            }
        }
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
    <input name="action" id="Button1" type="submit" style="display: none" value="updatekuaidi" />
    <input type="hidden" id="hiId" name="hiId" runat="server" />
    <input type="hidden" id="express_id" name="express_id" runat="server" />
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <%--<input type="hidden" name="action" value="updatekuaidi" />--%>
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        未选择快递</h2>
                                    <ul class="contact-filter" style="top: 48px">
                                        <uc3:BranchOrder_PartnerCashOnDelivery ID="BranchOrder_PartnerCashOnDelivery1" runat="server" />
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
    function Save(i) {
        var id = i;
        var ex = "sl" + i.toString();
        $("#hiId").val(id);
        var express_id = document.getElementById(ex).value;
        $("#express_id").val(express_id);
        $("#Button1").click();
    }
   
</script>

<%LoadUserControl("_footer.ascx", null); %>
