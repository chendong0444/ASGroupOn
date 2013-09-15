(function (a) {
    a.hideAdressbar = function (g) {
        g = typeof g === "string" ? document.querySelector(g) : g;
        var b = navigator.userAgent,
            i = ~b.indexOf("iPhone") || ~b.indexOf("iPod"),
            k = ~b.indexOf("iPad"),
            f = i || k,
            e = ~b.indexOf("Android"),
            j = a.navigator.standalone,
            c = 0;
        if (!(f || e) || !g) {
            return
        }
        if (e) {
            a.addEventListener("scroll", function () {
                g.style.height = a.innerHeight + "px"
            }, false)
        }
        var h = function () {
            var l = 0;
            if (f) {
                l = document.documentElement.clientHeight;
                if (i && !j) {
                    l += 60
                }
            } else {
                if (e) {
                    l = a.innerHeight + 56
                }
            }
            g.style.height = l + "px";
            setTimeout(scrollTo, 0, 0, 1)
        };
        (function d() {
            var l = g.offsetWidth;
            if (c === l) {
                return
            }
            c = l;
            h();
            a.addEventListener("resize", d, false)
        }())
    };
    hideAdressbar(document.body)
}(this));