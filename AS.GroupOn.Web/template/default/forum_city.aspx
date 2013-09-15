<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<script runat="server">
    protected IPagers<ITopic> page = null;
    protected TopicFilter filter = new TopicFilter();
    protected IList<ITopic> list = null;
    protected string PageHtml = String.Empty;
    protected string Pagepar = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        //base.OnLoad(e);
        if (CurrentCity != null)
        {
            AS.GroupOn.Controls.PageValue.Title = CurrentCity.Name + "讨论区| " + ASSystemArr["abbreviation"];
        }
        else
        {
            AS.GroupOn.Controls.PageValue.Title = "全部城市讨论区" + ASSystemArr["abbreviation"];
        }
        Get_Bbs();
    }
    #region 查询讨论区帖子

    public void Get_Bbs()
    {
        string ename = "";
        if (CurrentCity != null)
        {
            ename = CurrentCity.Ename;
        }
        Pagepar = GetUrl("讨论区城市", "forum_city.aspx?page={0}");
        filter.AddSortOrder(TopicFilter.Create_Time_DESC);
        filter.AddSortOrder(TopicFilter.Head_DESC);
        filter.PageSize = 30;
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        filter.Parent_id = 0;
        filter.Public_id = CurrentCity.Id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            page = session.Topic.GetPager(filter);
        }
        if (page != null)
        {
            list = page.Objects;
        }
        if (list.Count == 0)
        {
            PageHtml = "对不起，没有相关数据";
        }
        else
        {
            if (list.Count > 0)
            {
                PageHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, page.TotalRecords, page.CurrentPage, Pagepar);
            }
        }
    }
    #endregion
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="form1" runat="server">
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="forum">
            <div class="dashboard" id="dashboard">
                <ul>
                    <li><a href="<%=GetUrl("讨论区所有","forum_index.aspx")%>">所有</a><span></span> </li>
                    <li class="current"><a href="<%=GetUrl("讨论区城市", "forum_city.aspx")%>">
                        <%if (CurrentCity != null)
                          { %>
                        <%=CurrentCity.Name%>讨论区
                        <% }
                          else
                          {%>
                        全部城市讨论区
                        <% }%>
                    </a><span></span></li>
                    <li><a href="<%=GetUrl("公共讨论区", "forum_aspublic.aspx")%>">公共讨论区</a><span></span></li></ul>
            </div>
            <div id="content-old" class="coupons-box clear">
                <div class="box clear">
                    <div class="box-content">
                        <div class="head">
                            <%if (CurrentCity != null)
                              { %>
                            <h2>
                                <%=CurrentCity.Name%>讨论区话题</h2>
                            <% }%>
                            <ul class="filter">
                                <li><a href="<%=GetUrl("发表新话题", "forum_new.aspx")%>">＋发表新话题</a></li></ul>
                        </div>
                        <div class="sect">
                            <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table" width="98%">
                                <tr>
                                    <th width="440">
                                        话题
                                    </th>
                                    <th width="80" nowrap>
                                        作者/时间
                                    </th>
                                    <th width="80" nowrap>
                                        回复/阅读
                                    </th>
                                    <th width="100" nowrap>
                                        最后发表
                                    </th>
                                </tr>
                                <%int i = 1;
                                  foreach (ITopic bbsmodel in list)
                                  {
                                      IUser usermodel = null;
                                      IUser user = null;
                                      using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                      {
                                          if (bbsmodel.Last_user_id != 0)
                                          {
                                              user = session.Users.GetByID(bbsmodel.Last_user_id);
                                          }
                                          else
                                          {
                                              user = session.Users.GetByID(bbsmodel.User_id);
                                          }
                                          usermodel = session.Users.GetByID(bbsmodel.User_id);
                                      }
                                %>
                                <tr <%if( i%2 !=0 ){ %> class="alt" <%} %>>
                                    <td style="text-align: left;">
                                        <%if (bbsmodel.Head != 0)
                                          { %>
                                        <a class="deal-title" href="<%=GetUrl("城市讨论区", "forum_topic.aspx?id="+bbsmodel.id)%>"
                                            style="color: Red">
                                            <%= bbsmodel.Title%></a>
                                        <%}
                                          else if (bbsmodel.Head == 0)
                                          { %>
                                        <a class="deal-title" href="<%=GetUrl("城市讨论区", "forum_topic.aspx?id="+bbsmodel.id)%>">
                                            <%= bbsmodel.Title%></a>
                                        <% }%>
                                    </td>
                                    <td class="author" nowrap>
                                        <%if (usermodel != null)
                                            { %><%=usermodel.Username%><br />
                                        <%} %><%=bbsmodel.create_time.ToShortDateString() %>
                                    </td>
                                    <td align="center" nowrap>
                                        <%= bbsmodel.Reply_number %>/<%=bbsmodel.View_number %>
                                    </td>
                                    <td class="author" nowrap>
                                        <%if (user != null)
                                          { %><%=user.Username%><br />
                                        <%} %>
                                        <%=bbsmodel.Last_time %>
                                    </td>
                                </tr>
                                <%  i++;
                                      } %>
                                <tr>
                                    <td colspan="4">
                                        <%=PageHtml %>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <%--<div id="sidebar">
                <% LoadUserControl(WebRoot + "UserControls/blocksubscribe.ascx", null); %>
            </div>--%>
        </div>
    </div>
</div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
