<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.Domain.Spi" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<script runat="server">
    protected string pagePar = "";
    public string style1 = "";
    public string style2 = "";
    protected IPagers<ITeam> pager = null;
    protected TeamFilter filter = new TeamFilter();
    protected IList<ITeam> iListTeam = null;
    protected IList<ITeam> iListTeam1 = null;
    protected string pageHtml = String.Empty;
    protected string request_type = "0";
    private NameValueCollection _systemView = null;
    protected string[] arr;
    protected override void OnLoad(EventArgs e)
    {

        base.OnLoad(e);
        if (!IsPostBack)
        {
            _systemView = AS.Common.Utils.WebUtils.GetSystem();
            if (_systemView != null && _systemView["irange"]!=null)
            {
                arr = _systemView["irange"].Split('|');


            }
        }
        request_type = Request["typeid"] == "" ? "0" : Request["typeid"];
        if (CurrentCity != null)
        {
            filter.CurrentCityId = CurrentCity.Id;
        }
        if (request_type == "1")
        {
            style1 = "";
            style2 = "class='current'";
        }
        else
        {
            style1 = "class='current'";
            style2 = "";
        }
    
        #region 筛选
        if (!string.IsNullOrEmpty(Request["shop"])&& Request["shop"] != "0") 
        {

            filter.StarTeamScore =AS.Common.Utils.Helper.GetInt(System.Text.RegularExpressions.Regex.Split(Request["shop"],"——")[0],0);
            filter.EndTeamScore = AS.Common.Utils.Helper.GetInt(System.Text.RegularExpressions.Regex.Split(Request["shop"],"——")[1], 0);
            pagePar = pagePar + "&_start=" + AS.Common.Utils.Helper.GetInt(System.Text.RegularExpressions.Regex.Split(Request["shop"], "——")[0], 0);
            pagePar = pagePar +"&_endt="+AS.Common.Utils.Helper.GetInt(System.Text.RegularExpressions.Regex.Split(Request["shop"],"——")[1],0);
            
        }else if(!string.IsNullOrEmpty(Request.QueryString["_start"]) || !string.IsNullOrEmpty(Request.QueryString["_endt"]))
        {
            
            filter.StarTeamScore =AS.Common.Utils.Helper.GetInt(Request.QueryString["_start"],0);
            filter.EndTeamScore = AS.Common.Utils.Helper.GetInt(Request.QueryString["_endt"], 0);
            pagePar = pagePar + "&_start=" + AS.Common.Utils.Helper.GetInt(Request.QueryString["_start"], 0);
            pagePar = pagePar + "&_endt=" + AS.Common.Utils.Helper.GetInt(Request.QueryString["_endt"], 0);
        }

        #endregion
        //可兑换产品的积分项目
        if (request_type == "0" || request_type == null)
        {
            pagePar = "&page={0}&type=0" + pagePar;
            pagePar = GetUrl("积分商城", "PointsShop_PointList.aspx?" + pagePar);
            filter.PageSize = 30;
            filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
            filter.AddSortOrder(" begin_time desc,Sort_order desc ,Id desc");
            filter.Cityblockothers = CurrentCity.Id;

            filter.FromEndTime = DateTime.Now;
            filter.Team_type = "point";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pager = session.Teams.GetPager(filter);
            }
            if (pager != null)
            {
                iListTeam = pager.Objects;

            }
            if (pager.TotalRecords > 30)
            {
                pageHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, pagePar);
            }
        }

        //已结束的积分项目
        if (request_type == "1")
        {
            TeamFilter filter1 = new TeamFilter();
            filter1.Team_type = "point";
            filter1.EndToTime = DateTime.Now;
            filter1.CurrentCityId = CurrentCity.Id;
            ITeam list1 = null;
            IPagers<ITeam> pages = null;

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                list1 = session.Teams.Get(filter1);
            }
            if (list1 != null)
            {
                pagePar = pagePar + "&page={0}&typeid=1";
                pagePar = GetUrl("积分商城", "PointsShop_PointList.aspx?" + pagePar.Substring(1));
                filter.PageSize = 30;
                filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
                filter.AddSortOrder(" begin_time desc,Sort_order desc ,Id desc");
                filter.CurrentCityId = CurrentCity.Id;
                filter.Team_type = "point";
                filter.EndToTime = DateTime.Now;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    pages = session.Teams.GetPager(filter);
                }
                if (pages != null)
                {
                    iListTeam1 = pages.Objects;
                }
                if (pages.TotalRecords > 30)
                {
                    pageHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pages.TotalRecords, pages.CurrentPage, pagePar);
                }

            }
        }

    }   
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<form id="form1">
<div id="bdw" class="bdw">
    <div id="shop_box" class="cf">
        <div id="int_top">
            <div id="right_top">
                <span class="left bold">积分有什么用？</span>
                <!--  <a href="#" class="pink right help">更多帮助</a>-->
                <div class="clear">
                    1. 积分可累计使用<br />
                    2. 积分可兑换超值商品、限时秒杀等</div>
            </div>
        </div>
        <!--积分商城（新加）-->
        <div id="recent-deals">
            <div class="dashboard" id="dashboard">
                <ul>
                    <li <%=style1 %>><a href="<%=GetUrl("积分商城", "PointsShop_PointList.aspx?typeid=0")%>">
                        当前可兑换产品</a><span></span></li>
                    <li <%=style2 %>><a href="<%=GetUrl("积分商城", "PointsShop_PointList.aspx?typeid=1")%>">
                        已结束兑换产品</a><span></span></li>
                </ul>
                <!--积分数量搜索开始-->
                <div class="search">
                    根据积分数量&nbsp;&nbsp;
                    <%--<asp:dropdownlist id="shop" runat="server"></asp:dropdownlist>--%>
                    <select name="shop" id="shop">
                        <option value="0">请选择</option>
                        <%if (arr!=null&&arr.Length>0)
                          {%>
                                                 <% for (int i = 0; i < arr.Length; i++)
                        {
                            if (arr[i].IndexOf(',') != -1)
                            {
                                string[] lis = arr[i].Split(',');
                                %>
                                <option value="<%=lis[0] +" —— "+ lis[1] %>" <%if(Request["shop"]==(lis[0] +" —— "+ lis[1]).ToString()){ %> selected="selected"<%} %> ><%=lis[0]+"---"+lis[1] %></option>
                                <%
                                
                            }
                     } %>   
                          <%} %>
       
                     </select>
                    &nbsp;
                    <input type="submit" class="formbutton1" name="btnselect" value="搜索" /></div>
                <input type="hidden" name="typeid" value="<%=request_type %>" />
            </div>
            <div class="shop_content">
                <ul class="xmas_column">
                    <!--积分列表循环，开始-->
                    <%if (request_type == "0" || request_type == null)
                      { %>
                    <%foreach (ITeam item1 in iListTeam)
                      {%>
                    <li class='xmas_img_li'>
                        <div class='xmas_img'>
                            <a href="<%=GetUrl("积分详情","pointsshop_index.aspx?id="+item1.Id.ToString()) %>" title="<%=item1.Title.ToString() %>"
                                target="_blank">
                                <img alt="<%=item1.Title.ToString() %> " src="<%=AS.Common.Utils.ImageHelper.getSmallImgUrl(item1.Image).ToString() %>"
                                    class="dynload" width='224' height='143' />
                            </a>
                        </div>
                        <div class='xmas_pro'>
                            <a class='pink' href="<%=GetUrl("积分详情","pointsshop_index.aspx?id="+item1.Id.ToString()) %>"
                                title="<%=item1.Title.ToString() %>" target="_blank">
                                <%=item1.Title.ToString().Length>30?item1.Title.ToString().Substring(0,30)+"...":item1.Title.ToString()%></a></div>
                        <div class='xmas_price'>
                            <div class='left'>
                                市场价：<span class='money'><%=ASSystem.currency%></span><%=item1.Market_price%>
                            </div>
                            <div class='right'>
                                所需积分：<%= item1.teamscore%></div>
                        </div>
                        <div class='xmas_buy'>
                            <a href='<%=AS.GroupOn.Controls.PageValue.WebRoot %>ajax/Pcar.aspx?id=<%=item1.Id %>'
                                class='center'>立即兑换</a></div>
                    </li>
                    <%}%>
                    <%}
                      else if (request_type == "1" && iListTeam1 != null)
                      { %>
                    <%foreach (ITeam item in iListTeam1)
                      {%>
                    <li class='xmas_img_li'>
                        <div class='xmas_img'>
                            <a href="<%=GetUrl("积分详情","pointsshop_index.aspx?id="+item.Id.ToString()) %>" title="<%=item.Title.ToString() %>"
                                target="_blank">
                                <img alt="<%=item.Title.ToString() %> " src="<%=AS.Common.Utils.ImageHelper.getSmallImgUrl(item.Image).ToString() %>"
                                    class="dynload" width='224' height='143' />
                            </a>
                        </div>
                        <div class='xmas_pro'>
                            <a class='pink' href="<%=GetUrl("积分详情","pointsshop_index.aspx?id="+item.Id.ToString()) %>"
                                title="<%=item.Title.ToString() %>" target="_blank">
                                <%=item.Title.ToString().Length > 30 ? item.Title.ToString().Substring(0, 30) + "..." : item.Title.ToString()%></a></div>
                        <div class='xmas_price'>
                            <div class='left'>
                                市场价：<span class='money'><%=ASSystem.currency%></span><%=item.Market_price%>
                            </div>
                            <div class='right'>
                                所需积分：<%= item.teamscore%></div>
                        </div>
                        <div class='xmas_buy'>
                            <a class='center'>已结束</a></div>
                    </li>
                    <%}%>
                    <%}%>
                </ul>
                <div class="clear">
                    </div><div>
                        <ul class="paginator">
                        <li class="current">
                            <%=pageHtml%>
                        </li>
                    </ul>
                </div>
            </div>
        
        </div>
        <div>
        </div>
    </div>
</div>
</form>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>