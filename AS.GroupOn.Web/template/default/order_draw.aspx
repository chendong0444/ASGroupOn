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
    public bool result = false;//是否过期
    public bool comResult = false;//没有开启返利
    public bool sumResult = true;//是否全部评论
    public string strpage;
    public string pagenum = "1";
    public int teamId = 0;
    public string pay = "";
    ICard cardmodel = null;
    IUser usermodel = null;
    ITeam teamodel = null;
    IPagers<IDraw> pager = null;
    IList<IDraw> drawlist = null;
    protected NameValueCollection _system = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Ordertype = "draw";
        _system = PageValue.CurrentSystemConfig;// 得到系统配置表信息

        comResult = comResultValue();
        #region 判断用户失效！
        NeedLogin();
        #endregion


        if (Request["pgnum"] != null)
        {
            if (AS.Common.Utils.NumberUtils.IsNum(Request["pgnum"].ToString()))
            {
                pagenum = Request["pgnum"].ToString();
            }
            else
            {
                SetError("您输入的参数非法");
            }
        }

        GetDraw();
    }


    public bool comResultValue()
    {
        bool result1 = false;
        if (_system["navUserreview"] != null && _system["navUserreview"] == "1")
        {
            result1 = true;
        }
        return result1;
    }

    #region 获取邀请人的姓名
    public string Getname(int userid)
    {
        string str = "";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            usermodel = session.Users.GetByID(userid);
        }
        if (usermodel != null)
        {
            str = usermodel.Username;
        }
        return str;
    }
    #endregion

    #region 根据项目编号，查询项目内容
    public string GetTeam(string id)
    {
        sumResult = true;

        //int userid = userbll.Getuserid(UserName);
        string str = "";

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teamodel = session.Teams.GetByID(Helper.GetInt(id, 0));
        }
        if (teamodel != null)
        {
            teamId = teamodel.Id;

            str = "<a class='deal-title' href='" + getTeamPageUrl(teamodel.Id) + "' target='_blank' >" + teamodel.Title + "</a>";
        }

        return str;
    }
    #endregion



    #region 显示用户下面的抽奖号码
    public void GetDraw()
    {

        DrawFilter drawfil = new DrawFilter();
        drawfil.userid = AsUser.Id;
        drawfil.PageSize = 30;
        drawfil.CurrentPage = Helper.GetInt(pagenum, 1);
        drawfil.AddSortOrder(DrawFilter.TeamID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Draw.GetSumPager(drawfil);
        }
        drawlist = pager.Objects;

        if (drawlist.Count == 0)
        {
            strpage = "对不起，没有相关数据";
        }
        else
        {
            if (pager.TotalRecords >= 30)
            {
                strpage = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, Convert.ToInt32(pagenum), GetUrl("我的抽奖", "order_draw.aspx?pgnum={0}"));
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
                <div id="coupons">
                    <div class="menu_tab" id="dashboard">
                        <%LoadUserControl("_MyWebside.ascx", Ordertype); %>
                    </div>
                    <div id="tabsContent" class="coupons-box">

                        <div class="box-content1 tab">
                            <div class="head">
                                <h2>我的抽奖</h2>
                                <div class="clear"></div>
                                <div class="header_info">
                                    <br>
                                    <strong>如何生成抽奖号？</strong>
                                    <br>
                                    <p>当团购网站发起抽奖项目时，您成功购买后，即可生成一个属于您的抽奖号码。</p>
                                    <br>
                                    <strong>如何获得多个抽奖号码？</strong>
                                    <br>
                                    <p>当您邀请您的朋友注册并成功购买后，您就能生成一个新的抽奖号码，邀请的人越多，您的抽奖号码越多。</p>
                                    <br>
                                    <strong>如何知道我中奖了？</strong>
                                    <br>
                                    <p>当您点击“详情”，如果某个号码显示“中奖”状态，那么恭喜您，你已经中奖了。更多的中奖信息，请随时关注网站的公告。</p>
                                </div>
                                <ul class="filter">
                                </ul>
                            </div>
                            <div class="sect">
                                <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                    <tr>
                                        <th width="500">项目名称
                                        </th>
                                        <th width="80">抽奖个数
                                        </th>
                                        <th width="40">操作
                                        </th>
                                    </tr>
                                    <%int i = 0; %>
                                    <%foreach (IDraw drw in drawlist)
                                      {
                                            
                                    %>
                                    <tr <%if (i % 2 != 0)
                                          {%> class='alt' <%} %>>
                                        <td>
                                            <%= GetTeam(drawlist[i].teamid.ToString())%>
                                        </td>
                                        <td style="text-align: left;">
                                            <%= drawlist[i].sum%>
                                        </td>
                                        <td>
                                            <a href="<%=GetUrl("我的抽奖详情","order_drawlist.aspx?teamid="+drawlist[i].teamid) %>">详情</a>
                                        </td>
                                    </tr>
                                    <% 
                                          i++;
                                          }%>
                                    <tr>
                                        <td colspan="7">
                                            <%=strpage%>
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
        <!-- bdw end -->

    </div>
</form>
<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %> 

