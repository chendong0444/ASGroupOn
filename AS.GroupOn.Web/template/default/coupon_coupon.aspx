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
   
    public IList<ICoupon> couponlist = null;
    public IList<IPcoupon> pcouponlist = null;
    public ITeam teammodel = null;
    protected NameValueCollection _system = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = PageValue.CurrentSystemConfig;// 得到系统配置表信息
        Ordertype = "coupon";
        //判断用户失效！
        NeedLogin();

        GetCoupon();

        GetPcoupon();
    }

    #region  查询用户的站内券
    public void GetCoupon()
    {
        CouponFilter couponfil = new CouponFilter();
        couponfil.User_id = AsUser.Id;
        couponfil.AddSortOrder(" Create_time desc,id desc");
        couponfil.Top = 5;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            couponlist = session.Coupon.GetList(couponfil);
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

    #region  查询用户的站外券
    public void GetPcoupon()
    {
        PcouponFilter pcouponfil = new PcouponFilter();
        pcouponfil.userid = AsUser.Id;
        pcouponfil.AddSortOrder(" buy_time desc,id desc");
        pcouponfil.Top = 5;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pcouponlist = session.Pcoupon.GetList(pcouponfil);
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
                                <h2>我的优惠券</h2>
                                <%LoadUserControl(WebRoot + "UserControls/blockaboutcoupon.ascx", null); %>

                                <ul class="filter">
                                    <li class="label"></li>
                                    <asp:literal id="litlink" runat="server"></asp:literal>
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
                                      { %>
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
                                          }%>
                                    <tr>
                                        <td>
                                            <a class="deal-title" href="#" target="_blank"></a>
                                        </td>
                                        <td></td>
                                        <td></td>
                                        <td></td>
                                        <td></td>
                                        <td class="coupon-more" style="text-align: right; color: #000;">
                                            <a href="<%=GetUrl("我的优惠券全部","coupon_index.aspx")%>" target="_blank">》更多</a>
                                        </td>
                                    </tr>
                                </table>
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
                                          {%>
                                        class='alt' <%} %>>
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
                                        <td>
                                            <a class="deal-title" href="#" target="_blank"></a>
                                        </td>
                                        <td></td>
                                        <td></td>
                                        <td colspan="2"></td>
                                        <td class="coupon-more" style="text-align: right; color: #000;">
                                            <a href="<%=GetUrl("我的站外券全部","coupon_pcoupon.aspx") %>" target="_blank">》更多</a>
                                        </td>
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
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %>
