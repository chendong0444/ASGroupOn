

var asdhtMall = new Object();
asdhtMall = {
    brandHover: function () {
        jQuery('#brandlist-ul li').hover(function () {
            jQuery(this).css({ 'border-bottom': '1px solid #ED145B' });
        }, function () {
            jQuery(this).css({ 'border-bottom': '1px solid #cccccc' });
        });
    },
    hotTeam: function () {
        jQuery('#hotlist-div li').hover(function () {

            jQuery('#new_new').hide(); jQuery('#new').children('a').removeClass('bm_htpccur');
            jQuery('#new_hot').hide(); jQuery('#hot').children('a').removeClass('bm_htpccur');
            jQuery('#new_star').hide(); jQuery('#star').children('a').removeClass('bm_htpccur');
            jQuery('#new_slow').hide(); jQuery('#slow').children('a').removeClass('bm_htpccur');
            var _id = jQuery(this).attr('id');
            jQuery('#new_' + _id).show();

            jQuery(this).children('a').addClass('bm_htpccur');
        }, function () {

        });
    },
    addCart: function (tid) {
        //添加到购物,如果重复购物车已经存在,则在其数量上加即可.如果选择不同的规格,则以最后一次为准
        var quantity = 1;
      
        jQuery.ajax({
            type: "POST",
            url: webroot + "ajax/car.aspx?type=mall&id=" + tid,
            success: function (rs) {
                if (rs == "1") {
                    alert('您已经成功添加到购物车');
                } else if (rs == 'lessquantity') {
                    alert('库存量不足,请重新挑选数量');
                } else if (rs == 'morequantity') {
                    alert('数量有限,您不能过多地添加到购物车');
                } else {
                    alert('添加失败,请刷新重试');
                }
            },
            error: function () {
                alert('加载失败,请刷新重试');
            }
        });
    },
    siderHover: function (sign) {
        jQuery('#bm_slist' + sign + ' li').hover(function () {
            jQuery('#bm_slist' + sign).find('.bm_slimg').each(function () { jQuery(this).hide(); });
            jQuery(this).children('.bm_slimg').show();
            jQuery(this).find('img').each(function () { jQuery(this).attr('src', jQuery(this).attr('original')); jQuery(this).show(); });
        }, function () {

        });

    },
    hotlist: function (sign) {
        jQuery('#bm_slist' + sign + ' li').hover(function () {
            jQuery('#brdlst_slist').find('.bm_slimg').each(function () { jQuery(this).hide(); });
            jQuery(this).children('.bm_slimg').show();
        });
    },
    menulist: function (sign) {
        if (!sign) { sign = 0; }
        jQuery('.bcls').each(function () { jQuery(this).show(); });
        jQuery('#menua' + sign).hide();
        jQuery('.c').attr('id', 'c' + sign);
        jQuery('#menuid').html(jQuery('#menuid' + sign).html());
    },
    setMore: function (id, height, obj) {
        if (jQuery("#" + id).css("height") == "auto") {
            jQuery("#" + id).css("height", height);
            jQuery(obj).html("更多");
        } else {
            jQuery("#" + id).css("height", "auto");
            jQuery(obj).html("精简");
        }
    },
    orderby: function (obj, url) {
        crutclass = jQuery(obj).attr('class');
        if (crutclass == 'schlist_upbtn') {
            crutclass = 'schlist_downbtn';
        } else {
            crutclass = 'schlist_upbtn';
        }
        jQuery(obj).attr('class', crutclass);
        jQuery.get(WEB_ROOT + url + "&oby=" + by + "&name=" + obj.name, function (html) { jQuery('#teamRs').html(html); });
        if (by == 'up') {
            by = 'down';
        } else {
            by = 'up';
        }
    }
}

var X = {};
X.get = function (u) { return X.ajax(u, {}, 'GET'); };
X.ajax = function (u, data, method) {
    if (u.indexOf('?') > 0)
        u = u + '&asdht=' + Math.random();
    else
        u = u + '?asdht=' + Math.random();
    jQuery.ajax({
        type: method,
        url: u,
        data: data,
        dataType: "json",
        success: X.json
    });
    return false;
};
X.json = function (r) {
    if (r != null) {
        var type = r['data']['type'];
        var data = r['data']['data'];
        if (type == 'alert') {
            alert(data);
        } else if (type == 'eval') {
            eval(data);
        } else if (type == 'refresh') {
            window.location.reload();
        } else if (type == 'updater') {
            var id = data['id'];
            var inner = data['html'];
            jQuery('#' + id).html(inner);
        } else if (type == 'frameDialog') {
            X.boxShowFrame(data, true);
        } else if (type == 'dialog') {
            X.boxShow(data, true);
        } else if (type == 'showdialog') {
            X.box(data);
        } else if (type == 'mix') {
            for (var x in data) {
                r['data'] = data[x];
                X.json(r);
            }
        }
    }
};
X.boxShowFrame = function (innerHTML, mask) {
    var dialog = $(window.parent.window.frames['Right'].document).find("#dialog");
    dialog.html(innerHTML);
    if (mask) {
        var height = $(window.parent.window.frames['Right'].document).height() + 'px';
        var width = $(window.parent.window.frames['Right'].document).width() + 'px';
        $(window.parent.window.frames['Right'].document).find('#pagemasker').css({ 'position': 'absolute', 'z-index': '3000', 'width': width, 'height': height, 'filter': 'alpha(opacity=0.5)', 'opacity': 0.5, 'top': 0, 'left': 0, 'background': '#CCC' });
        $(window.parent.window.frames['Right'].document).find('#pagemasker').attr('display', mask);
        $(window.parent.window.frames['Right'].document).find('#dialog').attr('display', mask);
    }
    var ew = $(dialog).get(0).scrollWidth;
    //var lt = (ww / 3 - ew / 3) + 'px';
    var dw = $(dialog).width();
    var ww = $(window.parent.window.frames['Right'].document).width();
    var wh = $(window.parent.window.frames['Right'].document).height();
    var x, y;
    if (window.parent.window.frames['Right'].document.body.scrollTop) {
        x = window.parent.window.frames['Right'].document.body.scrollLeft;
        y = window.parent.window.frames['Right'].document.body.scrollTop;
    }
    else {
        x = window.parent.window.frames['Right'].document.documentElement.scrollLeft;
        y = window.parent.window.frames['Right'].document.documentElement.scrollTop;
    }
    xy = { x: x, y: y };
    var lt = ((ww - dw) / 2 + xy.x) + 'px'; //右侧框架宽度+滚动条左侧宽度
    var tp = (wh * 0.05 + xy.y) + 'px'; //右侧框架高度 * 0.05+滚动条高度
    dialog.css('background-color', '#FFF');
    dialog.css('left', lt);
    dialog.css('top', tp);
    dialog.css('z-index', 9999);
    dialog.css('display', 'block');

    return false;
};
X.boxShow = function (innerHTML, mask) {
    var dialog = jQuery('#dialog');
    dialog.html(innerHTML);
    if (mask) { X.boxMask('block'); }
    var ew = dialog.get(0).scrollWidth;
    var ww = jQuery(window).width();
    var lt = (ww / 2 - ew / 2) + 'px';
    var wh = jQuery(window).height();
    var xy = X.getXY();

    var tp = (wh * 0.15 + xy.y) + 'px';

    dialog.css('background-color', '#FFF');
    dialog.css('left', lt);
    dialog.css('top', tp);
    dialog.css('z-index', 9999);
    dialog.css('display', 'block');

    return false;
};
X.box = function () {
    var box = jQuery('#box');
    // alert(box);
};

X.getXY = function () {
    var x, y;
    if (document.body.scrollTop) {
        x = document.body.scrollLeft;
        y = document.body.scrollTop;
    }
    else {
        x = document.documentElement.scrollLeft;
        y = document.documentElement.scrollTop;
    }
    return { x: x, y: y };
};

X.boxMask = function (display) {
    var height = jQuery('body').height() + 'px';
    var width = jQuery(window).width() + 'px';
    jQuery('#pagemasker').css({ 'position': 'absolute', 'z-index': '3000', 'width': width, 'height': height, 'filter': 'alpha(opacity=0.5)', 'opacity': 0.5, 'top': 0, 'left': 0, 'background': '#CCC', 'display': display });
    jQuery('#dialog').css('display', display);
};

X.boxShow = function (innerHTML, mask) {
    var dialog = jQuery('#dialog');
    dialog.html(innerHTML);
    if (mask) { X.boxMask('block'); }
    var ew = dialog.get(0).scrollWidth;
    var ww = jQuery(window).width();
    var lt = (ww / 2 - ew / 2) + 'px';
    var wh = jQuery(window).height();
    var xy = X.getXY();

    var tp = (wh * 0.15 + xy.y) + 'px';

    dialog.css('background-color', '#FFF');
    dialog.css('left', lt);
    dialog.css('top', tp);
    dialog.css('z-index', 9999);
    dialog.css('display', 'block');

    return false;
};
X.boxClose = function () {
    jQuery('#dialog').html('').css('z-index', -9999);
    X.boxMask('none');
    return false;
};
/* X.miscajax */
X.miscajax = function (script, action) {
    return !X.get(webroot + 'ajax/' + script + '.aspx?action=' + action + "&a=" + Math.random());
};






