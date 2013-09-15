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
    protected string strkey = "";
    public int page = 1;
    protected string pagerhtml = String.Empty;

    public NameValueCollection _system = new NameValueCollection();
    protected IPagers<IOrder> pager = null;
    protected IList<IOrder> ilistorder = null;
    protected OrderFilter orderfilter = new OrderFilter();
    protected string keys = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();
        if (CookieUtils.GetCookieValue("pbranch", keys) == null || CookieUtils.GetCookieValue("pbranch", keys) == "")
        {
            Response.Redirect(WebRoot + "login.aspx?action=pbranch");
        }
        if (Request.HttpMethod == "GET")
        {
            page = Helper.GetInt(Request.QueryString["page"], 1);
        }

        int key = Helper.GetInt(Request["key"], 1);
        strkey = key.ToString();
        sql = BranchOrder_PartnerCashOnDelivery1.GetWhereString();
        url = BranchOrder_PartnerCashOnDelivery1.GetUrl();

        sql = sql + " and Express='Y' ";
        if (key == 1)
        {
            sql = sql + " and State='nocod' and service='cashondelivery' and (Express_id>0 and len(Express_no)>0)";
        }
        else if (key == 2)
        {
            sql = sql + " and State='nocod' and service='cashondelivery' and (Express_id=0 or len(Express_no)=0)";
        }
        else
        {
            sql = sql + " and State='pay' and service='cashondelivery'";
        }

        InitPage();
    }

    private void InitPage()
    {
        StringBuilder stTitle = new StringBuilder();

        stTitle.Append("<tr>");
        stTitle.Append("<th width='10%'>ID</th>");
        stTitle.Append("<th width='20%'>项目</th>");
        stTitle.Append("<th width='15%'>用户</th>");
        stTitle.Append("<th width='5%'>数量</th>");
        stTitle.Append("<th width='7%'>总款</th>");
        stTitle.Append("<th width='12%'>支付方式</th>");
        stTitle.Append("<th width='8%'>余付</th>");
        stTitle.Append("<th width='10%'>在线支付</br>货到付款</th>");
        stTitle.Append("<th width='8%>递送方式</th>");
        stTitle.Append("<th width='5%'>详情</th>");
        stTitle.Append("</tr>");
        ltOrderTitle.Text = stTitle.ToString();

        StringBuilder stContent = new StringBuilder();
        orderfilter.table = "(SELECT distinct Id,User_id,State,Service,Credit,cashondelivery,[Money],Address,Express,Express_id,Express_no,Express_xx,"
        + "Quantity,Origin,Pay_time from(select t.*,Category.name as Category_name from (select [Order].Id, orderdetail.Teamid,[Order].result,"
        +"[order].Address,[order].remark as order_remark,User_id,Email,Username,Quantity,Origin,Service,[Order].Credit,[order].Money,"
        +"cashondelivery,Express,[Order].Create_time as order_create_time,[order].Parent_orderid as order_parent_orderid,"
        +"[order].Partner_id as order_Partner_id,Pay_time,[user].mobile,State,team_id,pay_id,Express_no,[order].mobile as order_mobile,"
        +"Express_id,Express_xx from [Order] inner join [User] on([Order].User_id=[User].Id)left join orderdetail "
        +"on([Order].Id=orderdetail.Order_id ))t  left join [Category]  on(Category.id=express_id) where t.Teamid "
        +"in(select Id from Team where Team.branch_id =" + Helper.GetInt(CookieUtils.GetCookieValue("pbranch", keys), 0) + "))t where 1=1 " + sql+")s";
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
                stContent.Append("<td width='80'>" + orderinfo.Id + "</td>");


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
                    stContent.Append("<td width='250'>");
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
                            stContent.Append("<a target='_blank' href='" + getTeamPageUrl(int.Parse(detailinfo.Teamid.ToString())) + "'>" + team.Title + "</a>");
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
                    stContent.Append("<td width='250'>");

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
                stContent.Append("<td width='140'><div style='word-wrap: break-word; width: 140px; overflow: hidden;'>" + userInfo.Username + "</br>" + userInfo.Email + "</div></td>");
                //数量
                stContent.Append("<td width='50'>" + orderinfo.Quantity + "</td>");
                //总款
                stContent.Append("<td width='50'><span class='money'>¥</span>" + orderinfo.Origin + "</td>");
                //支付方式
                stContent.Append("<td width='120'>" + WebUtils.GetPayText(orderinfo.State.ToString(), orderinfo.Service.ToString()) + "</td>");
                //余额付款
                stContent.Append("<td width='50'><span class='money'>¥</span>" + orderinfo.Credit + "</td>");
                //在线支付、货到付款
                //if (orderinfo.State.ToString() == "cashondelivery")
                if (orderinfo.Service.ToString() == "cashondelivery" && orderinfo.State.ToString() == "pay")
                {
                    stContent.Append("<td width='80'><span class='money'>¥</span>" + orderinfo.cashondelivery + "</td>");
                }
                else
                {
                    stContent.Append("<td width='80'><span class='money'>¥</span>" + orderinfo.Money + "</td>");
                }
                //递送方式
                if (orderinfo.Express.ToString() == "Y")
                {
                    stContent.Append("<td width='100'>" + "快递");
                    if (int.Parse(orderinfo.Express_id.ToString()) != 0)
                    {
                        ICategory category = Store.CreateCategory();
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            category = session.Category.GetByID(orderinfo.Express_id);
                        }
                        if (category.Name != "" && category.Name != null)
                        {
                            stContent.Append("</br>" + category.Name);
                        }
                        if (orderinfo.Express_no != "" && orderinfo.Express_no != null)
                        {
                            stContent.Append("</br>" + orderinfo.Express_no);
                        }
                        if (orderinfo.Express_xx != "" && orderinfo.Express_xx != null)
                        {
                            stContent.Append("</br>" + orderinfo.Express_xx);
                        }
                    }
                }
                else
                {
                    stContent.Append("<td>" + "其他");
                }
                stContent.Append("</td>");
                //详情
                stContent.Append("<td width='50' class='op' nowrap>");
                stContent.Append("<a class='ajaxlink' href='" + PageValue.WebRoot + "ajax/branch.aspx?action=orderview&id=" + orderinfo.Id + "'>详情</a>");
                stContent.Append("</tr>");
                i++;
            }

            pagerhtml = WebUtils.GetPagerHtml(30, pager.TotalRecords, page, url);

            ltOrderContent.Text = stContent.ToString();
        }
        else
        {
            stContent.Append("<tr><td colspan='10'>暂无数据！</td></tr>");
            ltOrderContent.Text = stContent.ToString();
        }
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
                                    <%if (strkey == "2")
                                      { %>
                                    <h2>
                                        未发货</h2>
                                    <%}
                                      else if (strkey == "1")
                                      {%>
                                    <h2>
                                        已发货</h2>
                                    <%}
                                      else if (strkey == "3")
                                      {%>
                                    <h2>
                                        已完成</h2>
                                    <%}
                                      else
                                      { %>
                                    <h2>
                                        付款订单</h2>
                                    <%} %>
                                    <ul class="contact-filter" style="top: 48px">
                                        <uc3:BranchOrder_PartnerCashOnDelivery ID="BranchOrder_PartnerCashOnDelivery1" runat="server" />
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="ltOrderTitle" runat="server"></asp:Literal>
                                        <asp:Literal ID="ltOrderContent" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="10">
                                                <ul class="paginator">
                                                    <li class="current">
                                                        <%= pagerhtml %>
                                                    </li>
                                                </ul>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan='10'>
                                                <span style='color: red'>(只显示已付款或货到付款的快递订单，需要管理员开通购物车及订单拆分功能)</span>
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

