<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<script runat="server">
    public string pagenum = "1";
    protected IPagers<ITopic> pager = null;
    protected TopicFilter filter = new TopicFilter();
    protected IList<ITopic> list = null;
    protected string PageHtml = String.Empty;
    protected string Pagepar = String.Empty;
    public bool falg = false;//显示公共讨论区，true，显示公共类型里面的讨论区
    public string bbsname = "";//公共类型里面的讨论区名称
    public string ASNzY = "";
    protected override void OnLoad(EventArgs e)
    {
        //base.OnLoad(e);
        if (Request["pgnum"] != null)
        {
            if (!string.IsNullOrEmpty(Request["pgnum"]))
            {
                pagenum = Request["pgnum"].ToString();
            }
            else
            {
                SetError("参数非法");
            }
        }
        AS.GroupOn.Controls.PageValue.Title = Getbbs(Request["ASNzY"]) + "讨论区话题讨论区 | ";
        Get_Tbs();
    }
    #region 判断讨论区的类别
    public string Gettype(string id)
    {
        ICategory catemodel = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            catemodel = session.Category.GetByID(AS.Common.Utils.Helper.GetInt(id, 0));
        }
        string str = "";
        if (catemodel != null)
        {
            if (catemodel.Zone == "city")
            {
                str = "本地";
            }
            else
            {
                str = catemodel.Name;
            }
        }
        return str;
    }
    #endregion

    #region 显示讨论区类型
    public string Getbbs(string id)
    {
        string str = "";
        if (id == null || id == "")
        {
            str = "公共";
            falg = false;
        }
        else
        {
            if (!string.IsNullOrEmpty(Request["ASNzY"]))
            {
                ICategory model = null;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    model = session.Category.GetByID(AS.Common.Utils.Helper.GetInt(id, 0));
                }
                if (model != null)
                {
                    str = model.Name;
                    bbsname = model.Name;
                    ASNzY = Request["ASNzY"].ToString();
                    falg = true;
                }
            }
            else
            {
                SetError("参数非法");
            }
        }
        return str;
    }
    #endregion
    #region 查询讨论区帖子
    public void Get_Tbs()
    {
        if (Request["ASNzY"] != null && Request["ASNzY"] != "")
        {
            if (!string.IsNullOrEmpty(Request["ASNzY"].ToString()))
            {
                filter.Public_id = AS.Common.Utils.Helper.GetInt(Request["ASNzY"], 0);
                ASNzY = Request["ASNzY"].ToString();
            }
            else
            {
                SetError("参数非法");
            }
        }
        filter.AddSortOrder(TopicFilter.Head_DESC);
        filter.AddSortOrder(TopicFilter.Create_Time_DESC);
        Pagepar = GetUrl("公共讨论区", "forum_aspublic.aspx?ASNzY=" + ASNzY + "&pgnum={0}");
        filter.PageSize = 30;
        filter.Parent_id = 0;
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["pgnum"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Topic.GetByPageS(filter);
        }
        if (pager != null)
        {
            list = pager.Objects;
        }
        if (list == null || list.Count == 0)
        {
            PageHtml = "没有符合条件的数据";
        }
        else
        {
            if (list.Count > 0)
            {
                PageHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, Pagepar);
            }
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
            <div id="forum">
                <div class="dashboard" id="dashboard">
                    <ul>
                        <li><a href="<%=GetUrl("讨论区所有","forum_index.aspx")%>">所有</a><span></span></li>
                        <li><a href="<%=GetUrl("讨论区城市", "forum_city.aspx")%>">
                            <%if (CurrentCity != null)
                              { %>
                            <%=CurrentCity.Name%>讨论区
                            <% }
                              else
                              {%>
                            全部城市讨论区
                            <% }%>
                        </a><span></span></li>
                        <%if (falg)
                          { %>
                        <li><a href="<%=GetUrl("公共讨论区", "forum_aspublic.aspx")%>">公共讨论区</a><span></span></li>
                        <li class="current"><a href="<%=GetUrl("公共讨论区", "forum_aspublic.aspx?ASNzY="+ASNzY)%>">
                            <%=bbsname%></a><span></span></li>
                        <% }
                          else
                          {%>
                        <li class="current"><a href="<%=GetUrl("公共讨论区", "forum_aspublic.aspx")%>">公共讨论区</a><span></span></li>
                        <% }%>
                    </ul>
                </div>
                <div id="content-old" class="coupons-box clear">
                    <div class="box clear">
                        <div class="box-content">
                            <div class="head">
                                <h2>
                                    <%=Getbbs(Request["ASNzY"])%>讨论区话题</h2>
                                <%if (falg)
                                  { %>
                                <ul class="filter">
                                    <li><a href="<%=GetUrl("发表新话题", "forum_new.aspx?ASNzY="+ASNzY)%>">发表新话题</a></li></ul>
                                <% }
                                  else
                                  {%>
                                <ul class="filter">
                                    <li><a href="<%=GetUrl("发表新话题", "forum_new.aspx")%>">发表新话题</a></li></ul>
                                <% }%>
                            </div>
                            <div class="sect">
                                <table id="orders-list" cellspacing="0" width="98%" cellpadding="0" border="0" class="coupons-table">
                                    <tr>
                                        <th width="360">
                                            话题
                                        </th>
                                        <th width="80" nowrap>
                                            讨论区
                                        </th>
                                        <th width="80" nowrap>
                                            作者/时间
                                        </th>
                                        <th width="80" nowrap>
                                            回复/阅读
                                        </th>
                                        <th width="100">
                                            最后发表
                                        </th>
                                    </tr>
                                    <%int i = 1;
                                      foreach (ITopic bbsmodel in list)
                                      {
                                          IUser user = null;
                                          IUser usermodel = null;
                                          using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                          {
                                              if (bbsmodel.Last_user_id != 0)
                                              {
                                                  usermodel = session.Users.GetByID(bbsmodel.Last_user_id);
                                              }
                                              else
                                              {
                                                  usermodel = session.Users.GetByID(bbsmodel.User_id);
                                              }
                                              user = session.Users.GetByID(bbsmodel.User_id);
                                          }
                                    %>
                                    <tr <% if(i%2 !=0 ){%> class="alt" <%} %>>
                                        <td style="text-align: left;">
                                            <%if (bbsmodel.Head != 0)
                                              { %>
                                            <a class="deal-title" href="<%=GetUrl("城市讨论区", "forum_topic.aspx?id="+bbsmodel.id)%>"
                                                style="color: Red">
                                                <%=bbsmodel.Title%></a>
                                            <%}
                                              else if (bbsmodel.Head == 0)
                                              {%>
                                            <a class="deal-title" href="<%=GetUrl("城市讨论区", "forum_topic.aspx?id="+bbsmodel.id)%>">
                                                <%=bbsmodel.Title%></a>
                                            <%} %>
                                        </td>
                                        <td nowrap>
                                            <a href="<%=GetUrl("公共讨论区", "forum_aspublic.aspx?ASNzY="+bbsmodel.Public_id)%>">
                                                <%=Gettype(bbsmodel.Public_id.ToString())%></a>
                                        </td>
                                        <td class="author" nowrap>
                                        <%if (user != null)
                                            { %><%=user.Username%><br />
                                            <%} %><%=bbsmodel.create_time.ToShortDateString() %>
                                        </td>
                                        <td align="center" nowrap>
                                            <%= bbsmodel.Reply_number %>/<%=bbsmodel.View_number %>
                                        </td>
                                        <td class="author" nowrap>
                                        <%if (usermodel != null)
                                          { %>
                                            <%=usermodel.Username%><br />
                                           <%} %> <%=bbsmodel.Last_time %>
                                        </td>
                                    </tr>
                                    <%i++;
                                      }
                                    %>
                                    <tr>
                                        <td colspan="5">
                                            <%=PageHtml%>
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
</div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
