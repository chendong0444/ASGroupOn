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
    IPagers<IDraw> pager = null;
    DrawFilter drawfil = new DrawFilter();
    protected IList<IDraw> dlist = null;
    IUser usermodel = null;
    ITeam teamodel = null;
    
    public string strpage;
    public string pagenum = "1";
    public int teamId = 0;
    public string pay = "";
    protected NameValueCollection _system = new NameValueCollection();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        Ordertype = "draw";

        if (Request["pgnum"] != null)
        {
            if (NumberUtils.IsNum(Request["pgnum"].ToString()))
            {
                pagenum = Request["pgnum"].ToString();
            }
            else
            {
                SetError("您输入的参数非法");
            }
        }

        if (Request["teamid"] != null)
        {
            Drawlist(Helper.GetInt(Request["teamid"], 0));//显示抽奖号码
        }

    }

    #region 根据项目编号和用户名查询抽奖号码
    public void Drawlist(int teamid)
    {
        string sql = " teamid=" + teamid + " and (userid=" + AsUser.Id + ")";
        int count;
       // dlist = drawbll.Searchdraw(30, Utils.Helper.GetInt(pagenum, 0), "*", "createtime desc", sql, out count);
        drawfil.teamid = teamid;
        drawfil.userid = AsUser.Id;
        drawfil.PageSize = 30;
        drawfil.AddSortOrder(DrawFilter.CREATETIME_DESC);
        drawfil.CurrentPage = Helper.GetInt(pagenum, 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Draw.GetPager(drawfil);

        }
         dlist=pager.Objects;
         count = pager.TotalRecords;
         if (count == 0)
        {
            strpage = "对不起，没有相关数据";
        }
        else
        {

            if (count >= 30)
            {
                strpage = AS.Common.Utils.WebUtils.GetPagerHtml(30, count, Convert.ToInt32(pagenum), GetUrl("我的抽奖详情", "order_drawlist.aspx?teamid=" + Helper.GetInt(Request["teamid"], 0) + "&pgnum={0}"));
            }
        }
    }
    #endregion


    #region 获取邀请人的姓名
    public string Getname(int userid)
    {
        string str = "";

        using (IDataSession session=AS.GroupOn.App.Store.OpenSession(false))
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
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            usermodel = session.Users.GetbyUName(UserName);
        }
        int userid = 0;
        if (usermodel!=null)
        {
            userid = usermodel.Id;
        }
        string str = "";

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teamodel = session.Teams.GetByID(Convert.ToInt32(id));
        }
        if (teamodel != null)
        {
            teamId = teamodel.Id;

            str = "<a class='deal-title' href='" +getTeamPageUrl(teamodel.Id) + "' target='_blank' >" + teamodel.Title + "</a>";


            if (comResult && !result)
            {

                UserReviewFilter userreviewfile = new UserReviewFilter();
                IList<IUserReview> userreviewlist = null;
                userreviewfile.team_id = teamodel.Id;
                userreviewfile.user_id = userid;  
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    userreviewlist = session.UserReview.GetList(userreviewfile);
                }
                if (userreviewlist[0].id > 0)
                {
                    str += "<p style='color:red;'>已评论</p>";
                }
                else
                {
                    sumResult = false;
                    str += "<p style='color:red;'>未评论</p>";
                }

            }


        }

        return str;
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
                    <div id="tabsContent" class="coupons-box ">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        我的抽奖</h2>
                                        <div class="clear"></div>
<div class="header_info">
<br><strong>如何生成抽奖号？</strong>
<br>
<p> 当团购网站发起抽奖项目时，您成功购买后，即可生成一个属于您的抽奖号码。</p>
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
                                            <th width="400">
                                                项目名称
                                            </th>
                                            <th width="80">
                                                抽奖号码
                                            </th>
                                            <th width="80">
                                                被邀请人
                                            </th>
                                            <th width="40">
                                                状态
                                            </th>
                                        </tr>
                                        <%int i = 0; %>
                                        <%foreach (IDraw model in dlist)
                                          {
                                            
                                        %>
                                        <tr <%if(i%2!=0){%> class='alt' <%} %>>
                                            <td>
                                                <%= GetTeam(model.teamid.ToString())%>
                                            </td>
                                            <td style="text-align: left;">
                                                <%= model.number%>
                                            </td>
                                            <td>
                                                <%= Getname(model.inviteid)%>
                                            </td>
                                            <td>
                                                <%if (model.state == "Y")
                                                  { %>
                                                中奖
                                                <% }
                                                  else
                                                  {%>
                                                未中奖
                                                <% }%>
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
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
   </form>

<%LoadUserControl("_htmlfooter.ascx", null); %>
<%LoadUserControl("_footer.ascx", null); %>   