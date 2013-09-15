<%@ Page Language="C#" AutoEventWireup="true"  Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<script runat="server">
    
    protected IPagers<ICatalogs> pager = null;

    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected System.Data.DataTable catalogsdt = null;
    protected IList<ICatalogs> catalogslist = null;
    protected StringBuilder sb2 = new StringBuilder();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_MallTeamCata_ListView))
        {
            SetError("你不具有查看商城分类列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        //分类
        CatalogsFilter catalogsfilter = new CatalogsFilter();

        #region 删除动作
        if (Request["id"] != null)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_MallTeamCata_Delete))
            {
                SetError("你不具有删除商城项目分类的权限！");
                Response.Redirect("mall_catalogs.aspx");
                Response.End();
                return;
            }
            Delete(AS.Common.Utils.Helper.GetInt(Request["id"], 0));
        }
        #endregion

        if (Request.Form["btn"] == "筛选")
        {
            if (this.txtcatename.Text != null)
            {
                if (this.txtcatename.Text != "" && this.txtcatename.Text != null)
                {
                    if (Request["text"]!=null&& Request["text"]!="")
                    {
                        catalogsfilter.catalognameLike = Request["text"].ToString();
                    }
                    else
                    {
                        catalogsfilter.catalognameLike = this.txtcatename.Text;
                    }                    
                    url += "&text=" + this.txtcatename.Text;
                    Literal2.Text = null;
                }

            }
        }
        //分类
        catalogsfilter.type = 1;
        url = url + "&page={0}";
        url = "mall_catalogs.aspx?" + url.Substring(1);
        catalogsfilter.PageSize = 30;
        catalogsfilter.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
        catalogsfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Catalogs.GetPager(catalogsfilter);
        }
        catalogslist = pager.Objects;
        BindData(catalogslist, 0, "");
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }
    public void BindData(IList<ICatalogs> catalist, int id, string blank)
    {
        CatalogsFilter cf = new CatalogsFilter();
        IList<ICatalogs> list = null;
        if (catalist != null && catalist.Count > 0)
        {
            cf.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
            cf.type = 1;
            if (id != 0)
                cf.parent_id = id;
            else
                cf.parent_id = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                list = session.Catalogs.GetList(cf);
            }
            if (id != 0)
                blank += "|─";
            if (list != null && list.Count > 0)
            {
                foreach (ICatalogs c in list)
                {
                    if (c.parent_id == 0)
                        sb2.Append("<tr class='alt'>");
                    else
                        sb2.Append("<tr>");
                    sb2.Append("<td>" + c.id + "</td>");
                    sb2.Append("<td>" + blank + c.catalogname + "</td>");
                    sb2.Append("<td>" + c.sort_order + "</td>");
                    sb2.Append("<td>" + c.parent_id + "</td>");
                    if (c.visibility == 0)
                        sb2.Append("<td>显示</td>");
                    else
                        sb2.Append("<td>隐藏</td>");

                    if (c.catahost == 0)
                        sb2.Append("<td>主推</td>");
                    else
                        sb2.Append("<td></td>");

                    sb2.Append("<td class='op'>");
                    sb2.Append("<a  href='mall_addcatalogs.aspx?id=" + c.id + "'>编辑</a>｜");
                    sb2.Append("<a  href='mall_catalogs.aspx?id=" + c.id + "'   ask='确认删除吗？'>删除</a>");
                    sb2.Append("</td>");
                    sb2.Append("</tr>");
                    BindData(list, c.id, blank);
                }
                Literal2.Text = sb2.ToString();
            }
        }
    }
    //根据编号删除分类
    public void Delete(int id)
    {
        CatalogsFilter cataft = new CatalogsFilter();
        cataft.parent_id = id;
        ICatalogs cata = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            cata = session.Catalogs.Get(cataft);
        }
        if (cata != null)
        {
            SetError("友情提示：此类下面有子类，无法删除");
        }
        else
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int idd = session.Catalogs.Delete(id);
            }
            SetSuccess("友情提示：删除成功");
            Response.Redirect("mall_catalogs.aspx");
        }
    }
    public string GetCity(string cityid)
    {
        string mailcitys = String.Empty;
        if (cityid.Length > 0)
        {
            string[] mail = cityid.Split(',');

            for (int j = 0; j < mail.Length; j++)
            {
                ICategory catemodel = null;
                CategoryFilter catefilter = new CategoryFilter();

                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    catemodel = session.Category.GetByID(AS.Common.Utils.Helper.GetInt(mail[j], 0));
                }

                if (catemodel != null)
                {
                    mailcitys = mailcitys + catemodel.Name + ",";
                }
                else
                {
                    if (!mailcitys.Contains("全部城市"))
                    {
                        if (mail[j] == "0")
                        {
                            mailcitys = mailcitys + "全部城市,";
                        }
                    }

                }
            }
        }
        else
        {
            mailcitys = "全部城市";
        }
        return mailcitys;
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
                                        商城分类</h2>
                                    <form id="Form2" runat="server">
                                    <div class="search">
                                        &nbsp;&nbsp; 父类名：<asp:TextBox class="h-input" ID="txtcatename" runat="server"></asp:TextBox><input
                                            id="btn" type="submit" group="a" value="筛选" name="btn" class="formbutton validator"
                                            style="padding: 1px 6px;" />
                                        <ul class="filter">
                                            <li><a href="mall_addcatalogs.aspx">新建商城分类</a></li>
                                        </ul>
                                    </div>
                                    </form>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='10%'>
                                                ID
                                            </th>
                                            <th width='20%'>
                                                分类名称
                                            </th>
                                            <th width='10%'>
                                                排序
                                            </th>
                                            <th width='15%'>
                                                父ID
                                            </th>
                                            <th width='15%'>
                                                状态
                                            </th>
                                            <th width='15%'>
                                                是否主推
                                            </th>
                                            <th width='10%'>
                                                操作
                                            </th>
                                        </tr>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
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
    </div>
</body>
<%LoadUserControl("_footer.ascx", null); %>