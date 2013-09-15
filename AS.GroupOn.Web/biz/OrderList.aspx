<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>

<%@ Register Src="~/UserControls/Order_PartnerSearch.ascx" TagName="Order_PartnerSearch"
    TagPrefix="uc5" %>
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
    protected OrderFilter orfilter = new OrderFilter();
    protected IPagers<IOrder> pager = null;
    protected IList<IOrder> ilistorder = null;
    protected IList<IOrderDetail> ilistordetail = null;
    protected OrderDetailFilter ordetailfilter = new OrderDetailFilter();
    protected string keys = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        _system = WebUtils.GetSystem();
        if (Request.HttpMethod == "GET")
        {
            page = Helper.GetInt(Request.QueryString["page"], 0);
        }

        int key = Helper.GetInt(Request["key"], 0);
        strkey = key.ToString();

        sql = Order_PartnerSearch1.GetWhereString();
        url = Order_PartnerSearch1.GetUrl();

        if (key == 2) //已发货
        {
            orfilter.Wheresql1 = "State='pay' and service!='cashondelivery' and (Express_id>0 and len(Express_no)>0)" + sql;

        }
        else if (key == 3) //未发货
        {
            orfilter.Wheresql2 = "State='pay' and service!='cashondelivery' and (Express_id=0 or len(Express_no)=0)" + sql;

        }
        else if (key == 4)
        {
            orfilter.Wheresql3 = "[state] = 'refunding' or  [state]='refund'" + sql;

        }
        else  //默认显示 付款订单
        {
            orfilter.Wheresql4 = "([state]='pay' or ([service]='cashondelivery' and [State]='nocod') or [state]='scorepay' )" + sql;

        }

        InitPage();
    }

    private void InitPage()
    {
        StringBuilder stTitle = new StringBuilder();
        stTitle.Append("<tr>");
        stTitle.Append("<th width='10%'>ID</th>");
        stTitle.Append("<th width='15%'>项目</th>");
        stTitle.Append("<th width='10%'>用户</th>");
        stTitle.Append("<th width='8%'>数量</th>");
        stTitle.Append("<th width='9%'>总款</th>");
        stTitle.Append("<th width='10%'>支付方式</th>");
        stTitle.Append("<th width='9%'>余付</th>");
        stTitle.Append("<th width='10%'>在线支付</br>货到付款</th>");
        stTitle.Append("<th width='10%'>递送方式</th>");
        stTitle.Append("<th width='9%'>详情</th>");
        stTitle.Append("</tr>");
        ltOrderTitle.Text = stTitle.ToString();

        StringBuilder stContent = new StringBuilder();
        orfilter.Partner_id = Helper.GetInt(CookieUtils.GetCookieValue("partner", keys), 0);

        orfilter.PageSize = 30;
        orfilter.AddSortOrder(OrderFilter.Pay_time_DESC);
        orfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Orders.GetPager2(orfilter);
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
                            stContent.Append("<a>项目已不存在!</a>");
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
                        stContent.Append("<a>项目已不存在!</a>");
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
                if (orinfo.State.ToString() == "refund")
                {
                    stContent.Append("<a class='ajaxlink' href='" + PageValue.WebRoot + "manage/ajax_partner.aspx?action=order_refund&id=" + orinfo.Id + "'>详情</a>");
                }
                else
                {
                    stContent.Append("<a class='ajaxlink' href='" + PageValue.WebRoot + "manage/ajax_partner.aspx?action=orderview&id=" + orinfo.Id + "'>详情</a>");
                }
                stContent.Append("</tr>");
                i++;
            }

            pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
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
                                      if (strkey == "3")
                                      { %>
                                    <h2>
                                        未发货</h2>
                                    <%}
                                      if (strkey == "4")
                                      { %>
                                    <h2>
                                        退款订单</h2>
                                    <%}
                                      if (strkey != "2" && strkey != "3" && strkey != "4")
                                      {%>
                                    <h2>
                                        付款订单</h2>
                                    <%}%>
                                    <ul class="contact-filter" style="top: 48px">
                                        <script src="../upfile/js/datePicker/WdatePicker.js" type="text/javascript"></script>
                                        <uc5:Order_PartnerSearch ID="Order_PartnerSearch1" runat="server" />
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
                                            <%if (strkey != "4")
                                              {%>
                                            <td colspan='10'>
                                                <span style='color: red'>(只显示已付款或货到付款的快递订单，需要管理员开通购物车及订单拆分功能)</span>
                                            </td>
                                            <%} %>
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
