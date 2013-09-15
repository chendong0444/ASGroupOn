<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected IPagers<IAsk> pager = null;
    protected IList<IAsk> iListAsk = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {

        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TeamAsk_ListView))
        {
            SetError("你不具有查看项目咨询列表权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        AskFilter filter = new AskFilter();
        //根据时间搜索
        if (!string.IsNullOrEmpty(Request.QueryString["begintime"]))
        {
            begintime.Value = Request.QueryString["begintime"];
        }
        if (!string.IsNullOrEmpty(begintime.Value))
        {
            url = url + "&begintime=" + begintime.Value;
            filter.FromCreate_time = Helper.GetDateTime(Convert.ToDateTime(begintime.Value).ToString("yyyy-MM-dd 0:0:0"), DateTime.Now);
        }

        if (!string.IsNullOrEmpty(Request.QueryString["endtime"]))
        {
            endtime.Value = Request.QueryString["endtime"];
        }
        if (!string.IsNullOrEmpty(endtime.Value))
        {
            url = url + "&endtime=" + endtime.Value;
            filter.ToCreate_time = Helper.GetDateTime(Convert.ToDateTime(endtime.Value).ToString("yyyy-MM-dd 23:59:59"), DateTime.Now);
        }

        if (!string.IsNullOrEmpty(Request.QueryString["teamid"]))
        {
            teamid.Value = Request.QueryString["teamid"];

        }
        //根据ID或用户名查找
        if (!string.IsNullOrEmpty(teamid.Value))
        {
            if (!string.IsNullOrEmpty(Request.QueryString["sevals"]))
            {
                seval.Value = Request.QueryString["sevals"];
            }
            switch (seval.Value)
            {
                case "1":
                    filter.Team_ID = Helper.GetInt(teamid.Value, 0);
                    if (AS.Common.Utils.NumberUtils.IsNum(teamid.Value))
                    {
                        url = url + "&teamid=" + teamid.Value;
                        url = url + "&sevals=1";
                    }
                    else
                    {
                        SetError("你输入了非法字符！");
                    }
                    break;
                case "2":
                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        IUser user = null;
                        user = session.Users.GetbyUName(teamid.Value);
                        if (user != null)
                        {
                            filter.User_id = Helper.GetInt(user.Id, 0);
                            url = url + "&teamid=" + teamid.Value;
                            url = url + "&sevals=2";
                        }
                        else
                        {
                            SetError("该用户不存在！");
                        }
                    }

                    break;
                case "0":
                    SetError("请选择查找类型");
                    break;
                default:
                    SetError("类型错误");
                    break;
            }
        }
        url = url + "&page={0}";
        url = "Index-XiangmuDabian.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(FeedbackFilter.CREATE_TIEM_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Ask.GetPagerTm(filter);

        }
        //删除

        if (!string.IsNullOrEmpty(Request.QueryString["del"]))
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TeamAsk_Delete))
            {
                SetError("你不具有删除项目咨询权限！");
                Response.Redirect("Index-XiangmuDabian.aspx");
                Response.End();
                return;

            }
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int i = 0;
                i = session.Ask.Delete(Convert.ToInt32(Request.QueryString["del"]));

                if (i > 0)
                {
                    SetSuccess("删除成功！");
                    Response.Redirect("Index-XiangmuDabian.aspx");
                }
            }
        }
        //删除选定
        if (Request.QueryString["item"] != null)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TeamAsk_Delete))
            {
                SetError("你不具有删除项目咨询权限！");
                Response.Redirect("Index-XiangmuDabian.aspx");
                Response.End();
                return;

            }
            
                string items = Request.QueryString["item"];
                string[] item = items.Split(';');
                foreach (string ids in item)
                {
                    int id = Helper.GetInt(ids, 0);
                    if (id != 0)
                    {

                        using (IDataSession sessions = AS.GroupOn.App.Store.OpenSession(false))
                        {

                            int i = 0;
                            i = sessions.Ask.Delete(id);
                            if (i > 0)
                            {
                                SetSuccess("删除选中成功！");

                            }
                            else
                            {
                                SetError("删除选中失败！");
                            }
                        }

                    }

                }
            
            Response.Redirect("Index-XiangmuDabian.aspx");
        }

        iListAsk = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);

    }
    
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
<script type="text/javascript">
    //批量选中
    $(function () {

        $("#ckall").click(function () {
            $("input[id='ckboxs']").attr("checked", $("#ckall").attr("checked"));
        });
    })
    //遍历选中项
    function GetDeleteItem() {
        var str = "";

        $("input[@name='checkboxs'][checked]").each(function () {
            str += $(this).val() + ";"
        });
        $("#items").val(str.substring(0, str.length - 1));
        if (str.length > 0) {
            var istrue = window.confirm("是否删除选中项？");
            if (istrue) {
                window.location = "Index-XiangmuDabian.aspx?item=" + $("#items").val();
            }

        }
        else {
            alert("请选择删除项 ！");
        }

    }
</script>
<script src="../upfile/js/datePicker/WdatePicker.js" type="text/javascript"></script>
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        项目答疑</h2>
                                        <div class="search">
                                     
                                        时间<input id="begintime" type="text" class="h-input" datatype="date" runat="server" />到<input
                                            id="endtime" type="text" class="h-input" datatype="date" runat="server" />
                                            &nbsp;&nbsp;
                                            <select name="select_type" id="seval" runat="server">
                                                <option value="0">请选择</option>
                                                <option value="1">项目ID</option>
                                                <option value="2">用户名</option>
                                            </select>
                                            <input type="text" id="teamid" class="h-input" runat="server" />&nbsp; &nbsp;
                                          
                                            <asp:Button ID="Button1" CssClass="formbutton" Style="padding: 1px 6px;" Text="筛选"
                                                runat="server" />
                                    <ul class="filter">
                                        <li>
                                        </li>
                                    </ul>
                                    </div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='10%'>
                                                <input type="checkbox" id="ckall" />
                                            </th>
                                            <th width='15%'>
                                                项目ID/产品名称
                                            </th>
                                            <th width='15%'>
                                                咨询人
                                            </th>
                                            <th width='15%'>
                                                咨询时间
                                            </th>
                                            <th width='20%'>
                                                咨询
                                            </th>
                                            <th width='10%'>
                                                答复
                                            </th>
                                            <th width='15%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%int i = 0;
                                            if (iListAsk != null && iListAsk.Count > 0)
                                          {
                                              foreach (IAsk askinfo in iListAsk)
                                              { if (i % 2 != 0)
                                                  {%>
                                                <tr>
                                                  <%}
                                                  else
                                                  {%>
                                                      <tr class="alt">
                                                 <% } i++;%>


                                            <td>
                                                <input name='checkboxs'  type="checkbox" id="ckboxs" value="<%=askinfo.Id %>" />
                                                <input id="items" runat="server" type="hidden" />
                                            </td>
                                            
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; width: 200px;'>
                                                    <a href="<%=getTeamPageUrl(askinfo.Team_id) %>" target="_blank">项目ID<%=askinfo.Team_id %>
                                                        <%=askinfo.team.Product%></a>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; width: 80px;'>
                                                    <%=askinfo.User.Username%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; width: 120px;'>
                                                    <%=askinfo.Create_time %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; width: 200px;'>
                                                    <%=askinfo.Content %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; width: 200px;'>
                                                    <%=askinfo.Comment%>
                                                </div>
                                            </td>
                                            <td class="op">
                                                <a class="remove-record" href="Index-XiangmuDabian_Content.aspx?id=<%=askinfo.Id %>">
                                                    编辑</a> | <a href="Index-XiangmuDabianEdit.aspx?id=<%=askinfo.Id %>">答复</a> | <a ask="确认删除吗？"
                                                        href="Index-XiangmuDabian.aspx?del=<%=askinfo.Id %>">删除</a>
                                            </td>
                                            </tr>
                                            <%    
                                                }
                                          } %>
                                             <tr>
                                                <td colspan="6">
                                                    <%if (pagerHtml != "")
                                                      { %>
                                                    <input value="删除选中" type="button" class="formbutton" style="padding: 1px 6px;" onClick="javascript:GetDeleteItem(); " />
                                                    <%=pagerHtml%>
                                                    <%} %>
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