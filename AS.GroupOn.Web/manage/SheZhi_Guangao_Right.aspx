﻿<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
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

    protected string startday = "";
    protected string endday = "";
    protected string locationFilename;
    protected ILocation locationmodel = null;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Set_Add_AddRight))
        {
            SetError("你不具有添加右侧广告位列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        startday = DateTime.Now.ToString("yyyy-MM-dd");
        endday = DateTime.Now.AddDays(6).ToString("yyyy-MM-dd");

        GetCity();

        if (Request.HttpMethod == "POST")
        {
            AddLocation();
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
    /// 添加右侧广告位
    /// </summary>
    protected void AddLocation()
    {
        ILocation locationmodel = Store.CreateLocation();
        int type = 0;
        int visibility = 0;
        if (Request["ddldisplay"] == "0")//0,隐藏，1显示 默认为显示
        {
            visibility = 0;
        }
        else
        {
            visibility = 1;
        }
        if (Request["txtheight"] != null && Request["txtheight"] != "")
        {
            type = Helper.GetInt(Convert.ToInt32(Request["txtheight"]), 0);
        }
        locationmodel.type = type;
        locationmodel.createdate = DateTime.Now;
        locationmodel.visibility = visibility;
        locationmodel.decpriction = Helper.GetString(Request["txthtml"], String.Empty);
        locationmodel.begintime = Helper.GetDateTime(Request["txtstart"], DateTime.MinValue);
        locationmodel.endtime = Helper.GetDateTime(Request["txtend"], DateTime.MinValue);
        //艾尚2.27功能 2012.1.2
        //新增的选项，记录广告显示在团购还是商城 0：团购 1：商城  表字段：height
        if (Request["ddlshow"] == "0")
        {
            locationmodel.height = "0";
            locationmodel.cityid = "," + Request["cityall"] + "," + (Request["SeCity"]) + ",";//城市编号
        }
        else
        {
            locationmodel.height = "1";
            locationmodel.cityid = ",0,,";
        }
        //添加链接地址
        locationmodel.pageurl = Request["pageurltxt"];
        locationmodel.width = Request["txttitle"];
        locationmodel.locationname = Request["txtcontent"];
        locationmodel.location = 2;

        int r = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            r = session.Location.Insert(locationmodel);
        }

        if (r > 0)
        {
            SetSuccess("添加成功！");
            Response.Redirect("SheZhi_GongGaoList.aspx");
        }
        else
        {
            SetSuccess("设置失败");
        }
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
        }
        else {
            $("#Div4").hide();
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
                                    <label id="area">
                                        广告类型</label>
                                    <select name="ddlshow" id="ddlshow" onChange="adType();">
                                        <option value="0">团购右侧广告 </option>
                                        <option value="1">商城右侧广告 </option>
                                    </select>
                                </div>
                                <div class="field" id="Div4" name="Div4">
                                    <label>
                                        城市</label>
                                    <div class="city-box" id="cityother" style="width:70%">
                                        <%if (Request["id"] != null)
                                          {
                                              if (Request["id"] == "0")
                                              { %>
                                        <input type="checkbox" name="cityall" id="Checkbox1" value="0" checked="checked"
                                            onclick="checkallcity()" />全部城市
                                        <%}
                                              if (cityid != null && cityid != "" && cityid.Contains(",0,"))
                                              {
                                        %>
                                        <input type="checkbox" name="cityall" id="cityall" value="0" checked="checked" onClick="checkallcity()" />全部城市
                                        <%}

                                             else
                                             {
                                                 if (Request["id"] != "0")
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
                                            if (Request["id"] != null)
                                            {
                                                if (cityid != null && cityid != "" && cityid.Contains("," + model.Id.ToString() + ","))
                                                {
                                        %>
                                        <%if (cityid.Contains(",0,"))
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
                                        <%if (cityid != null && cityid != "" && cityid.Contains(",0,"))
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
                                <div class="field" id="Div1">
                                    <label>
                                        广告标题</label>
                                    <input type="text" name="txttitle" id="txttitle" require="true" datatype="require"
                                        class="f-input" group="g" value="" />
                                    <font style="color: red" id="Font1"></font>
                                </div>
                                <div class="field" id="field_notice">
                                    <label>
                                        广告内容</label>
                                    <textarea cols="45" rows="5" name="txtcontent" id="Textarea1" class="f-textarea xheditor {upImgUrl:'../upload.aspx?immediate=1&t=2',urlType:'abs'}" style="width:70%"></textarea>
                                </div>
                                <div class="field" id="Div5">
                                    <label>
                                        链接地址</label>
                                    <input type="text" id="pageurltxt" name="pageurltxt" class="f-input" />
                                </div>
                                <div class="field" id="Div6">
                                    <label>
                                    </label>
                                    <span class="inputtip">例：http://www.example.com &nbsp;"http://"不可省略</span>
                                </div>
                                <table id="tb" style="margin-left: 1px;">
                                </table>
                                <div class="field" id="Div2">
                                    <label>
                                        开始日期</label>
                                    <input name="txtstart" id="txtstart" datatype="date" class="h-input" value="<%=startday %>"
                                        style="width: 120px;" type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});" />
                                    <font style="color: red" id="Font2"></font>
                                </div>
                                <div class="field" id="Div3">
                                    <label>
                                        结束日期</label>
                                    <input name="txtend" id="txtend" datatype="date" class="h-input" value="<%=endday %>"
                                        style="width: 120px;" type="text" onFocus="WdatePicker({dateFmt:'yyyy-MM-dd'});" />
                                    <font style="color: red" id="Font3"></font>
                                </div>
                                <div class="field" style="display: none;">
                                    <label>
                                        html代码</label>
                                    <input type="text" name="txthtml" id="txthtml" textmode="MultiLine" require="true"
                                        datatype="require" class="f-input" group="goto" value="" />
                                </div>
                                <div class="field" id="height">
                                    <label>
                                        排序</label>
                                    <input type="text" name="txtheight" id="txtheight" require="true" datatype="number"
                                        class="number" group="goto" value="0" />
                                    <span class="inputtip">请填写数字，数值大到小排序</span> <font style="color: red" id="fhei"></font>
                                </div>
                                <div class="field" id="vis">
                                    <label>
                                        是否显示</label>
                                    <select name="ddldisplay">
                                        <option value="1">显示 </option>
                                        <option value="0">隐藏 </option>
                                    </select>
                                </div>
                                <div class="act">
                                    <input id="Submit1" type="submit" value="保存" name="commit" class="validator formbutton"
                                        group="g" />
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