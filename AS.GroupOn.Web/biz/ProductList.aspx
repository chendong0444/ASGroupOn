<%@ Page Language="C#" EnableViewState="false" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>



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
    int page = 1;
    protected string pagerhtml = String.Empty;
    string url = String.Empty;
    string request_status = String.Empty;
    string request_name = String.Empty;
   protected ProductFilter pfilter = new ProductFilter();
   protected IPagers<IProduct> pager = null;
   protected IList<IProduct> ilistpro = null;
   protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //if (Request.HttpMethod == "POST")
        //{
        //    request_status = ddlStatus.Value.ToString();
        //    request_name = txtproduct.Value.ToString();
        //}
        //else
        //{
        if (Request["btnselect"] == "筛选")
        {
            request_status = Helper.GetString(Request.QueryString["ddlStatus"], String.Empty);
            request_name = Helper.GetString(Request.QueryString["txtproduct"], String.Empty);
            page = Helper.GetInt(Request.QueryString["page"], 1);
        }
        //}

        if (Request["del"] != null && Request["del"].ToString() != "")
        {
            
            int i = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.Product.Delete(Helper.GetInt(Request["del"],0));
            }
            if (i > 0)
            {
                SetSuccess("删除产品成功！");
                Response.Redirect("ProductList.aspx");
                Response.End();
            }
        }

        initPage();

    }


    private void initPage()
    {
        if (CookieUtils.GetCookieValue("partner",key) == null || CookieUtils.GetCookieValue("partner",key) == "")
        {
            Response.Redirect(GetUrl("后台管理", "Login.aspx?type=merchant"));
            Response.End();
        }

        StringBuilder sb1 = new StringBuilder();
        sb1.Append("<tr >");
        sb1.Append("<th width='15%'>ID</th>");
        sb1.Append("<th width=\"20%\">名称</th>");
        sb1.Append("<th width=\"10%\">库存</th>");
        sb1.Append("<th width='10%' nowrap>状态</th>");
        sb1.Append("<th  width=\"20%\">备注</th>");
        sb1.Append("<th width='25%' nowrap>操作</th>");
        sb1.Append("</tr>");
        Literal1.Text = sb1.ToString();
       
        if(!string.IsNullOrEmpty(Request.QueryString["ddlStatus"]))
        {
            pfilter.Status = Helper.GetInt(Request.QueryString["ddlStatus"], 0);
            url = "&ddlStatus=" + Request.QueryString["ddlStatus"];
        }
        if (!string.IsNullOrEmpty(Request.QueryString["txtproduct"]))
        {
            pfilter.Productnamelike = Helper.GetString(Request.QueryString["txtproduct"], string.Empty);
            url += "&txtproduct=" + Request.QueryString["txtproduct"];
        }
        StringBuilder sb2 = new StringBuilder();
        url = url + "&page={0}";
        url = "ProductList.aspx?" + url.Substring(1);
        pfilter.partnerId = Helper.GetInt(CookieUtils.GetCookieValue("partner",key), 0);
        pfilter.AddSortOrder(ProductFilter.ID_DESC);
        pfilter.AddSortOrder(ProductFilter.SORTORDER_DESC);
        pfilter.PageSize = 30;
        pfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Product.GetPager(pfilter);
        }
        ilistpro = pager.Objects;
        if (ilistpro != null)
        {
            int count = 0;
                foreach ( IProduct proinfo in ilistpro )
                {
                   
                    if (count % 2 == 0)
                    {
                        sb2.Append("<tr class='alt'>");
                    }
                    else
                    {
                        sb2.Append("<tr>");
                    }
                    count++;
                    sb2.Append("<td>" + proinfo.id.ToString() + "</td>");
                    sb2.Append("<td>" + proinfo.productname.ToString() + "</td>");
                    sb2.Append("<td>" + proinfo.inventory.ToString() + "</td>");
                    if (proinfo.status.ToString() == "1")
                    {
                        sb2.Append("<td >上架</td>");
                    }
                    else if (proinfo.status.ToString() == "2")
                    {
                        sb2.Append("<td >被拒绝</td>");
                    }
                    else if (proinfo.status.ToString() == "4")
                    {
                        sb2.Append("<td >待审核</td>");
                    }
                    else if (proinfo.status.ToString() == "8")
                    {
                        sb2.Append("<td >下架</td>");
                    }
                    else if (proinfo.status.ToString() == "0")
                    {
                        sb2.Append("<td ></td>");
                    }
                    sb2.Append("<td >" + proinfo.ramark + "</td>");


                    sb2.Append("<td class='op' nowrap>");
                    sb2.Append("<a class='ajaxlink' href='" + PageValue.WebRoot + "manage/ajax_manage.aspx?action=productdetail&id=" + proinfo.id + "'>详情</a>");
                    if (proinfo.status.ToString() == "4" || proinfo.status.ToString() == "2")
                    {
                        sb2.Append(" ｜ <a class='deal-title' href='ProductAdd.aspx?id=" + proinfo.id + "'>编辑</a>");
                        sb2.Append(" ｜ <a class='deal-title' href='ProductList.aspx?del=" + proinfo.id + "'>删除</a>");

                    }
                    if (proinfo.open_invent.ToString() == "1")
                    {
                        sb2.Append(" ｜ <a class='ajaxlink' href='" + PageValue.WebRoot + "manage/ajax_coupon.aspx?action=pinvent&p=biz&inventid=" + proinfo.id + "' target='_blank'>出入库</a>");

                    }
                    sb2.Append("</td>");
                    sb2.Append("</tr>");
                   
                }
        }
        pagerhtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
        Literal2.Text = sb2.ToString();
    }
 
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
                                        产品列表</h2>
                                    <ul class="contact-filter">
                                        <li>状态：
                                            <select id="ddlStatus" name="ddlStatus" class="h-input">
                                            <option value="">请选择</option>
                                            <option value="1" <%if(Request.QueryString["ddlStatus"] == "1"){ %>selected="selected" <%} %>>上架</option>
                                            <option value="2" <%if(Request.QueryString["ddlStatus"] == "2"){ %>selected="selected" <%} %>>被拒绝</option>
                                            <option value="4" <%if(Request.QueryString["ddlStatus"] == "4"){ %>selected="selected" <%} %>>待审核</option>
                                            <option value="8" <%if(Request.QueryString["ddlStatus"] == "8"){ %>selected="selected" <%} %>>下架</option>
                                            </select>
                                            &nbsp;&nbsp; &nbsp;&nbsp;产品名称：<input type="text" id="txtproduct" name="txtproduct" class="h-input" <%if(!string.IsNullOrEmpty(Request.QueryString["txtproduct"])){ %>value="<%=Request.QueryString["txtproduct"] %>" <%} %> 
                                             />
                                            <input type="submit" id="btnselect" group="goto" value="筛选" class="formbutton validator" name="btnselect"
                                                style="padding: 1px 6px;" />
                                        </li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                       
                                        <tr>
                                            <td colspan="9">
                                            <ul class="paginator">
                                                    <li class="current">
                                                        <%= pagerhtml%>
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

