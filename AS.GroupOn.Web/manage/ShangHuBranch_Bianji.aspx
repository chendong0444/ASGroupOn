<%@ Page Language="C#" AutoEventWireup="true"  Inherits ="AS.GroupOn.Controls.AdminPage"%>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    protected string branch_id = String.Empty;
    protected string partner_id = String.Empty;
    protected IBranch branch = null;
    protected BranchFilter filter = new BranchFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack) 
        {
            branch_id = Request["branch_id"];
            partner_id = Request["bid"];
        }
        filter.id =Convert.ToInt32(branch_id);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
        {
            branch = session.Branch.Get(filter);
        }
        jingweidu.Value = branch.point;
    } 
</script>

<%LoadUserControl("_header.ascx", null); %>
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
<body class="newbie">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="partner">
                    
                    <div id="content" class="box-content clear mainwide">
                        <div class="clear box">
                            <div class="box-content">
                                <div class="head" style="height:35px;">
                                    <h2>
                                        新建分店</h2>
                                        
                                </div><ul class="filter">
                                          <li><a href="ShangHuBranch.aspx?bid=<%=partner_id %>">
                                返回分店列表</a></li>
                                        </ul>
                                <div class="sect">
                                    <form id="form1" method="post" enctype="multipart/form-data"  >
                                    <input type="hidden" value="ShanghuBranch_Bianji" name="action" />
                                    <div class="wholetip clear">
                                        <h3>
                                           1. 登陆信息</h3>
                                    </div>
                                       <div class="field">
                                        <label>
                                            用户名</label>
                                        <input type="text" size="30" name="username" id="username" class="f-input" 
                                        group="a" require="true" datatype="require"  value="<%=branch.username %>" />
                                        <input type="hidden"  name="partnerid" value="<%=partner_id %>" />
                                        <input type="hidden" name="id" value="<%=branch_id %>" />
                                    </div>
                                   <div class="field password">
                                        <label>新密码</label>
                                        <input type="password" value="" size="30" name="userpwda" id="userpwda" class="f-input" />
                                         <span class="hint">如果不想修改密码，请保持空白</span>
                                        <input type="hidden" name="userpwd" id="userpwd" value="<%=branch.userpwd %>" /> 
                                    </div>
                                    <div nowrap class="field password">
                                        <label>
                                            确认新密码</label>
                                        <input type="password" value="" size="30" 
                                        name="newuserpwd" id="newuserpwd" class="f-input" />
                                    </div>
                                    <div class="wholetip clear">
                                        <h3>
                                           2. 基本信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>分站名称</label>
                                        <input type="text" size="30" name="branchname" id="branchname" class="f-input" 
                                            group="a" require="true" datatype="require" value="<%=branch.branchname %>"  />
                                    </div>
                                    <div class="field">
                                        <label>
                                            联系人</label>
                                        <input type="text" size="30" name="contact" id="contact" class="f-input" value="<%=branch.contact %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            联系电话</label>
                                        <input type="text" size="30" name="phone" id="phone" class="f-input" value="<%=branch.phone %>"/>
                                    </div>
                                    <div class="field">
                                        <label>
                                            分店地址</label>
                                        <input type="text" size="500" name="address" id="address" class="f-input" 
                                            datatype="require" group="a" require="true"  value="<%=branch.address %>" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            手机号码</label>
                                        <input type="text" size="30" name="mobile" id="mobile" class="f-input"  maxlength="11"
                                            datatype="mobile" value="<%=branch.mobile %>"  />
                                    </div>
                                <%--    <div class="field">
                                        <label>
                                            400验证电话</label>
                                        <input type="text" size="30" name="verifymobile" id="verifymobile" class="f-input"
                                             value="<%=branch.verifymobile %>"  />
                                    </div>--%>
                                    <div class="field">
                                        <label>
                                            消费密码</label>
                                        <input type="text" size="500" name="secret" id="secret" class="f-input"  group="a"
                                             value="<%=branch.secret%>"/>
                                    </div>
                                    <div class="field">
                                        <label>
                                            分店经纬度</label>
                                        <input type="text" size="500" name="jingweidu" id="jingweidu" class="f-input"
                                            group="a" runat="server" />
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
                                    <div class="act">
                                        <input type="submit" value="编辑" name="commit" id="submit" class="formbutton validator" group="a"  />
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
<%LoadUserControl("_footer.ascx", null); %>
