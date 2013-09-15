<%@ Page Language="C#"  AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<script runat="server">
    protected IPagers<ICatalogs> pager = null;
    protected ICatalogs catalogs = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected IList<ICity> citylist = null;
    protected System.Data.DataTable catalogsdt = null;
    protected IList<ICatalogs> catalogslist = null;
    protected string cityid = "";//城市编号
    protected int parentid = 0;
    protected string cata = "";
    protected string strcitys = "";
    protected string name = "";
    protected string topnum = "6";
    protected string sort = "";
    protected string hide = "0";
    protected int host = 0;
    protected string style = "";
    protected string citystr = "";
    protected string idsstr = "";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Team_Add)) 
        {
            SetError("你不具有新建项目分类的权限");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        
        if (Request["button"] == "确定")
        {
            AddCataLogs();
        }
        if (!IsPostBack)
        {
            ICatalogs cmodel = null;
            if (Request["id"] != null)
            {
                hid.Value = Request["id"];
                GetCata(Helper.GetInt(Request["id"], 0));
                using (IDataSession session = Store.OpenSession(false))
                {
                    cmodel = session.Catalogs.GetByID(Helper.GetInt(Request["id"], 0));
                }
            }
            BindData(0, "");
            setcity();
        }
    }
    /// <summary>
    /// 城市
    /// </summary>
    private void setcity()
    {
        StringBuilder sb1 = new StringBuilder();
        if (cityid != "")
        {
            if (cityid.Contains(",0,"))
            {
                sb1.Append("<input type='checkbox' name='cityall' id='cityall' value='0' checked='checked'  onclick='checkallcity()'/>全部城市");
            }
            else
            {
                sb1.Append("<input type='checkbox' name='cityall' id='cityall' value='0'  onclick='checkallcity()'/>全部城市");
            }
        }
        else
        {
            sb1.Append("<input type='checkbox' name='cityall' id='cityall' value='0' checked='checked' onclick='checkallcity()'/>全部城市");
        }
        CityFilter cf = new CityFilter();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            citylist = session.Citys.GetList(cf);
        }
        foreach (var item in citylist)
        {
            if (cityid.Contains(item.Id.ToString()))
            {
                sb1.Append("<input type='checkbox' name='city_id' value='" + item.Id + "'  checked='checked'/>&nbsp;" + item.Name + "&nbsp;&nbsp;");
            }
            else
            {
                sb1.Append("<input type='checkbox' name='city_id' value='" + item.Id + "' disabled=disabled />&nbsp;" + item.Name + "&nbsp;&nbsp;");
            }
        }
        citystr = sb1.ToString();
    }
    public void BindData(int id, string blank)
    {
        CatalogsFilter cf = new CatalogsFilter();
        cf.type = 0;
        cf.parent_id = id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            catalogslist = session.Catalogs.GetList(cf);
        }
        if (catalogslist != null && catalogslist.Count > 0)
        {
            if (id != 0)
                blank += "|─";
            foreach (var item in catalogslist)
            {
                if (item.id == parentid)
                    cata += " <option value=" + item.id + "," + item.parent_id + " selected=selected  >" + blank + "" + item.catalogname + "</option>";
                else
                    cata += " <option value=" + item.id + "," + item.parent_id + ">" + blank + "" + item.catalogname + "</option>";
                BindData(item.id, blank);
            }
        }
    }
    /// <summary>
    /// 根据编号显示目录
    /// </summary>
    public void GetCata(int id)
    {
        if (!IsPostBack)
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
                //pid = "," + catalogs.ids + "," + catalogs.id + ",";
                if (catalogs.parent_id != 0)
                {
                    style = "style='display:none'";
                }
            }
        }
    }
    public void AddCataLogs()
    {
        int parentid = 0;
        parentid = Helper.GetInt(Request["parent"].ToString().Split(',')[0], 0);
        if (hid.Value != "")//更新
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Team_Edit))
            {
                SetError("你不具有编辑项目分类的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
            int cataid = Helper.GetInt(hid.Value, 0);
            if (cataid != 0)
            {
                ICatalogs catamodel = AS.GroupOn.App.Store.CreateCatalogs();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    catamodel = session.Catalogs.GetByID(cataid);
                }
                catamodel.catalogname = Request["child"];
                catamodel.sort_order = AS.Common.Utils.Helper.GetInt(Request["sort"], 0);
                catamodel.keyword = this.keyword.InnerText;
                catamodel.type = 0;
                catamodel.parent_id = parentid;
                if (parentid == 0)//顶级分类
                {
                    catamodel.keyword = this.keyword.InnerText;
                    catamodel.cityid = "," + Request["cityall"] + "," + Request["city_id"] + ",";
                    catamodel.visibility = Helper.GetInt(Request["state"], 0);//状态是否显示
                    catamodel.keytop = Helper.GetInt(Request["topsum"], 0);//显示个数
                    catamodel.catahost = Helper.GetInt(Request["host"], 0);//类别是否主推
                }
                using (IDataSession session = Store.OpenSession(false))
                {
                    session.Catalogs.Update(catamodel);
                }
                IList<ICatalogs> listodel = null;
                CatalogsFilter cf = new CatalogsFilter();
                cf.type = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    listodel = session.Catalogs.GetList(cf);
                }
                foreach (var item in listodel)
                {
                    Update(item.id);//更新所有二级分类IDS
                }
                UpdatePart();//更新顶级分类IDS
                SetSuccess("友情提示：更新成功！");
                Response.Redirect("Type_catalogs.aspx");
            }
        }
        else//新增
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Team_Add))
            {
                SetError("你不具有新建项目分类列表的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
            ICatalogs catamodel = Store.CreateCatalogs();
            CatalogsFilter cataft = new CatalogsFilter();
            IList<ICatalogs> catalis = null;
            catamodel.catalogname = Request["child"];
            cataft.catalogname = catamodel.catalogname.Trim();
            cataft.type = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                catalis = session.Catalogs.GetList(cataft);
            }
            if (catalis.Count>0)
            {
                SetError("分类中已包含此分类，请勿重复添加");
                Response.Redirect("Type_catalogs.aspx");
                Response.End();
            }
            catamodel.sort_order = Helper.GetInt(Request["sort"], 0);
            catamodel.parent_id = Helper.GetInt(Request["parent"].Split(',')[0], 0);
            catamodel.keyword = this.keyword.InnerText;
            catamodel.ids = "";
            if (Request["cityall"] != "" || Request["city_id"] != "")
            {
                catamodel.cityid = "," + Request["cityall"] + "," + Request["city_id"] + ",";
            }
            else
            {
                catamodel.cityid = null;
            }
            catamodel.visibility = Helper.GetInt(Request["state"], 0);//状态是否显示
            if (parentid == 0)//顶级分类
            {
                catamodel.keytop = Helper.GetInt(Request["topsum"], 0);//显示个数
                catamodel.catahost = Helper.GetInt(Request["host"], 0);//类别是否主推
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Catalogs.Insert(catamodel);
                }
                IList<ICatalogs> listodel = null;
                CatalogsFilter cf = new CatalogsFilter();
                cf.type = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    listodel = session.Catalogs.GetList(cf);
                }
                foreach (var item in listodel)
                {
                    Update(item.id);//更新所有二级分类IDS
                }
                UpdatePart();//更新顶级分类IDS
                SetSuccess("友情提示：添加成功！");
                Response.Redirect("Type_catalogs.aspx");
            }
            else//子分类
            {
                ICatalogs smallcata = null;
                int ids = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    smallcata = session.Catalogs.GetByID(parentid);
                    if (smallcata != null)
                    {
                        catamodel.cityid = smallcata.cityid;
                        catamodel.visibility = smallcata.visibility;
                        catamodel.catahost = smallcata.catahost;
                    }
                    ids = session.Catalogs.Insert(catamodel);
                }
                if (ids > 0)
                {
                    IList<ICatalogs> listodel = null;
                    CatalogsFilter cf = new CatalogsFilter();
                    cf.type = 0;
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        listodel = session.Catalogs.GetList(cf);
                    }
                    foreach (var item in listodel)
                    {
                        Update(item.id);//更新所有二级分类IDS
                    }
                    UpdatePart();//更新顶级分类IDS
                }
                SetSuccess("友情提示：添加成功！");
                Response.Redirect("Type_catalogs.aspx");
            }
        }
    }

    private void UpdatePart()
    {
        ICatalogs model = null;
        IList<ICatalogs> listodel = null;
        CatalogsFilter cf = new CatalogsFilter();
        cf.type = 0;
        cf.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listodel = session.Catalogs.GetList(cf);
        }
        foreach (var item in listodel)
        {
            if (item.ids != null || item.ids != String.Empty)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    model = session.Catalogs.GetByID(item.parent_id);
                    if (model != null)
                    {
                        if (!model.ids.Contains(item.ids.ToString()))
                        {
                            model.ids += "," + item.ids;
                            session.Catalogs.Update(model);
                        }
                    }
                }
            }
        }
    }
    private void Update(int id)
    {
        ICatalogs model = null;
        IList<ICatalogs> listodel = null;
        CatalogsFilter cf = new CatalogsFilter();
        cf.parent_id = id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listodel = session.Catalogs.GetList(cf);
            model = session.Catalogs.GetByID(id);
            model.ids = String.Empty;
            session.Catalogs.Update(model);
        }
        string ids = String.Empty;
        foreach (var item in listodel)
        {
            item.visibility = model.visibility;
            item.catahost = model.catahost;
            item.cityid = model.cityid;
            if (!item.ids.Contains(item.id.ToString()))
            {
                ids += item.id.ToString() + ",";
            }
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                session.Catalogs.Update(item);
            }
        }
        if (ids != String.Empty)
        {
            model.ids = ids.TrimEnd(',');
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                session.Catalogs.Update(model);
            }
        }
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    function checkallcity() {
        var str = $("#cityall").attr('checked');
        if (str) {
            $('[name=city_id]').attr('checked', false);
            $('[name=city_id]').attr('disabled', true);
        }
        else {
            $('[name=city_id]').attr('disabled', false);
        }
    }
    function hideon(obj) {
        var num = new Array();
        num = obj.value.split(",");
        if (num[1] != "a") {
            $("#s").hide();
            $("#t").hide();
            $("#h").hide();
            $("#city").hide();

        } else if (num[1] == "a") {
            $("#s").show();
            $("#t").show();
            $("#h").show();
            $("#city").show();
        }
    }
</script>
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
                                        <h2>项目分类</h2>
                                    </div>
                                    <input type='hidden' name='action' value='addcatalogs' />
                                    <div class="sect">
                                        <table width="96%" class="orders-list">
                                          
                                            <tr>
                                                <td width="120" style='text-align: right; padding-right: 10px;'>
                                                    <b>顶级分类：</b>
                                                </td>
                                                <td>
                                                    <input id="hid" type="hidden" runat="server" />
                                                    <select id="parent" class="f-input" name="parent" onchange="hideon(this)">
                                                        <option value="0,a">顶级分类</option>
                                                        <%=cata%>
                                                    </select>
                                                </td>
                                            </tr>
                                           

                                            <tr>
                                                <td width="120" style='text-align: right; padding-right: 10px;'>
                                                    <b>分类名称：</b>
                                                </td>
                                                <td>
                                                    <input group="a" type="text" name="child" id="child" require="true" datatype="require"
                                                        class="f-input" value='<%=name %>' />
                                                </td>
                                            </tr>

                                            <tr id="city" <%=style %>>
                                                <td width="120" style='text-align: right; padding-right: 10px;' nowrap><b>输出城市：</b></td>
                                                <td>
                                                    <%=citystr%>
                                                </td>
                                            </tr>
                                            <tr id="s" <%=style %>>
                                                <td width="120" style='text-align: right; padding-right: 10px;'><b>分类是否显示：</b></td>
                                                <td>

                                                    <select id="state" name="state">
                                                        <%if (hide == "0")
                                                          { %>
                                                        <option value="0" selected="selected">是</option>
                                                        <option value="1">否</option>
                                                        <% }
                                                          else
                                                          {%>
                                                        <option value="0">是</option>
                                                        <option value="1" selected="selected">否</option>
                                                        <% }%>
                                                    </select>
                                                </td>
                                            </tr>
                                            <tr id="h" <%=style %>>
                                                <td width="120" style='text-align: right; padding-right: 10px;'><b>是否主推到首页：</b></td>
                                                <td>

                                                    <select id="host1" name="host">
                                                        <%if (host == 0)
                                                          { %>
                                                        <option value="0" selected="selected">是</option>
                                                        <option value="1">否</option>
                                                        <% }
                                                          else
                                                          {%>
                                                        <option value="0">是</option>
                                                        <option value="1" selected="selected">否</option>
                                                        <% }%>
                                                    </select>
                                                </td>
                                            </tr>
                                            <tr id="t" <%=style %>>
                                                <td width="120" style='text-align: right; padding-right: 10px;'><b>首页主推个数：</b></td>
                                                <td>
                                                    <input group="a" type="text" name="topsum" id="topsum" require="true" datatype="number" class="f-input" value='<%=topnum %>' /></td>
                                            </tr>
                                            <tr>
                                                <td width="120" style='text-align: right; padding-right: 10px;'><b>排序：</b></td>
                                                <td>
                                                    <input group="a" type="text" name="sort" id="sort" require="true" datatype="number" class="f-input" value='<%=sort %>' /></td>
                                            </tr>
                                            <tr>
                                                <td width="120" style='text-align: right; padding-right: 10px;' nowrap>
                                                    <b>关键字：</b>
                                                </td>
                                                <td>
                                                    <textarea id="keyword" name="keyword" cols="60" rows="7" class="f-input" runat="server"></textarea>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                                <td>
                                                    <font style="color: red">关键字以英文版的逗号分隔符隔开，比如：游泳,跑步,娱乐</font>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
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
</html>