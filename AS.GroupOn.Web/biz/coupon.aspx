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
<script runat="server">
    public string strCouponname = "";
  
    public NameValueCollection _system = new NameValueCollection();
   
    int page = 1;
    protected string pagerhtml = String.Empty;
    string url = String.Empty;
    string request_tteamId = String.Empty;
    string request_orderId = String.Empty;
    string request_coupon = String.Empty;
    string request_state = String.Empty;
    string request_teamid = String.Empty;
   protected CouponFilter coufilter = new CouponFilter();
   protected IList<ICoupon> ilistcoupon = null;
   protected IPagers<ICoupon> pager = null;
   protected string key = FileUtils.GetKey();
   protected ISystem system = Store.CreateSystem();

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();

        if (Request["btnselect"] == "筛选")
        {
            request_tteamId = Helper.GetString(hidTeamId.Value, String.Empty);
            request_orderId = Helper.GetString(Request.QueryString["txtOrderId"], String.Empty);
            request_coupon = Helper.GetString(Request.QueryString["txtcoupon"], String.Empty);
            request_state = Helper.GetString(Request.QueryString["ddlstate"], String.Empty);
            page = Helper.GetInt(Request.QueryString["page"], 1);
            request_teamid = Helper.GetString(Request.QueryString["teamid"], String.Empty);
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            system = session.System.GetByID(1);
        }
        if (system != null)
        {
            strCouponname = system.couponname;
        }
        initPage();
    }


    private void initPage()
    {
        if (CookieUtils.GetCookieValue("partner",key) == null || CookieUtils.GetCookieValue("partner",key) == "")
        {
            Response.Redirect(WebRoot + "Login.aspx?action=merchant");
        }
        string strPartnerID = CookieUtils.GetCookieValue("partner",key).ToString();
      
        if (!string.IsNullOrEmpty(Request.QueryString["teamid"]))
        {
            coufilter.Team_ids = Helper.GetInt(Request.QueryString["teamid"], 0);
            url = "teamid=" + Request.QueryString["teamid"];
            hidTeamId.Value = Helper.GetInt(Request.QueryString["teamid"], 0).ToString();
        }
        else
        {
            if (!string.IsNullOrEmpty(request_tteamId))
            {
                coufilter.Team_ids = Helper.GetInt(request_tteamId, 0);
                url += "&txtTeamId=" + request_tteamId;
            }
        }
        if (!string.IsNullOrEmpty(Request.QueryString["txtOrderId"])) 
        {
            coufilter.Order_id = Helper.GetInt(Request.QueryString["txtOrderId"], 0);
            url += "&txtOrderId=" + Request.QueryString["txtOrderId"];
        }
        if (!string.IsNullOrEmpty(Request.QueryString["txtcoupon"]))   
        {
            coufilter.Id = Helper.GetString(Request.QueryString["txtcoupon"], string.Empty);
            url += "&txtcoupon=" + Request.QueryString["txtcoupon"];
        }
        if (!string.IsNullOrEmpty(Request.QueryString["ddlstate"]))
        {
            coufilter.Consume = Helper.GetString(Request.QueryString["ddlstate"], string.Empty);
            url += "&ddlstate=" + Request.QueryString["ddlstate"];
        }
        StringBuilder sb = new StringBuilder();

        coufilter.Partner_id = Helper.GetInt(CookieUtils.GetCookieValue("partner",key), 0);
        coufilter.AddSortOrder(CouponFilter.Create_time_DESC);
        coufilter.PageSize=30;
        coufilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Coupon.GetPager2(coufilter);
        }
        ilistcoupon = pager.Objects;
        sb.Append("<tr><th width=\"15%\" nowrap>编号</th><th width=\"25%\">项目名称</th><th width=\"15%\">购买者</th><th width=\"10%\" nowrap>密码</th><th width=\"12%\" nowrap>开始时间</th><th width=\"13%\" nowrap>有效日期</th><th width=\"10%\">状态</th></tr>");
        
        if (ilistcoupon.Count > 0)
        {
            int i = 0;
           foreach(ICoupon coupon in ilistcoupon)
            {
                //显示的数据
                if (i % 2 != 0)
                {
                    sb.Append("<tr  id='team-list-id-" + coupon.Id + "'>");
                }
                else
                {
                    sb.Append("<tr class=\"alt\"  id='team-list-id-" + coupon.Id + "'>");
                }

                sb.Append("<td>" +coupon.Id.ToString() + "</td>");
                if (coupon.Team != null && coupon.Team.Title != null)
                {
                    sb.Append("<td width=\"450\" nowrop>" + coupon.Team_id.ToString() + "&nbsp;(<a class=\"deal-title\" href=\"" + getTeamPageUrl(int.Parse(coupon.Team_id.ToString())) + "\" target=\"_blank\">" + coupon.Team.Title + "</a>)</td>");
                }
                else
                {
                    sb.Append("<td width=\"450\" nowrop></td>");
                }


                UserFilter ufilter = new UserFilter();
                IUser mUser = Store.CreateUser();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    mUser = session.Users.GetByID(Helper.GetInt(coupon.User_id,0));
                }
                if (mUser != null)
                {
                    sb.Append("<td nowrap>" + mUser.Email + "<br/>" + mUser.Username + "</td>");
                }
                else
                {
                    sb.Append("<td nowrap></td>");
                }
                if (system != null)
                {
                    if (ASSystem.partnerdown == 1)
                    {
                        sb.Append("<td>" +coupon.Secret.ToString() + "</td>");

                    }
                    else
                    {
                        sb.Append("<td>*******</td>");
                    }
                }
                sb.Append("<td nowrap>" + ((coupon.start_time is DateTime) ? DateTime.Parse(coupon.start_time.ToString()).ToString("yyyy-MM-dd") : String.Empty) + "</td>");
                sb.Append("<td nowrap>" + DateTime.Parse(coupon.Expire_time.ToString()).ToString("yyyy-MM-dd") + "</td>");

                if (coupon.Consume.ToString() == "Y")
                {
                    sb.Append("<td nowrap>已消费<br/>");

                }
                else
                {
                    if (Convert.ToDateTime(DateTime.Parse(coupon.Expire_time.ToString()).ToString("yyyy-MM-dd 23:59:59")) < DateTime.Now)
                    {
                        sb.Append("<td nowrap>已过期</td>");
                    }
                    else
                    {
                        sb.Append("<td nowrap>有效</td>");
                    }
                }

                sb.Append("</tr>");
                i++;
            }
        }
        else
        {
            sb.Append("<tr><td colspan=\"7\">暂无数据！</td></tr>");
        }
        
        ltCouponn.Text = sb.ToString();
        pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, PageValue.WebRoot + "biz/coupon.aspx?" + url + "&page={0}");
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
                                        <%=strCouponname %>列表</h2>
                                    <ul class="contact-filter">
                                        <li>
                                            项目ID：<input type="text" id="txtTeamId" name="txtTeamId" class="h-input" <%if(!string.IsNullOrEmpty(request_tteamId)){ %> disabled="disabled" value="<%=request_tteamId %>" <%}
                                            if(!string.IsNullOrEmpty(Request.QueryString["teamid"]))
                                            {%> disabled="disabled" value="<%=Request.QueryString["teamid"] %>"
                                            
                                            <%} %> 
                                             />
                                            订单ID：<input type="text" id="txtOrderId" name="txtOrderId" class="h-input" <%if(!string.IsNullOrEmpty(Request.QueryString["txtOrderId"])){ %>value="<%=Request.QueryString["txtOrderId"] %>" <%} %> 
                                             />
                                            券编号：<input type="text" id="txtcoupon" name="txtcoupon" class="h-input" <%if(!string.IsNullOrEmpty(Request.QueryString["txtcoupon"])){ %>value="<%=Request.QueryString["txtcoupon"] %>" <%} %> 
                                             />&nbsp;
                                            
                                            <select id="ddlstate" name="ddlstate" class="h-input">
                                            <option value="" selected="selected">请选择</option>
                                            <option value="Y" <%if(Request.QueryString["ddlstate"] == "Y"){ %>selected="selected" <%} %> >已使用</option>
                                            <option value="N" <%if(Request.QueryString["ddlstate"] == "N"){ %>selected="selected" <%} %>>未使用</option>
                                            </select>
                                            <input type="submit" value="筛选" name="btnselect" class="formbutton validator" style="padding: 1px 6px;" />
                                            <input id="hidTeamId" type="hidden" runat="server" />
                                            </li></ul>
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