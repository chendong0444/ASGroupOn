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
    protected IPagers<IOprationLog> pager = null;
    protected IList<IOprationLog> iListOprationLog = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected int id = 0;
    string check1 = "";
    string check2 = "";
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Log_List))
        {
            SetError("你不具有查看操作日志列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        //删除选定
        
        if (Request.QueryString["item"] != null)
        {

            string items = Request.QueryString["item"];
            string[] item = items.Split(';');
            foreach (string ids in item)
            {
                int id = Helper.GetInt(ids, 0);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {

                    int i = 0;
                    i = session.OprationLog.Delete(id);
                    if (i > 0)
                    {
                        SetSuccess("删除选中成功！");
                        AS.Common.Utils.WebUtils.LogWrite("删除操作日志", "《删除操作日志记录》Option_LogId:" + id + ",操作员ID：" + AS.Common.Utils.WebUtils.GetLoginAdminID() + "");
                    }
                    else
                    {
                        SetError("删除选中失败！");
                    }
                }

            }
            string key = AS.Common.Utils.FileUtils.GetKey();
            AS.AdminEvent.ConfigEvent.AddOprationLog(AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", key), 0), "删除操作日志", "删除操作日志 ID:" + Request.QueryString["item"].ToString(), DateTime.Now);
            Response.Redirect("Option_Log.aspx?page=" + Helper.GetInt(Request.QueryString["url"], 1));
        }
        OprationLogFilter filter = new OprationLogFilter();
        url = url + "&page={0}";
        url = "Option_Log.aspx?" + url.Substring(1);
        filter.PageSize = 30;

        if (Request.QueryString["startTime"] != null && Request.QueryString["startTime"].ToString() != "")
        {
            url = url + "&startTime=" + Request.QueryString["startTime"];
            string strfirsttime = Request.QueryString["startTime"].ToString();
            filter.FromCreateTime = DateTime.Parse(strfirsttime);
            Session["startTime"] = strfirsttime;
        }
        else
        {
            Session["startTime"] = null;
        }

        if (Request.QueryString["endTime"] != null && Request.QueryString["endTime"].ToString() != "")
        {
            url = url + "&endTime=" + Request.QueryString["endTime"];
            string strendtime = Request.QueryString["endTime"].ToString();
            filter.ToCreateTime = DateTime.Parse(strendtime);
            Session["endtime"] = strendtime;
        }
        else
        {
            Session["endtime"] = null;
        }
        
        filter.AddSortOrder(OprationLogFilter.CREATE_TIME_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.OprationLog.GetPager(filter);
        }
        iListOprationLog = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);

    } 
</script>
 
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
    <form id="form1" runat="server" method="get">
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
                                        操作日志列表</h2>
                                        <div class="search">
                                        时&nbsp;间：
                                            <input type="text" value="<%=Request.QueryString["startTime"] %>" name="startTime"
                                                onfocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});" class="date" style="width: 110px" />到&nbsp;&nbsp;&nbsp;<input
                                                    type="text" name="endTime" value='<%=Request.QueryString["endTime"] %>'
                                                    onfocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});" class="date" style="width: 110px" />
                                            &nbsp;&nbsp;<input type="submit" value="筛选" id="btnselect" runat="server" class="formbutton validator"
                                                group="a" name="btnselect" style="padding: 1px 6px;" />
                                                </div>
                                    <ul class="filter">
                                      
                                               
                                    </ul>
                                    
                                </div>
                                
                                <div class="sect">
                                
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='8%'>
                                            
                                            </th>
                                            <th width='15%'>
                                                ID
                                            </th>
                                            <th width='15%'>
                                                操作管理员
                                            </th>
                                            <th width='17%'>
                                                日志类型
                                            </th>
                                            <th width='25%'>
                                                日志内容
                                            </th>
                                            <th width='20%'>
                                                操作时间
                                            </th>
                                        </tr>
                                        <%if (iListOprationLog != null && iListOprationLog.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (IOprationLog oprationinfo in iListOprationLog)
                                              {
                                                  if (i % 2 == 0)
                                                  {%>
                                        <tr>
                                            <td>
                                                <input type="checkbox" id="check" value="<%=oprationinfo.id %>" name="check" <%=check1 %> />
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=oprationinfo.id %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=oprationinfo.User.Username %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=oprationinfo.type %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; width:200px '>
                                                    <%=oprationinfo.logcontent %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=oprationinfo.createtime %>
                                                </div>
                                            </td>
                                        </tr>
                                        <% }
                                                  else
                                                  {%>
                                        <tr class="alt">
                                            <td>
                                                <input type="checkbox" id="check" value="<%=oprationinfo.id %>" name="check" <%=check1 %>/>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=oprationinfo.id %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=oprationinfo.User.Username %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=oprationinfo.type %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; width:200px '>
                                                    <%=oprationinfo.logcontent %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=oprationinfo.createtime %>
                                                </div>
                                            </td>
                                        </tr>
                                        <%}
                                                  i++;
                                              }
                                          } %>
                                        <tr>
                                            <td colspan="6">
                                            <input id="items" runat="server" type="hidden" />
                                            <% if (pagerHtml != "")
                                               { %>
                                            <input type="checkbox" id="checkall"  name="checkall"/>全选&nbsp;&nbsp;&nbsp;
                                 <input type="button" class="formbutton validator" value="删除选中" onClick="javascript:GetDeleteItem(<%= Helper.GetInt(Request.QueryString["page"], 1) %>);" />
                                               <%} %> <%=pagerHtml %>
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
<script language="javascript" type="text/javascript">

    $(function () {

        $("#checkall").click(function () {
            $("input[id='check']").attr("checked", $("#checkall").attr("checked"));
        });
    })
    function GetDeleteItem(url) {
        var str = "";
        var urls = url;
        $("input[id='check']:checked").each(function () {
            str += $(this).val() + ";";
        });

        $("#items").val(str.substring(0, str.length - 1));
        var itemval = $("#items").val();
        if (str.length > 0) {
            var istrue = window.confirm("是否删除选中项？");
            if (istrue) {

                window.location = "Option_Log.aspx?item=" + itemval + "&url=" + urls;
            }

        }
        else {
            alert("你还没有选择删除项！ ");
        }

    }
</script>
<%LoadUserControl("_footer.ascx", null); %>