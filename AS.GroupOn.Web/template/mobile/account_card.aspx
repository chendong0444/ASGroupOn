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
    protected IPagers<ICard> pager = null;
    protected IList<ICard> list_card = null;
    protected StringBuilder strhtml = new StringBuilder();
    protected string pagerhtml = string.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "我的代金券";
        MobileNeedLogin();
        InitData();
    }
    //获取【我的代金劵】数据
    private void InitData()
    {
        CardFilter cardfil = new CardFilter();
        cardfil.isGet = 1;
        cardfil.user_id = AsUser.Id;
        cardfil.PageSize = 15;
        cardfil.CurrentPage = AS.Common.Utils.Helper.GetInt(Request["page"], 1);
        cardfil.AddSortOrder(CardFilter.Begin_time_Desc);
        
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Card.GetMobilCard(cardfil);
        }
        list_card = pager.Objects;
        if (pager != null && pager.TotalRecords > 0)
        {
            for (int i = 0; i < list_card.Count; i++)
            {
                if (list_card[i].Team != null)  //过滤项目是否是商城项目
                {
                    if (list_card[i].Team.teamcata == 0)
                    {
                        strhtml.Append("<div class='card-list'>");
                        strhtml.Append("<div class='card'>");
                        strhtml.Append("<strong class='value'>" + list_card[i].Credit.ToString() + "</strong>");
                        strhtml.Append("<ul>");
                        strhtml.Append("<li class='code'>" + list_card[i].Id.ToString() + "</li>");
                        strhtml.Append("<li class='endtime'>有效期至" + list_card[i].End_time.ToString() + "</li>");
                        strhtml.Append("<li class='limit'>只适用于项目：<a href='" + GetMobilePageUrl(list_card[i].Team_id) + "'>" + list_card[i].Team.Product + "</a></li>");
                        strhtml.Append("</ul>");
                        if (list_card[i].consume.ToString() == "Y")
                        {
                            strhtml.Append("<span class='status available'>已消费</span>");
                        }
                        else if (list_card[i].consume.ToString() == "N" && Convert.ToDateTime(list_card[i].End_time) < DateTime.Now)
                        {
                            strhtml.Append("<span class='status available'>已过期</span>");
                        }
                        else if (list_card[i].consume.ToString() == "N" && Convert.ToDateTime(list_card[i].End_time) >= DateTime.Now)
                        {
                            strhtml.Append("<span class='status available'>未消费</span>");
                        }
                        strhtml.Append("</div>");
                        strhtml.Append("</div>");
                    }
                }
                else if (int.Parse(list_card[i].Team_id.ToString()) == 0 && int.Parse(list_card[i].Partner_id.ToString()) != 0)
                {
                    strhtml.Append("<div class='card-list'>");
                    strhtml.Append("<div class='card'>");
                    strhtml.Append("<strong class='value'>" + list_card[i].Credit.ToString() + "</strong>");
                    strhtml.Append("<ul>");
                    strhtml.Append("<li class='code'>" + list_card[i].Id.ToString() + "</li>");
                    strhtml.Append("<li class='endtime'>有效期至" + list_card[i].End_time.ToString() + "</li>");
                    //strhtml.Append("<li class='limit'>只适用于此商户下的项目：<a href='" + GetUrl("手机版个人中心代金卷查看商户项目", "account_card_product.aspx") + int.Parse(list_card[i].Partner_id.ToString()) + "'>查看</a></li>");
                    strhtml.Append("<li class='limit'>只适用于此商户下的项目：<a href='" + GetUrl("手机版个人中心代金卷查看商户项目", "account_card_product.aspx?id=" + int.Parse(list_card[i].Partner_id.ToString())) + "'>查看</a></li>");
                    
                    strhtml.Append("</ul>");
                    if (list_card[i].consume.ToString() == "Y")
                    {
                        strhtml.Append("<span class='status available'>已消费</span>");
                    }
                    else if (list_card[i].consume.ToString() == "N" && Convert.ToDateTime(list_card[i].End_time) < DateTime.Now)
                    {
                        strhtml.Append("<span class='status available'>已过期</span>");
                    }
                    else if (list_card[i].consume.ToString() == "N" && Convert.ToDateTime(list_card[i].End_time) >= DateTime.Now)
                    {
                        strhtml.Append("<span class='status available'>未消费</span>");
                    }
                    strhtml.Append("</div>");
                    strhtml.Append("</div>");
                }
                else
                {
                    strhtml.Append("<div class='card-list'>");
                    strhtml.Append("<div class='card'>");
                    strhtml.Append("<strong class='value'>" + list_card[i].Credit.ToString() + "</strong>");
                    strhtml.Append("<ul>");
                    strhtml.Append("<li class='code'>" + list_card[i].Id.ToString() + "</li>");
                    strhtml.Append("<li class='endtime'>有效期至" + list_card[i].End_time.ToString() + "</li>");
                    strhtml.Append("<li class='limit'>无使用限制</li>");
                    strhtml.Append("</ul>");
                    if (list_card[i].consume.ToString() == "Y")
                    {
                        strhtml.Append("<span class='status available'>已消费</span>");
                    }
                    else if (list_card[i].consume.ToString() == "N" && Convert.ToDateTime(list_card[i].End_time) < DateTime.Now)
                    {
                        strhtml.Append("<span class='status available'>已过期</span>");
                    }
                    else if (list_card[i].consume.ToString() == "N" && Convert.ToDateTime(list_card[i].End_time) >= DateTime.Now)
                    {
                        strhtml.Append("<span class='status available'>未消费</span>");
                    }
                    strhtml.Append("</div>");
                    strhtml.Append("</div>");
                }
            }
            pagerhtml = WebUtils.GetMBPagerHtml(15, pager.TotalRecords, pager.CurrentPage, GetUrl("手机版个人中心代金卷", "account_card.aspx?page={0}"));
        }
        else
        {
            strhtml.Append("<p class='empty'>您还没有代金券呢，<a href='" + GetUrl("手机版用户代金卷帮助", "help_card.aspx") + "'>如何获取?</a></p>");
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<body id='account' >
    <header>
            <div class="left-box">
                <a class="go-back" href="javascript:history.back()"><span>返回</span></a>
            </div>
        <h1>我的代金券</h1>
    </header>
<div class="body">
    <%=strhtml %>
    <nav class="pageinator">
        <div id="nav-page">
            <%=pagerhtml %>
        </div>
        <div id="nav-top">
            <span class="nav-button" onclick="javascript:void(window.scrollTo(0, 0));"><span>回到顶部</span></span>
        </div>
    </nav>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
