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
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    IProduct promodel = Store.CreateProduct();
    public NameValueCollection _system = null;
    protected NameValueCollection sysmodel = new NameValueCollection();
    public string inven = "";
    public string bulletin = "";
    public string type = "";
    public string remarktype = "";
    protected string key = FileUtils.GetKey();
    protected int ires = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _system = WebUtils.GetSystem();
        if (!Page.IsPostBack)
        {
            initDropdown();
            initPage();

        }

        if (Request.HttpMethod == "POST")
        {
            if (CookieUtils.GetCookieValue("partner", key) != String.Empty)
            {
                if (Request["id"] != null && Request["id"].ToString() != "")
                {
                    UpdateContent();

                }
                else
                {
                    addContent();
                }
                int maxid = 0;
                ProductFilter filter = new ProductFilter();
                IProduct product = Store.CreateProduct();
                using (IDataSession sesssion = AS.GroupOn.App.Store.OpenSession(false))
                {
                    maxid = Helper.GetInt(sesssion.Product.SelMaxId(filter), 0);
                    product = sesssion.Product.GetByID(maxid);
                }

                if (product.open_invent != 1)
                {
                    Response.Redirect("ProductList.aspx", true);
                }
            }
            else
            {
                SetError("您没有登录，请登录");
                Response.Redirect(GetUrl("后台管理", "Login.aspx?type=merchant"));
                Response.End();
            }
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
        CategoryFilter catefilter = new CategoryFilter();
        catefilter.Zone = "brand";
        IList<ICategory> ilistcate = null;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            ilistcate = session.Category.GetList(catefilter);
        }
        foreach (ICategory item in ilistcate)
        {
            ListItem li = new ListItem();
            li.Text = item.Name;
            li.Value = item.Id.ToString();
            ddlbrand.Items.Add(li);
        }
        ddlbrand.DataBind();

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
        if (CookieUtils.GetCookieValue("partner", key) == null || CookieUtils.GetCookieValue("partner", key) == "")
        {
            Response.Redirect(WebRoot + "login.aspx?action=merchant");
        }


        if (Request["id"] != null && Request["id"].ToString() != "")
        {
            type = "edit";
            IProduct promodel = Store.CreateProduct();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                promodel = session.Product.GetByID(Helper.GetInt(Request["id"], 0));
            }

            if (promodel != null)
            {
                createproduct.Value = promodel.productname;
                market_price.Value = promodel.price.ToString();

                #region 项目的颜色或者尺寸
                //string[] bulletinteam = promodel.bulletin.Replace("{", "").Replace("}", "").Split(',');
                //for (int i = 0; i < bulletinteam.Length; i++)
                //{
                //    string txt = bulletinteam[i];

                //    if (bulletinteam[i] != "")
                //    {

                //        if (bulletinteam[i].Split(':')[0] != "" && bulletinteam[i].Split(':')[1] != "")
                //        {
                //            bulletin += "<tr>";
                //            bulletin += "<td>";
                //            bulletin += "属性：<input type=\"text\" name=\"StuNamea" + i + "\" value=" + bulletinteam[i].Split(':')[0] + ">数值：<input type=\"text\" name=\"Stuvaluea" + i + "\" value=" + bulletinteam[i].Split(':')[1].Replace("[", "").Replace("]", "") + "><input type=\"button\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
                //            bulletin += "</td>";
                //            bulletin += "</tr>";

                //        }
                //    }
                //}
                #endregion

                //createsort_order.Value = promodel.sortorder.ToString();
                ddlinventory.SelectedValue = promodel.open_invent.ToString();
                createdetail.Value = promodel.detail;

                if (promodel.status == 1)
                {
                    lblstatus.Text = "上架";
                }
                else if (promodel.status == 2)
                {
                    lblstatus.Text = "被拒绝";
                    remarktype = "Y";
                    remark.Value = promodel.ramark;
                }
                else if (promodel.status == 4)
                {
                    lblstatus.Text = "待审核";
                }
                else if (promodel.status == 8)
                {
                    lblstatus.Text = "下架";
                }
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
        string createUpload = "";

        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            promodel = session.Product.GetByID(Helper.GetInt(Request["id"], 0));
        }
        promodel.productname = createproduct.Value;
        promodel.price = decimal.Parse(market_price.Value);

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
        //promodel.sortorder = int.Parse(createsort_order.Value);
        promodel.open_invent = int.Parse(ddlinventory.SelectedValue);
        promodel.detail = createdetail.Value;
        promodel.status = 4;

        if (Image.FileName != null)
        {
            createUpload = WebUtils.setUpload();

        }
        if (Image.FileName != null && Image.FileName != "")
        {
            #region 上传图片

            //判断上传文件的大小
            if (Image.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传

            string uploadName = Image.FileName;//获取待上传图片的完整路径，包括文件名 

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
                    if (!Directory.Exists(path))
                    {
                        Directory.CreateDirectory(path);

                    }
                    Image.PostedFile.SaveAs(path + pictureName);

                    //生成缩略图
                    string strOldUrl = path + pictureName;
                    string strNewUrl = path + "small_" + pictureName;
                    ImageHelper.CreateThumbnailNobackcolor(strOldUrl, strNewUrl, 235, 150);

                    //图片加水印
                    string drawuse = "";
                    string drawimgType = "";
                    ImageHelper.DrawImgWord(createUpload + "\\" + pictureName, ref drawuse, ref drawimgType, _system);
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
            //修改信息的时候，将该产品下的项目信息也修改
            IList<ITeam> ilistteam = null;
            TeamFilter tfilter = new TeamFilter();
            tfilter.productid = promodel.id;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilistteam = session.Teams.GetList(tfilter);
            }
            if (ilistteam != null)
            {
                foreach (ITeam teammodel in ilistteam)
                {
                    if (teammodel != null)
                    {
                        teammodel.open_invent = promodel.open_invent;
                        teammodel.bulletin = promodel.bulletin;
                        teammodel.Partner_id = promodel.partnerid;
                        teammodel.inventory = promodel.inventory;
                        teammodel.invent_result = promodel.invent_result;

                        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                        {
                            int i = session.Teams.Update(teammodel);
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
                Response.Redirect("ProductADD.aspx?id=" + Helper.GetInt(Request["id"], 0));
            }
        }
        else
        {
            SetError("修改产品失败！");
        }
    }


    private void addContent()
    {
        string createUpload = "";
       
        promodel.productname = createproduct.Value;
        promodel.price = decimal.Parse(market_price.Value);
        promodel.partnerid = int.Parse(CookieUtils.GetCookieValue("partner", key));
        promodel.bulletin = addcolor();
        //promodel.sortorder = int.Parse(createsort_order.Value);
        promodel.open_invent = int.Parse(ddlinventory.SelectedValue);
        promodel.detail = createdetail.Value;
        promodel.status = 4;
        promodel.team_price = decimal.Parse(Team_price.Value);
        promodel.brand_id = int.Parse(ddlbrand.SelectedValue);
        promodel.summary = createsummary.Value;
        if (Image.FileName != null)
        {
            createUpload = WebUtils.setUpload();

        }
        if (Image.FileName != null && Image.FileName != "")
        {
            #region 上传图片

            //判断上传文件的大小
            if (Image.PostedFile.ContentLength > 512000)
            {
                SetError("请上传 512KB 以内的图片!");
                return;
            }//如果文件大于512kb，则不允许上传

            string uploadName = Image.FileName;//获取待上传图片的完整路径，包括文件名 

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
                    if (!Directory.Exists(path))
                    {
                        Directory.CreateDirectory(path);

                    }
                    Image.PostedFile.SaveAs(path + pictureName);

                    //生成缩略图
                    string strOldUrl = path + pictureName;
                    string strNewUrl = path + "small_" + pictureName;
                    ImageHelper.CreateThumbnailNobackcolor(strOldUrl, strNewUrl, 235, 150);

                    //图片加水印
                    string drawuse = "";
                    string drawimgType = "";
                    ImageHelper.DrawImgWord(createUpload + "\\" + pictureName, ref drawuse, ref drawimgType, _system);
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
        promodel.status = 1;    //直接上架，不审核
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
        catch (Exception ex)
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

    function show(mydiv) {
        var str = "img" + mydiv;
        alert(str);

        var obj = document.getElementById("img0");
        alert(obj.value);
    }


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
            //            $.ajax({
            //                type: "POST",
            //                url: webroot + "ajax/ajax_key.aspx?key=" + obj.value + "",

            //                success: function (msg) {
            //                    if (msg != "") {
            //                        $("#aa").html(msg);
            //                    }

            //                }
            //            });
        } else {
            $("#key").html("");
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
<body>
    <form id="form2" runat="server">
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
                                          {%>编辑产品<% }
                                          else
                                          { %>
                                        新建产品<%  } %></h2>
                                </div>
                                <div class="sect">
                                    <div class="wholetip clear">
                                        <h3>
                                            1、基本信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            产品名称</label>
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
                                            商品图片</label>
                                        <asp:FileUpload ID="Image" name="Image" class="f-input" Height="30px" Width="694px"
                                            size="80" runat="server" />
                                        <span class="hint">商品图片不能为空 </span>&nbsp;
                                        <label id="ImageSet" class="hint" runat="server">
                                        </label>
                                    </div>
<%--                                    <div class="field">
                                        <label>
                                            产品规格</label>
                                        <input type="button" name="btnAddFile" value="添加" onclick="additem('tb')" /><font
                                            style='color: red'>例如：属性填写：颜色 数值填写：红色|黄色|蓝色</font>
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
--%>                                    <div class="field">
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
                                            <textarea cols="45" style="height: 500px; width: 700px;" rows="5" name="detail" id="createdetail"
                                                class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1',urlType:'abs'}"
                                                runat="server"></textarea></div>
                                    </div>
                                    <%if (type == "edit")
                                      { %>
                                    <div class="field">
                                        <label>
                                            状态</label>
                                        <span class="inputtip">
                                            <asp:Label ID="lblstatus" runat="server"></asp:Label></span>
                                    </div>
                                    <%if (remarktype == "Y")
                                      { %>
                                    <div class="field">
                                        <label>
                                            备注</label>
                                        <div style="float: left;">
                                            <textarea cols="45" rows="5" name="remark" id="remark" class="f-textarea" runat="server"></textarea></div>
                                    </div>
                                    <%} %>
                                    <%} %>
                                    <div class="act">
                                        <input id="leadesubmit" name="commit" type="submit" value="好了，提交" group="g" class="formbutton validator" />
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
