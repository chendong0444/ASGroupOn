<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.SalePage" %>
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
<%@ Import Namespace="System.IO" %>
<script runat="server">
    protected bool canLoadMap = false;
    protected bool baiduLoadMap = true;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!Page.IsPostBack)
        {
            getBesinse();
        }
    }
    /// <summary>
    /// 显示相关选择项
    /// </summary>
    private void getBesinse()
    {
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        ListItem li11 = new ListItem();
        li11.Value = "";
        li11.Text = "-----选择城市----";
        SelectOne.Items.Add(li11);
        CategoryFilter catefilter = new CategoryFilter();
        IList<ICategory> ilistcate = null;
        catefilter.Zone = "city";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistcate = session.Category.GetList(catefilter);
        }
        foreach(ICategory item in ilistcate)
        {
            ListItem li12 = new ListItem();
            li12.Value = item.Id.ToString();
            li12.Text = item.Name.ToString();
            SelectOne.Items.Add(li12);
        }

        ListItem li21 = new ListItem();
        li21.Value = "";
        li21.Text = "----选择分类----";
        SelectTwo.Items.Add(li21);
        CategoryFilter cafilter = new CategoryFilter();
        IList<ICategory> ilistca = null;
        cafilter.Zone = "partner";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistca = session.Category.GetList(cafilter);
        }
        foreach(ICategory item in ilistca)
        {
            ListItem li22 = new ListItem();
            li22.Value = item.Id.ToString();
            li22.Text = item.Name;
            SelectTwo.Items.Add(li22);
        }
        SelectOne.DataBind();
        SelectTwo.DataBind();
    }
    /// <summary>
    /// 创建商户的方法
    /// </summary>
    private void createBesinse()
    {
        IPartner pt = Store.CreatePartner();
        PartnerFilter partfilter = new PartnerFilter();
        partfilter.Username = username.Value;
        int usernameResult = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            usernameResult = session.Partners.GetCount(partfilter);
        }
        if (usernameResult>0)
        {
            //判断用户名是否存在
            SetError("商户已存在,请重新输入！");
            Response.Redirect("PartnetAdd.aspx");
            return;
        }
        pt.Username = username.Value;
        pt.Password =WebUtils.GetPasswordByMD5(pwd.Value);
        if (SelectOne.SelectedItem.Value != "")
        {
            pt.City_id = Convert.ToInt32(SelectOne.SelectedItem.Value);
        }
        if (SelectTwo.SelectedItem.Value != "")
        {
            pt.Group_id = Convert.ToInt32(SelectTwo.SelectedItem.Value);
        }
        if (shangwuxiu.Value != String.Empty)
            pt.Open = shangwuxiu.Value.ToUpper();
        else
            pt.Open = "N";
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
                    string path = Server.MapPath(PageValue.WebRoot + "upfile/user/");
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

            pictureName = PageValue.WebRoot + "upfile/user/" + pictureName;
            pt.Image = pictureName;
            #endregion

        }
        else
        {
            pt.Image = "";
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
                    string path = Server.MapPath(PageValue.WebRoot + "upfile/user/");
                    FileUpload2.PostedFile.SaveAs(path + pictureName1);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            pictureName1 = PageValue.WebRoot + "upfile/user/" + pictureName1;
            pt.Image1 = pictureName1;
        }
        else
        {
            pt.Image1 = "";
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
                    string path = Server.MapPath(PageValue.WebRoot + "upfile/user/");
                    FileUpload3.PostedFile.SaveAs(path + pictureName2);
                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            pictureName2 = PageValue.WebRoot + "upfile/user/" + pictureName2;
            pt.Image2 = pictureName2;
        }
        else
        {
            pt.Image2 = "";
        }
        pt.Title = shangwuMingcheng.Value;
        pt.Homepage = homepage.Value;
        pt.Contact = contact.Value;
        pt.Phone = phone.Value;
        pt.Address = address.Value;
        pt.Mobile = mobile.Value;

        if (secret.Value == "")
        {
            pt.Secret = "000000";
        }
        else
        {
            pt.Secret = secret.Value;
        }
        pt.point = jingweidu.Value;
        pt.Location = location.Value;
        pt.Other = other.Value;
        pt.Bank_name = bankname.Value;
        pt.Bank_user = bankuser.Value;
        pt.Bank_no = bankno.Value;
        pt.area = area.Value;
        pt.Create_time = DateTime.Now;
        pt.Enable = "Y";
        #region ##在商家表添加了销售人员id

        pt.saleid = CookieUtils.GetCookieValue("sale", key).ToString() + ",";
       
        //提交数据库
        int addresult = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            addresult = session.Partners.Insert(pt);
        }
        if (addresult > 0)
        {
            SetSuccess("添加成功！");
            Response.Redirect("PartnetList.aspx");
        }
        else
        {
            SetError("添加失败！");
            Response.Redirect("PartnetAdd.aspx");
        }
        #endregion
    }
    protected void submit_ServerClick(object sender, EventArgs e)
    {
        createBesinse();
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<script src="http://api.map.baidu.com/api?v=1.2" type="text/javascript"></script>

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
        left:0;
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

<body>
<form id="form1" runat="server" method="post">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
  <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content">
                        <div class="box clear">
                            <div class="box-content clear mainwide">
                                <div class="head">
                                    <h2>
                                        新建商户</h2>
                                </div>
                                <div class="sect">
                                    <%--<form id="form2" enctype="multipart/form-data" class="validator" runat="server">--%>
                                    <div class="wholetip clear">
                                        <h3>
                                            1、登录信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            用户名</label>
                                        <input type="text" size="30" name="username" id="username" class="f-input" value=""
                                            group="a" runat="server" require="true" datatype="require" />
                                    </div>
                                    <div class="field password">
                                        <label>
                                            登录密码</label>
                                        <input type="text" size="30" name="password" id="pwd" class="f-input" value="" group="a"
                                            runat="server" require="true" datatype="require" />
                                    </div>
                                    <div class="wholetip clear">
                                        <h3 id="H3_1" runat="server">
                                            2、标注信息</h3>
                                    </div>
                                    <div class="field" style="height: 38px;">
                                        <label>
                                            城市及分类</label>
                                        <asp:DropDownList ID="SelectOne" runat="server" class="f-input" Style="width: 160px;">
                                        </asp:DropDownList>
                                        <asp:DropDownList ID="SelectTwo" class="f-input" runat="server" Style="width: 160px;">
                                        </asp:DropDownList>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户秀</label>
                                        <input type="text" size="30" name="open" id="shangwuxiu" class="number" value=""
                                            maxlength="1" require="true" group="a" datatype="english" style="text-transform: uppercase;"
                                            runat="server" /><span class="inputtip">Y:前台商户秀展示 N:不参与前台商户秀</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商家图片</label>
                                        <asp:FileUpload ID="FileUpload1" runat="server" Height="29px" Width="696px" size="80" /></div>
                                    <div class="field">
                                        <label>
                                            商家图片1</label>
                                        <asp:FileUpload ID="FileUpload2" runat="server" Height="28px" Width="696px" size="80" /></div>
                                    <div class="field">
                                        <label>
                                            商家图片2</label>
                                        <asp:FileUpload ID="FileUpload3" runat="server" Height="31px" Width="694px" size="80" /></div>
                                    <div class="wholetip clear">
                                        <h3>
                                            3、基本信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户名称</label>
                                        <input type="text" size="30" name="title" id="shangwuMingcheng" class="f-input" value=""
                                            group="a" require="true" datatype="require" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            网站地址</label>
                                        <input type="text" size="30" name="homepage" id="homepage" class="f-input" value=""
                                            runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            联系人</label>
                                        <input type="text" size="30" name="contact" id="contact" class="f-input" value=""
                                            runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            联系电话</label>
                                        <input type="text" size="30" name="phone" id="phone" class="f-input" value="" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户地址</label>
                                        <input type="text" size="30" name="address" id="address" class="f-input" value=""
                                            datatype="require" group="a" require="true" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            商圈</label>
                                        <input type="text" size="30" name="area" id="area" class="f-input" value="" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            手机号码</label>
                                        <input type="text" size="30" name="mobile" id="mobile" class="f-input" value="" maxlength="11"
                                            datatype="mobile" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            消费密码</label>
                                        <input type="text" size="30" name="secret" id="secret" class="f-input" value="000000" group="a"
                                            runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户经纬度</label>
                                        <input type="text" size="30" name="jingweidu" id="jingweidu" class="f-input" value=""
                                            group="a" runat="server" />
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
                                    <%if (canLoadMap)
                                      {%>
                                    <script type="text/javascript">
                                        Map.Add({ mapid: "map_canvas", jingweiduid: "jingweidu" });
                                    </script>
                                    <% }
                                      else if (baiduLoadMap)
                                      {%>
                                    <script type="text/javascript">
                                        if ($("#jingweidu").val() != "") {
                                            var jing = 0;
                                            var wei = 0;
                                            var map = new BMap.Map("map_canvas");
                                            map.centerAndZoom(new BMap.Point(116.404, 39.915), 11);

                                            var local = new BMap.LocalSearch(map, {
                                                renderOptions: { map: map }
                                            });
                                            var pointid = $("#jingweidu").val();
                                            if (pointid.indexOf(',') >= 0) {
                                                var one = pointid.split(',');
                                                jing = parseFloat(one[0]);
                                                wei = parseFloat(one[1]);
                                            }
                                            function initMap() {
                                                createMap();
                                                setMapEvent();
                                                addMapControl();
                                            }

                                            function sercarch() {
                                                if (document.getElementById("keyword").value == "") {
                                                    alert("请您输入要查询的区域");
                                                    return false;

                                                }
                                                local.search(document.getElementById("keyword").value);
                                            }

                                            function createMap() {
                                                var point = new BMap.Point(wei, jing);
                                                map.centerAndZoom(point, 15);
                                                function addMarker(point) {
                                                    var marker = new BMap.Marker(point);
                                                    map.addOverlay(marker);
                                                }
                                                for (var i = 0; i < 1; i++) {
                                                    var point = new BMap.Point(wei, jing);
                                                    addMarker(point);
                                                }
                                                var menu = new BMap.ContextMenu();
                                                var txtMenuItem = [{
                                                    text: '以此处为商户位',
                                                    callback: function (p) {
                                                        map.clearOverlays(); var center = map.getCenter();
                                                        var marker = new BMap.Marker(p), px = map.pointToPixel(p);
                                                        map.addOverlay(marker);

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
                                                window.map = map;
                                            }

                                            function setMapEvent() {
                                                map.enableDragging();
                                                map.enableScrollWheelZoom();
                                                map.enableDoubleClickZoom();
                                                map.enableKeyboard();

                                            }
                                            function addMapControl() {
                                                //向地图中添加缩放控件
                                                var ctrl_nav = new BMap.NavigationControl({ anchor: BMAP_ANCHOR_TOP_LEFT, type: BMAP_NAVIGATION_CONTROL_LARGE });
                                                map.addControl(ctrl_nav);
                                                //向地图中添加缩略图控件
                                                var ctrl_ove = new BMap.OverviewMapControl({ anchor: BMAP_ANCHOR_BOTTOM_RIGHT, isOpen: 1 });
                                                map.addControl(ctrl_ove);
                                                //向地图中添加比例尺控件
                                                var ctrl_sca = new BMap.ScaleControl({ anchor: BMAP_ANCHOR_BOTTOM_LEFT });
                                                map.addControl(ctrl_sca);
                                                map.addControl(new BMap.MapTypeControl());
                                            }
                                            initMap();
                                        }
                                        else {
                                            var map = new BMap.Map("map_canvas");
                                            var point = new BMap.Point(116.404, 39.915);
                                            map.centerAndZoom(point, 11);

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
                                        }
                                    </script>
                                    <% } %>
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
                                        <input type="text" size="30" name="bank_name" id="bankname" class="f-input" value=""
                                            runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            开户名</label>
                                        <input type="text" size="30" name="bank_user" id="bankuser" class="f-input" value=""
                                            runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            银行账户</label>
                                        <input type="text" size="30" name="bank_no" id="bankno" class="f-input" value=""
                                            runat="server" />
                                    </div>
                                    <div class="act">
                                        <input type="submit" value="新建" name="commit" id="submit" class="formbutton validator"
                                            runat="server" group="a" onserverclick="submit_ServerClick" />
                                    </div>
                                    <div style="_height:100px;"></div>
                                   <%-- </form>--%>
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
</html>