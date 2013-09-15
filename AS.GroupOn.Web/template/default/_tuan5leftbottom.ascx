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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    public IList<ICatalogs> hostlist = null;//主推的类别
    public int currentcityid = 0;
    public IList<ICatalogs> catachildlist = null;
    protected AS.Enum.TeamState state = AS.Enum.TeamState.none;
    protected DateTime overtime = DateTime.Now;  //预订结束时间
    protected IList<ITeam> otherteams = null;
    public NameValueCollection _system = new NameValueCollection();
    protected IList<ITeam> teamlist = null;
    public string cataids = String.Empty;
    public override void UpdateView()
    {
        _system = WebUtils.GetSystem();
        if (CurrentCity != null)
        {
            currentcityid = CurrentCity.Id;
        }
        hostlist = TeamMethod.GethostCata(0, currentcityid);
        UpdateView(CurrentTeam.Id);
    }
    public override string CacheKey
    {
        get
        {
            int cityid = 0;
            if (CurrentCity != null)
                cityid = CurrentCity.Id;
            return "cacheusercontrol-tuan5leftbottom-" + cityid;
        }
    }
    public override bool CanCache
    {
        get
        {
            return true;
        }
    }
    /// <summary>
    /// 根据分类编号，显示分类下面的信息
    /// </summary>
    /// <param name="top"></param>
    /// <param name="catamodel"></param>
    public IList<ITeam> GetBycata(int top, ICatalogs catamodel)
    {
        IList<ITeam> teamlist = null;
        if (catamodel != null)
        {
            if (catamodel.ids != null && catamodel.ids.ToString() != "")
            {
                teamlist =TeamMethod.GetTopTeam(currentcityid, top, catamodel.ids.TrimEnd(','), CurrentTeam.Id.ToString());

            }
            else
            {
                teamlist = TeamMethod.GetTopTeam(currentcityid, top, catamodel.id.ToString(), CurrentTeam.Id.ToString());
            }
        }
        return teamlist;
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
    public void UpdateView(int teamid)
    {
        int top = 0;
        if (ASSystem != null)
        {
            top = Helper.GetInt(WebUtils.config["indexteam"], 10);
            if (top > 0)
            {
                string wherestr = " 1=1  ";
                if (CurrentCity != null)
                {
                    wherestr = wherestr + " and (City_id=" + CurrentCity.Id + " or level_cityid=" + CurrentCity.Id + "  or city_id=0 or ','+othercity+',' like '%," + CurrentCity.Id + ",%')";
                }
                else
                {
                    wherestr = wherestr + "  and City_id>=0 ";
                }
                wherestr = wherestr + " and teamcata=0 and (Team_type='normal' or Team_type='draw' or Team_type='goods') and teamhost=0  and Team.id<>" + teamid + " and Begin_time<='" + DateTime.Now.ToString() + "' and end_time>='" + DateTime.Now.ToString() + "' and (catalogs.catahost=1 or team.cataid=0) ";
                string sql = "select top " + top + " Team.* from team left join catalogs on(team.cataid=catalogs.id) where " + wherestr + "  order by  team.sort_order desc,Begin_time desc,team.id desc";
                using (IDataSession session = Store.OpenSession(false))
                {
                    otherteams = session.Teams.GetList(sql);
                }
            }
        }
    }
    public static bool isShop(ITeam model)
    {
        bool falg = false;
        NameValueCollection configs = WebUtils.GetSystem();
        if (configs["closeshopcar"] == "0")//开启购物车车标志
        {
            if (model.Delivery == "express")//是否是快递
                falg = true;
        }
        return falg;
    }
</script>
<!--循环一日多团4-开始-->
<%if (hostlist != null && hostlist.Count > 0)
  {%>
<%foreach (ICatalogs model in hostlist)
  { %>
<div id="deal-default">
    <div class="tuan_morexq">
        <div class="tuanmore_boxxq">
            <div class="box_tag1">
                <h2>
                    <a href="<%=getTeamDetailPageUrl(model.id, 0, 0, 0) %>">
                        <%=model.catalogname %></a></h2>
                <div class="in_hot1">
                    <% catachildlist = TeamMethod.GetCataall(12, model.id, currentcityid); %>
                    <%if (catachildlist != null && catachildlist.Count > 0)
                      { %>
                    <%foreach (ICatalogs childmodel in catachildlist)
                      { %>
                    <a href="<%=getTeamDetailPageUrl(childmodel.id, 0, 0, 0) %>">
                        <%=childmodel.catalogname %><span>(<%=TeamMethod.GetSum(childmodel.id, currentcityid,0)%>)</span></a>
                    <% }
                      } %>
                </div>
            </div>
            <div class="tuan_jpq">
                <!--分类下的项目显示-->
                <%IList<ITeam> teamlist = null; %>
                <%teamlist = GetBycata(model.keytop, model); %>
                <% int itype = 0; %>
                <%if (teamlist != null && teamlist.Count > 0)
                  {%>
                <%foreach (ITeam teammodel in teamlist)
                  {
                      itype++;
                %>
                <%if (itype % 3 == 0)
                  {%>
                <div class="tuanmore1_listxq" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                    <%}
                  else
                  { %>
                    <div class="tuanmore1_listxq" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                        <%} %>
                        <div class="lists1_img img_fl">
                            <a href="<%=getTeamPageUrl(teammodel.Id)  %>"
                                target="_blank" class="image_link">
                                <img <%=ashelper.getimgsrc(teammodel.Image) %> width="294" height="207" class="dynload"
                                    alt="<%=teammodel.Title %>" title="<%=teammodel.Title %>" />
                            </a>
                        </div>
                        <h3 class="newh3">
                            <a class="js_dlst " href="<%=getTeamPageUrl(teammodel.Id)  %>"
                                target="_blank">
                                <%=teammodel.Title %></a></h3>
                        <!--2012.1.31 修改模板-->
                        <%  if (GetState(teammodel) == AS.Enum.TeamState.successnobuy)
                            {%>
                        <div class="tuanbd5 over">
                            <div class="goods_price">
                                <div class="price_now">
                                    <span class="rmb">
                                        <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b><span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                                </div>
                            </div>
                            <div class="goods_status">
                                <a href="#" target="_blank" title="<%=teammodel.Product %>"></a>
                            </div>
                        </div>
                        <% }
                            else if (isover(teammodel))
                            {%>
                        <div class="tuanbd5 end">
                            <div class="goods_price">
                                <div class="price_now">
                                    <span class="rmb">
                                        <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b><span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                                </div>
                            </div>
                            <div class="goods_status">
                                <a href="#" target="_blank" title="<%=teammodel.Product %>"></a>
                            </div>
                        </div>
                        <% }
                            else
                            {%>
                        <% if (teammodel.Delivery == "draw")
                           {%>
                        <div class="tuanbd5 chouj">
                            <div class="goods_price">
                                <div class="price_now">
                                    <span class="rmb">
                                        <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b><span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                                </div>
                            </div>
                            <div class="goods_status">
                                <a href="<%=getTeamPageUrl(teammodel.Id) %>"
                                    target="_blank" title="<%=teammodel.Product %>"></a>
                            </div>
                        </div>
                        <% }
                           else
                           {%>
                        <div class="tuanbd5">
                            <div class="goods_price">
                                <div class="price_now">
                                    <span class="rmb">
                                        <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b><span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                                </div>
                            </div>
                            <div class="goods_status">
                                <a href="<%=getTeamPageUrl(teammodel.Id) %>"
                                    target="_blank" title="<%=teammodel.Product %>"></a>
                            </div>
                        </div>
                        <% }%>
                        <% }%>
                        <div class="tuanft5">
                            <div class="goods_time">
                              <%if ((teammodel.End_time - DateTime.Now).Days >= 3)
                              { %>
                          <strong class="title">剩余时间：</strong><span>
                                       3天以上</span>
                            <%}
                              else
                              { %>
                                <strong class="title">剩余时间：</strong>
                                <%if ((teammodel.End_time - DateTime.Now).Days>0)
                                 {%>
                                  <span class="num" id="Span1"><%=(teammodel.End_time - DateTime.Now).Days%></span>天 
                              <%}%>
                                <span id="Span2" class="num"><%=(teammodel.End_time - DateTime.Now).Hours%></span>时
                                <span id="Span3" class="num"><%=(teammodel.End_time - DateTime.Now).Minutes%></span>分
                            <%} %>
                        </div>
                            <div class="goods_buyernumber">
                                <!-- 秒杀判断 -->
                                <span class="num">
                                    <%=teammodel.Now_number%></span>人购买
                            </div>
                            <%if (isShop(teammodel))
                              { 
                            %>
                            <a href="<%=WebRoot%>ajax/car.aspx?id=<%=teammodel.Id %>"></a>
                            <% }
                              else
                              { 
                            %>
                            <div class="xq" onmouseover="show(this)" onmouseout="hide(this)">
                                <%if (!isShop(teammodel))
                                  {%>
                                <div style="display: none;" class="adre_widtd">
                                    <%if (teammodel.Partner!= null)
                                      {
                                          if (teammodel.Partner.Address != "")
                                          {
                                    %>
                                    <p>
                                        <strong>
                                            <%if (teammodel.Partner.area != "")
                                              {%><%=teammodel.Partner.area%><% }
                                              else
                                              { %>地址<%} %></strong>：
                                        <%=teammodel.Partner.Address%>
                                    </p>
                                    <em></em>
                                    <% }
                                            else
                                            { 
                                    %>
                                    <p>
                                        <strong>
                                            <%if (teammodel.Partner.area != "")
                                              {%><%=teammodel.Partner.area%><% }
                                              else
                                              { %>地址<%} %></strong>： 暂无地址
                                    </p>
                                    <em></em>
                                    <%
                                            }
                                        }

                                        else
                                        {     %><strong> 地址</strong>： 暂无地址 <em></em>
                                    <%} %>
                                </div>
                                <%
                                  }%>
                            </div>
                            <%
                              }%>
                        </div>
                    </div>
                    <% }%>
                    <%} %>
                    <a href="<%=getTeamDetailPageUrl(model.id, 0, 0, 0) %>"
                        class="more_link1">点击查看更多>></a>
                    <!--分类下的项目结束-->
                </div>
            </div>
        </div>
    </div>
    <% }
  }%>
    <!--循环一日多团4-结束-->
    <%if (otherteams != null && otherteams.Count > 0)
      { %>
    <div id="deal-default">
        <div class="tuan_morexq">
            <div class="tuanmore_boxxq">
                <div class="box_tag1">
                    <h2>
                        <a href="#">今日团购</a></h2>
                    <div class="in_hot1">
                    </div>
                    <a href="#" class="more_link"></a>
                </div>
                <div class="tuan_jpq">
                    <% int i = 0; %>
                    <%foreach (ITeam teammodel in otherteams)
                      {

                          i++;
                    %>
                    <%if (i % 3 == 0)
                      {%>
                    <div class="tuanmore1_listxq" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                        <%}
                      else
                      { %>
                        <div class="tuanmore1_listxq" onmouseover="fnOver(this)" onmouseout="fnOut(this)">
                            <%} %>
                            <%if (teammodel.Delivery == "draw")
                              { %>
                            <% }%>
                            <div class="lists1_img img_fl">
                                <a href="<%=getTeamPageUrl(teammodel.Id) %>"
                                    target="_blank" class="image_link">
                                    <img <%=ashelper.getimgsrc(teammodel.Image) %> width="294" height="207" class="dynload"
                                        alt="<%=teammodel.Title %>" title="<%=teammodel.Title %>" />
                                </a>
                            </div>
                            <h3 class="newh3">
                                <a value="10,0 -255px,北京,13,no" class="js_dlst " href="<%=getTeamPageUrl(teammodel.Id) %>"
                                    target="_blank">
                                    <%=teammodel.Title%></a></h3>
                            <!--2012.1.31 修改模板-->
                            <%  if (GetState(teammodel) == AS.Enum.TeamState.successnobuy)
                                {%>
                            <div class="tuanbd5 over">
                                <div class="goods_price">
                                    <div class="price_now">
                                        <span class="rmb">
                                            <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b><span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                                    </div>
                                </div>
                                <div class="goods_status">
                                    <a href="#" target="_blank" title="<%=teammodel.Product %>"></a>
                                </div>
                            </div>
                            <% }
                                else if (isover(teammodel))
                                {%>
                            <div class="tuanbd5 end">
                                <div class="goods_price">
                                    <div class="price_now">
                                        <span class="rmb">
                                            <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b><span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                                    </div>
                                </div>
                                <div class="goods_status">
                                    <a href="#" target="_blank" title="<%=teammodel.Product %>"></a>
                                </div>
                            </div>
                            <% }
                                else
                                {%>
                            <% if (teammodel.Delivery == "draw")
                               {%>
                            <div class="tuanbd5 chouj">
                                <div class="goods_price">
                                    <div class="price_now">
                                        <span class="rmb">
                                            <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b><span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                                    </div>
                                </div>
                                <div class="goods_status">
                                    <a href="<%=getTeamPageUrl(teammodel.Id) %>"
                                        target="_blank" title="<%=teammodel.Product %>"></a>
                                </div>
                            </div>
                            <% }
                               else
                               {%>
                            <div class="tuanbd5">
                                <div class="goods_price">
                                    <div class="price_now">
                                        <span class="rmb">
                                            <%=ASSystem.currency%></span><b><%=GetMoney(teammodel.Team_price)%></b><span class="price_original">原价<%=ASSystem.currency%><%=GetMoney(teammodel.Market_price)%></span>
                                    </div>
                                </div>
                                <div class="goods_status">
                                    <a href="<%=getTeamPageUrl(teammodel.Id) %>"
                                        target="_blank" title="<%=teammodel.Product %>"></a>
                                </div>
                            </div>
                            <% }%>
                            <% }%>
                            <div class="tuanft5">
                               <div class="goods_time">
                              <%if ((teammodel.End_time - DateTime.Now).Days >= 3)
                              { %>
                          <strong class="title">剩余时间：</strong><span>
                                       3天以上</span>
                            <%}
                              else
                              { %>
                                <strong class="title">剩余时间：</strong>
                                    <%if ((teammodel.End_time - DateTime.Now).Days>0)
                              {%>
                                  <span class="num" id="hour_1"><%=(teammodel.End_time - DateTime.Now).Days%></span>天
                              <%}%>
                                <span id="Span4" class="num"><%=(teammodel.End_time - DateTime.Now).Hours%></span>时
                                <span id="min_1" class="num"><%=(teammodel.End_time - DateTime.Now).Minutes%></span>分
                            <%} %>
                        </div>
                                <div class="goods_buyernumber">
                                    <!-- 秒杀判断 -->
                                    <span class="num">
                                        <%=teammodel.Now_number%></span>人购买
                                </div>
                                <%if (isShop(teammodel))
                                  { 
                                %>
                                <a href="<%=WebRoot%>ajax/car.aspx?id=<%=teammodel.Id %>"></a>
                                <% }
                                  else
                                  { 
                                %>
                                <div class="xq" onmouseover="show(this)" onmouseout="hide(this)">
                                    <%if (isShop(teammodel))
                                      {
                                    %>
                                    <div style="display: none;" class="adre_widtd">
                                        <%if (teammodel.Partner != null)
                                          {
                                              if (teammodel.Partner.Address != "")
                                              {
                                        %>
                                        <p>
                                            <strong>
                                                <%if (teammodel.Partner.area != "")
                                                  {%><%=teammodel.Partner.area%><% }
                                                  else
                                                  { %>地址<%} %></strong>：
                                            <%=teammodel.Partner.Address%>
                                        </p>
                                        <em></em>
                                        <%}
                                                else
                                                { 
                                        %>
                                        <p>
                                            <strong>
                                                <%if (teammodel.Partner.area != "")
                                                  {%><%=teammodel.Partner.area%><% }
                                                  else
                                                  { %>地址<%} %></strong>： 暂无地址
                                        </p>
                                        <em></em>
                                        <%
                                                }
                                            }
                                            else
                                            {     %><strong> 地址</strong>： 暂无地址 <em></em>
                                        <%} %>
                                    </div>
                                    <%
                                      }%>
                                </div>
                                <%}%>
                            </div>
                        </div>
                        <% }%>
                    </div>
                </div>
            </div>
        </div>
         <%}%>

