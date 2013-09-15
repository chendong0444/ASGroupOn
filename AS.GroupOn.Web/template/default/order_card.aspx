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
<script runat="server">
    string sql = " 1=1 ";
    ITeam teammodel = null;
    IList<ICard> cardlist = null;
    IPagers<ICard> pager = null;
    IUser userInfo = null;
    public string par = "";
    public string teamid = "";
    public string partnerid = "";
    public string strcode = "";
    public string strpage;
    public string pagenum = "1";
    public string consume = "all";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Ordertype = "card";

        //判断用户失效！
        NeedLogin();

        if (!Page.IsPostBack)
        {
            if (Request["pagenum"] != null)
            {
                if (AS.Common.Utils.NumberUtils.IsNum(Request["pagenum"].ToString()))
                {
                    pagenum = Request["pagenum"].ToString();
                }
                else
                {
                    SetError("您输入的参数非法");
                }
            }
            else
            {
                pagenum = "1";
            }
        }
        GetCardByUserId();
    }

    IPartner partner = null;
    private void GetCardByUserId()
    {
        CardFilter cardfil = new CardFilter();
        if (Request["consume"] != null && Request["consume"].ToString() != "")
        {
            consume = Request["consume"].ToString();
            if (consume == "n") //未消费
            {
                cardfil.consume = "N";
                cardfil.FromEnd_time = DateTime.Now;
            }
            if (consume == "y") //已消费
            {
                cardfil.consume = "Y";
            }
            if (consume == "d")
            {
                cardfil.consume = "N";
                cardfil.ToEnd_time = DateTime.Now;
            }
        }

        cardfil.isGet = 1;
        cardfil.user_id = AsUser.Id;
        cardfil.PageSize = 30;
        cardfil.CurrentPage = Helper.GetInt(Request["consume"], 0);
        cardfil.AddSortOrder(CardFilter.Begin_time_Desc);
        StringBuilder stBTitle = new StringBuilder();
        StringBuilder stBContent = new StringBuilder();
        stBTitle.Append("<tr >");
        stBTitle.Append("<th width='10%'>ID</th>");
        stBTitle.Append("<th width='10%'>面额</th>");
        stBTitle.Append("<th width='10%'>有效期限</th>");
        stBTitle.Append("<th width='50%'>可使用项目</th>");
        stBTitle.Append("<th width='20%'>状态</th>");
        stBTitle.Append("</tr>");

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Card.GetPager(cardfil);

        }
        cardlist = pager.Objects;
        if (pager != null)
        {
            if (pager.TotalRecords > 0)
            {
                for (int i = 0; i < cardlist.Count; i++)
                {
                    if (i % 2 != 0)
                    {
                        stBContent.Append("<tr class='alt'>");
                    }
                    else
                    {
                        stBContent.Append("<tr>");
                    }
                    stBContent.Append("<td>" + cardlist[i].Id.ToString() + "</td>");
                    stBContent.Append("<td nowrap>" + ASSystem.currency + cardlist[i].Credit.ToString() + "</td>");
                    stBContent.Append("<td nowrap>" + cardlist[i].Begin_time.ToString() + "<br/>" + cardlist[i].End_time.ToString() + "</td>");
                    if (cardlist[i].Team != null)
                    {
                        stBContent.Append("<td>" + cardlist[i].Team.Title + "</td>");
                    }
                    else if (int.Parse(cardlist[i].Team_id.ToString()) == 0 && int.Parse(cardlist[i].Partner_id.ToString()) != 0)
                    {
                        stBContent.Append("<td><a class='ajaxlink' href='" + PageValue.WebRoot + "ajax/card.aspx?action=pt&partnerId=" + int.Parse(cardlist[i].Partner_id.ToString()) + "'>查看</a></td>");
                    }
                    else
                    {
                        stBContent.Append("<td>暂无项目</td>");
                    }
                    if (cardlist[i].consume.ToString() == "Y")
                    {
                        stBContent.Append("<td nowrap>已消费</td>");
                    }
                    else if (cardlist[i].consume.ToString() == "N" && Convert.ToDateTime(cardlist[i].End_time) < DateTime.Now)
                    {
                        stBContent.Append("<td nowrap>已过期</td>");
                    }
                    else if (cardlist[i].consume.ToString() == "N" && Convert.ToDateTime(cardlist[i].End_time) >= DateTime.Now)
                    {
                        stBContent.Append("<td nowrap>未消费</td>");
                    }
                    else
                    {
                        stBContent.Append("<td nowrap></td>");
                    }
                    stBContent.Append("</tr>");
                }
            }
        }
        Literal1.Text = stBTitle.ToString();
        Literal2.Text = stBContent.ToString();

        if (pager.TotalRecords >= 30)
        {
            strpage = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, Convert.ToInt32(pagenum), GetUrl("我的代金券", "order_card.aspx?consume=" + consume + "&pagenum={0}"));
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
                                <h2>我的代金券</h2>
                                <div class="clear" >
                                </div>
                                <ul class="filter-card">
                                    <li class="label">分类: </li>
                                    <li <%=GetStyle("all",consume) %> ><a href="<%=GetUrl("我的代金券", "order_card.aspx?consume=all") %>">全部</a> </li>
                                    <li <%=GetStyle("n",consume) %>><a href="<%=GetUrl("我的代金券", "order_card.aspx?consume=n") %>">未消费</a> </li>
                                    <li <%=GetStyle("y",consume) %>><a href="<%=GetUrl("我的代金券", "order_card.aspx?consume=y") %>">已消费</a> </li>
                                    <li <%=GetStyle("d",consume) %>><a href="<%=GetUrl("我的代金券", "order_card.aspx?consume=d") %>">已过期</a></li>
                                </ul>
                            </div>
                            <div class="sect">
                                <div class="clear">
                                </div>
                                <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                    <asp:literal id="Literal1" runat="server"></asp:literal>
                                    <asp:literal id="Literal2"
                                        runat="server"></asp:literal>
                                    <tr>
                                        <td colspan="10">
                                            <ul class="paginator">
                                                <li class="current">
                                                    <%=strpage%>
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
    </div>
</form>
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %>
