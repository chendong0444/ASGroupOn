<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">
    
    public NameValueCollection _system = new NameValueCollection();
    public string state = "all";
    public int id = 0;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected IPagers<IOrder> pager = null;
    protected IList<IOrder> iListOrder = null;
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Ordertype = "partner";
        
        //判断用户失效！
        NeedLogin();
        
        if (Request["id"] != null)
        {
            if (!string.IsNullOrEmpty(Request["id"]))
            {
                if (NumberUtils.IsNum(Request["id"].ToString()))
                {
                    id = int.Parse(Request["id"].ToString());
                }
            }
            else
            {
                SetError("您输入的参数非法");
            }
        }
        if (Request["state"] == "no")
        {
            state = "no";
        }
        GetPartner();
    }

    public void GetPartner()
    {
        _system = WebUtils.GetSystem();
        StringBuilder stBTitle = new StringBuilder();
        StringBuilder stBContent = new StringBuilder();
        stBTitle.Append("<tr>");
        stBTitle.Append("<th width='250'>商户名称</th>");
        stBTitle.Append("<th width='400'>项目名称</th>");
        stBTitle.Append("<th width='100'>状态</th>");
        stBTitle.Append("<th width='100'>操作</th>");
        stBTitle.Append("</tr>");

        IUser usermodel = null;
        UserFilter userft = new UserFilter();
        //userft.Username = CookieUtils.GetCookieValue("username", AS.Common.Utils.FileUtils.GetKey());
        int uid = Convert.ToInt32(CookieUtils.GetCookieValue("userid", AS.Common.Utils.FileUtils.GetKey()));
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            //usermodel = session.Users.GetByName(userft);
            usermodel = session.Users.GetByID(uid);
        }
        int userid = Helper.GetInt(usermodel.Id, 0);
        OrderFilter orderfilter = new OrderFilter();
        orderfilter.PageSize = 30;
        orderfilter.AddSortOrder(OrderFilter.Teamid_DESC);
        orderfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        orderfilter.userid = userid;
        if (state == "no")
        {
            orderfilter.Wheresql1 = "Userreview.id is null ";
        }
        if (id > 0)
        {
            orderfilter.Wheresql1 = "Team.Partner_id=" + id;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Orders.GetPagerPartner(orderfilter);
        }
        iListOrder = pager.Objects;

        if (iListOrder != null)
        {
            if (iListOrder.Count > 0)
            {
                int i = 0;
                foreach (IOrder iorderInfo in iListOrder)
                {
                    ITeam team = null;
                    IPartner partner = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        team = session.Teams.GetByID(iorderInfo.tid);
                        partner = session.Partners.GetByID(iorderInfo.tpartnerid);
                    }
                    if (i % 2 != 0)
                    {
                        stBContent.Append("<tr class='alt'>");
                    }
                    else
                    {
                        stBContent.Append("<tr>");
                    }
                    i++;
                    if (partner != null)
                    {
                        stBContent.Append("<td width='250'><a class='deal-title' href='" + getPartnerPageUrl(Helper.GetString(_system["isrewrite"], "0"), iorderInfo.tpartnerid) + "' target='_blank' title='" + partner.Title + "' >" + partner.Title + "</a></td>");
                    }
                    else
                    {
                        stBContent.Append("<td></td>");
                    }
                    if (team != null)
                    {
                        stBContent.Append("<td width='400'><a class='deal-title' href='" + getTeamPageUrl(iorderInfo.tid) + "' target='_blank' title='" + team.Title + "' >" + team.Title + "</a></td>");
                    }
                    else
                    {
                        stBContent.Append("<td></td>");
                    }
                    if (iorderInfo.urevid.ToString() == "0" || iorderInfo.urevid==null)
                    {
                        stBContent.Append("<td width='100'>未评论</td>");
                        if (_system["openUserreviewPartner"] != null && _system["openUserreviewPartner"] == "1")
                        {
                            stBContent.Append("<td width='100'><a class='ajaxlink' href='" + WebRoot + "ajax/list_comments.aspx?id=" + iorderInfo.tid + "&pid=" + iorderInfo.tpartnerid + "&uid=" + userid + "'>评论</td>");
                        }
                        else
                        {
                            stBContent.Append("<td width='100'>未开启</td>");
                        }
                    }
                    else
                    {
                        stBContent.Append("<td width='100'>已评论</td>");
                        stBContent.Append("<td width='100'>----</td>");
                    }
                    stBContent.Append("</tr>");
                }
            }
            else
            {
                stBContent.Append("<div class='comments'>");
                stBContent.Append("暂无评论");
                stBContent.Append("</div>");
            }
            Literal1.Text = stBTitle.ToString();
            Literal2.Text = stBContent.ToString();

            if (pager.TotalRecords >= 30)
            {
                if (id > 0)
                {
                    url = url + "&page={0}";

                    url = GetUrl("个人中心商户评论", "buy_Send_list_partner.aspx?" + url.Substring(1));
                    url = url + "&id=" + id;
                    url = url + "&state=" + state;
                    pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
                }
                else
                {
                    url = url + "&page={0}";
                    url = GetUrl("个人中心商户评论", "buy_Send_list_partner.aspx?" + url.Substring(1));
                    url = url + "&state=" + state;
                    pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
                }
            }
        }
    }

    #region 样式
    public string GetStyle(string s, string style)
    {
        string str = "";
        if (s == style)
        {
            str = "class='current'";
        }

        return str;
    }
    #endregion
    
</script>

<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="coupons">
            <div class="menu_tab" id="dashboard">
                <%LoadUserControl("_MyWebside.ascx", Ordertype); %>
            </div>
            <div id="tabsContent" class="coupons-box">
                <div class="box-content1 tab">
                    <div class="head">
                        <h2>
                            商户评论</h2>
                        <div class="clear">
                        </div>
                        <ul class="filter">
                            <li class="label">分类: </li>
                            <li <%=GetStyle("all",state) %>>
                                <%if (id > 0)
                                  {%><a href="<%=GetUrl("个人中心商户评论", "buy_Send_list_partner.aspx?id=" + id)%>"><%}
                                  else
                                  {%><a href="<%=GetUrl("个人中心商户评论", "buy_Send_list_partner.aspx")%>"><%} %>全部</a></li>
                            <li <%=GetStyle("al",state) %>>
                                <%if (id > 0)
                                  {%><a href="<%=GetUrl("个人中心商户已评论", "buy_Send_list_pcomments.aspx?id=" + id)%>"><%}
                                  else
                                  {%><a href="<%=GetUrl("个人中心商户已评论", "buy_Send_list_pcomments.aspx")%>"><%} %>已评论</a> </li>
                            <li <%=GetStyle("no",state) %>>
                                <%if (id > 0)
                                  {%><a href="<%=GetUrl("个人中心商户评论", "buy_Send_list_partner.aspx?state=no&id=" + id)%>"><%}
                                  else
                                  {%><a href="<%=GetUrl("个人中心商户评论", "buy_Send_list_partner.aspx?state=no")%>"><%} %>未评论</a> </li>
                        </ul>
                        <div class="header_info">
                            <br>
                            <strong>我如何才能发表商户评论?</strong>
                            <br>
                            <p>
                                只有当您成功购买过此商户下的项目，才能对此商户发表您的评论。</p>
                        </div>
                    </div>
                    <div class="sect">
                        <div class="clear">
                        </div>
                        <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                            <asp:literal id="Literal1" runat="server"></asp:literal>
                            <asp:literal id="Literal2" runat="server"></asp:literal>
                            <tr>
                                <td colspan="4">
                                    <ul class="paginator">
                                        <li class="current">
                                            <%=pagerHtml %>
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
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %>  