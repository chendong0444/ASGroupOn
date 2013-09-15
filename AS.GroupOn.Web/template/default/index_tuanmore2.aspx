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
<script runat="server">
    protected bool over = false;
    protected NameValueCollection order = new NameValueCollection();
    protected NameValueCollection team = new NameValueCollection();
    protected int size = 0;
    protected int offset = 0;
    protected int imageindex = 1;
    protected int teamid = 0;
    new protected ITeam CurrentTeam = null;
    protected int twoline = 0;
    protected long curtimefix = 0;
    protected long difftimefix = 0;
    protected AS.Enum.TeamState state = AS.Enum.TeamState.none;
    protected string teamstatestring = String.Empty;//项目状态的英文soldout卖光,success成功,failure失败
    public string strtitle = "";
    protected DateTime overtime = DateTime.Now;  //团购结束时间
    public int sortorder = 0;
    protected bool buy = true;//允许购买
    protected int ordercount = 0;//成功购买当前项目的订单数量
    protected int detailcount = 0;//成功购买当前项目数量
    protected int buycount = 0;//当前项目购买数量
    protected string buyurl = String.Empty;//购买按钮链接
    public IList<ITeam> otherteams = null;
    public WebUtils wshelp = new WebUtils();
    public NameValueCollection _system = new NameValueCollection();
    public string cityid = "0";
    protected IList<ITeam> list_team = null;
    protected TeamFilter filter = new TeamFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (CurrentCity != null)
        {
            cityid = CurrentCity.Id.ToString();
        }
        _system = PageValue.CurrentSystemConfig;
        teamid = Helper.GetInt(Request["id"], 0);
        if (teamid > 0)
        {
            using (IDataSession session = Store.OpenSession(false))
            {
                CurrentTeam = session.Teams.GetByID(teamid);
            }
        }
        else
        {
            CurrentTeam = base.CurrentTeam;
        }
        if (CurrentTeam == null)
        {
            Response.End();
            return;
        }
        UpdateView();
    }
    public void UpdateView()
    {
        int top = 0;
        if (ASSystem != null)
        {
            top = Helper.GetInt(WebUtils.config["indexteam"], 10);
            if (top > 0)
            {
                filter.teamcata = 0;
                filter.ToBegin_time = DateTime.Now;
                filter.FromEndTime = DateTime.Now;
                filter.TypeIn = "'normal','draw','goods'";
                filter.Cityblockothers = Helper.GetInt(CurrentCity.Id, 0);
                filter.AddSortOrder(TeamFilter.Sort_Order_DESC);
                filter.AddSortOrder(TeamFilter.Begin_time_DESC);
                filter.AddSortOrder(TeamFilter.ID_DESC);
                filter.Top = top;
                filter.CurrentPage = 1;
                using (IDataSession session = Store.OpenSession(false))
                {
                    otherteams = session.Teams.GetList(filter);
                }
                if (otherteams.Count > 0)
                    Session["teamid"] = otherteams[0].Id;
                else
                    Session["teamid"] = "0";
            }
        }
    }
    public bool isover(ITeam model)
    {
        bool falg = false;
        state = GetState(model);
        if (state == AS.Enum.TeamState.fail || state == AS.Enum.TeamState.successtimeover || state == AS.Enum.TeamState.successnobuy)
        {
            falg = true;
            overtime = model.End_time;
        }
        return falg;
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    $(document).ready(function () {
        jQuery("div.deal-timeleft").each(function () {
            var numid = jQuery(this).attr("num");
            var SysSecond = parseInt(jQuery(this).attr('diff')) / 1000;
            var InterValObj = window.setInterval(SetRemainTime, 1000);
            function SetRemainTime() {
                if (SysSecond > 0) {
                    SysSecond = SysSecond - 1;
                    var second = Math.floor(SysSecond % 60);
                    var minite = Math.floor((SysSecond / 60) % 60);
                    var hour = Math.floor((SysSecond / 3600) % 24);
                    var day = Math.floor((SysSecond / 3600) / 24);
                    if (day > 0) {
                        $("#counter" + numid).html("<span>" + day + "</span>天<span>" + hour + "</span>时<span>" + minite + "</span>分<span>" + second + "</span>秒");
                    }
                    else {
                        $("#counter" + numid).html("<span>" + hour + "</span>时<span>" + minite + "</span>分<span>" + second + "</span>秒");
                    }

                } else {
                    window.clearInterval(InterValObj);
                }
            }
        });
    });
</script>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <%LoadUserControl(WebRoot + "UserControls/admid.ascx", null); %>
        <div id="deal-default">
            <div id="content">
                <!--循环开始-->
                <%int num = 0;%>
                <%if (otherteams != null && otherteams.Count > 0)
                  {%>
                <%foreach (ITeam model in otherteams)
                  {%>
                <%imageindex = 1; %>
                <!-- 循环分享信息 -->
                <div id="deal-share">
                    <div class="deal-share-top">
                        <div class="deal-share-links">
                            <h4>分享到：</h4>
                            <ul class="cf">
                                <li><a class="sina" href="<%=BaseUserControl.Share_sina(model,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                                    target="_blank">新浪微博</a></li>
                                <li><a class="qq" href="<%=BaseUserControl.Share_QQ(model,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                                    target="_blank">腾讯微博</a></li>
                                <li><a class="renren" href="<%=BaseUserControl.Share_renren( model,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                                    target="_blank">人人</a></li>
                                <li><a class="kaixin" href="<%=BaseUserControl.Share_kaixin( model,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                                    target="_blank">开心</a></li>
                                <li><a class="douban" href="<%=BaseUserControl.Share_douban( model,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                                    target="_blank">豆瓣</a></li>
                                <li><a class="im" href="javascript:void(0);" id="deal-share-im" onclick="$('#deal-share-im-c-<%=model.Id %>').toggle();">MSN/QQ</a></li>
                                <li><a class="email" href="<%=BaseUserControl.Share_mail( model,WWWprefix,ASUserArr["id"], ASSystemArr) %>"
                                    id="A3">邮件</a></li>
                            </ul>
                        </div>
                    </div>
                    <div class="deal-share-fix">
                    </div>
                    <div id="deal-share-im-c-<%=model.Id %>" style="display: none;" class="deal-share-im-c ">
                        <div class="deal-share-im-b">
                            <h3>复制下面的内容后通过 MSN 或 QQ 发送给好友：</h3>
                            <p>
                                <input id="share-copy-text-<%=model.Id %>" type="text" value="<%=WWWprefix.Substring(0, WWWprefix.LastIndexOf("/"))+getTeamPageUrl(model.Id)%>&r=<%=ASUserArr["id"] %>"
                                    size="40" class="f-input" tip="复制成功，请粘贴到你的MSN或QQ上推荐给您的好友" />
                                <input id="share-copy-button" type="button" value="复制" class="formbutton" onclick="X.misc.copyToCB('share-copy-text-<%=model.Id %>    ');" />
                            </p>
                        </div>
                    </div>
                </div>
                <!-- 循环分享信息结束 -->
                <div id="deal-intro" class="cf">
                    <div class="quan">
                        <div class="roll">
                            <%=num + 1 %>
                        </div>
                    </div>
                    <h1>
                        <a class="deal-today-link" href="<%=getTeamPageUrl(model.Id)  %>">
                            <%=TeamMethod.GetTeamtype(model)%>:</a><a class="deal-today-link-xx" href="<%=getTeamPageUrl(model.Id)  %>"><%=model.Title%></a></h1>
                    <div class="main">
                        <div class="deal-buy">
                            <div class="deal-price-tag">
                            </div>
                            <%if (GetState(model) == AS.Enum.TeamState.successnobuy)
                              { %>
                            <p class="deal-price">
                                <strong>
                                    <%=ASSystemArr["currency"]%><%=GetMoney(model.Team_price)%></strong><span class="deal-price-over"></span>
                            </p>
                            <%}
                              else if (isover(model))
                              { %>
                            <p class="deal-price">
                                <strong>
                                    <%=ASSystemArr["Currency"]%><%=GetMoney(model.Team_price)%></strong><span class="deal-price-end"></span>
                            </p>
                            <%}
                              else
                              { %>
                            <p class="deal-price">
                                <strong>
                                    <%=ASSystemArr["Currency"]%><%=GetMoney(model.Team_price)%></strong> <a href="<%=PageValue.WebRoot%>ajax/car.aspx?id=<%=model.Id %>"
                                        target="_blank"><span class="deal-price-buy"></span></a>
                                <%if (model.Delivery == "express")
                                  { %>
                                <a href="<%=PageValue.WebRoot%>ajax/car.aspx?id=<%=model.Id %>" target="_blank">
                                    <span class="deal-price-buy"></span></a>
                                <%}
                                  else if (model.Delivery == "coupon")
                                  {%>
                                <a href="<%=PageValue.WebRoot%>ajax/car.aspx?id=<%=model.Id%>" target="_blank">
                                    <span class="deal-price-buy"></span></a>
                                <%}
                                  else if (model.Delivery == "draw")
                                  {%>
                                <a href="<%=PageValue.WebRoot%>ajax/car.aspx?id=<%=model.Id%>" target="_blank">
                                    <span class="button-deal-cj"></span></a>
                                <% }%>
                                <% } %>
                        </div>
                        <table class="deal-discount">
                            <tr>
                                <th>原价
                                </th>
                                <th>折扣
                                </th>
                                <th>节省
                                </th>
                            </tr>
                            <tr>
                                <td>
                                    <%=ASSystemArr["Currency"]%><%=GetMoney(model.Market_price)%>
                                </td>
                                <td>
                                    <%=WebUtils.GetDiscount(Helper.GetDecimal(model.Market_price, 0), Helper.GetDecimal(model.Team_price, 0))%>
                                </td>
                                <td>
                                    <%=ASSystemArr["Currency"]%><%=GetMoney((Helper.GetDecimal(model.Market_price, 0) - Helper.GetDecimal(model.Team_price, 0)).ToString())%>
                                </td>
                            </tr>
                        </table>
                        <%if (isover(model))
                          { %>
                        <div class="deal-box deal-timeleft deal-off" id="deal-timeleft" curtime="<%=curtimefix %>"
                            diff="<%=difftimefix %>">
                            <div class="limitdate">
                                <p class="deal-buy-ended">
                                    <%=overtime.ToString("yyyy-MM-dd HH:mm:ss")%><br />
                                </p>
                            </div>
                        </div>
                        <%}
                          else
                          {
                              curtimefix = Helper.GetTimeFix(DateTime.Now) * 1000;
                              difftimefix = Helper.GetTimeFix(model.End_time) * 1000;
                              difftimefix = difftimefix - curtimefix;
           
                        %>
                        <div class="deal-box deal-timeleft deal-on" num="<%=num %>" id="deal-timeleft" curtime="<%=curtimefix %>"
                            diff="<%=difftimefix %>">
                            <h3></h3>
                            <div class="limitdate">
                                    <%if ((model.End_time - DateTime.Now).Days >= 3)
                                      { %>
                                    <ul><span style="font-size:20px;">3天以上</span></ul>
                                    <%}
                                      else
                                      { %>
                                 <ul id="counter<%=num %>">
                                    <span>
                                        <%=(model.End_time - DateTime.Now).Hours%></span>时<span>
                                            <%=(model.End_time - DateTime.Now).Minutes%></span>分<span>
                                                <%=(model.End_time - DateTime.Now).Seconds%></span>秒 </ul>
                                    <%} %>
                            </div>
                        </div>
                        <%} %>
                        <%if (!isover(model))
                          { %>
                        <%if (GetState(model) == AS.Enum.TeamState.begin)
                          {
                              if (model.Min_number > 0)
                              {
                                  size = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(190 * (Convert.ToDouble(model.Now_number) / Convert.ToDouble(model.Min_number)))));

                                  offset = Convert.ToInt32(Math.Ceiling(Convert.ToDouble(5 * (Convert.ToDouble(model.Now_number) / Convert.ToDouble(model.Min_number)))));
                              }%>
                        <div class="deal-box deal-status" id="deal-status">
                            <p class="deal-buy-tip-top">
                                <strong>
                                    <%=model.Now_number%></strong> 人已购买
                            </p>
                            <div class="progress-pointer" style="padding-left: <%=(size-offset)%>px;">
                                <span></span>
                            </div>
                            <div class="progress-bar">
                                <div class="progress-left" style="width: <%=(size-offset)%>px;">
                                </div>
                                <div class="progress-right ">
                                </div>
                            </div>
                            <div class="cf">
                                <div class="min">
                                    0
                                </div>
                                <div class="max">
                                    <%=model.Min_number%>
                                </div>
                            </div>
                            <%if (model.Max_number > 0)
                              { %>
                            <p class="deal-buy-tip-btm">
                                还差 <strong>
                                    <%= (model.Min_number - model.Now_number)%></strong> 人到达最低团购人数
                            </p>
                            <%} %>
                        </div>
                        <%}
                          else if (GetState(model) == AS.Enum.TeamState.successbuy)
                          { %>
                        <div class="deal-box deal-status deal-status-open" id="deal-status">
                            <p class="deal-buy-tip-top">
                                <strong>
                                    <%=model.Now_number%></strong> 人已购买
                            </p>
                            <%if (model.Max_number > 0 && model.Max_number > model.Now_number)
                              { %>
                            <p class="deal-buy-tip-btm">
                                本单仅剩：<strong><%=model.Max_number - model.Now_number%></strong>份，欲购从速
                            </p>
                            <%} %>
                            <%if (model.Now_number >= model.Min_number)
                              { %>
                            <p class="deal-buy-on" style="line-height: 200%;">
                                <img src="<%=ImagePath() %>deal-buy-succ.gif" />
                                团购成功
                                <% }%>
                                <%if ((model.Max_number == 0) || (model.Max_number - model.Now_number) > 0)
                                  { %>
                                可以继续购买<%} %>
                            </p>
                            <%if (model.Reach_time.HasValue)
                              { %>
                            <p class="deal-buy-tip-btm">
                                <%=model.Reach_time.Value.ToString("MM-dd HH:mm")%><br />
                                达到最低团购人数：<strong><%=model.Min_number%></strong>人
                            </p>
                            <%} %>
                        </div>
                        <%} %>
                        <%}
                          else
                          { %>
                        <div class="deal-box deal-status deal-status-<%=teamstatestring %>" id="deal-status">
                            <div class="deal-buy-<%=teamstatestring %>">
                            </div>
                            <p class="deal-buy-tip-total">
                                共有 <strong>
                                    <%=model.Now_number%></strong> 人购买
                            </p>
                        </div>
                        <%} %>
                    </div>
                    <div class="side">
                        <div class="deal-buy-cover-img" id="team_images" imglist="team_images">
                            <div id="zk">
                                <p>
                                    <span class="zk">
                                        <%=WebUtils.GetDiscount(Helper.GetDecimal(model.Market_price, 0), Helper.GetDecimal(model.Team_price, 0)).Replace("折", "")%></span>
                                </p>
                            </div>
                            <%if (model.Image1 != String.Empty || model.Image2 != String.Empty)
                              { %>
                            <div class="mid">
                                <ul>
                                    <li class="first"><a href="<%=getTeamPageUrl(model.Id)%>" target="_blank">
                                        <img <%=ashelper.getimgsrc(model.Image) %> class="dynload" /></a></li>
                                    <%if (model.Image1 != String.Empty)
                                      { %>
                                    <li><a href="<%=getTeamPageUrl(model.Id)%>" target="_blank">
                                        <img <%=ashelper.getimgsrc(model.Image1) %> class="dynload" /></a></li>
                                    <%} %>
                                    <%if (model.Image2 != String.Empty)
                                      { %>
                                    <li><a href="<%=getTeamPageUrl(model.Id)%>" target="_blank">
                                        <img <%=ashelper.getimgsrc(model.Image2) %> class="dynload" /></a></li>
                                    <%} %>
                                </ul>
                                <div id="img_list" img="img_list">
                                    <a ref="1" class="active">1</a>
                                    <%if (model.Image1 != String.Empty)
                                      { %><%imageindex = imageindex + 1;%>
                                    <a ref="<%=imageindex %>">
                                        <%=imageindex%></a>
                                    <%
                                      } %>
                                    <%if (model.Image2 != String.Empty)
                                      { %><%imageindex = imageindex + 1;%>
                                    <a ref="<%=imageindex %>">
                                        <%=imageindex%></a>
                                    <%} %>
                                </div>
                            </div>
                            <%}
                              else
                              { 
                            %>
                            <a href="<%=getTeamPageUrl(model.Id)  %>"
                                target="_blank">
                                <img <%=ashelper.getimgsrc(model.Image) %> class="dynload" width="440" height="280" /></a>
                            <%} %>
                        </div>
                        <div class="digest">
                            <br />
                            <%=model.Summary%>
                        </div>
                    </div>
                </div>
                <%num++;%>
                <%}%>
                <%}%>
                <!--循环结束-->
            </div>
            <div id="sidebar">
                <div class="sharespace">
                </div>
                <%LoadUserControl(WebRoot + "UserControls/adleft.ascx", null); %>
                <%LoadUserControl(WebRoot + "UserControls/blockSign.ascx", null); %>
                <%LoadUserControl(WebRoot + "UserControls/blockinvite.ascx", null); %>
                <%LoadUserControl(WebRoot + "UserControls/blockcomment.ascx", null); %>
                <%LoadUserControl(WebRoot + "UserControls/blockbulletin.ascx", null); %>
                <%LoadUserControl(WebRoot + "UserControls/blockflv.ascx", CurrentTeam); %>
                <%LoadUserControl(WebRoot + "UserControls/blockask.ascx", CurrentTeam); %>
                <%LoadUserControl(WebRoot + "UserControls/blockqq.ascx", CurrentTeam); %>
                <%
                    if (_system["newgao"] != null)
                    {
                        if (_system["newgao"] == "1")
                        { %>
                <%LoadUserControl(PageValue.WebRoot + "UserControls/uc_NewList.ascx", null); %>
                <% 
                        }
                    }%>
                <%LoadUserControl(WebRoot + "UserControls/blockvote.ascx", null); %>
                <%LoadUserControl(WebRoot + "UserControls/blockbusiness.ascx", null); %>
                <%LoadUserControl(WebRoot + "UserControls/blocksubscribe.ascx", null); %>
            </div>
        </div></div></div>
        <!-- bd end -->
    </div>
    <!-- bdw end -->
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>