<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.AdminPage" %>
<%@ Import Namespace="AS.GroupOn.Controls" %>
<%@ Import Namespace ="AS.GroupOn.Domain" %>
<%@ Import Namespace="AS.GroupOn.DataAccess" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<script runat="server">
    protected IList<IBranch> branch = null;
    protected BranchFilter filter = new BranchFilter();
    protected string partner_id = String.Empty;
    protected string branchid = String.Empty;
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack) 
        {
            partner_id = Request["partnerid"];
        }
        filter.partnerid =AS.Common.Utils.Helper.GetInt(partner_id,0);
        using (IDataSession session = AS.GroupOn.App.Store.OpenSession(false)) 
        {
            branch = session.Branch.GetList(filter);
        }
        
    }

</script>

<% LoadUserControl("_header.ascx", null); %>
<style>
    #preview
    {
        border: 1px solid #bfd2e1;
        width: 500px;
        height: 368px;
        position: relative;
        left: 145px;
        display: block;
        clear: both;
        font-family: Arial, Helvetica, sans-serif, "宋体";
    }
    #map_canvas
    {
        height: 368px;
    }
    #float_search_bar
    {
        left:0;
        z-index: 2012;
        position: absolute;
        width: 490px;
        height: 31px;
        background: url("/upfile/css/i/search_bar.png") repeat-x;
        background-position: 0 -21px;
        padding: 3px 0 0 10px;
    }
    #float_search_bar label, #float_search_bar span
    {
        color: #0787cb;
        font-size: 14px;
    }
    #float_search_bar input
    {
        width: 180px;
        height: 16px;
        margin-top: 1px;
    }
    #float_search_bar input:focus
    {
        outline: none;
    }
    #float_search_bar input
    {
        border: 0;
        width: 300px;
        height: 20px;
        border: 1px solid #ccc;
        margin-right: 5px;
        cursor: pointer;
    }
    #float_search_bar .seach-map
    {
        border: 0;
        color: white;
        width: 70px;
        height: 20px;
        background: url("/upfile/css/i/search_bar.png") no-repeat;
        background-position: 0 0;
        margin-right: 5px;
        cursor: pointer;
    }
</style>

<script src="http://api.map.baidu.com/api?v=1.2" type="text/javascript"></script>
<script type="text/javascript">
    $(function () {
        $("#phone").blur(function (event) {
            var p = $("#phone").val();
            var k = p.split("-");
            if (p != "") {
                for (var i = 0; i < k.length; i++) {
                    if (k[i].match(/^(-|\+)?\d+$/) == null) {
                        //不是数字类型
                        $("#phone").attr("class", "f-input errorInput");
                        return false;
                    }
                    else {
                        $("#phone").attr("class", "f-input");

                    }
                }
            }
            else {
                $("#phone").attr("class", "f-input");
            }


        });
        $("#submit").click(function (event) {
            var p = $("#phone").val();
            var k = p.split("-");
            if (p != "") {
                for (var i = 0; i < k.length; i++) {
                    if (k[i].match(/^(-|\+)?\d+$/) == null) {
                        //不是数字类型
                        $("#phone").attr("class", "f-input errorInput");
                        return false;
                    }
                    else {
                        $("#phone").attr("class", "f-input");

                    }
                }
            }
            else {
                $("#phone").attr("class", "f-input");
            }

        });
    });

</script>
<body class="newbie">
    <div id="pagemasker">
    </div>
    <div id="dialog">
    </div>
    <div id="doc">
        <div id="bdw" class="bdw">
            <div id="bd" class="cf">
                <div id="partner">
                   
                    <div id="content" class="clear mainwide">
                        <div class="clear box">
                            <div class="box-content">
                                <div class="head" style="height:35px;">
                                    <h2>
                                        新建分店</h2>
                                       <div class="search"> 
                                       <ul class="filter">
                                       <li>
                                        <a href="ShangHuBranch.aspx?bid=<%=partner_id %>">
                                返回分店列表</a></li>
                                </ul>
                                </div>
                                </div>
                                <div class="sect">
                                    <form id="form1" method="post" enctype="multipart/form-data"  >
                                    <input type="hidden" value="CreateShanghuBranch" name="action" />
                                    <div class="wholetip clear">
                                        <h3>
                                           1. 登陆信息</h3>
                                    </div>
                                       <div class="field">
                                        <label>
                                            用户名</label>
                                        <input type="text" name="username" id="username" class="f-input" 
                                        group="a" require="true" datatype="require"  />
                                        <input type="hidden"  name="partnerid" value="<%=partner_id %>" />
                                    </div>
                        
                                   <div class="field password">
                                        <label>
                                            密  码</label>
                                        <input type="password" size="30" name="userpwd" id="userpwd" 
                                            class="f-input"  require="true" datatype="require" group="a" />
                                    </div>
                                    <div nowrap class="field password">
                                        <label>
                                            确认密码</label>
                                        <input type="password" size="30" require="true" group="a"  onblur="pwdchange()"
                                        datatype="require" name="newuserpwd" id="newuserpwd" class="f-input" />
                                    </div>
                                    <script type="text/javascript" >
                                        function pwdchange() {
                                            var pwd = $("#userpwd").val();
                                            var pwd1 = $("#newuserpwd").val();
                                            if (pwd != pwd1) {
                                                alert("密码不一致,请重新输入");
                                                return;
                                             }
                                         }
                                    </script>
                                    <div class="wholetip clear">
                                        <h3>
                                           2. 基本信息</h3>
                                    </div>
                                    <div class="field">
                                        <label>
                                            分店名称</label>
                                        <input type="text" size="30" name="branchname" id="branchname" class="f-input" 
                                            group="a" require="true" datatype="require"  />
                                    </div>
                                    <div class="field">
                                        <label>
                                            联系人</label>
                                        <input type="text" size="30" name="contact" id="contact" class="f-input" />
                                    </div>
                                    <div class="field">
                                        <label>
                                            联系电话</label>
                                        <input type="text" size="30" name="phone" id="phone" class="f-input"/>
                                    </div>
                                    <div class="field">
                                        <label>
                                            分店地址</label>
                                        <input type="text" size="500" name="address" id="address" class="f-input" 
                                            group="a" require="true" datatype="require"/>
                                    </div>
                                    <div class="field">
                                        <label>
                                            手机号码</label>
                                        <input type="text" size="30" name="mobile" id="mobile" class="f-input"  maxlength="11"
                                            datatype="mobile"  />
                                    </div>
                            <%--        <div class="field">
                                        <label>
                                            400验证电话</label>
                                        <input type="text" size="30" name="verifymobile" id="verifymobile" class="f-input"
                                              />
                                    </div>--%>
                                    <div class="field">
                                        <label>
                                            消费密码</label>
                                        <input type="text" size="500" name="secret" id="secret" class="f-input" value="000000"  group="a"/>
                                    </div>
                                    <div class="field">
                                        <label>
                                            分店经纬度</label>
                                        <input type="text" size="500" name="jingweidu" id="jingweidu" class="f-input" value=""
                                            group="a" runat="server" />
                                    </div>
                                       <div id="preview">
                                        <div id="float_search_bar">
                                            <label>
                                                区域名称：</label>
                                            <input type="text" id="keyword" />
                                            <input class="seach-map" id="search_button" onClick="sercarch()" type="button" value="查找" />
                                        </div>
                                        <div id="map_canvas" style="width: 500px; height: 340px; margin-left: 0px; float: left;
                                            display: block; top: 30px;">
                                        </div>
                                    </div>
                                      <script type="text/javascript">
                                          var map = new BMap.Map("map_canvas");
                                          map.centerAndZoom(new BMap.Point(116.404, 39.915), 11);
                                          var local = new BMap.LocalSearch(map, {
                                              renderOptions: { map: map }
                                          });
                                          function sercarch() {
                                              if (document.getElementById("keyword").value == "") {
                                                  alert("请您输入要查询的区域");
                                                  return false;
                                              }
                                              local.search(document.getElementById("keyword").value);
                                          }
                                          $(document).ready(function () {

                                              var point = new BMap.Point(116.404, 39.915);
                                              map.centerAndZoom(point, 11);

                                              var menu = new BMap.ContextMenu();
                                              var txtMenuItem = [
                                            {
                                                text: '以此处为商户位',
                                                callback: function (p) {
                                                    map.clearOverlays();
                                                    var center = map.getCenter();
                                                    var marker = new BMap.Marker(p), px = map.pointToPixel(p); map.addOverlay(marker);
                                                    $("#jingweidu").val(p.lat + "," + p.lng);
                                                }
                                            },
                                            {
                                                text: '清除标记',
                                                callback: function (p) {
                                                    map.clearOverlays();
                                                }
                                            },
                                            {
                                                text: '放大',
                                                callback: function () { map.zoomIn() }
                                            },
                                            {
                                                text: '缩小',
                                                callback: function () { map.zoomOut() }
                                            },
                                            {
                                                text: '放置到最大级',
                                                callback: function () { map.setZoom(18) }
                                            },
                                            {
                                                text: '查看全国',
                                                callback: function () { map.setZoom(4) }
                                            }
 ];
                                              for (var i = 0; i < txtMenuItem.length; i++) {
                                                  menu.addItem(new BMap.MenuItem(txtMenuItem[i].text, txtMenuItem[i].callback, 100));
                                                  if (i == 1) {
                                                      menu.addSeparator();
                                                  }
                                              }
                                              map.addContextMenu(menu);
                                              map.enableScrollWheelZoom();
                                              map.addControl(new BMap.NavigationControl());
                                              map.addControl(new BMap.ScaleControl());
                                              map.addControl(new BMap.OverviewMapControl());
                                              map.addControl(new BMap.MapTypeControl());
                                              map.centerAndZoom(point, 15);
                                          });
                                    </script>
                                    <div class="act">
                                        <input type="submit" value="新建" name="commit" id="submit" class="formbutton validator" group="a"  />
                                    </div>
                                    </form>
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

