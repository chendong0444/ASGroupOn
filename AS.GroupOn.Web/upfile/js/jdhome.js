jQuery.easing['jswing'] = jQuery.easing['swing'];
jQuery.extend( jQuery.easing,
{
	def: 'easeOutQuad',
	swing: function (x, t, b, c, d) {
		//alert(jQuery.easing.default);
		return jQuery.easing[jQuery.easing.def](x, t, b, c, d);
	},
	easeInQuad: function (x, t, b, c, d) {
		return c*(t/=d)*t + b;
	},
	easeOutQuad: function (x, t, b, c, d) {
		return -c *(t/=d)*(t-2) + b;
	},
	easeInOutQuad: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t + b;
		return -c/2 * ((--t)*(t-2) - 1) + b;
	},
	easeInCubic: function (x, t, b, c, d) {
		return c*(t/=d)*t*t + b;
	},
	easeOutCubic: function (x, t, b, c, d) {
		return c*((t=t/d-1)*t*t + 1) + b;
	},
	easeInOutCubic: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t + b;
		return c/2*((t-=2)*t*t + 2) + b;
	},
	easeInQuart: function (x, t, b, c, d) {
		return c*(t/=d)*t*t*t + b;
	},
	easeOutQuart: function (x, t, b, c, d) {
		return -c * ((t=t/d-1)*t*t*t - 1) + b;
	},
	easeInOutQuart: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
		return -c/2 * ((t-=2)*t*t*t - 2) + b;
	},
	easeInQuint: function (x, t, b, c, d) {
		return c*(t/=d)*t*t*t*t + b;
	},
	easeOutQuint: function (x, t, b, c, d) {
		return c*((t=t/d-1)*t*t*t*t + 1) + b;
	},
	easeInOutQuint: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
		return c/2*((t-=2)*t*t*t*t + 2) + b;
	},
	easeInSine: function (x, t, b, c, d) {
		return -c * Math.cos(t/d * (Math.PI/2)) + c + b;
	},
	easeOutSine: function (x, t, b, c, d) {
		return c * Math.sin(t/d * (Math.PI/2)) + b;
	},
	easeInOutSine: function (x, t, b, c, d) {
		return -c/2 * (Math.cos(Math.PI*t/d) - 1) + b;
	},
	easeInExpo: function (x, t, b, c, d) {
		return (t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b;
	},
	easeOutExpo: function (x, t, b, c, d) {
		return (t==d) ? b+c : c * (-Math.pow(2, -10 * t/d) + 1) + b;
	},
	easeInOutExpo: function (x, t, b, c, d) {
		if (t==0) return b;
		if (t==d) return b+c;
		if ((t/=d/2) < 1) return c/2 * Math.pow(2, 10 * (t - 1)) + b;
		return c/2 * (-Math.pow(2, -10 * --t) + 2) + b;
	},
	easeInCirc: function (x, t, b, c, d) {
		return -c * (Math.sqrt(1 - (t/=d)*t) - 1) + b;
	},
	easeOutCirc: function (x, t, b, c, d) {
		return c * Math.sqrt(1 - (t=t/d-1)*t) + b;
	},
	easeInOutCirc: function (x, t, b, c, d) {
		if ((t/=d/2) < 1) return -c/2 * (Math.sqrt(1 - t*t) - 1) + b;
		return c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b;
	},
	easeInElastic: function (x, t, b, c, d) {
		var s=1.70158;var p=0;var a=c;
		if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
		if (a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		return -(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
	},
	easeOutElastic: function (x, t, b, c, d) {
		var s=1.70158;var p=0;var a=c;
		if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
		if (a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		return a*Math.pow(2,-10*t) * Math.sin( (t*d-s)*(2*Math.PI)/p ) + c + b;
	},
	easeInOutElastic: function (x, t, b, c, d) {
		var s=1.70158;var p=0;var a=c;
		if (t==0) return b;  if ((t/=d/2)==2) return b+c;  if (!p) p=d*(.3*1.5);
		if (a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		if (t < 1) return -.5*(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
		return a*Math.pow(2,-10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )*.5 + c + b;
	},
	easeInBack: function (x, t, b, c, d, s) {
		if (s == undefined) s = 1.70158;
		return c*(t/=d)*t*((s+1)*t - s) + b;
	},
	easeOutBack: function (x, t, b, c, d, s) {
		if (s == undefined) s = 1.70158;
		return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
	},
	easeInOutBack: function (x, t, b, c, d, s) {
		if (s == undefined) s = 1.70158; 
		if ((t/=d/2) < 1) return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b;
		return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;
	},
	easeInBounce: function (x, t, b, c, d) {
		return c - jQuery.easing.easeOutBounce (x, d-t, 0, c, d) + b;
	},
	easeOutBounce: function (x, t, b, c, d) {
		if ((t/=d) < (1/2.75)) {
			return c*(7.5625*t*t) + b;
		} else if (t < (2/2.75)) {
			return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
		} else if (t < (2.5/2.75)) {
			return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
		} else {
			return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
		}
	},
	easeInOutBounce: function (x, t, b, c, d) {
		if (t < d/2) return jQuery.easing.easeInBounce (x, t*2, 0, c, d) * .5 + b;
		return jQuery.easing.easeOutBounce (x, t*2-d, 0, c, d) * .5 + c*.5 + b;
	}
});

(function(){
	//mouseover
	$(".plist .style1 .p-img,.plist .style2 .p-img").bind("mouseover",function(){
		$(this).css("opacity","0.7");
	}).bind("mouseout",function(){
		$(this).css("opacity","1");
	});
//	$("#hot").Jtab({
//		delay:200,
//		source:"data-boole"
//	},function(source,object,n){
//		var _width=(window.screen.width>=1200)?178:154;
//		$("#hot .tab-arrow").animate({
//			left: n*_width
//		}, 500, 'easeInOutQuint');
//		if(n==1){
//			if(!source){
//				return;
//			}
//			pageConfig.FN_GuessYou(source,object);
//		}else{
//			object.find("img").Jlazyload({
//				type:"image",
//				source:"data-src"
//			},function(){
//				pageConfig.FN_ImgError(object.get(0));
//			})
//		}
//	});
	///限时抢购
//	pageConfig.TIMER_Timed=[];
//	pageConfig.FN_TimedInit=function(){
//		$.Jtimer({
//			pids:"36,37,38,39,40",
//			template:pageConfig.TPL_Timed,
//			reset:pageConfig.FN_TimedInit,
//			timer:pageConfig.TIMER_Timed,
//			finishedClass:"pi pix0"
//		})
//	};
//	pageConfig.FN_TimedInit();
	//slide tpls
	pageConfig.TPL_MSlide={
		itemsWrap:"<ul class=\"slide-items\">{innerHTML}</ul>",
		itemsContent:"{for item in json}\
			{var v=pageConfig.FN_GetCompatibleData(item)}\
			<li><a href=\"${v.href}\" target=\"_blank\" title=\"${v.alt}\">\
				<img height=\"${v.height}\" width=\"${v.width}\" src=\"${v.src}\" data-img=\"2\" />\
			</a></li>\
		{/for}",
		controlsWrap:"<div class=\"slide-controls\">{innerHTML}</div>",
		controlsContent:"{for item in json}\
			<span class=\"{if parseInt(item_index)==0}curr{/if}\">${parseInt(item_index)+1}</span>\
		{/for}"
	};
	//slides
	$("#slide").Jslider({
		data:pageConfig.DATA_MSlide,
		auto:true,
		reInit:true,
		slideWidth:(screen.width>=1210)?670:550,
		slideHeight:240,
		maxAmount:10,
		slideDirection:3,
		template:pageConfig.TPL_MSlide
	});
	var a = new pageConfig.FN_InitSidebar();
	a.setTop();
	a.scroll();
})();
(function($) {
    $.fn.imgScroll = function(options, callback) {
        // 默认参数
        var defaults = {
            // 动态数据
            data: [],
            // 数据渲染模板
            template: null,
            // 事件类型=click,mouseover
            evtType: 'click',
            // 可见图片个数
            visible: 1,
            // 方向x,y
            direction: 'x',
            // 按钮-下一张，默认为元素选择器字符串，也可以是jQuery对象
            next: '#next',
            // 按钮-上一张，默认为元素选择器字符串，也可以是jQuery对象
            prev: '#prev',
            // 滚动到头按钮class
            disableClass: 'disabled',
            // 滚动到头按钮class是否加方向前缀prev-, next-
            disableClassPerfix: false,
            // 滚动速度
            speed: 300,
            // 每次滚动图片个数
            step: 1,
            // 是否循环
            loop: false,
            // 无法(不足以)滚动时是否显示控制按钮
            showControl: false,
            // 每个滚动元素宽度，默认取li的outerWidth
            width: null,
            // 每个滚动元素宽度，默认取li的outerHeight
            height: null,
            // 是否显示滚动当前状态(1,2,3,4,...)
            navItems: false,
            // 包围元素的class，默认为'scroll-nav-wrap'
            navItmesWrapClass: 'scroll-nav-wrap',
            // 当前项目高亮class
            navItemActivedClass: 'current',
            // 滚动分页状态条==<<==(n/total)==>>==
            status: false,
            // 滚动分布状态条包围元素选择器，如页面已准备好元素可传元素css selector否则生成一个class为scroll-status-wrap的div插入到滚动后面
            statusWrapSelector: '.scroll-status-wrap'

        };

        // 继承 初始化参数 - 替代默认参数
        var settings = $.extend(defaults, options);

        // 实例化每个滚动对象
        return this.each(function() {

            var that = $(this),
                ul = that.find('ul').eq(0),
                nextFrame, lis = ul.children('li'),
                len = lis.length,
                liWidth = null,
                liHeight = null,

                btnNext = typeof settings.next == 'string' ? $(settings.next) : settings.next,
                btnPrev = typeof settings.prev == 'string' ? $(settings.prev) : settings.prev,

                current = 0,
                step = settings.step,
                visible = settings.visible,
                total = Math.ceil((len - visible) / step) + 1,
                loop = settings.loop,
                dir = settings.direction,
                evt = settings.evtType,

                disabled = settings.disableClass,
                prevDisabled = settings.disableClassPerfix ? 'prev-' + disabled : disabled,
                nextDisabled = settings.disableClassPerfix ? 'next-' + disabled : disabled,

                nav = settings.navItems,
                navWrap = settings.navItmesWrapClass,
                navHasWrap = $('.' + navWrap).length > 0,
                navClass = settings.navItemActivedClass,

                status = settings.status,
                statusWrap = settings.statusWrapSelector,
                hasStatusWrap = $(statusWrap).length > 0,

                last = false,
                first = true,

                perfect = (len - visible) % step === 0,

                TPL = settings.template || '<ul>{for slide in list}<li><a href="${slide.href}" target="_blank"><img src="${slide.src}" alt="${slide.alt}" /></a></li>{/for}</ul>';


            /**
             * direction 滚动方向
             */
            function resetStyles(direction) {

                // 重置按钮样式
                if(len >= step + visible && !loop) {
                    btnPrev.addClass(prevDisabled);
                    btnNext.removeClass(nextDisabled);
                } else {
                    if(!loop) {
                        btnNext.addClass(nextDisabled);
                    }
                }

                // 重置每个滚动列表项样式
                if(lis.eq(0).css('float') !== 'left') {
                    lis.css('float', 'left');
                }

                // 重新设置滚动列表项高宽
                liWidth = settings.width || lis.eq(0).outerWidth();
                liHeight = settings.height || lis.eq(0).outerHeight();

                // 重置最外层可视区域元素样式
                that.css({
                    'position': that.css('position') == 'static' ? 'relative' : that.css('position'),
                    'width': direction == 'x' ? liWidth * visible : liWidth,
                    'height': direction == 'x' ? liHeight : liHeight * visible,
                    'overflow': 'hidden'
                });

                // 重置滚动内容区元素样式
                ul.css({
                    'position': 'absolute',
                    'width': direction == 'x' ? liWidth * len : liWidth,
                    'height': direction == 'x' ? liHeight : liHeight * len,
                    'top': 0,
                    'left': 0
                });

                if(typeof callback === 'function') {

                    callback.apply(that, [
                    current, total,
                    // 每次可视区li的总集合
                    lis.slice(current * step, current * step + visible),
                    // 每次滚动到可视区li的集合
                    lis.slice(current * step + visible - step, current * step + visible)]);

                }
            }

            /**
             * 重新初始化参数
             */
            function reInitSettings() {

                len = settings.data.length;
                ul = that.find('ul').eq(0);
                lis = ul.children('li');
                total = Math.ceil((len - visible) / step) + 1;
                perfect = (len - visible) % step === 0;
            }

            /**
             * direction 滚动方向
             */
            function renderHTML(data) {
                var r = {
                    list: data
                };

                that.html(TPL.process(r));

                reInitSettings();
            }

            /**
             * index 切换到第几页滚动
             * isPrev 是否点击上一张
             */
            function switchTo(index, isPrev) {

                // 是否正在动画中
                if(ul.is(':animated')) {
                    return false;
                }

                if(loop) {
                    if(first && isPrev) {
                        current = total;
                    }

                    if(last && !isPrev) {
                        current = -1;
                    }
                    index = isPrev ? --current : ++current;
                } else {

                    // 是否滚动到头或者尾
                    if(first && isPrev || last && !isPrev) {
                        return false;
                    } else {
                        index = isPrev ? --current : ++current;
                    }
                }


                // 滚动下一帧位移量
                nextFrame = dir == 'x' ? {
                    left: index >= (total - 1) ? -(len - visible) * liWidth : -index * step * liWidth
                } : {
                    top: index >= (total - 1) ? -(len - visible) * liHeight : -index * step * liHeight
                };

                // 滚动完成一帧回调


                function onEnd() {

                    if(!loop) {
                        // 滚动尾
                        if(len - index * step <= visible) {
                            btnNext.addClass(nextDisabled);
                            last = true;
                        } else {
                            btnNext.removeClass(nextDisabled);
                            last = false;
                        }

                        // 滚动头
                        if(index <= 0) {
                            btnPrev.addClass(prevDisabled);
                            first = true;
                        } else {
                            btnPrev.removeClass(prevDisabled);
                            first = false;
                        }
                    } else {
                        if(len - index * step <= visible) {
                            last = true;
                        } else {
                            last = false;
                        }

                        if(index <= 0) {
                            first = true;
                        } else {
                            first = false;
                        }
                    }


                    // 显示导航数字
                    if(nav || status) {
                        setCurrent(index);
                    }

                    // 每次滚动后回调参数
                    if(typeof callback == 'function') {
                        /**
                         * index 当前滚动到第几页
                         * total 一共有多少页
                         * 可视区域内的滚动li jQuery对象集合
                         */

                        callback.apply(that, [
                        index, total,
                        // 每次可视区li的总集合
                        lis.slice(index * step, index * step + visible),
                        // 每次滚动到可视区li的集合
                        lis.slice(index * step + visible - step, index * step + visible)]);
                    }
                }

                // 是否动画滚动
                if( !! settings.speed) {
                    ul.animate(
                    nextFrame, settings.speed, onEnd);
                } else {
                    ul.css(nextFrame);
                    onEnd();
                }
            }

            /**
             * 显示数字分页1,2,3,4,5,6...
             * nav 数字导航外层div的class
             * 数字导航当前页高亮class
             */
            function showNavItem(nav, actived) {

                var navPage = navHasWrap ? $('.' + nav).eq(0) : $('<div class="' + nav + '"></div>');

                for(var i = 0; i < total; i++) {
                    navPage.append('<em ' + (i === 0 ? ' class=' + actived : '') + ' title="' + (i + 1) + '">' + (i + 1) + '</em>');
                }

                if(!navHasWrap) {
                    that.after(navPage);
                }
            }

            /**
             * 显示数字导航 (1/10)
             */
            function showStatus() {
                var statusPage = hasStatusWrap ? $(statusWrap).eq(0) : $('<div class="' + statusWrap.replace('.', '') + '"></div>');

                statusPage.html('<b>1</b>/' + total);

                if(!hasStatusWrap) {
                    that.after(statusPage);
                }
            }

            // 设置当前状态的数字导航与分页
            function setCurrent(ind) {
                if(nav) {
                    $('.' + navWrap).find('em').removeClass(navClass).eq(ind).addClass(navClass);
                }

                if(status) {
                    $(statusWrap).html('<b>' + (ind + 1) + '</b>/' + total);
                }
            }

            function bindEvent() {
                btnPrev.unbind(evt).bind(evt, function() {
                    switchTo(current, true);
                });
                btnNext.unbind(evt).bind(evt, function() {
                    switchTo(current, false);
                });
            }

            // 自定义数据模板
            if(settings.data.length > 0) {
                if(!settings.width || !settings.height) {
                    return false;
                }

                renderHTML(settings.data);
            }

            // 初始化滚动
            if(len > visible && visible >= step) {


                // 可以滚动
                resetStyles(dir);
                bindEvent();

                if(nav) {
                    showNavItem(navWrap, navClass);
                }

                if(status) {
                    showStatus(statusWrap);
                }
            } else {
                // 无法滚动
                //if(settings.showControl) {
                //    btnNext.add(btnPrev).show();
                //} else {
                //    btnNext.add(btnPrev).hide();
                //}
                //btnPrev.addClass(prevDisabled);
                //btnNext.addClass(nextDisabled);
                resetStyles(dir);
                //bindEvent();
                if (nav) {
                    showNavItem(navWrap, navClass);
                }
                if (status) {
                    showStatus(statusWrap);
                }
            }
        });
    };
})(jQuery);
$("#mscroll-list").imgScroll({
	width:(screen.width>=1200)?203:163,
	height: 159,
	visible:3,
	step: 3,
	loop: true,
	next: "#mscroll-ctrl-next",
	prev: "#mscroll-ctrl-prev",
	data: pageConfig.DATA_MScroll,
	template: pageConfig.TPL_MScroll
}, function(n, total, objs, exObjs) {
	exObjs.find("img").each(function() {
		var style = $(this).attr("data-lazyload");
		if ( !$(this).attr("style") ) {
			$(this).attr("style", style).removeAttr("data-lazyload");
		}
	});	
});
(function (a) {
    a.fn.jqueryzoom = function (b) {
        var d = {
            xzoom: 200,
            yzoom: 200,
            offset: 10,
            position: "right",
            lens: 1,
            preload: 1
        };
        if (b) {
            a.extend(d, b)
        }
        var c = "";
        a(this).hover(function () {
            var g = a(this).offset().left;
            var l = a(this).offset().top;
            var j = a(this).find("img").get(0).offsetWidth;
            var f = a(this).find("img").get(0).offsetHeight;
            c = a(this).find("img").attr("alt");
            var h = a(this).find("img").attr("jqimg");
            a(this).find("img").attr("alt", "");
            if (a("div.zoomdiv").get().length == 0) {
                a(this).after("<div class='zoomdiv'><img class='bigimg' src='" + h + "'/></div>");
                a(this).append("<div class='jqZoomPup'>&nbsp;</div>")
            }
            function k(m) {
                this.x = m.pageX;
                this.y = m.pageY
            }
            a("div.zoomdiv").width(d.xzoom);
            a("div.zoomdiv").height(d.yzoom);
            a("div.zoomdiv").show();
            if (!d.lens) {
                a(this).css("cursor", "crosshair")
            }
            a(document.body).mousemove(function (p) {
                mouse = new k(p);
                var q = a(".bigimg").get(0).offsetWidth;
                var o = a(".bigimg").get(0).offsetHeight;
                var m = "x";
                var n = "y";
                if (isNaN(n) | isNaN(m)) {
                    var n = (q / j);
                    var m = (o / f);
                    a("div.jqZoomPup").width((d.xzoom) / (n * 1));
                    a("div.jqZoomPup").height((d.yzoom) / (m * 1));
                    if (d.lens) {
                        a("div.jqZoomPup").css("visibility", "visible")
                    }
                }
                xpos = mouse.x - a("div.jqZoomPup").width() / 2 - g;
                ypos = mouse.y - a("div.jqZoomPup").height() / 2 - l;
                if (d.lens) {
                    xpos = (mouse.x - a("div.jqZoomPup").width() / 2 < g) ? 0 : (mouse.x + a("div.jqZoomPup").width() / 2 > j + g) ? (j - a("div.jqZoomPup").width() - 2) : xpos;
                    ypos = (mouse.y - a("div.jqZoomPup").height() / 2 < l) ? 0 : (mouse.y + a("div.jqZoomPup").height() / 2 > f + l) ? (f - a("div.jqZoomPup").height() - 2) : ypos
                }
                if (d.lens) {
                    a("div.jqZoomPup").css({
                        top: ypos,
                        left: xpos
                    })
                }
                scrolly = ypos;
                a("div.zoomdiv").get(0).scrollTop = scrolly * m;
                scrollx = xpos;
                a("div.zoomdiv").get(0).scrollLeft = (scrollx) * n
            })
        }, function () {
            a(this).children("img").attr("alt", c);
            a(document.body).unbind("mousemove");
            if (d.lens) {
                a("div.jqZoomPup").remove()
            }
            a("div.zoomdiv").remove()
        });
        count = 0;
        if (d.preload) {
            a("body").append("<div style='display:none;' class='jqPreload" + count + "'>360buy</div>");
            a(this).each(function () {
                var g = a(this).children("img").attr("jqimg");
                var f = jQuery("div.jqPreload" + count + "").html();
                jQuery("div.jqPreload" + count + "").html(f + '<img src="' + g + '">')
            })
        }
    }
})(jQuery);