<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.App" %>

<script runat="server">
    
    protected string cityid;
    protected int a = 0;
    protected int idLocation;
    protected IList<ICategory> iListCategory = null;

    protected string locationFilename;
    protected ILocation ilocation = null;
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Add_Edit))
        {
            SetError("你不具有编辑广告位的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        
        GetCity();
        
        if (Request.HttpMethod == "POST")
        {
            Update();
        }

        if (Request["updateId"] != null && Request["updateId"].ToString() != "")
        {
            UpdateLoad();
        }

    }

    /// <summary>
    /// 获取城市列表
    /// </summary>
    protected void GetCity()
    {
        CategoryFilter filter = new CategoryFilter();
        filter.Zone = "city";
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            iListCategory = session.Category.GetList(filter);
        }
    }

    /// <summary>
    /// 编辑时加载数据
    /// </summary>
    protected void UpdateLoad()
    {
        int strid = Helper.GetInt(Request["updateId"], 0);
        if (strid > 0)
        {
            lblad.Attributes.Add("style", "display:none");
            btnAdd.Attributes.Add("style", "display:none");
            //ilocation = Store.CreateLocation();
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilocation = session.Location.GetByID(strid);
                a = 1;
                //cityid = ilocation.cityid;
            }
        }
    }

    /// <summary>
    /// 修改
    /// </summary>
    /// <param name="id"></param>
    public void Update()
    {
        int strid = Helper.GetInt(Request["updateId"], 0);
        if (strid > 0)
        {
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                ilocation = session.Location.GetByID(strid);
                if (Request["ddlshow"] == "0")
                {
                    ilocation.height = "0";
                    ilocation.cityid = "," + Request["cityall"] + "," + (Request["SeCity"]) + ",";//城市编号
                }
                else
                {
                    ilocation.height = "1";
                    ilocation.cityid = ",0,,";
                }
                if (Request["ddldisplay"] == "0")
                {
                    ilocation.visibility = 0;
                }
                else
                {
                    ilocation.visibility = 1;
                }
                //新增的广告位内容
                //判断是否更改了广告位的内容
                if (!string.IsNullOrEmpty(Request.Files[0].FileName))
                {

                    //判断上传的图片是否符合要求
                    string err = FileProcess(0);
                    if (err != "")
                    {
                        SetError("上传的图片格式不正确");
                        Response.Redirect("SheZhi_Guangao.aspx?id=" + ilocation.id);
                    }
                    else
                    {
                        ilocation.locationname = locationFilename;
                    }

                }
                else
                {
                    //若没有更改广告位的内容，读取隐藏域中的值
                    ilocation.locationname = Request["hidnochangelocationname"];
                }
                if (Request["ddlLocation"] != null && Request["ddlLocation"] != "")
                {
                    ilocation.location = Helper.GetInt(Convert.ToInt32(Request["ddlLocation"]), 1);
                }
                else
                {
                    ilocation.location = 1;
                }
                ilocation.type = Helper.GetInt(Request["txtheight"], 0);
                ilocation.createdate = DateTime.Now;
                ilocation.begintime = Convert.ToDateTime(Request["txtstart"]);
                ilocation.endtime = Convert.ToDateTime(Request["txtend"]);
                ilocation.decpriction = Helper.GetString(Request["txthtml"], String.Empty);
                ilocation.width = Helper.GetString(Request["txttitle"], String.Empty);
                ilocation.pageurl = Request["pageurltxt"];

                int r = session.Location.Update(ilocation);
                if (r > 0)
                {
                    SetSuccess("修改成功！");
                    Response.Redirect("SheZhi_GongGaoList.aspx");
                }
                else
                {
                    SetError("修改失败！");
                    Response.Redirect("SheZhi_GongGaoList.aspx");
                }
            }
        }
    }

    /// <summary>
    /// 对上传的图片进行处理
    /// </summary>
    /// <param name="i"></param>
    private string FileProcess(int i)
    {

        // 初始化一大堆变量
        string attachdir = PageValue.WebRoot + "upload/images";     // 上传文件保存路径，结尾不要带/
        int dirtype = 1;                 // 1:按天存入目录 2:按月存入目录 3:按扩展名存目录  建议使用按天存
        int maxattachsize = 2097152;     // 最大上传大小，默认是2M
        string upext = "txt,rar,zip,jpg,jpeg,gif,png,swf,wmv,avi,wma,mp3,mid";    // 上传扩展名
        int msgtype = 2;                 //返回上传参数的格式：1，只返回url，2，返回参数数组
        byte[] file;                     // 统一转换为byte数组处理
        string localname = "";

        string err = "";
        string msg = "''";

        HttpPostedFile postedfile = Request.Files[i];
        // 读取原始文件名
        localname = postedfile.FileName;
        // 初始化byte长度.
        file = new Byte[postedfile.ContentLength];

        // 转换为byte类型
        System.IO.Stream stream = postedfile.InputStream;
        stream.Read(file, 0, postedfile.ContentLength);
        stream.Close();
        if (file.Length == 0) err = "";
        else
        {
            if (file.Length > maxattachsize) err = "文件大小超过" + maxattachsize + "字节";
            else
            {
                string attach_dir, attach_subdir, filename, extension, target;

                // 取上载文件后缀名
                extension = GetFileExt(localname);

                if (("," + upext + ",").IndexOf("," + extension + ",") < 0) err = "上传文件扩展名必需为：" + upext;
                else
                {
                    switch (dirtype)
                    {
                        case 2:
                            attach_subdir = "month_" + DateTime.Now.ToString("yyMM");
                            break;
                        case 3:
                            attach_subdir = "ext_" + extension;
                            break;
                        default:
                            attach_subdir = "day_" + DateTime.Now.ToString("yyMMdd");
                            break;
                    }
                    attach_dir = attachdir + "/" + attach_subdir + "/";

                    // 生成随机文件名
                    Random random = new Random(DateTime.Now.Millisecond);
                    filename = DateTime.Now.ToString("yyyyMMddhhmmss") + random.Next(10000) + "." + extension;
                    target = attach_dir + filename;
                    locationFilename = target;//记录广告位内容路径
                    try
                    {
                        CreateFolder(Server.MapPath(attach_dir));
                        System.IO.FileStream fs = new System.IO.FileStream(Server.MapPath(target), System.IO.FileMode.Create, System.IO.FileAccess.Write);
                        fs.Write(file, 0, file.Length);
                        fs.Flush();
                        fs.Close();
                    }
                    catch (Exception ex)
                    {
                        err = ex.Message.ToString();
                    }
                }
            }
        }

        return err;
    }

    string GetFileExt(string FullPath)
    {
        if (FullPath != "") return FullPath.Substring(FullPath.LastIndexOf('.') + 1).ToLower();
        else return "";
    }
    void CreateFolder(string FolderPath)
    {
        if (!System.IO.Directory.Exists(FolderPath)) System.IO.Directory.CreateDirectory(FolderPath);
    }
    
   
</script>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">

    function checkallcity() {
        var str = $("#cityall").attr('checked');
        if (str) {
            $('[name=SeCity]').attr('disabled', true);
            $('[name=SeCity]').attr('checked', false);
        }
        else {
            $('[name=SeCity]').attr('disabled', false);
        }
    }
    var num = 0;
    function addItem(id) {
        var row, cell, str;
        row = document.getElementById(id).insertRow(-1);
        if (row != null) {
            cell = row.insertCell(-1);
            cell.innerHTML = "<div class=\"field\" ><label> 广告标题</label><input class=\"f-input\" group=\"goto\" require=\"true\" datatype=\"require\"  name=\"txttitle" + (num + 1) + "\" ></div><div class=\"field\" ><label>广告内容</label><input type=\"file\" class=\"f-input\" name=\"locationnametxt" + (num + 1) + "\"></div><div class=\"field\" ><label>链接地址</label><input  class=\"f-input\" name=\"urltxt" + (num + 1) + "\"></div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type=\"button\" value=\"删除\" onclick='deleteitem(this," + '"' + "tb" + '"' + ");'>";
        }

        num++;
    }
    function deleteitem(obj, id) {
        var rowNum, curRow3
        curRow = obj.parentNode.parentNode;
        rowNum = document.getElementById(id).rows.length - 1;
        document.getElementById(id).deleteRow(curRow.rowIndex);
    }
    function adType() {
        var str = $("#ddlshow").val();
        if (str == 0) {
            $("#Div4").show();
            $("#Div7").removeClass("field");
            $("#tdiv").removeClass("ad_box");
            $("#Div8").hide();
        }
        else {
            $("#Div4").hide();
            $("#Div7").addClass("field");
            $("#tdiv").addClass("ad_box");
            $("#Div8").show();
        }
    }
   
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
                                    <h1>
                                        <a href="SheZhi_GongGaoList.aspx" style="color: black; font-size: 20px;">列表显示</a>
                                    </h1>
                                </div>
                                <div class="field" id="location">
                                    <label id="area">广告类型</label>
                                    <select name="ddlshow" id="ddlshow"  onchange="adType();">
                                        <option value="0" <%if(ilocation.height == "0"){%> selected="selected" <%} %>>团购首页广告
                                        </option>
                                        <option value="1" <%if(ilocation.height == "1"){%> selected="selected" <%} %>>商城首页广告
                                        </option>
                                    </select>
                                </div>
                                <div class="field" id="Div4" name="Div4" <%if(ilocation.height == "1"){%> style="display:none" <% } %>>
                                    <label>
                                        城市</label>
                                    <div class="city-box" id="cityother">
                                        <%if (Request["updateId"] != null)
                                          {
                                              if (Request["updateId"] == "0")
                                              { %>
                                        <input type="checkbox" name="cityall" id="Checkbox1" value="0" checked="checked"
                                            onclick="checkallcity()" />全部城市
                                        <%}
                                            if (ilocation.cityid != null && ilocation.cityid != "" && ilocation.cityid.Contains(",0,"))
                                             {
                                        %>
                                        <input type="checkbox" name="cityall" id="cityall" value="0" checked="checked" onClick="checkallcity()" />全部城市
                                        <%}

                                              else
                                              {
                                                  if (Request["updateId"] != "0")
                                                  {
                                                      
                                        %>
                                        <input type="checkbox" name="cityall" id="cityall" value="0" onClick="checkallcity()" />全部城市
                                        <% }
                                              }%>
                                        <% }
                                          else
                                          {%>
                                        <input type="checkbox" name="cityall" value="0" id="cityall" checked="checked" onClick="checkallcity()" />全部城市
                                        <% }%>
                                        <%foreach (ICategory model in iListCategory)
                                          { %>
                                        <%
                                            if (Request["updateId"] != null)
                                            {
                                                if (ilocation.cityid != null && ilocation.cityid != "" && ilocation.cityid.Contains("," + model.Id.ToString() + ","))
                                                {
                                        %>
                                        <%if (ilocation.cityid.Contains(",0,"))
                                          { %>
                                        <input type="checkbox" name="SeCity" value="<%=model.Id %>" checked="checked" disabled="disabled" /><%=model.Name%>
                                        <% }
                                          else
                                          {%>
                                        <input type="checkbox" name="SeCity" value="<%=model.Id %>" checked="checked" /><%=model.Name%>
                                        <% }%>
                                        <% }
                                                else
                                                {%>
                                        <%if (ilocation.cityid != null && ilocation.cityid != "" && ilocation.cityid.Contains(",0,"))
                                          { %>
                                        <input type="checkbox" name="SeCity" value="<%=model.Id %>" disabled="disabled" /><%=model.Name%>
                                        <% }
                                          else
                                          {%>
                                        <input type="checkbox" name="SeCity" value="<%=model.Id %>" /><%=model.Name%>
                                        <% }%>
                                        <% }
                                            }
                                            else
                                            {%>
                                        <input type="checkbox" name="SeCity" value="<%=model.Id %>" disabled="disabled" /><%=model.Name%>
                                        <% }%>
                                        <% }%>
                                    </div>
                                    <font style="color: red" id="Font4"></font>
                                </div>
                                <div <%if(a==0) {%> class="field" <%} %>id="Div7">
                                    <label id="lblad" runat="server">
                                        广告内容</label>
                                    <input type="button" value="添加" id="btnAdd" onClick="addItem('tb')" runat="server"/>
                                    <div id="tdiv" <%if(a==0) {%>class="ad_box" <%} %>>
                                        <div class="field" id="Div1">
                                            <label>广告标题</label>
                                            <input type="text" name="txttitle" id="txttitle" require="true" datatype="require" class="f-input" group="goto" value="<%=ilocation.width %>" />
                                            <font style="color: red" id="Font1"></font>
                                        </div>
                                        <div class="field" id="field_notice">
                                            <label>广告内容</label>
                                            <input type="hidden" name="hidnochangelocationname" value="<%=ilocation.locationname %>" />
                                            <span name="nochangelocationname" id="nochangelocationname"><%=ilocation.locationname %></span>
                                            <input type="file" name="locationname" id="locationname" class="f-input" runat="server" />
                                            <div class="field">
                                                <font id="firstpage" style="display: none">广告位置商城首页展示，图片高度为298px，宽度为736px
                                                </font><font id="rightpage" style="display: none">广告位置商城右侧展示，图片宽度为233px
                                                </font>
                                            </div>
                                        </div>
                                        <div class="field" id="Div5">
                                            <label>链接地址</label>
                                            <input type="text" id="pageurltxt" name="pageurltxt" class="f-input" value="<%=ilocation.pageurl %>" />
                                        </div>
                                        <div class="field" id="Div6">
                                            <label>
                                            </label>
                                            <span class="inputtip">例：http://www.example.com &nbsp;"http://"不可省略</span>
                                        </div>
                                        <table id="tb" style="margin-left: 1px;">
                                        </table>
                                    </div>
                                </div>
                                <div class="field" id="Div2">
                                    <label>开始日期</label>
                                    <input name="txtstart" id="txtstart" datatype="date" class="h-input" value="<%=ilocation.begintime.ToString("yyyy-MM-dd") %>" style="width: 120px;" type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});" />
                                    <font style="color: red" id="Font2"></font>
                                </div>
                                <div class="field" id="Div3">
                                    <label>结束日期</label>
                                    <input name="txtend" id="txtend" datatype="date" class="h-input" value="<%=ilocation.endtime.ToString("yyyy-MM-dd") %>" style="width: 120px;" type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});" />
                                    <font style="color: red" id="Font3"></font>
                                </div>
                                <div class="field" style="display: none;">
                                    <label>html代码</label>
                                    <input type="text" name="txthtml" id="txthtml" TextMode="MultiLine" require="true" datatype="require" class="f-input" group="goto" value="<%=ilocation.decpriction %>" />
                                </div>
                                <div class="field" id="height">
                                    <label>排序</label>
                                    <input type="text" name="txtheight" id="txtheight" require="true" datatype="number" class="number" group="goto" <%if(string.IsNullOrEmpty(ilocation.type.ToString())){%> value="0" <%} else{%> value="<%=ilocation.type%>" <%} %> />
                                    <span class="inputtip">请填写数字，数值大到小排序</span> <font style="color: red" id="fhei"></font>
                                </div>
                                <div class="field" id="vis">
                                    <label>是否显示</label>
                                    <select name="ddldisplay">
                                        <option value="1" <%if(ilocation.visibility == 1){%> selected="selected" <%} %> >显示
                                        </option>
                                        <option value="0" <%if(ilocation.visibility == 0){%> selected="selected" <%} %>>隐藏
                                        </option>
                                    </select>
                                </div>
                                <div class="field" id="Div8">
                                    <label>显示位置</label>
                                    <select name="ddlLocation">
                                        <option value="1" <%if(ilocation.location == 1){%> selected="selected" <%} %> >上面显示
                                        </option>
                                        <option value="3"  <%if (ilocation.location == 3){%> selected="selected" <%} %>>下面显示
                                        </option>
                                    </select> <span style="color: #666;">只适用于京东模板</span>
                                </div>  
                                <div class="act">
                                    <input id="Submit1" type="submit" value="保存" name="commit" class="validator formbutton" group="g" />
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