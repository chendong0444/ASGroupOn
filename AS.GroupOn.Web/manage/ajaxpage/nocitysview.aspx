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
    protected string html = String.Empty;
    protected int expressid = 0;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        expressid = Helper.GetInt(Request["expressid"], 0);
        html = WebUtils.LoadPageString(PageValue.WebRoot + "manage/ajaxpage/logistic_nocitys.aspx?pid=0&expressid=" + expressid);
    }
</script>
<script src="../../upfile/js/jquery.contextmenu.r2-min.js" type="text/javascript"></script>
<script src="../../upfile/js/jquery.simple.tree.js" type="text/javascript"></script>

<div id="doc">
    <div id="order-pay-dialog" class="order-pay-dialog-c" style="width: 380px;">
        <h3>
            <span id="order-pay-dialog-close" class="close" onclick="return X.boxClose();">关闭</span></h3>
        <div style="overflow-x: hidden; padding: 10px;">
            <ul class="simpleTree">
                <li class="root" id='cityid_0' pid=""><span>全国城市列表</span>
                    <ul>
                        <%=html %>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</div>
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
