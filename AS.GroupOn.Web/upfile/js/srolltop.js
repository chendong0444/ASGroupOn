

//返回顶部按钮
function show_goback(page_name) {
    if (page_name != 'index2') {
        var nav_num = 0; loc_url = location.href;
        var domain = loc_url.substring(7);
        domain = domain.substring(0, domain.indexOf('/'));
        var is_show_by_page = 0;    //是否显示按钮根据不同的页面
        var back_links = $('.mainnav .nav ul li a');
        back_links.each(function (i) {
            if (loc_url.indexOf($(back_links[i]).attr('href')) == 7 + domain.length) {
                nav_num = i;
                is_show_by_page = 1;
                return false;
            }
        });
        if (is_show_by_page == 0 && loc_url == 'http://' + domain + '/') {
            is_show_by_page = 1;
        }
        if (is_show_by_page == 0) {
            return false;
        }
        var re = 90;
    } else {
        var re = 240;
        is_show_by_page = 1;
    }
    var fe = $('#go_lstop');
    var top_h = $('#go_lstop').height();
    var footer_top = $('.g_footer').offset().top;

    if (nav_num == 0) {
        top_h -= 148;
    }
    function fixed_goback() {
        var y = $(window).scrollTop();
        if (y < 450) {
            fe.css('display', 'none');
            fe.stop();
            fe.hide();
            return false;
        } else {
            fe.fadeIn();
        }

        var top, ua = get_navigator();
        var h = $(window).height() - re;
        if (ua == 'ie6') {
            if (footer_top <= y + h + top_h + top) {
                top = footer_top - top_h - 25;
            } else {
                top = y + h;
            }
        } else {
            if (footer_top <= y + h + top_h + top) {
                top = footer_top - y - top_h - 25;
            } else {
                top = h;
                if (top < 0) {
                    top = 10;
                }

            }
        }
        var window_width = $(window).width();

        var left = (window_width + 996) / 2;

        fe.css('display', 'block');
        fe.css('top', top + 'px');
        fe.css('margin-left', left + 'px');

    }
    $(window).scroll(function () { fixed_goback(); });
    $(window).resize(function () { fixed_goback(); });
}


//返回浏览器版本
function get_navigator() {
    var ua = navigator.userAgent.toLowerCase();
    if (ua.indexOf('msie 6.0') > -1) {
        return 'ie6';
    } else if (ua.indexOf('firefox') > -1) {
        return 'firefox';
    }
    return false;
}

