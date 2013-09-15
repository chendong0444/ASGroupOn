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
    public string sql = "1=1";
    public string url;
    protected string strkey = "";
    public DataTable dt;
    public int page = 1;
    protected string pagerhtml = String.Empty;

    public NameValueCollection _system = new NameValueCollection();
    protected IPagers<IOrder> pager = null;
    protected IList<ITeam> ilistteam = null;
    protected OrderDetailFilter ordetailfilter = new OrderDetailFilter();
    protected IList<IOrderDetail> ilistordetail = null;
    protected IOrder order = Store.CreateOrder();
    protected OrderFilter orderfilter = new OrderFilter();
    protected IList<IOrder> ilistorder = null;
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
    
        sql = BranchOrder_PartnerSearch1.GetWhereString();
        url = BranchOrder_PartnerSearch1.GetUrl();
        sql = sql + "and (State='pay' or State='nocod') and Express='Y' ";

        if (key == 2)
        {
            sql = sql + "and State='pay' and service!='cashondelivery' and (Express_id>0 and len(Express_no)>0)";

        }
        else if (key == 3)
        {
            sql = sql + "and State='pay' and service!='cashondelivery' and (Express_id=0 or len(Express_no)=0)";
        }
        else
        {
            sql = sql + "and (State='pay' or State='nocod') and Express='Y'";
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
        stTitle.Append("<th width='8%'>递送方式</th>");
        stTitle.Append("<th width='5%'>详情</th>");
        stTitle.Append("</tr>");
        ltOrderTitle.Text = stTitle.ToString();

        StringBuilder stContent = new StringBuilder();
        orderfilter.table = "(SELECT distinct Id,User_id,State,Service,Credit,cashondelivery,[Money],Address,Express,Express_id,Express_no,Express_xx,"
        + "Quantity,Origin,Pay_time from(select t.*,Category.name as Category_name from (select [Order].Id, orderdetail.Teamid ," +
            "[Order].result as order_result,[Order].address,[Order].remark,User_id,Email,Username,Quantity," +
            "Origin,Service,[Order].Credit,[Order].Money,cashondelivery,Express,[Order].Create_time as order_create_time," +
            "[Order].Parent_orderid as order_parent_orderid,[Order].Partner_id as order_Partner_id,Pay_time,[user].mobile as user_mobile," +
            "[State],team_id,pay_id,Express_no,[Order].mobile,Express_id,Express_xx from [Order] inner join [User] " +
            "on([Order].User_id=[User].Id)left join orderdetail on([Order].Id=orderdetail.Order_id ))t  left join [Category] " +
        "on(Category.id=express_id) where t.Teamid in(select Id from Team where Team.branch_id =" + Helper.GetInt(CookieUtils.GetCookieValue("pbranch", keys), 0) + "))t where 1=1 " + sql+")s";
        //orderfilter.Wheresql1 = sql;
        orderfilter.CurrentPage = page;
        orderfilter.PageSize = 30;
        orderfilter.AddSortOrder(OrderFilter.Pay_time_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Orders.GetBranchPage(orderfilter);
        }
        ilistorder = pager.Objects;
        if (ilistorder.Count > 0)
        {
            int i = 0;
            foreach (IOrder orinfo in ilistorder)
            {
                if ((i + 1) % 2 == 0)
                {
                    stContent.Append("<tr>");
                }
                else
                {
                    stContent.Append("<tr class='alt'>");
                }
                stContent.Append("<td width='80'>" + orinfo.Id + "</td>");

                //订单详情
                ordetailfilter.Order_ID = orinfo.Id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ilistordetail = session.OrderDetail.GetList(ordetailfilter);
                }
                //项目
                if (ilistordetail.Count > 0)
                {
                    stContent.Append("<td width='250'>");
                    foreach (IOrderDetail ordeinfo in ilistordetail)
                    {
                        ITeam team = Store.CreateTeam();
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            team = session.Teams.GetByID(ordeinfo.Teamid);
                        }
                        stContent.Append("<b>项目ID" + ordeinfo.Teamid + "</b>" + "(总共:" + ordeinfo.Num + "件)");
                        stContent.Append("</br>");
                        if (team == null)
                        {
                            stContent.Append("<a>项目已不存在</a>");
                        }
                        if (team != null)
                        {
                            stContent.Append("<a target='_blank' href='" + getTeamPageUrl(int.Parse(ordeinfo.Teamid.ToString())) + "'>" + team.Title + "</a>");
                        }
                        if (ordeinfo.result.ToString() == "")
                        {
                            stContent.Append("</br>");
                        }
                        else
                        {
                            stContent.Append(AS.GroupOn.Domain.Spi.Order.Getbulletin((ordeinfo.result).ToString(), 0));
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
                        team = session.Teams.GetByID(orinfo.Team_id);
                    }
                    stContent.Append("<b>项目ID" + orinfo.Team_id + "</b>" + "(总共:" + orinfo.Quantity + "件)");
                    stContent.Append("</br>");
                    if (team == null)
                    {
                        stContent.Append("<a>项目已不存在</a>");
                    }
                    if (team != null)
                    {
                        stContent.Append("<a target='_blank' href='" + getTeamPageUrl(Helper.GetInt(orinfo.Team_id.ToString(), 0)) + "'>" + team.Title + "</a>");
                    }
                    if (orinfo.result.ToString() == "")
                    {
                        stContent.Append("</br>");
                    }
                    else
                    {
                        stContent.Append(AS.GroupOn.Domain.Spi.Order.Getbulletin((orinfo.result).ToString(), 0));
                    }
                    stContent.Append("</td>");
                }

                //用户
                IUser userInfo = Store.CreateUser();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    userInfo = session.Users.GetByID(orinfo.User_id);
                }
                stContent.Append("<td width='140'><div style='word-wrap: break-word; width: 140px; overflow: hidden;'>" + userInfo.Username + "</br>" + userInfo.Email + "</div></td>");
                //数量
                stContent.Append("<td width='50'>" + orinfo.Quantity + "</td>");
                //总款
                stContent.Append("<td width='50'><span class='money'>¥</span>" + orinfo.Origin + "</td>");
                //支付方式
                string state = orinfo.State.ToString();
                stContent.Append("<td width='120'>" + WebUtils.GetPayText(orinfo.State.ToString(), orinfo.Service.ToString()) + "</td>");
                //余额付款
                stContent.Append("<td width='50'><span class='money'>¥</span>" + orinfo.Credit + "</td>");
                //在线支付、货到付款
                //if (orinfo.State.ToString() == "cashondelivery")
                if (orinfo.Service.ToString() == "cashondelivery" && orinfo.State.ToString() == "pay")
                {
                    stContent.Append("<td width='80'><span class='money'>¥</span>" + orinfo.cashondelivery + "</td>");
                }
                else
                {
                    stContent.Append("<td width='80'><span class='money'>¥</span>" + orinfo.Money + "</td>");
                }
                //递送方式
                if (orinfo.Express.ToString() == "Y")
                {
                    stContent.Append("<td width='100'>" + "快递");
                    if (int.Parse(orinfo.Express_id.ToString()) != 0)
                    {
                        ICategory category = Store.CreateCategory();
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            category = session.Category.GetByID(orinfo.Express_id);
                        }
                        if (category != null && category.Name != "")
                        {
                            if (category.Name != "")
                            {
                                stContent.Append("</br>" + category.Name);
                            }
                        }

                        if (orinfo.Express_no != null)
                        {
                            stContent.Append("</br>" + orinfo.Express_no);
                        }
                        if (orinfo.Express_xx != null)
                        {
                            stContent.Append("</br>" + orinfo.Express_xx);
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

                stContent.Append("<a class='ajaxlink' href='" + PageValue.WebRoot + "ajax/branch.aspx?action=orderview&id=" + orinfo.Id + "'>详情</a>");

                stContent.Append("</tr>");
                i++;
            }

           
        }
        else
        {
            stContent.Append("<tr><td colspan='10'>暂无数据！</td></tr>");
            ltOrderContent.Text = stContent.ToString();
        }
        pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        ltOrderContent.Text = stContent.ToString();
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1" runat="server" method="post">
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
                                        已发货</h2>
                                    <%}
                                      else if (strkey == "3")
                                      {%>
                                    <h2>
                                        未发货</h2>
                                    <%}
                                      else
                                      { %>
                                    <h2>
                                        付款订单</h2>
                                    <%} %>
                                    <ul class="contact-filter" style="top: 48px">
                                        <uc3:BranchOrder_PartnerSearch ID="BranchOrder_PartnerSearch1" runat="server" />
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
    function isNum() {
        if (event.keyCode < 48 || event.keyCode > 57) {
            event.keyCode = 0;
        }
    }
    function clearNoNum(obj) {
        obj.value = obj.value.replace(/[^\d.]/g, "");  //清除“数字”和“.”以外的字符 
        obj.value = obj.value.replace(/^\./g, "");  //验证第一个字符是数字而不是. 
        obj.value = obj.value.replace(/\.{2,}/g, "."); //只保留第一个. 清除多余的. 
        obj.value = obj.value.replace(".", "$#$").replace(/\./g, "").replace("$#$", ".");
    }
</script>
<%LoadUserControl("_footer.ascx", null); %>

