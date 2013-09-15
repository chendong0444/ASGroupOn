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
   
    public int partnerid = 0;
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        try
        {
            partnerid = int.Parse(Request.QueryString["bid"]);
        }
        catch { }
    }

    /// <summary>
    /// 创建分站的方法
    /// </summary>
    private void createBranch()
    {
        IBranch branch = Store.CreateBranch();
        branch.partnerid = Helper.GetInt(Request.QueryString["bid"],0);
        branch.branchname = branchname.Value;
        branch.contact = contact.Value;
        branch.phone = phone.Value;
        branch.address = address.Value;
        branch.mobile = mobile.Value;
        branch.secret = secret.Value.Trim();
        branch.point = jingweidu.Value;
        branch.username = name.Value;
        branch.userpwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(pwd.Value + PassWordKey, "md5");
        #region ##在商家表添加了销售人员id
        int strSaleId = 0;
        try
        {
            strSaleId = int.Parse(CookieUtils.GetCookieValue("sale", key).ToString());
        }
        catch { }
        //提交数据库
        int addresult = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            addresult = session.Branch.Insert(branch);
        }
        if (addresult > 0)
        {
            SetSuccess("添加成功！");

        }
        else
        {
            SetError("添加失败！");
        }
        Response.Redirect(PageValue.WebRoot+"sale/PartnetBranch.aspx?bid="+Helper.GetInt(Request.QueryString["bid"],0));
        #endregion
    }
    protected void submit_ServerClick(object sender, EventArgs e)
    {
        createBranch();

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
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        新建分站</h2>
                                </div>
                                <div class="sect">
                                    
                                    <div class="wholetip clear">
                                        <h3>
                                            基本信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            分站用户名</label>
                                        <input type="text" size="30" name="name" id="name" class="f-input" value=""
                                            group="a" require="true" datatype="require" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            密码</label>
                                        <input type="text" size="30" name="pwd" id="pwd" class="f-input" value=""
                                            group="a" require="true" datatype="require" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            分站名称</label>
                                        <input type="text" size="30" name="branchname" id="branchname" class="f-input" value=""
                                            group="a" require="true" datatype="require" runat="server" />
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
                                        Map.Add({ mapid: "map_canvas", jingweiduid: "jingweidu" });
                                    </script>
                                    <% }
                                      else if (baiduLoadMap)
                                      {%>
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
                                    <% } %>
                                    <div class="act">
                                        <input type="submit" value="新建" name="commit" id="submit" class="formbutton validator"
                                            runat="server" group="a" onserverclick="submit_ServerClick" onclick="" />
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