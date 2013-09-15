(function (a) {
    a.fn.unveil = function (j) {
        var f = a(window),
            c = j || 0,
            e = window.devicePixelRatio > 1,
            h = e ? "data-src-retina" : "data-src",
            k = this,
            i, g, b;
        this.one("unveil", function () {
            b = this.getAttribute(h);
            b = b || this.getAttribute("data-src");
            if (b) {
                this.setAttribute("src", b)
            }
        });

        function d() {
            g = k.filter(function () {
                var m = a(this),
                    l = f.scrollTop(),
                    o = l + f.height(),
                    p = m.offset()
                        .top,
                    n = p + m.height();
                return n >= l - c && p <= o + c
            });
            i = g.trigger("unveil");
            k = k.not(i)
        }
        f.scroll(d);
        f.resize(d);
        d();
        return this
    }
})(Zepto);