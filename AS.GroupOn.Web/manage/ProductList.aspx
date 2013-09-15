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
    
    protected IPagers<IProduct> pager = null;
    protected IList<IProduct> iListProduct = null;

    protected string pagerHtml = String.Empty;
    protected string url = "";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Product_ListView))
        {
            SetError("你不具有查看产品列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        
        ProductFilter filter = new ProductFilter();
        if (this.partnerid.Text != null && this.partnerid.Text != "" || Request["partnerid"] != "" && Request["partnerid"]!=null)
        {
            if (Request["partnerid"] != "" && Request["partnerid"] != null)
            {
                this.partnerid.Text = Request["partnerid"];
            }
            filter.partnerId = AS.Common.Utils.Helper.GetInt(this.partnerid.Text, 0);
            url = url + "&partnerid=" + this.partnerid.Text;
        }
        if (ddlStatus.SelectedValue != "" || Request["Status"] != "" && Request["Status"] != null)
        {
            if (ddlStatus.SelectedValue != "")
            {
                filter.Status = AS.Common.Utils.Helper.GetInt(ddlStatus.SelectedValue, 0);
                url = url + "&Status=" + ddlStatus.SelectedValue;
            }
            else
            {
                ddlStatus.SelectedValue = Request["Status"];
                filter.Status = AS.Common.Utils.Helper.GetInt(ddlStatus.SelectedValue, 0);
                url = url + "&Status=" + ddlStatus.SelectedValue;
            }

        }
        if (likename.Text != "" || Request["likename"] != "" && Request["likename"] != null)
        {
            if (Request["likename"] != "" && Request["likename"] != null)
            {
                likename.Text = Request["likename"];
            }

            filter.Productnamelike = likename.Text;

            url = url + "&likename=" + likename.Text;


        }
        if (Request["del"] != null && Request["del"].ToString() != "")
        {
            IList<ITeam> lit = null;
            TeamFilter teamft = new TeamFilter();
            teamft.productid = Convert.ToInt32(Request["del"].ToString());
            using (IDataSession Session = AS.GroupOn.App.Store.OpenSession(false))
            {
                lit = Session.Teams.GetList(teamft);
            }
            if (lit.Count > 0)
            {
                SetError("删除产品失败，该产品下已经有项目信息！");
            }
            else
            {
                using (IDataSession Session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int id2 = Session.Product.Delete(int.Parse(Request["del"].ToString()));
                }
                SetSuccess("删除产品成功！");
            }
            Response.Redirect("ProductList.aspx");
            Response.End();
        }
        url = url + "&page={0}";
        url = "ProductList.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(ProductFilter.SORTORDER_DESC);
        filter.AddSortOrder(ProductFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Product.GetPager(filter);
        }
        iListProduct = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }
    
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
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
                                        产品列表</h2>
                                    <form id="Form2" runat="server" method="get">
                                    <div class="search">
                                        &nbsp;&nbsp; 商家ID：<asp:TextBox ID="partnerid" runat="server" CssClass="h-input"></asp:TextBox>&nbsp;
                                        状态：<asp:DropDownList class="h-input" ID="ddlStatus" runat="server">
                                            <asp:ListItem Value="">请选择</asp:ListItem>
                                            <asp:ListItem Value="1">上架</asp:ListItem>
                                            <asp:ListItem Value="2">被拒绝</asp:ListItem>
                                            <asp:ListItem Value="4">待审核</asp:ListItem>
                                            <asp:ListItem Value="8">下架</asp:ListItem>
                                        </asp:DropDownList>
                                        &nbsp; 产品名称：<asp:TextBox class="h-input" ID="likename" runat="server"></asp:TextBox>&nbsp;
                                        <asp:Button ID="Button1" CssClass="formbutton" Style="padding: 1px 6px;" Text="筛选"
                                            runat="server" />
                                    </div>
                                    </form>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='8%'>
                                                ID
                                            </th>
                                            <th width='20%'>
                                                名称
                                            </th>
                                            <th width='10%'>
                                                商家
                                            </th>
                                            <th width='10%'>
                                                价格
                                            </th>
                                            <th width='5%'>
                                                数量
                                            </th>
                                            <th width='10%'>
                                                排序
                                            </th>
                                            <th width='15%'>
                                                添加时间
                                            </th>
                                            <th width='5%'>
                                                状态
                                            </th>
                                            <th width='25%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListProduct != null && iListProduct.Count > 0)
                                          {
                                              int i = 0;
                                              int producid = 0;
                                              foreach (IProduct productInfo in iListProduct)
                                              {
                                                  if (i % 2 != 0)
                                                  { %>
                                        <tr>
                                            <%}
                                                  else
                                                  { %>
                                            <tr class="alt">
                                                <% }
                                                  i++;
                                                %>
                                                <td>
                                                    <%=productInfo.id %>
                                                </td>
                                                <td>
                                                    <%=productInfo.productname %>
                                                </td>
                                                <%if (productInfo.Partner != null && productInfo.Partner.Title!=null)
                                                  {
                                                %>
                                                <td>
                                                    <%=productInfo.Partner.Title %>
                                                </td>
                                                <%}
                                                  else
                                                  {%>
                                                <td>
                                                </td>
                                                <%}%>
                                                <td>
                                                    <%= productInfo.price %>
                                                </td>
                                                <td>
                                                    <%=productInfo.inventory  %>
                                                </td>
                                                <td>
                                                    <%=productInfo.sortorder %>
                                                </td>
                                                <td>
                                                    <%=productInfo.createtime %>
                                                </td>
                                                <% if (productInfo.status == 1)
                                                  {
                                                %>
                                                <td>
                                                    上架
                                                </td>
                                                <%
}
                                                  else if (productInfo.status == 2)
                                                  {%>
                                                <td>
                                                    被拒绝
                                                </td>
                                                <%}
                                                  else if (productInfo.status == 4)
                                                  {%>
                                                <td>
                                                    待审核
                                                </td>
                                                <%}
                                                  else if (productInfo.status == 8 || producid != 0)
                                                  {%>
                                                <td>
                                                    下架
                                                </td>
                                                <%}
                                                  else if (productInfo.inventory == 0 || productInfo.inventory < 0)
                                                  {%>
                                                <td>
                                                    下架
                                                </td>
                                                <%}
                                                  else
                                                  {%>
                                                <td>
                                                    无法查询到状态
                                                </td>
                                                <%}   
                                                %>
                                                <td>
                                                    <a class="ajaxlink" href="ajax_manage.aspx?action=productdetail&id=<%=productInfo.id %>">
                                                        详情</a>|<a href="ProductAdd.aspx?id=<%=productInfo.id %>">编辑</a>
                                                    <%if (productInfo.status != 4 && !AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Product_Delete)){ %>
                                                        |<a href="ProductList.aspx?del=<%=productInfo.id %>" ask="确定删除吗?">删除</a>
                                                    <%}%>
                                                    <%if (!AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Product_Examine)) {%>
                                                        |<a class="ajaxlink" href="ajax_manage.aspx?action=productstatus&id=<%=productInfo.id %>">审核</a>
                                                    <%}
                                                    if (productInfo.open_invent == 1 && !AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Product_Storage))
                                                    {%>
                                                        |<a class="ajaxlink" href="ajax_coupon.aspx?action=pinvent&p=p&inventid=<%=productInfo.id %>">出入库</a>
                                                    <%} %>
                                                </td>
                                            </tr>
                                            <%
                                                }
                                          }
                                            %>
                                            <tr>
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
</body>
<%LoadUserControl("_footer.ascx", null); %>
