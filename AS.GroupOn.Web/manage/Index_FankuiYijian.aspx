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
    protected IPagers<IFeedback> pager = null;
    protected IList<IFeedback> iListFeedback = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {  
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FeedBack_ListView))
        {
            SetError("你不具有查看意见反馈列表权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        FeedbackFilter filter = new FeedbackFilter();
        filter.Category = "suggest";
        if (!string.IsNullOrEmpty(Request.QueryString["likename"]))
        {

            likename.Value = Request.QueryString["likename"];
        }

        if (!string.IsNullOrEmpty(likename.Value))
        {
            filter.Content = likename.Value;
            url = url + "&likename=" + likename.Value;
        }
        url = url + "&page={0}";
        url = "Index_FankuiYijian.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(FeedbackFilter.CREATE_TIEM_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Feedback.GetPager(filter);
        }
            if (!string.IsNullOrEmpty(Request.QueryString["del"]))
            {
                if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FeedBack_Delete))
                {
                    SetError("你不具有删除反馈信息权限！");
                    Response.Redirect("Index_FankuiYijian.aspx");
                    Response.End();
                    return;
                }
                int i = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    i = session.Feedback.Delete(Convert.ToInt32(Request.QueryString["del"]));
                }
                if (i > 0)
                {
                    SetSuccess("删除成功！");
                    Response.Redirect("Index_FankuiYijian.aspx");
                }
            }
        
        //处理
        if (!string.IsNullOrEmpty(Request.QueryString["id"]))
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FeedBack_Handle))
            {
                SetError("你不具有处理反馈信息权限！");
                Response.Redirect("Index_FankuiYijian.aspx");
                Response.End();
                return;

            }

            IFeedback feedback = null;

            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {

                feedback = session.Feedback.GetByID(Convert.ToInt32(Request.QueryString["id"]));
            }
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int i = 0;
                if (!string.IsNullOrEmpty(PageValue.CurrentAdmin.ToString()))
                {
                    feedback.User_id = PageValue.CurrentAdmin.Id;
                }
                else
                {
                    SetError("没有检索到您的登录");
                    Response.Redirect("Login.aspx");
                }
                i = session.Feedback.Update(feedback);
                if (i > 0)
                {
                    SetSuccess("处理完成");
                    Response.Redirect("Index_FankuiYijian.aspx");
                }
            }

        }

        //删除选定
        if (Request.QueryString["item"] != null)
        {
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FeedBack_Delete))
            {
                SetError("你不具有删除反馈信息权限！");
                Response.Redirect("Index_FankuiYijian.aspx");
                Response.End();
                return;
            }

            string items = Request.QueryString["item"];
            string[] item = items.Split(';');
            foreach (string ids in item)
            {
                int id = Helper.GetInt(ids, 0);
                if (id!=0)
                {
                    
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {

                    int i = 0;
                    i = session.Feedback.Delete(id);
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
            Response.Redirect("Index_FankuiYijian.aspx");
        }

        iListFeedback = pager.Objects;
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
                window.location = "Index_FankuiYijian.aspx?item=" + $("#items").val();
            }

        }
        else {
            alert("你还没有选择删除项！ ");

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
                    <div id="content" class="box-content mainwide">
                        <div class="box clear">
                            <div class="box-content">
                                <div class="head">
                                    <h2>
                                        意见反馈</h2>
                                        <div class="search">
                                       内容：
                                            <input type="text" id="likename" class="h-input" runat="server" />&nbsp; &nbsp;
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
                                            <th width='20%'>
                                                客户
                                            </th>
                                            <th width='20%'>
                                                内容
                                            </th>
                                            <th width='20%'>
                                                操作人
                                            </th>
                                            <th width='20%'>
                                                日期
                                            </th>
                                            <th width='10%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%int i = 0;
                                            if (iListFeedback != null && iListFeedback.Count > 0)
                                          {
                                              foreach (IFeedback feedbackInfo in iListFeedback)
                                              {if (i%2!=0)
                                            {%>
                                                <tr>
                                            <%}
                                                  else
                                                  {%>
                                                      <tr class="alt">
                                                 <% } i++;%>


                                            <td>
                                                <input name='checkboxs' type="checkbox" id="ckboxs" value="<%=feedbackInfo.Id %>" />
                                            </td>
                                            <input id="items" runat="server" type="hidden" />
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; width: 170px;'>
                                                    <%=feedbackInfo.title %><br />
                                                    <%=feedbackInfo.Contact %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; width: 200px;'>
                                                    <a title='<%=feedbackInfo.Content %>'>
                                                        <%=feedbackInfo.Content %></a>
                                                </div>
                                            </td>
                                            <%if (feedbackInfo.User != null)
                                              { 
                                            %>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=feedbackInfo.User.Username%>
                                            </td>
                                            <%
                                                }
                                              else
                                              { 
                                            %>
                                            <td>&nbsp;
                                                
                                            </td>
                                            <% }
                                            %>
                                            <td>
                                                <%=feedbackInfo.Create_time%>
                                            </td>
                                            <%if (feedbackInfo.User_id == 0)
                                              {
                                            %>
                                            <td>
                                                <a ask="确认删除吗？" class="remove-record" href="Index_FankuiYijian.aspx?del=<%=feedbackInfo.Id %>">
                                                    删除</a> | <a href="Index_FankuiYijian.aspx?id=<%=feedbackInfo.Id %>">处理</a>
                                            </td>
                                            <%
                                                }
                                              else
                                              { 
                                            %>
                                            <td>
                                                <a ask="确认删除吗？" class="remove-record" href="Index_FankuiYijian.aspx?del=<%=feedbackInfo.Id %>">
                                                    删除</a>
                                            </td>
                                            <%
                                                } %>
                                        </tr>
                                        <%       
                                            }
                                          } %>
                                        <tr>
                                            <td colspan="6">
                                                    <% if (pagerHtml != "") { %>
                                                <input value="删除选中" type="button" class="formbutton" style="padding: 1px 6px;" onClick="javascript:GetDeleteItem(); " />
                                                <%=pagerHtml %> <%} %>
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