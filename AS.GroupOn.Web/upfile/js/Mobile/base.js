var MT = window.MT || {};

MT.namespace = function () {
    var b = arguments, g = null, e, c, f;
    for (e = 0; e < b.length; ++e) {
        f = b[e].split(".");
        g = MT;
        for (c = f[0] === "MT" ? 1 : 0; c < f.length; ++c) {
            g[f[c]] = g[f[c]] || {};
            g = g[f[c]];
        }
    }
    return g;
};

MT.namespace("touch");

MT.namespace("util");

MT.namespace("widgets");

var util = MT.util = {
    isLocalStorageSupported: function () {
        try {
            return "localStorage" in window && window.localStorage !== null;
        } catch (a) {
            return false;
        }
    },
    uniq: function (c) {
        var d = [], g = {}, f, e, b = c.length;
        if (b < 2) {
            return c;
        }
        for (f = 0; f < b; f++) {
            e = c[f];
            if (g[e] !== 1) {
                d.push(e);
                g[e] = 1;
            }
        }
        return d;
    },
    errMsgFadeIn: function (a, b) {
        var c = this;
        $("#okMsg").hide();
        if (c.data("active")) {
            c[a](b).animate("shake", 500);
        } else {
            c[a](b).fadeIn().data("active", true);
        }
        window.scrollTo(0, 1);
    },
    bindObjKeys: function () {
        var e = true, b = ["toString", "toLocaleString", "valueOf", "hasOwnProperty", "isPrototypeOf", "propertyIsEnumerable", "constructor"], f = Function.prototype.call.bind(Object.prototype.hasOwnProperty), a = b.length;
        for (var c in {
            toString: null
        }) {
            e = false;
        }
        Object.keys = function d(k) {
            if (typeof k !== "object" && typeof k !== "function" || k === null) {
                throw new TypeError("Object.keys called on a non-object");
            }
            var h = [];
            for (var j in k) {
                if (f(k, j)) {
                    h.push(j);
                }
            }
            if (e) {
                for (var l = 0, m = a; l < m; l++) {
                    var g = b[l];
                    if (f(k, g)) {
                        h.push(g);
                    }
                }
            }
            return h;
        };
    }
};

util.tapOrClick = MT.util.tapOrClick = function () {
    return "click";
}();

(function (a) {
    MT.touch = {
        init: function () {
            var b = this;
            b.formElStyle();
            if (navigator.userAgent.indexOf("Android") === -1) {
                a("input[type=number]").attr("pattern", "[0-9]*").attr("type", "text");
            }
            b.webAppLink();
        },
        initIscroll: function () {
            var c = function (d) {
                a(window).trigger("scroll");
            };
            if (a("form").length == 0) {
                var b = new iScroll("scroll-wrapper", {
                    onScrollMove: c,
                    onScrollEnd: c
                });
            }
        },
        webAppLink: function () {
            var b = function (c) {
                switch (c.nodeName.toLowerCase()) {
                    case "textarea":
                    case "select":
                        return false;

                    case "input":
                        switch (c.type) {
                            case "button":
                            case "checkbox":
                            case "file":
                            case "image":
                            case "radio":
                            case "submit":
                                return true;
                        }
                        return !c.disabled && !c.readOnly;

                    default:
                        return /\bneedsfocus\b/.test(c.className);
                }
            };
            a("body").on(util.tapOrClick, "a", function (c) {
                c.preventDefault();
                if (!a(this).hasClass("no-direct")) {
                    window.location = this.getAttribute("href");
                    return false;
                }
            });
            document.body.addEventListener("click", function (c) {
                if (util.tapOrClick === "tap" && !b(c.target)) {
                    c.stopImmediatePropagation();
                    c.preventDefault();
                }
            }, true);
        },
        formElStyle: function () {
            var b = a("form");
            if (b.length < 1) {
                return;
            }
            var c = a(".forCheckbox");
            c.each(function (f) {
                var d = a(this).find("input").attr("checked");
                a(this).addClass(d);
            });
            c.on(util.tapOrClick, function (f) {
                f.preventDefault();
                c.removeClass("checked");
                var d = a(this).find("input").attr("checked");
                a(this).addClass(d);
            });
        },
        goTop: function () {
            var b = a("#nav-top");
            if (!b) {
                return;
            }
            b.on(util.tapOrClick, function (c) {
                c.preventDefault();
                window.scrollTo(0, 0);
            });
        },
        toggleByLink: function () {
            var b = a(".tag"), c = a(".tab-box");
            b.on(util.tapOrClick, function (f) {
                f.preventDefault();
                var d = a(this), g = d.next(".tab-box");
                if (g.css("display") === "block") {
                    g.hide();
                    d.removeClass("current");
                } else {
                    g.show();
                    d.addClass("current");
                }
            });
        },
        tipsForLink: function (d, c) {
            var b = a(d);
            b.on(util.tapOrClick, function (g) {
                g.preventDefault();
                var f = window.confirm(c);
                if (!f) {
                    return;
                }
                window.location = b.data("href");
            });
        },
        commonBanner: function (c) {
            var d = a("#common-banner");
            if (d.find("ul>li").length > 1) {
                var b = document.createElement("script");
                b.async = "async";
                b.src = c;
                b.onload = function () {
                    new a.slide({
                        panel: d.find("ul"),
                        tab: d.find("ol"),
                        easing: "ease",
                        direction: "left",
                        duration: .2
                    });
                };
                a("head").append(b);
            }
        },
        _changeForm2TenPay: function (c, f, b, e) {
            if (c.length > 0) {
                var d = '<input type="hidden" name="bank_type" value="' + e + '" />';
                c.replaceWith(a(d));
            } else {
                f.val(e);
            }
            b.val("tenpaywap");
        },
        _changeForm2AliPay: function (c, f, b, e) {
            if (f.length > 0) {
                var d = '<input type="hidden" name="cashierCode" value="' + e + '" />';
                f.replaceWith(a(d));
            } else {
                c.val(e);
            }
            b.val("alipaywap");
        },
        selectBank: function (c, e) {
            var b = c.find("span"), d = this;
            b.on(util.tapOrClick, function (m) {
                m.preventDefault();
                b.css("background", "#FFF");
                a(this).css("background", "#F1F1F1");
                var l = a(this), h, k = l.data("bankcode"), i = l.data("banktype"), f = c.find("input[name=paytype]"), g = c.find("input[name=cashierCode]"), j = c.find("input[name=bank_type]");
                if (i === "bank_type") {
                    d._changeForm2TenPay(g, j, f, k);
                } else {
                    d._changeForm2AliPay(g, j, f, k);
                }
                if (e) {
                    verifyAccount();
                } else {
                    c.submit();
                }
            });
        },
        initQuantityBox: function () {
            a(".quantity-box").on(util.tapOrClick, function (h) {
                h.preventDefault();
                var g = a(this), c = g.find(".minus"), f = g.find(".plus"), i = g.find("input"), d = i.attr("min") || 0, b = i.attr("max") || Number.MAX_VALUE;
                target = h.target.parentNode.className, quantity = Number(i.val());
                if (target.indexOf("minus") > -1) {
                    if (quantity - 1 >= d) {
                        i.val(quantity - 1);
                    }
                    if (quantity - 1 == d) {
                        c.removeClass("active");
                    }
                    if (f.attr("class").indexOf("active") < 0) {
                        f.addClass("active");
                    }
                } else {
                    if (target.indexOf("plus") > -1) {
                        if (quantity + 1 <= b) {
                            i.val(quantity + 1);
                        }
                        if (quantity + 1 == b) {
                            f.removeClass("active");
                        }
                        if (c.attr("class").indexOf("active") < 0) {
                            c.addClass("active");
                        }
                    }
                }
            });
        }
    };
})(Zepto);