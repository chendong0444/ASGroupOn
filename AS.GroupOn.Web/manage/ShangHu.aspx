<%@ Page Language="C#" AutoEventWireup="true"  Inherits ="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.GroupOn.Domain.Spi" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script  runat="server">
    
    protected IPagers<IPartner> pager = null;
    protected IList<IPartner> iListPartner = null;
    protected int Branch = 0;
    protected string pagerHtml = String.Empty;
    protected string pagePar = "";
    protected IList<ICategory> Icategorylist = null;
    protected IList<ICategory> gettypeList = null;
    protected int countpage = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        PageValue.Title = "商户列表";

        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Partner_List))
        {
            SetError("你不具有查看商户列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        int id = AS.Common.Utils.Helper.GetInt(Request["remove"], 0);
        if (id > 0)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Partner_Delete))
            {
                SetError("你不具备删除商户列表的权限!");
                Response.Redirect("ShangHu.aspx");
                Response.End();
                return;
            }
            else
            {
                int delete = 0;
                //删除之前判断该商户下是否建立有分站，如果有分站就不能删除
                BranchFilter filter1 = new BranchFilter();
                filter1.partnerid = id;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    Branch = session.Branch.GetCount(filter1);
                }
                if (Branch > 0)
                {
                    SetError("无法删除带有分店的商户");
                   
                }
                else
                {
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        delete = session.Partners.Delete(id);
                    }
                    if (delete > 0)
                    {
                        SetSuccess("删除成功");
                        string key = AS.Common.Utils.FileUtils.GetKey();
                        AS.AdminEvent.ConfigEvent.AddOprationLog(AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", key), 0), "删除商户", "删除商户 ID:" + Request.QueryString["remove"].ToString(), DateTime.Now);
                    }
                    else
                    {
                        SetError("删除失败");
                    }
           
                }

            }
        }
        //销售ID筛选  
        PartnerFilter filter = new PartnerFilter();
        if (!string.IsNullOrEmpty(Request["saleid"]))
        {
            filter.saleid = AS.Common.Utils.Helper.GetString(Request["saleid"], String.Empty);
            pagePar = pagePar + "&saleid=" + Helper.GetString(Request["saleid"], String.Empty);
        }
        //项目ID筛选
        TeamFilter teamfilter = new TeamFilter();
        ITeam team = null;
        if (!string.IsNullOrEmpty(Request["teamid"]))
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                team = session.Teams.GetByID(AS.Common.Utils.Helper.GetInt(Request["teamid"], 0));
            }
            if (team != null)
            {
                int parid = team.Partner_id;
                filter.Id = parid;
                pagePar = pagePar + "&teamid=" + parid;
            }
        }
        //商户名称
        if (!string.IsNullOrEmpty(Request["ptitle"]))
        {
            filter.Title = Helper.GetString(Request["ptitle"], String.Empty);
            pagePar = pagePar + "&ptitle=" + Helper.GetString(Request["ptitle"], String.Empty);
        }
        //结算状态
        Partner_DetailFilter pdfilter = new Partner_DetailFilter();
        IList<IPartner_Detail> pdetailList = null;
        string partnerid = String.Empty;
        if (!string.IsNullOrEmpty(Request["ddlStatus"]) && AS.Common.Utils.Helper.GetInt(Request["ddlStatus"],0)!=0)
        {
            pdfilter.settlementstate = AS.Common.Utils.Helper.GetInt(Request["ddlStatus"], 0);
            StringBuilder sb1 = new StringBuilder();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                pdetailList = session.Partner_Detail.GetList(pdfilter);
            }
            if (pdetailList.Count > 0)
            {
                foreach (IPartner_Detail item in pdetailList)
                {
                    sb1.Append(item.partnerid + ",");
                }
                partnerid = sb1.ToString().Remove(sb1.ToString().LastIndexOf(","), 1);
                filter.par_Id = partnerid;
            }
            else
            {
                filter.par_Id = AS.Common.Utils.Helper.GetString(Request["ddlStatus"], "0");
            }
            pagePar = pagePar + "&ddlStatus=" + Request["ddlStatus"];
        }
        //商户秀
        if (!string.IsNullOrEmpty(Request["open"]))
        {
            filter.Open = Helper.GetString(Request["open"], String.Empty);
            pagePar = pagePar + "&open=" + Helper.GetString(Request["open"], String.Empty);
        }
        //城市
        if (!string.IsNullOrEmpty(Request["city_id"]))
        {
            filter.City_id = Helper.GetInt(Request["city_id"], 0);
            pagePar = pagePar + "&city_id=" + Helper.GetInt(Request["city_id"], 0);

        }
        //分类
        if (!string.IsNullOrEmpty(Request["partner"]) && AS.Common.Utils.Helper.GetInt(Request["partner"],0)!=0)
        {
            filter.Group_id = Helper.GetInt(Request["partner"], 0);
            pagePar = pagePar + "&partner=" + Helper.GetInt(Request["partner"], 0);

        }
        //所有城市
        CategoryFilter filt = new CategoryFilter();
        filt.Zone = "city";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            Icategorylist = session.Category.GetList(filt);
        }
        //查所有分类
        CategoryFilter filter2 = new CategoryFilter ();
        filter2.Zone = "partner";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
        {
            gettypeList = session.Category.GetList(filter2);
        }
        pagePar = pagePar + "&page={0}";
        pagePar = "ShangHu.aspx?" + pagePar.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(PartnerFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Partners.GetPager(filter);
        }
        countpage = pager.TotalPage;
        iListPartner = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, pagePar);
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1">
      <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
     
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                     &nbsp;&nbsp;<h2>商户</h2>
                                      <input type="hidden" value="<%=countpage %>" id="countpage" name="countpage" /><!--记录总页数-->
                                    <div class="search">
                                        &nbsp;&nbsp;
                                        销售ID:
                                        <input id="saleid" type="text" name="saleid" class="h-input" value="<%=Request["saleid"] %>"  />&nbsp;
                                        项目ID:
                                        <input id="teamid" type="text" name="teamid" class="h-input" value="<%=Request["teamid"] %>"  />&nbsp;
                                        商户名称：
                                        <input id="username" type="text" name="ptitle" class="h-input" value="<%=Request["ptitle"] %>"  />&nbsp;
                                        <select name="ddlStatus" class="h-input">
                                            <option value="0"
                                                <%if(Request["ddlStatus"]=="0"){ %>
                                                selected="selected"
                                                <%} %>
                                            >结算状态</option>
                                            <option value="1"
                                                <%if(Request["ddlStatus"]=="1"){ %>
                                                selected="selected"
                                                <%} %>
                                            >待审核</option>
                                            <option value="2"
                                                <%if(Request["ddlStatus"]=="2"){ %>
                                                selected="selected"
                                                <%} %>
                                            >拒绝</option>
                                            <option value="4"
                                                <%if(Request["ddlStatus"]=="4"){ %>
                                                selected="selected"
                                                <%} %>
                                            >正在结算</option>
                                            <option value="8"
                                                <%if(Request["ddlStatus"]=="8"){ %>
                                                selected="selected"
                                                <%} %>
                                            >已结算</option>
                                        </select>

                                        &nbsp;
                                        <select name='open' class="h-input">
                                            <option value='' <%if(Request["open"]=="")
                                                {%> 
                                                selected="selected" 
                                                <%}%>>全部秀
                                            </option>
                                            <option value='Y' <%if(Request["open"]=="Y")
                                                {%> 
                                                selected="selected" 
                                                <%}%>>开放展示
                                            </option>
                                            <option value='N' <%if(Request["open"]=="N")
                                                {%>
                                                 selected="selected" 
                                                 <%}%>>关闭展示
                                             </option>
                                        </select>&nbsp;

                                        <select name="city_id"  class="h-input">
                                            <option value=""
                                                <%if(Request["city_id"]==""){%>
                                                  selected="selected"
                                                <%} %>
                                                >全部城市</option>
                                                <% foreach (ICategory item in Icategorylist)
                                                {%>
                                                    <option value="<%=item.Id %>"
                                                    <%if(Helper.GetInt(Request["city_id"],0)==item.Id){ %>
                                                    selected="selected"
                                                    <%} %>><%=item.Name %></option> 
                                                <%} %>
                                        </select>
                                        <select name="partner" class="h-input">
                                                <option value=""
                                                <%if(Request["partner"]==""){%>
                                                selected="selected"<%} %>>全部分类</option>
                                                <% foreach (ICategory  item1 in gettypeList)
                                                   {%>
                                                      <option value="<%=item1.Id %>"
                                                          <%
                                                            if(AS.Common.Utils.Helper.GetInt(Request["partner"],0)==item1.Id)
                                                            {%> 
                                                            selected ="selected"
                                                           <%} %>>
                                                           <%=item1.Name%>
                                                       </option> 
                                                   <%} %>
                                        </select>&nbsp;
                                    <input id="saixuan" name="btnselect" type="submit" value="筛选" class="formbutton" style="padding: 1px 6px;"/>
                                    <ul class="filter"  >
                                        <li>
                                        </li>
                                    </ul>
                                </div>
                                    <div class="sect">
                                        <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='10%'>ID</th>
                                            <th width='15%'>名称</th>
                                            <th width='10%'>分类</th>
                                            <th width='10%'>联系人</th>
                                            <th width='10%'>电话号码</th>
                                            <th width='15%'>销售人员</th>
                                            <th width='5%'>商户秀</th> 
                                            <th width='25%'>&nbsp;&nbsp;&nbsp;操  作</th>
                                        </tr>
                                        <% int i = 2; %>
                                        <%foreach (IPartner item in iListPartner)
                                          {
                                              if (i % 2 == 0)
                                              {%>
                                                 <tr class="alt">
                                            <%}else{ %>
                                                <tr>
                                                <%} i++;%>
                                                <td><%=item.Id %></td>

                                                <td><%=item.Title%></td>
                                                <td>
                                                <%
                                                //分类
                                                if (item.getTypeNameByGroupID != null)
                                                 {%>
                                                <%=item.getTypeNameByGroupID.Name%>
                                                <%} %>
                                                <br />
                                                <% 
                                               if (item.getTypeNameByCityID != null)
                                                {
                                                %>
                                                <%=item.getTypeNameByCityID.Name%>
                                               
                                                <%} %>
                                                </td>

                                                <td><%=item.Contact %></td>
                                         
                                                <td><%=item.Phone%><br />

                                                <%=item.Mobile%></td>
                                                    
                                                <!--销售人员-->
                                                <td><%=item.getRealName%></td>

                                                <td><%=item.Open %></td>

                                                 <td >
 
                                                    <a href='ShangHuBianji.aspx?update=<%=item.Id %>'>编辑</a>｜

                                                    <a href='ShangHu.aspx?remove=<%=item.Id %>' ask='确定删除本商户？'>删除</a>｜

                                                    <a href='ShangHuBranch.aspx?bid=<%=item.Id.ToString() %>'>分店管理</a>｜

                                                    <a href='JieSuan.aspx?Id=<%=item.Id.ToString() %> '>结算</a>

                                                    <%
                                                     //状态为待审核的商户
                                                    if (item.getPartnerState>0)
                                                    {%>
                                                      (<a href='JieSuan_ShenHe.aspx?Id=<%=item.Id %>&ddlStatus=1'>待审核 : <%=item.getPartnerState %></a>)
                                                     <%} %>
                                                    </td>
                                            </tr> 
                                          <%}%>
                                        <tr>
                                            <td colspan="8">
                                                <%=pagerHtml%>
                                            </td>
                                        </tr>
                                    </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
