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
    
    public string state = "all";
    public NameValueCollection _system = new NameValueCollection();
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected IPagers<IOrder> pager = null;
    protected IList<IOrder> iListOrder = null;
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Ordertype = "buy";

        //判断用户失效！
        NeedLogin();
        if (Request["state"] == "no")
        {
            state = "no";
        }
        url = url + "&state=" + state;
        GetTeam();
    }

    private void GetTeam()
    {
        _system = WebUtils.GetSystem();
        StringBuilder stBTitle = new StringBuilder();
        StringBuilder stBContent = new StringBuilder();
        stBTitle.Append("<tr>");
        stBTitle.Append("<th width='120'>项目图片</th>");
        stBTitle.Append("<th width='500'>项目名称</th>");
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
        
        url = url + "&page={0}";
        url = GetUrl("个人中心产品评论", "buy_Send_list_team.aspx?" + url.Substring(1));
        OrderFilter orderfilter = new OrderFilter();
        orderfilter.PageSize = 30;
        orderfilter.AddSortOrder(OrderFilter.Teamid_DESC);
        orderfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        orderfilter.userid = userid;
        
        string wherestr = "(Userreview.Type is null or Userreview.Type = 'team')";
        if (state == "no")
        {
            wherestr += " and Userreview.id is null";
        }
        orderfilter.Wheresql1 = wherestr;

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Orders.GetPagerPLTeam(orderfilter);
        }
        iListOrder = pager.Objects;

        if (iListOrder != null)
        {
            if (iListOrder.Count > 0)
            {
                int i = 0;
                foreach (IOrder iorderInfo in iListOrder)
                {
                    if (i % 2 != 0)
                    {
                        stBContent.Append("<tr class='alt'>");
                    }
                    else
                    {
                        stBContent.Append("<tr>");
                    }
                    i++;
                    ITeam team = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        team = session.Teams.GetByID(iorderInfo.vtid);
                    }
                    if (team != null)
                    {
                        stBContent.Append("<td width='120'><div class='deal_pic'>");

                        stBContent.Append("<a href='" + getTeamPageUrl(iorderInfo.vtid) + "' target='_blank' title='" + team.Title + "'>");
                        stBContent.Append("<img src='" + ImageHelper.getSmallImgUrl(team.Image) + "' width='110' height='70'  border='0'/>");
                        stBContent.Append("</a>");
                        stBContent.Append("</div></td>");
                        stBContent.Append("<td width='400'><a class='deal-title' href='" + getTeamPageUrl(iorderInfo.vtid) + "' target='_blank' title='" + team.Title + "' >" + team.Title + "</a></td>");

                    }
                    else
                    {
                        stBContent.Append("<td></td>");
                        stBContent.Append("<td width='400'></td>");
                    }
                    if (iorderInfo.urid.ToString()=="0"|| iorderInfo.urid==null)
                    {
                        stBContent.Append("<td width='100'>未评论</td>");
                        if (_system["navUserreview"] != null && _system["navUserreview"] == "1")
                        {
                            stBContent.Append("<td width='100'><a class='ajaxlink' href='" + WebRoot + "ajax/list_comments.aspx?id=" + iorderInfo.vtid + "&uid=" + userid + "'>评论</td>");
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
            pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
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
                            产品评论</h2>
                        <div class="clear">
                        </div>
                        <ul class="filter">
                            <li class="label">分类: </li>
                            <li <%=GetStyle("all",state) %>><a href="<%=GetUrl("个人中心产品评论", "buy_Send_list_team.aspx")%>">全部</a> </li>
                            <li <%=GetStyle("al",state) %>><a href="<%=GetUrl("产品未评论分页用", "buy_send_listcomments.aspx") %>">已评论</a> </li>
                            <li <%=GetStyle("no",state) %>><a href="<%=GetUrl("个人中心产品评论", "buy_Send_list_team.aspx?state=no")%>">未评论</a> </li>
                        </ul>
                        <div class="header_info">
                            <br>
                            <strong>我如何才能发表到货评论?</strong>
                            <br>
                            <p>
                                只有当您成功购买过此商品后，才能对此商品发表您的到货评论。</p>
                            <br>
                            <strong>我发表了评论，什么时候能返利呢？</strong>
                            <br>
                            <p>
                                如果您发表了评论，请等待管理员的审核通过，通过后会将返利直接冲入您的账户。</p>
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
