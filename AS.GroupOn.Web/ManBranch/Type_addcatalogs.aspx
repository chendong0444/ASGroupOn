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
    
    protected IPagers<ICatalogs> pager = null;
    protected ICatalogs catalogs = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected IList<ICategory> categoryslist = null;
    protected System.Data.DataTable catalogsdt = null;
    protected IList<ICatalogs> catalogslist = null;
    protected string cityid = "";//城市编号
    protected string pid = "";
    protected int parentid = 0;
    protected string cata = "";
    protected string strcitys = "";
    protected string name = "";
    protected string topnum = "6";
    protected string sort = "";
    protected string hide = "0";
    protected int host = 0;
    protected string style = "";
    protected string str1 = "";
    protected string str2 = "";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
      
        //分类
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        //分类
        catalogsfilter.type = 0;
        url = url + "&page={0}";
        url = "Type_addcatalogs.aspx?" + url.Substring(1);
        catalogsfilter.PageSize = 30;
        catalogsfilter.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
        catalogsfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        catalogsfilter.cityid =","+AsAdmin.City_id+","; 
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Catalogs.GetPager(catalogsfilter);
        }
        catalogslist = pager.Objects;
        System.Data.DataTable dt = AS.Common.Utils.Helper.ToDataTable(catalogslist.ToList());
        if (Request["id"] != null)
        {

            hid.Value = (Request["id"]);
            GetCata(AS.Common.Utils.Helper.GetInt(Request["id"], 0));
        }
        if (Request["button"] == "确定")
        {
            AddCataLogs();
            Response.Redirect("Type_catalogs.aspx");

        }
        if (!IsPostBack)
        {

            ddlparent.Items.Add(new ListItem("顶级分类", "0,a"));
            if (dt.Rows.Count>0)
            {
                 BindData(dt, 0, "");
            }
           
        }
        setcity();
        xianshiyincang();
    }

    private void hiden(object sender, EventArgs e)
    {
        xianshiyincang();
    }

    private void xianshiyincang()
    {
        if (this.ddlparent.SelectedValue.Contains(",a"))
        {
            StringBuilder sb1 = new StringBuilder();

            sb1.Append("<tr id='city'" + style + "><td width='120' style='padding-right:10px; text-align:right;' ><b>输出城市：</b></td><td> " + strcitys + "</td></tr>");

            str1 = sb1.ToString();

            StringBuilder sb2 = new StringBuilder();
            sb2.Append("<tr id='s' " + style + "><td width='120' style='padding-right:10px; text-align:right;' ><b>分类是否显示：</b></td><td><select id='state' name='state'>");

            if (hide == "0")
            {
                sb2.Append("<option value='0' selected='selected'>是</option>");
                sb2.Append("<option value='1'>否</option>");
            }
            else
            {
                sb2.Append(" <option value='0'>是</option>");
                sb2.Append("<option value='1' selected='selected'>否</option>");
            }
            sb2.Append("'</select></td> </tr><tr id='h'" + style + "> <td width='120' style='padding-right:10px; text-align:right;' nowrap>  <b>是否主推到首页：</b>  </td>    <td> <select id='host1' name='host'>");
            if (host == 0)
            {
                sb2.Append("<option value='0' selected='selected'>是</option><option value='1'>否</option>");
            }
            else
            {
                sb2.Append("<option value='0'>是</option><option value='1' selected='selected'>否</option>");
            }
            sb2.Append("</select></td> </tr> <tr id='t' " + style + "> <td width='120' style='padding-right:10px; text-align:right;' nowrap><b>首页主推个数：</b> </td><td> <input group='a' type='text' name='topsum' id='topsum'require='true'datatype='number'class='f-input' value=" + topnum + " /></td></tr>");
            str2 = sb2.ToString();
        }
        else
        {
            str1 = "";
            str2 = "";
        }
    }
    /// <summary>
    /// 绑定分类
    /// </summary>
    /// <param name="dt"></param>
    /// <param name="id"></param>
    /// <param name="blank"></param>
    private void BindData(System.Data.DataTable dt, int id, string blank)
    {

        if (dt != null && dt.Rows.Count > 0)
        {
            System.Data.DataView dv = new System.Data.DataView(dt);
            dv.RowFilter = "parent_id = " + id.ToString();


            if (id != 0)
            {
                blank += "|─";
            }

            foreach (System.Data.DataRowView drv in dv)
            {
                if (parentid == AS.Common.Utils.Helper.GetInt(drv["id"], 0))
                {
                    if (!pid.Contains("," + drv["id"].ToString() + ","))
                    {
                        this.ddlparent.Items.Add(new ListItem(blank + "" + drv["catalogname"].ToString(), drv["id"] + "," + drv["parent_id"]));
                        ddlparent.SelectedValue = drv["id"] + "," + drv["parent_id"];
                    }
                }
                else
                {
                    if (!pid.Contains("," + drv["id"].ToString() + ","))
                    {
                        this.ddlparent.Items.Add(new ListItem(blank + "" + drv["catalogname"].ToString(), drv["id"] + "," + drv["parent_id"]));
                    }
                }
                BindData(dt, Convert.ToInt32(drv["id"]), blank);
            }
        }
    }

    /// <summary>
    /// 城市
    /// </summary>
    private void setcity()
    {
        StringBuilder sb1 = new StringBuilder();
        ICategory cateby = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            cateby = session.Category.GetByID(AsAdmin.City_id);
        }
        sb1.Append("<input type='checkbox' checked='checked'   name='city_id' value='" + cateby.Id + "' disabled='disabled' />&nbsp;" + cateby.Name + "&nbsp;&nbsp;");
        strcitys = sb1.ToString();
    }

    /// <summary>
    /// 根据编号显示目录
    /// </summary>
    public void GetCata(int id)
    {
        CatalogsFilter cataloggilter = new CatalogsFilter();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            catalogs = session.Catalogs.GetByID(id);
        }
        if (catalogs != null)
        {
            name = catalogs.catalogname;
            sort = catalogs.sort_order.ToString();
            parentid = catalogs.parent_id;
            keyword.Value = catalogs.keyword;
            topnum = catalogs.keytop.ToString();
            hide = catalogs.visibility.ToString();
            host = catalogs.catahost;
            cityid = catalogs.cityid;
            pid = "," + catalogs.ids + "," + catalogs.id + ",";
            if (catalogs.parent_id != 0)
            {
                style = "style='display:none'";
            }

        }
    }
    #region 添加项目的分类
    public void AddCataLogs()
    {

        ICatalogs catas = null;
        CatalogsFilter catafilter = new CatalogsFilter();
        IList<ICatalogs> listcata = null;
        catafilter.AddSortOrder(CatalogsFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listcata = session.Catalogs.GetList(catafilter);
        }
        System.Data.DataTable dt = null;
        dt = AS.Common.Utils.Helper.ToDataTable(listcata.ToList());
        #region 新增项目的额分类
        if (hid.Value != "")
        {
            ICatalogs catamodel = AS.GroupOn.App.Store.CreateCatalogs();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                catamodel = session.Catalogs.GetByID(AS.Common.Utils.Helper.GetInt(hid.Value, 0));
            }
            catamodel.catalogname = Request["child"];

            catamodel.sort_order = AS.Common.Utils.Helper.GetInt(Request["sort"], 0);
            if (Request.Form["keyword"] != null)
            {

                catamodel.keyword = Request.Form["keyword"];
            }
            catamodel.keytop = AS.Common.Utils.Helper.GetInt(Request["topsum"], 0);//显示个数
            catamodel.visibility = AS.Common.Utils.Helper.GetInt(Request["state"], 0);//状态是否显示
            catamodel.catahost = AS.Common.Utils.Helper.GetInt(Request["host"], 0);//类别是否主推

            string blank = "";

            #region 删除目录下面的子编号
            if (catamodel.parent_id != AS.Common.Utils.Helper.GetInt(Request["ddlparent"].ToString().Split(',')[0], 0))
            {
                Delete(dt, catamodel.parent_id, "", catamodel.id);
            }
            #endregion


            catamodel.parent_id = AS.Common.Utils.Helper.GetInt(Request["ddlparent"].ToString().Split(',')[0], 0);
            catamodel.cityid = "," + AsAdmin.City_id + ",";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int idd = session.Catalogs.Update(catamodel);
            }

            #region 记录跟目录下面的子id
            ICatalogs cataparten = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                cataparten = session.Catalogs.GetByID(AS.Common.Utils.Helper.GetInt(Request["ddlparent"].ToString().Split(',')[0], 0));
            }
            if (cataparten != null)
            {
                if (!cataparten.ids.Contains(AS.Common.Utils.Helper.GetInt(hid.Value, 0).ToString()))
                {
                    cataparten.ids += "," + AS.Common.Utils.Helper.GetInt(hid.Value, 0);
                    if (cataparten.ids != "")
                    {
                        catamodel.ids += "," + cataparten.ids;
                    }
                    if (AS.Common.Utils.Helper.GetString(catamodel.ids, "") != "")
                    {
                        if (AS.Common.Utils.Helper.GetString(catamodel.ids, "").Substring(0, 1) == ",")
                        {
                            catamodel.ids = catamodel.ids.Substring(1, catamodel.ids.Length - 1);
                        }
                    }
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int iddd = session.Catalogs.Update(catamodel);
                    }
                    Update(dt, catamodel.parent_id, "", AS.Common.Utils.Helper.GetInt(hid.Value, 0));
                }
            }
            #endregion

        }
        else
        {
            ICatalogs catamodel = AS.GroupOn.App.Store.CreateCatalogs();
            catamodel.catalogname = Request["child"];
            CatalogsFilter cataft = new CatalogsFilter();
            IList<ICatalogs> catalis = null;
            
            cataft.catalogname = catamodel.catalogname.Trim();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                catalis = session.Catalogs.GetList(cataft);
            }
            if (catalis.Count > 0)
            {
                SetError("分类中已包含此分类，请勿重复添加");
                Response.Redirect("Type_catalogs.aspx");
                Response.End();
            }
            catamodel.parent_id = AS.Common.Utils.Helper.GetInt(Request["ddlparent"].Split(',')[0], 0);
            catamodel.sort_order = AS.Common.Utils.Helper.GetInt(Request["sort"], 0);
            if (Request.Form["keyword"] != null)
            {

                catamodel.keyword = Request.Form["keyword"];
            }

            catamodel.keytop = AS.Common.Utils.Helper.GetInt(Request["topsum"], 0);//显示个数
            catamodel.visibility = AS.Common.Utils.Helper.GetInt(Request["state"], 0);//状态是否显示
            catamodel.catahost = AS.Common.Utils.Helper.GetInt(Request["host"], 0);//类别是否主推
            catamodel.cityid = "," + AsAdmin.City_id + ",";
        #endregion

            #region 记录跟目录下面的子id
            //CatalogsFilter cataft = new CatalogsFilter();
            //cataft.parent_id = catamodel.parent_id;
            //cataft.AddSortOrder(CatalogsFilter.ID_DESC);
            //using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            //{
            //    catamodel = session.Catalogs.Get(cataft);
            //}
            if (catamodel != null)
            {
                catamodel.ids += "," + catamodel.id;
                if (AS.Common.Utils.Helper.GetString(catamodel.ids, "") != "")
                {
                    if (AS.Common.Utils.Helper.GetString(catamodel.ids, "").Substring(0, 1) == ",")
                    {
                        catamodel.ids = catamodel.ids.Substring(1, catamodel.ids.Length - 1);
                    }
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int id1 = session.Catalogs.Update(catamodel);
                }

                Update(dt, catamodel.parent_id, "", catamodel.id);
            }

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int id1 = session.Catalogs.Insert(catamodel);
            }
            #endregion


        }
    }
    #endregion
    public void Delete(System.Data.DataTable dt, int id, string blank, int cid)
    {
        ICatalogs cata2 = null;
        ICatalogs catas = null;
        System.Data.DataView dv = new System.Data.DataView(dt);
        dv.RowFilter = "id = " + id.ToString();
        if (id != 0)
        {
            blank += "|─";
        }

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            catas = session.Catalogs.GetByID(id);
            cata2 = session.Catalogs.GetByID(cid);
        }
        foreach (System.Data.DataRowView drv in dv)
        {
            if (catas != null)
            {
                catas.ids = catas.ids.Replace("," + cid.ToString(), "").Replace(cid.ToString(), "");
                if (cata2.ids != "")
                {
                    string[] strcata = cata2.ids.Split(',');
                    for (int i = 0; i < strcata.Length; i++)
                    {
                        catas.ids = catas.ids.Replace("," + strcata[i], "").Replace(strcata[i], "");
                    }
                }
                if (AS.Common.Utils.Helper.GetString(catas.ids, "") != "")
                {
                    if (AS.Common.Utils.Helper.GetString(catas.ids, "").Substring(0, 1) == ",")
                    {
                        catas.ids = catas.ids.Substring(1, catas.ids.Length - 1);
                    }
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int id2 = session.Catalogs.Update(catas);
                }
            }
            Delete(dt, Convert.ToInt32(drv["parent_id"]), blank, cid);
        }
    }
    private void Update(System.Data.DataTable dt, int id, string blank, int cid)
    {
        ICatalogs catamodel = null;
        ICatalogs catas = null;
        System.Data.DataView dv = new System.Data.DataView(dt);
        dv.RowFilter = "id = " + id.ToString();
        if (id != 0)
        {
            blank += "|─";
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            catas = session.Catalogs.GetByID(id);
            catamodel = session.Catalogs.GetByID(cid);
        }
        foreach (System.Data.DataRowView drv in dv)
        {
            if (catas != null)
            {
                catas.ids += "," + cid;
                if (AS.Common.Utils.Helper.GetString(catas.ids, "") != "")
                {
                    if (AS.Common.Utils.Helper.GetString(catas.ids, "").Substring(0, 1) == ",")
                    {
                        catas.ids = catas.ids.Substring(1, catas.ids.Length - 1);
                    }
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int iddd = session.Catalogs.Update(catas);
                }
            }
            Update(dt, Convert.ToInt32(drv["parent_id"]), blank, cid);
        }
    }
</script>
<script type="text/javascript">
    function hideon(obj) {
        if (obj != "1") {
            $("#s").hide();
            $("#t").hide();
            $("#h").hide();
            $("#city").hide();

        } else if (obj == "2") {
            $("#s").show();
            $("#t").show();
            $("#h").show();
            $("#city").show();

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
                                        项目分类</h2>
                                </div>
                                <input type='hidden' name='action' value='addcatalogs' />
                                <div class="sect">
                                    <table width="96%" class="orders-list">
                                        <tr>
                                            <td width="120" style="padding-right:10px; text-align:right;" nowrap>
                                                <b>顶级分类：</b>
                                            </td>
                                            <td>
                                                <input id="hid" type="hidden" runat="server" />
                                                <asp:DropDownList CssClass="h-input" ID="ddlparent" runat="server" AutoPostBack="true" OnSelectedIndexChanged="hiden">
                                                </asp:DropDownList>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="120" style="padding-right:10px; text-align:right;" nowrap>
                                                <b>分类名称：</b>
                                            </td>
                                            <td>
                                                <input group="a" type="text" name="child" id="child" require="true" datatype="require"
                                                    class="f-input" value='<%=name %>' />
                                            </td>
                                        </tr>
                                        <%=str1 %>
                                        <tr>
                                            <td width="120" style="padding-right:10px; text-align:right;" nowrap>
                                                <b>排序：</b>
                                            </td>
                                            <td>
                                                <input group="a" type="text" name="sort" id="sort" require="true" datatype="number"
                                                    class="f-input" value='<%=sort %>' />
                                            </td>
                                        </tr>
                                        <%=str2 %>
                                        <tr>
                                            <td width="120" style="padding-right:10px; text-align:right;"  nowrap>
                                                <b>关键字：</b>
                                            </td>
                                            <td>
                                                <textarea id="keyword" name="keyword" cols="60" rows="7" class="f-input" runat="server"></textarea>
                                                </td>
                                        </tr>
                                        <tr>
                                            <td>
                                            </td>
                                            <td>
                                                <font style="color: red">关键字以英文版的逗号分隔符隔开，比如：游泳,跑步,娱乐
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                            </td>
                                            <td>
                                                <input type="hidden" id="citys" runat="server" />
                                                <input type="submit" name="button" group="a" class="formbutton validator" value="确定" />
                                            </td>
                                        </tr>
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
    </form>
</body>
<%LoadUserControl("_footer.ascx", null); %>
