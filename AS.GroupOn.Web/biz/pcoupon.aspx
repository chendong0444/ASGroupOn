<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>


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
    protected string pagerhtml = String.Empty;
    string url = String.Empty;
    string request_teamid = String.Empty;
    string request_pcoupon = String.Empty;
    string request_state = String.Empty;
    int page = 1;
    protected PcouponFilter pcoufilter = new PcouponFilter();
    protected IList<IPcoupon> ilistpcoupon = null;
    protected IPagers<IPcoupon> pager = null;
    protected ISystem system = Store.CreateSystem();
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();

        //if (Request.HttpMethod == "POST")
        //{
        //    request_pcoupon = txtcoupon.Value.ToString();
        //    request_state = ddlstate.Value.ToString();
        //    request_teamid = Helper.GetString(Request.QueryString["teamid"], String.Empty);
        //}
        //else
        //{
        if (Request["btnselect"] == "筛选")
        {
            request_pcoupon = Helper.GetString(Request.QueryString["txtcoupon"], String.Empty);
            request_state = Helper.GetString(Request.QueryString["state"], String.Empty);
           
            page = Helper.GetInt(Request.QueryString["page"], 1);
        }
        //}
        request_teamid = Helper.GetString(Request.QueryString["teamid"], String.Empty);
        initPage();

    }

    private void initPage()
    {
        string strPartnerID = CookieUtils.GetCookieValue("partner").ToString();
      
        if (request_teamid != String.Empty)
        
        {
            pcoufilter.teamid =Helper.GetInt(request_teamid,0);
            url = "teamid=" + request_teamid;
        }

        //if (request_pcoupon != String.Empty)
        if (!string.IsNullOrEmpty(Request.QueryString["txtcoupon"]))
        {
            pcoufilter.number = Request.QueryString["txtcoupon"];
            url += "&txtcoupon=" + Request.QueryString["txtcoupon"];
        }
        //if (request_state != "0" && request_state != String.Empty)
        if (!string.IsNullOrEmpty(Request.QueryString["ddlstate"]))
        {
            pcoufilter.state = Request.QueryString["ddlstate"];
            url += "&ddlstate=" + Request.QueryString["ddlstate"];
        }
        StringBuilder sb = new StringBuilder();
        pcoufilter.partnerid = Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0);
        pcoufilter.AddSortOrder(PcouponFilter.CREATE_TIME_DESC);
        pcoufilter.PageSize = 30;
        pcoufilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Pcoupon.GetPager2(pcoufilter);
        }
        ilistpcoupon = pager.Objects;
        sb.Append("<tr><th width=\"15%\" nowrap>券号</th><th width=\"25%\">项目名称</th><th width=\"15%\">购买者</th><th width=\"15%\" nowrap>开始时间</th><th width=\"15%\" nowrap>有效日期</th><th width=\"15%\">状态</th></tr>");
       
        if (ilistpcoupon.Count > 0)
        {
            int i = 0;
            foreach(IPcoupon pcoupon in ilistpcoupon)
            {
                //显示的数据
                if (i % 2 != 0)
                {
                    sb.Append("<tr  id='team-list-id-" + pcoupon.id + "'>");
                }
                else
                {
                    sb.Append("<tr class=\"alt\"  id='team-list-id-" + pcoupon.id + "'>");
                }
                sb.Append("<td>" + pcoupon.number.ToString() + "</td>");

                ITeam mteam = Store.CreateTeam();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mteam = session.Teams.GetByID(Helper.GetInt(pcoupon.teamid, 0));
                }
                sb.Append("<td>" + pcoupon.teamid.ToString() + "&nbsp;(<a class=\"deal-title\" href=\"" + getTeamPageUrl(int.Parse(pcoupon.teamid.ToString())) + "\" target=\"_blank\">" + mteam.Title + "</a>)</td>");

                UserFilter ufilter = new UserFilter();
                IUser mUser = Store.CreateUser();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mUser = session.Users.GetByID(Helper.GetInt(pcoupon.userid, 0));
                }
                if (mUser != null)
                {
                    sb.Append("<td nowrap>" + mUser.Email + "<br/>" + mUser.Username + "</td>");
                }
                else
                {
                    sb.Append("<td nowrap></td>");
                }
                sb.Append("<td nowrap>" + ((pcoupon.start_time is DateTime) ? DateTime.Parse(pcoupon.start_time.ToString()).ToString("yyyy-MM-dd") : String.Empty) + "</td>");
                sb.Append("<td nowrap>" + DateTime.Parse(pcoupon.expire_time.ToString()).ToString("yyyy-MM-dd") + "</td>");

                if (pcoupon.state.ToString() == "buy")
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

        pagerhtml =AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, PageValue.WebRoot + "biz/pcoupon.aspx?" + url + "&page={0}");
        ltCouponn.Text = sb.ToString();

    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
<form id="form1" runat="server" method="get">
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
                                        <li>券编号：<input type="text" id="txtcoupon" name="txtcoupon" class="h-input" <%if(!string.IsNullOrEmpty(Request.QueryString["txtcoupon"])){ %>value="<%=Request.QueryString["txtcoupon"] %>"
                                            <%} %> />
                                            <select id="ddlstate" name="ddlstate" class="h-input">
                                            <option value="">请选择</option>
                                            <option value="buy" <%if(Request.QueryString["ddlstate"] == "buy"){ %>selected="selected" <%} %>>已购买</option>
                                            <option value="nobuy" <%if(Request.QueryString["ddlstate"] == "nobuy"){ %>selected="selected" <%} %>>未购买</option>
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