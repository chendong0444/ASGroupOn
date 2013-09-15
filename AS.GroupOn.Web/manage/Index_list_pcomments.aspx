<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>

<%@ Import Namespace="AS.GroupOn" %>
<%@ Import Namespace="AS.Common" %>
<%@ Import Namespace="AS.Common.Utils" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Accessor" %>
<%@ Import Namespace="System.Collections.Generic" %>
<script runat="server">
    protected IPagers<IUserReview> pager = null;
    protected IList<IUserReview> iUserReview = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_PartnerComment_ListView))
        {
            SetError("你不具有查看商户评论权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        UserReviewFilter filter = new UserReviewFilter();
        //分页

        filter.unstate = 2;

        filter.type = "partner";
        //时间限定
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


        //更具用户名查找
        if (!string.IsNullOrEmpty(teamid.Value))
        {
            if (!string.IsNullOrEmpty(Request.QueryString["sevals"]))
            {
                seval.Value = Request.QueryString["sevals"];
            }
            switch (seval.Value)
            {
                case "1":
                    filter.partner_id = Helper.GetInt(teamid.Value, 0);
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
                            filter.user_id = Helper.GetInt(user.Id, 0);
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
        //  处理/未处理快捷搜索
        if (!string.IsNullOrEmpty(Request.QueryString["s"]))
        {
            string s = Request.QueryString["s"];
            if (s == "Y")
            {
                filter.state = 1;
            }
            else if (s == "N")
            {
                filter.state = 0;
            }
            url = url + "&s=" + Request.QueryString["s"];
        }
        url = url + "&page={0}";
        url = "Index_list_pcomments.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(UserReviewFilter.Create_Time_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {

            pager = session.UserReview.GetPager(filter);
        }
        //处理和删除
        IUserReview userreview = null;


        if (!string.IsNullOrEmpty(Request.QueryString["id"]))//处理
        {

            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TeamComment_Handle))
            {
                SetError("你不具有处理产品评论权限！");
                Response.Redirect("Index_list_pcomments.aspx");
                Response.End();
                return;

            }
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {

                userreview = session.UserReview.GetByID(Convert.ToInt32(Request.QueryString["id"]));
            }
        }
        else if (!string.IsNullOrEmpty(Request.QueryString["del"]))//删除
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TeamComment_Delete))
            {
                SetError("你不具有删除产品评论权限！");
                Response.Redirect("Index_list_comments.aspx");
                Response.End();
                return;
            }
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {

                userreview = session.UserReview.GetByID(Convert.ToInt32(Request.QueryString["del"]));
            }
        }
        if (!string.IsNullOrEmpty(Request.QueryString["id"]) || !string.IsNullOrEmpty(Request.QueryString["del"]))
        {

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int i = 0;

                if (!string.IsNullOrEmpty(PageValue.CurrentAdmin.ToString()))
                {
                    userreview.admin_id = PageValue.CurrentAdmin.Id;
                    if (!string.IsNullOrEmpty(Request.QueryString["id"]))
                    {
                        //判断管理员是否有此操作
                        //if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TeamComment_Handle))
                        //{
                        //    SetError("你不具有处理产品评论权限！");
                        //    Response.Redirect("Index_list_pcomments.aspx");
                        //    Response.End();
                        //    return;

                        //}
                        userreview.state = 1;
                    }
                    else if (!string.IsNullOrEmpty(Request.QueryString["del"]))
                    {
                        //if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_TeamComment_Delete))
                        ////    //{
                        ////    //    SetError("你不具有删除产品评论权限！");
                        ////    //    Response.Redirect("Index_list_comments.aspx");
                        ////    //    Response.End();
                        ////    //    return;
                        userreview.state = 2;
                    }

                }
                else
                {
                    SetError("没有检索到您的登录");
                    Response.Redirect("Login.aspx");
                }

                i = session.UserReview.Update(userreview);
                if (i > 0)
                {
                    SetSuccess("操作成功！");
                    Response.Redirect("Index_list_pcomments.aspx");
                }
            }
        }
        //删除选定
        if (Request.QueryString["item"] != null)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_PartnerComment_Delete))
            {
                SetError("你不具有删除商户评论权限！");
                Response.Redirect("Index_list_pcomments.aspx");
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

                    using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                    {
                        int i = 0;
                        userreview = session.UserReview.GetByID(id);
                        userreview.state = 2;
                        i = session.UserReview.Update(userreview);
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
            Response.Redirect("Index_list_pcomments.aspx");
        }
        iUserReview = pager.Objects;
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
                    window.location = "Index_list_pcomments.aspx?item=" + $("#items").val();
                }

            }
            else {
                alert("请选择删除项 ！");
            }

        }
    </script>
    <form id="form1" runat="server">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="coupons-box clear mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        商家评论</h2>
                                    <div class="search">
                                        时间<input id="begintime" type="text" class="h-input" datatype="date" runat="server" />到<input
                                            id="endtime" type="text" class="h-input" datatype="date" runat="server" />
                                        &nbsp;&nbsp;
                                        <select name="select_type" id="seval" runat="server">
                                            <option value="0">请选择</option>
                                            <option value="1">商户ID</option>
                                            <option value="2">用户名</option>
                                        </select>
                                        <input type="text" id="teamid" class="h-input" runat="server" />&nbsp; &nbsp;
                                        <asp:Button ID="Button1" CssClass="formbutton" Style="padding: 1px 6px;" Text="筛选"
                                            runat="server" />
                                        <a href="Index_list_pcomments.aspx?s=Y">已处理</a>|<a href="Index_list_pcomments.aspx?s=N">未处理</a>
                                        <ul class="filter">
                                            <li></li>
                                        </ul>
                                    </div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='4%'>
                                                <input type="checkbox" id="ckall" />
                                            </th>
                                            <th width='10%'>
                                                商户名称
                                            </th>
                                            <th width='15%'>
                                                项目ID/项目名称
                                            </th>
                                            <th width='15%'>
                                                用户名称
                                            </th>
                                            <th width='15%'>
                                                评价内容
                                            </th>
                                            <th width='8%'>
                                                评论状态
                                            </th>
                                            <th width='12%'>
                                                评价时间
                                            </th>
                                            <th width='8%'>
                                                满意度
                                            </th>
                                            <th width='10%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%int i = 0;
                                          if (iUserReview != null && iUserReview.Count > 0)
                                          {

                                              foreach (IUserReview UserReviewInfo in iUserReview)
                                              {
                                                  if (i % 2 != 0)
                                                  {%>
                                        <tr>
                                            <%}
                                                  else
                                                  {
                                            %>
                                            <tr class="alt">
                                                <% } i++;%>
                                                <td style='word-wrap: break-word; overflow: hidden; width: 4%;'>
                                                    <input name='checkboxs' type="checkbox" id="ckboxs" value="<%=UserReviewInfo.id %>" />
                                                    <input id="items" runat="server" type="hidden" />
                                                </td>
                                                <td>
                                                    <div style='word-wrap: break-word; overflow: hidden; width: 100px;'>
                                                        <a href="<%=getTeamPageUrl(UserReviewInfo.team_id) %>" target="_blank">
                                                            商户ID:
                                                            <%if (UserReviewInfo.team != null)
                                                              {%>
                                                            <%if (UserReviewInfo.team != null)
                                                              {%>
                                                            <%=UserReviewInfo.team.Partner_id%>&nbsp;&nbsp;
                                                            <%}
                                                              else
                                                              { %>
                                                            &nbsp;&nbsp;
                                                            <% } %>
                                                            <%}
                                                              else
                                                              { %>
                                                            [项目不存在]
                                                            <% } %>
                                                            <%if (UserReviewInfo.partner != null)
                                                              {%><%=UserReviewInfo.partner.Title %>
                                                            <% }%></a>
                                                </td>
                                                <td>
                                                    <div style='word-wrap: break-word; overflow: hidden; width: 150px;'>
                                                        项目ID:<%=UserReviewInfo.team_id%><br />

                                                        <%if (UserReviewInfo.team != null)
                                                          {%>
                                                        <%=UserReviewInfo.team.Title%>
                                                        <%}
                                                          else
                                                          { %>
                                                           [项目不存在]
                                                            <% } %>
                                                        
                                                        </div>
                                                </td>
                                                <%if (UserReviewInfo.user != null)
                                                  { 
                                                %>
                                                <td>
                                                    <div style='word-wrap: break-word; overflow: hidden; width: 150px;'>
                                                        <a href="ajax_manage.aspx?action=userview&Id=<%=UserReviewInfo.user_id %>" class='ajaxlink'
                                                            title='<%=UserReviewInfo.comment%>'>
                                                            <%=UserReviewInfo.user.Email%><br />
                                                            <%=UserReviewInfo.user.Username%></a>
                                                    </div>
                                                    <%
                                                        }
                                                  else
                                                  { 
                                                    %>
                                                    <td>
                                                        &nbsp;
                                                    </td>
                                                    <% }
                                                    %>
                                                    <td>
                                                        <div style='word-wrap: break-word; overflow: hidden; width: 200px;'>
                                                            <%=UserReviewInfo.comment%></div>
                                                    </td>
                                                    <%if (UserReviewInfo.state == 0)
                                                      {%>
                                                    <td>
                                                        <div style='word-wrap: break-word; overflow: hidden; width: 50px;'>
                                                            未处理</div>
                                                    </td>
                                                    <%}
                                                      else if (UserReviewInfo.state == 1)
                                                      {%>
                                                    <td>
                                                        <div style='word-wrap: break-word; overflow: hidden; width: 50px;'>
                                                            已处理</div>
                                                    </td>
                                                    <% 
                                                        }
                                                      else if (UserReviewInfo.state == 2)
                                                      {%>
                                                    <td>
                                                        <div style='word-wrap: break-word; overflow: hidden; width: 50px;'>
                                                            已失效</div>
                                                    </td>
                                                    <% 
                                                        }%>
                                                    <td>
                                                        <div style='word-wrap: break-word; overflow: hidden; width: 120px;'>
                                                            <%=UserReviewInfo.create_time%></div>
                                                    </td>
                                                    <%if (UserReviewInfo.score == 100)
                                                      {%>
                                                    <td>
                                                        <div style='word-wrap: break-word; overflow: hidden; width: 50px;'>
                                                            满意</div>
                                                    </td>
                                                    <%}
                                                      else if (UserReviewInfo.score == 50)
                                                      {%>
                                                    <td>
                                                        <div style='word-wrap: break-word; overflow: hidden; width: 50px;'>
                                                            一般</div>
                                                    </td>
                                                    <% }
                                                      else if (UserReviewInfo.score == 0)
                                                      {%>
                                                    <td>
                                                        <div style='word-wrap: break-word; overflow: hidden; width: 50px;'>
                                                            失望</div>
                                                    </td>
                                                    <%}%>
                                                    <%if (UserReviewInfo.admin_id == 0 && UserReviewInfo.state == 1)
                                                      {
                                                    %>
                                                    <td>
                                                        自动处理|<a ask="确认删除吗？" class="remove-record" href="Index_list_pcomments.aspx?del=<%=UserReviewInfo.id %>">删除</a>
                                                    </td>
                                                    <%
                                                        }
                                                      else if (UserReviewInfo.admin_id == 0 && UserReviewInfo.state == 0)
                                                      {%>
                                                    <td>
                                                        <a href="Index_list_pcomments.aspx?id=<%=UserReviewInfo.id %>">处理</a>|<a ask="确认删除吗？"
                                                            class="remove-record" href="Index_list_pcomments.aspx?del=<%=UserReviewInfo.id %>">删除</a>
                                                    </td>
                                                    <% }
                                                      else if (UserReviewInfo.admin_id != null)
                                                      {
                                                          IUser aduser = null;
                                                          using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                                                          {
                                                              aduser = session.Users.GetByID(UserReviewInfo.admin_id);
                                                          }
                                                          if (UserReviewInfo.aduser != null)
                                                          {%>
                                                    <td>
                                                        <%=UserReviewInfo.aduser.Username%>|<a ask="确认删除吗？" class="remove-record" href="Index_list_comments.aspx?del=<%=UserReviewInfo.id %>">删除</a>
                                                    </td>
                                                    <%  }
                                                          else
                                                          {%>
                                                    <td>
                                                        管理员已不存在|<a ask="确认删除吗？" class="remove-record" href="Index_list_comments.aspx?del=<%=UserReviewInfo.id %>">删除</a>
                                                    </td>
                                                    <% }
                                                      }%>
                                            </tr>
                                            <%       
}
                                          } %>
                                            <tr>
                                                <td colspan="8">
                                                    <% if (pagerHtml != "") { %>
                                                    <input value="删除选中" type="button" class="formbutton" style="padding: 1px 6px;" onclick="javascript:GetDeleteItem(); " />
                                                    <%=pagerHtml %>
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
