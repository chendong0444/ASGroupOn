<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    
    protected IPagers<IArea> pager = null;
    protected IArea areamodel = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected string ids = "";
    protected string editid = String.Empty;
    protected string cityid = "0";
    protected string citypid = "0";

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Category_Area_Add))
        {
            SetError("你不具有添加商圈的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }

        AreaFilter areafilter = new AreaFilter();
        if (Request["zone"] != null)
        {
            if (Request["zone"].ToString() == "area")
            {
                if (Request["cityids"] != null)
                {
                    ids = Request["cityids"].ToString();
                }
                if (Request["edit"] != null && Request["edit"].ToString() != String.Empty)
                {
                    editid = Request["edit"].ToString();
                    if (Request["button"] == "确定")
                    {
                        UpdataCataLogs(AS.Common.Utils.Helper.GetInt(Request["edit"], 0));
                        Response.Redirect("Type_Area.aspx");
                    }
                    else
                    {
                        EditCataLogs(AS.Common.Utils.Helper.GetInt(Request["edit"], 0));
                    }
                }
                else
                {
                    if (Request["button"] == "确定")
                    {
                        AddCataLogs();
                        Response.Redirect("Type_Area.aspx");
                    }

                }
            }
            else
            {
                Response.Redirect("Type_Area.aspx");
            }
        }


    }

    /// <summary>
    /// 显示区域信息
    /// </summary>
    /// <param name="id"></param>
    private void EditCataLogs(int id)
    {
        if (id != 0)
        {
            IArea area = null;

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                area = session.Area.GetByID(id);
            }

            if (area != null)
            {
                name.Value = area.areaname;
                ename.Value = area.ename;
                display.Value = area.display;
                sort_order.Value = area.sort.ToString();
                cityid = area.cityid.ToString();
                if (cityid != "0")
                {
                    ICategory category = null;
                    CategoryFilter bllCategory = new CategoryFilter();
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        category = session.Category.GetByID(area.cityid);
                    }
                    if (category != null)
                    {
                        if (category.City_pid == 0)
                        {
                            cityid = category.Id.ToString();
                        }
                        else
                        {
                            cityid = category.City_pid.ToString();
                            citypid = category.Id.ToString();
                        }
                    }

                }
            }
        }
    }
    /// <summary>
    /// 更新
    /// </summary>
    /// <param name="id"></param>
    private void UpdataCataLogs(int id)
    {
        if (id != 0)
        {
            IArea area = null;

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                area = session.Area.GetByID(id);

                if (area != null)
                {
                    area.areaname = name.Value;
                    area.ename = ename.Value;
                    area.display = display.Value;
                    area.sort = int.Parse(sort_order.Value);
                    //area.Cityid = int.Parse(this.hid_cityid.Value);
                    if (ids != "")
                    {
                        if (ids.IndexOf(',') > 1)
                        {
                            string[] keys = ids.Split(',');
                            for (int i = 0; i < keys.Length; i++)
                            {
                                area.cityid = int.Parse(keys[1].ToString());
                            }
                        }
                        else
                        {
                            area.cityid = int.Parse(ids);
                        }
                    }

                    session.Area.Update(area);
                }
            }
        }
    }
    /// <summary>
    /// 添加
    /// </summary>
    private void AddCataLogs()
    {
        IArea areamodel = AS.GroupOn.App.Store.CreateArea();
        string id = String.Empty;
        if (ids != "")
        {
            if (ids.IndexOf(',') > 0)
            {
                string[] keys = ids.Split(',');
                for (int i = 0; i < keys.Length; i++)
                {
                    id = keys[1].ToString();
                }
            }
            else
            {
                id = ids;
            }
            areamodel.areaname = this.Request["name"].ToString();
            areamodel.cityid = Convert.ToInt32(id);
            areamodel.display = display.Value.ToUpper();
            areamodel.ename = this.ename.Value;
            areamodel.sort = Convert.ToInt32(this.Request["sort_order"].ToString());
            areamodel.type = "area";
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int idd = session.Area.Insert(areamodel);
            }
        }
        else
        {
            SetError("请您先添加城市");
            Response.Redirect("Type_Chengshi.aspx");
        }
    }
    private void hidden(EventArgs e, object obj)
    {

    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    function changecity(pid) {
        var sels = $("#citylist").find("select");
        var str = "";
        var candel = false;
        var obj = null;
        var citynames = "";
        var cityids = "";
        for (var i = 0; i < sels.length; i++) {
            if (!candel) {
                str = str + "-" + sels.eq(i).val();
                citynames = citynames + "," + sels.eq(i).val();
                cityids = cityids + "," + sels.eq(i).find("option:selected").attr("oid");

            }
            else
                sels.eq(i).remove();

            if (sels.eq(i).attr("pid") == pid) {
                candel = true;
                obj = sels.eq(i);
            }
        }
        if (str.length > 0)
            str = str.substr(1);
        if (citynames.length > 0) {
            citynames = citynames.substr(1);
            cityids = cityids.substr(1);
        }
        $("#area").html(str);
        $("#cityids").val(cityids);
        if (obj != null) {
            var oid = obj.find("option:selected").attr("oid");
            if (oid != null) {

                var u = webroot + "ajax_getcity.aspx?pid=" + oid;
                $.ajax({
                    type: "POST",
                    url: "ajax_getcity.aspx",
                    data: { "pid": oid },
                    success: function (msg) {
                        X.boxClose();
                        if (msg != "") {
                            $("#citylist").append(msg);
                            $("#expressarea").html("");
                        }

                    }
                });
            }
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
        
        <input type="hidden" name="cityids" id="cityids" />
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        区域商圈</h2>
                                    <input id="hid" type="hidden" runat="server" />
                                </div>
                                <div  class="sect">
                                    <table width="96%" class="coupons-table-xq">
                                        <tr>
                                            <td width="120" width="120" style="text-align:right; padding-right:10px;">
                                                <b>选择城市：</b>
                                            </td>
                                            <td>
                                                <div id="citylist" class="cityclass">
                                                </div>
                                                <span id="area" class="hint_kd"></span>
                                                <%if (cityid != "0")
                                                  {
                                                      if (cityid != "0" && citypid != "0")
                                                      {%>
                                                <script type="text/javascript">
                                                    $("#citylist").load('ajax_getcity.aspx?cityid='+<%=cityid %>+'&citypid='+<%=citypid %>+'&as=111', null, function (data) {

                                                    });
                                                </script>
                                                <% }
                                                          else
                                                          {%>
                                                <script type="text/javascript">
                                                    $("#citylist").load('ajax_getcity.aspx?cityid='+<%=cityid %>+'&as=222', null, function (data) {

                                                    });
                                                </script>
                                                <% } %>
                                                <%}
                                                  else
                                                  { %>
                                                <script type="text/javascript">
                                                    $("#citylist").load("ajax_getcity.aspx?pid=0&as=333&cityid=''", null, function (data) {

                                                    });
                                                </script>
                                                <%} %>
                                            </td> 
                                        </tr>
                                        <tr>
                                            <td width="120" style="text-align:right; padding-right:10px;">
                                                <b>区域名称：</b>
                                            </td>
                                            <td>
                                                <input group="city" type="text" name="name" id="name" require="true" datatype="require"
                                                    class="f-input" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="120" style="text-align:right; padding-right:10px;">
                                                <b>英文名称：</b>
                                            </td>
                                            <td>
                                                <input type="text" group="city" name="ename" id="ename" require="true" datatype="english"
                                                    class="f-input" style="text-transform: lowercase;" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="120" style="text-align:right; padding-right:10px;">
                                                <b>导航显示(Y/N)：</b>
                                            </td>
                                            <td>
                                                <input type="text" group="city" name="display" id="display" datatype="english" maxlength="1" class="f-input" style="text-transform: uppercase;"
                                                    runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td width="120" style="text-align:right; padding-right:10px;">
                                                <b>排序(降序)：</b>
                                            </td>
                                            <td>
                                                <input type="text" group="city" name="sort_order" id="sort_order" require="true"
                                                    datatype="number" value="0" class="f-input" runat="server" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                            </td>
                                            <td>
                                                <input type="submit" name="button" group="city" onClick="checkUrl()" class="formbutton validator"
                                                    value="确定" />
                                            </td>
                                        </tr>
                                    </table>
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
