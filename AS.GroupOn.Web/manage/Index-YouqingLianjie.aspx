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
    protected IPagers<IFriendLink> pager = null;
    protected IList<IFriendLink> iListFriendLink = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FriendLink_ListView))
        {
            SetError("你不具有查看友情链接列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;
        }
        if (Request["delId"] != null && Request["delId"].ToString() != "")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FriendLink_Delete))
            {
                SetError("你不具有删除友情链接的权限！");
                Response.Redirect("index_index.aspx");
                Response.End();
                return;
            }
            else
            {
                Del();
            }
        }
        //批量删除
        if (Request.QueryString["item"] != null && Request.QueryString["item"] != "")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_FriendLink_Delete))
            {
                SetError("你不具有删除友情链接的权限！");
                Response.Redirect("Index-YouqingLianjie.aspx");
                Response.End();
                return;
            }
            else
            {
                BulkDel();
            }
        }
        InitData();
    }

    /// <summary>
    /// 绑定友情链接数据列表
    /// </summary>
    protected void InitData()
    {
        url = url + "&page={0}";
        url = "Index-YouqingLianjie.aspx?" + url.Substring(1);
        FriendLinkFilter filter = new FriendLinkFilter();
        filter.PageSize = 30;
        filter.AddSortOrder(FriendLinkFilter.Sort_Order_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.FriendLink.GetPager(filter);
        }
        iListFriendLink = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }
    /// <summary>
    /// 删除
    /// </summary>
    protected void Del()
    {
        int strid = Helper.GetInt(Request["delId"], 0);
        if (strid > 0)
        {
            int del_id = 0;
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                del_id = session.FriendLink.Delete(strid);
            }
            if (del_id > 0)
            {
                SetSuccess("删除成功");
            }
            Response.Redirect("Index-YouqingLianjie.aspx");
            Response.End();
            return;
        }
    }
    /// <summary>
    /// 批量删除
    /// </summary>
    protected void BulkDel()
    {
        string items = Request.QueryString["item"];
        string[] item = items.Split(';');
        foreach (string ids in item)
        {
            int id = Helper.GetInt(ids, 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                int i = 0;
                i = session.FriendLink.Delete(id);
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
        Response.Redirect("Index-YouqingLianjie.aspx?page=" + Helper.GetInt(Request.QueryString["url"], 1));
    }

    
</script>
<%LoadUserControl("_header.ascx", null); %>
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
                                        友情链接</h2>
                                    <ul class="filter">
                                        <li>
                                            
                                        </li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='5%'>
                                                <input type='checkbox' id='checkall' name='checkall' />全选
                                            </th>
                                            <th width='5%'>
                                                ID
                                            </th>
                                            <th width='20%'>
                                                网站名称
                                            </th>
                                            <th width='25%'>
                                                网站网址
                                            </th>
                                            <th width='30%'>
                                                LOGO
                                            </th>
                                            <th width='5%'>
                                                排序
                                            </th>
                                            <th width='10%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListFriendLink != null && iListFriendLink.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (IFriendLink friendlinkInfo in iListFriendLink)
                                              {
                                                  if (i % 2 != 0)
                                                  {
                                        %>
                                        <tr>
                                        <%
                                                  }
                                                  else
                                                  {
                                        %>
                                        <tr class='alt'>
                                        <%
                                                  }
                                            i++;
                                        %>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <input type='checkbox' id='check' name='check' value="<%=friendlinkInfo.Id%>" />
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=friendlinkInfo.Id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=friendlinkInfo.Title%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=friendlinkInfo.url%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=friendlinkInfo.Logo%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=friendlinkInfo.Sort_order%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <a  href="addyouqinglianjie.aspx?updateId=<%=friendlinkInfo.Id%>">编缉</a>｜
                                                    <a  href="Index-YouqingLianjie.aspx?delId=<%=friendlinkInfo.Id%>" ask='确定要删除吗?'>删除</a>

                                                </div>
                                            </td>
                                        </tr>
                                        <%       
                                            }
                                          } %>
                                        <tr>
                                            <td colspan="7">
                                                <input id="items" type="hidden" />
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
            <!-- bd end -->
        </div>
        <!-- bdw end -->
    </div>
    </form>
</body>
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
                window.location = "Index-YouqingLianjie.aspx?item=" + $("#items").val() + "&url=" + urls;
            }
        }
        else {
            alert("你还没有选择删除项！ ");
        }
    }
</script>
<%LoadUserControl("_footer.ascx", null); %>


