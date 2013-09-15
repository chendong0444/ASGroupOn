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
    protected double[] position = { 0, 0 };//经纬度
    protected string key = FileUtils.GetKey();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (Request.QueryString["Id"] != null)
        {
            strPartnerId = Helper.GetInt(Request.QueryString["Id"].ToString(), 0);
        }
        if (Request.HttpMethod != "POST")
        {
            if (Request.QueryString["Id"] != null)
            {
                getContent(strPartnerId);
            }

            if (Request.QueryString["del"] != null && Request.QueryString["image"] != null)
            {
                int id = int.Parse(Request.QueryString["del"].ToString());
                int index = int.Parse(Request.QueryString["image"].ToString());
                IPartner partner = Store.CreatePartner();
                partner.Id = id;
                
                if (index == 1)
                {
                    partner.Image1 = "";
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int upim1 = session.Partners.UpdateImage1(partner);
                    }
                }
                if (index == 2)
                {
                    partner.Image2 = "";
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int upim1 = session.Partners.UpdateImage2(partner);
                    }
                }
                SetSuccess("删除成功!");
                Response.Redirect("PartnetUpdate.aspx?id=" + id + "");
            }
        }
    }

    private void getContent(int id)
    {
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        IList<IPartner> ilistpartner = null;
        PartnerFilter partfilter = new PartnerFilter();
        partfilter.Id = Helper.GetInt(id, 0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistpartner = session.Partners.GetList(partfilter);
        }
        foreach (IPartner item in ilistpartner)
        {
            //城市分类
            sb1.Append("<select name='city_id' class='f-input' style='width:160px;'>");
            sb1.Append("<option value=''>--选择城市--</option>");
            CategoryFilter catefilter = new CategoryFilter();
            IList<ICategory> ilistcate = null;
            catefilter.Zone = "city";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilistcate = session.Category.GetList(catefilter);
            }
            foreach (ICategory item1 in ilistcate)
            {
                if (item.City_id == item1.Id)
                {
                    sb1.Append("<option value='" + item1.Id + "' selected>" + item1.Name + "</option>");
                }
                else
                {
                    sb1.Append("<option value='" + item1.Id + "' >" + item1.Name + "</option>");
                }
            }

            sb1.Append("</select>");
            //商户分类
            sb2.Append("<select name='group_id' class='f-input' style='width:160px;'>");
            CategoryFilter cafilter = new CategoryFilter();
            IList<ICategory> ilistca = null;
            cafilter.Zone = "partner";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilistca = session.Category.GetList(cafilter);
            }

            foreach (ICategory item2 in ilistca)
            {
                if (item2.Id == item.Group_id)
                {
                    sb2.Append("<option value='" + item2.Id + "' selected>" + item2.Name + "</option>");
                }
                else
                {
                    sb2.Append("<option value='" + item2.Id + "' >" + item2.Name + "</option>");
                }
            }
            sb2.Append("<option value=''>--选择分类--</option>");
            sb2.Append("</select>");
            Literal1.Text = sb1.ToString();
            Literal2.Text = sb2.ToString();
            Hidden1.Value = item.Id.ToString();
            username.Value = item.Username;
            shangwuxiu.Value = item.Open;
            ImageSet.InnerText = item.Image;
            if (item.Image1 != "")
            {
                hfimg1.Value = item.Image1;
                lblImg1.InnerHtml = item.Image1 + "<span>&nbsp;&nbsp;</span><a href='PartnetUpdate.aspx?del=" + item.Id + "&image=1'>删除</a>";
            }
            if (item.Image2 != "")
            {
                hfimg2.Value = item.Image2;
                lblImg2.InnerHtml = item.Image2 + "<span>&nbsp;&nbsp;</span>" + "<a href='PartnetUpdate.aspx?del=" + item.Id + "&image=2'>删除</a>";
            }
            shangwuMingcheng.Value = item.Title;
            homepage.Value = item.Homepage;
            contact.Value = item.Contact;
            phone.Value = item.Phone;
            address.Value = item.Address;
            secret.Value = item.Secret;//消费密码
            mobile.Value = item.Mobile;
            jingweidu.Value = item.point;
            location.Value = item.Location;
            other.Value = item.Other;
            bankname.Value = item.Bank_name;
            bankno.Value = item.Bank_no;
            bankuser.Value = item.Bank_user;
            hdPwd.Value = item.Password;
            hdUID.Value = item.User_id.ToString();
            hdHead.Value = item.Head.ToString();
            area.Value = item.area;
            if (item.point.Length > 0)
            {
                string[] pois = item.point.Split(',');
                if (pois.Length == 2)
                {
                    position[0] = Helper.GetDouble(pois[0], 0);
                    position[1] = Helper.GetDouble(pois[1], 0);
                }
            }
        }
    }
    protected void submit_ServerClick(object sender, EventArgs e)
    {
        IPartner mPatn = Store.CreatePartner();
        mPatn.Id = Helper.GetInt(Hidden1.Value,0);
        if (Request.Form["city_id"].ToString() != "")
        {
            mPatn.City_id = int.Parse(Request.Form["city_id"].ToString());
        }
        else
        {
            mPatn.City_id = 0;
        }
        if (Request.Form["group_id"].ToString() != "")
        {
            mPatn.Group_id = int.Parse(Request.Form["group_id"].ToString());
        }
        else
        {
            mPatn.Group_id = 0;
        }

        if (username.Value == "")
        {
            SetError("商户用户名不能为空！");
            Response.Redirect("PartnetUpdate.aspx?id=" + Hidden1.Value);
        }
        else
        {
            int nameResult = 0;
            PartnerFilter pfilter = new PartnerFilter();
            pfilter.NotId = Helper.GetInt(Request.QueryString["Id"], 0);
            pfilter.Username = Helper.GetString(username.Value, String.Empty);
            using (IDataSession sesssion = AS.GroupOn.App.Store.OpenSession(false))
            {
            nameResult=sesssion.Partners.GetCount(pfilter);
            }
            
            
            if (nameResult>0)
            {
                //说明除了此用户外其他用户也有这个用户名
                SetError("用户名已存在,请重新输入！");
                Response.Redirect(Request.UrlReferrer.AbsoluteUri);
                Response.End();
                return;
            }
            mPatn.Username = username.Value;
        }
        if (pwd.Value != "")
        {

            mPatn.Password =WebUtils.GetPasswordByMD5(pwd.Value);
        }
        else
        {
            mPatn.Password = hdPwd.Value;
        }
        if (shangwuxiu.Value != String.Empty)
            mPatn.Open = shangwuxiu.Value.ToUpper();
        else
            mPatn.Open = "N";
        mPatn.Title = shangwuMingcheng.Value;
        mPatn.Homepage = homepage.Value;
        mPatn.Contact = contact.Value;
        mPatn.Phone = phone.Value;
        mPatn.Address = address.Value;
        mPatn.Mobile = mobile.Value;
        mPatn.point = jingweidu.Value;
        mPatn.Secret = secret.Value;
        mPatn.Location = location.Value;
        mPatn.Other = other.Value;
        mPatn.Bank_name = bankname.Value;
        mPatn.Bank_no = bankno.Value;
        mPatn.Bank_user = bankuser.Value;
        mPatn.User_id = int.Parse(hdUID.Value);
        mPatn.Head = int.Parse(hdHead.Value);
        if (FileUpload1.FileName != null && FileUpload1.FileName.ToString() != "")
        {
            //上传图片
            //判断上传文件的大小
            if (FileUpload1.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传

            string uploadName = FileUpload1.FileName;//获取待上传图片的完整路径，包括文件名 
            string ext = System.IO.Path.GetExtension(uploadName).ToLower();
            if (ext != ".jpg" && ext != ".bmp" && ext != ".jpeg" && ext != ".png" && ext != "gif")
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
                    FileUpload1.PostedFile.SaveAs(path + pictureName);

                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            mPatn.Image = PageValue.WebRoot + "upfile/user/" + pictureName;
        }
        else
        {
            mPatn.Image = ImageSet.InnerText;

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

            string uploadName = FileUpload2.FileName;//获取待上传图片的完整路径，包括文件名 
            string ext = System.IO.Path.GetExtension(uploadName).ToLower();
            if (ext != ".jpg" && ext != ".bmp" && ext != ".jpeg" && ext != ".png" && ext != "gif")
            {
                SetError("上传的图片不合法");
                Response.Redirect(Request.RawUrl);
                Response.End();
                return;
            }
            string pictureName1 = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (FileUpload2.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 
                pictureName1 = DateTime.Now.Ticks.ToString() + 2 + suffix;
            }
            try
            {
                if (uploadName != "")
                {
                    string path = Server.MapPath(PageValue.WebRoot + "upfile/user/");
                    FileUpload2.PostedFile.SaveAs(path + pictureName1);

                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            mPatn.Image1 = PageValue.WebRoot + "upfile/user/" + pictureName1;
        }
        else
        {
            mPatn.Image1 = hfimg1.Value;
        }

        if (FileUpload3.FileName != null && FileUpload3.FileName.ToString() != "")
        {
            //上传图片2
            //判断上传文件的大小
            if (FileUpload3.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传

            string uploadName = FileUpload3.FileName;//获取待上传图片的完整路径，包括文件名 
            string ext = System.IO.Path.GetExtension(uploadName).ToLower();
            if (ext != ".jpg" && ext != ".bmp" && ext != ".jpeg" && ext != ".png" && ext != "gif")
            {
                SetError("上传的图片不合法");
                Response.Redirect(Request.RawUrl);
                Response.End();
                return;
            }
            string pictureName = "";//上传后的图片名，以当前时间为文件名，确保文件名没有重复 
            if (FileUpload3.FileName != "")
            {
                int idx = uploadName.LastIndexOf(".");
                string suffix = uploadName.Substring(idx);//获得上传的图片的后缀名 
                pictureName = DateTime.Now.Ticks.ToString() + 3 + suffix;

            }
            try
            {
                if (uploadName != "")
                {
                    string path = Server.MapPath(PageValue.WebRoot + "upfile/user/");
                    FileUpload3.PostedFile.SaveAs(path + pictureName);

                }
            }
            catch (Exception ex)
            {
                Response.Write(ex);
            }
            mPatn.Image2 = PageValue.WebRoot + "upfile/user/" + pictureName;
        }
        else
        {
            mPatn.Image2 = hfimg2.Value;
        }
        mPatn.area = area.Value;
        IPartner part = Store.CreatePartner();
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            part = session.Partners.GetByID(Helper.GetInt(strPartnerId, 0));
        }
        
        
        if (part!=null)
        {
            mPatn.saleid = part.saleid.ToString();
        }
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            int upresult = session.Partners.Update(mPatn);
        }
        SetSuccess("更新成功！");
        Response.Redirect("PartnetUpdate.aspx?Id=" + Request.QueryString["Id"].ToString(), true);
    }

    #region ################### 接参 ###################
    private int GetSaleId()//接收销售人员id
    {
        int sale_id = 0;
        if (!object.Equals(CookieUtils.GetCookieValue("sale", key), null))
        {
            try
            {
                sale_id = Helper.GetInt(CookieUtils.GetCookieValue("sale", key).ToString(), 0);
            }
            catch { }
        }
        return sale_id;
    }
        #endregion
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
                                        编缉商户</h2>
                                </div>
                                <div class="sect">
                                    
                                    <div class="wholetip clear">
                                        <h3>
                                            1、登录信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            用户名</label>
                                        <input type="text" size="30" readonly="readonly" name="username" id="username" class="f-input"
                                            value="" group="a" require="true" datatype="require" runat="server" />
                                    </div>
                                    <div class="field password">
                                        <label>
                                            登录密码</label>
                                        <input type="text" size="30" name="password" id="pwd" class="f-input" value="" runat="server" />
                                        <span class="hint">如果不想修改密码，请保持空白</span>
                                    </div>
                                    <div class="wholetip clear">
                                        <h3 id="H3_1" runat="server">
                                            2、标注信息</h3>
                                    </div>
                                    <div class="field" style="height: 38px">
                                        <label>
                                            城市及分类</label>
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商户秀</label>
                                        <input type="text" size="30" name="open" id="shangwuxiu" class="number" value=""
                                            maxlength="1" require="true" datatype="english" style="text-transform: uppercase;"
                                            group="a" runat="server" /><span class="inputtip">Y:前台商户秀展示 N:不参与前台商户秀</span>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商家图片</label>
                                        <asp:FileUpload ID="FileUpload1" runat="server" Height="29px" Width="696px" size="80"/>
                                        <label id="ImageSet" class="hint" runat="server">
                                        </label>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商家图片1</label>
                                        <asp:FileUpload ID="FileUpload2" runat="server" Height="28px" Width="694px" size="80"/>
                                        <label id="lblImg1" class="hint" runat="server">
                                        </label>
                                    </div>
                                    <div class="field">
                                        <label>
                                            商家图片2</label>
                                        <asp:FileUpload ID="FileUpload3" runat="server" Height="31px" Width="694px" size="80"/>
                                        <label id="lblImg2" class="hint" runat="server">
                                        </label>
                                    </div>
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
                                            runat="server" datatype="require" require="ture" />
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
                                            group="a" datatype="require" require="true" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            商圈</label>
                                        <input type="text" size="30" name="area" id="area" class="f-input" runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            手机号码</label>
                                        <input type="text" size="30" name="mobile" id="mobile" class="f-input" value="" maxlength="11"
                                            runat="server" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            消费密码</label>
                                        <input type="text" size="30" name="secret" id="secret" class="f-input" value="" group="a"
                                            runat="server" require="true" datatype="require" />
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
                                        <input id="Hidden1" type="hidden" runat="server" />
                                        <input id="hdPwd" type="hidden" runat="server" />
                                        <input id="hdUID" type="hidden" runat="server" />
                                        <input id="hdHead" type="hidden" runat="server" />
                                        <asp:HiddenField ID="hfimg1" runat="server" />
                                        <asp:HiddenField ID="hfimg2" runat="server" />
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