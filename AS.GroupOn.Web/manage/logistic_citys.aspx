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
        
        background: url(css/i/collapsable.gif) 0 -2px no-repeat #fff;
    }
    .simpleTree .folder-open-last
    {
        
        background: url(css/i/collapsable-last.gif) 0 -2px no-repeat #fff;
    }
    .simpleTree .folder-close
    {
        
        background: url(css/i/expandable.gif) 0 -2px no-repeat #fff;
    }
    .simpleTree .folder-close-last
    {
        
        background: url(css/i/expandable-last.gif) 0 -2px no-repeat #fff;
    }
    .simpleTree .doc
    {
      
        background: url(css/i/leaf.gif) 0 -1px no-repeat #fff;
    }
    .simpleTree .doc-last
    {
        
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
<script runat="server">
    protected string html = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //判断管理员是否有此操作
        if (AdminPage.IsAdmin && AdminPage.CheckUserOptionAuth(PageValue.CurrentAdmin, ActionEnum.Option_LogisticsCity_List))
        {
            SetError("你不具有查看物流城市的权限！");
            Response.Redirect("index_index.aspx");
            Response.End();
            return;

        }

        html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/logistic_citys.aspx?pid=0");

    }
    
</script>
<%LoadUserControl("_header.ascx", null); %>
<script src="../upfile/js/jquery.contextmenu.r2-min.js" type="text/javascript"></script>
<script src="../upfile/js/jquery.simple.tree.js" type="text/javascript"></script>

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
                    <div id="content" class="box-content">
                        <div class="box clear">
                            <div class="box-content clear mainwide">
                                <div class="head">
                                    <table>
                                        <tbody>
                                            <tr>
                                                <td height="40px" width="">
                                                </td>
                                                <td>
                                                <span>全国城市列表</span>
                                                    <li><a class="ajaxlink" href="#"></a></li>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                                <div class="sect">
                                    <div class="contextMenu" id="myMenu1">
                                        <ul>
                                            <li id="add">
                                                <img src="css/i/folder_add.png" />添加子城市</li>
                                            <li id="edit">
                                                <img src="css/i/folder_edit.png" />编辑城市名称</li>
                                            <li id="delete">
                                                <img src="css/i/folder_delete.png" />删除当前城市及子城市</li>
                                        </ul>
                                    </div>
                                    <div class="contextMenu" id="myMenu2">
                                        <ul>
                                            <li id="edit">
                                                <img src="css/i/folder_edit.png" />
                                                Edit</li>
                                            <li id="delete">
                                                <img src="css/i/folder_delete.png" />
                                                Delete</li>
                                        </ul>
                                    </div>
                                    <ul class="simpleTree">
                                        <li class="root" id='cityid_0' pid="">
                                            <ul>
                                                <%=html %>
                                            </ul>
                                        </li>
                                    </ul>
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
<script type="text/javascript">

    var simpleTreeCollection;
    $(document).ready(function () {
        simpleTreeCollection = $('.simpleTree').simpleTree({
            autoclose: true,
            afterClick: function (node) {
                //alert("text-"+$('span:first',node).text());
            },
            afterDblClick: function (node) {
                //alert("text-" + $('span:first', node).text());
            },
            afterMove: function (destination, source, pos) {
                //alert("destination-"+destination.attr('id')+" source-"+source.attr('id')+" pos-"+pos);
            },
            afterAjax: function (node) {
                $(node).find("li[pid]").contextMenu('myMenu1', {
                    bindings: {
                        'add': function (t) {
                            var id = $(t).attr('id').replace("cityid_", "");
                            var pid = $(t).attr('pid');
                            var tit = window.prompt("请输入当前城市下的子城市");
                            if (tit != null) {
                                $(t).trigger("addnode", [id, tit]);
                            }
                        },
                        'edit': function (t) {
                            //alert('Trigger was ' + t.id + '\nAction was Email');
                            var id = $(t).attr('id').replace("cityid_", "");
                            var pid = $(t).attr('pid');
                            var tit = window.prompt("请填写当前城市的名称");
                            if (tit != null) {
                                $(t).trigger("editnode", [id, tit, editnode]);
                            }
                        },
                        'delete': function (t) {
                            //alert('Trigger was ' + t.id + '\nAction was Delete');
                            var id = $(t).attr('id').replace("cityid_", "");
                            if (window.confirm("您确认删除当前选中的城市么?")) {
                                $(t).trigger("delnode", [id, delnode]);
                            }
                        }
                    }
                });


            },
            animate: true,
            //,docToFolderConvert:true
            afterContextMenu: false
        });

        $("li[pid]").contextMenu('myMenu1', {
            bindings: {
                'add': function (t) {
                    var id = $(t).attr('id').replace("cityid_", "");
                    var pid = $(t).attr('pid');
                    var tit = window.prompt("请输入当前城市下的子城市");
                    if (tit != null) {
                        $(t).trigger("addnode", [id, tit]);
                    }
                },
                'edit': function (t) {
                    //alert('Trigger was ' + t.id + '\nAction was Email');
                    var id = $(t).attr('id').replace("cityid_", "");
                    var pid = $(t).attr('pid');
                    var tit = window.prompt("请填写当前城市的名称");
                    if (tit != null) {
                        $(t).trigger("editnode", [id, tit, editnode]);
                    }
                },
                'delete': function (t) {
                    var id = $(t).attr('id').replace("cityid_", "");
                    if (window.confirm("您确认删除当前选中的城市么?"))
                        $(t).trigger("delnode", [id, delnode]);
                }
            }
        });

    });

    function delnode(id) {
        X.get(webroot + 'ajax/logistic_citys.aspx?id=' + id + '&action=del');
    }
    function editnode(id, name) {
        X.get(webroot + 'ajax/logistic_citys.aspx?id=' + id + '&action=edit&name=' + encodeURIComponent(name));
    }

</script>
</html>