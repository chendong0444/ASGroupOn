<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>

<%@ Register Src="~/UserControls/Order_PartnerCashOnDelivery.ascx" TagName="Order_PartnerCashOnDelivery"
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
    public int page = 1;
    public string sqll;
    public string where = String.Empty;
    protected string pagerhtml = String.Empty;
    protected OrderFilter orfilter = new OrderFilter();
    protected IPagers<IOrder> pager = null;
    protected IList<IOrder> ilistorder = null;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Order_PartnerCashOnDelivery1.SearchExpress = true;
        if (CookieUtils.GetCookieValue("partner", key) == null || CookieUtils.GetCookieValue("partner", key) == "")
        {
            Response.Redirect(WebRoot + "Login.aspx?action=merchant");
        }
        if (Request.HttpMethod == "GET")
        {
            page = Helper.GetInt(Request.QueryString["page"], 1);
        }
        Order_PartnerCashOnDelivery1.PartnerId = int.Parse(CookieUtils.GetCookieValue("partner", key));

        InitPage();

    }

    private void InitPage()
    {
        if (CookieUtils.GetCookieValue("partner", key) == null || CookieUtils.GetCookieValue("partner", key) == "")
        {
            Response.Redirect(WebRoot + "Login.aspx?action=merchant");
        }
        StringBuilder stTitle = new StringBuilder();
        stTitle.Append("<tr>");
        stTitle.Append("<th width='15%'>ID</th>");
        stTitle.Append("<th class='xiangmu'  width='25%'>项目</th>");
        stTitle.Append("<th width='15%'>用户</th>");
        stTitle.Append("<th width='20%'>派送地址</th>");
        stTitle.Append("<th width='10%'>快递公司</th>");
        stTitle.Append("<th width='15%'>操作</th>");
        stTitle.Append("</tr>");
        ltOrderTitle.Text = stTitle.ToString();
        sqll = sql + "  Partner_id=" + CookieUtils.GetCookieValue("partner", key) + " and service='cashondelivery' and (state='nocod' or state='pay') and Express='Y' and Express_id>0 and isnull(express_xx,'')<>'已打印'";
        sql = Order_PartnerCashOnDelivery1.GetWhereString();
        url = Order_PartnerCashOnDelivery1.GetUrl();
        where = Convert.ToBase64String(HttpUtility.UrlEncodeToBytes(sqll, Encoding.UTF8));
        StringBuilder stContent = new StringBuilder();
        orfilter.Wheresql1 = "Partner_id=" + CookieUtils.GetCookieValue("partner", key) + " and service!='cashondelivery' and State='pay' and Express='Y' and Express_id>0 and isnull(express_xx,'')<>'已打印'" + sql;
       
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
                //ID
                stContent.Append("<td>" + orinfo.Id + "</td>");

                //订单详情
                IList<IOrderDetail> ilistorde = null;
                OrderDetailFilter ordefilter = new OrderDetailFilter();
                ordefilter.Order_ID = orinfo.Id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ilistorde = session.OrderDetail.GetList(ordefilter);
                }
                //项目
                if (ilistorde.Count > 0)
                {
                    stContent.Append("<td>");
                    foreach (IOrderDetail ordeinfo in ilistorde)
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
                            stContent.Append("<a target='_blank' href='" + getTeamPageUrl(Helper.GetInt(ordeinfo.Teamid.ToString(), 0)) + "'>" + team.Title + "</a>");
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
                    stContent.Append("<td>");
                    ITeam team = Store.CreateTeam();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        team = session.Teams.GetByID(orinfo.Team_id);
                    }
                    stContent.Append("<b>项目ID" + orinfo.Id + "</b>" + "(总共:" + orinfo.Quantity + "件)");
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
                stContent.Append("<td>" + userInfo.Username + "</br>" + userInfo.Email + "</td>");
                //派送地址
                stContent.Append("<td>" + orinfo.Address + "</td>");
                //快递公司
                IList<ICategory> ilistcate = null;
                CategoryFilter catefilter = new CategoryFilter();
                catefilter.Zone = "express";
                catefilter.AddSortOrder(CategoryFilter.Sort_Order_DESC);
                catefilter.AddSortOrder(CategoryFilter.ID_ASC);
                catefilter.Id = orinfo.Express_id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    ilistcate = session.Category.GetList(catefilter);
                }
                foreach (ICategory cate in ilistcate)
                {
                    if (cate != null && cate.Name != null)
                    {
                        stContent.Append("<td>" + cate.Name + "<br />" + orinfo.Express_no + "</td>");
                    }
                    else
                    {
                        stContent.Append("<td><br />" + orinfo.Express_no + "</td>");
                    }
                }
                //操作
                stContent.Append("<td class='op' nowrap>");
                stContent.Append("<a class='ajaxlink' href='" + PageValue.WebRoot + "manage/ajax_print.aspx?action=print&amp;id=" + orinfo.Id + "'>打印快递</a>｜ ");
                stContent.Append("<a class='ajaxlink' href='" + PageValue.WebRoot + "manage/ajax_partner.aspx?action=orderview&id=" + orinfo.Id + "'>详情</a>");
                stContent.Append("</tr>");
                i++;
            }
            pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
            ltOrderContent.Text = stContent.ToString();
        }
        else
        {
            stContent.Append("<tr><td colspan='6'>暂无数据！</font></td></tr>");
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
        <script src="../upfile/js/datePicker/WdatePicker.js" type="text/javascript"></script>
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        未打印
                                    </h2>
                                    <ul class="contact-filter" style="top: 48px">
                                        <uc5:Order_PartnerCashOnDelivery ID="Order_PartnerCashOnDelivery1" runat="server" />
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="ltOrderTitle" runat="server"></asp:Literal>
                                        <asp:Literal ID="ltOrderContent" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="6" class="style1">
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
