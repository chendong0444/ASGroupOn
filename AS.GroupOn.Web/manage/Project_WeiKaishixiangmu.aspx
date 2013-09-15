<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">

    protected IPagers<ITeam> pager = null;
    protected IList<ITeam> teamlist = null;
    protected IList<ITeam> teamlist2 = null;
    protected IList<ICatalogs> catalogslist = null;
    private NameValueCollection _system = new NameValueCollection();
    protected CouponFilter couponfilter = new CouponFilter();
    protected IList<ICatalogs> iListCatalogs = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected CategoryFilter categoryfilter = new CategoryFilter();
    protected IList<ICategory> iListCategory = null;
    protected CatalogsFilter catalogsfilter = new CatalogsFilter();
    protected System.Data.DataTable catalogsdt = null;
    protected int count = 0;
    protected string style = null;
    protected string style1 = null;
    protected string style2 = null;
    protected string style3 = null;
    protected ITeam teamodel = null;
    protected ICategory categorymodel = null;
    private string href = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Team_NoStart))
        {
            SetError("你不具有查看未开始项目列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        _system = AS.Common.Utils.WebUtils.GetSystem();
        TeamFilter filter2 = new TeamFilter();
        if (Request.QueryString["remove"] != null)
        {
            delProject(int.Parse(Request.QueryString["remove"].ToString()));
        }
        if (Request.QueryString["downloadid"] != null)
        {
           string sb1 = TeamMethod.xiazai(Request.QueryString["downloadid"]);
           if (sb1.Contains("没有数据505"))
           {
               SetError("没有数据，请重新选择条件下载！");
               Response.Redirect("YingXiao_ShujuXiazai_Team.aspx");
               Response.End();
           }
           else
           {
               Response.ClearHeaders();
               Response.Clear();
               Response.Expires = 0;
               Response.Buffer = true;
               Response.AddHeader("Accept-Language", "zh-tw");
               //文件名称
               Response.AddHeader("content-disposition", "attachment; filename=" + System.Web.HttpUtility.UrlEncode("team_" + DateTime.Now.ToString("yyyy-MM-dd") + ".xls", System.Text.Encoding.UTF8) + "");
               Response.ContentType = "Application/octet-stream";
               //文件内容
               Response.Write(sb1.ToString());
               Response.End();
               SetSuccess("下载成功");
           }
        }
        if (Request["btnselect"] == "筛选" && ddlhost.SelectedValue == "" && this.ddlparent.SelectedValue == "" && this.ddlstate.SelectedValue == "")
        {
            Response.Redirect("Project_DangqianXiangmu.aspx");
        }
        #region 根据项目标题查询模糊查询
        if (Request["btnselect"] == "筛选" || Request.QueryString["teamhost"] != null || Request.QueryString["CataID"] != null || Request.QueryString["teamhost"] != null || Request.QueryString["teamID"] != null || Request.QueryString["TitleLike"] != null || Request.QueryString["cityidIn"] != null || Request.QueryString["Partner_id"] != null)
        {
            
            if (ddlhost.SelectedValue == "1" || Request.QueryString["teamhost"] == "1")
            {
                filter2.teamhost = 1;
                url = url + "&teamhost=1";
            }
            else if (ddlhost.SelectedValue == "2" || Request.QueryString["teamhost"] == "2")
            {
                filter2.teamhost = 2;
                url = url + "&teamhost=2";
            }
            if (this.ddlparent.SelectedValue != "0" || Request.QueryString["CataID"] != null)
            {
                if (Request.QueryString["CataID"] != null)
                {
                    filter2.CataID = AS.Common.Utils.Helper.GetInt(Request.QueryString["CataID"], 0);
                    url = url + "&CataID=" + Request.QueryString["CataID"];
                }
                else
                {
                    filter2.CataID = AS.Common.Utils.Helper.GetInt(this.ddlparent.SelectedValue, 0);
                    url = url + "&CataID=" + this.ddlparent.SelectedValue;
                }
            }
            //if (this.ddlstate.SelectedValue != "0")
            //{
            if (this.ddlstate.SelectedValue == "1" || Request.QueryString["teamID"] != null)//项目ID
            {
                if (Request.QueryString["teamID"] != null)
                {
                    this.ddlstate.SelectedValue = "1";
                    this.txtteam.Text = Request.QueryString["teamID"].ToString();
                }

                filter2.Id = AS.Common.Utils.Helper.GetInt(this.txtteam.Text, 0);
                url = url + "&teamID=" + AS.Common.Utils.Helper.GetInt(this.txtteam.Text, 0);
            }
            else if (this.ddlstate.SelectedValue == "2" || Request.QueryString["TitleLike"] != null)//项目标)//项目标题
            {
                if (Request.QueryString["TitleLike"] != null)
                {
                    this.ddlstate.SelectedValue = "2";
                    this.txtteam.Text = Request.QueryString["TitleLike"].ToString();
                }
                if (this.txtteam.Text != null)
                {
                    filter2.TitleLike = this.txtteam.Text;
                    url = url + "&TitleLike=" + AS.Common.Utils.Helper.GetInt(this.txtteam.Text, 0);
                }
            }
            else if (this.ddlstate.SelectedValue == "3" || Request.QueryString["cityidIn"] != null)//城)//城市
            {
                if (Request.QueryString["cityidIn"] != null)
                {
                    this.ddlstate.SelectedValue = "3";
                    this.txtteam.Text = Request.QueryString["cityidIn"].ToString();
                }
                if (this.txtteam.Text != null)
                {
                    filter2.cityidIn = this.txtteam.Text;
                    url = url + "&cityidIn=" + this.txtteam.Text;
                }
            }
            else if (this.ddlstate.SelectedValue == "4" || Request.QueryString["Partner_id"] != null)//商)//商户
            {
                if (Request.QueryString["Partner_id"] != null)
                {
                    this.ddlstate.SelectedValue = "4";
                    this.txtteam.Text = Request.QueryString["Partner_id"].ToString();
                }
                if (this.txtteam.Text != null && this.txtteam.Text != "")
                {
                    filter2.Partner_id = AS.Common.Utils.Helper.GetInt(this.txtteam.Text, 0);
                    url = url + "&Partner_id=" + AS.Common.Utils.Helper.GetInt(this.txtteam.Text, 0);
                }
            }
            //}

        }
        #endregion

        #region 复制项目
        if (Request["add"] != null)
        {
            AddTeam(Convert.ToInt32(Request["add"]));
        }
        #endregion
        #region 复制到商城项目
        if (Request["addmall"] != null && Request["teamcata"] != null)
        {
            AddMallTeam(Convert.ToInt32(Request["addmall"].ToString()), Convert.ToInt32(Request["teamcata"].ToString()));
        }
        #endregion

        url = url + "&page={0}";
        url = "Project_WeiKaishixiangmu.aspx?" + url.Substring(1);

        filter2.PageSize = 30;
        filter2.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        if (Request.QueryString["team_type"] != null)
        {
            switch (Request.QueryString["team_type"].ToString())
            {
                case "normal":
                    style1 = "current";
                    break;
                case "seconds":
                    style2 = "current";
                    break;
                case "goods":
                    style3 = "current";
                    break;
            }
            filter2.Team_type = Request.QueryString["team_type"].ToString();
            url = url + "&team_type=" + Request.QueryString["team_type"].ToString();
        }
        else
        {
            style = "current";
        }
        filter2.AddSortOrder(TeamFilter.Sort_Order_DESC);
        filter2.AddSortOrder(TeamFilter.ID_DESC);
        filter2.teamcata = 0;
        filter2.unpoint = "point";
        //filter2.State = TeamState.None;
        filter2.FromBegin_time = DateTime.Now;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Teams.GetPager(filter2);
        }
        teamlist2 = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);


        //分类
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        //分类
        catalogsfilter.type = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            catalogslist = session.Catalogs.GetList(catalogsfilter);
        }
        catalogsdt = AS.Common.Utils.Helper.ToDataTable(catalogslist.ToList());
        if (!IsPostBack)
        {
            this.ddlparent.Items.Add(new ListItem("请选择", "0"));
            BindData(catalogsdt, "0", "", "parent_id", this.ddlparent, "catalogname", "id");
        }

    }



    #region 复制项目
    public void AddTeam(int teamid)
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teamodel = session.Teams.GetByID(teamid);
        }

        if (teamodel.autolimit <= 0)
        {
            teamodel.autolimit = 0;
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int id = session.Teams.Insert(teamodel);
        }
        SetSuccess("友情提示：复制成功");
        Response.Redirect("Project_WeiKaishixiangmu.aspx");
    }
    #endregion

    #region 复制为商城项目
    public void AddMallTeam(int teamid, int teamcata)
    {
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            teamodel = session.Teams.GetByID(teamid);
        }
        if (teamodel.autolimit <= 0)
        {
            teamodel.autolimit = 0;
        }
        teamodel.Now_number = 0;//复制到商城购买人数变为0
        teamodel.Per_number = 0;//商城不限制购买人数
        teamodel.Conduser = "N";
        teamodel.teamcata = teamcata;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int id = session.Teams.Insert(teamodel);
        }

        SetSuccess("友情提示：复制成功");
        Response.Redirect("Project_WeiKaishixiangmu.aspx");
    }
    #endregion

    private void delProject(int id)
    {
        bool result = false;
        result = TeamMethod.isExist(id);
        if (result)
        {
            SetError("项目已成交 , 不可删除！");
        }
        else
        {
            int num = TeamMethod.delProject(id);
            if (num > 0)
            {
                SetSuccess("删除成功");
            }
            string key = AS.Common.Utils.FileUtils.GetKey();
            AS.AdminEvent.ConfigEvent.AddOprationLog(AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", key), 0), "删除项目", "删除项目 ID:" + Request.QueryString["remove"].ToString(), DateTime.Now);
        }
    }
    
    /// <summary>
    /// 绑定下拉框列表
    /// </summary>
    /// <param name="dt"></param>
    /// <param name="id">ID 值 </param>
    /// <param name="blank">是否需要加符号?不加为null</param>
    /// <param name="sqlvalue">筛选为 ID值 的数据</param>
    /// <param name="listName"> 这里是需要绑定的下拉列表控件ID</param>
    private void BindData(System.Data.DataTable dt, string id, string blank, string sqlvalue, DropDownList listName, string name, string value)
    {
        if (dt != null && dt.Rows.Count > 0)
        {
            System.Data.DataView dv = new System.Data.DataView(dt);
            if (sqlvalue != null && sqlvalue != "")
            {
                dv.RowFilter = sqlvalue + "= " + id;
            }

            if (id != "0" && blank != null)
            {
                blank += "|─";
            }
            foreach (System.Data.DataRowView drv in dv)
            {
                listName.Items.Add(new ListItem(blank + "" + drv[name].ToString(), drv[value].ToString()));
                BindData(dt, drv[value].ToString(), blank, sqlvalue, listName, name, value);
            }
        }

    }

</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        未开始项目</h2>
                                    <div class="search">
                                       &nbsp;&nbsp; 属性：<asp:DropDownList class="h-input" ID="ddlhost" runat="server">
                                            <asp:ListItem Value="0">请选择</asp:ListItem>
                                            <asp:ListItem Value="2">推荐</asp:ListItem>
                                            <asp:ListItem Value="1">新品</asp:ListItem>
                                        </asp:DropDownList>
                                        分类：
                                        <asp:DropDownList ID="ddlparent" class="h-input" style=" width:150px" runat="server">
                                        </asp:DropDownList>
                                        <asp:DropDownList ID="ddlstate" class="h-input" runat="server">
                                            <asp:ListItem Value="0">请选择</asp:ListItem>
                                            <asp:ListItem Value="1">项目编号</asp:ListItem>
                                            <asp:ListItem Value="2">项目标题</asp:ListItem>
                                            <asp:ListItem Value="3">城市</asp:ListItem>
                                            <asp:ListItem Value="4">商户编号</asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:TextBox class="h-input" ID="txtteam" runat="server"></asp:TextBox>
                                        <input type="submit" id="btnselect" group="goto" value="筛选" class="formbutton" name="btnselect"
                                            style="padding: 1px 6px;" />
                                        <ul class="filter">
                                            <li class="<%=style %>"><a href="Project_WeiKaishixiangmu.aspx">全部</a></li>
                                            <li class="<%=style1 %>"><a href="Project_WeiKaishixiangmu.aspx?team_type=normal">团购</a></li>
                                            <li class="<%=style2 %>"><a href="Project_WeiKaishixiangmu.aspx?team_type=seconds">秒杀</a></li>
                                            <li class="<%=style3 %>"><a href="Project_WeiKaishixiangmu.aspx?team_type=goods">热销</a></li>
                                        </ul>
                                    </div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='8%'>
                                                ID
                                            </th>
                                            <th width='20%'>
                                                项目名称
                                            </th>
                                            <th width='10%'>
                                                属性
                                            </th>
                                            <th width='15%'>
                                                类别
                                            </th>
                                            <th width='8%'>
                                                排序
                                            </th>
                                            <th width='12%'>
                                                日期
                                            </th>
                                            <th width='5%'>
                                                成交
                                            </th>
                                            <th width='7%'>
                                                价格
                                            </th>
                                            <th width='15%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (teamlist2 != null && teamlist2.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (ITeam teamInfo in teamlist2)
                                              {
                                                  href = getTeamPageUrl(teamInfo.Id);
                                                  if (i % 2 != 0)
                                                  {%>
                                        <tr>
                                            <% }
                                                  else
                                                  {%>
                                            <tr class="alt">
                                                <% }
                                                  i++;
                                                %>
                                                <td>
                                                    <%=teamInfo.Id%>
                                                </td>
                                                <% if (teamInfo.Team_type == "normal")
                                                   {%>
                                                <td>
                                                    [团购] <a href="<%= href %>" target="_blank" class="deal-title">
                                                        <%=teamInfo.Title%>
                                                    </a>
                                                </td>
                                                <% }
                                                   else if (teamInfo.Team_type == "seconds")
                                                   {%>
                                                <td>
                                                    [秒杀] <a href="<%= href %>" target="_blank" class="deal-title">
                                                        <%=teamInfo.Title%>
                                                    </a>
                                                </td>
                                                <%}
                                                   else if (teamInfo.Team_type == "goods")
                                                   {%>
                                                <td>
                                                    [热销] <a href="<%= href %>" target="_blank" class="deal-title">
                                                        <%=teamInfo.Title%>
                                                    </a>
                                                </td>
                                                <% }
                                                   else
                                                   { %>
                                                <td>
                                                    [积分]<a href="<%= href %>" target="_blank" class="deal-title">
                                                        <%=teamInfo.Title%></a>
                                                </td>
                                                <%
                                                    } %>
                                                <%if (teamInfo.teamhost == 1)
                                                  {
                                                %>
                                                <td>
                                                    新品
                                                </td>
                                                <%}
                                                  else if (teamInfo.teamhost == 2)
                                                  {%>
                                                <td>
                                                    推荐
                                                </td>
                                                <% }
                                                  else
                                                  {%>
                                                <td>
                                                </td>
                                                <%} %>
                                                <%ICategory cate = null;
                                                  using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                  {
                                                      cate = session.Category.GetByID(teamInfo.City_id);
                                                  }%>
                                                <td>
                                                    <%if (cate != null)
                                                      {%>
                                                    <%=cate.Name %>
                                                    <%}
                                                      else if (teamInfo.City_id == 0)
                                                      {%>
                                                    全部城市
                                                    <% }
                                                      else
                                                      {%>
                                                    全部城市
                                                    <%}%>
                                                    <br />
                                                    <% if (teamInfo.cataid != null)
                                                       {
                                                           catalogsfilter.id = teamInfo.cataid;
                                                           using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                           {
                                                               iListCatalogs = session.Catalogs.GetList(catalogsfilter);
                                                           }
                                                           foreach (ICatalogs catalogs in iListCatalogs)
                                                           {
                                                               if (catalogs.catalogname != null)
                                                               { %>
                                                    [<%= catalogs.catalogname %>]
                                                    <% }%>
                                                    <%else
{%>
                                                    <%}
                                                       }
                                                   }
                                                       else
                                                       {%>
                                                    <a></a>
                                                    <%}%>
                                                    <br />
                                                    <%if (teamInfo.Group_id != null)
                                                      {
                                                          categoryfilter.Id = teamInfo.Group_id;
                                                          using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                          {
                                                              iListCategory = session.Category.GetList(categoryfilter);
                                                          }
                                                          foreach (ICategory category in iListCategory)
                                                          {
                                                              if (category.Name != null)
                                                              { %>
                                                    [<%= category.Name %>](API)
                                                    <% }
                                                          else
                                                          { }
                                                      }
                                                  }%>
                                                </td>
                                                <td>
                                                    <%=teamInfo.Sort_order %>
                                                </td>
                                                <td>
                                                    <%=teamInfo.Begin_time%>
                                                    <br />
                                                    <%=teamInfo.End_time %>
                                                </td>
                                                <td>
                                                    <%=teamInfo.Now_number%>/<%=teamInfo.Min_number%>
                                                </td>
                                                <td>
                                                    <span class='money'>￥</span><%=teamInfo.Market_price%><br />
                                                    <span class='money'>￥</span><%=teamInfo.Team_price%>
                                                </td>
                                                <td class="op">
                                                    <a class="ajaxlink" href="ajax_manage.aspx?action=teamdetail&id=<%=teamInfo.Id%>">详情</a>｜
                                                    <a class="deal-title" href="Project_BianjiXiangmu.aspx?id=<%=teamInfo.Id%>">编辑</a>｜
                                                    <a class="deal-title" href="Project_WeiKaishixiangmu.aspx?remove=<%= teamInfo.Id%>"
                                                        ask="确定删除本项目吗?">删除</a>｜ <a class="deal-title" href="Project_WeiKaishixiangmu.aspx?add=<%= teamInfo.Id %>"
                                                            ask="确定复制本项目吗？">复制</a>
                                                    <%
                                                        if (teamInfo.productid == 0)//没有绑定产品的才有出入库操作
                                                        {
                                                            if (teamInfo.Delivery == "express")
                                                            {%>
                                                    <br />
                                                    <a class="ajaxlink" href="ajax_coupon.aspx?action=invent&p=&inventid=<%= teamInfo.Id %>"
                                                        target='_blank'>出入库</a>
                                                    <%   }
                                                    }
                                                    if (teamInfo.Delivery.ToString() == "draw")
                                                    {%>
                                                    <br />
                                                    <a href="Project_DrawList.aspx?id=<%=teamInfo.Id %>" target="_parent">抽奖信息</a>
                                                    <%}


                                                    if (teamInfo.Delivery.ToString() == "pcoupon")
                                                    {%>
                                                    <br />
                                                    <a href="PcouponFile.aspx?teamid=<%=teamInfo.Id%>" target="_parent">导入站外券</a>(剩：<a
                                                        href="Youhui_pcoupon.aspx?where_type=1&states=nobuy&type_name=<%=teamInfo.Id  %>">
                                                        <%
                                                            PcouponFilter coupfit = new PcouponFilter();
                                                            coupfit.state = "nobuy";
                                                            coupfit.teamid = teamInfo.Id;
                                                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                            {
                                                                count = session.Pcoupon.GetList(coupfit).Count;
                                                            } %>
                                                        <%=count %></a> / 总：<a href="Youhui_pcoupon.aspx?where_type=1&type_name=<%= teamInfo.Id %>"><% 
                                                                                                                                                        PcouponFilter coupfit2 = new PcouponFilter();
                                                                                                                                                        coupfit2.teamid = teamInfo.Id;
                                                                                                                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                                                                                                        {
                                                                                                                                            count = session.Pcoupon.GetList(coupfit2).Count;
                                                                                                                                        } %>
                                                            <%=count %></a>)
                                                    <%}%>
                                                    <br />
                                                    <a href="Project_WeiKaishixiangmu.aspx?downloadid=<%= teamInfo.Id %>">下载</a>
                                                    <%if (teamInfo.Delivery.ToString() == "express")
                                                      {%>
                                                    |<a href="Project_WeiKaishixiangmu.aspx?addmall=<%=teamInfo.Id%>&teamcata=1" ask="确定将本项目复制到商城吗?">
                                                        复制到商城</a>
                                                    <% }
                                                  
                                                    %>
                                                </td>
                                            </tr>
                                            <%
                                                }
                                          } %>
                                            <td colspan="10">
                                                <%=pagerHtml %>
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
</body>
<%LoadUserControl("_footer.ascx", null); %>
