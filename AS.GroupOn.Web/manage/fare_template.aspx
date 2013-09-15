<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="AS.Common.Utils" %>
<script runat="server">
    protected IPagers<IFareTemplate> pager = null;
    protected IList<IFareTemplate> iListFareTemplate = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FareTemplate_List))
        {
            SetError("你不具有查看运费模版的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        FareTemplateFilter filter = new FareTemplateFilter();
        url = url + "&page={0}";
        url = "fare_template.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(FareTemplateFilter.ID_ASC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.FareTemplate.GetPager(filter);
        }
        iListFareTemplate = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);

        int id = Helper.GetInt(Request["del"], 0);
        if(id>0)
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FareTemplate_Delete))
            {
                SetError("你不具有删除运费模版的权限！");
                Response.Redirect("fare_template.aspx");
                Response.End();
                return;

            }
        
        int i = 0;
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            i = session.FareTemplate.Delete(id);
        }
        if (i > 0)
        {
            SetSuccess("删除成功！！");
            Response.Redirect("fare_template.aspx");
            Response.End();
        }
        }
    }
</script>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    var add_id = 1;
    function templatedel(id) {
        var a = $("#add_" + id);
        var p = a.parent();
        p.remove();
    }

    function templateadd() {
        add_id = add_id + 1;
        $(".othercitys").append("<li style='height: 55px;line-height: 28px;'>其他城市：<input type='text' fare='city' class='numberkdqt' ><br>首件运费价格：<input type='text' fare='one' class='numberkd'>每增加：<input type='text' size='10' fare='number' size='10' class='numberkd'>件，运费增加：<input fare='two' size='10' type='text' class='numberkd'>元&nbsp;&nbsp;<input fare='del' href='javascript:void(0)' id='add_" + add_id + "' onclick='templatedel(" + add_id + ")' value='删除' class='btn' type='button' ></li>");

    }
    function templateaddsave() {
        var templatename = $("#templatename").attr("value");
        var defaultone = $("#default").find("input[fare='one']").attr("value");
        var defaultnumber = $("#default").find("input[fare='number']").attr("value");
        var defaulttwo = $("#default").find("input[fare='two']").attr("value");
        var error = "";
        if (templatename == "") {
            error = "模板名称不能为空\r\n";
        }
        var fareone = $("input[fare='one']");
        for (var i = 0; i < $(fareone).length; i++) {
            if (isNaN(parseFloat($(fareone).eq(i).attr("value")))) {
                error = error + "首件运费应为货币类型\r\n";
                break;
            }
        }
        var number = $("input[fare='number']");
        for (var i = 0; i < $(number).length; i++) {
            if (isNaN(parseInt($(number).eq(i).attr("value")))) {
                error = error + "数量应为整型\r\n";
                break;
            }
        }

        var two = $("input[fare='two']");
        for (var i = 0; i < $(two).length; i++) {
            if (isNaN(parseFloat($(two).eq(i).attr("value")))) {
                error = error + "次件运费应为货币类型\r\n";
                break;
            }
        }

        var city = $("input[fare='city']");
        for (var i = 0; i < $(city).length; i++) {
            if ($(city).eq(i).val() == "") {
                error = error + "其他城市如果为空请删除\r\n";
                break;
            }
        }

        if (error != "") {
            alert(error);
            return;
        } //{"fare":[{"cityid":"0","one":2.2,"number":3,"two":1,"cityname":"默认城市"}]}
        else {
            var json = "";
            json = json + "{\"fare\":[{\"cityid\":\"0\",\"one\":" + defaultone + ",\"number\":" + defaultnumber + ",\"two\":" + defaulttwo + ",\"cityname\":\"默认城市\"}";
            var othercitys = $(".othercitys").find("li");
            for (var i = 0; i < $(othercitys).length; i++) {
                var line = $(othercitys).eq(i);
                json = json + ",{\"cityid\":\"0\",\"one\":" + $(line).find("input[fare='one']").attr("value") + ",\"number\":" + $(line).find("input[fare='number']").attr("value") + ",\"two\":" + $(line).find("input[fare='two']").attr("value") + ",\"cityname\":\"" + $(line).find("input[fare='city']").attr("value") + "\"}";
            }
            json = json + "]}";
            if ($("#edit").length == 0) {
                var u = webroot + "ajax/fare_template.aspx?action=addsave";
                $.ajax({
                    type: "POST",
                    url: u,
                    data: { "name": templatename, "value": json }, // "name="+templatename+"&value="+,
                    success: function (msg) {
                        alert("保存成功");
                        window.location = "fare_template.aspx";
                        X.boxClose();
                    }
                });
            }
            else {
                u = webroot + "ajax/fare_template.aspx?action=editsave&id=" + $("#edit").val();
                $.ajax({
                    type: "POST",
                    url: u,
                    data: { "name": templatename, "value": json }, // "name="+templatename+"&value="+,
                    success: function (msg) {
                        alert("保存成功");
                        X.boxClose();
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
        
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        运费模板管理</h2>
                                        <div class="search">
                                    <ul class="filter" style="top: 0">
                                        <li><a  class="ajaxlink" href="<%=PageValue.WebRoot %>ajax/fare_template.aspx?action=add">
                                            新建运费模版</a></li>
                                    </ul></div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='35%'>
                                                ID
                                            </th>
                                            <th width='35%'>
                                                运费模板名称
                                            </th>
                                            <th width='30%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListFareTemplate != null && iListFareTemplate.Count > 0)
                                          {
                                              int i = 1;
                                              foreach (IFareTemplate faretemplateinfo in iListFareTemplate)
                                              {

                                                  if (i % 2 == 0)
                                                  {%>
                                        <tr class="alt">
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=faretemplateinfo.id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=faretemplateinfo.name%>
                                                </div>
                                            </td>
                                            <td>
                                                <a class="ajaxlink" href="<%=PageValue.WebRoot %>ajax/fare_template.aspx?action=edit&id=<%=faretemplateinfo.id %>">
                                                    编辑</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="fare_template.aspx?del=<%=faretemplateinfo.id %>" ask="确定删除吗？">删除</a>
                                            </td>
                                        </tr>
                                        <% }
                                                  else
                                                  {%>
                                        <tr>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=faretemplateinfo.id %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=faretemplateinfo.name %>
                                                </div>
                                            </td>
                                            <td>
                                                <a class="ajaxlink" href="<%=PageValue.WebRoot %>ajax/fare_template.aspx?action=edit&id=<%=faretemplateinfo.id %>">
                                                    编辑</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="fare_template.aspx?del=<%=faretemplateinfo.id %>" ask="确定删除吗？">删除</a>
                                            </td>
                                        </tr>
                                        <% }
                                                  i++;

                                              }
                                          } %>
                                        <tr>
                                            <td colspan="6">
                                                <%=pagerHtml %>
                                            </td>
                                        </tr>
                                    </table>
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

