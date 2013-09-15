<%@ Page Language="C#" AutoEventWireup="true" Inherits="AS.GroupOn.Controls.FBasePage" %>
<%@ Import Namespace="AS.GroupOn.DataAccess.Filters" %>
<%@ Import Namespace="AS.GroupOn.Domain" %>
<script runat="server">
    protected IList<ICategory> categoryList = null;
    protected CategoryFilter filter = new CategoryFilter();
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (ASSystem.title == String.Empty)
        {
            AS.GroupOn.Controls.PageValue.Title = "团购达人";
        }
        if (!IsPostBack)
        {
            filter.Zone = "city";
            using (AS.GroupOn.DataAccess.IDataSession session = AS.GroupOn.App.Store.OpenSession(false))
            {
                categoryList = session.Category.GetList(filter);
            }
        }
    }
</script>
<%LoadUserControl("_htmlheader.ascx", null); %>
<%LoadUserControl("_header.ascx", null); %>
<script type="text/javascript">
    $(function () {
        var wikiurl = window.location.protocol + "//" + window.location.host;
        ////文字版开始
        var minheight = 10;
        $('#switchcity').change(function () {

            var cityid = $(this).val();
            var height = $('#hei_city').val();
            var width = $('#wid_city').val();
            src1 = wikiurl + webroot + 'template/default/help_pendantShow.aspx?stype=3&&cityid=' + cityid + '&height=' + height;
            $('#widget_city').removeAttr('src').attr('src', src1).removeAttr('height').attr('height', height).removeAttr('width').attr('width', '100%');
            iff = "<iframe id='widget_city' width=100% height=" + height + " style='position:absolute;left:0;top:0;' frameborder='0' scrolling='no' src='" + src1 + "'></iframe>";
            return false;
        });

        $('#zishiying_city').click(function () {
            if ($(this).attr('checked')) {
                $('#wid_city').attr('disabled', 'true');
            } else {
                $('#wid_city').removeAttr('disabled');
            }
        });


        $('#showyangshi_city').click(function () {
            var cityid = $('#switchcity').val();
            var width = '';
            var height = '';
            var src1 = '';
            var iff = '';

            if (!($('#zishiying_city').attr('checked'))) {
                width = $('#wid_city').val();
                if (width < 220) {
                    alert('宽度建议不要低于220像素');
                    $('#wid_city').val('220');
                    return;
                } else if (isNaN(width)) {
                    $('#wid_city').val('220');
                    return;
                } else if (width > 1024) {
                    alert('宽度建议不要大于1024像素');
                    $('#wid_city').val('1024');
                    return;
                }
            }

            height = $('#hei_city').val();
            if (height < minheight) {
                alert('高度建议不要低于' + minheight + '像素');
                $('#hei_city').val(minheight);
                return;
            } else if (isNaN(height)) {
                $('#hei_city').val(minheight);
                return;
            } else if (height > 1000) {
                alert('高度建议不大于1000像素');
                $('#hei_city').val('1000');
                return;
            }

            if ($('#zishiying_city').attr('checked')) {
                src1 = wikiurl + webroot + 'template/default/help_pendantShow.aspx?stype=3&&cityid=' + cityid + '&height=' + height;
                $('#widget_city').removeAttr('src').attr('src', src1).removeAttr('height').attr('height', height).removeAttr('width').attr('width', '100%');
                iff = "<iframe id='widget_city' width='100%' height='" + height + "' style='position:absolute;left:0;top:0;' frameborder='0' scrolling='no' src='" + src1 + "'></iframe>";
            } else {
                src1 = wikiurl + webroot + 'template/default/help_pendantShow.aspx?stype=3&&cityid=' + cityid + '&width=' + width + '&height=' + height;
                $('#widget_city').removeAttr('src').attr('src', src1).removeAttr('height').attr('height', height).removeAttr('width').attr('width', width);
                iff = "<iframe id='widget_city' width='" + width + "' height='" + (parseInt(height) - 4) + "' style='position:absolute;left:0;top:0;' frameborder='0' scrolling='no' src='" + src1 + "'></iframe>";
            }
            $('#invite_url_city').empty().val(iff);
        });




        ////////////////////////////////////////////
        ////美编版开始
        ///////////////////////////////////////////
        //颜色选择
        $('#sc a').each(function (index) {
            var color = $(this);

            color.click(function () {
                $('#sc a').removeClass('abcd');
                color.addClass('abcd');
                var src = wikiurl + webroot + "template/default/help_pendantShow.aspx?stype=1&&bg=" + index;
                $('#widget').removeAttr('src').attr('src', src);
                var src2 = iff = "<iframe id='widget' style='width:100%; height:360px;' frameborder='0' scrolling='no' src='" + src + "'></iframe>";
                $('#invite_url').empty().val(src2);
                return false;
            });
        });


        $('#wid').blur(function () {
            if (!($('#zishiying').attr('checked'))) {
                var width = $('#wid').val();
                if (width < 220) {
                    alert('宽度建议读低于220像素');
                    $('#wid').val('220');
                }
            }
        });
        $('#hei').blur(function () {

            var height = $('#hei').val();
            if (height < 360) {
                alert('高度建议不要低于360像素');
                $('#hei').val('360');
                return;
            } else if (isNaN(height)) {
                $('#hei').val('360');
                return;
            }
        });

        $('#zishiying').click(function () {
            if ($(this).attr('checked')) {
                $('#wid').attr('disabled', 'true');
            } else {
                $('#wid').removeAttr('disabled');
            }
        });






        $('#showyangshi').click(function () {
            var width = '';
            var height = '';
            var src1 = '';
            var iff = '';
            if (!($('#zishiying').attr('checked'))) {
                width = $('#wid').val();
                if (width < 220) {
                    alert('宽度建议不要低于220像素');
                    $('#wid').val('220');
                    return;
                }
                else if (isNaN(width)) {
                    $('#wid').val('220');
                    return;
                }
            }
            height = $('#hei').val();
            if (height < 360) {
                alert('高度建议不要低于360像素');
                $('#hei').val('380');
                return;
            } else if (isNaN(height)) {
                $('#hei').val('360');
                return;
            }
            var background = '';
            $('#sc a').each(function (index) {
                var ccc = $(this);
                if (ccc.hasClass('abcd')) {
                    background = index;
                }
            });
            if (background == '') {
                background = 0;
            }
            if ($('#zishiying').attr('checked')) {

                src1 = wikiurl + webroot + 'template/default/help_pendantShow.aspx?stype=1&&bg=' + background + '&&height=' + height;
                $('#widget').removeAttr('src').attr('src', src1).removeAttr('height').attr('height', height).removeAttr('width').attr('width', '228');
                iff = "<iframe id='widget' width='100%' height='" + height + "'  frameborder='0' scrolling='no' src='" + src1 + "'></iframe>";


            } else {
                src1 = wikiurl + webroot + 'template/default/help_pendantShow.aspx?stype=1&&bg=' + background + '&&width=' + width + '&&height=' + height;
                $('#widget').removeAttr('src').attr('src', src1).removeAttr('height').attr('height', height).removeAttr('width').attr('width', parseInt(width) + 8);
                iff = "<iframe id='widget' width='" + width + "' height='" + height + "'  frameborder='0' scrolling='no' src='" + src1 + "'></iframe>";
            }
            $('#invite_url').empty().val(iff);
        });







        ////////////////////////////////////////////
        ////简洁版开始
        ///////////////////////////////////////////
        //处理背景
        $('#bg_simple a').each(function (index) {
            var width = '';
            var height = '';
            var src1 = '';
            var iff = '';
            if (!($('#zishiying').attr('checked'))) {
                width = $('#wid').val();
                if (width < 220) {
                    alert('宽度建议不要低于220像素');
                    $('#wid').val('220');
                    return;
                }
                else if (isNaN(width)) {
                    $('#wid').val('220');
                    return;
                }
            }
            height = $('#hei').val();
            if (height < 360) {
                alert('高度建议不要低于360像素');
                $('#hei').val('380');
                return;
            } else if (isNaN(height)) {
                $('#hei').val('360');
                return;
            }
            var background = '';
            $('#sc a').each(function (index) {
                var ccc = $(this);
                if (ccc.hasClass('abcd')) {
                    background = index;
                }
            });
            if (background == '') {
                background = 0;
            }
            var color = $(this);
            color.click(function () {
                $('#bg_simple a').removeClass('abcd_simple');
                color.addClass('abcd_simple');

                var src = wikiurl + webroot + "template/default/help_pendantShow.aspx?stype=2&&bg=" + index;
                $('#widget_simple').removeAttr('src').attr('src', src);
                var src2 = iff = "<iframe id='widget_simple' style='width:" + (parseInt(width) + 4) + "px; height:" + (parseInt(height) + 4) + "px;' frameborder='0' scrolling='no' src='" + src + "'></iframe>";
                $('#invite_url_simple').empty().val(src2);
                return false;
            });
        });

        $('#zishiying_simple').click(function () {
            if ($(this).attr('checked')) {
                $('#wid_simple').attr('disabled', 'true');
            } else {
                $('#wid_simple').removeAttr('disabled');
            }
        });
        $('#wid_simple').blur(function () {
            if (!($('#zishiying_simple').attr('checked'))) {
                var width = $('#wid_simple').val();
                if (width < 220) {
                    alert('宽度建议读低于220像素');
                    $('#wid_simple').val('220');
                }
            }
        });
        $('#hei_simple').blur(function () {

            var height = $('#hei_simple').val();
            if (height < 365) {
                alert('高度建议不要低于365像素');
                $('#hei_simple').val('365');
                return;
            } else if (isNaN(height)) {
                $('#hei_simple').val('365');
                return;
            }
        });


        $('#showyangshi_simple').click(function () {
            var width = '';
            var height = '';
            var src1 = '';
            var iff = '';
            if (!($('#zishiying_simple').attr('checked'))) {
                width = $('#wid_simple').val();
                if (width < 220) {
                    alert('宽度建议不要低于220像素');
                    $('#wid_simple').val('220');
                    return;
                }
                else if (isNaN(width)) {
                    $('#wid_simple').val('220');
                    return;
                }
            }
            height = $('#hei_simple').val();
            if (height < 365) {
                alert('高度建议不要低于365像素');
                $('#hei_simple').val('365');
                return;
            } else if (isNaN(height)) {
                $('#hei_simple').val('365');
                return;
            }
            var background = '';
            $('#bg_simple a').each(function (index) {
                var ccc = $(this);
                if (ccc.hasClass('abcd_simple')) {
                    background = index;
                }
            });
            if (background == '') {
                background = 0;
            }
            if ($('#zishiying_simple').attr('checked')) {

                src1 = wikiurl + webroot + 'template/default/help_pendantShow.aspx?stype=2&&bg=' + background + '&&height=' + height;
                $('#widget_simple').removeAttr('src').attr('src', src1).removeAttr('height').attr('height', height).removeAttr('width').attr('width', '228');
                iff = "<iframe id='widget_simple' width='100%' height='" + height + "' style='position:absolute;left:0;top:0;' frameborder='0' scrolling='no' src='" + src1 + "'></iframe>";
            } else {
                src1 = wikiurl + webroot + 'template/default/help_pendantShow.aspx?stype=2&&bg=' + background + '&&width=' + width + '&&height=' + height;
                $('#widget_simple').removeAttr('src').attr('src', src1).removeAttr('height').attr('height', height).removeAttr('width').attr('width', parseInt(width) + 8);
                iff = "<iframe id='widget_simple' width='" + width + "' height='" + height + "'  frameborder='0' scrolling='no' src='" + src1 + "'></iframe>";
            }
            $('#invite_url_simple').empty().val(iff);
        });
        ////简洁版结束
    });
    //代码复制功能
    function copy1() {
        var et = document.getElementById("invite_url");
        et.select();
        document.execCommand("Copy");
        alert("复制成功");

    }
    function copy2() {
        var et = document.getElementById("invite_url_simple");
        et.select();
        document.execCommand("Copy");
        alert("复制成功");

    }
    function copy3() {
        var et = document.getElementById("invite_url_city");
        et.select();
        document.execCommand("Copy");
        alert("复制成功");

    }

</script>
<div id="bdw" class="bdw">
    <div id="bd" class="cf">
        <div id="learn">
            <div class="dashboard1" id="dashboard">
                <%LoadUserControl(WebRoot + "UserControls/helpmenu.ascx", null); %>
            </div>
            <div id="content" class="about">
                <div class="box">
                    <div class="box-content">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>
                                    <div class="head">
                                        <h2>团购挂件 - A 美编版 </h2>
                                    </div>
                                    <div class="sect">
                                        <div class="pf">
                                            <div class="pf_left">
                                                <div class="jyx">
                                                    <p class="tt">加工一下，让挂件和你的界面更匹配</p>
                                                    <div class="color_box">
                                                        <div class="ys">颜色:</div>
                                                        <div id="sc" class="l nr"><a class="color1" href="#">橘色</a> <a class="color2" href="#">蓝色</a> <a class="color3" href="#">黄色</a> <a class="color4" href="#">黑色</a></div>
                                                    </div>
                                                    <div class="color_box">
                                                        <div class="ys">尺寸:</div>
                                                        <div id="sc1" class="l nr">
                                                            宽度
                                                            <input type="text" id="wid" value="220"  disabled,class="xzipt" />
                                                            <input type="checkbox" style="vertical-align: middle;" checked="checked" id="zishiying" />
                                                            <label for="zishiying">自动调整宽度</label>
                                                            <br />
                                                            高度
                                                            <input type="text" id="hei" value="360" class="xzipt" />
                                                        </div>
                                                    </div>
                                                    <div class="yl">
                                                        <input type="button" style="width: 200px; padding: 3px; height: 30px;" value="预览并生成代码" id="showyangshi" class="yulan" />
                                                    </div>
                                                    <div class="hddm">
                                                        <p class="tt">获得HTML代码</p>
                                                        <br />
                                                        <span class="zi_hui">请复制下面的代码，粘贴到博客的自定义模块中。</span>
                                                        <textarea id="invite_url" style="width: 360px; height: 80px;" rows="" cols="" name="textarea"></textarea>
                                                    </div>
                                                    <div class="yl">
                                                        <input type="button" style="width: 100px; padding: 3px; height: 30px;" value="复制代码" id="copy_bt1" onclick="copy1()" class="btn_fz" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="pf_right">
                                                <iframe id="widget" width="228" height="360" frameborder="0" scrolling="no" src="<%=AS.GroupOn.Controls.PageValue.WebRoot %>template/default/help_pendantShow.aspx?stype=1"></iframe>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </table>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>
                                    <div class="head">
                                        <h2>团购挂件  - B 精简版 </h2>
                                    </div>
                                    <div class="sect">
                                        <div class="pf">
                                            <div class="pf_left">
                                                <div class="jyx">
                                                    <p class="tt">加工一下，让挂件和你的界面更匹配</p>
                                                    <div class="color_box">
                                                        <div class="ys">颜色:</div>
                                                        <div id="bg_simple" class="l nr"><a class="color1" href="javascript:void(0)">橘色</a> <a class="color2" href="javascript:void(0)">蓝色</a> <a class="color3" href="javascript:void(0)">黄色</a> <a class="color4" href="javascript:void(0)">黑色</a></div>
                                                    </div>
                                                    <div class="color_box">
                                                        <div class="ys">尺寸:</div>
                                                        <div id="sc_simple" class="l nr">
                                                            宽度
                                                            <input type="text" id="wid_simple" value="220" class="xzipt" />
                                                            <input type="checkbox" style="vertical-align: middle;" id="zishiying_simple" />
                                                            <label for="zishiying">自动调整宽度</label>
                                                            <br />
                                                            高度
                                                            <input type="text" id="hei_simple" value="365" class="xzipt" />
                                                        </div>
                                                    </div>
                                                    <div class="yl">
                                                        <input type="button" style="width: 200px; padding: 3px; height: 30px;" value="预览并生成代码" id="showyangshi_simple" class="yulan" />
                                                    </div>
                                                    <div class="hddm">
                                                        <p class="tt">获得HTML代码</p>
                                                        <br />
                                                        <span class="zi_hui">请复制下面的代码，粘贴到博客的自定义模块中。</span>
                                                        <textarea id="invite_url_simple" style="width: 360px; height: 80px;" rows="" cols="" name="textarea"></textarea>
                                                    </div>
                                                    <div class="yl">
                                                        <input type="button" style="width: 100px; padding: 3px; height: 30px;" value="复制代码" id="copy_bt2" onclick="copy2()" class="btn_fz" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="pf_right">
                                                <iframe id="widget_simple" width="228" height="365" frameborder="0" scrolling="no" src="<%=AS.GroupOn.Controls.PageValue.WebRoot %>template/default/help_pendantShow.aspx?stype=2"></iframe>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </table>
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>
                                    <div class="head">
                                        <h2>团购挂件 - C 文字版 </h2>
                                    </div>
                                    <div class="sect">
                                        <div class="pf">
                                            <div class="pf_left">
                                                <div class="jyx">
                                               <%--<div class="city">请选择城市：</div>
                                                    <select id="switchcity">
                                                        <% foreach (ICategory item in categoryList)
                                                           {%>
                                                        <option value="<%=item.Id %>"
                                                            <% if (Convert.ToInt32(Request["switchcity"]) == item.Id)
                                                               { %>
                                                            selected="selected" <%} %>><%=item.Name %></option>
                                                        <%} %>
                                                    </select>--%>
                                                    <div class="color_box">
                                                        <div class="ys">尺寸:</div>
                                                        <div id="sc3" class="l nr">
                                                            宽度
                      <input type="text" id="wid_city" value="220" class="xzipt" />
                                                            <input type="checkbox" style="vertical-align: middle;" id="zishiying_city" />
                                                            <label for="zishiying">自动调整宽度</label>
                                                            <br />
                                                            高度
                      <input type="text" id="hei_city" value="360" class="xzipt" />
                                                        </div>
                                                    </div>
                                                    <div class="yl">
                                                        <input type="button" style="width: 200px; padding: 3px; height: 30px;" value="预览并生成代码" id="showyangshi_city" class="yulan" />
                                                    </div>
                                                    <div class="hddm">
                                                        <p class="tt">获得HTML代码</p>
                                                        <br />
                                                        <span class="zi_hui">请复制下面的代码，粘贴到博客的自定义模块中。</span>
                                                        <textarea id="invite_url_city" style="width: 360px; height: 80px;" rows="" cols="" name="textarea"></textarea>
                                                    </div>
                                                    <div class="yl">
                                                        <input type="button" style="width: 100px; padding: 3px; height: 30px;" value="复制代码" id="copy_bt3"  onclick="copy3()" class="btn_fz" />
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="pf_right">
                                                <iframe id="widget_city" width="220" height="360" frameborder="0" scrolling="no" src="<%=AS.GroupOn.Controls.PageValue.WebRoot %>template/default/help_pendantShow.aspx?stype=3"></iframe>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
            <div class="clear"></div>
        </div>
    </div>
</div>
<%LoadUserControl("_footer.ascx", null); %>
<%LoadUserControl("_htmlfooter.ascx", null); %>


