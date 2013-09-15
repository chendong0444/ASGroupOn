<%@ Control Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.BaseUserControl" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">

    public NameValueCollection _system = null;
    protected string abbreviation = String.Empty;
    protected string footlogo = String.Empty;
    protected IList<IFriendLink> piclinks = null;
    protected FriendLinkFilter picfilter = new FriendLinkFilter();
    protected IList<IFriendLink> textlinks = null;
    protected FriendLinkFilter textfilter = new FriendLinkFilter();
    protected string sitename = String.Empty;
    protected string icp = String.Empty;
    protected string statcode = String.Empty;
    protected bool closeLocation = false;
    protected void closeLocationResult()
    {
        if (_system != null && _system["closeLocation"] == "1")
        {
            closeLocation = true;
        }
        else
        {
            closeLocation = false;
        }
    }
    public override void UpdateView()
    {

        _system = WebUtils.GetSystem();
        if (ASSystem != null)
        {
            abbreviation = ASSystem.abbreviation;
            if (PageValue.CurrentSystemConfig["mallfootlogo"] != null && PageValue.CurrentSystemConfig["mallfootlogo"].ToString() != "")
            {
                footlogo = _system["mallfootlogo"];
            }
            else
            {
                footlogo = ASSystem.footlogo;
            }
            sitename = ASSystem.sitename;
            icp = ASSystem.icp;
            statcode = ASSystem.statcode;
            closeLocationResult();

        }
        if (closeLocation)
        {
            picfilter.Logo = true;
            textfilter.Logo = false;
            using (IDataSession session = Store.OpenSession(false))
            {
                piclinks = session.FriendLink.GetList(picfilter);
                textlinks = session.FriendLink.GetList(textfilter);
            }

        }
    }
</script>

<div class="clear"></div>
<div id="ftw">
    <div class="g_footer c"></div>
    <div id="ft">
        <p class="contact">
            <a href="<%=GetUrl("意见反馈","feedback_suggest.aspx")%>">意见反馈</a>
        </p>
        <ul class="cf">
            <li class="col">
                <h3></h3>
                <ul class="sub-list">
                    <li><a href="<%=GetUrl("玩转东购团","help_tour.aspx")%>">玩转<%=abbreviation%></a></li>
                    <li><a href="<%=GetUrl("常见问题","help_faqs.aspx")%>">常见问题</a></li>
                    <li><a href="<%=GetUrl("东购团概念","help_asdht.aspx")%>"><%=abbreviation%>概念</a></li>
                    <li><a href="<%=GetUrl("开发API","help_api.aspx")%>">开发API</a></li>
                </ul>
            </li>
            <li class="col">
                <h3></h3>
                <ul class="sub-list">
                    <%if (CurrentCity != null)
                      { %>
                    <li><a href="<%=GetUrl("邮件订阅","help_Email_Subscribe.aspx?cityid="+CurrentCity.Id)%>">邮件订阅</a></li>
                    <li><a href="<%=GetUrl("RSS订阅","help_RSS_feed.aspx?ename="+CurrentCity.Ename)%>">RSS订阅</a></li>
                    <%} %>
                    <%else
                      { %>
                    <li><a href="<%=GetUrl("邮件订阅","help_Email_Subscribe.aspx?cityid=0")%>">邮件订阅</a></li>
                    <li><a href="<%=GetUrl("RSS订阅","help_RSS_feed.aspx")%>">RSS订阅</a></li>
                    <%} %>
                    <%if (ASSystem.sinablog != "")
                      {%>
                    <li><a href="<%=ASSystem.sinablog %>" target="_blank">新浪微博</a></li>
                    <%} %>
                    <%if (ASSystem.qqblog != "")
                      {%>
                    <li><a href="<%=ASSystem.qqblog %>" target="_blank">腾讯微博</a></li>
                    <%} %>
                </ul>
            </li>
            <li class="col">
                <h3></h3>
                <ul class="sub-list">
                    <li><a href="<%=GetUrl("商务合作","feedback_seller.aspx")%>">商务合作</a></li>
                    <li><a href="<%=GetUrl("友情链接","help_link.aspx")%>">友情链接</a></li>
                    <li><a href="<%=GetUrl("后台管理","Login.aspx")%>">后台管理</a></li>
                </ul>
            </li>
            <li class="col">
                <h3></h3>
                <ul class="sub-list">
                    <li><a href="<%=GetUrl("关于东购团","about_us.aspx")%>">关于<%=abbreviation %></a></li>
                    <li><a href="<%=GetUrl("工作机会","about_job.aspx")%>">工作机会</a></li>
                    <li><a href="<%=GetUrl("联系方式","about_contact.aspx")%>">联系方式</a></li>
                    <li><a href="<%=GetUrl("用户协议","about_terms.aspx")%>">用户协议</a></li>
                </ul>
            </li>
            <li class="col end">
                <div class="logo-footer">
                    <%if (Request.Url.ToString().ToLower().IndexOf("/mall/") > 0)
                      {
                    %>
                    <a href="<%=WebRoot%>mall/index.aspx">

                        <%if (_system != null && _system["mallfootlogo"] != null && _system["mallfootlogo"].ToString() != "")
                          {
                        %>
                        <img src="<%=_system["mallfootlogo"].ToString() %>" />
                        <%  
                     }
                          else
                          {
                        %>
                        <img src="/upfile/img/mall_logo.png" />
                        <%
                     } %>
                    </a>
                    <%
                  }
                      else
                      { 
                    %>
                    <a href="<%=WebRoot%>index.aspx">
                        <img src="<%=footlogo %>" /></a>
                    <%
                  } %>
                </div>
            </li>
        </ul>

        <div class="copyright">
            <%if (closeLocation)
              { %>
            <div>
                <strong>友情链接</strong>
            </div>
            <p style="margin: 5px 0px; color: rgb(51, 51, 51); font-weight: bold;">
                <%
              int i = 0;
              if (piclinks != null && piclinks.Count > 0)
              {
                  foreach (IFriendLink link in piclinks)
                  {
                      i++;
                      if (i <= 29)
                      { %>
                <a target="_blank" href="<%=link.url %>">
                    <img width="88" height="31" alt="<%=link.Title %>" src="<%=link.Logo %>"></a>
                <%}
                          else
                          { %>
                <a target="_blank" href="<%=GetUrl("友情链接","help_link.aspx")%>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;查看更多&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a>
                <%
                              break;
                          }
                %>
                <%} %>
                <%} %>
            </p>
            <p style="margin: 5px 0px; color: rgb(51, 51, 51);">
                <marquee height="22" onmouseover="this.stop()" onmouseout="this.start();" width="960"
                    direction="up" scrolldelay="60" scrollamount="1">
                      <%if (textlinks != null && textlinks.Count > 0)
                        {%>
                            <% foreach (IFriendLink link in textlinks)
                               { %>
<a target="_blank" href="<%=link.url %>"><%=link.Title %></a>
 <%} %>
                        <%} %>

</marquee>
                <%} %>
            </p>
            <p>
                &copy;<span>2013</span>&nbsp;<%=sitename %>（<%=WWWprefix %>）版权所有&nbsp;<a href="<%=GetUrl("用户协议","about_terms.aspx")%>">使用<%=abbreviation %>前必读</a>&nbsp;<a
                    href="http://www.miibeian.gov.cn/" target="_blank"><%=icp %></a>&nbsp;&nbsp;<%=statcode %>
            </p>
            <p>
                &nbsp;Powered by 正大商城(沪ICP备13015182号</a>)
                  
            </p>
        </div>

    </div>
</div>
<input type="hidden" name="buttontype" id="buttontype" value="" />
<!--返回顶部开始-->

<div id="go_lstop" class="uptop"><a onclick="window.scrollTo(0,0);">
    <img src="<%=ImagePath() %>backtotop.gif"></a></div>
<%if (!Request.Url.AbsoluteUri.Contains("/biz/") && !Request.Url.AbsoluteUri.Contains("/sale/") && !Request.Url.AbsoluteUri.Contains("/branch/"))
  { %>
<script type="text/javascript">
    $(function () {
        $("#go_lstop").hide();
        show_goback('index2');
    });
</script>
<%} %>
<!--返回顶部结束-->


<!--[if IE 6]>
<script src="<%=WebRoot%>upfile/js/pngie6.js" type="text/javascript" ></script>
<script type="text/javascript">
    DD_belatedPNG.fix('img,#zk,#logo,.goinput,.goimg,.list1_goods,#partner-comment-btn,#partner-btn,.list1_new,.sjIcon,.list1_cj,.list_new,.list_goods,.list_cj,.pic .normal_on,.pic .normal_off,#recent-deals .pic .isopen,.pzcart,#deal-intro .deal-price-tag,#ft .logo-footer,.deal-price-buy,.cart,.sjIcon,.none-back-money,.deal-price-end,.back-money,.none-over-times,.over-times,.normal_wait,#partner-btn,.goods_on,.isopen,.seconds_off,.seconds_on,.deal-price-over,.roll,.deal-price-notstart,.button-deal-cj,.deal-price-tag,#deal-intro .deal-price-creditmiaosha,.team-more-tag-new,.lg_logo,.lg_logo img,fieldset, img'); 
</script>
<![endif]-->
