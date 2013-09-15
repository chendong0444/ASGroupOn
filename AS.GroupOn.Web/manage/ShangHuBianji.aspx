<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.Domain.Spi" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server" >
    protected int partner_id = 0;
    protected AS.GroupOn.Domain.IPartner partner = new AS.GroupOn.Domain.Spi.Partner();
    protected IList<AS.GroupOn.Domain.ICategory> categoryList = null;
    protected IList<AS.GroupOn.Domain.ICategory> categoryList1 = null;
    protected AS.GroupOn.DataAccess.Filters.CategoryFilter filter = new AS.GroupOn.DataAccess.Filters.CategoryFilter();
    protected AS.GroupOn.DataAccess.Filters.CategoryFilter filter1 = new AS.GroupOn.DataAccess.Filters.CategoryFilter();
    protected string password = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Partner_Edit))
        {
            SetError("你没有编辑商户的权限");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (!IsPostBack)
        {
            partner_id = AS.Common.Utils.Helper.GetInt(Request["update"], 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                partner = session.Partners.GetByID(partner_id);
            }
            if (partner != null)
            {
                password = partner.Password;
                location.Value = partner.Location;
                other.Value = partner.Other;
            }
        }

        //查所有城市
        filter.Zone = "city";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            categoryList = session.Category.GetList(filter);
        }
        //查所有分类
        filter1.Zone = "partner";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            categoryList1 = session.Category.GetList(filter1);
        }
        if (Request.HttpMethod == "POST")
        {
            IPartner parnter = new Partner();
            parnter.Id = AS.Common.Utils.Helper.GetInt(Request["Pid"], 0);
            parnter.Username =AS.Common.Utils.Helper.GetString(Request["Username"],String.Empty);
            //验证商户用户名唯一
            PartnerFilter pfilter = new PartnerFilter();
            pfilter.AddSortOrder(PartnerFilter.ID_DESC);
            IList<IPartner> Lists = null;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
            {
                Lists = session.Partners.GetList(pfilter);
            }
            if (Lists != null)
            {
                foreach (IPartner item in Lists)
                {
                    if (item.Id != AS.Common.Utils.Helper.GetInt(Request["Pid"], 0) && item.Username == AS.Common.Utils.Helper.GetString(Request["Username"], String.Empty))
                    {
                        SetError("用户名已存在");
                        Response.Redirect("ShangHu.aspx");
                        Response.End();
                        return;
                    }
                 
                }
            }
            if (Request["Password"] == "")
            {
                parnter.Password = AS.Common.Utils.Helper.GetString(Request["pwd"], String.Empty);
            }
            else
            {
                parnter.Password = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Request["password"] + PassWordKey, "md5");
            }
            
            parnter.City_id =AS.Common.Utils.Helper.GetInt(Request["SelectOne"],0);
            parnter.Group_id = AS.Common.Utils.Helper.GetInt(Request["SelectTow"],0);
            parnter.Open = Request["shanghuxiu"].ToUpper() == "Y" ? "Y" : "N";
            

                if (FileUpload1.FileName != null && FileUpload1.FileName != "")
                {
                    if (FileUpload1.PostedFile.ContentLength > 512000)
                    {
                        SetError("请上传512KB以内的图片");
                        return;
                    }
                    string FileName1 = FileUpload1.FileName;
                    string ext = System.IO.Path.GetExtension(FileName1).ToLower();
                    if (ext != ".jpg" && ext != ".bmp" && ext != ".jpeg" && ext != ".png" && ext != ".gif")
                    {
                        SetError("上传的图片不合法");
                        Response.Redirect(Request.RawUrl);
                        Response.End();
                        return;
                    }
                    string PictureName1 = "";
                    if (FileUpload1.FileName != "")
                    {
                        int idx = FileName1.IndexOf('.');
                        string extname = FileName1.Substring(idx);
                        PictureName1 = DateTime.Now.Ticks.ToString() + 1 + extname;
                    } try
                    {
                        if (FileName1 != "")
                        {
                            string path = Server.MapPath(WebRoot + "upfile/user/");
                            FileUpload1.PostedFile.SaveAs(path + PictureName1);

                        }
                    }
                    catch (Exception ex)
                    {
                        Response.Write(ex);
                    }
                    PictureName1 = WebRoot + "upfile/user/" + PictureName1;
                    parnter.Image = PictureName1;
                }
                else
                {
                    parnter.Image = Request["Img1"];
                }
           
                if (FileUpload2.FileName!=null && FileUpload2.FileName!="")
                {
                    if (FileUpload2.PostedFile.ContentLength > 512000) 
                    {
                        SetError("请上传512KB以内的图片");
                        return;
                    }
                    string FileName2 = FileUpload2.FileName;
                    string ext = System.IO.Path.GetExtension(FileName2).ToLower();
                    if (ext != ".jpg" && ext != ".bmp" && ext != ".jpeg" && ext != ".png" && ext != ".gif")
                    {
                        SetError("上传的图片不合法");
                        Response.Redirect(Request.RawUrl);
                        Response.End();
                        return;
                    }
                    string PictureName2 = "";
                    if (FileUpload2.FileName != "")
                    {
                        int idx = FileName2.IndexOf('.');
                        string extname = FileName2.Substring(idx);
                     
                        PictureName2 = DateTime.Now.Ticks.ToString() + 2 + extname;
                    } try
                    {
                        if (FileName2 != "")
                        {
                            string path = Server.MapPath(WebRoot + "upfile/user/");
                            FileUpload2.PostedFile.SaveAs(path + PictureName2);

                        }
                    }
                    catch (Exception ex)
                    {
                        Response.Write(ex);
                    }
                    PictureName2 = WebRoot + "upfile/user/" + PictureName2;
                    parnter.Image1 = PictureName2;
                    
                }
                else 
                {
                    parnter.Image1 = Request["Img2"];
                }
           
                if (FileUpload3.FileName!=null && FileUpload3.FileName!="")
                {
                    if (FileUpload3.PostedFile.ContentLength > 512000) 
                    {
                        SetError("请上传512KB以内的图片");
                        return;
                    }
                    string FileName3 = FileUpload3.FileName;
                    string ext = System.IO.Path.GetExtension(FileName3).ToLower();
                    if (ext != ".jpg" && ext != ".bmp" && ext != ".jpeg" && ext != ".png" && ext != ".gif")
                    {
                        SetError("上传的图片不合法");
                        Response.Redirect(Request.RawUrl);
                        Response.End();
                        return;
                    }
                    string PictureName3 = "";
                    if (FileUpload3.FileName != "")
                    {
                        int idx = FileName3.IndexOf('.');
                        string extname = FileName3.Substring(idx);
                     
                        PictureName3 = DateTime.Now.Ticks.ToString() + 3 + extname;
                    } try
                    {
                        if (FileName3 != "")
                        {
                            string path = Server.MapPath(WebRoot + "upfile/user/");
                            FileUpload3.PostedFile.SaveAs(path + PictureName3);

                        }
                    }
                    catch (Exception ex)
                    {
                        Response.Write(ex);
                    }
                    PictureName3 = WebRoot + "upfile/user/" + PictureName3;
                    parnter.Image2 = PictureName3;
                    
                }
                else 
                {
                    parnter.Image2 = Request["Img3"];
                }
              
            parnter.Title =Helper.GetString(Request["title"],"");
            parnter.Homepage = Helper.GetString(Request["homepage"],"");
            parnter.Contact = Helper.GetString(Request["contact"],"");
            parnter.Phone = Helper.GetString(Request["phone"],"");
            parnter.Address = Helper.GetString(Request["address"],"");
            parnter.area = Helper.GetString(Request["area"],"");
            parnter.Mobile = Helper.GetString(Request["mobile"],"");
            parnter.Secret =Helper.GetString(Request["secret"],"");
            parnter.point = Helper.GetString(Request["jingweidu"],"");
            parnter.Location = Helper.GetString(Request["location"],"");
            parnter.Other = Helper.GetString(Request["other"],"");
            parnter.Bank_name = Helper.GetString(Request["bank_name"],"");
            parnter.Bank_user = Helper.GetString(Request["bank_user"],"");
            parnter.Bank_no = Helper.GetString(Request["bank_no"], "");
            parnter.Create_time = DateTime.Now;
            parnter.saleid = Helper.GetString(Request["saleid"], "");
            parnter.Enable = Helper.GetString(Request["Enable"], "");
            parnter.sale_id = Helper.GetString(Request["sale_id"], "");
            parnter.verifymobile = Helper.GetString(Request["verifymobile"], "");
            int count = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                count = session.Partners.Update(parnter);
            }
            if (count > 0)
            {
                SetSuccess("修改成功");
                Response.Redirect("ShangHu.aspx");
                Response.End();
                return;
            }
            else 
            {
                SetError("修改失败");
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
                 
                    <div id="content" class="clear mainwide">
                        <div class="clear box">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        编辑商户</h2>
                                </div>
                                <div class="sect">
                                    <form id="form1" runat="server" method="post" action="ShangHuBianji.aspx" enctype="multipart/form-data">

                                    <div class="wholetip clear">
                                        <h3>
                                            1、登录信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            用户名</label>
                                        <input type="text" size="30" name="Username" id="username" class="f-input" value="<%=partner.Username %>" group="a" require="true" datatype="require" />
                                    </div>
                                    <input type="hidden" name="Pid" value="<%=partner_id %>" />
                                    <div class="field password">
                                        <label>
                                            登录密码</label>
                                        <input type="password" size="30" name="Password" id="Password" class="f-input" value="" group="a"require="true" datatype="require" />
                                        <span class="hint">&nbsp;如果不想修改密码，请保持空白</span>
                                        <input type="hidden" name="pwd" id="pwd" value="<%=password %>" />
                                    </div>
                                    <div class="wholetip clear">
                                        <h3 id="H3_1">
                                            2、标注信息</h3>
                                    </div>
                                     <div class="field" style="height: 38px;">
                                        <label>城市及分类</label>
                                     <select id="SelectOne" name="SelectOne" class="f-input" style="width:160px;"><!--选择分类-->
                                          <option>--选择城市--</option>
                                     <%foreach (AS.GroupOn.Domain.ICategory item in categoryList)
                                                {%>
                                                   <option value="<%=item.Id %>"
                                                   <%
                                                       if (item.Id == partner.City_id)
                                                       {%>
                                                           selected="selected" ><%=item.Name %> </option> 
                                                      <% }
                                                       else {%>
                                                        <option value="<%=item.Id %>"><%=item.Name %></option>
                                                       <%} %>
                                                <%}%>
                                                
                                        </select>
                                        <select id="SelectTwo" name="SelectTow" class="f-input" style="width:160px;"><!--选择分类-->
                                           <option>--选择分类--</option>
                                            <%foreach (AS.GroupOn.Domain.ICategory item in categoryList1 )
                                              {%>
                                                  <option value="<%=item.Id%>"
                                                  <%
                                                      if (item.Id  == partner.Group_id)
                                                      {
                                                      %>
                                                        selected="selected"> <%=item.Name%></option>
                                                      <%}
                                                     else { %>

                                                     <option value="<%=item.Id %>"><%=item.Name %></option>

                                                      <%} %>
                                                 
                                              <%} %>
                                        </select>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户秀</label>
                                        <input type="text" size="30" name="shanghuxiu" id="shanghuxiu" class="number" value="<%=partner.Open %>"
                                            maxlength="1" require="true" group="a" datatype="english" style="text-transform: uppercase;"
                                             /><span class="inputtip">Y:前台商户秀展示 N:不参与前台商户秀</span>
                                    </div>
                                   <div class="field">
                                        <label>
                                            商家图片</label>
                                         <asp:FileUpload ID="FileUpload1" runat="server" Height="31px" Width="694px" />
                                         <input type="hidden" name="Img1" value="<%=partner.Image %>" />
                                         <label class="hint" ><%=partner.Image %></label>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商家图片1</label>
                                        <asp:FileUpload ID="FileUpload2" runat="server" Height="29px" Width="696px" />
                                         <input type="hidden" name="Img2" value="<%=partner.Image1 %>" />
                                        </div>

                                    <div class="field">
                                        <label>
                                            商家图片2</label>
                                         <asp:FileUpload ID="FileUpload3" runat="server" Height="28px" Width="696px" />
                                         <input type="hidden" name="Img3" value="<%=partner.Image2 %>" />
                                        </div>
                                    <div class="wholetip clear">
                                        <h3>
                                            3、基本信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户名称</label>
                                        <input type="text" size="30" name="title" id="title" class="f-input" value="<%=partner.Title %>"
                                            group="a"  require="true" datatype="require"/>
                                    </div>
                                    <div class="field">
                                        <label>
                                            网站地址</label>
                                        <input type="text" size="30" name="homepage" id="homepage" class="f-input" value="<%=partner.Homepage %>"
                                         />
                                    </div>
                                    <div class="field">
                                        <label>
                                            联系人</label>
                                        <input type="text" size="30" name="contact" id="contact" class="f-input" value="<%=partner.Contact %>"
                                         />
                                    </div>
                                    <div class="field">
                                        <label>
                                            联系电话</label>
                                        <input type="text" size="30" name="phone" id="phone" class="f-input" value="<%=partner.Phone %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户地址</label>
                                        <input type="text" size="30" name="address" id="address" class="f-input" value="<%=partner.Address %>" 
                                        datatype="require" group="a" require="true" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            商圈</label>
                                        <input type="text" size="30" name="area" id="area" class="f-input" value="<%=partner.area %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            手机号码</label>
                                        <input type="text" size="30" name="mobile" id="mobile" class="f-input" value="<%=partner.Mobile %>" maxlength="11"
                                            datatype="mobile"/>
                                    </div>
                                    <div class="field">
                                        <label>
                                            消费密码</label>
                                        <input type="text" group="a" size="30" name="secret" id="secret" class="f-input" value="<%=partner.Secret %>"/>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户经纬度</label>
                                        <input type="text" size="30" name="jingweidu" id="jingweidu" class="f-input" value="<%=partner.point %>"
                                            group="a" />
                                    </div>
                                          <div id="preview">
                                        <div id="float_search_bar">
                                            <label>
                                                区域名称：</label>
                                            <input type="text" id="keyword" />
                                            <input class="seach-map" id="search_button" onClick="sercarch()" type="button" value="查找" />
                                        </div>
                                        <div id="map_canvas" style="width: 500px; height: 340px; margin-left: 0px; float: left;
                                            display: block; top: 30px;">
                                        </div>
                                    </div>
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
                                        <input type="text" size="30" name="bank_name" id="bankname" class="f-input" value="<%=partner.Bank_name %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            开户名</label>
                                        <input type="text" size="30" name="bank_user" id="bankuser" class="f-input" value="<%=partner.Bank_user %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            银行账户</label>
                                        <input type="text" size="30" name="bank_no" id="bankno" class="f-input" value="<%=partner.Bank_no %>"/>
                                    </div>
                                    <input type="hidden" value="<%=partner.saleid %>" name="saleid" />
                                    <input type="hidden" value="<%=partner.Enable %>" name="Enable" />
                                     <input type="hidden" value="<%=partner.sale_id %>" name="sale_id" />
                                      <input type="hidden" value="<%=partner.verifymobile %>" name="verifymobile" />
                                    <div class="act">
                                        <input type="submit" value="编辑" class="formbutton validator" />
                                    </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
          
        </div>
      
    </div>
</body>
<% LoadUserControl("_footer.ascx", null); %>