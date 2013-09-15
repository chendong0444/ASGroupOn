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
    IPagers<ICoupon> pager = null;
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
        base.OnLoad(e);
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
        string consum = "N";
        StringBuilder sb = new StringBuilder();
        if (Request["consum"] != null)
        {
            consum = Request["consum"].ToString();

            if (consum == "Y")
            {
                sb.Append("<li><a href=\"" + GetUrl("我的优惠券全部", "coupon_index.aspx?consum=N") + "\">未使用</a> </li>");
                sb.Append("<li class='current'><a href=\"" + GetUrl("我的优惠券全部", "coupon_index.aspx?consum=Y") + "\">已使用</a></li>");
                sb.Append(" <li><a href=\"" + GetUrl("我的优惠券全部", "coupon_index.aspx?consum=expire") + "\">已过期</a></li>");
            }
            else if (consum == "N")
            {
                sb.Append("<li class='current'><a href=\"" + GetUrl("我的优惠券全部", "coupon_index.aspx?consum=N") + "\">未使用</a> </li>");
                sb.Append("<li ><a href=\"" + GetUrl("我的优惠券全部", "coupon_index.aspx?consum=Y") + "\">已使用</a></li>");
                sb.Append(" <li><a href=\"" + GetUrl("我的优惠券全部", "coupon_index.aspx?consum=expire") + "\">已过期</a></li>");
            }
            else if (consum == "expire")
            {
                sb.Append("<li><a href=\"" + GetUrl("我的优惠券全部", "coupon_index.aspx?consum=N") + "\">未使用</a> </li>");
                sb.Append("<li ><a href=\"" + GetUrl("我的优惠券全部", "coupon_index.aspx?consum=Y") + "\">已使用</a></li>");
                sb.Append(" <li class='current'><a href=\"" + GetUrl("我的优惠券全部", "coupon_index.aspx?consum=expire") + "\">已过期</a></li>");
            }
        }
        else
        {
            sb.Append("<li class='current'><a href=\"" + GetUrl("我的优惠券全部", "coupon_index.aspx?consum=N") + "\">未使用</a> </li>");
            sb.Append("<li ><a href=\"" + GetUrl("我的优惠券全部", "coupon_index.aspx?consum=Y") + "\">已使用</a></li>");
            sb.Append(" <li><a href=\"" + GetUrl("我的优惠券全部", "coupon_index.aspx?consum=expire") + "\">已过期</a></li>");
        }
        litlink.Text = sb.ToString();

        //判断用户失效！
        NeedLogin();

        GetCoupon(consum);


    }

    #region  查询用户的站内券
    public void GetCoupon(string strconsum)
    {
        CouponFilter couponfil = new CouponFilter();
        couponfil.PageSize = 30;
        couponfil.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["pgnum"], 1);
        couponfil.User_id = AsUser.Id;
        if (Helper.GetString(strconsum, String.Empty) == "Y" || Helper.GetString(strconsum, String.Empty) == "N")
        {
            couponfil.Consume = Helper.GetString(strconsum, String.Empty);
        }
        if (strconsum == "expire") //查询过期的优惠券
        {

            couponfil.User_id = AsUser.Id;
            couponfil.ToExpire_time = DateTime.Now;
        }


        couponfil.AddSortOrder(CouponFilter.Create_time_DESC);
        couponfil.AddSortOrder(CouponFilter.ID_DESC);


        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Coupon.GetPager(couponfil);

        }

        couponlist = pager.Objects;

        if (pager.TotalRecords == 0)
        {
            strpage = "对不起，没有相关数据";
        }
        else
        {
            if (pager.TotalRecords >= 10)
            {
                strpage = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, Convert.ToInt32(pagenum), GetUrl("我的优惠券全部","coupon_index.aspx?consum=" + strconsum + "&pgnum={0}"));
            }
        }
    }
    #endregion

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
                                    <table id="orders-list2" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <td class="coupon-tt" colspan="6">我的站内券
                                            </td>
                                        </tr>
                                        <tr>
                                            <th width="180">项目名称
                                            </th>
                                            <th width="80" nowrap>优惠券编号
                                            </th>
                                            <th width="60" nowrap>密码
                                            </th>
                                            <th width="80" nowrap>开始时间
                                            </th>
                                            <th width="80" nowrap>有效日期
                                            </th>
                                            <th width="80">操作
                                            </th>
                                        </tr>
                                        <% int i = 0;%>
                                        <%foreach (ICoupon model in couponlist)
                                          {
                                             
                                        %>
                                        <tr <%if (i % 2 != 0)
                                              {%>
                                            class='alt' <%} %>>
                                            <td>
                                                <a class="deal-title" href="<%=getTeamPageUrl(model.Team_id)  %>" target="_blank">
                                                    <%=GetTeam(model.Team_id.ToString())%></a>
                                            </td>
                                            <td>
                                                <%=model.Id %>
                                            </td>
                                            <td>
                                                <%=model.Secret %>
                                            </td>
                                            <td>
                                                <%=((model.start_time.HasValue) ? model.start_time.Value.ToString("yyyy-MM-dd") : String.Empty)%>
                                            </td>
                                            <td>
                                                <%=DateTime.Parse(model.Expire_time.ToString()).ToString("yyyy-MM-dd") %>
                                            </td>
                                            <td>
                                                <%if (isTime(model.Expire_time) == false)
                                                  { %>
                                                已过期
                                                <% }
                                                  else if (model.Consume == "Y")
                                                  {
                                                %>
                                                      已消费
                                                      <% 
                                                  }
                                                  else
                                                  {%>
                                                <a href="<%=PageValue.WebRoot%>ajax/coupon.aspx?action=sms&id=<%=model.Id %>&csecret=<%=model.Secret%>" class="ajaxlink">短信</a>｜<a
                                                    href="<%=GetUrl("优惠券打印","coupon_print.aspx?couponid="+model.Id +"&csecret="+model.Secret)%>" target="_blank">打印</a>
                                                <% }%>
                                            </td>
                                        </tr>
                                        <% i++;
                                          }
                                        %>
                                        <tr>
                                            <td colspan="6">
                                                <%=strpage%>
                                            </td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
                                            <td></td>
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
