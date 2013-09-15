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
    protected IPagers<INews> pager = null;
    protected IList<INews> iListNews = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_News_List))
        {
            SetError("你不具有查看新闻公告列表的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        if (Request["delId"] != null && Request["delId"].ToString() != "")
        {
            Del();
        }
        if (Request.QueryString["item"] != null && Request.QueryString["item"] != "")
        {
            BulkDel();//批量删除
        }
        InitData();
    }

    /// <summary>
    /// 绑定新闻公告数据列表
    /// </summary>
    protected void InitData()
    {
        url = url + "&page={0}";
        url = "NewList.aspx?" + url.Substring(1);
        NewsFilter filter = new NewsFilter();
        filter.PageSize = 30;
        filter.AddSortOrder(NewsFilter.ID_DESC);
        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.News.GetPager(filter);
        }
        iListNews = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);
    }

    /// <summary>
    /// 删除
    /// </summary>
    protected void Del()
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_News_Delete))
        {
            SetError("你不具有删除新闻公告列表的权限！");
            Response.Redirect("NewList.aspx");
            Response.End();
            return;

        }
        else
        {
            int strid = Helper.GetInt(Request["delId"], 0);
            if (strid > 0)
            {
                int del_id = 0;
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    del_id = session.News.Delete(strid);
                }
                if (del_id > 0)
                {
                    SetSuccess("删除成功");
                }
                Response.Redirect("NewList.aspx");
                Response.End();
                return;
            }
        }
    }
    /// <summary>
    /// 批量删除
    /// </summary>
    protected void BulkDel()
    {
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_News_Delete))
        {
            SetError("你不具有删除新闻公告列表的权限！");
            Response.Redirect("NewList.aspx");
            Response.End();
            return;
        }
        else
        {
            string items = Request.QueryString["item"];
            string[] item = items.Split(';');
            foreach (string ids in item)
            {
                int strid = Helper.GetInt(ids, 0);
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int i = 0;
                    i = session.News.Delete(strid);
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
            Response.Redirect("NewList.aspx?page=" + Helper.GetInt(Request.QueryString["url"], 1));
        }
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
                                        新闻公告</h2>
                                    <ul class="filter">
                                        <li>
                                            
                                        </li>
                                    </ul>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width='5%'>
                                                <input type='checkbox' id='checkall' name='checkall' /> 全选
                                            </th>
                                            <th width='5%'>
                                                ID
                                            </th>
                                            <th width='30%'>
                                                标题
                                            </th>
                                            <th width='20%'>
                                                类型
                                            </th>
                                            <th width='15%'>
                                                创建日期
                                            </th>
                                            <th width='15%'>
                                                管理员
                                            </th>
                                            <th width='10%'>
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListNews != null && iListNews.Count > 0)
                                          {
                                              int i = 0;
                                              foreach (INews newsInfo in iListNews)
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
                                                    <input type='checkbox' id='check' name='check' value="<%=newsInfo.id%>" />
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=newsInfo.id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <a href="<%=GetUrl("新闻", "usercontrols_newlist.aspx?id="+newsInfo.id)%>" target="_blank" ><%=newsInfo.title%></a>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                   <% if (newsInfo.type == 0)
                                                       { 
                                                    %>
                                                        团购
                                                    <%
                                                        }
                                                       else
                                                       { 
                                                    %>
                                                        商城
                                                    <%
                                                       }   
                                                    %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=newsInfo.create_time.ToString("yyyy-MM-dd")%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=newsInfo.User.Username%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <a href="Addnews.aspx?updateId=<%=newsInfo.id%>" >编辑</a> |
                                                    <a ask="确定删除此新闻吗？" href="NewList.aspx?delId=<%=newsInfo.id%>" >删除</a>
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
                                            <td>&nbsp;
                                                
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
                window.location = "NewList.aspx?item=" + $("#items").val() + "&url=" + urls;
            }
        }
        else {
            alert("你还没有选择删除项！ ");
        }
    }
</script>
<%LoadUserControl("_footer.ascx", null); %>