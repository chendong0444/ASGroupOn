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
    int strPartnerId = 0;
    public int partnerid = 0;
    int branchId = 0;
    protected double[] position = { 0, 0 };//经纬度
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        partnerid = Helper.GetInt(Request.QueryString["bid"], 0);
        branchId = Helper.GetInt(Request.QueryString["Id"], 0);
        if (Request.QueryString["Id"] != null)
        {
            getContent(branchId);
        }

        //对商户分店的操作一定要属于销售人员
        int existresult = 0;
        BranchFilter branfilter = new BranchFilter();
        branfilter.table = "(select p.saleid,b.id,b.partnerid from partner p inner join branch b on  p.id=b.partnerid) tt where ','+saleid+',' like '%," + GetSaleId().ToString() + ",%' and id=" + branchId + " and partnerid=" + partnerid;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            existresult = session.Branch.Count(branfilter);
        }
        if(existresult<=0)
        {
            Response.Redirect("PartnetList.aspx");
            return;
        }

    }

    private void getContent(int id)
    {
        IBranch branch = Store.CreateBranch();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            branch = session.Branch.GetByID(id);
        }
        Hid.Value = id.ToString();
        Hpartnerid.Value = branch.partnerid.ToString();
        branchname.Value = branch.branchname;
        contact.Value = branch.contact;
        phone.Value = branch.phone;
        address.Value = branch.address;
        mobile.Value = branch.mobile;
        jingweidu.Value = branch.point;

        if (!string.IsNullOrEmpty(branch.point))
        {
            string[] pois = branch.point.Split(',');
            if (pois.Length == 2)
            {
                position[0] = Helper.GetDouble(pois[0], 0);
                position[1] = Helper.GetDouble(pois[1], 0);
            }
        }

        secret.Value = branch.secret;
    }
    protected void submit_ServerClick(object sender, EventArgs e)
    {
        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            IBranch mBr = Store.CreateBranch();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                mBr = session.Branch.GetByID(Helper.GetInt(Request["id"], 0));
            }
            
            
            mBr.branchname = Request.Form["branchname"];
            mBr.contact = Request.Form["contact"];
            mBr.phone = Request.Form["phone"];
            mBr.address = Request.Form["address"];
            mBr.mobile = Request.Form["mobile"];
            mBr.point = Request.Form["jingweidu"];
            mBr.secret = Request.Form["secret"];
            mBr.id = Helper.GetInt(Request["id"], 0);
            
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int upresult = session.Branch.Update(mBr);
            }
            SetSuccess("更新成功！");
            Response.Redirect("PartnetBranchUpdate.aspx?Id=" + Request.QueryString["Id"].ToString() + "&bid=" + Hpartnerid.Value + "");
        }


    }
    #region ################### 接参 ###################
    private int GetSaleId()//接收销售人员id
    {
        int sale_id = 0;
        if (!object.Equals(CookieUtils.GetCookieValue("sale", key), null))
        {
            try
            {
                sale_id = int.Parse(CookieUtils.GetCookieValue("sale", key).ToString());
            }
            catch { }
        }
        return sale_id;
    }
        #endregion
</script>
<%LoadUserControl("_header.ascx", null); %>
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
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        编辑分站</h2>
                                </div>
                                <div class="sect">
                                   
                                    <div class="wholetip clear">
                                        <h3>
                                            基本信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            分站名称</label>
                                        <input type="text" size="30" name="asd" id="branchname" class="f-input" value=""
                                            group="a" require="true" datatype="require" runat="server" />
                                    </div>
                                    <input type="hidden" size="30" name="Hid" id="Hid" class="f-input" value="" datatype="require"
                                        group="a" require="true" runat="server" />
                                    <input type="hidden" size="30" name="Hpartnerid" id="Hpartnerid" class="f-input"
                                        value="" datatype="require" group="a" require="true" runat="server" />
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
                                            分站地址</label>
                                        <input type="text" size="30" name="address" id="address" class="f-input" value=""
                                            datatype="require" group="a" require="true" runat="server" />
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
                                        <input type="text" size="30" name="secret" id="secret" class="f-input" value="" group="a"
                                            runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            分站经纬度</label>
                                        <input type="text" size="30" name="jingweidu" id="jingweidu" class="f-input" value=""
                                            group="a" runat="server" />
                                    </div>
                                    <%if (canLoadMap)
                                      {%>
                                     <div id="map_canvas" style="width: 500px; height: 300px; margin-left: 145px; float: left;">
                                    </div>
                                    <script type="text/javascript">
                                        Map.Add({ mapid: "map_canvas", jingweiduid: "jingweidu", jingweidu: document.getElementById("jingweidu").value });
                                    </script>
                                    <% }
                                      else if (baiduLoadMap)
                                      {%>
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
                                    <%} %>
                                    <div class="act">
                                        <input id="hdPartnerid" type="hidden" runat="server" />
                                        <input type="submit" value="编缉" name="commit" id="submit" class="formbutton validator"
                                            runat="server" group="a" onserverclick="submit_ServerClick" />
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
</html>