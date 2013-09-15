
Function.prototype.overwrite = function (b) {
    var a = b;
    if (!a.original) {
        a.original = this
    }
    return a
};
Date.prototype.toString = Date.prototype.toString.overwrite(function (b) {
    var a = new String();
    if (typeof (b) == "string") {
        a = b;
        a = a.replace(/yyyy|YYYY/, this.getFullYear());
        a = a.replace(/yy|YY/, this.getFullYear().toString().substr(2, 2));
        a = a.replace(/MM/, this.getMonth() >= 9 ? this.getMonth() + 1 : "0" + (this.getMonth() + 1));
        a = a.replace(/M/, this.getMonth());
        a = a.replace(/dd|DD/, this.getDate() > 9 ? this.getDate() : "0" + this.getDate());
        a = a.replace(/d|D/, this.getDate());
        a = a.replace(/hh|HH/, this.getHours() > 9 ? this.getHours() : "0" + this.getHours());
        a = a.replace(/h|H/, this.getHours());
        a = a.replace(/mm/, this.getMinutes() > 9 ? this.getMinutes() : "0" + this.getMinutes());
        a = a.replace(/m/, this.getMinutes());
        a = a.replace(/ss|SS/, this.getSeconds() > 9 ? this.getSeconds() : "0" + this.getSeconds());
        a = a.replace(/s|S/, this.getSeconds())
    }
    return a
});
String.prototype.format = function () {
    var a = this;
    if (arguments.length > 0) {
        parameters = $.makeArray(arguments);
        $.each(parameters, function (b, c) {
            a = a.replace(new RegExp("\\{" + b + "\\}", "g"), c)
        })
    }
    return a
};
function StringBuilder() {
    this.strings = new Array();
    this.length = 0
}
StringBuilder.prototype.append = function (a) {
    this.strings.push(a);
    this.length += a.length
};
StringBuilder.prototype.toString = function (b, a) {
    return this.strings.join("").substr(b, a)
};
(function ($) {
    $.jmsajax = function (options) {
        var defaults = {
            type: "POST",
            dataType: "msjson",
            data: {},
            beforeSend: function (xhr) {
                xhr.setRequestHeader("Content-type", "application/json; charset=utf-8")
            },
            contentType: "application/json; charset=utf-8",
            error: function (x, s, m) {
                alert("Status: " + ((x.statusText) ? x.statusText : "Unknown") + "\nMessage: " + msJSON.parse(((x.responseText) ? x.responseText : "Unknown")).Message)
            }
        };
        var options = $.extend(defaults, options);
        if (options.method) {
            options.url += "/" + options.method
        }
        if (options.data) {
            if (options.type == "GET") {
                var data = "";
                for (var i in options.data) {
                    if (data != "") {
                        data += "&"
                    }
                    data += i + "=" + msJSON.stringify(options.data[i])
                }
                options.url += "?" + data;
                data = null;
                options.data = "{}"
            } else {
                if (options.type == "POST") {
                    options.data = msJSON.stringify(options.data)
                }
            }
        }
        if (options.success) {
            if (options.dataType) {
                if (options.dataType == "msjson") {
                    var base = options.success;
                    options.success = function (response, status) {
                        var y = dateparse(response);
                        if (options.version) {
                            if (options.version >= 3.5) {
                                y = y.d
                            }
                        } else {
                            if (response.indexOf('{"d":') == 0) {
                                y = y.d
                            }
                        }
                        base(y, status)
                    }
                }
            }
        }
        return $.ajax(options)
    };
    dateparse = function (data) {
        try {
            return msJSON.parse(data, function (key, value) {
                var a;
                if (typeof value === "string") {
                    if (value.indexOf("Date") >= 0) {
                        a = /^\/Date\(([0-9]+)\)\/$/.exec(value);
                        if (a) {
                            return new Date(parseInt(a[1], 10))
                        }
                    }
                }
                return value
            })
        } catch (e) {
            return null
        }
    };
    msJSON = function () {
        function f(n) {
            return n < 10 ? "0" + n : n
        }

        var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g, escapeable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g, gap, indent, meta = {
            "\b": "\\b",
            "\t": "\\t",
            "\n": "\\n",
            "\f": "\\f",
            "\r": "\\r",
            '"': '\\"',
            "\\": "\\\\"
        }, rep;
        function quote(string) {
            escapeable.lastIndex = 0;
            return escapeable.test(string) ? '"' + string.replace(escapeable, function (a) {
                var c = meta[a];
                if (typeof c === "string") {
                    return c
                }
                return "\\u" + ("0000" + (+(a.charCodeAt(0))).toString(16)).slice(-4)
            }) + '"' : '"' + string + '"'
        }

        function str(key, holder) {
            var i, k, v, length, mind = gap, partial, value = holder[key];
            if (value && typeof value === "object" && typeof value.toJSON === "function") {
                value = value.toJSON(key)
            }
            if (typeof rep === "function") {
                value = rep.call(holder, key, value)
            }
            switch (typeof value) {
                case "string":
                    return quote(value);
                case "number":
                    return isFinite(value) ? String(value) : "null";
                case "boolean":
                case "null":
                    return String(value);
                case "object":
                    if (!value) {
                        return "null"
                    }
                    if (value.toUTCString) {
                        return '"\\/Date(' + (value.getTime()) + ')\\/"'
                    }
                    gap += indent;
                    partial = [];
                    if (typeof value.length === "number" && !(value.propertyIsEnumerable("length"))) {
                        length = value.length;
                        for (i = 0; i < length; i += 1) {
                            partial[i] = str(i, value) || "null"
                        }
                        v = partial.length === 0 ? "[]" : gap ? "[\n" + gap + partial.join(",\n" + gap) + "\n" + mind + "]" : "[" + partial.join(",") + "]";
                        gap = mind;
                        return v
                    }
                    if (rep && typeof rep === "object") {
                        length = rep.length;
                        for (i = 0; i < length; i += 1) {
                            k = rep[i];
                            if (typeof k === "string") {
                                v = str(k, value, rep);
                                if (v) {
                                    partial.push(quote(k) + (gap ? ": " : ":") + v)
                                }
                            }
                        }
                    } else {
                        for (k in value) {
                            if (Object.hasOwnProperty.call(value, k)) {
                                v = str(k, value, rep);
                                if (v) {
                                    partial.push(quote(k) + (gap ? ": " : ":") + v)
                                }
                            }
                        }
                    }
                    v = partial.length === 0 ? "{}" : gap ? "{\n" + gap + partial.join(",\n" + gap) + "\n" + mind + "}" : "{" + partial.join(",") + "}";
                    gap = mind;
                    return v
            }
        }
        return {
            stringify: function (value, replacer, space) {
                var i;
                gap = "";
                indent = "";
                if (typeof space === "number") {
                    for (i = 0; i < space; i += 1) {
                        indent += " "
                    }
                } else {
                    if (typeof space === "string") {
                        indent = space
                    }
                }
                rep = replacer;
                if (replacer && typeof replacer !== "function" && (typeof replacer !== "object" || typeof replacer.length !== "number")) {
                    throw new Error("JSON.stringify")
                }
                return str("", {
                    "": value
                })
            },
            parse: function (text, reviver) {
                var j;
                function walk(holder, key) {
                    var k, v, value = holder[key];
                    if (value && typeof value === "object") {
                        for (k in value) {
                            if (Object.hasOwnProperty.call(value, k)) {
                                v = walk(value, k);
                                if (v !== undefined) {
                                    value[k] = v
                                } else {
                                    delete value[k]
                                }
                            }
                        }
                    }
                    return reviver.call(holder, key, value)
                }
                cx.lastIndex = 0;
                if (cx.test(text)) {
                    text = text.replace(cx, function (a) {
                        return "\\u" + ("0000" + (+(a.charCodeAt(0))).toString(16)).slice(-4)
                    })
                }
                if (/^[\],:{}\s]*$/.test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, "@").replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, "]").replace(/(?:^|:|,)(?:\s*\[)+/g, ""))) {
                    j = eval("(" + text + ")");
                    return typeof reviver === "function" ? walk({
                        "": j
                    }, "") : j
                }
                throw new SyntaxError("JSON.parse")
            }
        }
    } ()
})(jQuery);
var TrimPath;
(function () {
    if (TrimPath == null) {
        TrimPath = new Object()
    }
    if (TrimPath.evalEx == null) {
        TrimPath.evalEx = function (src) {
            return eval(src)
        }
    }
    var UNDEFINED;
    if (Array.prototype.pop == null) {
        Array.prototype.pop = function () {
            if (this.length === 0) {
                return UNDEFINED
            }
            return this[--this.length]
        }
    }
    if (Array.prototype.push == null) {
        Array.prototype.push = function () {
            for (var i = 0; i < arguments.length; ++i) {
                this[this.length] = arguments[i]
            }
            return this.length
        }
    }
    TrimPath.parseTemplate = function (tmplContent, optTmplName, optEtc) {
        if (optEtc == null) {
            optEtc = TrimPath.parseTemplate_etc
        }
        var funcSrc = parse(tmplContent, optTmplName, optEtc);
        var func = TrimPath.evalEx(funcSrc, optTmplName, 1);
        if (func != null) {
            return new optEtc.Template(optTmplName, tmplContent, funcSrc, func, optEtc)
        }
        return null
    };
    try {
        String.prototype.process = function (context, optFlags) {
            var template = TrimPath.parseTemplate(this, null);
            if (template != null) {
                return template.process(context, optFlags)
            }
            return this
        }
    } catch (e) {
    }
    TrimPath.parseTemplate_etc = {};
    TrimPath.parseTemplate_etc.statementTag = "forelse|for|if|elseif|else|var|macro";
    TrimPath.parseTemplate_etc.statementDef = {
        "if": {
            delta: 1,
            prefix: "if (",
            suffix: ") {",
            paramMin: 1
        },
        "else": {
            delta: 0,
            prefix: "} else {"
        },
        elseif: {
            delta: 0,
            prefix: "} else if (",
            suffix: ") {",
            paramDefault: "true"
        },
        "/if": {
            delta: -1,
            prefix: "}"
        },
        "for": {
            delta: 1,
            paramMin: 3,
            prefixFunc: function (stmtParts, state, tmplName, etc) {
                if (stmtParts[2] != "in") {
                    throw new etc.ParseError(tmplName, state.line, "bad for loop statement: " + stmtParts.join(" "))
                }
                var iterVar = stmtParts[1];
                var listVar = "__LIST__" + iterVar;
                return ["var ", listVar, " = ", stmtParts[3], ";", "var __LENGTH_STACK__;", "if (typeof(__LENGTH_STACK__) == 'undefined' || !__LENGTH_STACK__.length) __LENGTH_STACK__ = new Array();", "__LENGTH_STACK__[__LENGTH_STACK__.length] = 0;", "if ((", listVar, ") != null) { ", "var ", iterVar, "_ct = 0;", "for (var ", iterVar, "_index in ", listVar, ") { ", iterVar, "_ct++;", "if (typeof(", listVar, "[", iterVar, "_index]) == 'function') {continue;}", "__LENGTH_STACK__[__LENGTH_STACK__.length - 1]++;", "var ", iterVar, " = ", listVar, "[", iterVar, "_index];"].join("")
            }
        },
        forelse: {
            delta: 0,
            prefix: "} } if (__LENGTH_STACK__[__LENGTH_STACK__.length - 1] == 0) { if (",
            suffix: ") {",
            paramDefault: "true"
        },
        "/for": {
            delta: -1,
            prefix: "} }; delete __LENGTH_STACK__[__LENGTH_STACK__.length - 1];"
        },
        "var": {
            delta: 0,
            prefix: "var ",
            suffix: ";"
        },
        macro: {
            delta: 1,
            prefixFunc: function (stmtParts, state, tmplName, etc) {
                var macroName = stmtParts[1].split("(")[0];
                return ["var ", macroName, " = function", stmtParts.slice(1).join(" ").substring(macroName.length), "{ var _OUT_arr = []; var _OUT = { write: function(m) { if (m) _OUT_arr.push(m); } }; "].join("")
            }
        },
        "/macro": {
            delta: -1,
            prefix: " return _OUT_arr.join(''); };"
        }
    };
    TrimPath.parseTemplate_etc.modifierDef = {
        eat: function (v) {
            return ""
        },
        escape: function (s) {
            return String(s).replace(/&/g, "&").replace(/</g, "<").replace(/>/g, ">")
        },
        capitalize: function (s) {
            return String(s).toUpperCase()
        },
        "default": function (s, d) {
            return s != null ? s : d
        }
    };
    TrimPath.parseTemplate_etc.modifierDef.h = TrimPath.parseTemplate_etc.modifierDef.escape;
    TrimPath.parseTemplate_etc.Template = function (tmplName, tmplContent, funcSrc, func, etc) {
        this.process = function (context, flags) {
            if (context == null) {
                context = {}
            }
            if (context._MODIFIERS == null) {
                context._MODIFIERS = {}
            }
            if (context.defined == null) {
                context.defined = function (str) {
                    return (context[str] != undefined)
                }
            }
            for (var k in etc.modifierDef) {
                if (context._MODIFIERS[k] == null) {
                    context._MODIFIERS[k] = etc.modifierDef[k]
                }
            }
            if (flags == null) {
                flags = {}
            }
            var resultArr = [];
            var resultOut = {
                write: function (m) {
                    resultArr.push(m)
                }
            };
            try {
                func(resultOut, context, flags)
            } catch (e) {
                if (flags.throwExceptions == true) {
                    throw e
                }
                var result = new String(resultArr.join("") + "[ERROR: " + e.toString() + (e.message ? "; " + e.message : "") + "]");
                result.exception = e;
                return result
            }
            return resultArr.join("")
        };
        this.name = tmplName;
        this.source = tmplContent;
        this.sourceFunc = funcSrc;
        this.toString = function () {
            return "TrimPath.Template [" + tmplName + "]"
        }
    };
    TrimPath.parseTemplate_etc.ParseError = function (name, line, message) {
        this.name = name;
        this.line = line;
        this.message = message
    };
    TrimPath.parseTemplate_etc.ParseError.prototype.toString = function () {
        return ("TrimPath template ParseError in " + this.name + ": line " + this.line + ", " + this.message)
    };
    var parse = function (body, tmplName, etc) {
        body = cleanWhiteSpace(body);
        var funcText = ["var TrimPath_Template_TEMP = function(_OUT, _CONTEXT, _FLAGS) { with (_CONTEXT) {"];
        var state = {
            stack: [],
            line: 1
        };
        var endStmtPrev = -1;
        while (endStmtPrev + 1 < body.length) {
            var begStmt = endStmtPrev;
            begStmt = body.indexOf("{", begStmt + 1);
            while (begStmt >= 0) {
                var endStmt = body.indexOf("}", begStmt + 1);
                var stmt = body.substring(begStmt, endStmt);
                var blockrx = stmt.match(/^\{(cdata|minify|eval)/);
                if (blockrx) {
                    var blockType = blockrx[1];
                    var blockMarkerBeg = begStmt + blockType.length + 1;
                    var blockMarkerEnd = body.indexOf("}", blockMarkerBeg);
                    if (blockMarkerEnd >= 0) {
                        var blockMarker;
                        if (blockMarkerEnd - blockMarkerBeg <= 0) {
                            blockMarker = "{/" + blockType + "}"
                        } else {
                            blockMarker = body.substring(blockMarkerBeg + 1, blockMarkerEnd)
                        }
                        var blockEnd = body.indexOf(blockMarker, blockMarkerEnd + 1);
                        if (blockEnd >= 0) {
                            emitSectionText(body.substring(endStmtPrev + 1, begStmt), funcText);
                            var blockText = body.substring(blockMarkerEnd + 1, blockEnd);
                            if (blockType == "cdata") {
                                emitText(blockText, funcText)
                            } else {
                                if (blockType == "minify") {
                                    emitText(scrubWhiteSpace(blockText), funcText)
                                } else {
                                    if (blockType == "eval") {
                                        if (blockText != null && blockText.length > 0) {
                                            funcText.push("_OUT.write( (function() { " + blockText + " })() );")
                                        }
                                    }
                                }
                            }
                            begStmt = endStmtPrev = blockEnd + blockMarker.length - 1
                        }
                    }
                } else {
                    if (body.charAt(begStmt - 1) != "$" && body.charAt(begStmt - 1) != "\\") {
                        var offset = (body.charAt(begStmt + 1) == "/" ? 2 : 1);
                        if (body.substring(begStmt + offset, begStmt + 10 + offset).search(TrimPath.parseTemplate_etc.statementTag) == 0) {
                            break
                        }
                    }
                }
                begStmt = body.indexOf("{", begStmt + 1)
            }
            if (begStmt < 0) {
                break
            }
            var endStmt = body.indexOf("}", begStmt + 1);
            if (endStmt < 0) {
                break
            }
            emitSectionText(body.substring(endStmtPrev + 1, begStmt), funcText);
            emitStatement(body.substring(begStmt, endStmt + 1), state, funcText, tmplName, etc);
            endStmtPrev = endStmt
        }
        emitSectionText(body.substring(endStmtPrev + 1), funcText);
        if (state.stack.length != 0) {
            throw new etc.ParseError(tmplName, state.line, "unclosed, unmatched statement(s): " + state.stack.join(","))
        }
        funcText.push("}}; TrimPath_Template_TEMP");
        return funcText.join("")
    };
    var emitStatement = function (stmtStr, state, funcText, tmplName, etc) {
        var parts = stmtStr.slice(1, -1).split(" ");
        var stmt = etc.statementDef[parts[0]];
        if (stmt == null) {
            emitSectionText(stmtStr, funcText);
            return
        }
        if (stmt.delta < 0) {
            if (state.stack.length <= 0) {
                throw new etc.ParseError(tmplName, state.line, "close tag does not match any previous statement: " + stmtStr)
            }
            state.stack.pop()
        }
        if (stmt.delta > 0) {
            state.stack.push(stmtStr)
        }
        if (stmt.paramMin != null && stmt.paramMin >= parts.length) {
            throw new etc.ParseError(tmplName, state.line, "statement needs more parameters: " + stmtStr)
        }
        if (stmt.prefixFunc != null) {
            funcText.push(stmt.prefixFunc(parts, state, tmplName, etc))
        } else {
            funcText.push(stmt.prefix)
        }
        if (stmt.suffix != null) {
            if (parts.length <= 1) {
                if (stmt.paramDefault != null) {
                    funcText.push(stmt.paramDefault)
                }
            } else {
                for (var i = 1; i < parts.length; i++) {
                    if (i > 1) {
                        funcText.push(" ")
                    }
                    funcText.push(parts[i])
                }
            }
            funcText.push(stmt.suffix)
        }
    };
    var emitSectionText = function (text, funcText) {
        if (text.length <= 0) {
            return
        }
        var nlPrefix = 0;
        var nlSuffix = text.length - 1;
        while (nlPrefix < text.length && (text.charAt(nlPrefix) == "\n")) {
            nlPrefix++
        }
        while (nlSuffix >= 0 && (text.charAt(nlSuffix) == " " || text.charAt(nlSuffix) == "\t")) {
            nlSuffix--
        }
        if (nlSuffix < nlPrefix) {
            nlSuffix = nlPrefix
        }
        if (nlPrefix > 0) {
            funcText.push('if (_FLAGS.keepWhitespace == true) _OUT.write("');
            var s = text.substring(0, nlPrefix).replace("\n", "\\n");
            if (s.charAt(s.length - 1) == "\n") {
                s = s.substring(0, s.length - 1)
            }
            funcText.push(s);
            funcText.push('");')
        }
        var lines = text.substring(nlPrefix, nlSuffix + 1).split("\n");
        for (var i = 0; i < lines.length; i++) {
            emitSectionTextLine(lines[i], funcText);
            if (i < lines.length - 1) {
                funcText.push('_OUT.write("\\n");\n')
            }
        }
        if (nlSuffix + 1 < text.length) {
            funcText.push('if (_FLAGS.keepWhitespace == true) _OUT.write("');
            var s = text.substring(nlSuffix + 1).replace("\n", "\\n");
            if (s.charAt(s.length - 1) == "\n") {
                s = s.substring(0, s.length - 1)
            }
            funcText.push(s);
            funcText.push('");')
        }
    };
    var emitSectionTextLine = function (line, funcText) {
        var endMarkPrev = "}";
        var endExprPrev = -1;
        while (endExprPrev + endMarkPrev.length < line.length) {
            var begMark = "${", endMark = "}";
            var begExpr = line.indexOf(begMark, endExprPrev + endMarkPrev.length);
            if (begExpr < 0) {
                break
            }
            if (line.charAt(begExpr + 2) == "%") {
                begMark = "${%";
                endMark = "%}"
            }
            var endExpr = line.indexOf(endMark, begExpr + begMark.length);
            if (endExpr < 0) {
                break
            }
            emitText(line.substring(endExprPrev + endMarkPrev.length, begExpr), funcText);
            var exprArr = line.substring(begExpr + begMark.length, endExpr).replace(/\|\|/g, "#@@#").split("|");
            for (var k in exprArr) {
                if (exprArr[k].replace) {
                    exprArr[k] = exprArr[k].replace(/#@@#/g, "||")
                }
            }
            funcText.push("_OUT.write(");
            emitExpression(exprArr, exprArr.length - 1, funcText);
            funcText.push(");");
            endExprPrev = endExpr;
            endMarkPrev = endMark
        }
        emitText(line.substring(endExprPrev + endMarkPrev.length), funcText)
    };
    var emitText = function (text, funcText) {
        if (text == null || text.length <= 0) {
            return
        }
        text = text.replace(/\\/g, "\\\\");
        text = text.replace(/\n/g, "\\n");
        text = text.replace(/"/g, '\\"');
        funcText.push('_OUT.write("');
        funcText.push(text);
        funcText.push('");')
    };
    var emitExpression = function (exprArr, index, funcText) {
        var expr = exprArr[index];
        if (index <= 0) {
            funcText.push(expr);
            return
        }
        var parts = expr.split(":");
        funcText.push('_MODIFIERS["');
        funcText.push(parts[0]);
        funcText.push('"](');
        emitExpression(exprArr, index - 1, funcText);
        if (parts.length > 1) {
            funcText.push(",");
            funcText.push(parts[1])
        }
        funcText.push(")")
    };
    var cleanWhiteSpace = function (result) {
        result = result.replace(/\t/g, "    ");
        result = result.replace(/\r\n/g, "\n");
        result = result.replace(/\r/g, "\n");
        result = result.replace(/^(\s*\S*(\s+\S+)*)\s*$/, "$1");
        return result
    };
    var scrubWhiteSpace = function (result) {
        result = result.replace(/^\s+/g, "");
        result = result.replace(/\s+$/g, "");
        result = result.replace(/\s+/g, " ");
        result = result.replace(/^(\s*\S*(\s+\S+)*)\s*$/, "$1");
        return result
    };
    TrimPath.parseDOMTemplate = function (elementId, optDocument, optEtc) {
        if (optDocument == null) {
            optDocument = document
        }
        var element = optDocument.getElementById(elementId);
        var content = element.value;
        if (content == null) {
            content = element.innerHTML
        }
        content = content.replace(/</g, "<").replace(/>/g, ">");
        return TrimPath.parseTemplate(content, elementId, optEtc)
    };
    TrimPath.processDOMTemplate = function (elementId, context, optFlags, optDocument, optEtc) {
        return TrimPath.parseDOMTemplate(elementId, optDocument, optEtc).process(context, optFlags)
    }
})();
(function (a) {
    a.fn.Jtab = function (d, h) {
        if (!this.length) {
            return
        }
        if (typeof d == "function") {
            h = d;
            d = {}
        }
        var b = a.extend({
            type: "static",
            auto: false,
            event: "mouseover",
            currClass: "curr",
            source: "data-tag",
            hookKey: "data-widget",
            hookItemVal: "tab-item",
            hookContentVal: "tab-content",
            stay: 5000,
            delay: 100,
            threshold: null,
            mainTimer: null,
            subTimer: null,
            index: 0,
            compatible: false
        }, d || {});
        var f = a(this).find("*[" + b.hookKey + "=" + b.hookItemVal + "]"), e = a(this).find("*[" + b.hookKey + "=" + b.hookContentVal + "]"), k = b.source.toLowerCase().match(/http:\/\/|\d|\.aspx|\.ascx|\.asp|\.php|\.html\.htm|.shtml|.js/g);
        if (f.length != e.length) {
            return false
        }
        var j = function (m, l) {
            b.subTimer = setTimeout(function () {
                f.eq(b.index).removeClass(b.currClass);
                if (b.compatible) {
                    e.eq(b.index).hide()
                }
                if (l) {
                    b.index++;
                    if (b.index == f.length) {
                        b.index = 0
                    }
                } else {
                    b.index = m
                }
                b.type = (f.eq(b.index).attr(b.source) != null) ? "dynamic" : "static";
                c()
            }, b.delay)
        };
        var g = function () {
            b.mainTimer = setInterval(function () {
                j(b.index, true)
            }, b.stay)
        };
        var c = function () {
            f.eq(b.index).addClass(b.currClass);
            if (b.compatible) {
                e.eq(b.index).show()
            }
            switch (b.type) {
                default:
                case "static":
                    var l = "";
                    break;
                case "dynamic":
                    var l = (!k) ? f.eq(b.index).attr(b.source) : b.source;
                    f.eq(b.index).removeAttr(b.source);
                    break
            }
            if (h) {
                h(l, e.eq(b.index), b.index)
            }
        };
        f.each(function (l) {
            a(this).bind(b.event, function () {
                clearTimeout(b.subTimer);
                clearInterval(b.mainTimer);
                j(l, false)
            }).bind("mouseleave", function () {
                if (b.auto) {
                    g()
                } else {
                    return
                }
            })
        });
        if (b.type == "dynamic") {
            j(b.index, false)
        }
        if (b.auto) {
            g()
        }
    }
})(jQuery);
(function (a) {
    a.Jtimer = function (d, h) {
        var c = a.extend({
            pids: null,
            template: null,
            reset: null,
            mainPlaceholder: "timed",
            subPlaceholder: "timer",
            resetPlaceholder: "reset",
            iconPlaceholder: "icon",
            finishedClass: "",
            timer: []
        }, d || {}), g = function (l) {
            var k = l.split(" "), j = k[0].split("-"), m = k[1].split(":");
            return new Date(j[0], j[1] - 1, j[2], m[0], m[1], m[2])
        }, e = function (j) {
            if (String(j).length < 2) {
                j = "0" + j
            }
            return j
        }, f = function (t, p) {
            if (p == {} || !p || !p.start || !p.end) {
                return
            }
            var j = g(p.start), l = g(p.server), n = g(p.end), v, u, o, s = (j - l) / 1000, m = (n - l) / 1000, w = "#" + c.mainPlaceholder + t, k = "#" + c.subPlaceholder + p.qid, r = "#" + c.resetPlaceholder + p.qid;
            if (s <= 0) {
                // var q = c.template.process(p);
                //a(w).html(q)
            }
            c.timer[p.qid] = setInterval(function () {
                if (s > 0) {
                    clearInterval(c.timer[p.qid]);
                    return
                } else {
                    if (m > 0) {
                        v = Math.floor(m / 3600);
                        u = Math.floor((m - v * 3600) / 60);
                        o = (m - v * 3600) % 60;
                        a(k).html("\u5269\u4f59<b>" + e(v) + "</b>\u5c0f\u65f6<b>" + e(u) + "</b>\u5206<b>" + e(o) + "</b>\u79d2");
                        m--
                    } else {
                        a(k).html("\u62a2\u8d2d\u7ed3\u675f\uff01");
                        if (c.iconPlaceholder) {
                            iconElement = "#" + c.iconPlaceholder + p.qid;
                            a(iconElement).attr("class", c.finishedClass).html("\u62a2\u5b8c")
                        }
                        if (c.reset) {
                            a(k).append('<a href="javascript:void(0)" id="' + r.substring(1) + '">\u5237\u65b0</a>');
                            a(r).bind("click", function () {
                                a.each(c.timer, function (x) {
                                    clearInterval(this)
                                });
                                c.reset()
                            })
                        }
                        clearInterval(c.timer[p.qid])
                    }
                }
            }, 1000)
        }, b = function (k, j) {
            return ((g(k.end) - g(k.server)) - (g(j.end) - g(j.server)))
        };
    }
})(jQuery);
(function (a) {
    a.fn.Jslider = function (h, n) {
        if (!this.length) {
            return
        }
        if (typeof h == "function") {
            n = h;
            h = {}
        }
        var d = a.extend({
            auto: false,
            reInit: false,
            data: [],
            defaultIndex: 0,
            slideWidth: 0,
            slideHeight: 0,
            slideDirection: 1,
            speed: "normal",
            stay: 5000,
            delay: 150,
            maxAmount: null,
            template: null,
            showControls: true
        }, h || {});
        var g = a(this), e = null, k = null, j = null, c = null, m = null, o = function () {
            var p;
            if (d.maxAmount && d.maxAmount < d.data.length) {
                d.data.splice(d.maxAmount, d.data.length - d.maxAmount)
            }
            if (typeof d.data == "object") {
                if (d.data.length) {
                    p = {};
                    p.json = d.data
                } else {
                    p = d.data
                }
            }
            var r = d.template;
            if (d.reInit) {
                var s, u = r.controlsContent.process(p);
                if (p != "") {
                    p.json = p.json.slice(1);
                    s = r.itemsContent.process(p);
                    g.find(".slide-items").eq(0).append(s);
                    g.find(".slide-controls").eq(0).html(u)

                }

            } else {
                var t = r.itemsWrap.replace("{innerHTML}", r.itemsContent) + r.controlsWrap.replace("{innerHTML}", r.controlsContent), q = t.process(p);
                g.html(q)
            }
            e = g.find(".slide-items");
            k = g.find(".slide-controls");
            j = k.find("span");
            f();
            l();
            if (n) {
                n(g)
            }
        }, f = function () {
            j.bind("mouseover", function () {
                var p = j.index(this);
                if (p == d.defaultIndex) {
                    return
                }
                clearTimeout(m);
                clearInterval(c);
                m = setTimeout(function () {
                    b(p)
                }, d.delay)
            }).bind("mouseleave", function () {
                clearTimeout(m);
                clearInterval(c);
                l()
            });
            e.bind("mouseover", function () {
                clearTimeout(m);
                clearInterval(c)
            }).bind("mouseleave", function () {
                l()
            })
        }, b = function (p) {
            j.each(function (v) {
                if (v == p) {
                    a(this).addClass("curr")
                } else {
                    a(this).removeClass("curr")
                }
            });
            var u = 0, t = 0;
            if (d.slideDirection == 3) {
                var q = e.children(), r = q.eq(d.defaultIndex), s = q.eq(p);
                r.css({
                    zIndex: 0
                });
                s.css({
                    zIndex: 1
                });
                r.fadeOut("fase");
                s.fadeIn("slow");
                d.defaultIndex = p
            } else {
                if (d.slideDirection == 1) {
                    e.css({
                        width: d.slideWidth * d.data.length
                    });
                    u = -d.slideWidth * p
                } else {
                    t = -d.slideHeight * p
                }
                e.animate({
                    top: t + "px",
                    left: u + "px"
                }, d.speed, function () {
                    d.defaultIndex = p
                })
            }
        }, l = function () {
            if (d.auto) {
                c = setInterval(function () {
                    var p = d.defaultIndex;
                    p++;
                    if (p == d.data.length) {
                        p = 0
                    }
                    b(p)
                }, d.stay)
            }
        };
        o()
    }
})(jQuery);
pageConfig.FN_InitSidebar = function () {
    if (!$("#toppanel").length) {
        $(document.body).prepend('<div class="w ld" id="toppanel"></div>')
    }
    $("#toppanel").append('<div id="sidepanel" class="hide"></div>');
    var a = $("#sidepanel");
    this.scroll = function () {
        var b = this;
        $(window).bind("scroll", function () {
            var c = document.body.scrollTop || document.documentElement.scrollTop;
            if (c == 0) {
                a.hide()
            } else {
                a.show()
            }
        });
        b.initCss();
        $(window).bind("resize", function () {
            b.initCss()
        })
    };
    this.initCss = function () {
        var b, c = pageConfig.compatible ? 1210 : 990;
        if (screen.width >= 1210) {
            if ($.browser.msie && $.browser.version <= 6) {
                b = {
                    right: "-26px"
                }
            } else {
                b = {
                    right: (document.documentElement.clientWidth - c) / 2 - 136 + "px"
                }
            }
            a.css(b)
        }
    };
    this.addCss = function (b) {
        a.css(b)
    };
    this.addItem = function (b) {
        a.append(b)
    };
    this.setTop = function () {
        this.addItem("<a href='#' class='gotop' title='\u4f7f\u7528\u5feb\u6377\u952eT\u4e5f\u53ef\u8fd4\u56de\u9876\u90e8\u54e6\uff01'><b></b>\u8fd4\u56de\u9876\u90e8</a>")
    }
};
(function (a) {
    a.fn.Jdropdown = function (d, e) {
        if (!this.length) {
            return
        }
        if (typeof d == "function") {
            e = d;
            d = {}
        }
        var c = a.extend({
            event: "mouseover",
            current: "hover",
            delay: 0
        }, d || {});
        var b = (c.event == "mouseover") ? "mouseout" : "mouseleave";
        a.each(this, function () {
            var h = null,
                g = null,
                f = false;
            a(this)
                .bind(c.event, function () {
                    if (f) {
                        clearTimeout(g)
                    } else {
                        var j = a(this);
                        h = setTimeout(function () {
                            j.addClass(c.current);
                            f = true;
                            if (e) {
                                e(j)
                            }
                        }, c.delay)
                    }
                })
                .bind(b, function () {
                    if (f) {
                        var j = a(this);
                        g = setTimeout(function () {
                            j.removeClass(c.current);
                            f = false
                        }, c.delay)
                    } else {
                        clearTimeout(h)
                    }
                })
        })
    }
})(jQuery);