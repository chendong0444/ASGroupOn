<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public IPagers<ITeam> teampager = null;
    public IList<ITeam> teamlis = null;
    public TeamFilter teamft = new TeamFilter();
    public string pagerhtml = string.Empty;
    public int page = 0;
    public int blag = 1;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "搜索";
        PageValue.WapBodyID = "search";
        string del = Request["del"];
        NameValueCollection _systemView = new NameValueCollection();
        if (Request["w"] != "" && Request["w"] != null)
        {
            _systemView = WebUtils.GetSystem();
            string words = Helper.GetString(Request["w"], String.Empty);
            string str = _systemView["searchs"];
            if (str != null && !str.Contains(words) && words != "")
            {
                _systemView.Add("searchs", words);
                WebUtils.CreateSystemByNameCollection1(_systemView);

                for (int i = 0; i < _systemView.Count; i++)
                {
                    string strKey = _systemView.Keys[i];
                    string strValue = _systemView[strKey];
                    FileUtils.SetConfig(strKey, strValue);
                }
            }
            page = Helper.GetInt(Request["page"], 1);
            teamft.TitleLike = words;
            teamft.teamcata = 0;
            teamft.ToBegin_time = DateTime.Now;
            teamft.FromEndTime = DateTime.Now;
            teamft.TypeIn = "'normal','draw'";
            teamft.Cityblockothers = Helper.GetInt(CurrentCity.Id, 0);
            teamft.CurrentPage = page;
            teamft.PageSize = 20;
            teamft.AddSortOrder(TeamFilter.MoreSort);
            using (IDataSession seion = Store.OpenSession(false))
            {
                teampager = seion.Teams.GetPager(teamft);
            }
            teamlis = teampager.Objects;
            if (teamlis != null && teamlis.Count > 0)
            {
                blag = 2;
                pagerhtml = WebUtils.GetMBPagerHtml(20, teampager.TotalRecords, teampager.CurrentPage, GetUrl("手机版搜索", "search.aspx?page={0}&w=" + words));
            }
            else
            {
                pagerhtml = "<div class=\"isEmpty\">抱歉，没有找到与“" + words + "”相关的团购</div>";
                blag = 3;
                teamft.TitleLike = string.Empty;
                teamft.Top = 9;
                using (IDataSession seion = Store.OpenSession(false))
                {
                    teamlis = seion.Teams.GetList(teamft);
                }
            }

        }
        else
        {
            blag = 1;
        }
        if (del == "yes")
        {
            _systemView.Add("searchs", "0");
            WebUtils.CreateSystemByNameCollection1(_systemView);

            for (int i = 0; i < _systemView.Count; i++)
            {
                string strKey = _systemView.Keys[i];
                string strValue = _systemView[strKey];
                FileUtils.SetConfig(strKey, strValue);
            }
        }
    } 
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div class="body">
    <section id="search-box">
        <form id="search-form" action="<%=GetUrl("手机版搜索","search.aspx") %>" method="get">
            <input id="keyword" name="w" value="" type="search" x-webkit-speech placeholder="请输入商品名称、地址等" />
            <input type="submit" value="搜索" />
        </form>
    </section>
    <%if (blag == 1)
      {
    %>

    <%    NameValueCollection value = new NameValueCollection();
          value = WebUtils.GetSystem();
          string[] searchs = null;
          if (value["searchs"] != "" && value["searchs"] != null && value["searchs"] != "0")
          {
              searchs = value["searchs"].Split(',');
          }
          if (searchs != null)
          {%>
    <section id="search-history">
        <div id="Div1">
            <h3>搜索历史</h3>
            <ul>
                <% for (int i = 0; i < searchs.Length; i++)
                   {
                       if (searchs[i] != "" && searchs[i] != "0")
                       {%>
                <li>
                    <a href="<%=GetUrl("手机版搜索","search.aspx?w="+searchs[i]) %>"><%=searchs[i] %></a>
                </li>

                <%}
        }%>
            </ul>
            <p id="clear-history">
                <span><a href="<%=GetUrl("手机版搜索","search.aspx?del=yes") %>">清除历史记录</a></span>
            </p>

        </div>
    </section>
    <%}%>
    <% } %>

    <%if (blag == 2)
      {%>
    <div id="deals">
        <div>
            <%if (teamlis != null && teamlis.Count > 0)
              {
                  foreach (ITeam item in teamlis)
                  {
            %>
            <a href="<%=GetMobilePageUrl(item.Id) %>">
                <img width="122" height="74" alt="<%=item.Product %>" src="<%=PageValue.CurrentSystem.domain+WebRoot %><%=item.PhoneImg==null?String.Empty:item.PhoneImg%>">
                <detail>
<ul>
<li class="brand"><%=item.Product %></li>
                        <li class="title indent"><%=item.Title %></li>
 <li class="price"><strong><%=GetMoney(item.Team_price)%></strong>元<del><%=GetMoney(item.Market_price)%>元</del><span><%=item.Now_number%>人</span></li>
</ul>
</detail>
            </a>
            <%}
              } %>
        </div>
    </div>
    <section id="nav-page"><%=pagerhtml %></section>
    <% } %>
    <%else if (blag == 3)
      { %>
    <section id="nav-page"><%=pagerhtml %></section>
    <div class="recommend">
        <h4>为您推荐今日新单：</h4>
        <div>
            <%if (teamlis != null && teamlis.Count > 0)
              {
                  foreach (ITeam item in teamlis)
                  {
            %>
            <a href="<%=GetMobilePageUrl(item.Id) %>"><span class="mark new"><i></i>新单 </span>
                <img width="122" height="74" alt="<%=item.Product %>" src="<%=PageValue.CurrentSystem.domain+WebRoot %><%=item.PhoneImg==null?String.Empty:item.PhoneImg%>">
                <detail>
<ul>
<li class="brand"><%=item.Product %></li>
                        <li class="title indent"><%=item.Title %></li>
 <li class="price"><strong><%=GetMoney(item.Team_price)%></strong>元<del><%=GetMoney(item.Market_price)%>元</del><span><%=item.Now_number%>人</span></li>
</ul>
</detail>
            </a>
            <%}
              } %>
        </div>
    </div>
    <%} %>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>