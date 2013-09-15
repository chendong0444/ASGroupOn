<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.PartnerPage" %>

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
    public string type = "";
    protected double[] position = { 0, 0 };//经纬度
    protected IBranch branch = Store.CreateBranch();
    protected BranchFilter branchfilter = new BranchFilter();
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            type = "edit";
        }
        if (!IsPostBack)
        {
            if (Request["id"] != null && Request["id"].ToString() != "")
            {
                getContent(int.Parse(Request["id"]));

            }
        }

    }

    /// <summary>
    /// 创建分站的方法
    /// </summary>
    private void createBranch()
    {

        branch.partnerid = Helper.GetInt(CookieUtils.GetCookieValue("partner", key), 0);

        branchfilter.username = username.Value;
        int i = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            i = session.Branch.GetCount(branchfilter);
        }
        if (i > 0)
        {
            SetError("已存在此用户名");
            Response.Redirect(Request.Url.AbsoluteUri);

        }
        else
        {
            branch.username = username.Value;
        }

        if (Newpassword.Value != TrueNewpassword.Value)
        {
            SetError("两次密码不一样！");
            Response.Redirect(Request.Url.AbsoluteUri);
        }
        else
        {
            branch.userpwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(Newpassword.Value + PassWordKey, "md5");
        }

        branch.branchname = branchname.Value;
        branch.contact = contact.Value;
        branch.phone = phone.Value;
        branch.address = address.Value;
        branch.mobile = mobile.Value;
        branch.secret = secret.Value.Trim();
        branch.point = jingweidu.Value;
        //提交数据库
        //Maticsoft.BLL.Branch bran= new Maticsoft.BLL.Branch();
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
        //Response.Redirect(Request.Url.AbsoluteUri);
        Response.Redirect("BranchList.aspx");
    }


    /// <summary>
    /// 修改分站的方法
    /// </summary>
    private void updateBranch()
    {
        IBranch mBr = Store.CreateBranch();
        mBr.id = Helper.GetInt(Hid.Value, 0);
        mBr.partnerid = Helper.GetInt(Hpartnerid.Value, 0);

        if (username.Value == HidUsername.Value)//判断是否修改过用户名（当前为未修改）
        {
            mBr.username = username.Value;
        }
        else
        {
            int ii = 0;
            branchfilter.username = Helper.GetString(username.Value, string.Empty);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ii = session.Branch.GetCount(branchfilter);
            }
            if (ii > 0)
            {
                SetError("已有此用户名");
                Response.Redirect(Request.Url.AbsoluteUri);
            }
            else
            {
                mBr.username = username.Value;
            }
        }

        if (settingspassword.Value == "")
        {
            mBr.userpwd = hfPwd.Value;
        }
        else
        {
            if (settingspassword.Value != settingspasswordconfirm.Value)
            {
                SetError("两次密码不一样！");
                Response.Redirect(Request.Url.ToString());
            }
            else
            {
                mBr.userpwd = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(settingspassword.Value + PassWordKey, "md5");
            }
        }

        mBr.branchname = branchname.Value;
        mBr.contact = contact.Value;
        mBr.phone = phone.Value;
        mBr.address = address.Value;
        mBr.mobile = mobile.Value;
        mBr.point = jingweidu.Value;
        mBr.secret = secret.Value;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int updateresult = session.Branch.Update(mBr);
        }
        //branchBLL.Update(mBr);
        SetSuccess("修改成功！");
        //Response.Redirect(Request.Url.AbsoluteUri);
        Response.Redirect("BranchList.aspx");
    }


    /// <summary>
    /// 得到某一分站信息
    /// </summary>
    /// <param name="id"></param>

    private void getContent(int id)
    {
        //branch = branchBLL.GetModel(id);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            branch = session.Branch.GetByID(id);
        }
        Hid.Value = id.ToString();
        Hpartnerid.Value = branch.partnerid.ToString();
        username.Value = branch.username;
        HidUsername.Value = branch.username;//用户名赋值给隐藏域

        //settingspassword.Value = branch.userpwd;
        settingspasswordconfirm.Value = branch.userpwd;
        hfPwd.Value = branch.userpwd;

        branchname.Value = branch.branchname;
        contact.Value = branch.contact;
        phone.Value = branch.phone;
        address.Value = branch.address;
        mobile.Value = branch.mobile;
        jingweidu.Value = branch.point;
        if (branch.point.Length > 0)
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

    protected void ConfirmBtn_Click(object sender, EventArgs e)
    {

        if (type == "edit")
        {
            updateBranch();
        }
        else
        {
            createBranch();
        }
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
                                        <%if (type == "edit")
                                          {%>编辑分站<% }
                                          else
                                          { %>
                                        新建分站<%  } %></h2>
                                </div>
                                <div class="sect">
                                    <div class="wholetip clear">
                                        <h3>
                                            1. 登陆信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            用户名</label>
                                        <input type="text" size="30" name="username" id="username" class="f-input" require="true"
                                            datatype="require" runat="server" group="goto" />
                                        <asp:HiddenField ID="HidUsername" runat="server" />
                                    </div>
                                    <% if (type == "edit")
                                       {%>
                                    <div class="field password">
                                        <label>
                                            新密码</label>
                                        <input type="password" size="30" name="password" id="settingspassword" runat="server"
                                            class="f-input" require="true" datatype="require" />
                                        <span class="hint">如果不想修改密码，请保持空白</span>
                                    </div>
                                    <div class="field password">
                                        <label>
                                            确认新密码</label>
                                        <input type="password" size="30" name="password" id="settingspasswordconfirm" class="f-input"
                                            runat="server" require="true" datatype="require" />
                                    </div>
                                    <%}
                                       else
                                       {%>
                                    <div class="field">
                                        <label>
                                            新密码</label>
                                        <input type="text" size="30" name="password" id="Newpassword" runat="server" class="f-input"
                                            require="true" datatype="require" group="goto" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            确认新密码</label>
                                        <input type="text" size="30" name="password" id="TrueNewpassword" class="f-input"
                                            runat="server" require="true" datatype="require" group="goto" />
                                    </div>
                                    <%} %>
                                    <div class="wholetip clear">
                                        <h3>
                                            2. 基本信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            分站名称</label>
                                        <input type="text" size="30" name="branchname" id="branchname" class="f-input" require="true"
                                            datatype="require" group="goto" runat="server" />
                                    </div>
                                    <input type="hidden" size="30" name="Hid" id="Hid" class="f-input" datatype="require"
                                        require="true" runat="server" />
                                    <input type="hidden" size="30" name="Hpartnerid" id="Hpartnerid" class="f-input"
                                        datatype="require" require="true" runat="server" />
                                    <div class="field">
                                        <label>
                                            联系人</label>
                                        <input type="text" size="30" name="contact" id="contact" class="f-input" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            联系电话</label>
                                        <input type="text" size="30" name="phone" id="phone" class="f-input" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            分站地址</label>
                                        <input type="text" size="30" name="address" id="address" class="f-input" datatype="require"
                                            require="true" group="goto" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            手机号码</label>
                                        <input type="text" size="30" name="mobile" id="mobile" class="f-input" maxlength="11"
                                            datatype="mobile" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            消费密码</label>
                                        <input type="text" size="30" name="secret" id="secret" class="f-input" value="000000" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            分站经纬度</label>
                                        <input type="text" size="30" name="jingweidu" id="jingweidu" class="f-input" runat="server" />
                                    </div>
                                    <%if (canLoadMap)
                                      {%>
                                    <div id="map_canvas" style="width: 500px; height: 300px; margin-left: 145px; float: left;">
                                    </div>
                                    <%if (type == "edit")
                                      {%>
                                    <script type="text/javascript">
                                        Map.Add({ mapid: "map_canvas", jingweiduid: "jingweidu", jingweidu: document.getElementById("jingweidu").value });
                                    </script>
                                    <%}
                                      else
                                      { %>
                                    <script type="text/javascript">
                                        Map.Add({ mapid: "map_canvas", jingweiduid: "jingweidu" });
                                    </script>
                                    <%} %>
                                    <%}
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
                                    <div class="act">
                                        <%--<asp:Button ID="ConfirmBtn" runat="server" group="a"  Text="确定" class="formbutton validator" 
                                            onclick="ConfirmBtn_Click" />--%>
                                        <input type="submit" runat="server" group="goto" value="确定" class="formbutton validator"
                                            onserverclick="ConfirmBtn_Click" />
                                        <asp:HiddenField ID="hfPwd" runat="server" />
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
