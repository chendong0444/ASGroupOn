<%@ Page Language="C#" AutoEventWireup="true" EnableViewState="false" Inherits="AS.GroupOn.Controls.SalePage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">
    string sql = " 1=1 ";
    string where = "";
    bool result;
    bool result2;
    int page = 1;
    protected string pagerhtml = String.Empty;
    string url = String.Empty;
    int request_teamid = -1;
    string request_name = String.Empty;
    string request_open = String.Empty;
    string request_city = String.Empty;
    string request_part = String.Empty;
    protected PartnerFilter pfilter = new PartnerFilter();
    protected IList<IPartner> ilistpart = null;
    protected IPagers<IPartner> pager = null;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //if (Request.HttpMethod == "POST")
        //{
        //    request_teamid = Helper.GetInt(Request.Form["teamid"], -1);
        //    request_name = Helper.GetString(Request.Form["username"], String.Empty);
        //    request_open = Helper.GetString(Request.Form["open"], String.Empty);
        //    request_city = Helper.GetString(Request.Form["city_id"], String.Empty);
        //    request_part = Helper.GetString(Request.Form["part"], String.Empty);
        //}
        //else
        //{
        
        if (Request["saixuan"] == "筛选")
        {
            request_teamid = Helper.GetInt(Request.QueryString["teamid"], -1);
            request_name = Helper.GetString(Request.QueryString["username"], String.Empty);
            request_open = Helper.GetString(Request.QueryString["open"], String.Empty);
            request_city = Helper.GetString(Request.QueryString["city_id"], String.Empty);
            request_part = Helper.GetString(Request.QueryString["part"], String.Empty);
            page = Helper.GetInt(Request.QueryString["page"], 1);
        }
        //}

        //if (!Page.IsPostBack)
        //{
            if (Session["sql"] != null)
            {
                Session.Remove("sql");
            }

            if (Request.QueryString["remove"] != null)
            {
                int partnetId = GetPartnetId();
                //对商户的操作一定要关联销售人员
                int existresult = 0;
                PartnerFilter partfilter = new PartnerFilter();
                partfilter.table = "Partner where  ','+saleid+',' like '%," + GetSaleId().ToString() + ",%' and id=" + partnetId;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    existresult = session.Partners.Count(partfilter);
                }
                if (existresult <= 0)
                {
                    Response.Redirect("PartnetList.aspx");
                    return;
                }
                int count = 0;
                TeamFilter teamfilter = new TeamFilter();
                teamfilter.table = " Team where partner_id=" + partnetId;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    count = session.Teams.GetDetailCount(teamfilter);
                }


                if (count > 0)
                {
                    SetError("删除商户失败，该商户下已经有项目信息！");
                }
                else
                {
                    //根据总店ID查询是否存在分店
                    IBranch branchmodel = Store.CreateBranch();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        branchmodel = session.Branch.GetByID(partnetId);
                    }
                    if (branchmodel != null)
                    {
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int debrpa = session.Branch.Delete(Helper.GetInt(partnetId, 0));
                            int depa = session.Partners.Delete(Helper.GetInt(partnetId, 0));
                        }

                        SetSuccess("删除成功");
                        Response.Redirect("PartnetList.aspx");
                    }
                    else
                    {
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int depa = session.Partners.Delete(Helper.GetInt(partnetId, 0));
                        }
                        SetSuccess("删除成功");
                        Response.Redirect("PartnetList.aspx");
                    }
                }
            }
        //}

        pdbshow();
    }

    /// <summary>
    /// 商户展示
    /// </summary>
    private void pdbshow()
    {
        #region ##在商家表添加了销售人员id
        int strSaleId = 0;
        strSaleId = Helper.GetInt(CookieUtils.GetCookieValue("sale", key).ToString(), 0);
        if (strSaleId != 0)
        {
            sql += " and  ','+saleid+',' like '%," + strSaleId + ",%'";
            Session.Add("sql", sql);
            result = true;
        }
        #endregion
        //if (request_teamid.ToString() != String.Empty && request_teamid > 0)
        if (!string.IsNullOrEmpty(Request.QueryString["teamid"]))
        {
            sql += " and id in(select partner_id from team where id=" + Request.QueryString["teamid"] + ") ";
            Session.Add("sql", sql);
            url += "&teamid=" + Request.QueryString["teamid"];
            result = true;
        }
        //if (request_name != String.Empty)
        if (!string.IsNullOrEmpty(Request.QueryString["username"]))
        {
            sql += " and Title like '" + Request.QueryString["username"] + "%' ";
            Session.Add("sql", sql);
            url += "&username=" + Request.QueryString["username"];
            result = true;
        }
        //if (request_open != String.Empty)
        if (!string.IsNullOrEmpty(Request.QueryString["open"]))
        {
            sql += " and [Open]='" + Request.QueryString["open"] + "' ";
            Session.Add("sql", sql);
            url += "&open=" + Request.QueryString["open"];
            result = true;
        }
        //if (request_city != String.Empty && request_city != "0")
        if (!string.IsNullOrEmpty(Request.QueryString["city_id"]))
        {
            sql += " and City_id=" + Request.QueryString["city_id"] + " ";
            Session.Add("sql", sql);
            url += "&city_id=" + Request.QueryString["city_id"];
            result = true;
        }
        //if (request_part != String.Empty)
        if (!string.IsNullOrEmpty(Request.QueryString["part"]))
        {
            sql += " and Group_id=" + Request.QueryString["part"] + " ";
            Session.Add("sql", sql);
            url += "&part=" + Request.QueryString["part"];
            result = true;
        }
        if (result == true)
        {
            sql = Session["sql"].ToString();

        }
        where = sql;
        //商户类型
        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<tr >");
        sb1.Append("<th width='12%'>ID</th>");
        sb1.Append("<th width='23%'>名称</th>");
        sb1.Append("<th width='10%'>分类</th>");
        sb1.Append("<th width='15%'>联系人</th>");
        sb1.Append("<th width='15%'>电话号码</th>");
        sb1.Append("<th width='10%'>商户秀</th>");
        sb1.Append("<th width='15%'>操作</th>");
        sb1.Append("</tr>");
        Literal5.Text = sb1.ToString();
        //商户数据
        StringBuilder sb2 = new StringBuilder();
        int i = 0;

        pfilter.table = " Partner where " + where;
        pfilter.PageSize = 30;
        pfilter.CurrentPage = Helper.GetInt(Request.QueryString["page"], 1) ;
        pfilter.AddSortOrder(PartnerFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Partners.Page(pfilter);
        }
        ilistpart = pager.Objects;

        foreach (IPartner pat in ilistpart)
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
            sb2.Append("<td>" + pat.Id.ToString() + "</td>");
            sb2.Append("<td style='text-align:left;'>");
            sb2.Append("<a class='deal-title' href='PartnetUpdate.aspx?id=" + pat.Id.ToString() + "'>" + pat.Title.ToString() + "</a>");
            sb2.Append("</td>");
            sb2.Append("<td nowrap>");
            CategoryFilter catefilter = new CategoryFilter();
            IList<ICategory> ilistcate = null;
            catefilter.Id = Helper.GetInt(pat.Group_id, 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilistcate = session.Category.GetList(catefilter);
            }
            foreach (ICategory item in ilistcate)
            {
                sb2.Append(item.Name.ToString());
            }
            sb2.Append("<br/>");
            CategoryFilter cfilter = new CategoryFilter();
            IList<ICategory> ilistc = null;
            cfilter.Id = Helper.GetInt(pat.City_id, 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilistc = session.Category.GetList(cfilter);
            }
            foreach (ICategory item in ilistc)
            {
                sb2.Append(item.Name.ToString());
            }
            sb2.Append("</td>");
            sb2.Append("<td nowrap>" + pat.Contact.ToString() + "</td>");
            sb2.Append("<td nowrap>" + pat.Phone.ToString() + "<br/>" + pat.Mobile.ToString() + "</td>");
            sb2.Append("<td nowrap>" + pat.Open.ToString() + "</td>");
            sb2.Append("<td class='op' nowrap>");
            sb2.Append("<a href='" + PageValue.WebRoot + "sale/PartnetUpdate.aspx?id=" + pat.Id.ToString() + "'>编辑</a>｜");
            sb2.Append("<a href='" + PageValue.WebRoot + "sale/PartnetList.aspx?remove=" + pat.Id.ToString() + "' ask='确定删除本商户？'>删除</a>｜");
            sb2.Append("<a href='" + PageValue.WebRoot + "sale/PartnetBranch.aspx?bid=" + pat.Id.ToString() + "'>分站管理</a>");
            sb2.Append("</td>");
            sb2.Append("</tr>");
        }
        Literal1.Text = sb2.ToString();
        if (result2 == true)
        {
            where += " and  Id not in(select top " + (page - 1) * 30 + " Id from Partner where " + sql + " order by Id desc) ";
        }

        pagerhtml = WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, PageValue.WebRoot + "sale/PartnetList.aspx?" + url + "&page={0}");
    }


    #region ################### 接参 ###################
    private int GetPartnetId()//总店ID
    {
        int partid = 0;
        if (!object.Equals(Request.QueryString["remove"], null))
        {
            try
            {
                partid = int.Parse(Request.QueryString["remove"].ToString());
            }
            catch { }
        }
        return partid;
    }

    private int GetSaleId()//接收销售人员id
    {
        int sale_id = 0;
        if (!object.Equals(CookieUtils.GetCookieValue("sale", key), null))
        {
            try
            {
                sale_id = int.Parse(CookieUtils.GetCookieValue("sale", key).ToString());
            }
            catch { }
        }
        return sale_id;
    }
        #endregion
</script>
<%LoadUserControl("_header.ascx", null); %>
<body>
    <form id="form1" runat="server" method="get">
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
                                        商户</h2>
                                    <div class="search">
                                        
                                            项目ID:
                                                <input id="teamid" type="text" name="teamid" class="h-input" <%if (!string.IsNullOrEmpty(Request.QueryString["teamid"]))
                                                  { %>value="<%=Request.QueryString["teamid"]%>"
                                                <%} %> />&nbsp;商户名称：<input
                                                    id="username" type="text" name="username" class="h-input" <%if (!string.IsNullOrEmpty(Request.QueryString["username"]))
                                                  { %>value="<%=Request.QueryString["username"]%>"
                                                <%} %>/>&nbsp;
                                                <select id="open" name='open' class='h-input'>
                                                    <option value='' >全部秀</option>
                                                    <option value='Y' <%if(Request.QueryString["open"]=="Y"){%> selected<%}%>>开放展示</option>
                                                    <option value='N' <%if(Request.QueryString["open"]=="N"){%> selected<%}%>>关闭展示</option>
                                                </select>&nbsp;
                                                <select id="city_id" name='city_id' class='h-input'>
                                                    <option value=''>全部城市</option>
                                                    <%  
                                                        CategoryFilter catefilter = new CategoryFilter();
                                                        IList<ICategory> ilistcategory = null;
                                                        catefilter.Zone = "city";
                                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                        {
                                                            ilistcategory = session.Category.GetList(catefilter);
                                                        }
                                                        foreach (ICategory item in ilistcategory)
                                                        { %>
                                                    <option value='<%=item.Id %>' <%if(Request.QueryString["city_id"]==item.Id.ToString()){%>
                                                        selected<%}%>>
                                                        <%=item.Name%></option>
                                                    "
                                                    <%} %>
                                                </select>
                                                <select id="part" name='part' class='h-input'>
                                                    <option value='' selected>全部分类</option>
                                                    <%
                                                        CategoryFilter cfilter = new CategoryFilter();
                                                        IList<ICategory> ilistca = null;
                                                        cfilter.Zone = "partner";
                                                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                        {
                                                            ilistca = session.Category.GetList(cfilter);
                                                        }
                                                        foreach (ICategory items in ilistca)
                                                        { %>
                                                    <option value='<%=items.Id %>' <%if(Request.QueryString["part"]==items.Id.ToString()){%>
                                                        selected<%}%>>
                                                        <%=items.Name%></option>
                                                    "
                                                    <%}%>
                                                </select>&nbsp;
                                                <input id="saixuan" name="saixuan" type="submit" value="筛选" class="formbutton"
                                                    style="padding: 1px 6px;" runat="server" />
                                    </div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal5" runat="server">
                                        </asp:Literal>
                                        <asp:Literal ID="Literal1" runat="server">
                                        </asp:Literal>
                                        <tr>
                                            <td colspan="7">
                                                <ul class="paginator">
                                                    <li class="current">
                                                        <%=pagerhtml%>
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
            </div>
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
