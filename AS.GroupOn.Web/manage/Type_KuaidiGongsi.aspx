<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
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

<style>
    body
    {
        font: normal 12px arial, tahoma, helvetica, sans-serif;
        margin: 0;
        padding: 20px;
    }
    .simpleTree
    {
        margin: 0;
        padding: 0; /*
	overflow:auto;
	width: 250px;
	height:350px;
	overflow:auto;
	border: 1px solid #444444;
	*/
    }
    .simpleTree li
    {
        list-style: none;
        margin: 0;
        padding: 0 0 0 34px;
        line-height: 14px;
    }
    .simpleTree li span
    {
        display: inline;
        clear: left;
        white-space: nowrap;
    }
    .simpleTree ul
    {
        margin: 0;
        padding: 0;
    }
    .simpleTree .root
    {
        margin-left: -16px;
        background: no-repeat 16px 0 #ffffff;
    }
    .simpleTree .line
    {
        margin: 0 0 0 -16px;
        padding: 0;
        line-height: 3px;
        height: 3px;
        font-size: 3px;
        background: url(../css/i/line_bg.gif) 0 0 no-repeat transparent;
    }
    .simpleTree .line-last
    {
        margin: 0 0 0 -16px;
        padding: 0;
        line-height: 3px;
        height: 3px;
        font-size: 3px;
        background: url(../manage/css/i/spacer.gif) 0 0 no-repeat transparent;
    }
    .simpleTree .line-over
    {
        margin: 0 0 0 -16px;
        padding: 0;
        line-height: 3px;
        height: 3px;
        font-size: 3px;
        background: url(css/i/line_bg_over.gif) 0 0 no-repeat transparent;
    }
    .simpleTree .line-over-last
    {
        margin: 0 0 0 -16px;
        padding: 0;
        line-height: 3px;
        height: 3px;
        font-size: 3px;
        background: url(css/i/line_bg_over_last.gif) 0 0 no-repeat transparent;
    }
    .simpleTree .folder-open
    {
        margin-left: -16px;
        background: url(css/i/collapsable.gif) 0 -2px no-repeat #fff;
    }
    .simpleTree .folder-open img
    {
        float:left;
    }
    .simpleTree .folder-open-last img
    {
        float:left;
    }
    .simpleTree .folder-open-last
    {
        margin-left: -16px;
        background: url(css/i/collapsable-last.gif) 0 -2px no-repeat #fff;
    }
    .simpleTree .folder-close
    {
        margin-left: -16px;
        background: url(css/i/expandable.gif) 0 -2px no-repeat #fff;
        
    }
    .simpleTree .folder-close img
    {
        float:left;
    }
    .simpleTree .folder-close-last
    {
        margin-left: -16px;
        background: url(css/i/expandable-last.gif) 0 -2px no-repeat #fff;
    }
    .simpleTree .folder-close-last img
    {
        float:left;
    }
    .simpleTree .doc
    {
        margin-left: -16px;
        background: url(css/i/leaf.gif) 0 -1px no-repeat #fff;
    }
    .simpleTree .doc-last
    {
        margin-left: -16px;
        background: url(css/i/leaf-last.gif) 0 -1px no-repeat #fff;
    }
    .simpleTree .ajax
    {
        background: url(css/i/spinner.gif) no-repeat 0 0 #ffffff;
        height: 16px;
        display: none;
    }
    .simpleTree .ajax li
    {
        display: none;
        margin: 0;
        padding: 0;
    }
    .simpleTree .trigger
    {
        display: inline;
        margin-left: -32px;
        width: 28px;
        height: 11px;
        cursor: pointer;
    }
    .simpleTree .text
    {
        cursor: default;
    }
    .simpleTree .active
    {
        cursor: default;
        background-color: #F7BE77;
        padding: 0px 2px;
        border: 1px dashed #444;
    }
    #drag_container
    {
        background: #ffffff;
        color: #000;
        font: normal 11px arial, tahoma, helvetica, sans-serif;
        border: 1px dashed #767676;
    }
    #drag_container ul
    {
        list-style: none;
        padding: 0;
        margin: 0;
    }
    
    #drag_container li
    {
        list-style: none;
        background-color: #ffffff;
        line-height: 18px;
        white-space: nowrap;
        padding: 1px 1px 0px 16px;
        margin: 0;
    }
    #drag_container li span
    {
        padding: 0;
    }
    
    #drag_container li.doc, #drag_container li.doc-last
    {
        background: url(css/i/leaf.gif) no-repeat -17px 0 #ffffff;
    }
    #drag_container .folder-close, #drag_container .folder-close-last
    {
        background: url(css/i/expandable.gif) no-repeat -17px 0 #ffffff;
    }
    
    #drag_container .folder-open, #drag_container .folder-open-last
    {
        background: url(css/i/collapsable.gif) no-repeat -17px 0 #ffffff;
    }
    .contextMenu
    {
        display: none;
        position: absolute;
        background-color: #000000;
    }
</style>
<%--<script src="../upfile/js/jquery.contextmenu.r2-min.js" type="text/javascript"></script>
<script src="../upfile/js/jquery.simple.tree.js" type="text/javascript"></script>--%>
<script type="text/javascript">
    function nocitychange(id, expressid) {
        if ($("#check_" + id).attr("checked")) {//
            X.get(webroot + "ajax/manage.aspx?action=nocitysedit&act=no&id=" + expressid + "&cityid=" + id);
        }
        else { //
            X.get(webroot + "ajax/manage.aspx?action=nocitysedit&act=yes&id=" + expressid + "&cityid=" + id);
        }
    }
</script>

<script runat="server">
    protected IPagers<ICategory> pager = null;
    protected IList<ICategory> iListCategory = null;
    protected string pagerHtml = String.Empty;
    protected string url = "";
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.OPtion_ExpressCompany_List))
        {
            SetError("你不具有查看快递设置的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }
        CategoryFilter filter = new CategoryFilter();
        filter.Zone = "express";

        url = url + "&page={0}";
        url = "Type_KuaidiGongsi.aspx?" + url.Substring(1);
        filter.PageSize = 30;
        filter.AddSortOrder(CategoryFilter.Sort_Order_DESC + "," + CategoryFilter.ID_DESC);

        filter.CurrentPage = AS.Common.Utils.Helper.GetInt(Request.QueryString["page"], 1);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
        {
            pager = session.Category.GetPager(filter);
        }
        iListCategory = pager.Objects;
        pagerHtml = AS.Common.Utils.WebUtils.GetPagerHtml(30, pager.TotalRecords, pager.CurrentPage, url);

        if (Request.QueryString["del"] != null && Request.QueryString["del"].ToString() != "")
        {
            //判断管理员是否有此操作
            if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_ExpressCompany_Delete))
            {
                SetError("你不具有删除快递公司的权限！");
                Response.Redirect("Type_KuaidiGongsi.aspx");
                Response.End();
                return;

            }
            int id = 0;
            int i = 0;
            id = Helper.GetInt(Request.QueryString["del"], 0);
            using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                i = session.Category.Delete(id);
            }
            if (i > 0)
            {
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int a = session.Userlevelrelus.DelByLevelid(id);  
                }
                ICategory cate = Store.CreateCategory();
                cate.Czone = id.ToString();
                using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
                {
                    int b = session.Category.UpByCzone(cate);
                }
            }
            //cate.Delete(Convert.ToInt32(Request.QueryString["del"].ToString()));
            SetSuccess("删除成功");
            Response.Redirect("Type_KuaidiGongsi.aspx", true);

        }
        
        
        
    }
    
</script>
<%LoadUserControl("_header.ascx", null); %>
<body class="newbie">

    <%--<form id="form1" runat="server">--%>
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="coupons">
                    <div id="content" class="box-content">
                        <div class="box clear">
                            <div class="box-content clear mainwide">
                                <div class="head" style="height:35px;">
                                    <h2>
                                        快递设置</h2>
                                        <div class="search">
                                    <ul class="filter" style="top: 0">
                                        <li><a class="ajaxlink" href="<%=PageValue.WebRoot%>manage/ajax_manage.aspx?action=categoryedit&zone=express">
                                            新建快递公司</a></li>
                                    </ul></div>
                                </div>
                                <div class="sect">
                                    <table id="orders-list" cellspacing="0" cellpadding="0" border="0" class="coupons-table">
                                        <tr>
                                            <th width="10%">
                                                ID
                                            </th>
                                            <th width="15%">
                                                中文名称
                                            </th>
                                            <th width="15%">
                                                英文名称
                                            </th>
                                            <th width="8%">
                                                首字母
                                            </th>
                                            <th width="8%">
                                                自定义分组
                                            </th>
                                            <th width="7%">
                                                导航
                                            </th>
                                            <th width="7%">
                                                排序
                                            </th>
                                            <th width="30%">
                                                操作
                                            </th>
                                        </tr>
                                        <%if (iListCategory != null && iListCategory.Count > 0)
                                          {
                                              int i = 1;
                                              foreach (ICategory categoryinfo in iListCategory)
                                              {
                                                  if (i % 2 == 0)
                                                  { %>
                                        <tr class="alt">
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=categoryinfo.Id%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=categoryinfo.Name%>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden;'>
                                                    <%=categoryinfo.Ename%></div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=categoryinfo.Letter%></div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=categoryinfo.Czone%></div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=categoryinfo.Display%></div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=categoryinfo.Sort_order%></div>
                                            </td>
                                            <td>
                                           
                                                <a class="ajaxlink" href="<%=PageValue.WebRoot %>manage/ajax_manage.aspx?action=freight&id=<%=categoryinfo.Id %>">
                                                    运费价格</a>｜<a class="ajaxlink" href="<%=PageValue.WebRoot %>manage/ajax_manage.aspx?action=nocitysview&id=<%=categoryinfo.Id %>">
                                                        未送达区域设置</a>｜<a class='ajaxlink' href="<%=PageValue.WebRoot %>manage/ajax_manage.aspx?action=categoryedit&zone=<%=categoryinfo.Zone %>&update=<%=categoryinfo.Id %>">编辑</a>｜
                                                <a class="remove-record" href="Type_KuaidiGongsi.aspx?del=<%=categoryinfo.Id %>" ask="确认删除吗？">删除</a>
                                           
                                            </td>
                                        </tr>
                                        <%}
                                                  else
                                                  {%>
                                        <tr>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=categoryinfo.Id %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=categoryinfo.Name %>
                                                </div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=categoryinfo.Ename%></div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=categoryinfo.Letter%></div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=categoryinfo.Czone%></div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=categoryinfo.Display%></div>
                                            </td>
                                            <td>
                                                <div style='word-wrap: break-word; overflow: hidden; '>
                                                    <%=categoryinfo.Sort_order%></div>
                                            </td>
                                            <td>
                                            
                                                <a class="ajaxlink" href="<%=PageValue.WebRoot %>manage/ajax_manage.aspx?action=freight&id=<%=categoryinfo.Id %>">
                                                    运费价格</a>｜<a class="ajaxlink" href="<%=PageValue.WebRoot %>manage/ajax_manage.aspx?action=nocitysview&id=<%=categoryinfo.Id %>">
                                                        未送达区域设置</a>｜<a class='ajaxlink' href="<%=PageValue.WebRoot %>manage/ajax_manage.aspx?action=categoryedit&zone=<%=categoryinfo.Zone %>&update=<%=categoryinfo.Id %>">编辑</a>｜
                                                <a class="remove-record" href="Type_KuaidiGongsi.aspx?del=<%=categoryinfo.Id %>" ask="确认删除吗？">删除</a>
                                            </td>
                                        </tr>
                                        <%}
                                                  i++;
                                              }

                                          } %>
                                        <tr>
                                            <td colspan="8">
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
   <%-- </form>--%>
    
</body>
<%LoadUserControl("_footer.ascx", null); %>
</html>