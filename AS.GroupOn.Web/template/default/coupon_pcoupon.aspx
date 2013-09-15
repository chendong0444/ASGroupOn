<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace=" System " %>
<%@ Import Namespace=" System.Collections.Generic " %>
<%@ Import Namespace=" System.Web " %>
<%@ Import Namespace=" System.Web.UI " %>
<%@ Import Namespace=" System.Web.UI.WebControls " %>
<%@ Import Namespace=" System.Data.SqlClient " %>
<%@ Import Namespace=" System.Data " %>
<%@ Import Namespace=" System.Collections.Specialized " %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>


<script runat="server">
    IPagers<IPcoupon> pager = null;
    public IList<ICoupon> couponlist = null;
    public IList<IPcoupon> pcouponlist = null;
    public ITeam teammodel = null;
    protected NameValueCollection _system = new NameValueCollection();
    public string strpage;
    public string pagenum = "1";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = PageValue.CurrentSystemConfig;// 得到系统配置表信息
        Ordertype = "coupon";

        //判断用户失效！
        NeedLogin();
        if (Request["pgnum"] != null)
        {
            if (NumberUtils.IsNum(Request["pgnum"].ToString()))
            {
                pagenum = Request["pgnum"].ToString();
            }
            else
            {
                SetError("您输入的参数非法");
            }
        }
        StringBuilder sb = new StringBuilder();

        litlink.Text = sb.ToString();
        GetPcoupon();
    }


    #region 根据项目编号，查询项目内容
    public string GetTeam(string id)
    {
        string str = "";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(Helper.GetInt(id, 0));
        }
        if (teammodel != null)
        {
            str = teammodel.Title;
        }

        return str;
    }
    #endregion

    #region  查询用户的站外券
    public void GetPcoupon()
    {

        PcouponFilter pcouponfil = new PcouponFilter();
        pcouponfil.PageSize = 30;
        pcouponfil.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["pgnum"], 1);
        pcouponfil.userid = AsUser.Id;
        pcouponfil.AddSortOrder(PcouponFilter.CREATE_TIME_DESC);
        pcouponfil.AddSortOrder(PcouponFilter.ID_DESC);



        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Pcoupon.GetPager(pcouponfil);

        }
        pcouponlist = pager.Objects;

        if (pcouponlist.Count == 0)
        {
            strpage = "对不起，没有相关数据";
        }
        else
        {
            if (pager.TotalRecords >= 30)
            {
                strpage = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, Convert.ToInt32(pagenum), GetUrl("我的站外券全部", "coupon_pcoupon.aspx?pgnum={0}"));
            }
        }



    }
    #endregion
    #region 判断优惠券的到期日期是否大于当前日期，如果大于，返回true
    public bool isTime(DateTime Consume_time)
    {
        if (Convert.ToDateTime(Consume_time.ToString("yyyy-MM-dd 23:59:59")) > DateTime.Now)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    #endregion
</script>

<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1" runat="server">
        <div id="pagemasker">
        </div>
        <div id="dialog">
        </div>
        <div id="doc">

            <div id="bdw" class="bdw">
                <div id="bd" class="cf">
                    <div id="coupons">
                        <div class="menu_tab" id="dashboard">
                            <%LoadUserControl("_MyWebside.ascx", Ordertype); %>
                        </div>
                        <div id="tabsContent" class="coupons-box">

                            <div class="box-content1 tab">
                                <div class="head">
                                    <h2 class="coupon-zwq">
                                       <a href="<%=GetUrl("我的优惠券全部","coupon_index.aspx")%>">我的站内券</a></h2>
                                    <h2>
                                        <a href="<%=GetUrl("我的站外券全部","coupon_pcoupon.aspx") %>">我的站外券</a></h2>
                                    <%LoadUserControl(WebRoot + "UserControls/blockaboutcoupon.ascx", null); %>

                                    <ul class="filter">
                                        <li class="label"></li>
                                        <asp:Literal ID="litlink" runat="server"></asp:Literal>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <td class="coupon-tt" colspan="6">我的站外券
                                            </td>
                                        </tr>
                                        <tr>
                                            <th width="180">项目名称
                                            </th>
                                            <th width="80" nowrap>优惠券编号
                                            </th>
                                            <th width="80" nowrap>开始时间
                                            </th>
                                            <th width="200" nowrap colspan="2">有效日期
                                            </th>
                                            <th width="80">操作
                                            </th>
                                        </tr>
                                        <% int j = 0;%>
                                        <%foreach (IPcoupon model in pcouponlist)
                                          { %>

                                        <tr <%if (j % 2 != 0)
                                              {%> class='alt' <%} %>>
                                            <td>
                                                <a class="deal-title" href="<%=getTeamPageUrl(model.teamid)  %>" target="_blank"><%=GetTeam(model.teamid.ToString())%></a>
                                            </td>
                                            <td>
                                                <%=model.number %>
                                            </td>
                                            <td>
                                                <%=((model.start_time.HasValue) ? model.start_time.Value.ToString("yyyy-MM-dd") : String.Empty)%>
                                            </td>
                                            <td colspan="2">
                                                <%=DateTime.Parse(model.expire_time.ToString()).ToString("yyyy-MM-dd") %>
                                            </td>
                                            <td>
                                                <%if (isTime(model.expire_time) == false)
                                                  {%>
                                                已过期
                                                <% }
                                                  else
                                                  {%>
                                                <a href="/ajax/coupon.aspx?action=psms&id=<%=model.id %>" class="ajaxlink">短信</a>
                                                <% }%>
                                            </td>
                                        </tr>
                                        <%j++;
                                          }%>
                                        <tr>
                                            <td colspan="6">
                                                <%=strpage%>
                                            </td>
                                            <td></td>
                                            <td></td>
                                            <td colspan="2"></td>
                                            <td class="coupon-more" style="text-align: right; color: #000;"></td>
                                        </tr>
                                    </table>
                                </div>
                            </div>

                        </div>

                    </div>
                </div>
            </div>

        </div>
    </form>
</body>
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %> 