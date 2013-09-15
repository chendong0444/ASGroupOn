<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    public NameValueCollection _system = new NameValueCollection();
    protected SystemFilter systemft = new SystemFilter();
    protected ISystem systemmodel = null;
    public ITeam m_team = null;
    public string strTeamTitle = "";
    public string strTeamID = "";
    string where = "1=1 and t1.state!=2 ";
    int page = 1;
    protected string pagerhtml = String.Empty;
    public string state = "al";
    IList<Hashtable> listhash = null;
    IList<Hashtable> listhash2 = null;
    protected override void OnLoad(EventArgs e)
    {
        Ordertype = "buy";
        base.OnLoad(e);
        page = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        NeedLogin();
        IUser user = null;
        //string s = AS.Common.Utils.CookieUtils.GetCookieValue("username", AS.Common.Utils.FileUtils.GetKey()); 
        int uid = Convert.ToInt32(AS.Common.Utils.CookieUtils.GetCookieValue("userid", AS.Common.Utils.FileUtils.GetKey()));
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            //usermodel = session.Users.GetByName(userft);
            user = session.Users.GetByID(uid);
        }       
        if (user!=null)
        {
            where += " and username='" + user.Username + "' ";
        }
        else
        {
            
        }
        
        setBuyTitle();

    }

    /// <summary>
    /// 买家评论内容
    /// </summary>
    public void setBuyTitle()
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            systemmodel = session.System.GetByID(1);
        }
        _system = AS.Common.Utils.WebUtils.GetSystem();
        string selector = "usId,t1.state,team.Id,username,Title,Image,comment,t1.create_time,t1.totalamount";
        string tablename = "(select userreview.Id as usId,userreview.state , user_id,team_id,username,userreview.create_time,comment,totalamount  from userreview left join [User] on  userreview.user_id=[User].Id)t1 left join team on t1.team_id=team.Id";
        int pageer2=0;
        int pageer = 0;
        string sqlstr = "";
        if (page!= 0)
        {
             pageer =15 * (page - 1) +1 ;
             pageer2 = pageer + 14;
             sqlstr = " WHERE ass BETWEEN " + pageer + " AND " + pageer2;
        }
        string sql = "SELECT * FROM (select " + selector + ",ROW_NUMBER() OVER ( order by  usId desc )  AS ass " + " from " + tablename + " where " + where + " ) as a ";
        if (sqlstr!="")
        {
            sql = sql + sqlstr;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {            
            listhash = session.GetData.GetDataList("select " + selector + " from "+tablename + " where " + where + " order by  usId desc");
            listhash2 = session.GetData.GetDataList(sql);
        }
        
        //SELECT * FROM (SELECT *,ROW_NUMBER() OVER (ORDER BY id desc ) AS ass	FROM [Team]) as a 	WHERE ass BETWEEN 1 AND 30;
        System.Data.DataTable dtable = AS.Common.Utils.Helper.ConvertDataTable(listhash2.ToList());
        pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(15, listhash.Count, page, GetUrl("产品未评论分页用", "buy_send_listcomments.aspx?page={0}"));
        StringBuilder sb1 = new StringBuilder();
        if (dtable.Rows.Count > 0)
        {
            if (systemmodel != null)
            {
                DateTime dt = System.DateTime.Now;
                for (int i = 0; i < dtable.Rows.Count; i++)
                {
                    //提取时间
                    System.Data.DataRow dr = dtable.Rows[i];
                    DateTime dt1 = Convert.ToDateTime(dr["create_time"].ToString());
                    sb1.Append("<div class='comments'>");
                    sb1.Append("<div class='deal_pic'>");
                    if (dr["Id"].ToString() != "")
                    {
                        sb1.Append("<a href='" + getTeamPageUrl(int.Parse(dr["Id"].ToString())) + "' target='_blank'>");
                        sb1.Append("<img src='" + AS.Common.Utils.ImageHelper.getSmallImgUrl(dr["Image"].ToString()) + "' width='110' height='70'  border='0'/>");
                        sb1.Append("</a>");
                        sb1.Append("</div>");
                        sb1.Append(" <div class='comment_content'>");
                        sb1.Append("<div class='pltitle'>");
                        sb1.Append(" <div class='desc'>" + AS.GroupOn.Controls.Utilys.GetUserLevel(AS.Common.Utils.Helper.GetDecimal(dr["totalamount"], 0)) + ":" + dr["username"].ToString() + " 评论了TA在" + systemmodel.abbreviation + "买到的&nbsp;<a href='" + getTeamPageUrl(int.Parse(dr["Id"].ToString())) + "' target='_blank'>" + dr["Title"].ToString() + "</a></div>");
                        sb1.Append("<div class='time'>");
                        if (_system["UserreviewYN"] != null && _system["UserreviewYN"] == "1")
                        {
                            if (Convert.ToInt32(dr["state"].ToString()) == 1)
                            {
                                sb1.Append("已处理&nbsp;");
                            }
                            else
                            {
                                sb1.Append("未处理&nbsp;");
                            }
                        }
                        else
                        {
                            sb1.Append("已处理&nbsp;");
                        }
                        if (dt1 != null)
                        {
                            sb1.Append(AS.Common.Utils.Helper.GetDateTime(dt, dt1));
                        }
                        else
                        {
                            sb1.Append("&nbsp;");
                        }
                        sb1.Append("</div>");
                        sb1.Append("<div class='clear'></div>");
                        sb1.Append("</div>");
                        sb1.Append("<p class='pingjia'>" + dr["comment"].ToString() + "</p>");
                    }
                    sb1.Append("</div>");

                    sb1.Append("</div>");
                }
            }
        }
        else
        {
            sb1.Append("<div class='comments'>");
            sb1.Append("暂无评论。您可以在" + systemmodel.abbreviation + "下方的'我的订单'里面给已经发货的订单评价哦");
            sb1.Append("</div>");
        }

        Literal1.Text = sb1.ToString();
        
              
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
<body>    
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
                                <br />
                                <strong>我如何才能发表到货评论?</strong>
                                <br />
                                <p>
                                    只有当您成功购买过此商品后，才能对此商品发表您的到货评论。</p>
                                <br />
                                <strong>我发表了评论，什么时候能返利呢？</strong>
                                <br />
                                <p>
                                    如果您发表了评论，请等待管理员的审核通过，通过后会将返利直接冲入您的账户。</p>
                            </div>
                        </div>
                        <div class="sect">
                            <!--买家评论循环开始-->
                            <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                            <!--买家评论循环结束-->
                            <div>
                                <ul class="paginator" style="margin-bottom: 20px; *margin-bottom: 4px;">
                                    <li class="current">
                                        <%= pagerhtml %>
                                    </li>
                                </ul>
                            </div>
                        </div>
                        <!--翻页列表部分 -->
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- bd end -->
    <!-- bdw end -->

</body>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>
