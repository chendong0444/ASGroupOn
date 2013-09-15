<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerBranchPage" %>


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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public string strCouponname = "";
    
    private NameValueCollection _system = new NameValueCollection();
    int page = 1;
    protected string pagerhtml = String.Empty;
    protected int type = 0;
    string url = String.Empty;
    string request_teamid = String.Empty;
    string request_pcoupon = String.Empty;
    string request_state = String.Empty;
    protected PcouponFilter pcoufilter = new PcouponFilter();
    protected IPagers<IPcoupon> pager = null;
    protected IList<IPcoupon> ilistpcoupon = null;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();


        if (CookieUtils.GetCookieValue("pbranch", key) == null || CookieUtils.GetCookieValue("pbranch", key) == "")
        {
            Response.Redirect(WebRoot + "login.aspx?action=pbranch");
        }



        if (Request.HttpMethod == "POST")
        {
            request_pcoupon = txtcoupon.Value.ToString();
            request_state = ddlstate.Value.ToString();
            request_teamid = Helper.GetString(Request.QueryString["teamid"], String.Empty);
        }
        else
        {
            request_pcoupon = Helper.GetString(Request.QueryString["pcoupon"], String.Empty);
            request_state = Helper.GetString(Request.QueryString["state"], String.Empty);
            request_teamid =Helper.GetString(Request.QueryString["teamid"], String.Empty);
            page = Helper.GetInt(Request.QueryString["page"], 1);
            txtcoupon.Value = request_pcoupon;
            ddlstate.Value = request_state;
            
        }
        initPage();

    }

    private void initPage()
    {
        string strSqlWhere = "where 1=1";

        if (request_teamid != String.Empty)
        {
            strSqlWhere = strSqlWhere + " and teamid=" + request_teamid;
            url = "teamid=" + request_teamid;
        }
        if (request_pcoupon != String.Empty)
        {
            strSqlWhere = strSqlWhere + " and number='" + request_pcoupon + "' ";
            url += "&pcoupon=" + request_pcoupon;
        }
        if (request_state != "0" && request_state != String.Empty)
        {
            strSqlWhere = strSqlWhere + " and  state='" + request_state + "'";
            url += "&state=" + request_state;
        }
        pcoufilter.table = "(select * from (SELECT [User].Username, [User].Email, Team.Title,team.city_id, pcoupon.* FROM  pcoupon LEFT OUTER JOIN Team ON pcoupon.teamid = Team.Id LEFT OUTER JOIN [User] ON pcoupon.userid = [User].Id)t where t.teamid in(select id from Team where branch_id=" + Helper.GetInt(CookieUtils.GetCookieValue("pbranch", key).ToString(), 0) + "))t " + strSqlWhere;
        
        pcoufilter.PageSize = 30;
        pcoufilter.CurrentPage = page;
        pcoufilter.AddSortOrder(PcouponFilter.CREATE_TIME_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Pcoupon.PagerPcoupon(pcoufilter);
        }
        StringBuilder sb = new StringBuilder();
        sb.Append("<tr><th width=\"15%\" nowrap>券号</th><th width=\"25%\">项目名称</th><th width=\"19%\">购买者</th><th width=\"13%\" nowrap>开始时间</th><th width=\"13%\" nowrap>有效日期</th><th width=\"15%\">状态</th></tr>");
        ilistpcoupon = pager.Objects;
        if (ilistpcoupon.Count > 0)
        {
            int i = 0;
            foreach(IPcoupon pcouinfo in ilistpcoupon)
            {
                //显示的数据
                if (i % 2 != 0)
                {
                    sb.Append("<tr  id='team-list-id-" + pcouinfo.id + "'>");
                }
                else
                {
                    sb.Append("<tr class=\"alt\"  id='team-list-id-" + pcouinfo.id + "'>");
                }
                sb.Append("<td>" + pcouinfo.number.ToString() + "</td>");
                ITeam mTeam = Store.CreateTeam();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mTeam = session.Teams.GetByID(Helper.GetInt(pcouinfo.teamid, 0));
                }
                sb.Append("<td>" + pcouinfo.teamid.ToString() + "&nbsp;(<a class=\"deal-title\" href=\"" + getTeamPageUrl(Helper.GetInt(pcouinfo.teamid,0)) + "\" target=\"_blank\">" + mTeam.Title + "</a>)</td>");

                IUser mUser = Store.CreateUser();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mUser = session.Users.GetByID(Helper.GetInt(pcouinfo.userid, 0));
                }
                if (mUser != null)
                {
                    sb.Append("<td nowrap>" + mUser.Email + "<br/>" + mUser.Username + "</td>");
                }
                else
                {
                    sb.Append("<td nowrap></td>");
                }

                sb.Append("<td nowrap>" + ((pcouinfo.start_time is DateTime) ? DateTime.Parse(pcouinfo.start_time.ToString()).ToString("yyyy-MM-dd") : String.Empty) + "</td>");
                sb.Append("<td nowrap>" + DateTime.Parse(pcouinfo.expire_time.ToString()).ToString("yyyy-MM-dd") + "</td>");

                if (pcouinfo.state.ToString() == "buy")
                {
                    sb.Append("<td nowrap>已购买<br/>");

                }
                else
                {
                    sb.Append("<td nowrap>未被购买</td>");
                }


                sb.Append("</tr>");
                i++;
            }
        }
        else
        {
            sb.Append("<tr><td colspan=\"6\">暂无数据！</td></tr>");
        }

        pagerhtml = WebUtils.GetPagerHtml(30, pager.TotalRecords, page, PageValue.WebRoot + "partnerbranch/pcoupon.aspx?" + url + "&page={0}");
        ltCouponn.Text = sb.ToString();

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
                                    <h2>
                                        站外券列表</h2>
                                    <ul class="contact-filter">
                                        <li>券编号：<input type="text" id="txtcoupon" runat="server" class="h-input" />&nbsp;
                                            <select id="ddlstate" runat="server">
                                            <option value="0" selected="selected">请选择</option>
                                            <option value="buy">已购买</option>
                                            <option value="nobuy">未购买</option>
                                            </select>
                                            <input type="submit" value="筛选" name="btnselect" class="formbutton" style="padding: 1px 6px;" /></li></ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="ltCouponn" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="7">
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