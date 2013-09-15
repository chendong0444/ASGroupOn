<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BasePage" %>

<%@ Register Src="~/UserControls/blockbusiness.ascx" TagName="blockbusiness" TagPrefix="uc1" %>
<%@ Register Src="~/UserControls/blocksubscribe.ascx" TagName="blocksubscribe" TagPrefix="uc2" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected ISystem ASSystem = null;
    protected string strWebName = "";
    protected string strNav = "";
    protected string strpage;
    protected string pagenum = "1";
    protected string retungid = "";
    protected string url = "";
    protected NameValueCollection _system = new NameValueCollection();
    protected IPagers<IPartner> pager = null;
    protected IList<IPartner> iListPartner = null;
    protected string pagerHtml = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = AS.Common.Utils.WebUtils.GetSystem();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ASSystem = session.System.GetByID(1);
        }
        if (Request["pgnum"] != null)
        {
            pagenum = Request["pgnum"].ToString();
        }
        if (Request["gid"] != null)
        {
            retungid = Request["gid"].ToString();
        }
        if (ASSystem.title == String.Empty)
        {
            PageValue.Title = "品牌商户" + "-" + ASSystem.sitetitle;
        }
        if (!Page.IsPostBack)
        {
            initWebName();
            initPage();
        }

    }

    private void initWebName()
    {
        SystemFilter systemft = new SystemFilter();
        IList<ISystem> listsystem = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listsystem = session.System.GetList(systemft);
        }
        System.Data.DataTable dt = null;
        dt = AS.Common.Utils.Helper.ToDataTable(listsystem.ToList());
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {

                if (dt.Rows[0]["abbreviation"] == null || dt.Rows[0]["abbreviation"].ToString() == "")
                {
                    strWebName = "艾尚团购";
                }
                else
                {
                    strWebName = dt.Rows[0]["abbreviation"].ToString();
                }
            }
        }
    }

    private void initPage()
    {
        StringBuilder sb = new StringBuilder();
        PartnerFilter partnerft = new PartnerFilter();

        string strGID = "";
        if (Request["gid"] == null || Request["gid"].ToString() == "")
        {
            strGID = "";
        }
        else
        {
            strGID = Request["gid"].ToString();
        }

        if (!AS.Common.Utils.NumberUtils.IsNum(strGID))
        {
            SetError("你输入的参数有误！");
            return;
        }

        partnerft.Open = "Y";
        if (strGID != "")
        {
            partnerft.Group_id = AS.Common.Utils.Helper.GetInt(strGID, 0);
        }

        if (ASSystem != null && CurrentCity != null&& CurrentCity.Id!=0)
        {
            if (ASSystem.citypartner == 1)
            {
                partnerft.City_id = CurrentCity.Id;
            }
        }

        url = url + "&page={0}";
        url = GetUrl("品牌商户", "partner_index.aspx?" + url.Substring(1));
        partnerft.AddSortOrder(PartnerFilter.CreateTime_DESC);
        partnerft.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        partnerft.PageSize = 10;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Partners.GetPager(partnerft);
        }
        iListPartner = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(10, pager.TotalRecords, pager.CurrentPage, url);
        System.Data.DataTable dt = AS.Common.Utils.Helper.ToDataTable(iListPartner.ToList());
        if (dt != null)
        {
            if (dt.Rows.Count > 0)
            {
                for (int i = 0; i < dt.Rows.Count; i++)
                {

                    string strId = dt.Rows[i]["ID"].ToString();
                    string strTitle = dt.Rows[i]["Title"].ToString();
                    string strPhone = dt.Rows[i]["Phone"].ToString();
                    string strImg = dt.Rows[i]["Image"].ToString();
                    string strOther = dt.Rows[i]["Other"].ToString();
                    string strOpen = dt.Rows[i]["Open"].ToString();


                    sb.Append("<li class=\"\">");
                    sb.Append("<h4><a href=" + GetUrl("品牌商户详情", "partner_view.aspx?id=" + strId) + " title=\"" + strTitle + "\" target=\"_blank\">" + strTitle + "</a><br/>联系电话：" + strPhone + "</h4>");
                    sb.Append("<div class=\"pic\">");
                    sb.Append("<a href=" + GetUrl("品牌商户详情", "partner_view.aspx?id=" + strId) + " title=\"" + strTitle + "\" target=\"_blank\"><img alt=\"" + strTitle + "\" src=\"" + strImg + "\" width=\"155\" height=\"99\"></a>");
                    sb.Append("</div>");

                    TeamFilter teamft = new TeamFilter();
                    UserReviewFilter UserReviewft = new UserReviewFilter();
                    //根据商户ID获取评论
                    UserReviewft.type = "partner";
                    UserReviewft.state = 1;
                    UserReviewft.partner_id = int.Parse(strId);
                    IList<IUserReview> ilistuserreview = null;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        ilistuserreview = session.UserReview.GetList(UserReviewft);
                    }
                    System.Data.DataTable dt2 = AS.Common.Utils.Helper.ToDataTable(ilistuserreview.ToList());

                    if (_system["openUserreviewPartner"] != null && _system["openUserreviewPartner"].ToString() == "1")
                    {
                        //总评论分值
                        int allCount = 0;
                        //用户评论分值
                        int count = 0;
                        //循环评论分值
                        if (dt2.Rows.Count > 0)
                        {
                            for (int z = 0; z < dt2.Rows.Count; z++)
                            {
                                if (int.Parse(dt2.Rows[z]["score"].ToString()) == 0)
                                {
                                    count = count + 0;
                                }
                                else
                                {
                                    count = count + int.Parse(dt2.Rows[z]["score"].ToString());
                                }
                                allCount = allCount + 100;
                            }
                        }

                        sb.Append("<ul class='three-hang'>");
                        if (allCount == 0)
                        {
                            sb.Append("<li>满意度：<span style='color:red'>--%</span></li>");
                        }
                        else
                        {
                            sb.Append("<li>满意度：<span style='color:red'>" + Convert.ToDouble((Convert.ToDouble(count) / Convert.ToDouble(allCount)).ToString("0.00")) * 100 + "%</span></li>");
                        }
                        sb.Append("<li>共" + dt2.Rows.Count + "条评论</li>");
                        sb.Append("<li><a href=" + GetUrl("品牌商户详情", "partner_view.aspx?id=" + strId) + " target=\"_blank\">查看全部评论</a></li>");
                        sb.Append("</ul>");
                    }
                    sb.Append("<div class=\"parinfo\">" + strOther + "</div>");
                    sb.Append("</li>");
                }
            }
        }
        ltpartne.Text = sb.ToString();
    }  
    
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="recent-deals">
            <div id="content">
                <div class="box">
                    <div class="box-content">
                        <div class="head">
                            <%if (ASSystem.catepartner == 1)
                              {%>
                            <dl class="sq-t">
                                <dt><a href="#">商家分类</a></dt>
                                <dd>
                                    <%
                                        CategoryFilter categoryft = new CategoryFilter();
                                        IList<ICategory> categorylist = null;
                                        categoryft.Zone = "partner";
                                        categoryft.Display = "Y";
                                        categoryft.AddSortOrder(CategoryFilter.Sort_Order_DESC);
                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                        {
                                            categorylist = session.Category.GetList(categoryft);
                                        }
                                        System.Data.DataTable dt = null;
                                        dt = AS.Common.Utils.Helper.ToDataTable(categorylist.ToList());
                                        if (dt != null)
                                        {
                                            if (dt.Rows.Count > 0)
                                            {
                                                if (retungid != "")
                                                {%>
                                    <a href="<%=GetUrl("品牌商户", "partner_index.aspx")%>">全部</a>
                                    <%}
                                                else
                                                { %>
                                    <a href="<%=GetUrl("品牌商户", "partner_index.aspx")%>" class="this_fl">全部</a>
                                    <%}
                                                for (int i = 0; i < dt.Rows.Count; i++)
                                                {
                                                    System.Data.DataRow dr = dt.Rows[i];
                                    %>
                                    <%if (retungid == dr["id"].ToString())
                                      {%>
                                    <a href="<%=GetUrl("品牌商户", "partner_index.aspx?gid="+dr["id"].ToString())%>" class="this_fl">
                                        <%=dr["Name"].ToString()%></a>
                                    <%}
                                      else
                                      {%>
                                    <a href="<%=GetUrl("品牌商户", "partner_index.aspx?gid="+dr["id"].ToString())%>">
                                        <%=dr["Name"].ToString()%></a>
                                    <%} %>
                                    <% 
}
                                            }
                                        }
                                        else
                                        {%>
                                    <a href="#">暂无商户</a>
                                    <%}
                              }
                              else
                              {
                                    %>
                                    <%} %>
                                </dd>
                            </dl>
                            <div class="clear">
                            </div>
                            <h2 style="">
                                <%=strWebName %>品牌商户</h2>
                        </div>
                        <div class="sect">
                            <ul class="deals-list">
                                <asp:literal id="ltpartne" runat="server"></asp:literal>
                            </ul>
                            <div class="clear">
                            </div>
                            <div>
                                <ul class="paginator">
                                    <li class="current">
                                        <%=strpage%>
                                        <%=pagerHtml %>
                                    </li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="sidebar">
                <uc1:blockbusiness ID="blockbusiness1" runat="server" />
                 <%LoadUserControl(WebRoot + "UserControls/blockbulletin.ascx", null); %>
                <uc2:blocksubscribe ID="blocksubscribe1" runat="server" />
               
            </div>
        </div>
    </div>
    <!-- bd end -->
</div>
<!-- bdw end -->
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>