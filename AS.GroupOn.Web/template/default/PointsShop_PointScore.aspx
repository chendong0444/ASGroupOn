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
    
    protected string dengji;
    protected string dazhe;
    protected string jifen;
    protected decimal xiaofeijin;
    protected string ming;
    protected ISystem systemmodel = null;
    protected IList<IUserlevelrules> dt = null;
    protected IPagers<IScorelog> pager = null;
    protected IList<IScorelog> iListScorelog = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Ordertype = "jifen";

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            systemmodel = session.System.GetByID(1);
        }

        NeedLogin();
        if (systemmodel != null)
        {
            ming = systemmodel.abbreviation;
        }
        xiaofeijin = getMoney();
        getContent(xiaofeijin);
        getJilu();//积分记录

    }
    /// <summary>
    /// 通过用户的金额获取用户的所有内容
    /// </summary>
    /// <param name="money"></param>
    public void getContent(decimal money)
    {
        StringBuilder sb1 = new StringBuilder();
        //获取等级
        dengji =Utilys.GetUserLevel(money);
        //获取打折率
        if (ActionHelper.GetUserLevelMoney(money) < 1)
        {
            dazhe = ActionHelper.GetUserLevelMoney(money) * 10 + "折";
        }
        else
        {
            dazhe = "不打折";
        }
        //获取列表

        UserlevelrulesFilters usleverulefilter = new UserlevelrulesFilters();
        usleverulefilter.minmoney = money;
        usleverulefilter.AddSortOrder(UserlevelrulesFilters.MINMONEY_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            dt = session.Userlevelrelus.GetdataByMinmoney(usleverulefilter);
        }
    }
    
    /// <summary>
    /// 获取用户的金额
    /// </summary>
    /// <returns></returns>
    public decimal getMoney()
    {
        decimal money = 0;
        //string name = "";
        //判断用户是否存在
        if (CookieUtils.GetCookieValue("username", AS.Common.Utils.FileUtils.GetKey()).Length > 0)
        {
            //获取当前用户名
            //name = CookieUtils.GetCookieValue("username",AS.Common.Utils.FileUtils.GetKey());
            int uid = Convert.ToInt32(CookieUtils.GetCookieValue("userid", AS.Common.Utils.FileUtils.GetKey()));
            //name = "looming";
            //获取用户的消费金额
            UserFilter userfilter = new UserFilter();
            //userfilter.LoginName = name;
            userfilter.ID = uid;
            IUser iuser = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                iuser = session.Users.Get(userfilter);
            }
            if (iuser != null)
            {
                money = iuser.totalamount;
                jifen = iuser.userscore.ToString();
            }
        }
        return money;
    }

    private void getJilu()
    {   
        //标题
        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<th width='200'>生成时间</th>");
        sb1.Append("<th width='150'>订单ID</th>");
        sb1.Append("<th width='100'>动作</th>");
        sb1.Append("<th width='100'>收支</th>");
        sb1.Append("<th width='160'>积分值</th>");
        Literal1.Text = sb1.ToString();
        //内容
        StringBuilder sb2 = new StringBuilder();

        url = url + "&page={0}";
        url = GetUrl("我的积分", "pointsshop_pointscore.aspx?" + url.Substring(1));
        ScorelogFilter filter = new ScorelogFilter();
        filter.PageSize = 30;
        filter.AddSortOrder(ScorelogFilter.Create_time_DESC);
        filter.CurrentPage =Helper.GetInt(Request.QueryString["page"], 1);
        filter.User_id = AsUser.Id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Scorelog.GetPager(filter);
        }
        iListScorelog = pager.Objects;
        if (iListScorelog.Count > 0)
        {
            int i = 0;
            foreach(IScorelog iscorelogInfo in iListScorelog)
            {
                if (i % 2 != 0)
                {
                    sb2.Append("<tr>");
                }
                else
                {
                    sb2.Append("<tr class='alt'>");
                }
                i++;
                sb2.Append("<td width='200'>" + iscorelogInfo.create_time.ToString("yyyy/MM/dd HH:mm:ss") + "</td>");
                sb2.Append("<td width='150'>" + iscorelogInfo.key + "</td>");
                sb2.Append("<td width='160'>" + iscorelogInfo.action + "</td>");
                int score = Helper.GetInt(iscorelogInfo.score, 0);

                if (iscorelogInfo.action == "下单")
                {
                    sb2.Append("<td width='160'>收入</td>");
                }
                else if (iscorelogInfo.action == "退单")
                {
                    sb2.Append("<td width='160'>支出</td>");
                }
                else if (iscorelogInfo.action == "积分兑换")
                {
                    sb2.Append("<td width='160'>支出</td>");
                }
                else if (iscorelogInfo.action == "取消兑换")
                {
                    sb2.Append("<td width='160'>收入</td>");
                }
                else if (iscorelogInfo.action == "签到")
                {
                    sb2.Append("<td width='160'>收入</td>");
                }
                else if (iscorelogInfo.action == "用户充值")
                {
                    sb2.Append("<td width='160'>收入</td>");
                }
                else
                {
                    sb2.Append("<td width='160'>其他</td>");
                }
                if (score < 0)
                {
                    sb2.Append("<td width='160'>" + -score + "</td>");
                }
                else
                {
                    sb2.Append("<td width='160'>" + score + "</td>");
                }
                sb2.Append("</tr>");
            }
        }
        Literal2.Text = sb2.ToString();
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }
</script>

<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="credit">
            <div class="menu_tab" id="dashboard">
                <%LoadUserControl("_MyWebside.ascx", Ordertype); %>
            </div>
            <div id="tabsContent" class="coupons-box">
                <div class="box-content1 tab">
                    <div class="head">
                        <h2>
                            我的积分</h2>
                          <%LoadUserControl(WebRoot + "UserControls/blockpointScore.ascx", null); %>
                    </div>
                    <div class="sect">
                        <p class="charge">
                            <%if (!String.IsNullOrEmpty(dengji))
                              { %>
                            您当前的会员等级：<%=dengji%>，购买<%=ming%>全部商品<span><%=dazhe%></span><br />
                            <%} %>
                            <h3 class="credit-title">
                                您的当前积分为： <strong>
                                    <%=jifen %></strong></h3>
                            <%  if (dt != null)
                                {
                                    foreach (IUserlevelrules iuleInfo in dt)
                                    {
                                        //如果消费下线大于用户钱数则显示等级。
                                        if (iuleInfo.minmoney > xiaofeijin)
                                        {%>
                            <div class="huiyuan">
                                <p>
                                    <span>想升级成<%=iuleInfo.Category.Name %>吗？</span></p>
                                <p>
                                    您已消费<span><%=xiaofeijin %>元</span>，只需继续在<%=ming%>再消费满<%=iuleInfo.minmoney -xiaofeijin%>元，即可拥有<%=iuleInfo.Category.Name%>全场购买商品<span><%=(iuleInfo.discount *10).ToString("f1") %>折</span>资格。</p>
                            </div>
                            <%}
                                }
                            } %>
                        </p>
                        <table id="order-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                            <asp:literal id="Literal1" runat="server"></asp:literal>
                            <asp:literal id="Literal2" runat="server"></asp:literal>
                            <tr>
                                <td colspan="5">
                                    <ul class="paginator">
                                        <li class="current">
                                            <%=pagerHtml%>
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
    <!-- bd end -->
</div>
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %>  