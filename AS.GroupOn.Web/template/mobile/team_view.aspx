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
    protected ITeam teammodel = null;
    protected int teamid = 0;
    protected bool over = false;
    protected AS.Enum.TeamState state = AS.Enum.TeamState.none;
    protected DateTime overtime = DateTime.Now;  //团购结束时间
    protected long difftimefix = 0;
    protected long curtimefix = 0;
    protected IPartner part = Store.CreatePartner();
    protected NameValueCollection partner = new NameValueCollection();
    protected System.Collections.Generic.IList<IBranch> branches = null;
    protected NameValueCollection team = new NameValueCollection();
    private string fonts = string.Empty;
    protected bool canLoadMap = false;//加载地图
    protected string mapInfo = String.Empty;//地图信息
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.WapBodyID = "deal-detail";
        PageValue.Title = "团购详情";
        teamid = Helper.GetInt(Request["id"], 0);
        using (IDataSession session = Store.OpenSession(false))
        {
            teammodel = session.Teams.GetByID(teamid);
        }
        if (teammodel != null)
        {
            if (teammodel.bulletin.Replace("{", "").Replace("}", "").Replace("[", "").Replace("]", "").Replace("|", "/") != "")
            {
                fonts = teammodel.bulletin.Replace("{", "").Replace("}", "").Replace("[", "").Replace("]", "").Replace("|", "/");
                string ends = fonts.Substring(fonts.Length - 1, 1);
                if (ends == ",")
                {
                    fonts = fonts.Substring(0, fonts.Length - 1);
                }
            }
            using (IDataSession seion = Store.OpenSession(false))
            {
                part = seion.Partners.GetByID(teammodel.Partner_id);
            }
            if (teammodel != null && teammodel.Delivery == "coupon")
            {
                canLoadMap = true;
            }
            if (part != null)
            {
                partner = Helper.GetObjectProtery(part);
            }
            if (teammodel != null)
            {
                BasePage bp = new BasePage();
                state = bp.GetState(teammodel);
                if (state == AS.Enum.TeamState.fail || state == AS.Enum.TeamState.successtimeover)
                {
                    over = true;
                    overtime = teammodel.End_time;
                }

                if (state == AS.Enum.TeamState.successnobuy)
                {
                    over = true;
                    if (teammodel.Close_time.HasValue)
                        overtime = teammodel.Close_time.Value;
                    else
                        overtime = teammodel.End_time;
                }
                if (teammodel.Begin_time > DateTime.Now)//未开始项目
                {
                    curtimefix = Helper.GetTimeFix(DateTime.Now) * 1000;
                    difftimefix = Helper.GetTimeFix(teammodel.Begin_time) * 1000;
                }
                else
                {
                    curtimefix = Helper.GetTimeFix(DateTime.Now) * 1000;
                    difftimefix = Helper.GetTimeFix(teammodel.End_time) * 1000;

                }
                difftimefix = difftimefix - curtimefix;
            }
            team = Helper.GetObjectProtery(teammodel);
        }
        else
        {
            SetError("友情提示：项目不存在！");
            Response.Redirect(GetUrl("手机版首页", "index.aspx"));
            Response.End();
            return;
        }
    } 
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<div id="deal">
    <div id="dealIntro">
        <h1>
            <%=teammodel.Title %></h1>
        <img alt="<%=teammodel.Product %>" width="138" height="84" src="<%=PageValue.CurrentSystem.domain+WebRoot %><%=teammodel.PhoneImg==null?String.Empty:teammodel.PhoneImg%>" />
        <detail>
            <ul>
             <li class="price"><label><%=ASSystemArr["currency"] %></label><%=GetMoney(teammodel.Team_price) %></li>
            <%if (over)
              { %>
                 <li class="remain"> <%= overtime.ToString("yyyy年MM月dd日hh点MM分")%></li>
            <%}
              else
              { %>
            <%if (teammodel.Begin_time <= DateTime.Now)
              {%>
             <%if ((teammodel.End_time - DateTime.Now).Days >= 3)
               { %>
                    <li class="remain">剩余3天以上</li>
                    <%}
               else
               { %>
              <li class="remain">剩余<%=(teammodel.Begin_time - DateTime.Now).Hours%>小时 <%=(teammodel.Begin_time - DateTime.Now).Minutes%>分<%=(teammodel.Begin_time - DateTime.Now).Seconds%>秒</li>
                    <%} %>

            <%}
              else
              {%>
             <%if ((teammodel.Begin_time - DateTime.Now).Days > 0)
               { %>
                     <li class="remain">剩余3天以上</li>
                    <%}
               else
               { %>
              <li class="remain">剩余<%=(teammodel.Begin_time - DateTime.Now).Hours%>小时 <%=(teammodel.Begin_time - DateTime.Now).Minutes%>分<%=(teammodel.Begin_time - DateTime.Now).Seconds%>秒</li>
                    <%} %>

            <%} %>
            <%} %>
             <%if (teammodel.Conduser == "Y")
               {%>
               <li class="count"><strong><%=teammodel.Now_number %></strong>人已购买</li>
             <%}
               else
               { %>
               <li class="count">已购买<strong><%=teammodel.Now_number %></strong>件</li>
              <%} %>
            </ul>
        </detail>
        <%if (teammodel.Delivery == "coupon" && teammodel.isrefund == "Y")
          {%>
        <p class="protect">
            <span class="yes">支持7天退款</span><span class="yes">支持过期退款</span>
        </p>
        <%}
          else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "S")
          { %>
        <p class="protect">
            <span class="no">支持7天退款</span><span class="yes">支持过期退款</span>
        </p>
        <%}
          else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "G")
          { %>
        <p class="protect">
            <span class="no">支持7天退款</span><span class="yes">支持过期退款</span>
        </p>
        <%}
          else if (teammodel.Delivery == "coupon" && teammodel.isrefund == "N")
          { %>
        <p class="protect">
            <span class="no">不支持7天退款</span><span class="no">不支持过期退款</span>
        </p>
        <%}
          else if (teammodel.Delivery == "coupon")
          { %>
        <p class="protect">
            <span class="no">不支持7天退款</span><span class="no">不支持过期退款</span>
        </p>
        <%} %>
    </div>
    <div style="margin: 0 8px;">
        <p class="c-submit">
            <%if (teammodel.Begin_time <= DateTime.Now && DateTime.Now < teammodel.End_time)
              {
                  if (teammodel.Max_number != 0 && teammodel.Now_number > teammodel.Max_number)
                  {%>
            <a href="#">超出最大购买量</a>
            <%}
                  else
                  {%>
            <% if (teammodel.Delivery == "draw")
               {%>
            <a href="<%=GetUrl("手机版订单购买", "team_buy.aspx") %><%=teammodel.Id %>">立即参与</a>
            <%}
               else
               {%>
            <a href="<%=GetUrl("手机版订单购买", "team_buy.aspx") %><%=teammodel.Id %>">立即购买</a>
            <% }%>

            <%}
              }
              else
              {%>
            <a href="#">该项目已结束</a>
            <%} %>
        </p>
    </div>
     <%if (!String.IsNullOrEmpty(team["notice"]))
          { %>
    <div id="deal-terms" class="deal-box">
        <h1 class="tag current" id="tb_1">购买须知</h1>
        <div class="tab-box" id="tbc_01">
            <%=team["notice"]%>
        </div>
    </div>
   <%} %>
    <div id="deal-details" class="deal-box">
        <h1 class="tag" id="tb_2">本单详情</h1>
        <div class="tab-box" id="tbc_02">
            <table class="standard-table">
                <thead>
                    <th width="41%">内容
                    </th>
                    <th width="18%">单价
                    </th>
                    <th width="23%">数量/规格
                    </th>
                    <th width="18%">小计
                    </th>
                </thead>
                <tbody>
                    <tr class="normal">
                        <td>
                            <%=teammodel.Title%>
                        </td>
                        <td class="center">
                            <%=ASSystemArr["Currency"]%><%=GetMoney(team["Market_price"])%>
                        </td>
                        <td class="center">1
                        </td>
                        <td class="right">
                            <%=ASSystemArr["Currency"]%><%=GetMoney(team["Market_price"])%>
                        </td>
                    </tr>
                    <tr class="comment">
                        <%if (fonts != "")
                          {%>
                        <td colspan="4" class="center">
                            <%=fonts %>
                        </td>
                        <%} %>
                    </tr>
                </tbody>
                <tfoot>
                    <tr>
                        <td></td>
                        <td></td>
                        <td>价值
                        </td>
                        <td class="right">
                            <%=ASSystemArr["Currency"] %><%=GetMoney(team["Market_price"])%>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td></td>
                        <td>
                            <%=PageValue.CurrentSystem.sitename%>价
                        </td>
                        <td class="right">
                            <%= team["Team_price"] %>
                        </td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>
     <%if (part != null)
      {%>
    <div id="deal-bizinfo" class="deal-box">
        <h1 class="tag" id="tb_3">商家信息</h1>
        <div class="tab-box" id="tbc_03">
           
            <ul>
                <li>
                    <%if (partner["Address"] != null && partner["Address"].ToString() != "")
                      { %>
                    <%=partner["Address"]%>
                    <%if (canLoadMap)
                      {%>
                    <a  ask="查看地图，可能会消耗较多流量。是否继续访问？" href='<%=WebRoot %>wap/deal/addressinfo/<%=teamid %>'>查看地图</a>
                    <%}
                      } %>
                    <%if (partner["Phone"] != null && partner["Phone"].ToString() != "")
                      { %>
                    <a  class="phone" href="tel:<%=partner["Phone"]%>">☎
                        <%=partner["Phone"]%></a>
                    <%} %>
                    <%if (partner["Mobile"] != null && partner["Mobile"].ToString() != "")
                      { %>
                    <a  class="phone" href="tel:<%=partner["Mobile"]%>">☎<%=partner["Mobile"]%></a>
                    <%} %>
                    <%if (partner["location"] != null && partner["location"].ToString() != "")
                      { %>
                    <p>
                        <%=partner["location"]%>
                    </p>
                    <%} %>
                </li>
                <!--分站信息开始-->
                <% if (partner["id"] != null)
                   {
                       BranchFilter branchf = new BranchFilter();
                       branchf.partnerid = Helper.GetInt(partner["id"], 0);

                       using (IDataSession seion = AS.GroupOn.App.Store.OpenSession(false))
                       {
                           branches = seion.Branch.GetList(branchf);
                       }
        
                %>
                <%
                       int loopid = 1;
                       if (branches != null && branches.Count > 0)
                       {
                %>
                <li style="list-style-type: none;">
                    <h1 class="tag" id="tb_4">分站信息</h1>
                    <div class="tab-box" id="tbc_04">
                        <%foreach (IBranch row in branches)
                          { %>
                        <div>
                            <%if (row.address.ToString() != "")
                              { %>
                            <%=row.address%>
                            <%}
                              if (row.phone != null && row.phone.ToString() != "")
                              { %>
                            <a  class="phone" href="tel:<%=row.phone%>">☎
                                <%=row.phone%></a>
                            <%} %>
                            <%if (row.mobile != null && row.mobile.ToString() != "")
                              { %>
                            <a  class="phone" href="tel:<%=row.mobile%>">☎
                                <%=row.mobile%></a>
                            <%} %>
                            <%loopid++;%>
                        </div>
                        <% }%>
                    </div>
                </li>
                <% }
                   } %>
                <!--分站信息结束-->
            </ul>
          
        </div>
    </div>
    <%}%>
    <div class="deal-box">
        <h1 id="deal-more" data-href="<%=GetUrl("手机版项目详情更多", "team_details.aspx") %><%=teamid %>">查看更多详情</h1>
    </div>
    <div style="margin: 0 8px;">
        <p class="c-submit">
            <%if (teammodel.Begin_time <= DateTime.Now && DateTime.Now < teammodel.End_time)
              {
                  if (teammodel.Max_number != 0 && teammodel.Now_number > teammodel.Max_number)
                  {%>
            <a href="#">超出最大购买量</a>
            <%}
                  else
                  {%>
            <% if (teammodel.Delivery == "draw")
               {%>
            <a href="<%=GetUrl("手机版订单购买", "team_buy.aspx")%><%=teammodel.Id %>">立即参与</a>
            <%}
               else
               {%>
            <a href="<%=GetUrl("手机版订单购买", "team_buy.aspx")%><%=teammodel.Id %>">立即购买</a>
            <% }%>
            <%}
              }
              else
              {%>
            <a href="#">该项目已结束</a>
            <%} %>
        </p>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<script type="text/javascript">
    $(document).ready(function () {
        MT.touch.tipsForLink('#deal-more', '团购详情图片较多，可能会消耗较多流量。是否继续访问？');
        MT.touch.toggleByLink();
    });
    $(document).ready(function () {
        $("#tb_1").click(function () {
            $("#tb_1").attr("class", "tag current");
            $("#tb_2").attr("class", "tag");
            $("#tb_3").attr("class", "tag");
            $("#tb_4").attr("class", "tag");
            $("#tbc_01").show();
            $("#tbc_02").hide();
            $("#tbc_03").hide();
            $("#tbc_04").hide();
        });
        $("#tb_2").click(function () {
            $("#tb_1").attr("class", "tag");
            $("#tb_2").attr("class", "tag current");
            $("#tb_3").attr("class", "tag");
            $("#tb_4").attr("class", "tag");
            $("#tbc_01").hide();
            $("#tbc_02").show();
            $("#tbc_03").hide();
            $("#tbc_04").hide();
        });
        $("#tb_3").click(function () {
            $("#tb_1").attr("class", "tag");
            $("#tb_2").attr("class", "tag");
            $("#tb_3").attr("class", "tag current");
            $("#tb_4").attr("class", "tag");
            $("#tbc_01").hide();
            $("#tbc_02").hide();
            $("#tbc_03").show();
            $("#tbc_04").hide();
        });
        $("#tb_4").click(function () {
            $("#tb_1").attr("class", "tag");
            $("#tb_2").attr("class", "tag");
            $("#tb_3").attr("class", "tag current");
            $("#tb_4").attr("class", "tag current");
            $("#tbc_01").hide();
            $("#tbc_02").hide();
            $("#tbc_03").show();
            $("#tbc_04").show();
        });
        $("#tbc_01").show();
        $("#tbc_02").hide();
        $("#tbc_03").hide();
        $("#tbc_04").hide();
    });
</script>
<%LoadUserControl("_htmlfooter.ascx", null); %>