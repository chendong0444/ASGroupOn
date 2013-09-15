<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    protected IPagers<ICatalogs> pager = null;
    protected ICatalogs catalogs = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected System.Collections.Generic.IList<ICategory> categoryslist = null;
    protected System.Data.DataTable catalogsdt = null;
    protected System.Collections.Generic.IList<ICatalogs> catalogslist = null;
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
    protected int location = 0;
    public NameValueCollection _system = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //分类
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        //分类
        catalogsfilter.type = 1;
        url = url + "&page={0}";
        url = "mall_addcatalogs.aspx?" + url.Substring(1);
        catalogsfilter.PageSize = 30;
        catalogsfilter.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
        catalogsfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        catalogsfilter.cityid = "," + AsAdmin.City_id.ToString() + ",";
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
            Response.Redirect("mall_catalogs.aspx");
        }
        if (!IsPostBack)
        {
            BindData(dt, 0, "");
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
                        cata += " <option value=" + drv["id"] + "," + drv["parent_id"] + " selected=selected  >" + blank + "" + drv["catalogname"].ToString() + "</option>";
                    }
                }
                else
                {
                    if (!pid.Contains("," + drv["id"].ToString() + ","))
                    {
                        cata += " <option value=" + drv["id"] + "," + drv["parent_id"] + " >" + blank + "" + drv["catalogname"].ToString() + "</option>";
                    }
                }
                BindData(dt, Convert.ToInt32(drv["id"]), blank);
            }
        }
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
            topnum = catalogs.keytop.ToString();
            hide = catalogs.visibility.ToString();
            host = catalogs.catahost;
            location = catalogs.location;
            cityid = catalogs.cityid;
            lblImg1.InnerText = catalogs.image;
            txturl.Value = catalogs.url;
            pid = "," + catalogs.ids + "," + catalogs.id + ",";
            if (catalogs.parent_id != 0)
            {
                style = "style='display:none'";
            }

        }
    }
    #region 添加项目的分类
    protected string createUpload = "";
    public void AddCataLogs()
    {
        ICatalogs catas = null;
        CatalogsFilter catafilter = new CatalogsFilter();
        IList<ICatalogs> listcata = null;
        catafilter.AddSortOrder(CatalogsFilter.ID_DESC);
        catafilter.cityid = "," + AsAdmin.City_id + ",";
        catafilter.type = 1;
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

            if (Image1.FileName != null)
            {
                createUpload = setUpload();
            }
            if (Image1.FileName != null && Image1.FileName != "")
            {
                #region 上传图片

                //判断上传文件的大小
                if (Image1.PostedFile.ContentLength > 512000)
                {
                    SetError("请上传 512KB 以内的图片!");
                    return;
                }//如果文件大于512kb，则不允许上传

                string uploadName = Image1.FileName;//获取待上传图片的完整路径，包括文件名 
                //string uploadName = InputFile.PostedFile.FileName; 
                string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
                if (Image1.FileName != "")
                {
                    int idx = uploadName.LastIndexOf(".");
                    string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                    if (suffix.ToLower() == ".jpg" || suffix.ToLower() == ".png" || suffix.ToLower() == ".gif" || suffix.ToLower() == ".jpeg" || suffix.ToLower() == ".bmp")
                    {
                        pictureName = DateTime.Now.Ticks.ToString() + suffix;
                    }
                    else
                    {
                        SetError("图片格式不正确！");
                        Response.Redirect("Commodity_add.aspx");
                        return;
                    }

                }
                try
                {
                    if (uploadName != "")
                    {
                        string path = Server.MapPath(createUpload);
                        if (!Directory.Exists(path))
                        {
                            Directory.CreateDirectory(path);

                        }

                        Image1.PostedFile.SaveAs(path + pictureName);

                        //生成缩略图
                        string strOldUrl = path + pictureName;
                        string strNewUrl = path + "small_" + pictureName;
                        AS.Common.Utils.ImageHelper.CreateThumbnailNobackcolor(strOldUrl, strNewUrl, 199, 425);

                        //图片加水印
                        string drawuse = "";
                        string drawimgType = "";
                        AS.Common.Utils.ImageHelper.Mall_DrawImgWord(createUpload + "\\" + pictureName, ref drawuse, ref drawimgType, _system);
                    }
                }
                catch (Exception ex)
                {
                    Response.Write(ex);
                }
                catamodel.image = createUpload.Replace("~", "") + pictureName;
                #endregion
            }
            else
            {
                if (Request["imget"] != null && Request["imget"].ToString() != String.Empty)
                {
                    catamodel.image = Request["imget"];
                }
                else if (lblImg1.InnerText != "")
                {
                    catamodel.image = lblImg1.InnerText;
                }

            }

            //if (txturl.Value != "")
            //{
                //catamodel.url = txturl.Value;
                catamodel.url = Request["txturl"];
            //}
            //else
            //{
            //    catamodel.url = "";
            //}

            catamodel.sort_order = AS.Common.Utils.Helper.GetInt(Request["sort"], 0);
            catamodel.cityid = "," + AsAdmin.City_id.ToString() + ",";
            catamodel.keytop = AS.Common.Utils.Helper.GetInt(Request["topsum"], 0);//显示个数
            catamodel.visibility = AS.Common.Utils.Helper.GetInt(Request["state"], 0);//状态是否显示
            catamodel.catahost = AS.Common.Utils.Helper.GetInt(Request["host"], 0);//类别是否主推
            catamodel.location = AS.Common.Utils.Helper.GetInt(Request["location"], 0);

            #region 删除目录下面的子编号
            if (catamodel.parent_id != AS.Common.Utils.Helper.GetInt(Request["parent"].ToString().Split(',')[0], 0))
            {
                Delete(dt, catamodel.parent_id, "", catamodel.id);
            }
            #endregion

            catamodel.parent_id = AS.Common.Utils.Helper.GetInt(Request["parent"].ToString().Split(',')[0], 0);

            if (catamodel.parent_id == 0)
            {
                if (string.IsNullOrEmpty(lblImg1.InnerText) && string.IsNullOrEmpty(catamodel.image))
                {
                    if (Request.Files[0].FileName.Length <= 0)
                    {
                        SetError("请上传商城分类图片");
                        Response.Redirect("mall_addcatalogs.aspx?id=" + Request["id"]);
                    }
                }
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int idd = session.Catalogs.Update(catamodel);
                }

            }

            else
            {
                catamodel.visibility = 0;
                catamodel.catahost = 0;
                catamodel.url = "";
                catamodel.image = "";
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int idd = session.Catalogs.Update(catamodel);
                }
            }


            #region 记录跟目录下面的子id
            ICatalogs cataparten = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                cataparten = session.Catalogs.GetByID(AS.Common.Utils.Helper.GetInt(Request["parent"].ToString().Split(',')[0], 0));
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
                    catamodel.type = 1;
                    catamodel.cityid = "," + AsAdmin.City_id.ToString() + ",";
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
            if (Image1.FileName != null)
            {
                createUpload = setUpload();
            }
            if (Image1.FileName != null && Image1.FileName != "")
            {
                #region 上传图片

                //判断上传文件的大小
                if (Image1.PostedFile.ContentLength > 512000)
                {
                    SetError("请上传 512KB 以内的图片!");
                    return;
                }//如果文件大于512kb，则不允许上传

                string uploadName = Image1.FileName;//获取待上传图片的完整路径，包括文件名 
                string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
                if (Image1.FileName != "")
                {
                    int idx = uploadName.LastIndexOf(".");
                    string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 

                    if (suffix.ToLower() == ".jpg" || suffix.ToLower() == ".png" || suffix.ToLower() == ".gif" || suffix.ToLower() == ".jpeg" || suffix.ToLower() == ".bmp")
                    {
                        pictureName = DateTime.Now.Ticks.ToString() + suffix;
                    }
                    else
                    {
                        SetError("图片格式不正确！");
                        Response.Redirect("Commodity_add.aspx");
                        return;
                    }

                }

                try
                {
                    if (uploadName != "")
                    {
                        string path = Server.MapPath(createUpload);
                        if (!Directory.Exists(path))
                        {
                            Directory.CreateDirectory(path);

                        }
                        Image1.PostedFile.SaveAs(path + pictureName);
                        //生成缩略图
                        string strOldUrl = path + pictureName;
                        string strNewUrl = path + "small_" + pictureName;
                        AS.Common.Utils.ImageHelper.CreateThumbnailNobackcolor(strOldUrl, strNewUrl, 199, 425);
                        //图片加水印
                        string drawuse = "";
                        string drawimgType = "";
                        AS.Common.Utils.ImageHelper.Mall_DrawImgWord(createUpload + "\\" + pictureName, ref drawuse, ref drawimgType, _system);
                    }
                }
                catch (Exception ex)
                {
                    Response.Write(ex);
                }
                catamodel.image = createUpload.Replace("~", "") + pictureName;
                #endregion
            }
            else
            {
                if (Request["imget"] != null && Request["imget"].ToString() != String.Empty)
                {
                    catamodel.image = Request["imget"];
                }
                else if (lblImg1.InnerText != "")
                {
                    catamodel.image = lblImg1.InnerText;
                }

            }

            if (txturl.Value != "")
            {
                catamodel.url = txturl.Value;
            }
            else
            {
                catamodel.image = "";
                catamodel.url = "";
            }

            catamodel.parent_id = AS.Common.Utils.Helper.GetInt(Request["parent"].Split(',')[0], 0);
            catamodel.sort_order = AS.Common.Utils.Helper.GetInt(Request["sort"], 0);
            catamodel.keytop = AS.Common.Utils.Helper.GetInt(Request["topsum"], 0);//显示个数
            catamodel.visibility = AS.Common.Utils.Helper.GetInt(Request["state"], 0);//状态是否显示
            catamodel.catahost = AS.Common.Utils.Helper.GetInt(Request["host"], 0);//类别是否主推
            catamodel.location = AS.Common.Utils.Helper.GetInt(Request["location"], 0);
            catamodel.type = 1;
            catamodel.cityid = "," + AsAdmin.City_id.ToString() + ",";
            if (catamodel.parent_id == 0)
            {
                if (Request.Files[0].FileName.Length <= 0)
                {
                    SetError("请上传商城分类图片");
                    Response.Redirect("mall_addcatalogs.aspx");
                }
            }
            else
            {
                catamodel.visibility = 0;
                catamodel.catahost = 0;
                catamodel.url = "";
                catamodel.image = "";
            }

        #endregion

            #region 记录跟目录下面的子id

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
                    int iddd = session.Catalogs.Insert(catamodel);
                }
                Update(dt, catamodel.parent_id, "", catamodel.id);
            }
            #endregion
        }
    }
    #endregion

    public string setUpload()
    {
        string result1 = "/upfile/team/";
        string path = Server.MapPath("~/upfile/team/");
        if (!System.IO.Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }
        result1 = result1 + DateTime.Now.Year + "/";
        path = path + DateTime.Now.Year + "/";
        if (!Directory.Exists(path))
            Directory.CreateDirectory(path);
        path = path + DateTime.Now.ToString("MMdd");
        if (!Directory.Exists(path))
            Directory.CreateDirectory(path);
        result1 = result1 + DateTime.Now.ToString("MMdd") + "/";


        return result1;
    }

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
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    function hideon(obj) {

        var num = new Array();

        num = obj.value.split(",");
        if (num[1] != "a") {
            $("#s").hide();
            $("#t").hide();
            $("#h").hide();
            $("#city").hide();
            $("#img").hide();
            $("#urldizhi").hide();
            $("#l").hide();

        } else if (num[1] == "a") {

            $("#lblImg1").text("");
            $("#s").show();
            $("#t").show();
            $("#h").show();
            $("#city").show();
            $("#img").show();
            $("#urldizhi").show();
            $("#l").show();

        }
    }

    function check() {
        var child = $("#child").val();
        if (child == "") {
            $("#child").css("background-color", "#FFCC33");
            return false;
        }
        var sort = $("#sort").val();
        if (sort != "" && sort != "0") {
            var reg = new RegExp("^[0-9]*[1-9][0-9]*$");
            if (!reg.exec(sort)) {
                $("#sort").css("background-color", "#FFCC33");
                return false;
            }
        }
    }

    function go() {
        var child = $("#child").val();
        if (child != "") {
            $("#child").css("background-color", "#FFFFFF");
        }
    }

    function sortgo() {
        var sort = $("#sort").val();
        if (sort != "" && sort != "0") {
            var reg = new RegExp("^[0-9]*[1-9][0-9]*$");
            if (reg.exec(sort)) {
                $("#sort").css("background-color", "#FFFFFF");
            }
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
                <div id="coupons" >
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        项目分类</h2>
                                </div>
                                <div class="sect">
                                <table width="96%" class="orders-list">
                                    <tr>
                                        <td width="120"  style="text-align:right; padding-right:10px;" nowrap>
                                            <b>顶级分类：</b>
                                        </td>
                                        <td>
                                            <input id="hid" type="hidden" runat="server" />
                                            <select id="parent" class="f-input"  name="parent" onChange="hideon(this)">
                                                <option value="0,a">顶级分类</option>
                                                <%=cata%>
                                            </select>
                                            <span style="color:Red">建议顶级分类设置为显示状态的个数不要超过8个</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="120"  style="text-align:right;padding-right:10px;"  nowrap>
                                            <b>分类名称：</b>
                                        </td>
                                        <td>
                                            <input group="a" type="text" name="child" id="child" require="true" datatype="require"
                                                class="f-input" value='<%=name %>' />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td width="120"  style="text-align:right;padding-right:10px;"  nowrap>
                                            <b>排序：</b>
                                        </td>
                                        <td>
                                            <input group="a" type="text" name="sort" id="sort" require="true" datatype="number"
                                                class="f-input" value='<%=sort %>' />
                                            <div>
                                                <label class="inputtip">
                                                    请填写数字，数值大到小排序</label></div>
                                        </td>
                                    </tr>
                                    <tr id="s" <%=style %>>
                                        <td width="120"  style="text-align:right;padding-right:10px;"  nowrap>
                                            <b>分类是否显示：</b>
                                        </td>
                                        <td>
                                            <select class="f-input"  id="state" name="state">
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
                                        <td width="120"  style="text-align:right;padding-right:10px;"  nowrap>
                                            <b>是否主推到首页：</b>
                                        </td>
                                        <td>
                                            <select class="f-input"  id="host1" name="host">
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
                                    <tr id="l" <%=style %>>
                                        <td width="120"  style="text-align:right;padding-right:10px;"  nowrap>
                                            <b>商城首页显示位置：</b>
                                        </td>
                                        <td>
                                            <select class="f-input"  id="loaction" name="location">
                                                <%if (location == 0)
                                                  { %>
                                                <option value="0" selected="selected">全部</option>
                                                <option value="1">顶部</option>
                                                <option value="2">列表</option>
                                                <% }
                                                  else if (location == 1)
                                                  { %>
                                                <option value="0">全部</option>
                                                <option value="1" selected="selected">顶部</option>
                                                <option value="2">列表</option>
                                                <% }
                                                  else
                                                  { %>
                                                <option value="0">全部</option>
                                                <option value="1">顶部</option>
                                                <option value="2" selected="selected">列表</option>
                                                <% } %>
                                            </select>
                                        </td>
                                    </tr>
                                    <tr id="img" <%=style %>>
                                        <td width="120"  style="text-align:right;padding-right:10px;" nowrap>
                                            <b>分类首页左侧广告：</b>
                                        </td>
                                        <td>
                                            <asp:FileUpload ID="Image1" runat="server" class="f-input" Height="26px" Width="240px"
                                                group="a" />
                                            <br />
                                            <label id="lblImg1" group="a" runat="server">
                                            </label>
                                        </td>
                                    </tr>
                                    <tr id="urldizhi" <%=style %>>
                                        <td width="120"  style="text-align:right;padding-right:10px;"  nowrap>
                                            <b>广告位链接地址：</b>
                                        </td>
                                        <td>
                                            <input group="a" id="txturl" name="txturl" class="f-input" runat="server" type="text" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>&nbsp;
                                            
                                        </td>
                                        <td>&nbsp;
                                            
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                        </td>
                                        <td>
                                            <input type="submit" name="button" group="a" onClick="checkUrl()" class="formbutton validator"
                                                value="确定" />
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