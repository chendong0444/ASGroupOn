<%@ Page Language="C#" AutoEventWireup="true" EnableViewState="false" Inherits="AS.GroupOn.Controls.AdminPage" %>


<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.App" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<script runat="server">
    protected IPagers<IFlow> pager = null;
    protected IList<IFlow> iListFlow = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected string select_type = string.Empty;
    protected string startTime = string.Empty;
    protected string endTime = string.Empty;
    protected bool IsTime = false;
    protected bool isCash = false;
    protected bool isRefund = false;
    protected string selTxt = string.Empty;
    FlowFilter filter = new FlowFilter();
    UserFilter uf = new UserFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
         //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_Flow_Sign))
        {

            SetError("你不具有查看签名记录的权限！");
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
                    i = session.Flow.Delete(id);
                    if (i > 0)
                    {
                        SetSuccess("删除选中成功！");
                        AS.Common.Utils.WebUtils.LogWrite("删除财务记录日志", "《删除签到记录》FlowId:" + id + ",操作员ID：" + AS.Common.Utils.WebUtils.GetLoginAdminID() + "");
                    }
                    else
                    {
                        SetError("删除选中失败！");
                    }
                }

            }
            string key = AS.Common.Utils.FileUtils.GetKey();
            AS.AdminEvent.ConfigEvent.AddOprationLog(AS.Common.Utils.Helper.GetInt(AS.Common.Utils.CookieUtils.GetCookieValue("admin", key), 0), "删除签名记录", "删除签名记录 ID:" + Request.QueryString["item"].ToString(), DateTime.Now);
            Response.Redirect("CaiWu_Sign.aspx?page=" + Helper.GetInt(Request.QueryString["url"], 1));
        }

        startTime = Request.QueryString["startTime"];
        endTime = Request.QueryString["endTime"];

        //根据时间进行筛选
        if (!string.IsNullOrEmpty(startTime) && !string.IsNullOrEmpty(endTime))
        {
            IsTime = true;

            url = url + "&stareTime=" + Request.QueryString["startTime"] + "&endTime=" + Request.QueryString["endTime"];

            startTime = AS.Common.Utils.Helper.GetDateTime(Request["startTime"], DateTime.Now).ToString("yyyy-MM-dd HH:mm:ss");
            endTime = AS.Common.Utils.Helper.GetDateTime(Request["endTime"], DateTime.Now).ToString("yyyy-MM-dd HH:mm:ss");

            filter.FromCreateTime = Convert.ToDateTime(startTime);
            filter.ToCreateTime = Convert.ToDateTime(endTime);

        }
        else
        {
            IsTime = false;
        }

        selTxt = Request.QueryString["memail"];
        select_type = Request.QueryString["select_type"];
          

        if (!string.IsNullOrEmpty(select_type))
        {
           

            if (!string.IsNullOrEmpty(selTxt))
            {

                if (select_type == "1")
                {
                    
                    url = url + "&select_type=" + Request.QueryString["select_type"];
                    uf.Username = selTxt;
                    using (IDataSession sesion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        IUser user = sesion.Users.GetByName(uf);
                        if (user != null)
                            filter.User_id = user.Id;

                    }

                }
                else if (select_type == "2")
                {
                    url = url + "&select_type=" + Request.QueryString["select_type"];
                    uf.Email = selTxt;
                    using (IDataSession sesion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        IUser user = sesion.Users.GetByEmail(uf);
                        if (user != null)
                            filter.User_id = user.Id;
                    }

                }
                else if (select_type == "3")
                {
                    url = url + "&select_type=" + Request.QueryString["select_type"];

                    uf.Signmobile = selTxt;
                    using (IDataSession sesion = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        IUser user = sesion.Users.Get(uf);
                        if (user != null)
                            filter.User_id = user.Id;
                    }
                }

                url = url + "&memail=" + Request.QueryString["memail"];
            }

        }

        InitData();
    }

    private void InitData()
    {
        StringBuilder sb1 = new StringBuilder();
        StringBuilder sb2 = new StringBuilder();
        IUser user = Store.CreateUser();
        sb1.Append("<tr >");
        sb1.Append("<th width='5%'><input type='checkbox' id='checkall' name='checkall' />全选</th>");
        sb1.Append("<th width='25%'>Email/用户名</th>");
        sb1.Append("<th width='20%'>绑定号码</th>");
        sb1.Append("<th width='15%'>动作</th>");
        sb1.Append("<th width='15%'>金额</th>");
        sb1.Append("<th width='20%'>签到时间</th>");
        sb1.Append("</tr>");

       
        url = url + "&page={0}";
        url = "CaiWu_Sign.aspx?" + url.Substring(1);
        filter.Action = "sign";
        filter.PageSize = 30;
        filter.AddSortOrder(FlowFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Flow.GetPager(filter);
        }
        
        iListFlow = pager.Objects;
        int i = 0;
        foreach (IFlow flow in iListFlow)
        {
            user = flow.User;
          
          
            if (i % 2 != 0)
            {
                sb2.Append("<tr>");
            }
            else
            {
                sb2.Append("<tr class='alt'>");
            }
            i++;
            sb2.Append("<td><input type='checkbox' id='check' name='check' value=" + flow.Id + " /></td>");
            if (user != null) 
                sb2.Append("<td ><div style='word-wrap: break-word;overflow: hidden; width: 200px;'>" + user.Email + "/" + user.Username + "</div></td>");
            else    
                sb2.Append("<td ></td>");
            if (user.Mobile != null)
                sb2.Append("<td >" + user.Signmobile + "</td>");
            else
                sb2.Append("<td ></td>");
                sb2.Append("<td >签到</td>");
                sb2.Append("<td >" + flow.Money + "</td>");
                sb2.Append("<td >" + flow.Create_time + "</td>");
            sb2.Append("</tr>");

            
        }
        Literal1.Text = sb1.ToString();
        Literal2.Text = sb2.ToString();

        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);

    }
        
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">
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
                                        签名记录</h2><form id="form1" runat="server" method="get">
                                <div class="search">
                                时&nbsp;间：
                                            <input type="text" readonly="readonly" <%if(!string.IsNullOrEmpty(Request.QueryString["startTime"])){ %> value='<%=Request.QueryString["startTime"] %>'<%} %> name="startTime"
                                                onfocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});" class="date" style="width: 110px"  />到&nbsp;&nbsp;&nbsp;<input
                                                    type="text" readonly="readonly" name="endTime"  <%if(!string.IsNullOrEmpty(Request.QueryString["endTime"])){ %> value='<%=Request.QueryString["endTime"] %>'<%} %>
                                                    onfocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});" class="date" style="width: 110px" />
                                        <select id="Select1" name="select_type">
                                                <option value="">请选择</option>
                                                <option value="1" <%if(Request.QueryString["select_type"] == "1"){%> selected="selected"<%} %>>用户名</option>
                                                <option value="2" <%if(Request.QueryString["select_type"] == "2"){%> selected="selected"<%} %>>E-Mail</option>
                                                <option value="3" <%if(Request.QueryString["select_type"] == "3"){%> selected="selected"<%} %>>手机号码</option>
                                            </select>
                                            &nbsp;<input type="text" name="memail" <%if(!string.IsNullOrEmpty(Request.QueryString["memail"])){ %> value='<%=Request.QueryString["memail"] %>'<%} %> class="h-input" />&nbsp;<input
                                                type="submit" value="筛选" class="formbutton" name="btnselect" style="padding: 1px 6px;" />             
                                <ul class="filter" style="top: 0px; ">
                                       
                                    </ul>
                             
                                </div>
                                </form>
                                </div>
                                
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <asp:Literal ID="Literal1" runat="server"></asp:Literal>
                                        <asp:Literal ID="Literal2" runat="server"></asp:Literal>
                                        <tr>
                                            <td colspan="8">
                                           <input id="items" runat="server" type="hidden" />
                                           <input value="删除选中" type="button" class="formbutton" style="padding: 1px 6px;" onClick='javascript:GetDeleteItem(<%= Helper.GetInt(Request.QueryString["page"], 1) %>);' />
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
        </div>
    </div>
</body>
<%LoadUserControl("_footer.ascx", null); %>
<script type="text/javascript">

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

        if (str.length > 0) {
            var istrue = window.confirm("是否删除选中项？");
            if (istrue) {
                window.location = "CaiWu_Sign.aspx?item=" + $("#items").val() + "&url=" + urls;
            }

        }
        else {
            alert("你还没有选择删除项！ ");
        }

    }



</script>