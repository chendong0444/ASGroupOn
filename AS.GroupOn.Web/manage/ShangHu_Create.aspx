<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.Domain.Spi" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
    protected IList<AS.GroupOn.Domain.ICategory> categoryList = null;
    protected IList<AS.GroupOn.Domain.ICategory> categoryList1 = null;
    protected CategoryFilter filter = new CategoryFilter();
    protected CategoryFilter filter1 = new CategoryFilter();
    protected IPartner partner = new Partner();
    protected string pictureName1 = String.Empty;
    protected string pictureName2 = String.Empty;
    protected string pictureName3 = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Partner_Add))
            {
                SetError("你没有新建商户的权限");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
        }

        filter.Zone = "city";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            categoryList = session.Category.GetList(filter);
        }
        filter1.Zone = "partner";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            categoryList1 = session.Category.GetList(filter1);
        }
        if (Request.HttpMethod == "POST")
        {

            partner.Username = Helper.GetString(Request["username"], String.Empty);

            //验证商户用户名是否唯一
            PartnerFilter pfile = new PartnerFilter();
            IList<IPartner> List = null;
            pfile.AddSortOrder(PartnerFilter.ID_DESC);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                List = session.Partners.GetList(pfile);
            }
            if (List != null)
            {
                foreach (IPartner item in List)
                {
                    if (Helper.GetString(Request["username"], String.Empty)!="" && item.Username == Helper.GetString(Request["username"], String.Empty))
                    {
                        SetError("该用户名已经存在");
                        Response.Redirect("ShangHu.aspx");
                        Response.End();
                        return;
                    }
                }
            }
            partner.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Request["password"] + PassWordKey, "md5");
            partner.City_id = AS.Common.Utils.Helper.GetInt(Request["SelectOne"], 0);
            partner.Group_id = AS.Common.Utils.Helper.GetInt(Request["SelectTow"], 0);
            partner.Open = Request["shanghuxiu"].ToUpper() == "Y" ? "Y" : "N";
            partner.Enable = "Y";


            if (FileUpload1.FileName != null && FileUpload1.FileName.ToString() != "")
            {
                //开始上传上传图片
                #region 上传图片

                //判断上传文件的大小
                if (FileUpload1.PostedFile.ContentLength > 512000)
                {
                    SetError("请上传 512KB 以内的图片!");
                    return;
                }//如果文件大于512kb，则不允许上传

                string uploadName = FileUpload1.FileName;//获取待上传图片的完整路径，包括文件名 
                string ext = System.IO.Path.GetExtension(uploadName).ToLower();
                if (ext != ".jpg" && ext != ".bmp" && ext != ".jpeg" && ext != ".png" && ext != ".gif")
                {
                    SetError("上传的图片不合法");
                    Response.Redirect(Request.RawUrl);
                    Response.End();
                    return;
                }
                string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
                if (FileUpload1.FileName != "")
                {

                    int idx = uploadName.LastIndexOf(".");
                    string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 
                    pictureName = DateTime.Now.Ticks.ToString() + 1 + suffix;
                }
                try
                {
                    if (uploadName != "")
                    {
                        string path = Server.MapPath(WebRoot + "upfile/user/");
                        if (!Directory.Exists(path))
                        {
                            Directory.CreateDirectory(path);

                        }
                        FileUpload1.PostedFile.SaveAs(path + pictureName);

                    }
                }
                catch (Exception ex)
                {
                    Response.Write(ex);
                }

                pictureName = WebRoot + "upfile/user/" + pictureName;
                partner.Image = pictureName;
                #endregion

            }
            else
            {
                partner.Image = "";
            }
            if (FileUpload2.FileName != null && FileUpload2.FileName.ToString() != "")
            {
                //上传图片1
                //判断上传文件的大小
                if (FileUpload2.PostedFile.ContentLength > 512000)
                {
                    SetError("请上传 512KB 以内的图片!");
                    return;
                }//如果文件大于512kb，则不允许上传

                string uploadName1 = FileUpload2.FileName;//获取待上传图片的完整路径，包括文件名 
                string ext = System.IO.Path.GetExtension(uploadName1).ToLower();
                if (ext != ".jpg" && ext != ".bmp" && ext != ".jpeg" && ext != ".png" && ext != ".gif")
                {
                    SetError("上传的图片不合法");
                    Response.Redirect(Request.RawUrl);
                    Response.End();
                    return;
                }
                string pictureName1 = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
                if (FileUpload2.FileName != "")
                {
                    int idx = uploadName1.LastIndexOf(".");
                    string suffix = uploadName1.Substring(idx);//获得上传的图片的后缀名 
                    pictureName1 = DateTime.Now.Ticks.ToString() + 2 + suffix;
                }
                try
                {
                    if (uploadName1 != "")
                    {
                        string path = Server.MapPath(WebRoot + "upfile/user/");
                        FileUpload2.PostedFile.SaveAs(path + pictureName1);

                    }
                }
                catch (Exception ex)
                {
                    Response.Write(ex);
                }
                pictureName1 = WebRoot + "upfile/user/" + pictureName1;
                partner.Image1 = pictureName1;
            }
            else
            {
                partner.Image1 = "";
            }
            if (FileUpload3.FileName != null && FileUpload3.FileName != "")
            {
                //上传图片2
                //判断上传文件的大小
                if (FileUpload3.PostedFile.ContentLength > 512000)
                {
                    SetError("请上传 512KB 以内的图片!");
                    return;
                }//如果文件大于512kb，则不允许上传

                string uploadName2 = FileUpload3.FileName;//获取待上传图片的完整路径，包括文件名 
                string ext = System.IO.Path.GetExtension(uploadName2).ToLower();
                if (ext != ".jpg" && ext != ".bmp" && ext != ".jpeg" && ext != ".png" && ext != ".gif")
                {
                    SetError("上传的图片不合法");
                    Response.Redirect(Request.RawUrl);
                    Response.End();
                    return;
                }
                string pictureName2 = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
                if (FileUpload3.FileName != "")
                {
                    int idx = uploadName2.LastIndexOf(".");
                    string suffix = uploadName2.Substring(idx);//获得上传的图片的后缀名 
                    pictureName2 = DateTime.Now.Ticks.ToString() + 3 + suffix;
                }
                try
                {
                    if (uploadName2 != "")
                    {
                        string path = Server.MapPath(WebRoot + "upfile/user/");
                        FileUpload3.PostedFile.SaveAs(path + pictureName2);

                    }
                }
                catch (Exception ex)
                {
                    Response.Write(ex);
                }
                pictureName2 = WebRoot + "upfile/user/" + pictureName2;
                partner.Image2 = pictureName2;
            }
            else
            {
                partner.Image2 = "";
            }
            partner.Title = Helper.GetString(Request["title"], String.Empty);
            partner.Homepage = Helper.GetString(Request["homepage"], String.Empty);
            partner.Contact = Helper.GetString(Request["contact"], String.Empty);
            partner.Phone = Helper.GetString(Request["phone"], String.Empty);
            partner.Address = Helper.GetString(Request["address"], String.Empty);
            partner.area = Helper.GetString(Request["area"], String.Empty);
            partner.Mobile = Helper.GetString(Request["mobile"], String.Empty);
            partner.Secret = Helper.GetString(Request["secret"], String.Empty);
            partner.point = Helper.GetString(Request["jingweidu"], String.Empty);
            partner.Location = Helper.GetString(Request["location"], String.Empty);
            partner.Other = Helper.GetString(Request["other"], String.Empty);
            partner.Bank_name = Helper.GetString(Request["bank_name"], String.Empty);
            partner.Bank_user = Helper.GetString(Request["bank_user"], String.Empty);
            partner.Bank_no = Helper.GetString(Request["bank_no"], String.Empty);
            partner.Create_time = DateTime.Now;
            partner.saleid = "";
            if (string.IsNullOrEmpty(Request["username"]) || string.IsNullOrEmpty(Request["password"]) || string.IsNullOrEmpty(Request["shanghuxiu"]) || string.IsNullOrEmpty(Request["title"]) || string.IsNullOrEmpty(Request["title"]) || string.IsNullOrEmpty(Request["address"]))
            {
                SetError("商家信息不完整");
                Response.Redirect("ShangHu_Create.aspx");
                Response.End();
                return;
            }
            if (!string.IsNullOrEmpty(Request["Image1"]) && !string.IsNullOrEmpty(Request["Image2"]) && !string.IsNullOrEmpty(Request["Image3"]))
            {
                SetError("至少上传一张商户图片");
                Response.Redirect("ShangHu_Create.aspx");
                Response.End();
                return;
            }
            int count = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                count = session.Partners.Insert(partner);
            }
            if (count > 0)
            {
                SetSuccess("添加成功");
                Response.Redirect("ShangHu.aspx");
                Response.End();
                return;
            }
            else
            {
                SetError("添加失败");
                Response.Redirect("ShangHu.aspx");
                Response.End();
                return;
            }

        }
    }
</script>
<% LoadUserControl("_header.ascx", null); %>
<style>
    #preview
    {
        border: 1px solid #bfd2e1;
        width: 500px;
        height: 368px;
        position: relative;
        left: 145px;
        display: block;
        clear: both;
        font-family: Arial, Helvetica, sans-serif, "宋体";
    }
    #map_canvas
    {
        height: 368px;
    }
    #float_search_bar
    {
        left: 0;
        z-index: 2012;
        position: absolute;
        width: 490px;
        height: 31px;
        background: url("/upfile/css/i/search_bar.png") repeat-x;
        background-position: 0 -21px;
        padding: 3px 0 0 10px;
    }
    #float_search_bar label, #float_search_bar span
    {
        color: #0787cb;
        font-size: 14px;
    }
    #float_search_bar input
    {
        width: 180px;
        height: 16px;
        margin-top: 1px;
    }
    #float_search_bar input:focus
    {
        outline: none;
    }
    #float_search_bar input
    {
        border: 0;
        width: 300px;
        height: 20px;
        border: 1px solid #ccc;
        margin-right: 5px;
        cursor: pointer;
    }
    #float_search_bar .seach-map
    {
        border: 0;
        color: white;
        width: 70px;
        height: 20px;
        background: url("/upfile/css/i/search_bar.png") no-repeat;
        background-position: 0 0;
        margin-right: 5px;
        cursor: pointer;
    }
</style>
<script src="http://api.map.baidu.com/api?v=1.2" type="text/javascript"></script>
<script type="text/javascript">
    $(function () {
        $("#phone").blur(function (event) {
            var p = $("#phone").val();
            var k = p.split("-");
            if (p != "") {
                for (var i = 0; i < k.length; i++) {
                    if (k[i].match(/^(-|\+)?\d+$/) == null) {
                        //不是数字类型
                        $("#phone").attr("class", "f-input errorInput");
                        return false;
                    }
                    else {
                        $("#phone").attr("class", "f-input");

                    }
                }
            }
            else {
                $("#phone").attr("class", "f-input");
            }
        });
        $("#submit").click(function (event) {
            var p = $("#phone").val();
            var k = p.split("-");
            if (p != "") {
                for (var i = 0; i < k.length; i++) {
                    if (k[i].match(/^(-|\+)?\d+$/) == null) {
                        //不是数字类型
                        $("#phone").attr("class", "f-input errorInput");
                        return false;
                    }
                    else {
                        $("#phone").attr("class", "f-input");

                    }
                }
            }
            else {
                $("#phone").attr("class", "f-input");
            }

        });
    });
</script>
<body class="newbie">
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="partner">
                    <div id="content" class=" box-content clear mainwide">
                        <%--<div class="clear box">--%>
                         <form id="form1" runat="server">
                        <div class="box-content">
                            <div class="head">
                                <h2>
                                    新建商户</h2>
                            </div>
                            <div class="sect">
                                <form method="post" enctype="multipart/form-data">
                                <div class="wholetip clear">
                                    <h3>
                                        1、登录信息</h3>
                                </div>
                                <div class="field">
                                    <label>
                                        用户名</label>
                                    <input type="text" name="username" maxlength="32" id="username" class="f-input" group="a"
                                        require="true" datatype="require" />
                                </div>
                                <div class="field password">
                                    <label>
                                        登录密码</label>
                                    <input type="text" name="password" maxlength="32" id="password" class="f-input" group="a"
                                        require="true" datatype="require" />
                                </div>
                                <div class="wholetip clear">
                                    <h3 id="H3_1">
                                        2、标注信息</h3>
                                </div>
                                <div class="field" style="height: 38px;">
                                    <label>
                                        城市及分类</label>
                                    <select id="SelectOne" name="SelectOne" class="f-input" style="width: 160px;">
                                        <!--选择城市-->
                                        <option>--选择城市--</option>
                                        <%foreach (AS.GroupOn.Domain.ICategory item in categoryList)
                                          {%>
                                        <option value="<%=item.Id %>" <%
                                                    if(item.Id==partner.City_id) 
                                                    {%> selected="selected">
                                            <%=item.Name%>
                                        </option>
                                        <%}
                                            else
                                            { %>
                                        <option value="<%=item.Id %>">
                                            <%=item.Name %></option>
                                        <%} %>
                                        <%}%>
                                    </select>
                                    <select id="SelectTwo" name="SelectTow" class="f-input" style="width: 160px;">
                                        <!--选择分类-->
                                        <option>--选择分类--</option>
                                        <%foreach (AS.GroupOn.Domain.ICategory item in categoryList1)
                                          {%>
                                        <option value="<%=item.Id %>" <%
                                                    if(item.Id==partner.Group_id)
                                                    {%> selected="selected">
                                            <%=item.Name%></option>
                                        <%}
                                            else
                                            {%>
                                        <option value="<%=item.Id %>">
                                            <%=item.Name %></option>
                                        <%} %>
                                        <%} %>
                                    </select>
                                </div>
                                <div class="field">
                                    <label>
                                        商户秀</label>
                                    <input type="text" name="shanghuxiu" id="shanghuxiu" class="number" value="Y" maxlength="1"
                                        require="true" group="a" datatype="english" style="text-transform: uppercase;" /><span
                                            class="inputtip">Y:前台商户秀展示 N:不参与前台商户秀</span>
                                </div>
                                <div class="field">
                                    <label>
                                        商家图片1</label>
                                    <asp:FileUpload ID="FileUpload1" runat="server" Height="29px" Width="696px" />
                                    <label class="hint" >&nbsp;&nbsp;至少上传一张图片</label>
                                </div>
                                <div class="field">
                                    <label>
                                        商家图片2</label>
                                    <asp:FileUpload ID="FileUpload2" runat="server" Height="28px" Width="696px" />
                                </div>
                                <div class="field">
                                    <label>
                                        商家图片3</label>
                                    <asp:FileUpload ID="FileUpload3" runat="server" Height="31px" Width="694px" />
                                </div>
                                <div class="wholetip clear">
                                    <h3>
                                        3、基本信息</h3>
                                </div>
                                <div class="field">
                                    <label>
                                        商户名称</label>
                                    <input type="text" maxlength="128" name="title" id="title" class="f-input" group="a"
                                        require="true" datatype="require" />
                                </div>
                                <div class="field">
                                    <label>
                                        网站地址</label>
                                    <input type="text" maxlength="128" name="homepage" id="homepage" class="f-input" />
                                </div>
                                <div class="field">
                                    <label>
                                        联系人</label>
                                    <input type="text" maxlength="32" name="contact" id="contact" class="f-input" />
                                </div>
                                <div class="field">
                                    <label>
                                        联系电话</label>
                                    <input type="text" maxlength="18" name="phone" id="phone" class="f-input" />
                                </div>
                                <div class="field">
                                    <label>
                                        商户地址</label>
                                    <input type="text" maxlength="128" name="address" id="address" class="f-input" datatype="require"
                                        group="a" require="true" />
                                </div>
                                <div class="field">
                                    <label>
                                        商圈</label>
                                    <input type="text" maxlength="1000" name="area" id="area" class="f-input" />
                                </div>
                                <div class="field">
                                    <label>
                                        手机号码</label>
                                    <input type="text" name="mobile" id="mobile" class="f-input" maxlength="11" datatype="mobile" />
                                </div>
                                <div class="field">
                                    <label>
                                        消费密码</label>
                                    <input type="text" maxlength="500" name="secret" id="secret" class="f-input" value="000000"
                                        group="a" />
                                </div>
                                <div class="field">
                                    <label>
                                        商户经纬度</label>
                                    <input type="text" maxlength="500" name="jingweidu" id="jingweidu" class="f-input"
                                        group="a" />
                                </div>
                                <div id="preview">
                                    <div id="float_search_bar">
                                        <label>
                                            区域名称：</label>
                                        <input type="text" id="keyword" />
                                        <input class="seach-map" id="search_button" onclick="sercarch()" type="button" value="查找" />
                                    </div>
                                    <div id="map_canvas" style="width: 500px; height: 340px; margin-left: 0px; float: left;
                                        display: block; top: 30px;">
                                    </div>
                                </div>
                                <script type="text/javascript">
                                    var map = new BMap.Map("map_canvas");
                                    map.centerAndZoom(new BMap.Point(116.404, 39.915), 11);
                                    var local = new BMap.LocalSearch(map, {
                                        renderOptions: { map: map }
                                    });

                                    function sercarch() {
                                        if (document.getElementById("keyword").value == "") {
                                            alert("请您输入要查询的区域");
                                            return false;
                                        }
                                        local.search(document.getElementById("keyword").value);
                                    }
                                    $(document).ready(function () {

                                        var point = new BMap.Point(116.404, 39.915);
                                        map.centerAndZoom(point, 11);

                                        var menu = new BMap.ContextMenu();
                                        var txtMenuItem = [
                                            {
                                                text: '以此处为商户位',
                                                callback: function (p) {
                                                    map.clearOverlays();
                                                    var center = map.getCenter();
                                                    var marker = new BMap.Marker(p), px = map.pointToPixel(p); map.addOverlay(marker);
                                                    $("#jingweidu").val(p.lat + "," + p.lng);
                                                }
                                            },
                                            {
                                                text: '清除标记',
                                                callback: function (p) {
                                                    map.clearOverlays();
                                                }
                                            },
                                            {
                                                text: '放大',
                                                callback: function () { map.zoomIn() }
                                            },
                                            {
                                                text: '缩小',
                                                callback: function () { map.zoomOut() }
                                            },
                                            {
                                                text: '放置到最大级',
                                                callback: function () { map.setZoom(18) }
                                            },
                                            {
                                                text: '查看全国',
                                                callback: function () { map.setZoom(4) }
                                            }
                                            ];
                                        for (var i = 0; i < txtMenuItem.length; i++) {
                                            menu.addItem(new BMap.MenuItem(txtMenuItem[i].text, txtMenuItem[i].callback, 100));
                                            if (i == 1) {
                                                menu.addSeparator();
                                            }
                                        }
                                        map.addContextMenu(menu);
                                        map.enableScrollWheelZoom();
                                        map.addControl(new BMap.NavigationControl());
                                        map.addControl(new BMap.ScaleControl());
                                        map.addControl(new BMap.OverviewMapControl());
                                        map.addControl(new BMap.MapTypeControl());
                                        map.centerAndZoom(point, 15);
                                    });
                                </script>
                                <div class="field">
                                    <label>
                                        位置信息</label>
                                    <div style="float: left;">
                                        <textarea cols="45" rows="5" name="location" id="location" class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1',urlType:'abs'}"
                                            runat="server"></textarea></div>
                                </div>
                                <div class="field">
                                    <label>
                                        其他信息</label>
                                    <div style="float: left;">
                                        <textarea cols="45" rows="5" name="other" id="other" class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1',urlType:'abs'}"
                                            runat="server"></textarea></div>
                                </div>
                                <div class="wholetip clear">
                                    <h3>
                                        4、银行信息</h3>
                                </div>
                                <div class="field">
                                    <label>
                                        开户行</label>
                                    <input type="text" size="30" name="bank_name" id="bank_name" class="f-input" />
                                </div>
                                <div class="field">
                                    <label>
                                        开户名</label>
                                    <input type="text" size="30" name="bank_user" id="bank_user" class="f-input" />
                                </div>
                                <div class="field">
                                    <label>
                                        银行账户</label>
                                    <input type="text" size="30" name="bank_no" id="bank_no" class="f-input" />
                                </div>
                                <div class="act">
                                    <input id="Submit1" type="submit" value="新建" class="formbutton validator" runat="server" />
                                </div>
                                </form>
                            </div>
                        </div>
                        <%-- </div>--%>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
<%LoadUserControl("_footer.ascx", null); %>