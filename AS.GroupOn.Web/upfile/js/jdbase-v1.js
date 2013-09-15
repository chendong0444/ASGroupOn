window.pageConfig = window.pageConfig || {};
pageConfig.wideVersion = (function () {
    return (screen.width >= 1210)
})();
if (pageConfig.wideVersion && pageConfig.compatible) {
    document.getElementsByTagName("body")[0].className = "root61"
}
pageConfig.FN_GetUrl = function (a, b) {
    if (typeof a == "string") {
        return a
    } else {
        return pageConfig.FN_GetDomain(a) + b + ".html"
    }
};
pageConfig.FN_StringFormat = function () {
    var e = arguments[0], f = arguments.length;
    if (f > 0) {
        for (var d = 0; d < f; d++) {
            e = e.replace(new RegExp("\\{" + d + "\\}", "g"), arguments[d + 1])
        }
    }
    return e
};
pageConfig.FN_GetRandomData = function (c) {
    var b = 0, f = 0, a, e = [];
    for (var d = 0; d < c.length; d++) {
        a = c[d].weight ? parseInt(c[d].weight) : 1;
        e[d] = [];
        e[d].push(b);
        b += a;
        e[d].push(b)
    }
    f = Math.ceil(b * Math.random());
    for (var d = 0; d < e.length; d++) {
        if (f > e[d][0] && f <= e[d][1]) {
            return c[d]
        }
    }
};
pageConfig.FN_GetCompatibleData = function (b) {
    var a = (screen.width < 1210);
    if (a) {
        b.width = b.widthB ? b.widthB : b.width;
        b.height = b.heightB ? b.heightB : b.height;
        b.src = b.srcB ? b.srcB : b.src
    }
    return b
};
pageConfig.FN_InitSlider = function (c, g) {
    var b = function (j, i) {
        return j.group - i.group
    };
    g.sort(b);
    var h = g[0].data, f = [], e = (h.length == 3) ? "style2" : "style1", a;
    f.push('<div class="slide-itemswrap"><ul class="slide-items"><li class="');
    f.push(e);
    f.push('" data-tag="');
    f.push(g[0].aid);
    f.push('">');
    for (var d = 0; d < h.length; d++) {
        a = this.FN_GetCompatibleData(h[d]);
        f.push('<div class="fore');
        f.push(d + 1);
        f.push('" width="');
        f.push(a.width);
        f.push('" height="');
        f.push(a.height);
        f.push('"><a target="_blank" href="');
        f.push(a.href);
        f.push('" title="');
        f.push(a.alt);
        f.push('"><img src="');
        if (d == 0) {
            f.push(a.src)
        } else {
            f.push('http://misc.360buyimg.com/lib/img/e/blank.gif" style="background:url(');
            f.push(a.src);
            f.push(") no-repeat center 0;")
        }
        f.push('" width="');
        f.push(a.width);
        f.push('" height="');
        f.push(a.height);
        f.push('" /></a></div>')
    }
    f.push('</li></ul></div><div class="slide-controls"><span class="curr">1</span></div>');
    document.getElementById(c).innerHTML = f.join("")
};