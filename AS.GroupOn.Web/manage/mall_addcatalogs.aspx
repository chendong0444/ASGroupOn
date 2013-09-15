<%@ Page Language="C#"   AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
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
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_MallTeamCata_Add)) 
        {
            SetError("你不具有新建商城项目分类的权限");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        //分类
        CatalogsFilter catalogsfilter = new CatalogsFilter();
        //分类
        catalogsfilter.type = 1;
        url = url + "&page={0}";
        url = "mall_addcatalogs.aspx?" + url.Substring(1);
        catalogsfilter.PageSize = 30;
        catalogsfilter.AddSortOrder(CatalogsFilter.Sort_Order_DESC);
        catalogsfilter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Catalogs.GetPager(catalogsfilter);
        }
        catalogslist = pager.Objects;
        if (Request["id"] != null)
        {
            hid.Value = AS.Common.Utils.Helper.GetString(Request["id"], "0");
            GetCata(AS.Common.Utils.Helper.GetInt(Request["id"], 0));
        }
        if (Request["button"] == "确定")
        {
            AddCataLogs();
        }
        if (!IsPostBack)
        {
            BindData(catalogslist, 0, "");
        }
    }

    /// <summary>
    /// 绑定分类
    /// </summary>
    /// <param name="dt"></param>
    /// <param name="id"></param>
    /// <param name="blank"></param>
    private void BindData(IList<ICatalogs> catalis, int id, string blank)
    {
        IList<ICatalogs> catalists = null;
        CatalogsFilter cataft = new CatalogsFilter();
        if (catalis!=null&&catalis.Count > 0)
        {
            cataft.AddSortOrder(CatalogsFilter.ID_ASC);
            cataft.type = 1;
            if (id != 0)
                cataft.parent_id = id;
            else
                cataft.parent_id = 0;
            if (id != 0)
                blank += "|─";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                catalists = session.Catalogs.GetList(cataft);
            }
            foreach (ICatalogs catam in catalists)
            {
                if (parentid == AS.Common.Utils.Helper.GetInt(catam.id, 0))
                {
                    if (!pid.Contains("," + catam.id.ToString() + ","))
                    {
                        cata += " <option value=" + catam.id + "," + catam.parent_id + " selected=selected  >" + blank + catam.catalogname + "</option>";
                    }
                }
                else
                {
                    if (!pid.Contains("," + catam.id .ToString() + ","))
                    {
                        cata += " <option value=" + catam.id  + "," +catam.parent_id  + " >" + blank + "" + catam.catalogname.ToString() + "</option>";
                    }
                }
                BindData(catalis, catam.id, blank);
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
            lblImg2.InnerText = catalogs.image1;
            txturl1.Value = catalogs.url1;
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
        CatalogsFilter catafilter = new CatalogsFilter();
        IList<ICatalogs> listcata = null;
        catafilter.AddSortOrder(CatalogsFilter.ID_DESC);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            listcata = session.Catalogs.GetList(catafilter);
        }
        if (hid.Value != "")//编辑
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_MallTeamCata_Edit))
            {
                SetError("你不具有编辑商城项目分类的权限！");
                Response.Redirect("mall_catalogs.aspx");
                Response.End();
                return;
            }
            CatalogsFilter cataft = new CatalogsFilter();
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
                        Response.Redirect("mall_addcatalogs.aspx");
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
            }
            else
            {
                if (catamodel.parent_id == 0)
                {
                    if (lblImg1.InnerText != "")
                    {
                        catamodel.image = lblImg1.InnerText;
                    }
                    else
                    {
                        SetError("请上传商城分类图片");
                        Response.Redirect("mall_addcatalogs.aspx?id=" + catamodel.id);
                    }
                }
            }
            if (Image2.FileName != null)
            {
                createUpload = setUpload();
            }
            if (Image2.FileName != null && Image2.FileName != "")
            {
                string uploadName = Image2.FileName;//获取待上传图片的完整路径，包括文件名 
                string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
                if (Image2.FileName != "")
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
                        Response.Redirect("mall_addcatalogs.aspx");
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
                        Image2.PostedFile.SaveAs(path + pictureName);
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
                catamodel.image1 = createUpload.Replace("~", "") + pictureName;
            }
            else
            {
                catamodel.image1 = lblImg2.InnerText;
            }
            catamodel.url = Request["txturl"];
            catamodel.url1 = Request["txturl1"];
            catamodel.sort_order = AS.Common.Utils.Helper.GetInt(Request["sort"], 0);
            catamodel.keytop = AS.Common.Utils.Helper.GetInt(Request["topsum"], 0);//显示个数
            catamodel.visibility = AS.Common.Utils.Helper.GetInt(Request["state"], 0);//状态是否显示
            catamodel.catahost = AS.Common.Utils.Helper.GetInt(Request["host"], 0);//类别是否主推
            catamodel.location = AS.Common.Utils.Helper.GetInt(Request["location"], 0);
            catamodel.parent_id = AS.Common.Utils.Helper.GetInt(Request["parent"].ToString().Split(',')[0], 0);
            IList<ICatalogs> listodel = null;
            CatalogsFilter cf = new CatalogsFilter();
            cf.type = 1;
            if (catamodel.parent_id == 0)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    session.Catalogs.Update(catamodel);
                    listodel = session.Catalogs.GetList(cf);
                }
                foreach (var item in listodel)
                {
                    Update(item.id);//更新所有分类IDS
                }
                UpdatePart();//更新顶级分类IDS
                SetSuccess("友情提示：更新成功！");
                Response.Redirect("mall_catalogs.aspx");  
            }
            else
            {
                catamodel.visibility = 0;
                catamodel.catahost = 0;
                catamodel.url = "";
                catamodel.image = "";
                catamodel.url1 = "";
                catamodel.image1 = "";
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                   session.Catalogs.Update(catamodel);
                   listodel = session.Catalogs.GetList(cf);
                }
                foreach (var item in listodel)
                {
                    Update(item.id);//更新所有二级分类IDS
                }
                UpdatePart();//更新顶级分类IDS
                SetSuccess("友情提示：更新成功！");
                Response.Redirect("mall_catalogs.aspx");  
            }
        }
        else //添加
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_MallTeamCata_Add))
            {
                SetError("你不具有添加商城分类列表的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
            CatalogsFilter cataft = new CatalogsFilter();
            IList<ICatalogs> catalis = null;
            ICatalogs catamodel = AS.GroupOn.App.Store.CreateCatalogs();
            catamodel.catalogname = Request["child"];
            cataft.catalogname = catamodel.catalogname.Trim();
            cataft.type = 1;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                catalis = session.Catalogs.GetList(cataft);
            }
            if (catalis != null && catalis.Count > 0)
            {
                SetError("分类中已包含此分类，请勿重复添加");
                Response.Redirect("mall_catalogs.aspx");
                Response.End();
            }
            if (AS.Common.Utils.Helper.GetInt(Request["parent"].Split(',')[0], 0) == 0)
            {
                if (Image1.FileName != "")
                {
                    createUpload = setUpload();
                }
                else
                {
                    SetError("请上传商城分类图片");
                    Response.Redirect("mall_addcatalogs.aspx");
                }
            }
            if (Image1.FileName != null && Image1.FileName != "")
            {
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
                        Response.Redirect("mall_catalogs.aspx");
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
                if (Request["Image1"] != null && Request["Image1"].ToString() != String.Empty)
                {
                    catamodel.image = Request["Image1"];
                }
                else if (lblImg1.InnerText != "")
                {
                    catamodel.image = lblImg1.InnerText;
                }
            }
            if (Image2.FileName != "")
            {
                createUpload = setUpload();
            }
            if (Image2.FileName != null && Image2.FileName != "")
            {
                string uploadName = Image1.FileName;//获取待上传图片的完整路径，包括文件名 
                string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
                if (Image2.FileName != "")
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
                        Response.Redirect("mall_catalogs.aspx");
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
                catamodel.image1 = createUpload.Replace("~", "") + pictureName;
            }
            else
            {
                catamodel.image1 = lblImg2.InnerText;
            }
            catamodel.url = txturl.Value;
            catamodel.url1 = txturl1.Value;
            catamodel.parent_id = AS.Common.Utils.Helper.GetInt(Request["parent"].Split(',')[0], 0);
            catamodel.sort_order = AS.Common.Utils.Helper.GetInt(Request["sort"], 0);
            catamodel.keytop = AS.Common.Utils.Helper.GetInt(Request["topsum"], 0);//显示个数
            catamodel.visibility = AS.Common.Utils.Helper.GetInt(Request["state"], 0);//状态是否显示
            catamodel.catahost = AS.Common.Utils.Helper.GetInt(Request["host"], 0);//类别是否主推
            catamodel.location = AS.Common.Utils.Helper.GetInt(Request["location"], 0);
            catamodel.type = 1;
            if (catamodel.parent_id != 0)
            {
                catamodel.visibility = 0;
                catamodel.catahost = 0;
                catamodel.url = "";
                catamodel.image = "";
                catamodel.url1 = "";
                catamodel.image1 = "";
            }
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
            IList<ICatalogs> listodel = null;
            CatalogsFilter cf = new CatalogsFilter();
            cf.type = 1;
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
            Response.Redirect("mall_catalogs.aspx");
        }
    }
    
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
    private void UpdatePart()
    {
        ICatalogs model = null;
        IList<ICatalogs> listodel = null;
        CatalogsFilter cf = new CatalogsFilter();
        cf.type = 1;
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
    function hideon(obj) {
        var num = new Array();
        num = obj.value.split(",");
        if (num[1] != "a") {
            $("#s").hide();
            $("#t").hide();
            $("#h").hide();
            $("#city").hide();
            $("#img").hide();
            $("#url").hide();
            $("#img1").hide();
            $("#url1").hide();
            $("#l").hide();

        } else if (num[1] == "a") {
            $("#lblImg1").text("");
            $("#s").show();
            $("#t").show();
            $("#h").show();
            $("#city").show();
            $("#img").show();
            $("#url").show();
            $("#img1").show();
            $("#url1").show();
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
                                    <tr id="url" <%=style %>>
                                        <td width="120"  style="text-align:right;padding-right:10px;"  nowrap>
                                            <b>广告位链接地址：</b>
                                        </td>
                                        <td>
                                            <input group="a" id="txturl" name="txturl" class="f-input" runat="server" type="text" />
                                        </td>
                                    </tr>
                                       <tr id="img1" <%=style %>>
                                        <td width="120"  style="text-align:right;padding-right:10px;" nowrap>
                                            <b>分类首页右侧广告：</b>
                                        </td>
                                        <td>
                                            <asp:FileUpload ID="Image2" runat="server" class="f-input" Height="26px" Width="240px"
                                                group="a" /> <span style="color:Red">只适用于京东模板</span>
                                            <br />
                                            <label id="lblImg2" group="a" runat="server">
                                            </label>
                                            
                                        </td>
                                           
                                    </tr>
                                    <tr id="url1" <%=style %>>
                                        <td width="120"  style="text-align:right;padding-right:10px;"  nowrap>
                                            <b>广告位链接地址：</b>
                                        </td>
                                        <td>
                                            <input group="a" id="txturl1" name="txturl" class="f-input" runat="server" type="text" />
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