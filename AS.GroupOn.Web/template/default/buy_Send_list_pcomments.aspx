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
    public string state = "al";
    public int id = 0;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected IPagers<IUserReview> pager = null;
    protected IList<IUserReview> iListUserReview = null;
    
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
        GetPartner();
    }

    public void GetPartner()
    {
        _system = WebUtils.GetSystem();
        StringBuilder stBContent = new StringBuilder();

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

        string wherestr = "[type]='partner' and state!=2 and partner_id > 0 and user_id =" + userid;
        if (id > 0)
        {
            wherestr += " and partner_id =" + id;
        }

        url = url + "&page={0}";
        url = "Send_list_pcomments.aspx?" + url.Substring(1);
        UserReviewFilter userreviewfilter = new UserReviewFilter();
        userreviewfilter.wheresql = wherestr;
        userreviewfilter.PageSize = 30;
        userreviewfilter.AddSortOrder(UserReviewFilter.Create_Time_DESC);
        userreviewfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.UserReview.GetPager(userreviewfilter);
        }
        iListUserReview = pager.Objects;

        if (iListUserReview != null)
        {
            if (iListUserReview.Count > 0)
            {
                DateTime dt = System.DateTime.Now;
                foreach (IUserReview userreviewInfo in iListUserReview)
                {
                    DateTime dt1 = userreviewInfo.create_time;
                    if (userreviewInfo.partner != null)
                    {
                        stBContent.Append("<div class='comments'>");
                        stBContent.Append("<div class='deal_pic'>");
                        stBContent.Append("<a href='" + getPartnerPageUrl(Helper.GetString(_system["isrewrite"], "0"), int.Parse(userreviewInfo.partner_id.ToString())) + "' target='_blank'>");
                        stBContent.Append("<img src='" + ImageHelper.getSmallImgUrl(userreviewInfo.partner.Image) + "' width='110' height='70'  border='0'/>");
                        stBContent.Append("</a>");
                        stBContent.Append("</div>");
                        stBContent.Append("<div class='comment_content'>");
                        stBContent.Append("<div class='pltitle'>");
                        //stBContent.Append(" <div class='desc'>" + Utils.Utility.GetUserLevel(Utils.Helper.GetDecimal(dr["totalamount"], 0)) + ":" + dr["username"].ToString() + " 评论了TA在" + systemmodel.abbreviation + "买到的&nbsp;<a href='" + getTeamPageUrl(Utils.Helper.GetString(_system["isrewrite"], "0"), int.Parse(dr["Id"].ToString())) + "' target='_blank'>" + dr["Title"].ToString() + "</a></div>");
                        stBContent.Append("<div class='desc'><a href='" + getPartnerPageUrl(Helper.GetString(_system["isrewrite"], "0"), int.Parse(userreviewInfo.partner_id.ToString())) + "' target='_blank'>" + userreviewInfo.partner.Title + "</a>");
                        if (userreviewInfo.team != null)
                        {
                            stBContent.Append("</br><a href='" + getTeamPageUrl(userreviewInfo.team_id) + "' target='_blank'>" + userreviewInfo.team.Title + "</a>");
                        }
                        stBContent.Append("</div>");
                        stBContent.Append("<div class='time'>");
                        if (_system["doUserreviewPartner"] != null && _system["doUserreviewPartner"] == "0")
                        {
                            if (userreviewInfo.state == 1)
                            {
                                stBContent.Append("已处理&nbsp;");
                            }
                            else
                            {
                                stBContent.Append("未处理&nbsp;");
                            }
                        }
                        else
                        {
                            stBContent.Append("已处理&nbsp;");
                        }
                        if (dt1 != null)
                        {
                            stBContent.Append(returnTime(dt, dt1));
                        }
                        else
                        {
                            stBContent.Append("&nbsp;");
                        }
                        stBContent.Append("</div>");
                        stBContent.Append("<div class='clear'></div>");
                        stBContent.Append("</div>");
                        stBContent.Append("<p class='pingjia'>" + userreviewInfo.comment + "</p>");
                        stBContent.Append("</div>");

                        stBContent.Append("</div>");
                    }
                }
            }
            else
            {
                stBContent.Append("<div class='comments'>");
                stBContent.Append("暂无评论");
                stBContent.Append("</div>");
            }
            Literal1.Text = stBContent.ToString();

            pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);

        }
    }

    /// <summary>
    /// 返回指定时间之差
    /// </summary>
    /// <param name="DateTime1">当前时间</param>
    /// <param name="DateTime2">之前时间</param>
    /// <returns></returns>
    public string returnTime(DateTime DateTime1, DateTime DateTime2)
    {
        string dateDiff = null;

        TimeSpan ts1 = new TimeSpan(DateTime1.Ticks);
        TimeSpan ts2 = new TimeSpan(DateTime2.Ticks);
        TimeSpan ts = ts1.Subtract(ts2).Duration();
        if (ts.Days > 0)
        {
            dateDiff += ts.Days.ToString() + "天";
        }
        if (ts.Hours > 0)
        {
            dateDiff += ts.Hours.ToString() + "小时";
        }
        if (ts.Minutes > 0)
        {
            dateDiff += ts.Minutes.ToString() + "分钟";
        }
        return dateDiff;

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
                            </li>
                        </ul>
                        <div class="header_info">
                            <br>
                            <strong>我如何才能发表商户评论?</strong>
                            <br>
                            <p>
                                只有当您成功购买过此商户下的项目，才能对此商户发表您的评论。</p>
                        </div>
                    </div>
                    <div class="content_body">
                        <asp:literal id="Literal1" runat="server"></asp:literal>
                        <div>
                            <ul class="paginator" style="margin-bottom: 20px; *margin-bottom: 4px;">
                                <li class="current">
                                    <%= pagerHtml %>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %>  