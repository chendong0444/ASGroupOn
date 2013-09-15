<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage"
    ValidateRequest="false" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    IProduct promodel = AS.GroupOn.App.Store.CreateProduct();
    ProductFilter productft = new ProductFilter();
    public NameValueCollection _system = null;
    public string inven = "";
    public string bulletin = "";
    public string strtitle = "";
    IProduct product = null;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //_system = sysmodel.GetSystem();
        if (Request.HttpMethod == "POST")
        {
            if (Request["id"] != null && Request["id"].ToString() != "")
            {
                UpdateContent();
            }
            else
            {
                addContent();
            }
            productft.AddSortOrder(ProductFilter.ID_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                product = session.Product.Get(productft);
            }
            if (product != null)
            {
                if (product.open_invent != 1)
                {
                    Response.Redirect("ProductList.aspx", true);
                }
            }
        }

        if (!Page.IsPostBack)
        {
            initDropdown();
            initPage();
        }
    }

    private void initDropdown()
    {
        //添加分类
        ListItem pinpai = new ListItem();
        pinpai.Text = "====请品牌分类=====";
        pinpai.Value = "0";
        pinpai.Selected = true;
        this.ddlbrand.Items.Add(pinpai);
        CategoryFilter cateft = new CategoryFilter();
        IList<ICategory> catelist = null;
        cateft.Zone = "brand";
        cateft.City_pid = AsAdmin.City_id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            catelist = session.Category.GetList(cateft);
        }
        foreach (ICategory item in catelist)
        {
            ListItem li = new ListItem();
            li.Text = item.Name;
            li.Value = item.Id.ToString();
            ddlbrand.Items.Add(li);
        }
        ddlbrand.DataBind();

        //添加商户
        PartnerFilter pate = new PartnerFilter();
        IList<IPartner> partnerlist = null;
        ListItem li1 = new ListItem();
        li1.Text = "===========请选择商户============";
        li1.Value = "0";
        li1.Selected = true;
       
        shanghu.Items.Add(li1);
        pate.AddSortOrder(PartnerFilter.ID_DESC);
        pate.City_id = AsAdmin.City_id;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            partnerlist = session.Partners.GetList(pate);
        }
        System.Data.DataTable dt = AS.Common.Utils.Helper.ToDataTable(partnerlist.ToList());
        if (dt != null && dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                ListItem li = new ListItem();
                li.Text = dt.Rows[i]["Title"].ToString();
                li.Value = dt.Rows[i]["Id"].ToString();
                shanghu.Items.Add(li);
            }
        }
        shanghu.DataBind();

        //开启库存费提醒
        ListItem inventory2 = new ListItem();
        inventory2.Text = "否";
        inventory2.Value = "0";
        ListItem inventory1 = new ListItem();
        inventory1.Text = "是";
        inventory1.Value = "1";

        if (_system != null)
        {
            if (_system["inventory"] != null)
            {
                if (_system["inventory"] == "1")
                {
                    inventory1.Selected = true;
                }
                else
                {
                    inventory2.Selected = true;
                }
            }
        }
        ddlinventory.Items.Add(inventory2);
        ddlinventory.Items.Add(inventory1);
        this.ddlinventory.DataBind();
    }

    private void initPage()
    {
        strtitle = "新建产品";
        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            strtitle = "编辑产品";
            IProduct promodel = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                promodel = session.Product.GetByID(int.Parse(Request["id"].ToString()));
            }
            if (promodel != null)
            {

                createproduct.Value = promodel.productname;
                market_price.Value = promodel.price.ToString();
                shanghu.SelectedValue = promodel.partnerid.ToString();
                #region 项目的颜色或者尺寸
                string[] bulletinteam = promodel.bulletin.Replace("{", "").Replace("}", "").Split(',');
                for (int i = 0; i < bulletinteam.Length; i++)
                {
                    string txt = bulletinteam[i];
                    if (bulletinteam[i] != "")
                    {
                        if (bulletinteam[i].Split(':')[0] != "" && bulletinteam[i].Split(':')[1] != "")
                        {
                            bulletin += "<tr>";
                            bulletin += "<td>";
                            bulletin += "属性：<input type=\"text\" name=\"StuNamea" + i + "\" value=" + bulletinteam[i].Split(':')[0] + ">数值：<input type=\"text\" name=\"Stuvaluea" + i + "\" value=" + bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "") + "><input type=\"button\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
                            bulletin += "</td>";
                            bulletin += "</tr>";
                        }
                    }
                }
                #endregion
                createsort_order.Value = promodel.sortorder.ToString();
                ddlinventory.SelectedValue = promodel.open_invent.ToString();
                createdetail.Value = promodel.detail;
                ImageSet.InnerText = promodel.imgurl;
                inven = promodel.inventory.ToString();
                Team_price.Value = promodel.team_price.ToString();
                ddlbrand.SelectedValue = promodel.brand_id.ToString();
                createsummary.Value = promodel.summary;
            }
        }
    }

    private void UpdateContent()
    {
        //Upload upload = new Upload();
        string createUpload = "";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            promodel = session.Product.GetByID(int.Parse(Request["id"].ToString()));
        }
        promodel.productname = createproduct.Value;
        promodel.price = decimal.Parse(market_price.Value);
        if (shanghu.SelectedValue==""||shanghu.SelectedValue==null||shanghu.SelectedValue=="===========请选择商户============")
        {
            SetError("商户不能为空！");
            return;
        }
        else
        {
            promodel.partnerid = int.Parse(shanghu.SelectedValue);
        }
        
        promodel.team_price = decimal.Parse(Team_price.Value);
        promodel.brand_id = int.Parse(ddlbrand.SelectedValue);
        promodel.summary = createsummary.Value;
        string[] bulletinteam = promodel.bulletin.Replace("{", "").Replace("}", "").TrimEnd(',').Split(',');
        int cou = 0;
        if (promodel.bulletin != "")
        {
            cou = bulletinteam.Length;
        }
       
        promodel.bulletin = addcolor(cou);
        promodel.sortorder = int.Parse(createsort_order.Value);
        promodel.open_invent = int.Parse(ddlinventory.SelectedValue);
        promodel.detail = createdetail.Value;

        if (Image.FileName != null)
        {
            createUpload = setUpload();
        }
        if (Image.FileName != null && Image.FileName != "")
        {
            #region 上传图片

            string uploadName = Image.FileName;//获取待上传图片的完整路径，包括文件名 
            //string uploadName = InputFile.PostedFile.FileName; 
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (Image.FileName != "")
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
                    Response.Redirect("ProductAdd.aspx");
                    return;
                }
            }

            try
            {
                if (uploadName != "")
                {
                    string path = Server.MapPath(createUpload);
                    if (!System.IO.Directory.Exists(path))
                    {
                        System.IO.Directory.CreateDirectory(path);

                    }

                    Image.PostedFile.SaveAs(path + pictureName);

                    //生成缩略图
                    string strOldUrl = path + pictureName;
                    string strNewUrl = path + "small_" + pictureName;
                    AS.Common.Utils.ImageHelper.CreateThumbnailNobackcolor(strOldUrl, strNewUrl, 235, 150);

                    //图片加水印
                    string drawuse = "";
                    string drawimgType = "";
                    AS.Common.Utils.ImageHelper.DrawImgWord(createUpload + "\\" + pictureName, ref drawuse, ref drawimgType, _system);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            promodel.imgurl = createUpload.Replace("~", "") + pictureName;

            #endregion
        }
        else
        {
            promodel.imgurl = ImageSet.InnerText;
        }
        int ires = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ires = session.Product.Update(promodel);
        }
        if (ires > 0)
        {
            TeamFilter teamft = new TeamFilter();
            IList<ITeam> listpro = null;
            //修改信息的时候，将该产品下的项目信息也修改
            teamft.productid = promodel.id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                listpro = session.Teams.GetList(teamft);
            }
            System.Data.DataTable dt = AS.Common.Utils.Helper.ToDataTable(listpro.ToList());
            if (dt != null)
            {
                if (dt.Rows.Count > 0)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        System.Data.DataRow dr = dt.Rows[i];
                        ITeam teammodel = null;
                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            teammodel = session.Teams.GetByID(int.Parse(dr["id"].ToString()));
                        }
                        if (teammodel != null)
                        {
                            teammodel.open_invent = promodel.open_invent;
                            teammodel.bulletin = promodel.bulletin;
                            teammodel.Partner_id = promodel.partnerid;
                            teammodel.inventory = promodel.inventory;
                            teammodel.invent_result = promodel.invent_result;
                            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                            {
                                int id2 = session.Teams.Update(teammodel);
                            }

                        }
                    }
                }
            }

            if (Helper.GetInt(promodel.open_invent, 0) == 1)//开启库存
            {
               
            }
            else
            {
                SetSuccess("修改成功");
            }
        }
        else
        {
            SetError("修改产品失败！");
        }
    }

    private void addContent()
    {
        //Upload upload = new Upload();
        string createUpload = "";
       
        promodel.productname = createproduct.Value;
        promodel.price = decimal.Parse(market_price.Value);
        if (shanghu.SelectedValue == "" || shanghu.SelectedValue == null || shanghu.SelectedValue == "===========请选择商户============" || shanghu.SelectedValue == "0")
        {
            SetError("商户不能为空！");
            return;
        }
        else
        {
            promodel.partnerid = int.Parse(shanghu.SelectedValue);
        }
        
        promodel.bulletin = addcolor();
        promodel.sortorder = int.Parse(createsort_order.Value);
        promodel.open_invent = int.Parse(ddlinventory.SelectedValue);
        promodel.detail = createdetail.Value;
        promodel.status = 4;
        promodel.team_price = decimal.Parse(Team_price.Value);
        promodel.brand_id = int.Parse(ddlbrand.SelectedValue);
        promodel.summary = createsummary.Value;

        if (Image.FileName != null)
        {
            createUpload = setUpload();
        }
        if (Image.FileName != null && Image.FileName != "")
        {
            #region 上传图片

            string uploadName = Image.FileName;//获取待上传图片的完整路径，包括文件名 
            //string uploadName = InputFile.PostedFile.FileName; 
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (Image.FileName != "")
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
                    Response.Redirect("ProductAdd.aspx");
                    return;
                }
            }
            try
            {
                if (uploadName != "")
                {
                    string path = Server.MapPath(createUpload);
                    if (!System.IO.Directory.Exists(path))
                    {
                        System.IO.Directory.CreateDirectory(path);
                    }
                    Image.PostedFile.SaveAs(path + pictureName);
                    ////生成缩略图
                    string strOldUrl = path + pictureName;
                    string strNewUrl = path + "small_" + pictureName;
                    AS.Common.Utils.ImageHelper.CreateThumbnailNobackcolor(strOldUrl, strNewUrl, 235, 150);
                    ////图片加水印
                    string drawuse = "";
                    string drawimgType = "";
                    AS.Common.Utils.ImageHelper.DrawImgWord(createUpload + "\\" + pictureName, ref drawuse, ref drawimgType, _system);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            promodel.imgurl = createUpload.Replace("~", "") + pictureName;

            #endregion
        }
        else
        {
            promodel.imgurl = Request["imget"];
        }

        if (promodel.imgurl == null || promodel.imgurl == "")
        {
            SetError("图片不能为空！");
            Response.Redirect("ProductAdd.aspx");
        }

        int ires = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ires = session.Product.Insert(promodel);
        }
        if (ires > 0)
        {
            if (Helper.GetInt(promodel.open_invent, 0) == 1)//开启库存
            {
                
            }
            else
            {
                SetSuccess("添加成功");
            }
        }
        else
        {
            SetError("添加产品失败！");
        }

    }

    /// <summary>
    /// 显示文件夹信息
    /// </summary>

    public string setUpload()
    {
        string result1 = "~/upload/team/";
        string path = Server.MapPath("~/upload/team/");
        if (!System.IO.Directory.Exists(path))
        {
            System.IO.Directory.CreateDirectory(path);
        }
        result1 = result1 + DateTime.Now.Year + "/";
        path = path + DateTime.Now.Year + "/";
        if (!System.IO.Directory.Exists(path))
            System.IO.Directory.CreateDirectory(path);
        path = path + DateTime.Now.ToString("MMdd");
        if (!System.IO.Directory.Exists(path))
            System.IO.Directory.CreateDirectory(path);
        result1 = result1 + DateTime.Now.ToString("MMdd") + "/";


        return result1;
    }

    #region 添加颜色或者尺寸
    public string addcolor()
    {
        string str = "";
        try
        {
            if (Request["totalNumber"] != null && Request["totalNumber"] != "")
            {
                int num = Convert.ToInt32(Request["totalNumber"]);
                str += "{";
                for (int i = 0; i < Convert.ToInt32(Request["totalNumber"]); i++)
                {
                    if (Request["StuName" + i] != null && Request["Stuvalue" + i] != null && Request["StuName" + i].ToString() != "" && Request["Stuvalue" + i].ToString() != "")
                    {
                        str += Request["StuName" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(".", "").Replace(",", "") + ":";
                        str += "[";
                        str += Request["Stuvalue" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(".", "").Replace(",", "");
                        str += "]";
                        str += ",";
                    }
                }
                str += "}";
            }
        }
        catch
        {
            SetError("友情提示：项目格式不正确");
        }
        return str;
    }
    #endregion

    #region 添加颜色或者尺寸
    public string addcolor(int count)
    {
        string str = "";
        if (Request["totalNumber"] != null && Request["totalNumber"] != "")
        {
            int num = Convert.ToInt32(Request["totalNumber"]);
            str += "{";

            for (int i = 0; i < count; i++)
            {
                if (Request["StuNamea" + i] != null && Request["Stuvaluea" + i] != null && Request["StuNamea" + i].ToString() != "" && Request["Stuvaluea" + i].ToString() != "")
                {
                    str += Request["StuNamea" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(".", "").Replace(",", "") + ":";
                    str += "[";
                    str += Request["Stuvaluea" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(".", "").Replace(",", "");
                    str += "]";
                    str += ",";
                }
            }
            for (int i = 0; i < num; i++)
            {
                if (Request["StuName" + i] != null && Request["Stuvalue" + i] != null && Request["StuName" + i].ToString() != "" && Request["Stuvalue" + i].ToString() != "")
                {
                    str += Request["StuName" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(".", "").Replace(",", "") + ":";
                    str += "[";
                    str += Request["Stuvalue" + i].Replace(":", "").Replace("-", "").Replace("[", "").Replace("]", "").Replace("{", "").Replace("}", "").Replace(".", "").Replace(",", "");
                    str += "]";
                    str += ",";
                }
            }
            str += "}";
        }
        return str;
    }
    #endregion
</script>
<%LoadUserControl("_header.ascx", null); %>
<%if (Helper.GetInt(promodel.open_invent, 0) == 1)
  {%>
<script language='javascript'>
    if (!confirm('友情提示：已开启库存功能，是否进行出入库操作！')) { location.href = 'ProductList.aspx' } else { X.get('/manage/ajax_coupon.aspx?action=pinvent&p=p&inventid=<%=promodel.id %>') }</script>
  <%}%>
<script type="text/javascript" language="javascript">
    var num = 0;
    function upload() {
        document.getElementById("status").innerHTML = "文件上传中...";
        multiUploadForm.submit();
    }

    function additem(id) {
        var row, cell, str;
        row = document.getElementById(id).insertRow(-1);
        if (row != null) {
            cell = row.insertCell(-1);
            cell.innerHTML = "属性：<input type=\"text\" name=\"StuName" + num + "\">数值：<input type=\"text\" name=\"Stuvalue" + num + "\"><input type=\"button\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
        }
        num++
        document.getElementsByName("totalNumber")[0].value = num;
    }

    function deleteitem(obj, id) {
        var rowNum, curRow;
        curRow = obj.parentNode.parentNode;
        rowNum = document.getElementById(id).rows.length - 1;
        document.getElementById(id).deleteRow(curRow.rowIndex);
    }

    function callback(msg) {
        document.getElementById("status").innerHTML = "文件上传完成...<br>" + msg;
    }

    function getkey(obj) {

        if (obj.value != 0) {
            $.ajax({
                type: "POST",
                url: webroot + "/ajax/ajax_key.aspx?key=" + obj.value + "",

                success: function (msg) {
                    if (msg != "") {
                        $("#aa").html(msg);
                    }
                }
            });
        } else {
            $("#key").html("");
        }
    }

    function cliks() {
        if (document.getElementById("isInvents").value == "1") {

            if (!confirm('友情提示：已开启库存功能，是否进行出入库操作！')) { location.href = 'ProductList.aspx' } else { X.get('ajax_coupon.aspx?action=pinvent&p=p&inventid=' + document.getElementById("produid").value) }
        }
    }

    function checkallcity() {
        var str = $("#cityall").attr('checked');
        if (str) {

            $('[name=city_id]').attr('checked', true);
        }
        else {

            $('[name=city_id]').attr('checked', false);
        }
    }
       
</script>
<script type="text/javascript">
    $(document).ready(function () {
        jQuery("#city").change(function () {

            var str = jQuery("#city").val();

            if (str != "") {

                if (str == "0") {
                    $('[name=cityall]').attr('disabled', true);
                } else {
                    $('[name=cityall]').attr('disabled', false);
                }
                $.ajax({
                    type: "POST",
                    url: webroot + "manage_ajax_othercitys.aspx",
                    data: { "cityid": str },
                    success: function (msg) {
                        $("#cityother").html(msg);
                    }
                });
            }
        });
    })
</script>
<script type="text/javascript">
    $(function () {
        function split(val) {
            return val.split(/,\s*/);
        }
        function extractLast(term) {
            return split(term).pop();
        }

        $("#birds")
        // don't navigate away from the field on tab when selecting an item
			.bind("keydown", function (event) {
			    if (event.keyCode === $.ui.keyCode.TAB &&
						$(this).data("autocomplete").menu.active) {
			        event.preventDefault();
			    }
			})
			.autocomplete({

			    source: function (request, response) {
			        $.getJSON(webroot + "ajax/ajax_key.aspx?key=" + $("#birds").val(), {
			            term: extractLast(request.term)
			        }, response);
			    },
			    search: function () {
			        // custom minLength
			        var term = extractLast(this.value);
			        if (term.length < 1) {
			            return false;
			        }
			    },
			    focus: function () {
			        // prevent value inserted on focus
			        return false;
			    },
			    select: function (event, ui) {
			        var terms = split(this.value);
			        // remove the current input
			        terms.pop();
			        // add the selected item
			        terms.push(ui.item.value);
			        // add placeholder to get the comma-and-space at the end
			        terms.push("");
			        this.value = terms.join(", ");
			        return false;
			    }
			});
    });
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
                                    <h2>
                                        <%=strtitle%></h2>
                                </div>
                                <div class="sect">
                                    <div class="wholetip clear">
                                        <h3>
                                            1、基本信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            产品名称</label>
                                        <input type="hidden" id="isInvents" runat="server" />
                                        <input type="hidden" id="produid" runat="server" />
                                        <input type="text" size="30" name="product" id="createproduct" class="f-input" group="g"
                                            datatype="require" require="true" runat="server" />
                                    </div>
                                    <div class="field" id="dbrand">
                                        <label>
                                            品牌分类</label>
                                        <asp:DropDownList ID="ddlbrand" name="ddlbrand" class="f-input" runat="server" Style="width: 160px;">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="field">
                                        <label>
                                            市场价</label>
                                        <input type="text" size="10" name="market_price" id="market_price" class="number"
                                            value="1" datatype="money" group="g" require="true" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            团购价</label>
                                        <input type="text" size="10" name="Team_price" id="Team_price" class="number" value="1"
                                            datatype="money" group="g" require="true" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户</label>
                                        <asp:DropDownList ID="shanghu" runat="server" CssClass="f-shinput">
                                        </asp:DropDownList><div>
                                        <span class="hint">商户为必选</span></div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商品图片</label>
                                        <asp:FileUpload ID="Image" name="Image" class="f-input" Height="30px" runat="server" />
                                        <span class="hint">商品图片不能为空 </span>&nbsp;
                                        <label id="ImageSet" class="hint" runat="server">
                                        </label>
                                    </div>
                                    <div class="field">
                                        <label>
                                            产品规格</label>
                                        <input type="button" name="btnAddFile" class="formbutton" value="添加" onClick="additem('tb')" /><font
                                            style='color: red; margin-left:10px;'>例如：属性填写：颜色 数值填写：红色|黄色|蓝色</font>
                                    </div>
                                    <div class="field">
                                        <label>
                                        </label>
                                        <table id="tb">
                                            <%=bulletin%>
                                        </table>
                                        <input type="hidden" name="totalNumber" value="0" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            排序</label>
                                        <input type="text" size="10" name="sort_order" id="createsort_order" class="number"
                                            value="0" group="g" datatype="number" runat="server" /><span class="inputtip">请填写数字，数值大到小排序</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            启用库存</label>
                                        <asp:DropDownList ID="ddlinventory" Style="float: left;" runat="server">
                                        </asp:DropDownList>
                                        <span class="inputtip">是否开启库存功能</span>
                                    </div>
                                    <%if (inven != "")
                                      { %>
                                    <div class="field">
                                        <label>
                                            库存数量</label>
                                        <span class="inputtip">
                                            <%=inven%></span>
                                    </div>
                                    <%} %>
                                    <div class="field" id="summery">
                                        <label>
                                            产品简介</label>
                                        <div style="float: left;">
                                            <textarea cols="45" rows="5" name="createsummary" id="createsummary" class="f-textarea"
                                                runat="server"></textarea></div>
                                    </div>
                                    <div class="field">
                                        <label>
                                            产品详情</label>
                                        <div style="float: left;">
                                            <textarea cols="45" style="height: 500px;" rows="5" name="detail" id="createdetail"
                                                class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1',urlType:'abs'}"
                                                runat="server"></textarea></div>
                                    </div>
                                    <div class="act">
                                        <input id="leadesubmit" name="commit" type="submit" value="好了，提交" group="g" class="formbutton validator"
                                            onclick="cliks()" />
                                    </div>
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